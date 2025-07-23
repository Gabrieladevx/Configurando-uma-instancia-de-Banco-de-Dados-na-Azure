# Melhores Práticas e Dicas para Azure Database

## 🎯 Visão Geral

Este documento reúne as melhores práticas, dicas valiosas e lições aprendidas para trabalhar com bancos de dados na Azure de forma eficiente, segura e econômica.

## 🏗️ Planejamento e Arquitetura

### Estratégia de Naming Convention

#### Convenção Recomendada
```
Recursos:
- Servidor SQL: srv-[projeto]-[ambiente]-[região]-[sequencial]
- Banco de Dados: db-[aplicacao]-[ambiente]
- Grupo de Recursos: rg-[projeto]-[ambiente]-[região]

Exemplos:
- srv-ecommerce-prod-brazilsouth-001
- db-catalog-dev
- rg-ecommerce-prod-brazilsouth
```

#### Tags Obrigatórias
```json
{
    "Environment": "Production|Development|Staging",
    "Project": "nome-do-projeto",
    "Owner": "email@empresa.com",
    "CostCenter": "codigo-centro-custo",
    "Backup": "Required|NotRequired",
    "Criticality": "High|Medium|Low"
}
```

### Seleção de Região

#### Critérios de Decisão
- **Latência**: Proximidade aos usuários finais
- **Compliance**: Requisitos de residência de dados
- **Disponibilidade**: Serviços disponíveis na região
- **Custo**: Variação de preços entre regiões
- **Disaster Recovery**: Região secundária para backup

#### Regiões Recomendadas para Brasil
```
Primária: Brazil South (São Paulo)
Secundária: Brazil Southeast (Rio de Janeiro)
Alternativa: East US 2 (para aplicações globais)
```

## 🔒 Segurança

### Autenticação e Autorização

#### Azure Active Directory Integration
```sql
-- Configurar administrador Azure AD
ALTER SERVER ROLE dbmanager ADD MEMBER [admin@empresa.com];

-- Criar usuário Azure AD no banco
CREATE USER [developer@empresa.com] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [developer@empresa.com];
```

#### Princípio do Menor Privilégio
```sql
-- Criar roles específicas
CREATE ROLE app_read_only;
GRANT SELECT ON SCHEMA::dbo TO app_read_only;

CREATE ROLE app_write;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::dbo TO app_write;

-- Atribuir usuários às roles
ALTER ROLE app_read_only ADD MEMBER [readonly_user];
ALTER ROLE app_write ADD MEMBER [app_service_principal];
```

### Network Security

#### Configuração de Firewall Restritiva
```bash
# Remover regra "Allow Azure Services"
az sql server firewall-rule delete \
    --resource-group myResourceGroup \
    --server myserver \
    --name AllowAllWindowsAzureIps

# Adicionar apenas IPs específicos
az sql server firewall-rule create \
    --resource-group myResourceGroup \
    --server myserver \
    --name AllowOfficeIP \
    --start-ip-address 203.0.113.100 \
    --end-ip-address 203.0.113.100
```

#### Virtual Network Integration
```bash
# Criar VNet service endpoint
az sql server vnet-rule create \
    --resource-group myResourceGroup \
    --server myserver \
    --name myVNetRule \
    --vnet-name myVNet \
    --subnet mySubnet
```

### Criptografia

#### Always Encrypted para Dados Sensíveis
```sql
-- Exemplo para dados de cartão de crédito
ALTER TABLE Payments
ADD CreditCardNumber_Encrypted VARBINARY(MAX) 
ENCRYPTED WITH (
    COLUMN_ENCRYPTION_KEY = CEK_CardNumber,
    ENCRYPTION_TYPE = DETERMINISTIC,
    ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
);
```

#### Transparent Data Encryption (TDE)
```sql
-- Verificar status do TDE
SELECT 
    name,
    is_encrypted,
    encryption_state_desc
FROM sys.dm_database_encryption_keys;

-- Habilitar TDE (habilitado por padrão no Azure)
ALTER DATABASE [mydatabase] SET ENCRYPTION ON;
```

## 📊 Performance e Otimização

### Sizing Apropriado

#### Metodologia de Dimensionamento
1. **Baseline Current State**
   ```sql
   -- Coletar métricas atuais
   SELECT 
       avg_cpu_percent,
       avg_data_io_percent,
       avg_log_write_percent,
       max_worker_percent,
       max_session_percent
   FROM sys.dm_db_resource_stats
   WHERE start_time > DATEADD(hour, -1, GETDATE());
   ```

2. **Projeção de Crescimento**
   - Crescimento esperado de dados (% ao ano)
   - Aumento de usuários simultâneos
   - Novas funcionalidades da aplicação

3. **Margin de Segurança**
   - CPU: máximo 70% em operação normal
   - Memória: máximo 80% em operação normal
   - Storage: máximo 85% de utilização

### Index Strategy

