# Troubleshooting e Soluções - Azure Database

## 🎯 Visão Geral

Este documento aborda os problemas mais comuns enfrentados ao trabalhar com bancos de dados na Azure, suas causas e soluções práticas testadas.

## 🔌 Problemas de Conectividade

### Erro: "Cannot connect to server"

#### Sintomas
```
System.Data.SqlClient.SqlException: 
A connection was attempted while the user account is unauthorized.
Login failed for user 'username'.
```

#### Causas Possíveis
1. **Firewall bloqueando conexão**
2. **Credenciais incorretas**
3. **String de conexão malformada**
4. **Servidor pausado (Serverless)**

#### Soluções

##### 1. Verificar e Configurar Firewall
```bash
# Listar regras de firewall existentes
az sql server firewall-rule list \
    --resource-group myResourceGroup \
    --server myserver

# Adicionar seu IP atual
az sql server firewall-rule create \
    --resource-group myResourceGroup \
    --server myserver \
    --name AllowMyCurrentIP \
    --start-ip-address $(curl -4 ifconfig.me) \
    --end-ip-address $(curl -4 ifconfig.me)

# Permitir serviços Azure (use com cuidado)
az sql server firewall-rule create \
    --resource-group myResourceGroup \
    --server myserver \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0
```

##### 2. Validar Credenciais
```sql
-- Verificar usuários existentes
SELECT 
    name,
    type_desc,
    is_disabled,
    create_date,
    modify_date
FROM sys.database_principals
WHERE type IN ('U', 'S');

-- Reset de senha (portal Azure ou CLI)
az sql server update \
    --resource-group myResourceGroup \
    --name myserver \
    --admin-password "NewSecurePassword123!"
```

##### 3. Testar Conectividade
```powershell
# Script PowerShell para teste completo
$serverName = "myserver.database.windows.net"
$databaseName = "mydatabase"
$username = "sqladmin"
$password = "MyPassword123!"

# Teste 1: Resolução DNS
try {
    $dnsResult = Resolve-DnsName -Name $serverName
    Write-Host "✅ DNS Resolution: Success" -ForegroundColor Green
    Write-Host "IP Address: $($dnsResult.IPAddress)"
} catch {
    Write-Host "❌ DNS Resolution: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}

# Teste 2: Conectividade TCP
try {
    $tcpTest = Test-NetConnection -ComputerName $serverName -Port 1433
    if ($tcpTest.TcpTestSucceeded) {
        Write-Host "✅ TCP Connection: Success" -ForegroundColor Green
    } else {
        Write-Host "❌ TCP Connection: Failed" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ TCP Connection: Error" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}

# Teste 3: Autenticação SQL
try {
    $connectionString = "Server=$serverName;Database=$databaseName;User ID=$username;Password=$password;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "✅ SQL Authentication: Success" -ForegroundColor Green
    
    # Teste simples de query
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT @@VERSION"
    $result = $command.ExecuteScalar()
    Write-Host "Database Version: $result"
    
    $connection.Close()
} catch {
    Write-Host "❌ SQL Authentication: Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}
```

### Erro: "Server was not found or was not accessible"

#### Sintomas
```
System.Data.SqlClient.SqlException:
A network-related or instance-specific error occurred while establishing 
a connection to SQL Server. The server was not found or was not accessible.
```

#### Soluções

##### 1. Verificar Status do Servidor
```bash
# Verificar status do servidor
az sql server show \
    --resource-group myResourceGroup \
    --name myserver \
    --query "state"

# Para Serverless - verificar se está pausado
az sql db show \
    --resource-group myResourceGroup \
    --server myserver \
    --name mydatabase \
    --query "status"
```

##### 2. Reativar Banco Serverless
```bash
# Forçar "despertar" banco serverless
az sql db show \
    --resource-group myResourceGroup \
    --server myserver \
    --name mydatabase
```

## ⚡ Problemas de Performance

### Lentidão Geral do Banco

