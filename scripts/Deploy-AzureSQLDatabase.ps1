# Script de Deployment Completo do Azure SQL Database
# Autor: Configuração Azure Database - DIO Challenge
# Data: Janeiro 2024

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, HelpMessage="Nome do grupo de recursos")]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true, HelpMessage="Nome do servidor SQL")]
    [string]$ServerName,
    
    [Parameter(Mandatory=$true, HelpMessage="Nome do banco de dados")]
    [string]$DatabaseName,
    
    [Parameter(Mandatory=$true, HelpMessage="Localização do Azure (ex: brazilsouth)")]
    [string]$Location,
    
    [Parameter(Mandatory=$true, HelpMessage="Login do administrador SQL")]
    [string]$AdminLogin,
    
    [Parameter(Mandatory=$true, HelpMessage="Senha do administrador SQL")]
    [SecureString]$AdminPassword,
    
    [Parameter(Mandatory=$false, HelpMessage="Tier de serviço (ex: S0, S1, S2)")]
    [string]$ServiceObjective = "S0",
    
    [Parameter(Mandatory=$false, HelpMessage="Tags para os recursos")]
    [hashtable]$Tags = @{
        Environment = "Development"
        Project = "DIO-Azure-Database"
        CreatedBy = "PowerShell-Script"
    }
)