#### Análise de Missing Indexes
```sql
-- Identificar índices faltantes
SELECT 
    ROUND(user_seeks * avg_total_user_cost * (avg_user_impact * 0.01), 0) AS index_advantage,
    migs.last_user_seek,
    mid.statement AS table_name,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_group_stats AS migs
INNER JOIN sys.dm_db_missing_index_groups AS mig 
    ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid 
    ON mig.index_handle = mid.index_handle
WHERE migs.last_user_seek > DATEADD(day, -30, GETDATE())
ORDER BY index_advantage DESC;
```

#### Manutenção de Índices
```sql
-- Script de manutenção automática
IF OBJECT_ID('sp_IndexMaintenance') IS NOT NULL
    DROP PROCEDURE sp_IndexMaintenance;
GO

CREATE PROCEDURE sp_IndexMaintenance
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    
    -- Reorganizar índices com fragmentação 5-30%
    SELECT @sql = STRING_AGG(
        'ALTER INDEX ' + i.name + ' ON ' + OBJECT_SCHEMA_NAME(i.object_id) 
        + '.' + OBJECT_NAME(i.object_id) + ' REORGANIZE;', CHAR(13))
    FROM sys.indexes i
    CROSS APPLY sys.dm_db_index_physical_stats(
        DB_ID(), i.object_id, i.index_id, NULL, 'LIMITED') s
    WHERE s.avg_fragmentation_in_percent BETWEEN 5 AND 30
    AND i.index_id > 0;
    
    EXEC sp_executesql @sql;
    
    -- Rebuild índices com fragmentação > 30%
    SELECT @sql = STRING_AGG(
        'ALTER INDEX ' + i.name + ' ON ' + OBJECT_SCHEMA_NAME(i.object_id) 
        + '.' + OBJECT_NAME(i.object_id) + ' REBUILD ONLINE = ON;', CHAR(13))
    FROM sys.indexes i
    CROSS APPLY sys.dm_db_index_physical_stats(
        DB_ID(), i.object_id, i.index_id, NULL, 'LIMITED') s
    WHERE s.avg_fragmentation_in_percent > 30
    AND i.index_id > 0;
    
    EXEC sp_executesql @sql;
END;
```

### Query Optimization

#### Configuração do Query Store
```sql
-- Configuração otimizada do Query Store
ALTER DATABASE CURRENT SET QUERY_STORE = ON;

ALTER DATABASE CURRENT SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 300,
    INTERVAL_LENGTH_MINUTES = 15,
    MAX_STORAGE_SIZE_MB = 1024,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
);
```

#### Identificação de Queries Problemáticas
```sql
-- Top 10 queries por CPU
SELECT TOP 10
    qst.query_sql_text,
    qs.execution_count,
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    qs.total_elapsed_time / qs.execution_count AS avg_duration,
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qst
ORDER BY qs.total_worker_time DESC;
```

## 💰 Gestão de Custos

### Estratégias de Otimização

#### Reserved Instances
```
Economia: Até 55% vs Pay-as-you-go
Período: 1 ou 3 anos
Recomendado para: Workloads estáveis
Flexibilidade: Instance size, região
```

#### Elastic Pools
```sql
-- Análise para Elastic Pool
SELECT 
    database_name,
    AVG(avg_cpu_percent) as avg_cpu,
    MAX(avg_cpu_percent) as max_cpu,
    AVG(avg_dtu_percent) as avg_dtu
FROM sys.dm_db_resource_stats
WHERE start_time > DATEADD(day, -30, GETDATE())
GROUP BY database_name
ORDER BY avg_dtu DESC;
```

#### Auto-pause para Dev/Test
```bash
# Configurar auto-pause para serverless
az sql db update \
    --resource-group myResourceGroup \
    --server myserver \
    --name mydatabase \
    --compute-model Serverless \
    --auto-pause-delay 60
```

### Monitoramento de Custos

#### Cost Alerts
```bash
# Criar alerta de custo
az consumption budget create \
    --budget-name "Database-Monthly-Budget" \
    --amount 500 \
    --time-grain Monthly \
    --start-date "2024-01-01T00:00:00Z" \
    --end-date "2024-12-31T00:00:00Z" \
    --resource-group-filter myResourceGroup
```

## 🔄 Backup e Disaster Recovery

### Estratégia de Backup Completa

#### Configuração de Retenção
```bash
# Backup de longo prazo
az sql db ltr-policy set \
    --resource-group myResourceGroup \
    --server myserver \
    --database mydatabase \
    --weekly-retention P4W \
    --monthly-retention P12M \
    --yearly-retention P7Y \
    --week-of-year 52
```

#### Point-in-Time Recovery
```sql
-- Restore para momento específico
RESTORE DATABASE mydatabase_restored
FROM DATABASE mydatabase
AS OF '2024-01-15T14:30:00.000Z';
```

### Geo-Replication

#### Configuração de Replica Secundária
```bash
# Criar geo-replica
az sql db replica create \
    --resource-group myResourceGroup \
    --server myserver \
    --name mydatabase \
    --partner-server myserver-secondary \
    --partner-resource-group myResourceGroup-secondary
```

#### Failover Testing
```bash
# Teste de failover planejado
az sql db replica set-primary \
    --resource-group myResourceGroup-secondary \
    --server myserver-secondary \
    --name mydatabase
```

