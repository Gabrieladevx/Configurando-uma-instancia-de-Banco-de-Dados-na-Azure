# Configurando uma Instância de Banco de Dados na Azure

[![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![SQL Database](https://img.shields.io/badge/Azure_SQL-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://docs.microsoft.com/en-us/azure/sql-database/)

## 📋 Sobre o Projeto

Este repositório documenta minha experiência prática com a configuração de instâncias de Banco de Dados na plataforma Microsoft Azure, como parte do desafio proposto pela DIO (Digital Innovation One). O objetivo é servir como material de apoio para estudos e futuras implementações.

## 🎯 Objetivos de Aprendizagem

- ✅ Aplicar conceitos aprendidos em ambiente prático
- ✅ Documentar processos técnicos de forma clara e estruturada  
- ✅ Utilizar o GitHub como ferramenta para compartilhamento de documentação técnica
- ✅ Compreender os diferentes serviços de banco de dados oferecidos pela Azure

## 📚 Conteúdo

### 📖 Documentação Principal
- [Guia Completo de Configuração](./docs/guia-configuracao.md)
- [Tipos de Serviços de Banco de Dados na Azure](./docs/tipos-servicos-bd.md)
- [Configuração Passo a Passo](./docs/passo-a-passo.md)
- [Melhores Práticas e Dicas](./docs/melhores-praticas.md)
- [Troubleshooting e Soluções](./docs/troubleshooting.md)

### 🖼️ Recursos Visuais
- [Capturas de Tela](./images/) - Screenshots do processo de configuração
- [Diagramas de Arquitetura](./images/arquitetura/) - Representações visuais da estrutura

## 🛠️ Serviços Azure Abordados

### Azure SQL Database
- **Descrição**: Banco de dados relacional como serviço (DBaaS)
- **Casos de Uso**: Aplicações web, sistemas de gestão, analytics
- **Características**: Alta disponibilidade, escalabilidade automática, backup automático

### Azure SQL Managed Instance  
- **Descrição**: Instância gerenciada do SQL Server na nuvem
- **Casos de Uso**: Migração de sistemas legados, aplicações empresariais
- **Características**: Compatibilidade total com SQL Server, isolamento de rede

### Azure Database for MySQL/PostgreSQL
- **Descrição**: Serviços gerenciados para bancos open-source
- **Casos de Uso**: Aplicações web modernas, microserviços
- **Características**: Backup automático, monitoramento integrado, patches automáticos

### Azure Cosmos DB
- **Descrição**: Banco de dados NoSQL distribuído globalmente
- **Casos de Uso**: Aplicações globais, IoT, real-time analytics
- **Características**: Multi-modelo, baixa latência, escalabilidade global

## 🚀 Processo de Configuração

### Pré-requisitos
- Conta ativa no Microsoft Azure
- Assinatura válida do Azure
- Conhecimentos básicos de SQL e administração de banco de dados

### Etapas Principais
1. **Planejamento e Dimensionamento**
   - Definição de requisitos
   - Escolha do tipo de serviço
   - Estimativa de custos

2. **Criação do Recurso**
   - Configuração inicial
   - Definição de parâmetros
   - Configuração de segurança

3. **Configuração Avançada**
   - Regras de firewall
   - Backup e recuperação
   - Monitoramento

4. **Testes e Validação**
   - Conectividade
   - Performance
   - Funcionalidades

## 💰 Considerações de Custo

| Serviço | Modelo de Preço | Fatores de Custo |
|---------|----------------|------------------|
| SQL Database | DTU ou vCore | Computação, armazenamento, backup |
| SQL Managed Instance | vCore | Instância, armazenamento, backup |
| MySQL/PostgreSQL | vCore | Computação, armazenamento, backup |
| Cosmos DB | RU/s | Request Units, armazenamento, replicação |

## 🔒 Segurança e Conformidade

- **Autenticação**: Azure Active Directory, SQL Authentication
- **Criptografia**: Em repouso e em trânsito
- **Firewall**: Regras de IP e redes virtuais
- **Auditoria**: Logs de segurança e compliance
- **Backup**: Automatizado com retenção configurável

## 📊 Monitoramento e Performance

### Métricas Importantes
- CPU e memória
- Transações por segundo
- Latência de queries
- Espaço de armazenamento utilizado

### Ferramentas de Monitoramento
- Azure Monitor
- SQL Insights
- Query Performance Insight
- Azure Advisor

## 🛡️ Backup e Recuperação

### Estratégias de Backup
- **Backup Automático**: Configurado por padrão
- **Backup Geo-redundante**: Para disaster recovery
- **Point-in-time Recovery**: Restauração para momento específico
- **Long-term Retention**: Retenção de longo prazo

## 🌐 Recursos Úteis

### Documentação Oficial
- [Azure SQL Database Documentation](https://docs.microsoft.com/en-us/azure/sql-database/)
- [Azure Database for MySQL](https://docs.microsoft.com/en-us/azure/mysql/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/)
- [Azure Cosmos DB Documentation](https://docs.microsoft.com/en-us/azure/cosmos-db/)

### Tutoriais e Guias
- [Início Rápido: Criar Instância Gerenciada de SQL do Azure](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-get-started)
- [Tutorial: Migrar SQL Server para Azure SQL Database](https://docs.microsoft.com/en-us/azure/dms/tutorial-sql-server-to-azure-sql)

### Ferramentas
- [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/)
- [SQL Server Management Studio (SSMS)](https://docs.microsoft.com/en-us/sql/ssms/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/)
