# Configuração Passo a Passo - Azure SQL Database

## 🎯 Objetivo

Este documento fornece um tutorial detalhado e prático para configurar uma instância do Azure SQL Database do zero, incluindo todas as etapas necessárias e capturas de tela dos processos.

## 🚀 Passo 1: Acesso ao Portal Azure

### 1.1 Login no Azure Portal
1. Acesse [portal.azure.com](https://portal.azure.com)
2. Faça login com suas credenciais da Microsoft
3. Verifique se está na assinatura correta

### 1.2 Navegação Inicial
1. No menu lateral, clique em **"Criar um recurso"**
2. Na barra de pesquisa, digite **"SQL Database"**
3. Selecione **"SQL Database"** da Microsoft

> 📸 **Captura de Tela**: Tela inicial do portal Azure com menu de criação de recursos

## 🗄️ Passo 2: Configuração Básica do Banco

### 2.1 Informações do Projeto
```
Assinatura: [Sua assinatura Azure]
Grupo de Recursos: [Criar novo ou selecionar existente]
Nome do Grupo: rg-database-demo
```

### 2.2 Detalhes da Instância
```
Nome do Banco de Dados: db-aplicacao-web
Servidor: [Criar novo servidor]
Localização: Brazil South (ou região de sua preferência)
```

### 2.3 Criação do Servidor SQL
1. Clique em **"Criar novo"** para o servidor
2. Preencha os dados:
   ```
   Nome do Servidor: srv-aplicacao-web-001
   Localização: Brazil South
   Método de Autenticação: "Usar autenticação do SQL"
   Login do Administrador: sqladmin
   Senha: MinhaS3nh4S3gur4!
   Confirmar Senha: MinhaS3nh4S3gur4!
   ```

> 📸 **Captura de Tela**: Formulário de criação do servidor SQL

### 2.4 Configuração de Computação e Armazenamento
1. Clique em **"Configurar banco de dados"**
2. Selecione o tier de serviço:
   - **Basic**: Para desenvolvimento e testes
   - **Standard**: Para cargas de trabalho moderadas
   - **Premium**: Para alta performance

**Exemplo para ambiente de desenvolvimento:**
```
Tier de Serviço: Standard
Nível de Computação: S0 (10 DTUs)
Armazenamento: 250 GB
```

> 📸 **Captura de Tela**: Seleção de tier de performance

## 🔒 Passo 3: Configuração de Segurança

### 3.1 Configuração de Rede
1. Na aba **"Rede"**, configure:
   ```
   Método de Conectividade: Ponto de extremidade público
   Permitir serviços do Azure: Sim
   Adicionar IP do cliente atual: Sim
   ```

2. **Regras de Firewall**:
   - Nome da regra: `AllowMyComputer`
   - IP inicial: [Seu IP público]
   - IP final: [Seu IP público]

> 📸 **Captura de Tela**: Configuração de firewall e rede

### 3.2 Configurações Adicionais
1. Na aba **"Configurações adicionais"**:
   ```
   Usar dados existentes: Nenhum
   Agrupamento: SQL_Latin1_General_CP1_CI_AS
   ```

2. **Advanced Data Security**:
   ```
   Habilitar Advanced Data Security: Sim
   ```

> 📸 **Captura de Tela**: Configurações de segurança avançada

## 🏷️ Passo 4: Tags e Revisão

### 4.1 Aplicação de Tags
```
Ambiente: Desenvolvimento
Projeto: AplicacaoWeb
Responsavel: MeuNome
CentroCusto: TI-001
```

### 4.2 Revisão Final
1. Revise todas as configurações
2. Verifique o custo estimado mensal
3. Clique em **"Criar"**

> 📸 **Captura de Tela**: Tela de revisão com resumo das configurações

## ⏱️ Passo 5: Processo de Deployment

### 5.1 Acompanhamento do Deployment
1. O processo levará alguns minutos
2. Acompanhe o progresso na seção "Notificações"
3. Aguarde a mensagem de "Deployment concluído"

### 5.2 Verificação do Recurso Criado
1. Acesse o grupo de recursos criado
2. Verifique se os seguintes recursos foram criados:
   - Servidor SQL
   - Banco de dados SQL
   - Regras de firewall

> 📸 **Captura de Tela**: Recursos criados no grupo de recursos

## 🔗 Passo 6: Teste de Conectividade

### 6.1 Obtenção da String de Conexão
1. Acesse o banco de dados criado
2. No menu lateral, clique em **"Strings de conexão"**
3. Copie a string de conexão ADO.NET:

```csharp
Server=tcp:srv-aplicacao-web-001.database.windows.net,1433;
Initial Catalog=db-aplicacao-web;
Persist Security Info=False;
User ID=sqladmin;
Password={your_password};
MultipleActiveResultSets=False;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

> 📸 **Captura de Tela**: Página de strings de conexão

### 6.2 Teste com SQL Server Management Studio (SSMS)

#### Instalação do SSMS
1. Baixe o SSMS do site oficial da Microsoft
2. Instale seguindo o assistente padrão

#### Conexão ao Banco
1. Abra o SQL Server Management Studio
2. Configure a conexão:
   ```
   Tipo de Servidor: Mecanismo de Banco de Dados
   Nome do Servidor: srv-aplicacao-web-001.database.windows.net
   Autenticação: Autenticação do SQL Server
   Login: sqladmin
   Senha: MinhaS3nh4S3gur4!
   ```

3. Clique em **"Conectar"**

> 📸 **Captura de Tela**: SSMS conectado ao Azure SQL Database

### 6.3 Teste com Azure Data Studio

#### Instalação do Azure Data Studio
1. Baixe do site oficial da Microsoft
2. Instale seguindo o assistente

#### Criação da Conexão
1. Abra o Azure Data Studio
2. Clique em **"New Connection"**
3. Preencha os dados:
   ```
   Connection Type: Microsoft SQL Server
   Server: srv-aplicacao-web-001.database.windows.net
   Authentication Type: SQL Login
   User name: sqladmin
   Password: MinhaS3nh4S3gur4!
   Database: db-aplicacao-web
   ```

> 📸 **Captura de Tela**: Azure Data Studio conectado

## 📊 Passo 7: Criação de Estruturas Básicas

### 7.1 Criação de Tabela de Teste
```sql
-- Criar tabela de usuários
CREATE TABLE Usuarios (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    DataCriacao DATETIME2 DEFAULT GETDATE(),
    Ativo BIT DEFAULT 1
);

-- Inserir dados de teste
INSERT INTO Usuarios (Nome, Email) VALUES
('João Silva', 'joao.silva@email.com'),
('Maria Santos', 'maria.santos@email.com'),
('Pedro Oliveira', 'pedro.oliveira@email.com');

-- Consultar dados
SELECT * FROM Usuarios;
```

### 7.2 Verificação da Performance
```sql
-- Verificar estatísticas básicas
SELECT 
    COUNT(*) as TotalRegistros,
    MIN(DataCriacao) as PrimeiroRegistro,
    MAX(DataCriacao) as UltimoRegistro
FROM Usuarios;
```

> 📸 **Captura de Tela**: Execução das queries no Azure Data Studio

## 📈 Passo 8: Configuração de Monitoramento

### 8.1 Habilitação do Query Performance Insight
1. No portal Azure, acesse seu banco de dados
2. No menu lateral, clique em **"Query Performance Insight"**
3. Clique em **"Configurações"**
4. Habilite a coleta de dados

### 8.2 Configuração de Alertas
1. Acesse **"Alertas"** no menu do banco de dados
2. Clique em **"Nova regra de alerta"**
3. Configure um alerta para DTU alta:
   ```
   Métrica: DTU Percentage
   Condição: Maior que 80%
   Período de Avaliação: 5 minutos
   Frequência: 1 minuto
   ```

> 📸 **Captura de Tela**: Configuração de alertas de performance

## 🔄 Passo 9: Backup e Recuperação

### 9.1 Verificação de Configurações de Backup
1. Acesse **"Backup de longo prazo"**
2. Verifique as configurações padrão:
   ```
   Retenção de backup automático: 7 dias
   Backup geo-redundante: Habilitado
   Point-in-time recovery: Últimos 7 dias
   ```

### 9.2 Teste de Restauração (Simulação)
1. No portal, clique em **"Restaurar"**
2. Verifique as opções disponíveis:
   - Restauração point-in-time
   - Restauração de backup geo-redundante
   - Restauração de backup excluído

> 📸 **Captura de Tela**: Opções de restauração do banco de dados

## ✅ Passo 10: Validação Final

### 10.1 Checklist de Configuração
- [ ] Servidor SQL criado e configurado
- [ ] Banco de dados ativo e acessível
- [ ] Regras de firewall configuradas
- [ ] Conectividade testada via SSMS/Azure Data Studio
- [ ] Tabelas de teste criadas
- [ ] Monitoramento configurado
- [ ] Backup automático verificado

### 10.2 Testes de Funcionalidade
```sql
-- Teste de inserção
INSERT INTO Usuarios (Nome, Email) 
VALUES ('Teste Usuario', 'teste@email.com');

-- Teste de consulta
SELECT COUNT(*) FROM Usuarios;

-- Teste de atualização
UPDATE Usuarios 
SET Nome = 'Teste Usuario Atualizado' 
WHERE Email = 'teste@email.com';

-- Teste de exclusão
DELETE FROM Usuarios 
WHERE Email = 'teste@email.com';
```

## 🎉 Conclusão

Parabéns! Você configurou com sucesso uma instância do Azure SQL Database. O banco está agora:

- ✅ **Operacional**: Totalmente funcional e acessível
- ✅ **Seguro**: Com autenticação e firewall configurados
- ✅ **Monitorado**: Com alertas e insights habilitados
- ✅ **Protegido**: Com backup automático ativo

## 📝 Próximos Passos

1. **Desenvolvimento**: Integrar com sua aplicação
2. **Otimização**: Ajustar performance conforme necessário
3. **Segurança**: Implementar criptografia e auditoria
4. **Scaling**: Ajustar recursos conforme demanda

## 🔗 Links Úteis

- [Documentação Azure SQL Database](https://docs.microsoft.com/pt-br/azure/sql-database/)
- [Download SSMS](https://docs.microsoft.com/pt-br/sql/ssms/download-sql-server-management-studio-ssms)
- [Download Azure Data Studio](https://docs.microsoft.com/pt-br/sql/azure-data-studio/download)

---

> 💡 **Dica**: Mantenha sempre suas credenciais seguras e monitore regularmente o desempenho e custos do seu banco de dados.
