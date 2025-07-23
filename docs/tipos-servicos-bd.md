# Tipos de Serviços de Banco de Dados na Azure

## 🎯 Visão Geral

A Microsoft Azure oferece uma ampla gama de serviços de banco de dados para atender diferentes necessidades de aplicações, desde bancos relacionais tradicionais até soluções NoSQL modernas e especializadas.

## 🗄️ Bancos de Dados Relacionais

### Azure SQL Database

#### Características Principais
- **Tipo**: PaaS (Platform as a Service)
- **Compatibilidade**: SQL Server
- **Escalabilidade**: Automática
- **Backup**: Automático com geo-replicação
- **SLA**: Até 99.995%

#### Modelos de Compra
1. **DTU (Database Transaction Unit)**
   - Basic: 5 DTUs, 2GB armazenamento
   - Standard: 10-3000 DTUs, até 1TB
   - Premium: 125-4000 DTUs, até 4TB

2. **vCore (Virtual Core)**
   - General Purpose: Balanced workloads
   - Business Critical: High performance, low latency
   - Hyperscale: Large databases (até 100TB)

#### Casos de Uso Ideais
- ✅ Aplicações web e móveis
- ✅ SaaS applications
- ✅ Modernização de aplicações legadas
- ✅ Desenvolvimento ágil

#### Limitações
- ❌ Funcionalidades específicas do SQL Server não suportadas
- ❌ Sem acesso ao sistema operacional
- ❌ Algumas extensões não disponíveis

### Azure SQL Managed Instance

#### Características Principais
- **Tipo**: PaaS com compatibilidade completa
- **Compatibilidade**: 100% SQL Server
- **Isolamento**: Rede virtual dedicada
- **Backup**: Automático com point-in-time recovery
- **SLA**: Até 99.99%

#### Configurações Disponíveis
1. **General Purpose**
   - Standard SSD storage
   - Até 8TB por instância
   - 4-80 vCores

2. **Business Critical**
   - Local SSD storage
   - Always On Availability Groups
   - Read replicas incluídas

#### Casos de Uso Ideais
- ✅ Migração lift-and-shift do SQL Server
- ✅ Aplicações que requerem funcionalidades avançadas
- ✅ Cenários híbridos on-premises/cloud
- ✅ Cross-database queries

#### Limitações
- ❌ Maior custo que SQL Database
- ❌ Tempo de provisionamento mais longo
- ❌ Requer configuração de VNet

### Azure Database for MySQL

#### Características Principais
- **Versões Suportadas**: 5.7, 8.0
- **Alta Disponibilidade**: Zone-redundant
- **Backup**: Automático (7-35 dias)
- **SSL**: Enforced por padrão

#### Tiers de Serviço
1. **Basic**
   - 1-2 vCores
   - Até 1TB storage
   - Backup local

2. **General Purpose**
   - 2-64 vCores
   - Até 16TB storage
   - Geo-redundant backup

3. **Memory Optimized**
   - 2-32 vCores
   - Otimizado para cargas memory-intensive

#### Casos de Uso Ideais
- ✅ Aplicações web PHP/Python/Node.js
- ✅ Migração de MySQL on-premises
- ✅ Desenvolvimento de aplicações open-source
- ✅ Content Management Systems

### Azure Database for PostgreSQL

#### Opções de Deployment
1. **Single Server**
   - Gerenciamento simplificado
   - 3 pricing tiers
   - Backup automático

2. **Flexible Server**
   - Controle granular
   - Zone-redundant HA
   - Manutenção customizável

3. **Hyperscale (Citus)**
   - Distribuição horizontal
   - Sharding automático
   - Multi-tenant applications

#### Casos de Uso Ideais
- ✅ Aplicações geoespaciais (PostGIS)
- ✅ Analytics e data warehousing
- ✅ Aplicações com JSON/JSONB
- ✅ Time-series data

## 🌐 Bancos de Dados NoSQL

### Azure Cosmos DB

#### Características Principais
- **Distribuição Global**: Multi-region, multi-master
- **Latência**: <10ms no percentil 99
- **Consistência**: 5 níveis configuráveis
- **SLA**: 99.999% availability

#### Modelos de API
1. **Core (SQL)**
   - JSON documents
   - SQL-like queries
   - LINQ support

2. **MongoDB**
   - Wire protocol compatible
   - Sharding automático
   - GridFS support

3. **Cassandra**
   - CQL compatibility
   - Column-family model
   - Eventual consistency

4. **Azure Table**
   - Key-value pairs
   - Schema-less
   - Partition key + row key

5. **Gremlin (Graph)**
   - Property graph model
   - Traversal queries
   - TinkerPop compatible

