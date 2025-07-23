# Guia Completo de Configuração de Banco de Dados na Azure

## 🎯 Visão Geral

Este guia fornece instruções detalhadas para configurar diferentes tipos de bancos de dados na Microsoft Azure, desde o planejamento inicial até a implementação e monitoramento.

## 📋 Pré-requisitos

### Conta e Assinatura Azure
- Conta Microsoft Azure ativa
- Assinatura com créditos suficientes
- Permissões adequadas (Contributor ou Owner)

### Conhecimentos Técnicos
- Fundamentos de SQL
- Conceitos básicos de cloud computing
- Experiência com administração de banco de dados

### Ferramentas Necessárias
- Navegador web atualizado
- Azure CLI (opcional)
- SQL Server Management Studio ou Azure Data Studio

## 🏗️ Planejamento da Configuração

### 1. Análise de Requisitos

#### Requisitos Funcionais
- **Tipo de dados**: Estruturados, semi-estruturados ou não-estruturados
- **Volume de dados**: Pequeno, médio ou grande escala
- **Padrão de acesso**: OLTP, OLAP ou híbrido
- **Consistência**: Forte, eventual ou flexível

#### Requisitos Não-Funcionais
- **Performance**: Latência, throughput, concorrência
- **Disponibilidade**: SLA requerido (99.9%, 99.95%, 99.99%)
- **Escalabilidade**: Vertical, horizontal ou ambas
- **Segurança**: Compliance, criptografia, auditoria

### 2. Seleção do Serviço

| Cenário | Serviço Recomendado | Justificativa |
|---------|-------------------|---------------|
| Aplicação web tradicional | Azure SQL Database | Gerenciado, escalável, cost-effective |
| Migração from SQL Server | SQL Managed Instance | Máxima compatibilidade |
| Aplicação global | Azure Cosmos DB | Distribuição global, baixa latência |
| Sistema legado MySQL | Azure Database for MySQL | Migração simplificada |
| Analytics e BI | Azure Synapse Analytics | Otimizado para OLAP |

### 3. Dimensionamento e Custos

#### Fatores de Dimensionamento
- **Computação**: CPU, memória, I/O
- **Armazenamento**: Tamanho, tipo (Standard/Premium)
- **Rede**: Largura de banda, latência
- **Backup**: Frequência, retenção, geo-replicação