#### Diagnóstico Inicial
```sql
-- Verificar utilização de recursos
SELECT 
    start_time,
    end_time,
    avg_cpu_percent,
    avg_data_io_percent,
    avg_log_write_percent,
    max_worker_percent,
    max_session_percent,
    avg_memory_usage_percent
FROM sys.dm_db_resource_stats
WHERE start_time > DATEADD(hour, -2, GETDATE())
ORDER BY start_time DESC;

-- Identificar queries custosas
SELECT TOP 10
    total_worker_time/execution_count AS avg_cpu_time,
    total_elapsed_time/execution_count AS avg_duration,
    total_logical_reads/execution_count AS avg_reads,
    execution_count,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY total_worker_time/execution_count DESC;
```

#### Soluções por Cenário

##### Alta Utilização de CPU
```sql
-- Identificar queries que consomem CPU
SELECT TOP 5
    qs.total_worker_time/qs.execution_count AS avg_cpu_time,
    qs.execution_count,
    SUBSTRING(qt.text, qs.statement_start_offset/2+1,
        (CASE WHEN qs.statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2
            ELSE qs.statement_end_offset END - qs.statement_start_offset)/2 + 1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY avg_cpu_time DESC;

-- Verificar planos de execução problemáticos
SELECT TOP 10
    cp.plan_handle,
    cp.usecounts,
    cp.size_in_bytes,
    cp.cacheobjtype,
    st.text
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC;
```

**Ações Corretivas:**
1. Otimizar queries identificadas
2. Criar índices adequados
3. Considerar upgrade de tier
4. Implementar cache na aplicação

##### Alto I/O de Dados
```sql
-- Analisar I/O por arquivo
SELECT 
    DB_NAME() AS database_name,
    file_id,
    io_stall_read_ms,
    num_of_reads,
    CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS avg_read_stall_ms,
    io_stall_write_ms,
    num_of_writes,
    CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS avg_write_stall_ms,
    io_stall_read_ms + io_stall_write_ms AS io_stalls,
    num_of_reads + num_of_writes AS total_io
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL)
ORDER BY io_stalls DESC;

-- Identificar tabelas com mais acessos
SELECT TOP 10
    OBJECT_SCHEMA_NAME(ios.object_id) AS schema_name,
    OBJECT_NAME(ios.object_id) AS object_name,
    ios.leaf_insert_count,
    ios.leaf_update_count,
    ios.leaf_delete_count,
    ios.range_scan_count,
    ios.singleton_lookup_count
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) ios
WHERE ios.object_id > 100
ORDER BY (ios.range_scan_count + ios.singleton_lookup_count) DESC;
```

### Deadlocks Frequentes

#### Identificação
```sql
-- Habilitar trace de deadlock
ALTER EVENT SESSION system_health ON SERVER STATE = STOP;
ALTER EVENT SESSION system_health ON SERVER STATE = START;

-- Query para analisar deadlocks
WITH DeadlockEvents AS (
    SELECT 
        event_data.value('(/event/@timestamp)[1]', 'datetime2') AS timestamp,
        event_data.value('(/event/data[@name="xml_report"]/value)[1]', 'xml') AS deadlock_graph
    FROM (
        SELECT CAST(target_data AS XML) AS target_data
        FROM sys.dm_xe_session_targets
        WHERE session_name = 'system_health'
    ) AS Data
    CROSS APPLY target_data.nodes('//RingBufferTarget/event') AS XEventData(event_data)
    WHERE event_data.value('(/event/@name)[1]', 'varchar(4000)') = 'xml_deadlock_report'
)
SELECT 
    timestamp,
    deadlock_graph.query('/deadlock/process-list/process/@id') AS process_ids,
    deadlock_graph.query('/deadlock/process-list/process/inputbuf') AS statements
FROM DeadlockEvents
WHERE timestamp > DATEADD(hour, -24, GETDATE())
ORDER BY timestamp DESC;
```