#### Casos de Uso Ideais
- ✅ Aplicações globalmente distribuídas
- ✅ IoT e telemetria
- ✅ Catálogos de produtos
- ✅ Aplicações real-time
- ✅ Gaming leaderboards

### Azure Cache for Redis

#### Tiers Disponíveis
1. **Basic**
   - Single node
   - 250MB - 53GB
   - Desenvolvimento e testes

2. **Standard**
   - Master/replica
   - Alta disponibilidade
   - SLA 99.9%

3. **Premium**
   - Clustering Redis
   - Persistência Redis
   - Virtual Network support

#### Casos de Uso Ideais
- ✅ Session storage
- ✅ Application caching
- ✅ Real-time analytics
- ✅ Message brokering

## 📊 Bancos de Dados Analíticos

### Azure Synapse Analytics

#### Componentes Principais
1. **SQL Pools**
   - Data warehousing
   - Massively parallel processing
   - Columnar storage

2. **Spark Pools**
   - Big data processing
   - Machine learning
   - Data lake analytics

3. **Data Explorer**
   - Time-series analytics
   - Log analytics
   - Real-time insights

#### Casos de Uso Ideais
- ✅ Data warehousing enterprise
- ✅ Advanced analytics
- ✅ Machine learning workflows
- ✅ Real-time analytics

### Azure Data Explorer (Kusto)

#### Características Principais
- **Performance**: Queries em segundos sobre TBs
- **Ingestão**: Streaming e batch
- **Linguagem**: KQL (Kusto Query Language)
- **Escalabilidade**: Horizontal automática

#### Casos de Uso Ideais
- ✅ Logs e telemetria analysis
- ✅ Time-series analytics
- ✅ IoT data processing
- ✅ Security analytics

## 🔄 Bancos de Dados Especializados

### Azure Database for MariaDB

#### Características
- **Versões**: 10.2, 10.3
- **Compatibilidade**: MySQL wire protocol
- **Storage**: General Purpose SSD
- **Backup**: Automático geo-redundante

### Azure SQL Edge

#### Características
- **Deployment**: IoT devices, edge computing
- **Tamanho**: Lightweight footprint
- **Streaming**: Built-in streaming capabilities
- **Machine Learning**: ONNX model support

## 📋 Matriz de Comparação

| Serviço | Tipo | Casos de Uso | Escalabilidade | Complexidade |
|---------|------|--------------|----------------|--------------|
| SQL Database | Relacional | Web apps, SaaS | Automática | Baixa |
| SQL Managed Instance | Relacional | Migração enterprise | Manual | Média |
| MySQL | Relacional | LAMP stack | Automática | Baixa |
| PostgreSQL | Relacional | Analytics, GIS | Automática | Média |
| Cosmos DB | NoSQL | Global apps | Ilimitada | Alta |
| Redis Cache | Cache | Performance | Manual | Baixa |
| Synapse | Analytics | Data warehouse | Manual | Alta |
| Data Explorer | Analytics | Time-series | Automática | Média |

## 🎯 Guia de Seleção

### Para Aplicações Web Tradicionais
```
Dados estruturados + familiaridade SQL → Azure SQL Database
Migração MySQL existente → Azure Database for MySQL
Aplicação PostgreSQL → Azure Database for PostgreSQL
```

### Para Aplicações Modernas
```
Escala global + baixa latência → Cosmos DB
Cache de alta performance → Redis Cache
Dados semi-estruturados → Cosmos DB (SQL API)
```

### Para Analytics
```
Data warehouse enterprise → Synapse Analytics
Logs e telemetria → Data Explorer
Time-series em escala → Data Explorer
```

### Para Migração
```
SQL Server completo → SQL Managed Instance
SQL Server simplificado → SQL Database
MySQL/PostgreSQL → Respectivos serviços Azure
```

## 💡 Considerações de Arquitetura

### Padrões Recomendados

#### Polyglot Persistence
- Usar diferentes bancos para diferentes necessidades
- SQL Database para transações OLTP
- Cosmos DB para catálogos e sessões
- Redis para cache
- Synapse para analytics

#### Hybrid Architectures
- SQL Managed Instance para core business
- Cosmos DB para dados globais
- Data Explorer para telemetria
- Redis para performance optimization

## 🔗 Integração com Outros Serviços

### Azure Data Factory
- ETL/ELT pipelines
- Data movement between services
- Scheduled data processing

### Azure Logic Apps
- Automated workflows
- Database triggers
- Cross-service integration

### Power BI
- Native connectors
- DirectQuery support
- Real-time dashboards

---

A escolha do serviço correto é fundamental para o sucesso do projeto. Considere sempre os requisitos de performance, escalabilidade, consistência e custo ao tomar sua decisão.