#### Estimativa de Custos
1. Use a [Calculadora de Preços do Azure](https://azure.microsoft.com/pricing/calculator/)
2. Considere custos ocultos (backup, rede, suporte)
3. Avalie opções de Reserved Instances para economia

## ⚙️ Configuração Passo a Passo

### Azure SQL Database

#### Etapa 1: Criação do Servidor
```bash
# Via Azure CLI
az sql server create \
    --name myserver \
    --resource-group myResourceGroup \
    --location "West Europe" \
    --admin-user myadmin \
    --admin-password myPassword123!
```

#### Etapa 2: Configuração do Firewall
```bash
# Permitir acesso do Azure
az sql server firewall-rule create \
    --resource-group myResourceGroup \
    --server myserver \
    --name AllowAzureIps \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# Permitir IP específico
az sql server firewall-rule create \
    --resource-group myResourceGroup \
    --server myserver \
    --name AllowMyIP \
    --start-ip-address 203.0.113.1 \
    --end-ip-address 203.0.113.1
```

#### Etapa 3: Criação do Banco de Dados
```bash
az sql db create \
    --resource-group myResourceGroup \
    --server myserver \
    --name mydatabase \
    --service-objective S0
```

### Azure SQL Managed Instance

#### Configuração de Rede
1. **Criar Rede Virtual**
2. **Configurar Subnet dedicada**
3. **Definir Network Security Group**
4. **Configurar Route Table**

#### Criação da Instância
```bash
az sql mi create \
    --resource-group myResourceGroup \
    --name myinstance \
    --location "West Europe" \
    --admin-user myadmin \
    --admin-password myPassword123! \
    --subnet /subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet} \
    --capacity 8 \
    --storage 32GB \
    --edition GeneralPurpose \
    --family Gen5
```

### Azure Cosmos DB

#### Configuração Básica
```bash
# Criar conta Cosmos DB
az cosmosdb create \
    --resource-group myResourceGroup \
    --name mycosmosdb \
    --locations regionName="West Europe" failoverPriority=0 isZoneRedundant=False \
    --default-consistency-level "Session"

# Criar database
az cosmosdb sql database create \
    --account-name mycosmosdb \
    --resource-group myResourceGroup \
    --name mydatabase

# Criar container
az cosmosdb sql container create \
    --account-name mycosmosdb \
    --resource-group myResourceGroup \
    --database-name mydatabase \
    --name mycontainer \
    --partition-key-path "/id" \
    --throughput 400
```

## 🔧 Configurações Avançadas

### Backup e Recuperação

#### SQL Database
- **Backup Automático**: Habilitado por padrão
- **Retenção**: 7-35 dias (Basic/Standard/Premium)
- **Geo-backup**: Automático para Standard/Premium
- **Point-in-time Recovery**: Até o último minuto

#### Configuração de Backup
```sql
-- Configurar retenção de backup de longo prazo
ALTER DATABASE mydatabase SET (BACKUP_RETENTION = '1 WEEK');

-- Restaurar para ponto específico no tempo
RESTORE DATABASE mydatabase_restored 
FROM DATABASE mydatabase 
AS OF '2024-01-15T10:30:00.000Z';
```

### Segurança

#### Transparent Data Encryption (TDE)
```sql
-- Habilitar TDE
ALTER DATABASE mydatabase SET ENCRYPTION ON;

-- Verificar status
SELECT 
    name,
    is_encrypted,
    encryption_state,
    encryption_state_desc
FROM sys.dm_database_encryption_keys;
```

#### Always Encrypted
```sql
-- Criar chave mestra
CREATE COLUMN MASTER KEY MyCMK
WITH (
    KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT',
    KEY_PATH = 'https://myvault.vault.azure.net/keys/mykey/'
);

-- Criar chave de criptografia
CREATE COLUMN ENCRYPTION KEY MyCEK
WITH VALUES (
    COLUMN_MASTER_KEY = MyCMK,
    ALGORITHM = 'RSA_OAEP',
    ENCRYPTED_VALUE = 0x...
);
```

#### Row Level Security (RLS)
```sql
-- Criar função de segurança
CREATE FUNCTION dbo.fn_securitypredicate(@UserId int)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result
WHERE @UserId = USER_ID();

-- Criar política de segurança
CREATE SECURITY POLICY dbo.MySecurityPolicy
ADD FILTER PREDICATE dbo.fn_securitypredicate(UserId) ON dbo.MyTable
WITH (STATE = ON);
```

### Monitoramento

#### Métricas Importantes
- **DTU/CPU Percentage**: Utilização de recursos
- **Database Size**: Crescimento do banco
- **Active Connections**: Conexões simultâneas
- **Query Duration**: Performance de consultas

#### Configuração de Alertas
```bash
# Criar regra de alerta para alta utilização de CPU
az monitor metrics alert create \
    --name "High CPU Alert" \
    --resource-group myResourceGroup \
    --scopes /subscriptions/{subscription-id}/resourceGroups/myResourceGroup/providers/Microsoft.Sql/servers/myserver/databases/mydatabase \
    --condition "avg Percentage CPU > 80" \
    --window-size 5m \
    --evaluation-frequency 1m
```

## 🚀 Otimização de Performance

### Indexação
```sql
-- Criar índice otimizado
CREATE NONCLUSTERED INDEX IX_MyTable_OptimizedIndex
ON dbo.MyTable (Column1, Column2)
INCLUDE (Column3, Column4)
WITH (ONLINE = ON, FILLFACTOR = 90);

-- Analisar fragmentação
SELECT 
    object_name(object_id) AS TableName,
    index_id,
    avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 10;
```

### Query Tuning
```sql
-- Habilitar Query Store
ALTER DATABASE mydatabase SET QUERY_STORE = ON;

-- Configurar Query Store
ALTER DATABASE mydatabase SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60
);

-- Analisar queries com pior performance
SELECT TOP 10
    query_id,
    query_sql_text,
    avg_duration,
    avg_cpu_time,
    avg_logical_io_reads
FROM sys.query_store_query_text qt
JOIN sys.query_store_query q ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
ORDER BY avg_duration DESC;
```

## 🔍 Troubleshooting

### Problemas Comuns

#### Conectividade
- Verificar regras de firewall
- Validar string de conexão
- Confirmar status do serviço

#### Performance
- Analisar planos de execução
- Verificar estatísticas de índices
- Monitorar waits e locks

#### Capacidade
- Monitorar utilização de DTU/vCore
- Verificar crescimento de logs
- Analisar padrões de acesso

### Scripts de Diagnóstico
```sql
-- Verificar conexões ativas
SELECT 
    session_id,
    login_name,
    host_name,
    program_name,
    login_time,
    status
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;

-- Analisar waits
SELECT TOP 10
    wait_type,
    wait_time_ms,
    waiting_tasks_count,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE waiting_tasks_count > 0
ORDER BY wait_time_ms DESC;

-- Verificar bloqueios
SELECT 
    blocking_session_id,
    session_id,
    wait_duration_ms,
    wait_type,
    resource_description
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
```

## 📚 Recursos Adicionais

### Documentação Técnica
- [Azure SQL Database Best Practices](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-best-practices-data-sync)
- [Performance Tuning Guide](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-performance-guidance)
- [Security Best Practices](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-security-best-practice)

### Ferramentas Úteis
- [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/)
- [SQL Server Profiler](https://docs.microsoft.com/en-us/sql/tools/sql-server-profiler/)
- [Database Migration Assistant](https://docs.microsoft.com/en-us/sql/dma/)

---

Este guia fornece uma base sólida para configurar bancos de dados na Azure. Lembre-se de sempre testar em ambiente de desenvolvimento antes de implementar em produção.
