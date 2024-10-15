-- BADC5, IFSP-PRC, 2024 (1sem), AtletaInscricaoModalidade
-- DANILO QUAGGIO - PC3027007
-- GABRIEL OLIVEIRA - PC3026825
-- MATHEUS PRUDENTE - PC3025543

-- Instrucoes basicas:
-- Nomear o script como TemaProntuario.sql (onde 'Tema' e' o tema do grupo e o 'Prontuario' pertence a quem fez o envio no Moodle)
-- Seguir rigorosamente a sintaxe do PostgreSQL
-- Este script precisa ser escrito de modo que possa ser executado completamente sem apresentar erros
-- Apagar as linhas comentadas somente quando 

-- [0] USUARIOS
-- Resumir aqui quais serao os usuarios, visto que o superusuario sera' utilizado apenas em casos excepcionais. 
CREATE DATABASE olimpiada;

\c olimpiada;


CREATE USER olimpiada_adm WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE olimpiada TO olimpiada_adm;
CREATE SCHEMA olimpiada;
-- Transferir a propriedade do esquema
ALTER SCHEMA olimpiada OWNER TO olimpiada_adm;

---------------------------------------------

-- [1] ESQUEMAS
-- Criacao de pelo menos 1 esquema
-- Nesse(s) esquema(s) serao criados: tabelas, visoes, funcoes, procedimentos, gatilhos, sequencias etc (vide secoes seguintes)

-- ----------------------------
-- [2] TABELAS
-- Criacao das tabelas e de suas restricoes (chaves primarias, unicidades, valores padrao, checagem e nao nulos)
-- Pelo menos 1 UNIQUE, 1 DEFAULT, 1 CHECK
-- Definicao das chaves estrangeiras das tabelas com acoes referenciais engatilhadas
-- As restricoes criadas com ALTER TABLE devem aparecer logo apos a tabela correspondente

-- Enum
CREATE TYPE sexo_enum AS ENUM ('HOMEM', 'MULHER');

-- Atleta
CREATE TABLE IF NOT EXISTS olimpiada.atleta(
    a_id SERIAL,
    a_nome VARCHAR,
    a_datanascimento DATE,
    a_sexo sexo_enum,
    a_nacionalidade VARCHAR DEFAULT 'Desconhecida',
    a_peso INT,
    a_altura INT
);

ALTER TABLE olimpiada.atleta
ADD CONSTRAINT atleta_pkey PRIMARY KEY (a_id);

ALTER TABLE olimpiada.atleta
ALTER COLUMN a_nome SET NOT NULL,
ALTER COLUMN a_datanascimento SET NOT NULL,
ALTER COLUMN a_sexo SET NOT NULL,
ALTER COLUMN a_nacionalidade SET NOT NULL,
ALTER COLUMN a_peso SET NOT NULL,
ALTER COLUMN a_peso TYPE FLOAT,
ALTER COLUMN a_altura SET NOT NULL;

ALTER TABLE olimpiada.atleta
ADD CONSTRAINT atleta_peso_check CHECK (a_peso > 0),
ADD CONSTRAINT atleta_altura_check CHECK (a_altura > 0);

-- Modalidade
CREATE TABLE IF NOT EXISTS olimpiada.modalidade(
    m_id SERIAL,
    m_nome VARCHAR,
    m_tipo VARCHAR,
    m_sexo sexo_enum,
    m_participantes INT,
    m_ano INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)
);

-- Restrições da tabela Modalidade
ALTER TABLE olimpiada.modalidade
ADD CONSTRAINT modalidade_pkey PRIMARY KEY (m_id);

--ALTER TABLE olimpiada.modalidade
--ADD CONSTRAINT modalidade_nome_unico UNIQUE (m_nome, m_ano);

ALTER TABLE olimpiada.modalidade
ALTER COLUMN m_nome SET NOT NULL,
ALTER COLUMN m_tipo SET NOT NULL,
ALTER COLUMN m_sexo SET NOT NULL,
ALTER COLUMN m_participantes SET NOT NULL;

ALTER TABLE olimpiada.modalidade
ADD CONSTRAINT modalidade_participantes_check CHECK (m_participantes > 0);

-- Inscrição
CREATE TABLE IF NOT EXISTS olimpiada.inscricao(
    i_id SERIAL,
    i_datainscricao DATE DEFAULT CURRENT_DATE,
    m_id INT,
    a_id INT
);

ALTER TABLE olimpiada.inscricao
ADD CONSTRAINT inscricao_pkey PRIMARY KEY (i_id);

ALTER TABLE olimpiada.inscricao
ALTER COLUMN i_datainscricao SET NOT NULL,
ALTER COLUMN m_id SET NOT NULL,
ALTER COLUMN a_id SET NOT NULL;

ALTER TABLE olimpiada.inscricao
ADD CONSTRAINT inscricao_modalidade_fkey
FOREIGN KEY (m_id) REFERENCES olimpiada.modalidade(m_id)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE olimpiada.inscricao
ADD CONSTRAINT inscricao_atleta_fkey
FOREIGN KEY (a_id) REFERENCES olimpiada.atleta(a_id)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Trigger para verificar se o sexo do atleta é o mesmo da modalidade
CREATE OR REPLACE FUNCTION check_gender_match()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT a_sexo FROM olimpiada.atleta WHERE a_id = NEW.a_id) !=
       (SELECT m_sexo FROM olimpiada.modalidade WHERE m_id = NEW.m_id) THEN
        RAISE EXCEPTION 'ERRO de Genero entre Atleta e Modalidade';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER gender_match_trigger