#### Soluções
1. **Otimizar ordem de acesso aos recursos**
2. **Implementar retry logic na aplicação**
3. **Usar isolation levels apropriados**
4. **Reduzir tempo de transação**

```sql
-- Exemplo de retry logic em stored procedure
CREATE PROCEDURE dbo.ProcessWithRetry
    @param1 INT
AS
BEGIN
    DECLARE @retry_count INT = 0;
    DECLARE @max_retries INT = 3;
    
    WHILE @retry_count < @max_retries
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;
            
            -- Sua lógica de negócio aqui
            UPDATE Table1 SET Column1 = @param1 WHERE ID = 1;
            UPDATE Table2 SET Column2 = @param1 WHERE ID = 1;
            
            COMMIT TRANSACTION;
            BREAK; -- Sucesso, sair do loop
            
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
                
            IF ERROR_NUMBER() = 1205 -- Deadlock
            BEGIN
                SET @retry_count = @retry_count + 1;
                WAITFOR DELAY '00:00:01'; -- Aguardar 1 segundo
                CONTINUE;
            END
            ELSE
            BEGIN
                THROW; -- Re-lançar outros erros
            END
        END CATCH
    END
    
    IF @retry_count = @max_retries
        THROW 50001, 'Maximum retry attempts reached', 1;
END;
```

## 💾 Problemas de Armazenamento

### Erro: "Database is full"

#### Sintomas
```
Could not allocate space for object 'dbo.TableName'.'PK_TableName' 
in database 'MyDatabase' because the 'PRIMARY' filegroup is full.
```

#### Diagnóstico
```sql
-- Verificar utilização de espaço
SELECT 
    database_name,
    storage_in_megabytes,
    allocated_storage_in_megabytes,
    max_size_in_megabytes,
    (CAST(storage_in_megabytes AS FLOAT) / max_size_in_megabytes) * 100 AS percent_used
FROM sys.dm_db_resource_stats
WHERE database_name = DB_NAME()
ORDER BY end_time DESC;

-- Analisar crescimento por tabela
SELECT 
    t.name AS table_name,
    s.name AS schema_name,
    p.rows AS row_count,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS total_space_mb,
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS used_space_mb,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS unused_space_mb
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name NOT LIKE 'dt%' AND t.is_ms_shipped = 0 AND i.object_id > 255
GROUP BY t.name, s.name, p.rows
ORDER BY total_space_mb DESC;
```

#### Soluções

##### 1. Expandir Armazenamento
```bash
# Aumentar limite de armazenamento
az sql db update \
    --resource-group myResourceGroup \
    --server myserver \
    --name mydatabase \
    --max-size 500GB
```

##### 2. Limpeza de Dados
```sql
-- Identificar dados antigos para purge
SELECT 
    table_name,
    COUNT(*) as record_count,
    MIN(created_date) as oldest_record,
    MAX(created_date) as newest_record
FROM (
    SELECT 'Orders' as table_name, created_date FROM Orders
    UNION ALL
    SELECT 'Logs' as table_name, log_date FROM ApplicationLogs
    UNION ALL
    SELECT 'Audit' as table_name, audit_date FROM AuditTrail
) data
GROUP BY table_name
ORDER BY oldest_record;

-- Script de limpeza em lotes (exemplo)
DECLARE @BatchSize INT = 1000;
DECLARE @RowsDeleted INT = @BatchSize;

WHILE @RowsDeleted = @BatchSize
BEGIN
    DELETE TOP (@BatchSize) FROM ApplicationLogs
    WHERE log_date < DATEADD(day, -90, GETDATE());
    
    SET @RowsDeleted = @@ROWCOUNT;
    
    -- Pausa para evitar bloqueios
    WAITFOR DELAY '00:00:01';
END;
```

### Fragmentação de Índices

