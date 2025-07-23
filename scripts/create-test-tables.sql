-- Scripts SQL para Teste e Validação
-- Azure SQL Database - DIO Challenge
-- Data: Janeiro 2024

-- =====================================================
-- 1. CRIAÇÃO DE ESTRUTURAS DE TESTE
-- =====================================================

-- Criar schema para testes
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'teste')
BEGIN
    EXEC('CREATE SCHEMA teste')
    PRINT 'Schema "teste" criado com sucesso'
END
ELSE
    PRINT 'Schema "teste" já existe'
GO

-- Tabela de usuários para testes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Usuarios' AND schema_id = SCHEMA_ID('teste'))
BEGIN
    CREATE TABLE teste.Usuarios (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Nome NVARCHAR(100) NOT NULL,
        Email NVARCHAR(255) UNIQUE NOT NULL,
        DataNascimento DATE,
        DataCriacao DATETIME2 DEFAULT GETDATE(),
        DataUltimaAtualizacao DATETIME2 DEFAULT GETDATE(),
        Ativo BIT DEFAULT 1,
        Observacoes NVARCHAR(MAX)
    );
    
    PRINT 'Tabela "teste.Usuarios" criada com sucesso'
END
ELSE
    PRINT 'Tabela "teste.Usuarios" já existe'
GO

-- Tabela de produtos para testes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Produtos' AND schema_id = SCHEMA_ID('teste'))
BEGIN
    CREATE TABLE teste.Produtos (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Nome NVARCHAR(200) NOT NULL,
        Descricao NVARCHAR(MAX),
        Preco DECIMAL(10,2) NOT NULL,
        Categoria NVARCHAR(50),
        DataCriacao DATETIME2 DEFAULT GETDATE(),
        Ativo BIT DEFAULT 1
    );
    
    PRINT 'Tabela "teste.Produtos" criada com sucesso'
END
ELSE
    PRINT 'Tabela "teste.Produtos" já existe'
GO

-- Tabela de pedidos para testes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Pedidos' AND schema_id = SCHEMA_ID('teste'))
BEGIN
    CREATE TABLE teste.Pedidos (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UsuarioId INT NOT NULL,
        DataPedido DATETIME2 DEFAULT GETDATE(),
        ValorTotal DECIMAL(10,2) NOT NULL,
        Status NVARCHAR(20) DEFAULT 'Pendente',
        FOREIGN KEY (UsuarioId) REFERENCES teste.Usuarios(Id)
    );
    
    PRINT 'Tabela "teste.Pedidos" criada com sucesso'
END
ELSE
    PRINT 'Tabela "teste.Pedidos" já existe'
GO

-- Tabela de itens do pedido
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ItensPedido' AND schema_id = SCHEMA_ID('teste'))
BEGIN
    CREATE TABLE teste.ItensPedido (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        PedidoId INT NOT NULL,
        ProdutoId INT NOT NULL,
        Quantidade INT NOT NULL DEFAULT 1,
        PrecoUnitario DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (PedidoId) REFERENCES teste.Pedidos(Id),
        FOREIGN KEY (ProdutoId) REFERENCES teste.Produtos(Id)
    );
    
    PRINT 'Tabela "teste.ItensPedido" criada com sucesso'
END
ELSE
    PRINT 'Tabela "teste.ItensPedido" já existe'
GO

-- =====================================================
-- 2. INSERÇÃO DE DADOS DE TESTE
-- =====================================================

-- Inserir usuários de teste
IF NOT EXISTS (SELECT * FROM teste.Usuarios)
BEGIN
    INSERT INTO teste.Usuarios (Nome, Email, DataNascimento) VALUES
    ('João Silva', 'joao.silva@email.com', '1985-03-15'),
    ('Maria Santos', 'maria.santos@email.com', '1990-07-22'),
    ('Pedro Oliveira', 'pedro.oliveira@email.com', '1988-11-08'),
    ('Ana Costa', 'ana.costa@email.com', '1992-01-30'),
    ('Carlos Ferreira', 'carlos.ferreira@email.com', '1987-05-12'),
    ('Lucia Pereira', 'lucia.pereira@email.com', '1989-09-18'),
    ('Roberto Lima', 'roberto.lima@email.com', '1991-12-03'),
    ('Fernanda Alves', 'fernanda.alves@email.com', '1986-04-25'),
    ('Marcos Rodrigues', 'marcos.rodrigues@email.com', '1993-08-14'),
    ('Juliana Sousa', 'juliana.sousa@email.com', '1984-06-07');
    
    PRINT 'Dados de teste inseridos em "teste.Usuarios"'