BEFORE INSERT OR UPDATE ON olimpiada.inscricao
FOR EACH ROW
EXECUTE FUNCTION check_gender_match();

-- ----------------------------
-- [3] CARGA DE DADOS
-- Consultar o script do tema do grupo e colocar aqui os comandos 
-- Identificar quem redigiu os comandos INSERT e UPDATE

-- Padrão:
INSERT INTO olimpiada.atleta (a_nome, a_datanascimento, a_sexo, a_nacionalidade, a_peso, a_altura) VALUES
('Ana Silva', '1990-05-15', 'MULHER', 'Portugal', 62.5, 175),              --01
('Carlos Souza', '1985-11-25', 'HOMEM', 'Portugal', 32.5, 199),            --02
('Maria Oliveira', '1992-09-10', 'MULHER', 'Estados Unidos', 49.5, 150),   --03
('João Santos', '1988-07-22', 'HOMEM', 'Estados Unidos', 300, 150),       --04
('Fernanda Costa', '1995-03-30', 'MULHER', 'Brasil', 58.0, 165),           --05
('Ricardo Pereira', '1987-01-05', 'HOMEM', 'Brasil', 80.0, 180),           --06
('Juliana Martins', '1993-12-18', 'MULHER', 'Portugal', 55.0, 170),        --07
('Roberto Almeida', '1984-08-16', 'HOMEM', 'Estados Unidos', 90.0, 185),   --08
('Isabela Lima', '1991-06-20', 'MULHER', 'Espanha', 62.0, 160),            --09
('Luiz Mendes', '1990-04-25', 'HOMEM', 'Brasil', 85.0, 178),               --10
('Patricia Ramos', '1994-10-12', 'MULHER', 'Estados Unidos', 54.0, 168),   --11
('André Silva', '1986-02-17', 'HOMEM', 'Brasil', 78.1, 182),               --12
('Camila Rodrigues', '1992-11-08', 'MULHER', 'Portugal', 57.0, 172),       --13
('Felipe Martins', '1989-09-29', 'HOMEM', 'Espanha', 82.0, 175),           --14
('Mariana Souza', '1995-07-10', 'MULHER', 'Estados Unidos', 60.0, 160),    --15
('Thiago Lima', '1988-12-03', 'HOMEM', 'Uruguai', 88.2, 179),              --16
('Gabriela Pereira', '1993-05-21', 'MULHER', 'Brasil', 59.0, 167),         --17
('Eduardo Costa', '1987-11-17', 'HOMEM', 'Portugal', 76.0, 180),           --18
('Larissa Oliveira', '1991-01-30', 'MULHER', 'Estados Unidos', 63.3, 165), --19
('Lucas Santos', '1992-08-14', 'HOMEM', 'Brasil', 84.4, 176),              --20 
('Letícia Almeida', '1994-06-23', 'MULHER', 'Brasil', 56.5, 162),          --21
('Vitor Ferreira', '1989-03-04', 'HOMEM', 'Portugal', 77.6, 177),          --22
('Amanda Silva', '1995-02-19', 'MULHER', 'Estados Unidos', 64.7, 162),     --23
('Ricardo Costa', '1986-07-07', 'HOMEM', 'Espanha', 83.8, 180),            --24
('Juliana Oliveira', '1993-09-01', 'MULHER', 'Estados Unidos', 61.9, 168); --25


INSERT INTO olimpiada.modalidade (m_nome, m_tipo, m_sexo, m_participantes, m_ano) VALUES
('Corrida 100m', 'Atletismo', 'HOMEM', 8, 2004),              --01
('Corrida 200m', 'Atletismo', 'MULHER', 8, 2008),             --02
('Maratona', 'Atletismo', 'HOMEM', 10, 2012),                 --03
('Maratona', 'Atletismo', 'MULHER', 10, 2016),                --04
('Salto a Distancia', 'Atletismo', 'HOMEM', 6, 2020), 		--05
('Lançamento de Martelo', 'Atletismo', 'MULHER', 6, 2024),    --06
('Futebol', 'Esportes em Grupos', 'HOMEM', 22, 2028),         --07
('Basquetball', 'Esportes em Grupos', 'MULHER', 12, 2004),    --08
('Voleyball', 'Esportes em Grupos', 'HOMEM', 12, 2008),       --09
('Handball', 'Esportes em Grupos', 'MULHER', 14, 2012),       --10
('Water Polo', 'Esportes em Grupos', 'HOMEM', 13, 2016),      --11
('Tenis', 'Esportes Individuais', 'MULHER', 2, 2020),         --12
('Tenis de Mesa', 'Esportes Individuais', 'HOMEM', 2, 2024),  --13
('Badminton', 'Esportes Individuais', 'MULHER', 2, 2028),     --14
('Esgrima', 'Esportes Individuais', 'HOMEM', 2, 2004),        --15
('Boxing', 'Esportes Individuais', 'MULHER', 1, 2008),        --16
('Luta Livre', 'Esportes Individuais', 'HOMEM', 1, 2012),     --17
('Taekwondo', 'Esportes Individuais', 'MULHER', 1, 2016),     --18
('Judo', 'Esportes Individuais', 'HOMEM', 1, 2020),           --19
('Lançamento de Disco', 'Atletismo', 'MULHER', 6, 2024);       --20