#### Diagnóstico
```sql
-- Analisar fragmentação de índices
SELECT 
    OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
    OBJECT_NAME(ips.object_id) AS object_name,
    i.name AS index_name,
    ips.index_id,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    CASE 
        WHEN ips.avg_fragmentation_in_percent < 5 THEN 'No Action'
        WHEN ips.avg_fragmentation_in_percent < 30 THEN 'REORGANIZE'
        ELSE 'REBUILD'
    END AS recommended_action
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 5
    AND ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

#### Solução Automatizada
```sql
-- Stored procedure para manutenção de índices
CREATE PROCEDURE dbo.IndexMaintenance
    @FragmentationThreshold FLOAT = 5.0,
    @RebuildThreshold FLOAT = 30.0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @SchemaName NVARCHAR(128);
    DECLARE @ObjectName NVARCHAR(128);
    DECLARE @IndexName NVARCHAR(128);
    DECLARE @Fragmentation FLOAT;
    
    DECLARE maintenance_cursor CURSOR FOR
    SELECT 
        OBJECT_SCHEMA_NAME(ips.object_id),
        OBJECT_NAME(ips.object_id),
        i.name,
        ips.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
    WHERE ips.avg_fragmentation_in_percent > @FragmentationThreshold
        AND ips.page_count > 100
        AND i.name IS NOT NULL;
    
    OPEN maintenance_cursor;
    
    FETCH NEXT FROM maintenance_cursor 
    INTO @SchemaName, @ObjectName, @IndexName, @Fragmentation;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @Fragmentation >= @RebuildThreshold
        BEGIN
            SET @sql = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @ObjectName + '] REBUILD ONLINE = ON;';
            PRINT 'REBUILD: ' + @sql;
        END
        ELSE
        BEGIN
            SET @sql = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @ObjectName + '] REORGANIZE;';
            PRINT 'REORGANIZE: ' + @sql;
        END
        
        BEGIN TRY
            EXEC sp_executesql @sql;
        END TRY
        BEGIN CATCH
            PRINT 'Error: ' + ERROR_MESSAGE();
        END CATCH
        
        FETCH NEXT FROM maintenance_cursor 
        INTO @SchemaName, @ObjectName, @IndexName, @Fragmentation;
    END
    
    CLOSE maintenance_cursor;
    DEALLOCATE maintenance_cursor;
END;
```

## 🔐 Problemas de Segurança

### Falhas de Autenticação

#### Azure AD Authentication Issues
```powershell
# Verificar configuração do Azure AD
az sql server ad-admin list \
    --resource-group myResourceGroup \
    --server myserver

# Configurar administrador Azure AD
az sql server ad-admin create \
    --resource-group myResourceGroup \
    --server myserver \
    --display-name "DBA Team" \
    --object-id "12345678-1234-1234-1234-123456789012"
```

#### Managed Identity Configuration
```sql
-- Criar usuário para Managed Identity
CREATE USER [myapp-identity] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [myapp-identity];
ALTER ROLE db_datawriter ADD MEMBER [myapp-identity];
```

### Auditoria e Compliance

#### Configurar SQL Audit
```bash
# Habilitar auditoria no servidor
az sql server audit-policy update \
    --resource-group myResourceGroup \
    --name myserver \
    --state Enabled \
    --storage-account mystorageaccount \
    --storage-key "storage-key" \
    --retention-days 90
```

#### Queries de Auditoria
```sql
-- Analisar logs de auditoria
SELECT 
    event_time,
    action_name,
    succeeded,
    database_name,
    schema_name,
    object_name,
    client_ip,
    application_name,
    principal_name,
    statement
FROM sys.fn_get_audit_file('https://mystorageaccount.blob.core.windows.net/sqldbauditlogs/*', DEFAULT, DEFAULT)
WHERE event_time > DATEADD(day, -7, GETDATE())
    AND action_name IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE')
ORDER BY event_time DESC;
```

## 🚨 Problemas de Backup e Recovery

### Falha na Restauração

#### Verificar Backups Disponíveis
```bash
# Listar backups disponíveis
az sql db ltr-backup list \
    --location "Brazil South" \
    --server myserver \
    --database mydatabase