END
GO

-- Inserir produtos de teste
IF NOT EXISTS (SELECT * FROM teste.Produtos)
BEGIN
    INSERT INTO teste.Produtos (Nome, Descricao, Preco, Categoria) VALUES
    ('Notebook Gamer', 'Notebook para jogos com placa de vídeo dedicada', 3499.99, 'Eletrônicos'),
    ('Mouse Wireless', 'Mouse sem fio ergonômico', 89.90, 'Acessórios'),
    ('Teclado Mecânico', 'Teclado mecânico para programadores', 299.90, 'Acessórios'),
    ('Monitor 4K', 'Monitor 27 polegadas 4K', 1299.99, 'Eletrônicos'),
    ('Webcam HD', 'Câmera web para videochamadas', 199.90, 'Acessórios'),
    ('Headset Gamer', 'Fone de ouvido para jogos', 249.90, 'Acessórios'),
    ('SSD 1TB', 'Disco sólido para armazenamento', 599.90, 'Hardware'),
    ('Memória RAM 16GB', 'Memória DDR4 16GB', 399.90, 'Hardware'),
    ('Placa de Vídeo', 'GPU para gaming e design', 2499.99, 'Hardware'),
    ('Fonte 650W', 'Fonte de alimentação modular', 449.90, 'Hardware');
    
    PRINT 'Dados de teste inseridos em "teste.Produtos"'
END
GO

-- Inserir pedidos de teste
IF NOT EXISTS (SELECT * FROM teste.Pedidos)
BEGIN
    INSERT INTO teste.Pedidos (UsuarioId, ValorTotal, Status) VALUES
    (1, 3589.89, 'Concluído'),
    (2, 389.80, 'Pendente'),
    (3, 1599.89, 'Enviado'),
    (4, 2749.88, 'Concluído'),
    (5, 649.80, 'Pendente'),
    (1, 849.80, 'Cancelado'),
    (6, 3949.88, 'Concluído'),
    (7, 199.90, 'Enviado'),
    (8, 1699.79, 'Pendente'),
    (9, 299.90, 'Concluído');
    
    PRINT 'Dados de teste inseridos em "teste.Pedidos"'
END
GO

-- Inserir itens de pedido
IF NOT EXISTS (SELECT * FROM teste.ItensPedido)
BEGIN
    INSERT INTO teste.ItensPedido (PedidoId, ProdutoId, Quantidade, PrecoUnitario) VALUES
    (1, 1, 1, 3499.99),  -- Notebook
    (1, 2, 1, 89.90),    -- Mouse
    (2, 3, 1, 299.90),   -- Teclado
    (2, 2, 1, 89.90),    -- Mouse
    (3, 4, 1, 1299.99),  -- Monitor
    (3, 6, 1, 249.90),   -- Headset
    (4, 9, 1, 2499.99),  -- Placa de Vídeo
    (4, 8, 1, 249.90),   -- Memória RAM corrigida
    (5, 7, 1, 599.90),   -- SSD
    (5, 10, 1, 49.90);   -- Fonte corrigida
    
    PRINT 'Dados de teste inseridos em "teste.ItensPedido"'
END
GO

-- =====================================================
-- 3. CRIAÇÃO DE ÍNDICES
-- =====================================================

-- Índice para melhorar consultas por email
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Usuarios_Email')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Usuarios_Email 
    ON teste.Usuarios (Email);
    
    PRINT 'Índice IX_Usuarios_Email criado'
END
GO

