# Configurações do Copilot

Este arquivo fornece instruções específicas para o GitHub Copilot gerar código de melhor qualidade para este projeto.

## Contexto do Projeto

Este é um repositório de documentação sobre configuração de bancos de dados na Azure, desenvolvido como parte de um desafio da DIO (Digital Innovation One).

## Instruções para o Copilot

### Tecnologias Principais
- Microsoft Azure
- Azure SQL Database
- Azure SQL Managed Instance
- Azure Cosmos DB
- PowerShell
- Azure CLI
- SQL Server

### Padrões de Código
- Use sempre as melhores práticas de segurança da Azure
- Prefira Azure CLI para automação
- Inclua tratamento de erros em scripts
- Use nomenclatura clara e descritiva para recursos
- Sempre inclua comentários explicativos

### Convenções de Nomenclatura
- Recursos Azure: prefixo indicando tipo (srv-, db-, rg-, etc.)
- Scripts: PascalCase para funções, kebab-case para arquivos
- Variáveis: camelCase

### Segurança
- Nunca hardcode credenciais
- Use Managed Identities quando possível
- Sempre configure firewalls restritivos
- Implemente princípio do menor privilégio

### Performance
- Sempre considere custos nas sugestões
- Prefira soluções escaláveis
- Inclua monitoramento nas implementações