# Verificar configuração de retenção
az sql db ltr-policy show \
    --resource-group myResourceGroup \
    --server myserver \
    --database mydatabase
```

#### Point-in-Time Recovery
```bash
# Restaurar para ponto específico
az sql db restore \
    --resource-group myResourceGroup \
    --server myserver \
    --name mydatabase-restored \
    --source-database mydatabase \
    --time "2024-01-15T10:30:00Z"
```

### Geo-Restore Issues

#### Verificar Status de Geo-Backup
```sql
-- Verificar último backup geo-redundante
SELECT 
    database_name,
    last_available_backup_date,
    earliest_restore_date
FROM sys.dm_geo_backup_databases
WHERE database_name = 'mydatabase';
```

## 📊 Ferramentas de Diagnóstico

### Script de Health Check Completo
```sql
-- Azure SQL Database Health Check
SET NOCOUNT ON;

PRINT '=== AZURE SQL DATABASE HEALTH CHECK ===';
PRINT 'Database: ' + DB_NAME();
PRINT 'Server: ' + @@SERVERNAME;
PRINT 'Time: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';

-- 1. Informações Básicas
PRINT '1. DATABASE INFORMATION';
SELECT 
    database_name = DB_NAME(),
    service_objective,
    edition,
    elastic_pool_name
FROM sys.database_service_objectives;

-- 2. Utilização de Recursos
PRINT '2. RESOURCE UTILIZATION (Last Hour)';
SELECT TOP 1
    'CPU %' = avg_cpu_percent,
    'Data IO %' = avg_data_io_percent,
    'Log IO %' = avg_log_write_percent,
    'Memory %' = avg_memory_usage_percent,
    'Workers %' = max_worker_percent,
    'Sessions %' = max_session_percent
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;

-- 3. Storage Information
PRINT '3. STORAGE INFORMATION';
SELECT 
    'Data Size (MB)' = CAST(SUM(CASE WHEN type = 0 THEN size END) * 8.0 / 1024 AS DECIMAL(10,2)),
    'Log Size (MB)' = CAST(SUM(CASE WHEN type = 1 THEN size END) * 8.0 / 1024 AS DECIMAL(10,2)),
    'Data Used (MB)' = CAST(SUM(CASE WHEN type = 0 THEN FILEPROPERTY(name, 'SpaceUsed') END) * 8.0 / 1024 AS DECIMAL(10,2))
FROM sys.database_files;

-- 4. Top Queries por CPU
PRINT '4. TOP 5 QUERIES BY CPU';
SELECT TOP 5
    'Avg CPU (ms)' = total_worker_time / execution_count,
    'Executions' = execution_count,
    'Query Text' = SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) + 1)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY total_worker_time / execution_count DESC;

-- 5. Index Fragmentation
PRINT '5. HIGHLY FRAGMENTED INDEXES';
SELECT TOP 10
    'Schema' = OBJECT_SCHEMA_NAME(object_id),
    'Table' = OBJECT_NAME(object_id),
    'Index' = i.name,
    'Fragmentation %' = CAST(avg_fragmentation_in_percent AS DECIMAL(5,2)),
    'Pages' = page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE avg_fragmentation_in_percent > 30 AND page_count > 100
ORDER BY avg_fragmentation_in_percent DESC;

-- 6. Wait Statistics
PRINT '6. TOP WAIT STATISTICS';
SELECT TOP 10
    'Wait Type' = wait_type,
    'Wait Time (s)' = wait_time_ms / 1000,
    'Waiting Tasks' = waiting_tasks_count,
    'Avg Wait (ms)' = CASE WHEN waiting_tasks_count > 0 
                          THEN wait_time_ms / waiting_tasks_count 
                          ELSE 0 END
FROM sys.dm_os_wait_stats
WHERE wait_time_ms > 0
ORDER BY wait_time_ms DESC;