INSERT INTO olimpiada.inscricao (i_datainscricao, m_id, a_id) VALUES
('2024-08-01', 1, 2),   --01
('2024-08-01', 2, 3),   --02    
('2024-08-02', 3, 4),   --03
('2024-08-02', 4, 5),   --04
('2024-08-03', 5, 6),   --05
('2024-08-03', 6, 7),   --06
('2024-08-04', 7, 8),   --07
('2024-08-04', 8, 9),   --08
('2024-08-05', 9, 10),   --09
('2024-08-05', 10, 11), --10
('2024-08-06', 11, 12), --11
('2024-08-06', 12, 13), --12
('2024-08-07', 13, 14), --13
('2024-08-07', 14, 15), --14
('2024-08-08', 15, 16), --15
('2024-08-08', 16, 17), --16
('2024-08-09', 17, 18), --17
('2024-08-09', 18, 19), --18
('2024-08-10', 19, 20), --19
('2024-08-10', 20, 21), --20
('2024-08-11', 1, 22), --21
('2024-08-11', 2, 23), --22
('2024-08-12', 3, 24), --23
('2024-08-12', 4, 25), --24
('2024-08-13', 5, 2), --25
('2024-08-13', 1, 2), --26
('2024-08-14', 2, 3), --27
('2024-08-14', 3, 4), --28
('2024-08-15', 4, 5), --29
('2024-08-15', 5, 6), --30
('2024-08-16', 6, 7), --31
('2024-08-16', 7, 8), --32
('2024-08-17', 8, 9), --33
('2024-08-17', 9, 10), --34
('2024-08-18', 10, 11), --35
('2024-08-18', 11, 12), --36
('2024-08-19', 12, 13), --37
('2024-08-19', 13, 14), --38
('2024-08-20', 14, 15), --39
('2024-08-20', 15, 16), --40
('2024-08-21', 16, 17), --41
('2024-08-21', 17, 18), --42
('2024-08-22', 18, 19), --43
('2024-08-22', 19, 20), --44
('2024-08-23', 20, 21), --45
('2024-08-23', 1, 22), --46
('2024-08-24', 2, 23), --47
('2024-08-24', 3, 24), --48
('2024-08-25', 4, 25), --49
('2024-08-25', 4, 1); --50

-- Matheus:
INSERT INTO olimpiada.inscricao (i_datainscricao, m_id, a_id) VALUES
('2024-08-31', 15, 12), --01
('2024-08-31', 16, 13), --02
('2024-09-01', 17, 14), --03
('2024-09-01', 18, 15), --04
('2024-09-02', 19, 16), --05
('2024-09-02', 20, 17), --06
('2024-09-03', 1, 18),  --07
('2024-09-03', 2, 19),  --08
('2024-09-04', 3, 20),  --09
('2024-09-04', 4, 21),  --10
('2024-09-05', 5, 22),  --11
('2024-09-05', 6, 23),  --12
('2024-09-06', 7, 24),  --13
('2024-09-06', 8, 25),  --14
('2024-09-07', 9, 2),   --15
('2024-09-07', 10, 3),  --16
('2024-09-08', 11, 4),  --17
('2024-09-08', 12, 5),  --18
('2024-09-09', 13, 6),  --19
('2024-09-09', 14, 7);  --20

-- Gabriel:
INSERT INTO olimpiada.inscricao (i_datainscricao, m_id, a_id) VALUES
('2024-09-10', 15, 8),  --01
('2024-09-10', 16, 9),  --02
('2024-09-11', 17, 10),  --03
('2024-09-11', 18, 11), --04
('2024-09-12', 19, 12), --05
('2024-09-12', 20, 13), --06
('2024-09-13', 1, 14),  --07
('2024-09-13', 2, 15),  --08
('2024-09-14', 3, 16),  --09
('2024-09-14', 4, 17),  --10
('2024-09-15', 5, 18),  --11
('2024-09-15', 6, 19),  --12
('2024-09-16', 7, 20),  --13
('2024-09-16', 8, 21),  --14
('2024-09-17', 9, 22),  --15
('2024-09-17', 10, 23), --16
('2024-09-18', 11, 24), --17
('2024-09-18', 12, 25), --18
('2024-09-19', 13, 2), --19
('2024-09-19', 14, 3);  --20

-- Danilo:
INSERT INTO olimpiada.inscricao (i_datainscricao, m_id, a_id) VALUES
('2024-09-20', 15, 2),  --01
('2024-09-20', 16, 3),  --02
('2024-09-21', 17, 4),  --03
('2024-09-21', 18, 5),  --04
('2024-09-22', 19, 6),  --05
('2024-09-22', 20, 7),  --06
('2024-09-23', 1, 8),   --07
('2024-09-23', 2, 9),   --08
('2024-09-24', 3, 10),  --09
('2024-09-24', 4, 11),  --10
('2024-09-25', 5, 12),  --11
('2024-09-25', 6, 13),  --12
('2024-09-26', 7, 14),  --13
('2024-09-26', 8, 15),  --14
('2024-09-27', 9, 16),  --15
('2024-09-27', 10, 17), --16
('2024-09-28', 11, 18), --17
('2024-09-28', 12, 19), --18
('2024-09-29', 13, 20), --19
('2024-09-29', 14, 21); --20

-- -----------------------
-- [4] CONSULTAS
-- Alem do comando SELECT correspondente, fornecer o que se pede

