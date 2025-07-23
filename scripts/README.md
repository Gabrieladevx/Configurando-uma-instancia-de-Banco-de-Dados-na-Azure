# Scripts de Automação - Azure Database

Esta pasta contém scripts úteis para automação de tarefas relacionadas aos bancos de dados na Azure.

## 📁 Estrutura dos Scripts

### PowerShell Scripts
- `Deploy-AzureSQLDatabase.ps1` - Script completo de deployment
- `Test-DatabaseConnectivity.ps1` - Teste de conectividade
- `Monitor-DatabasePerformance.ps1` - Monitoramento de performance
- `Backup-DatabaseConfiguration.ps1` - Backup de configurações

### Azure CLI Scripts
- `deploy-sql-database.sh` - Deployment via Azure CLI
- `configure-firewall.sh` - Configuração de firewall
- `setup-monitoring.sh` - Configuração de monitoramento

### SQL Scripts
- `create-test-tables.sql` - Criação de tabelas de teste
- `performance-queries.sql` - Queries de análise de performance
- `maintenance-procedures.sql` - Procedimentos de manutenção

## 🚀 Como Usar

1. **Pré-requisitos**
   - Azure CLI instalado
   - PowerShell 7+ (para scripts PowerShell)
   - Permissões adequadas na assinatura Azure

2. **Configuração**
   - Ajuste as variáveis no início de cada script
   - Configure as credenciais de autenticação
   - Valide em ambiente de desenvolvimento primeiro

3. **Execução**
   - Execute scripts em ordem quando aplicável
   - Monitore logs e saídas
   - Valide resultados antes de prosseguir

## ⚠️ Avisos Importantes

- Sempre teste em ambiente de desenvolvimento primeiro
- Revise configurações antes de executar em produção
- Mantenha backups antes de fazer alterações
- Monitore custos após deployment de recursos

---

**Nota**: Estes scripts são fornecidos como exemplos educacionais. Adapte-os às suas necessidades específicas.