-- Índice para melhorar consultas por categoria de produto
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Produtos_Categoria')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Produtos_Categoria 
    ON teste.Produtos (Categoria);
    
    PRINT 'Índice IX_Produtos_Categoria criado'
END
GO

-- Índice para melhorar consultas por status do pedido
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Pedidos_Status')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pedidos_Status 
    ON teste.Pedidos (Status);
    
    PRINT 'Índice IX_Pedidos_Status criado'
END
GO

-- =====================================================
-- 4. QUERIES DE VALIDAÇÃO E TESTE
-- =====================================================

PRINT '=== EXECUTANDO QUERIES DE VALIDAÇÃO ==='

-- Contar registros em cada tabela
SELECT 'Usuários' as Tabela, COUNT(*) as TotalRegistros FROM teste.Usuarios
UNION ALL
SELECT 'Produtos', COUNT(*) FROM teste.Produtos
UNION ALL
SELECT 'Pedidos', COUNT(*) FROM teste.Pedidos
UNION ALL
SELECT 'Itens Pedido', COUNT(*) FROM teste.ItensPedido;

-- Top 5 produtos mais caros
PRINT 'Top 5 produtos mais caros:'
SELECT TOP 5 
    Nome, 
    Preco, 
    Categoria
FROM teste.Produtos 
ORDER BY Preco DESC;

-- Usuários com pedidos
PRINT 'Usuários que fizeram pedidos:'
SELECT 
    u.Nome,
    u.Email,
    COUNT(p.Id) as TotalPedidos,
    SUM(p.ValorTotal) as ValorTotalPedidos
FROM teste.Usuarios u
LEFT JOIN teste.Pedidos p ON u.Id = p.UsuarioId
GROUP BY u.Id, u.Nome, u.Email
ORDER BY TotalPedidos DESC;

-- Análise de vendas por categoria
PRINT 'Vendas por categoria:'
SELECT 
    pr.Categoria,
    COUNT(DISTINCT p.Id) as TotalPedidos,
    SUM(ip.Quantidade) as QuantidadeVendida,
    SUM(ip.Quantidade * ip.PrecoUnitario) as ReceitaTotal
FROM teste.Produtos pr
INNER JOIN teste.ItensPedido ip ON pr.Id = ip.ProdutoId
INNER JOIN teste.Pedidos p ON ip.PedidoId = p.Id
WHERE p.Status != 'Cancelado'
GROUP BY pr.Categoria
ORDER BY ReceitaTotal DESC;

-- Status dos pedidos
PRINT 'Status dos pedidos:'
SELECT 
    Status,
    COUNT(*) as Quantidade,
    SUM(ValorTotal) as ValorTotal
FROM teste.Pedidos
GROUP BY Status
ORDER BY Quantidade DESC;

-- =====================================================
-- 5. PROCEDURES DE TESTE
-- =====================================================

-- Procedure para obter relatório de usuário
IF OBJECT_ID('teste.sp_RelatorioUsuario') IS NOT NULL
    DROP PROCEDURE teste.sp_RelatorioUsuario;
GO

CREATE PROCEDURE teste.sp_RelatorioUsuario
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Informações do usuário
    SELECT 
        'Informações do Usuário' as Secao,
        u.Nome,
        u.Email,
        u.DataNascimento,
        u.DataCriacao,
        CASE WHEN u.Ativo = 1 THEN 'Ativo' ELSE 'Inativo' END as Status
    FROM teste.Usuarios u
    WHERE u.Id = @UsuarioId;
    
    -- Histórico de pedidos
    SELECT 
        'Histórico de Pedidos' as Secao,
        p.Id as PedidoId,
        p.DataPedido,
        p.ValorTotal,
        p.Status,
        COUNT(ip.Id) as TotalItens
    FROM teste.Pedidos p
    LEFT JOIN teste.ItensPedido ip ON p.Id = ip.PedidoId
    WHERE p.UsuarioId = @UsuarioId
    GROUP BY p.Id, p.DataPedido, p.ValorTotal, p.Status
    ORDER BY p.DataPedido DESC;
    
    -- Resumo estatístico
    SELECT 
        'Resumo Estatístico' as Secao,
        COUNT(p.Id) as TotalPedidos,
        ISNULL(SUM(p.ValorTotal), 0) as ValorTotalCompras,
        ISNULL(AVG(p.ValorTotal), 0) as TicketMedio
    FROM teste.Pedidos p
    WHERE p.UsuarioId = @UsuarioId
        AND p.Status != 'Cancelado';