-- [4.1] Listagem
-- Usar juncao(oes) (JOINs), filtro(s) (WHERE), ordenacao (ORDER BY)
-- Enunciado: Listar todos os atletas inscritos em modalidades de Atletismo, ordenando por nacionalidade e, em seguida, por nome.
-- Importancia na aplicacao: Permite aos funcionarios da olimpiada visualisar todos os atletas, 
-- 		junto com suas nascionalidades, e as modalidades do tipo atletismo em que estão participando.
-- Usuario(s) atendido(s): Funcionarios e Admnistradores
SELECT  a.a_nome AS Nome_Atleta,
	a.a_nacionalidade AS Nacionalidade,
	m.m_nome AS Modalidade,
	i.i_datainscricao AS Data_Inscricao
FROM olimpiada.atleta a
JOIN olimpiada.inscricao i ON a.a_id = i.a_id
JOIN olimpiada.modalidade m ON i.m_id = m.m_id
WHERE m.m_tipo = 'Atletismo'
ORDER BY a.a_nacionalidade, a.a_nome;


-- [4.2] Relatorio
-- Usar juncao(oes) (JOINs), filtro(s) (WHERE), agrupamento (GROUP BY) e funcao de agregacao (count, sum, avg, etc)
-- Enunciado: Gerar um relatório mostrando o número de inscrições por modalidade, agrupado pelo tipo de modalidade e pelo sexo dos participantes.
-- Importancia na aplicacao: Permite ter uma analise estátisca dos atletas e seus esportes praticados.
-- Usuario(s) atendido(s): Leitores, Funcionarios e Admnistradores
SELECT  m.m_tipo AS Tipo_Modalidade,
	m.m_sexo AS Sexo_Participante,
COUNT(i.i_id) AS Numero_Inscricoes
FROM olimpiada.modalidade m
JOIN olimpiada.inscricao i ON m.m_id = i.m_id
GROUP BY m.m_tipo, m.m_sexo
ORDER BY m.m_tipo, m.m_sexo;
-- -------------------------
-- [5] VISOES


-- [5.1] Visao
-- A visao deve ter, no minimo, as caracteristicas de 4.1
-- Enunciado: Criar uma visão que redija o comando descrito em 4.1.
-- Importancia na aplicacao: Simplificar o acesso do select 4.1 para os usuarios.
-- Usuario(s) atendido(s): Funcionarios e Admnistradores
CREATE VIEW vw_atletas_modalidades_atletismo AS
SELECT  a.a_nome AS Nome_Atleta,
	a.a_nacionalidade AS Nacionalidade,
	m.m_nome AS Modalidade,
	i.i_datainscricao AS Data_Inscricao
FROM olimpiada.atleta a
JOIN olimpiada.inscricao i ON a.a_id = i.a_id
JOIN olimpiada.modalidade m ON i.m_id = m.m_id
WHERE m.m_tipo = 'Atletismo'
ORDER BY a.a_nacionalidade, a.a_nome;


-- [5.2] Consulta na visao
-- Consultar a visao criada em 5.1 realizando filtro(s) (WHERE)
-- Enunciado: Consultar a visão que redije o comando descrito em 4.1, com a adição de um filtro para atletas brasileiros.
-- Importancia na aplicacao: Simplificar o acesso do select 4.1 para os usuarios, alem de ver apenas os atletas do Brasil.
-- Usuario(s) atendido(s): Funcionarios e Admnistradores
SELECT * 
FROM vw_atletas_modalidades_atletismo
WHERE Nacionalidade = 'Brasil';

-- [5.3] Visao materializada
-- A visao deve ter, no minimo, as caracteristicas de 4.2
-- Enunciado: Criar uma Visão Materialisada que redija o comando descrito em 4.2.
-- Importancia na aplicacao: Alem da Simplificação do Comando, existe uma vantagem de processamento em utilizar visões materialisadas, a pesar da possibilidade de dados datados.
-- Usuario(s) atendido(s): Leitores, Funcionarios e Admnistradores
CREATE MATERIALIZED VIEW mv_inscricoes_por_modalidade AS
SELECT  m.m_tipo AS Tipo_Modalidade,
	m.m_sexo AS Sexo_Participante,
COUNT(i.i_id) AS Numero_Inscricoes
FROM olimpiada.modalidade m
JOIN olimpiada.inscricao i ON m.m_id = i.m_id
GROUP BY m.m_tipo, m.m_sexo
ORDER BY m.m_tipo, m.m_sexo;

-- [5.4] Consulta na visao materializada
-- Consultar a visao materializada criada realizando filtro(s) (WHERE)
-- Enunciado: Criar uma Visão Materialisada que redija o comando descrito em 4.2, com a adição de um filtro para o tipo de modalidade "Esportes em grupos"
-- Importancia na aplicacao: Alem da Simplificação do Comando, existe uma vantagem de processamento em utilizar visões materialisadas, a pesar da possibilidade de dados datados.
-- Usuario(s) atendido(s): Leitores, Funcionarios e Admnistradores
SELECT * 
FROM mv_inscricoes_por_modalidade
WHERE Tipo_Modalidade = 'Esportes em Grupos';

-- [5.5] Atualizacao da visao materializada
-- Comente brevemente sobre a necessidade de atualizacao e qual seria a frequencia/periodicidade
-- Redija o comando REFRESH correspondente