PRINT '';
PRINT '=== HEALTH CHECK COMPLETED ===';
```

### PowerShell Monitoring Script
```powershell
# Azure SQL Database Monitoring Script
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$ServerName,
    
    [Parameter(Mandatory=$true)]
    [string]$DatabaseName
)

# Função para log com timestamp
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "Starting Azure SQL Database monitoring..."

try {
    # Verificar status do banco
    $database = az sql db show `
        --resource-group $ResourceGroupName `
        --server $ServerName `
        --name $DatabaseName `
        --output json | ConvertFrom-Json
    
    Write-Log "Database Status: $($database.status)"
    Write-Log "Service Objective: $($database.currentServiceObjectiveName)"
    Write-Log "Edition: $($database.edition)"
    
    # Verificar métricas de performance
    $endTime = Get-Date
    $startTime = $endTime.AddHours(-1)
    
    $metrics = az monitor metrics list `
        --resource "/subscriptions/$((az account show --query id -o tsv))/resourceGroups/$ResourceGroupName/providers/Microsoft.Sql/servers/$ServerName/databases/$DatabaseName" `
        --metric "cpu_percent,dtu_consumption_percent,storage_percent" `
        --start-time $startTime.ToString("yyyy-MM-ddTHH:mm:ssZ") `
        --end-time $endTime.ToString("yyyy-MM-ddTHH:mm:ssZ") `
        --output json | ConvertFrom-Json
    
    foreach ($metric in $metrics.value) {
        $latestValue = $metric.timeseries.data | Sort-Object timeStamp -Descending | Select-Object -First 1
        if ($latestValue.average) {
            Write-Log "$($metric.name.value): $([math]::Round($latestValue.average, 2))%"
        }
    }
    
    # Verificar alertas ativos
    $alerts = az monitor activity-log list `
        --resource-group $ResourceGroupName `
        --start-time $startTime.ToString("yyyy-MM-ddTHH:mm:ssZ") `
        --status "Active" `
        --output json | ConvertFrom-Json
    
    if ($alerts.Count -gt 0) {
        Write-Log "Active alerts found: $($alerts.Count)" "WARNING"
        foreach ($alert in $alerts) {
            Write-Log "Alert: $($alert.operationName) - $($alert.status)" "WARNING"
        }
    } else {
        Write-Log "No active alerts"
    }
    
} catch {
    Write-Log "Error occurred: $($_.Exception.Message)" "ERROR"
    exit 1
}

Write-Log "Monitoring completed successfully"
```

## 🛠️ Ferramentas Úteis

### 1. Azure SQL Database Query Editor
- Acesso via portal Azure
- Execução de queries simples
- Ideal para troubleshooting rápido

### 2. SQL Server Management Studio (SSMS)
- Ferramenta completa para Windows
- Recursos avançados de diagnóstico
- Plans de execução detalhados

### 3. Azure Data Studio
- Multiplataforma
- Extensões para Azure
- Notebooks para documentação

### 4. Azure CLI Scripts
- Automação de tarefas
- Monitoramento programático
- Integração com pipelines

## 📞 Quando Abrir Ticket de Suporte

### Situações que Requerem Suporte Microsoft
1. **Corruption de dados**
2. **Performance degradation inexplicável**
3. **Falhas de hardware/infraestrutura**
4. **Problemas de conectividade regional**
5. **Bugs confirmados na plataforma**

### Informações para Incluir no Ticket
- Resource ID completo
- Timestamp dos problemas
- Logs de erro detalhados
- Scripts de reprodução
- Impacto no negócio

---

## 💡 Dicas Finais de Troubleshooting

1. **Sempre colete evidências antes de fazer mudanças**
2. **Use ferramentas de monitoramento proativamente**
3. **Mantenha scripts de diagnóstico prontos**
4. **Documente soluções para problemas recorrentes**
5. **Teste soluções em ambiente de desenvolvimento primeiro**

> 🎯 **Lembre-se**: A prevenção é sempre melhor que a correção. Implemente monitoramento robusto!