END;
GO

PRINT 'Procedure teste.sp_RelatorioUsuario criada'

-- Testar a procedure
PRINT 'Testando procedure com usuário ID 1:'
EXEC teste.sp_RelatorioUsuario @UsuarioId = 1;

-- =====================================================
-- 6. FUNÇÃO DE TESTE
-- =====================================================

-- Função para calcular idade
IF OBJECT_ID('teste.fn_CalcularIdade') IS NOT NULL
    DROP FUNCTION teste.fn_CalcularIdade;
GO

CREATE FUNCTION teste.fn_CalcularIdade(@DataNascimento DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Idade INT;
    
    SET @Idade = DATEDIFF(YEAR, @DataNascimento, GETDATE()) - 
                 CASE 
                     WHEN MONTH(@DataNascimento) > MONTH(GETDATE()) 
                          OR (MONTH(@DataNascimento) = MONTH(GETDATE()) AND DAY(@DataNascimento) > DAY(GETDATE()))
                     THEN 1 
                     ELSE 0 
                 END;
    
    RETURN @Idade;
END;
GO

PRINT 'Função teste.fn_CalcularIdade criada'

-- Testar a função
PRINT 'Testando função de cálculo de idade:'
SELECT 
    Nome,
    DataNascimento,
    teste.fn_CalcularIdade(DataNascimento) as Idade
FROM teste.Usuarios
WHERE DataNascimento IS NOT NULL
ORDER BY Nome;

-- =====================================================
-- 7. VIEW DE TESTE
-- =====================================================

-- View para relatório de vendas
IF OBJECT_ID('teste.vw_RelatorioVendas') IS NOT NULL
    DROP VIEW teste.vw_RelatorioVendas;
GO

CREATE VIEW teste.vw_RelatorioVendas
AS
SELECT 
    p.Id as PedidoId,
    u.Nome as NomeCliente,
    u.Email as EmailCliente,
    p.DataPedido,
    p.Status as StatusPedido,
    pr.Nome as NomeProduto,
    pr.Categoria,
    ip.Quantidade,
    ip.PrecoUnitario,
    (ip.Quantidade * ip.PrecoUnitario) as ValorTotalItem,
    p.ValorTotal as ValorTotalPedido
FROM teste.Pedidos p
INNER JOIN teste.Usuarios u ON p.UsuarioId = u.Id
INNER JOIN teste.ItensPedido ip ON p.Id = ip.PedidoId
INNER JOIN teste.Produtos pr ON ip.ProdutoId = pr.Id;
GO

PRINT 'View teste.vw_RelatorioVendas criada'

-- Testar a view
PRINT 'Testando view de relatório de vendas:'
SELECT TOP 10 * FROM teste.vw_RelatorioVendas ORDER BY DataPedido DESC;

-- =====================================================
-- 8. TRIGGER DE AUDITORIA
-- =====================================================

-- Tabela de auditoria
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditoriaUsuarios' AND schema_id = SCHEMA_ID('teste'))
BEGIN
    CREATE TABLE teste.AuditoriaUsuarios (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UsuarioId INT NOT NULL,
        Operacao CHAR(1) NOT NULL, -- I=Insert, U=Update, D=Delete
        DadosAnteriores NVARCHAR(MAX),
        DadosNovos NVARCHAR(MAX),
        DataOperacao DATETIME2 DEFAULT GETDATE(),
        UsuarioSistema NVARCHAR(128) DEFAULT SYSTEM_USER
    );
    
    PRINT 'Tabela teste.AuditoriaUsuarios criada'
END
GO

-- Trigger de auditoria
IF OBJECT_ID('teste.tr_AuditoriaUsuarios') IS NOT NULL
    DROP TRIGGER teste.tr_AuditoriaUsuarios;
GO

CREATE TRIGGER teste.tr_AuditoriaUsuarios
ON teste.Usuarios
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Para INSERT
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO teste.AuditoriaUsuarios (UsuarioId, Operacao, DadosNovos)
        SELECT 
            i.Id,
            'I',
            CONCAT('Nome:', i.Nome, '; Email:', i.Email, '; Ativo:', i.Ativo)
        FROM inserted i;
    END
    
    -- Para UPDATE
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO teste.AuditoriaUsuarios (UsuarioId, Operacao, DadosAnteriores, DadosNovos)
        SELECT 
            i.Id,
            'U',
            CONCAT('Nome:', d.Nome, '; Email:', d.Email, '; Ativo:', d.Ativo),
            CONCAT('Nome:', i.Nome, '; Email:', i.Email, '; Ativo:', i.Ativo)
        FROM inserted i
        INNER JOIN deleted d ON i.Id = d.Id;
    END
    
    -- Para DELETE
    IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO teste.AuditoriaUsuarios (UsuarioId, Operacao, DadosAnteriores)
        SELECT 
            d.Id,
            'D',
            CONCAT('Nome:', d.Nome, '; Email:', d.Email, '; Ativo:', d.Ativo)
        FROM deleted d;
    END
END;
GO

PRINT 'Trigger teste.tr_AuditoriaUsuarios criado'

-- Testar o trigger
PRINT 'Testando trigger de auditoria:'
UPDATE teste.Usuarios SET Observacoes = 'Teste de auditoria' WHERE Id = 1;

SELECT TOP 5 * FROM teste.AuditoriaUsuarios ORDER BY DataOperacao DESC;

-- =====================================================
-- 9. LIMPEZA E ESTATÍSTICAS FINAIS
-- =====================================================

-- Atualizar estatísticas
UPDATE STATISTICS teste.Usuarios;
UPDATE STATISTICS teste.Produtos;
UPDATE STATISTICS teste.Pedidos;
UPDATE STATISTICS teste.ItensPedido;

PRINT 'Estatísticas atualizadas'

-- Resumo final
PRINT '=== RESUMO FINAL DOS TESTES ==='

SELECT 
    'Estruturas Criadas' as Categoria,
    'Schemas' as Tipo,
    COUNT(*) as Quantidade
FROM sys.schemas 
WHERE name = 'teste'

UNION ALL

SELECT 
    'Estruturas Criadas',
    'Tabelas',
    COUNT(*)
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'teste'

UNION ALL

SELECT 
    'Estruturas Criadas',
    'Índices',
    COUNT(*)
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'teste' AND i.index_id > 0

UNION ALL

SELECT 
    'Estruturas Criadas',
    'Procedures',
    COUNT(*)
FROM sys.procedures p
INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE s.name = 'teste'

UNION ALL

SELECT 
    'Estruturas Criadas',
    'Functions',
    COUNT(*)
FROM sys.objects o
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE s.name = 'teste' AND o.type = 'FN'

UNION ALL

SELECT 
    'Estruturas Criadas',
    'Views',
    COUNT(*)
FROM sys.views v
INNER JOIN sys.schemas s ON v.schema_id = s.schema_id
WHERE s.name = 'teste'

UNION ALL

SELECT 
    'Estruturas Criadas',
    'Triggers',
    COUNT(*)
FROM sys.triggers t
INNER JOIN sys.tables tb ON t.parent_id = tb.object_id
INNER JOIN sys.schemas s ON tb.schema_id = s.schema_id
WHERE s.name = 'teste';

PRINT ''
PRINT '✅ Todos os testes foram executados com sucesso!'
PRINT '✅ Estruturas de teste criadas e populadas'
PRINT '✅ Azure SQL Database está funcionando corretamente'
PRINT ''
PRINT 'Para limpar os dados de teste, execute: DROP SCHEMA teste CASCADE'