-- A visão materializada deve ser atualizada periodicamente para refletir as mudanças recentes nas inscrições de atletas, ja 
-- a frequência da atualização dependerá da frequência de novas inscrições e das necessidades dos usuários, como diariamente ou semanalmente.
-- Em periodos de jogos olimpicos, por exemplo, a atualização deveria ser diaria, ou até a cada 12 horas.

REFRESH MATERIALIZED VIEW mv_inscricoes_por_modalidade;

-- ---------------------------------------------
-- [6] DESEMPENHO DO PROCESSAMENTO DAS CONSULTAS
-- Primeiro analise o desempenho das suas consultas 4.1., 4.2, 5.2 e 5.4, verificando custo e tempo das operacoes
-- Depois de analisa-las, comente a necessidade da criacao ou nao de um indice e justifique a escolha pelo tipo de indice.
-- Selecione uma dentre essas consultas (a mais importante delas) e apresente aquilo que se pede abaixo.

-- [6.1] EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT  a.a_nome AS Nome_Atleta,
	a.a_nacionalidade AS Nacionalidade,
	m.m_nome AS Modalidade,
	i.i_datainscricao AS Data_Inscricao
FROM olimpiada.atleta a
JOIN olimpiada.inscricao i ON a.a_id = i.a_id
JOIN olimpiada.modalidade m ON i.m_id = m.m_id
WHERE m.m_tipo = 'Atletismo'
ORDER BY a.a_nacionalidade, a.a_nome;

--Tempo de Planejamento: 6.551 ms
--Tempo de Execução: 1.612 ms
--Loop mais custoso Nested Loop  (cost=0.16..17.47 rows=1 width=40) (actual time=0.084..0.648 rows=45 loops=1)

-- [6.2] EXPLAIN 
EXPLAIN ANALYZE
SELECT  m.m_tipo AS Tipo_Modalidade,
	m.m_sexo AS Sexo_Participante,
COUNT(i.i_id) AS Numero_Inscricoes
FROM olimpiada.modalidade m
JOIN olimpiada.inscricao i ON m.m_id = i.m_id
GROUP BY m.m_tipo, m.m_sexo
ORDER BY m.m_tipo, m.m_sexo;
--Tempo de Planejamento:  0.709 ms
--Tempo de Execução: 0.884 ms
--Mais Custosa  Sort  (cost=21.15..21.42 rows=110 width=40) (actual time=0.761..0.769 rows=110 loops=1)

-- [6.3] Comentarios e justificativas para o indice 
EXPLAIN ANALYZE
SELECT * 
FROM vw_atletas_modalidades_atletismo
WHERE Nacionalidade = 'Brasil';
--Tempo de Planejamento:  1.011 ms
--Tempo de Execução: 1.366 ms
--Mais Custosa Sort  (cost=18.27..18.27 rows=1 width=100) (actual time=1.220..1.226 rows=12 loops=1)

-- [6.4] CREATE INDEX e PARAMETROS (Set)
-- Crie o indice, verifique se o indice ja esta sendo usado no processamento da consulta e, caso nao esteja, ajuste os parametros

-- Índice da [6.4] 
-- Índice na coluna 'm_tipo'
CREATE INDEX ind_modalidade_m_tipo ON olimpiada.modalidade(m_tipo);
-- Índice na coluna de junção em 'inscricao'
CREATE INDEX ind_inscricao_a_id ON olimpiada.inscricao(a_id);
CREATE INDEX ind_inscricao_m_id ON olimpiada.inscricao(m_id);
-- Índice na coluna de junção em 'atleta'
CREATE INDEX ind_atleta_a_id ON olimpiada.atleta(a_id);

-- ---------------------------------------------
-- [7] STORED PROCEDURE
-- Vislumbrar a criacao de um procedimento armazenado para o banco de dados.
-- Comentar a utilidade do procedimento na aplicacao.
-- Redigir o comando CREATE OR REPLACE PROCEDURE correspondente usando PL/pgSQL.
-- Redigir um comando SQL que chame o procedimento, explicando o que sua chamada faz.
-- O procedimento devera' ter parametro(s).


-- Comentar a utilidade do procedimento na aplicacao.
-- Remove os atletas que estão fora da faixa de peso da modalidade e criar um relatório com o maior e menor peso, e suas médias, de forma a manter
-- uma olimpiada justa para os participante e observar a saude dos atletas.