## 📈 Monitoramento e Alertas

### Métricas Essenciais

#### Performance Counters
```sql
-- Monitoramento em tempo real
SELECT 
    start_time,
    avg_cpu_percent,
    avg_data_io_percent,
    avg_log_write_percent,
    max_worker_percent,
    max_session_percent,
    avg_memory_usage_percent
FROM sys.dm_db_resource_stats
WHERE start_time > DATEADD(minute, -60, GETDATE())
ORDER BY start_time DESC;
```

#### Custom Metrics via Azure Monitor
```bash
# Enviar métrica customizada
az monitor metrics create \
    --resource-id "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Sql/servers/{server}/databases/{db}" \
    --metric-name "CustomBusinessMetric" \
    --value 100 \
    --timestamp "2024-01-15T10:30:00Z"
```

### Alerting Strategy

#### Alertas Críticos
```json
{
    "CPU > 80%": "5 minutes",
    "DTU > 90%": "2 minutes", 
    "Connection Failures": "immediate",
    "Storage > 85%": "15 minutes",
    "Deadlocks > 10/hour": "1 hour"
}
```

#### Runbooks Automatizados
```powershell
# Runbook para scale up automático
param(
    [string]$ResourceGroupName,
    [string]$ServerName,
    [string]$DatabaseName
)

# Scale up em caso de alta utilização
Set-AzSqlDatabase -ResourceGroupName $ResourceGroupName `
    -ServerName $ServerName `
    -DatabaseName $DatabaseName `
    -RequestedServiceObjectiveName "S2"
```

## 🚀 DevOps e Automação

### Infrastructure as Code

#### Bicep Template
```bicep
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: serverName
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 268435456000
  }
}
```

### Database Migration

#### Azure Database Migration Service
```bash
# Criar serviço de migração
az dms create \
    --resource-group myResourceGroup \
    --name myDMS \
    --location "Brazil South" \
    --subnet-id "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}"
```

### CI/CD Pipeline

#### Azure DevOps Pipeline
```yaml
trigger:
- main

pool:
  vmImage: 'windows-latest'

steps:
- task: SqlAzureDacpacDeployment@1
  displayName: 'Deploy Database Schema'
  inputs:
    azureSubscription: 'Azure-Service-Connection'
    ServerName: '$(sqlServerName).database.windows.net'
    DatabaseName: '$(databaseName)'
    SqlUsername: '$(sqlUsername)'
    SqlPassword: '$(sqlPassword)'
    DacpacFile: '$(System.DefaultWorkingDirectory)/Database/Database.dacpac'
```

## 🎯 Troubleshooting Comum

### Problemas de Conectividade

#### Checklist de Diagnóstico
1. **Firewall Rules**: Verificar IPs permitidos
2. **Connection String**: Validar formato e credenciais
3. **Network Latency**: Testar de diferentes locais
4. **SSL/TLS**: Verificar certificados

#### Script de Diagnóstico
```powershell
# Teste de conectividade completo
$serverName = "myserver.database.windows.net"
$databaseName = "mydatabase"

# Teste de resolução DNS
Resolve-DnsName -Name $serverName

# Teste de conectividade TCP
Test-NetConnection -ComputerName $serverName -Port 1433

# Teste de autenticação SQL
try {
    $connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=true;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "Conexão bem-sucedida!"
    $connection.Close()
} catch {
    Write-Error "Erro de conexão: $($_.Exception.Message)"
}
```

### Performance Issues

#### Query Performance Troubleshooting
```sql
-- Identificar bloqueios
SELECT 
    session_id,
    blocking_session_id,
    wait_type,
    wait_time,
    wait_resource,
    sql_text.text
FROM sys.dm_exec_requests
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sql_text
WHERE blocking_session_id <> 0;

-- Estatísticas de Wait
SELECT TOP 10
    wait_type,
    wait_time_ms / 1000.0 AS wait_time_seconds,
    percentage = wait_time_ms * 100.0 / SUM(wait_time_ms) OVER()
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP')
ORDER BY wait_time_ms DESC;
```

## 📚 Recursos e Ferramentas

### Ferramentas Essenciais
- **Azure Data Studio**: IDE multiplataforma
- **SSMS**: Ferramenta completa para Windows
- **Azure CLI**: Automação e scripting
- **PowerShell**: Administração avançada
- **Azure Monitor**: Monitoramento e alertas

### Links Úteis
- [Azure SQL Performance Best Practices](https://docs.microsoft.com/azure/sql-database/sql-database-performance-guidance)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
- [SQL Server Central](https://www.sqlservercentral.com/)

---

## 💡 Dicas Finais

1. **Sempre teste em ambiente de desenvolvimento primeiro**
2. **Monitore custos regularmente**
3. **Mantenha documentação atualizada**
4. **Implemente automação progressivamente**
5. **Invista em treinamento da equipe**
6. **Mantenha-se atualizado com novidades da Azure**

> 🎯 **Lembre-se**: A otimização é um processo contínuo, não um evento único!