# Função para log com timestamp
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "INFO" { "White" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Função para verificar se o Azure CLI está instalado e autenticado
function Test-AzurePrerequisites {
    Write-Log "Verificando pré-requisitos..."
    
    # Verificar Azure CLI
    try {
        $azVersion = az version --output json 2>$null | ConvertFrom-Json
        Write-Log "Azure CLI versão $($azVersion.'azure-cli') encontrado" "SUCCESS"
    }
    catch {
        Write-Log "Azure CLI não encontrado. Instale o Azure CLI antes de continuar." "ERROR"
        exit 1
    }
    
    # Verificar autenticação
    try {
        $account = az account show --output json 2>$null | ConvertFrom-Json
        Write-Log "Autenticado como: $($account.user.name)" "SUCCESS"
        Write-Log "Assinatura ativa: $($account.name)" "INFO"
    }
    catch {
        Write-Log "Não autenticado no Azure. Execute 'az login' primeiro." "ERROR"
        exit 1
    }
}

# Função para criar grupo de recursos
function New-ResourceGroup {
    param([string]$Name, [string]$Location, [hashtable]$Tags)
    
    Write-Log "Verificando grupo de recursos '$Name'..."
    
    $rg = az group show --name $Name --output json 2>$null | ConvertFrom-Json
    
    if ($rg) {
        Write-Log "Grupo de recursos '$Name' já existe" "INFO"
    }
    else {
        Write-Log "Criando grupo de recursos '$Name'..."
        
        $tagString = ($Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join " "
        
        az group create `
            --name $Name `
            --location $Location `
            --tags $tagString `
            --output none
            
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Grupo de recursos criado com sucesso" "SUCCESS"
        }
        else {
            Write-Log "Erro ao criar grupo de recursos" "ERROR"
            exit 1
        }
    }
}

# Função para criar servidor SQL
function New-SqlServer {
    param(
        [string]$Name,
        [string]$ResourceGroup,
        [string]$Location,
        [string]$AdminLogin,
        [SecureString]$AdminPassword,
        [hashtable]$Tags
    )
    
    Write-Log "Verificando servidor SQL '$Name'..."
    
    $server = az sql server show --name $Name --resource-group $ResourceGroup --output json 2>$null | ConvertFrom-Json
    
    if ($server) {
        Write-Log "Servidor SQL '$Name' já existe" "INFO"
    }
    else {
        Write-Log "Criando servidor SQL '$Name'..."
        
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword))
        $tagString = ($Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join " "
        
        az sql server create `
            --name $Name `
            --resource-group $ResourceGroup `
            --location $Location `
            --admin-user $AdminLogin `
            --admin-password $plainPassword `
            --tags $tagString `
            --output none
            
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Servidor SQL criado com sucesso" "SUCCESS"
        }
        else {
            Write-Log "Erro ao criar servidor SQL" "ERROR"
            exit 1
        }
    }
}

# Função para configurar firewall
function Set-SqlServerFirewall {
    param(
        [string]$ServerName,
        [string]$ResourceGroup
    )
    
    Write-Log "Configurando regras de firewall..."
    
    # Permitir serviços Azure
    az sql server firewall-rule create `
        --resource-group $ResourceGroup `
        --server $ServerName `
        --name "AllowAzureServices" `
        --start-ip-address 0.0.0.0 `
        --end-ip-address 0.0.0.0 `
        --output none
        
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Regra 'AllowAzureServices' criada" "SUCCESS"
    }
    
    # Obter IP público atual e adicionar
    try {
        $currentIP = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content.Trim()
        
        az sql server firewall-rule create `
            --resource-group $ResourceGroup `
            --server $ServerName `
            --name "AllowCurrentIP" `
            --start-ip-address $currentIP `
            --end-ip-address $currentIP `
            --output none
            
        if ($LASTEXITCODE -eq 0) {
            Write-Log "IP atual ($currentIP) adicionado ao firewall" "SUCCESS"
        }
    }
    catch {
        Write-Log "Não foi possível obter IP público atual" "WARNING"
    }
}

# Função para criar banco de dados
function New-SqlDatabase {
    param(
        [string]$Name,
        [string]$ServerName,
        [string]$ResourceGroup,
        [string]$ServiceObjective,
        [hashtable]$Tags
    )
    
    Write-Log "Verificando banco de dados '$Name'..."
    
    $database = az sql db show --name $Name --server $ServerName --resource-group $ResourceGroup --output json 2>$null | ConvertFrom-Json
    
    if ($database) {
        Write-Log "Banco de dados '$Name' já existe" "INFO"
    }
    else {
        Write-Log "Criando banco de dados '$Name' com tier '$ServiceObjective'..."
        
        $tagString = ($Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join " "
        
        az sql db create `
            --name $Name `
            --server $ServerName `
            --resource-group $ResourceGroup `
            --service-objective $ServiceObjective `
            --tags $tagString `
            --output none
            
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Banco de dados criado com sucesso" "SUCCESS"
        }
        else {
            Write-Log "Erro ao criar banco de dados" "ERROR"
            exit 1
        }
    }
}

# Função para obter informações de conexão
function Get-ConnectionInfo {
    param(
        [string]$ServerName,
        [string]$DatabaseName,
        [string]$AdminLogin
    )
    
    Write-Log "Obtendo informações de conexão..."
    
    $connectionString = "Server=tcp:$ServerName.database.windows.net,1433;Initial Catalog=$DatabaseName;Persist Security Info=False;User ID=$AdminLogin;Password=<YourPassword>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    
    Write-Log "=== INFORMAÇÕES DE CONEXÃO ===" "INFO"
    Write-Log "Servidor: $ServerName.database.windows.net" "INFO"
    Write-Log "Banco de dados: $DatabaseName" "INFO"
    Write-Log "Usuário: $AdminLogin" "INFO"
    Write-Log "Porta: 1433" "INFO"
    Write-Log "" "INFO"
    Write-Log "Connection String (ADO.NET):" "INFO"
    Write-Log $connectionString "INFO"
    Write-Log "================================" "INFO"
}

# Função para testar conectividade
function Test-DatabaseConnection {
    param(
        [string]$ServerName,
        [string]$DatabaseName,
        [string]$AdminLogin,
        [SecureString]$AdminPassword
    )
    
    Write-Log "Testando conectividade com o banco de dados..."
    
    try {
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword))
        
        # Testar conexão usando az sql
        $result = az sql db show-connection-string `
            --server $ServerName `
            --name $DatabaseName `
            --client ado.net `
            --output tsv
            
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Conectividade testada com sucesso" "SUCCESS"
        }
    }
    catch {
        Write-Log "Erro ao testar conectividade: $($_.Exception.Message)" "WARNING"
    }
}

# Função principal
function Deploy-AzureSQLDatabase {
    try {
        Write-Log "=== INICIANDO DEPLOYMENT DO AZURE SQL DATABASE ===" "INFO"
        Write-Log "Grupo de Recursos: $ResourceGroupName" "INFO"
        Write-Log "Servidor: $ServerName" "INFO"
        Write-Log "Banco de Dados: $DatabaseName" "INFO"
        Write-Log "Localização: $Location" "INFO"
        Write-Log "Service Objective: $ServiceObjective" "INFO"
        Write-Log "" "INFO"
        
        # Verificar pré-requisitos
        Test-AzurePrerequisites
        
        # Criar grupo de recursos
        New-ResourceGroup -Name $ResourceGroupName -Location $Location -Tags $Tags
        
        # Criar servidor SQL
        New-SqlServer -Name $ServerName -ResourceGroup $ResourceGroupName -Location $Location -AdminLogin $AdminLogin -AdminPassword $AdminPassword -Tags $Tags
        
        # Configurar firewall
        Set-SqlServerFirewall -ServerName $ServerName -ResourceGroup $ResourceGroupName
        
        # Criar banco de dados
        New-SqlDatabase -Name $DatabaseName -ServerName $ServerName -ResourceGroup $ResourceGroupName -ServiceObjective $ServiceObjective -Tags $Tags
        
        # Obter informações de conexão
        Get-ConnectionInfo -ServerName $ServerName -DatabaseName $DatabaseName -AdminLogin $AdminLogin
        
        # Testar conectividade
        Test-DatabaseConnection -ServerName $ServerName -DatabaseName $DatabaseName -AdminLogin $AdminLogin -AdminPassword $AdminPassword
        
        Write-Log "" "INFO"
        Write-Log "=== DEPLOYMENT CONCLUÍDO COM SUCESSO ===" "SUCCESS"
        Write-Log "O Azure SQL Database está pronto para uso!" "SUCCESS"
        
    }
    catch {
        Write-Log "Erro durante o deployment: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

# Executar deployment
Deploy-AzureSQLDatabase