-- Redigir o comando CREATE OR REPLACE PROCEDURE correspondente usando PL/pgSQL.
-- Criar ou substituir a procedure para analisar dados dos atletas na modalidade
CREATE OR REPLACE PROCEDURE analisar_modalidade_atletas(
    p_modalidade_id INT,
    p_peso_maximo FLOAT,
    p_peso_minimo FLOAT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_media_peso FLOAT;
    v_media_altura FLOAT;
    v_media_idade FLOAT;
    v_min_peso FLOAT;
    v_max_peso FLOAT;
    v_min_altura FLOAT;
    v_max_altura FLOAT;
    v_min_idade FLOAT;
    v_max_idade FLOAT;
    v_atual_data DATE := CURRENT_DATE;
    v_a_id INT;
    v_a_nome VARCHAR;
    v_a_peso FLOAT;
    v_a_altura FLOAT;
    v_a_datanascimento DATE;
BEGIN
    -- Verificar se a modalidade existe
    IF NOT EXISTS (
        SELECT 1
        FROM olimpiada.modalidade
        WHERE m_id = p_modalidade_id
    ) THEN
        RAISE EXCEPTION 'Modalidade com ID % não encontrada.', p_modalidade_id;
    END IF;

    -- Coletar IDs dos atletas a serem excluídos e exibir notificações
    FOR v_a_id, v_a_nome, v_a_peso IN
        SELECT a.a_id, a.a_nome, a.a_peso
        FROM olimpiada.atleta a
        WHERE a.a_peso > p_peso_maximo OR a.a_peso < p_peso_minimo
    LOOP
        RAISE NOTICE 'Atleta % (% kg) está fora dos limites e será excluído.', v_a_nome, v_a_peso;
    END LOOP;

    -- Excluir inscrições de atletas fora dos limites de peso fornecidos
    DELETE FROM olimpiada.inscricao
    WHERE a_id IN (
        SELECT a_id
        FROM olimpiada.atleta
        WHERE a_peso > p_peso_maximo OR a_peso < p_peso_minimo
    ) AND m_id = p_modalidade_id;

    -- Calcular a média, menor e maior valor de peso, altura e idade dos atletas restantes na modalidade
    SELECT 
        AVG(a_peso), 
        AVG(a_altura), 
        AVG(EXTRACT(YEAR FROM AGE(a_datanascimento))),
        MIN(a_peso), MAX(a_peso), 
        MIN(a_altura), MAX(a_altura),
        MIN(EXTRACT(YEAR FROM AGE(a_datanascimento))), MAX(EXTRACT(YEAR FROM AGE(a_datanascimento)))
    INTO 
        v_media_peso, 
        v_media_altura, 
        v_media_idade,
        v_min_peso, v_max_peso, 
        v_min_altura, v_max_altura,
        v_min_idade, v_max_idade
    FROM olimpiada.inscricao i
    JOIN olimpiada.atleta a ON i.a_id = a.a_id
    WHERE i.m_id = p_modalidade_id;

    -- Exibir os resultados
    RAISE NOTICE 'Média de Peso: %.2f kg', v_media_peso;
    RAISE NOTICE 'Média de Altura: %.2f cm', v_media_altura;
    RAISE NOTICE 'Média de Idade: %.2f anos', v_media_idade;
    RAISE NOTICE 'Peso - Mínimo: %.2f kg, Máximo: %.2f kg', v_min_peso, v_max_peso;
    RAISE NOTICE 'Altura - Mínimo: %.2f cm, Máximo: %.2f cm', v_min_altura, v_max_altura;
    RAISE NOTICE 'Idade - Mínima: %.2f anos, Máxima: %.2f anos', v_min_idade, v_max_idade;

END;
$$;


-- Redigir um comando SQL que chame o procedimento, explicando o que sua chamada faz.
-- A Chamada recebe um id, o peso maximo e peso minimo de uma modalide e executa o procedimento.
CALL analisar_modalidade_atletas(2, 100, 50);



-- ---------------------------------------------
-- [8] USER-DEFINED FUNCTION (UDF)
-- Vislumbrar a criacao de uma funcao (UDF) para o banco de dados.
-- Comentar a utilidade da funcao na aplicacao.
-- Redigir o comando CREATE OR REPLACE FUNCTION correspondente usando PL/pgSQL.
-- Redigir um comando SQL que chame a funcao, explicando o que sua chamada faz.
-- A funcao devera' ter parametro(s).

-- Comentar aqui a utilidade da funcao na aplicacao 
--A Utilidade de criar uma fução é que facilita as consultas que seriam mais complexas sem a função, pode melhorar o desempenho do banco
-- deixando ele mais otimizado. 

CREATE OR REPLACE FUNCTION AtualizarAtleta(
    id INT,
    altura NUMERIC,
    peso NUMERIC
)
RETURNS TABLE(imc NUMERIC, mensagem TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    imc NUMERIC;
    altura_metro FLOAT;
BEGIN
    -- Calcular o IMC
    altura_metro := altura * 0.01;
    imc := peso / (altura_metro * altura_metro);

    -- Atualizar os dados do atleta na tabela
    UPDATE olimpiada.atleta 
    SET a_altura = altura,
     a_peso = peso
    WHERE a_id = id;

    -- Verificar se a atualização foi realizada
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Atleta com ID % não encontrado', id;
    END IF;

    -- Verificar a condição saudável
    IF imc < 17 THEN                     --Abaixo do Normal
        RETURN QUERY 
        SELECT imc, 'Atleta não está em condições saudáveis. IMC abaixo do normal.';
    ELSIF imc >= 17 AND imc < 30 THEN --Dentro da Normalidade
        RETURN QUERY 
        SELECT imc, 'Atleta está em condições saudáveis.';
    ELSE                                     --Acima do Normal
        RETURN QUERY 
        SELECT imc, 'Atleta está com IMC acima do normal.';
    END IF;
END;
$$;

-- Redigir um comando SQL que chame o procedimento, explicando o que sua chamada faz.
SELECT AtualizarAtleta(1, 175, 70);
-- A chamada atualiza os dados do atleta com ID 1 para altura 175 cm e peso 70 kg, 
-- e retorna o IMC calculado junto com uma mensagem sobre a condição de saúde do atleta em relação ao IMC.

------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION Descobrir_Modalidade(nome_Atleta VARCHAR) 
RETURNS VARCHAR AS $$
DECLARE modalidades VARCHAR;
BEGIN
    SELECT STRING_AGG(m.m_nome, ', ') INTO modalidades
    FROM olimpiada.atleta a
    JOIN olimpiada.inscricao i ON a.a_id = i.a_id
    JOIN olimpiada.modalidade m ON i.m_id = m.m_id
    WHERE a.a_nome = nome_Atleta;
    RETURN modalidades;
END;
$$ LANGUAGE 'plpgsql';
-- Essa função ela recebe um nome de um atleta e retorna as modalidades em que ele está inscrito

-- SELECT ou INSERT ou UPDATE ou DELETE abaixo para chamar a funcao (apagar esta linha)
SELECT Descobrir_Modalidade('Carlos Souza') AS modalidades;
-- ---------------------------------------------
-- [10] TRIGGER
-- Revisar as aplicacoes em potencial para bancos de dados ativos (e gatilhos).
-- Vislumbrar a criacao de um gatilho e de uma funcao engatilhada para o banco de dados.
-- Se necessario redigir logo abaixo outros comandos SQL necessarios (criacao de coluna, atualizacao de tuplas etc):

-- [10.1] ROW
-- A sua utilidade é que ele vai ser chamado para cada insert vericando o genero 

--O Trigger está entre as linhas 117 até a 135, ele serve para verificar se na inscrição a modalidade e o atleta são do mesmo genero 
--Ele é usado antes do inserção para verificar se tem o erro de genero entre a modalidade e o atleta 


-- [10.2] STATEMENT


CREATE OR REPLACE FUNCTION check_participantes_excedidos()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se existe alguma modalidade onde o número de inscrições excede o limite de participantes permitido
    IF EXISTS (
        SELECT 1
        FROM olimpiada.modalidade m
        LEFT JOIN (
            SELECT m_id, COUNT(*) AS total_inscricoes
            FROM olimpiada.inscricao
            GROUP BY m_id
        ) i ON m.m_id = i.m_id
        WHERE (i.total_inscricoes IS NOT NULL AND i.total_inscricoes > m.m_participantes)
    ) THEN
        RAISE EXCEPTION 'ERRO: O número de inscrições em uma ou mais modalidades excede o limite de participantes permitido.';
    END IF;

    RETURN NULL; -- Não altera nenhuma linha
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_participantes_trigger
AFTER INSERT OR UPDATE ON olimpiada.inscricao
FOR EACH STATEMENT
EXECUTE FUNCTION check_participantes_excedidos();


-- Redigir pelo menos 1 comando SQL que dispare o gatilho em nivel de sentenca
insert into olimpiada.inscricao (i_datainscricao, m_id, a_id) VALUES 
('2024-01-09', 14,13),
('2024-01-09', 14,15),
('2024-01-09', 14,17);
-- Descrever o que acontece no banco de dados quando e' disparado
-- Verifica as pessoas que tem em uma modalidade e da um erro caso ultrapasse o limite de participantes 

-- ---------------------------------------------
-- [11] SEGURANCA
--Usuario Administrador


-- [11.1] ACESSO REMOTO (pg_hba.conf)
--host    olimpiada             olimpiada_adm               192.168.1.100/32          scram-sha-256
--host    olimpiada             olimpiada_func              192.168.1.100/33          scram-sha-256
--host    olimpiada             olimpiada_leitor            192.168.1.100/34          scram-sha-256

-- [11.2] PAPEIS (Roles)
-- Criar papeis de usuarios e de grupo(s)
-- Para cada papel criado adicionar um comentario antes explicando qual e' a utilidade dele na aplicacao
---------------
--Papel ADM, os administradores do sistema.
CREATE ROLE admin_role WITH LOGIN PASSWORD 'admin';

-- Papel para usuários, toda pessoa que não faz parte do comite poderá apenas ter acesso a ver consultas
CREATE ROLE app_user WITH LOGIN PASSWORD 'user';

-- Papel para funcionarios que utilizam o sistema, podendo inserir novos dados e criar consultas.
CREATE ROLE tech_role WITH LOGIN PASSWORD 'tech';

---------------
--Usuario Funcionario
-- Exemplo de um funcionario com o papel tech_role
CREATE USER olimpiada_func WITH PASSWORD 'funcionario';
--Usuario Leitor
-- Exemplo de um usuario com o papel app_user
CREATE USER olimpiada_leitor WITH PASSWORD 'padrao';

-- Da os devidos papeis para seus respectivos usuarios
GRANT admin_role TO olimpiada_adm;
GRANT tech_role TO olimpiada_func;
GRANT app_user TO olimpiada_leitor;
-------------------------------------

-- [11.3] PRIVILEGIOS DE ACESSO (Grant)

-- Concedendo permissões
GRANT CONNECT ON DATABASE olimpiada TO admin_role, tech_role, app_user;

GRANT USAGE ON SCHEMA olimpiada TO tech_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA olimpiada TO tech_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA olimpiada TO tech_role;

GRANT USAGE ON SCHEMA olimpiada TO app_user;
GRANT SELECT ON ALL TABLES IN SCHEMA olimpiada TO app_user;


-- [11.3.1]
-- Assegurar os privilegios necessarios para o(s) papel(is) poder(em) criar o(s) esquema(s) da Secao 1
-- Usuario(s) que podem conceder esse acesso alem do superusuario: olimpiada_adm
GRANT CREATE ON DATABASE olimpiada TO admin_role;

-- [11.3.2]
-- Assegurar os privilegios necessarios para o(s) papel(is) poder(em) criar a(s) tabela(s), as sequencias e as restricoes da Secao 2 e as visoes da Secao 5
-- Usuario(s) que podem conceder esse acesso alem do superusuario: olimpiada_adm aqui
GRANT CREATE ON SCHEMA olimpiada TO admin_role;
GRANT CREATE ON DATABASE olimpiada TO tech_role;
GRANT CREATE ON SCHEMA olimpiada TO tech_role;
GRANT USAGE ON SCHEMA olimpiada TO tech_role;

-- [11.3.3]
-- Assegurar os privilegios necessarios para o(s) papel(is) poder(em) inserir e atualizar tuplas, conforme a Secao 3
-- Usuario(s) que podem conceder esse acesso alem do superusuario: olimpiada_adm
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA olimpiada TO admin_role;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA olimpiada TO tech_role;



-- [11.3.4]
-- Assegurar os privilegios necessarios para o(s) papel(is) poder(em) executar as consultas das Secoes 4 e 5
-- Usuario(s) que podem conceder esse acesso alem do superusuario: olimpiada_adm
GRANT SELECT ON ALL TABLES IN SCHEMA olimpiada TO admin_role; 
GRANT SELECT ON ALL TABLES IN SCHEMA olimpiada TO tech_role; 

GRANT SELECT ON olimpiada.atleta TO app_user;
GRANT SELECT ON olimpiada.inscricao TO app_user;
GRANT SELECT ON olimpiada.modalidade TO app_user;
GRANT SELECT ON vw_atletas_modalidades_atletismo TO app_user;

-- [11.3.5]
-- Assegurar os privilegios necessarios para o(s) papel(is) poder(em) executar os comandos da Secao 7
-- Usuario(s) que podem conceder esse acesso alem do superusuario: olimpiada_adm
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA olimpiada TO admin_role; 
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA olimpiada TO tech_role; 


-- [11.3.6] 
-- Assegurar os privilegios necessarios para o(s) papel(is) poder(em) executar o que constara' futuramente nas Secoes 8, 9 e 10
GRANT EXECUTE ON FUNCTION AtualizarAtleta TO app_user; 


-- [11.4] PRIVILEGIOS DE ACESSO (Revoke)

-- [11.4.1]
-- Revogar o acesso em 11.3.1 de pelo menos 1 papel
-- Usuario(s) que podem revogar esse acesso alem do superusuario: olimpiada_adm
REVOKE CREATE ON DATABASE olimpiada FROM admin_role;

-- [11.4.2]
-- Revogar o acesso em 11.3.2 de pelo menos 1 papel
-- Usuario(s) que podem revogar esse acesso alem do superusuario: olimpiada_adm
REVOKE CREATE ON SCHEMA olimpiada FROM tech_role; 

-- [11.4.3]
-- Revogar o acesso em 11.3.3 de pelo menos 1 papel
-- Usuario(s) que podem revogar esse acesso alem do superusuario: olimpiada_adm
REVOKE INSERT, UPDATE ON ALL TABLES IN SCHEMA olimpiada FROM tech_role; 

-- [11.4.4]
-- Revogar o acesso em 11.3.4 de pelo menos 1 papel
-- Usuario(s) que podem revogar esse acesso alem do superusuario: olimpiada_adm
REVOKE SELECT ON ALL TABLES IN SCHEMA olimpiada FROM app_user;

-- [11.4.5]
-- Revogar o acesso em 11.3.5 de pelo menos 1 papel
-- Usuario(s) que podem revogar esse acesso alem do superusuario: olimpiada_adm
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA olimpiada FROM tech_role; 

-- [11.4.6]
-- Revogar o acesso em 11.3.6 de pelo menos 1 papel
-- Usuario(s) que podem revogar esse acesso alem do superusuario: olimpiada_adm
REVOKE EXECUTE ON FUNCTION AtualizarAtleta FROM app_user; 


-- Se for necessario para executar os comandos seguintes, assegure novamente os privilegios de acesso revogados acima
GRANT CONNECT ON DATABASE olimpiada TO admin_role, tech_role, app_user;
GRANT USAGE ON SCHEMA olimpiada TO tech_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA olimpiada TO tech_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA olimpiada TO tech_role;
GRANT USAGE ON SCHEMA olimpiada TO app_user;
GRANT SELECT ON ALL TABLES IN SCHEMA olimpiada TO app_user;
GRANT CREATE ON DATABASE olimpiada TO admin_role;
GRANT CREATE ON SCHEMA olimpiada TO admin_role;
GRANT CREATE ON DATABASE olimpiada TO tech_role;
GRANT CREATE ON SCHEMA olimpiada TO tech_role;
GRANT USAGE ON SCHEMA olimpiada TO tech_role;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA olimpiada TO admin_role;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA olimpiada TO tech_role;
GRANT SELECT ON ALL TABLES IN SCHEMA olimpiada TO admin_role; 
GRANT SELECT ON ALL TABLES IN SCHEMA olimpiada TO tech_role; 
GRANT SELECT ON olimpiada.atleta TO app_user;
GRANT SELECT ON olimpiada.inscricao TO app_user;
GRANT SELECT ON olimpiada.modalidade TO app_user;
GRANT SELECT ON vw_atletas_modalidades_atletismo TO app_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA olimpiada TO admin_role; 
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA olimpiada TO tech_role; 
GRANT EXECUTE ON FUNCTION Descobrir_Modalidade TO app_user; 
-- ---------------------------------------------


-- ---------------------------------------------
-- [12] TRANSACOES
-- Nao incluir aqui
-- Usar/entregar o modelo proprio para esse topico
