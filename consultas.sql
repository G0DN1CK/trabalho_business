-- =========================================
-- CONSULTAS ANALÍTICAS - DW ACIDENTES
-- COMPATÍVEIS COM METABASE (POSTGRESQL)
-- =========================================


-- 1. Evolução de acidentes ao longo do tempo
SELECT
    TO_CHAR(MAKE_DATE(d.ano, d.mes, 1), 'MM/YYYY') AS periodo,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
INNER JOIN dim_data d
    ON f.id_data = d.id_data
GROUP BY MAKE_DATE(d.ano, d.mes, 1)
ORDER BY MAKE_DATE(d.ano, d.mes, 1);


-- 2. Tipos de acidentes mais comuns
SELECT 
    COALESCE(o.tipo_de_acidente, 'não informado') AS tipo_de_acidente,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
INNER JOIN dim_ocorrencia o 
    ON f.id_ocorrencia = o.id_ocorrencia
GROUP BY COALESCE(o.tipo_de_acidente, 'não informado')
ORDER BY total_acidentes DESC
LIMIT 10;


-- 3. Análise de gravidade dos acidentes
SELECT 
    COALESCE(f.gravidade_acidente, 'não informado') AS gravidade_acidente,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
GROUP BY COALESCE(f.gravidade_acidente, 'não informado')
ORDER BY total_acidentes DESC;


-- 4. Locais mais perigosos (KM)
SELECT
    CAST(l.km AS TEXT) AS km,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
INNER JOIN dim_localizacao l
    ON f.id_localizacao = l.id_localizacao
WHERE l.km IS NOT NULL
GROUP BY l.km
ORDER BY total_acidentes DESC, l.km
LIMIT 10;


-- 5. Horários mais perigosos
SELECT
    CONCAT(EXTRACT(HOUR FROM f.horario)::INT, 'h') AS hora,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
WHERE f.horario IS NOT NULL
GROUP BY EXTRACT(HOUR FROM f.horario)::INT
ORDER BY EXTRACT(HOUR FROM f.horario)::INT;

-- 6. Dias da semana com mais acidentes
SELECT 
    d.dia_semana AS dia_semana,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
INNER JOIN dim_data d 
    ON f.id_data = d.id_data
GROUP BY 
    d.dia_semana,
    CASE d.dia_semana
        WHEN 'segunda-feira' THEN 1
        WHEN 'terça-feira' THEN 2
        WHEN 'quarta-feira' THEN 3
        WHEN 'quinta-feira' THEN 4
        WHEN 'sexta-feira' THEN 5
        WHEN 'sábado' THEN 6
        WHEN 'domingo' THEN 7
        ELSE 99
    END
ORDER BY 
    CASE d.dia_semana
        WHEN 'segunda-feira' THEN 1
        WHEN 'terça-feira' THEN 2
        WHEN 'quarta-feira' THEN 3
        WHEN 'quinta-feira' THEN 4
        WHEN 'sexta-feira' THEN 5
        WHEN 'sábado' THEN 6
        WHEN 'domingo' THEN 7
        ELSE 99
    END;


-- 7. Total de vítimas por ano
SELECT 
    d.ano AS ano,
    SUM(COALESCE(f.total_vitimas, 0)) AS total_vitimas
FROM fato_acidentes f
INNER JOIN dim_data d 
    ON f.id_data = d.id_data
GROUP BY d.ano
ORDER BY d.ano;


-- 8. Tipos de veículos mais envolvidos
SELECT 'automovel' AS tipo_veiculo, SUM(COALESCE(f.automovel, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'moto' AS tipo_veiculo, SUM(COALESCE(f.moto, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'caminhao' AS tipo_veiculo, SUM(COALESCE(f.caminhao, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'onibus' AS tipo_veiculo, SUM(COALESCE(f.onibus, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'bicicleta' AS tipo_veiculo, SUM(COALESCE(f.bicicleta, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'utilitarios' AS tipo_veiculo, SUM(COALESCE(f.utilitarios, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'outros' AS tipo_veiculo, SUM(COALESCE(f.outros, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'tracao_animal' AS tipo_veiculo, SUM(COALESCE(f.tracao_animal, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'transporte_de_cargas_especiais' AS tipo_veiculo, SUM(COALESCE(f.transporte_de_cargas_especiais, 0)) AS total FROM fato_acidentes f
UNION ALL
SELECT 'trator_maquinas' AS tipo_veiculo, SUM(COALESCE(f.trator_maquinas, 0)) AS total FROM fato_acidentes f
ORDER BY total DESC;


-- 9. Relação veículos x gravidade
SELECT 
    COALESCE(f.gravidade_acidente, 'não informado') AS gravidade_acidente,
    ROUND(AVG(COALESCE(f.total_veiculos_envolvidos, 0))::numeric, 2) AS media_veiculos
FROM fato_acidentes f
GROUP BY COALESCE(f.gravidade_acidente, 'não informado')
ORDER BY media_veiculos DESC;


-- 10. Top trechos + gravidade combinada
SELECT 
    COALESCE(l.trecho::text, 'não informado') AS trecho,
    COALESCE(f.gravidade_acidente, 'não informado') AS gravidade_acidente,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
INNER JOIN dim_localizacao l 
    ON f.id_localizacao = l.id_localizacao
GROUP BY 
    COALESCE(l.trecho::text, 'não informado'),
    COALESCE(f.gravidade_acidente, 'não informado')
ORDER BY total_acidentes DESC, trecho;


-- 11. Total de mortos por ano
SELECT 
    d.ano AS ano,
    SUM(COALESCE(f.mortos, 0)) AS total_mortos
FROM fato_acidentes f
INNER JOIN dim_data d 
    ON f.id_data = d.id_data
GROUP BY d.ano
ORDER BY d.ano;


-- 12. Total de feridos graves por ano
SELECT 
    d.ano AS ano,
    SUM(COALESCE(f.gravemente_feridos, 0)) AS total_feridos_graves
FROM fato_acidentes f
INNER JOIN dim_data d 
    ON f.id_data = d.id_data
GROUP BY d.ano
ORDER BY d.ano;


-- 13. Média de vítimas por acidente
SELECT 
    ROUND(AVG(COALESCE(f.total_vitimas, 0))::numeric, 2) AS media_vitimas_por_acidente
FROM fato_acidentes f;


-- 14. Média de veículos por acidente
SELECT 
    ROUND(AVG(COALESCE(f.total_veiculos_envolvidos, 0))::numeric, 2) AS media_veiculos_por_acidente
FROM fato_acidentes f;


-- 15. Tipos de ocorrência mais frequentes
SELECT 
    COALESCE(o.tipo_de_ocorrencia, 'não informado') AS tipo_de_ocorrencia,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
INNER JOIN dim_ocorrencia o 
    ON f.id_ocorrencia = o.id_ocorrencia
GROUP BY COALESCE(o.tipo_de_ocorrencia, 'não informado')
ORDER BY total_acidentes DESC;


-- 16. Acidentes por trimestre
SELECT
    CONCAT(d.ano, ' T', d.trimestre) AS periodo,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
JOIN dim_data d
    ON f.id_data = d.id_data
GROUP BY d.ano, d.trimestre
ORDER BY d.ano, d.trimestre;


-- 17. Total de acidentes por trecho
SELECT 
    COALESCE(l.trecho::text, 'não informado') AS trecho,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
INNER JOIN dim_localizacao l 
    ON f.id_localizacao = l.id_localizacao
GROUP BY COALESCE(l.trecho::text, 'não informado')
ORDER BY total_acidentes DESC, trecho;


-- 18. Total de acidentes por sentido
SELECT 
    COALESCE(l.sentido, 'não informado') AS sentido,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
INNER JOIN dim_localizacao l 
    ON f.id_localizacao = l.id_localizacao
GROUP BY COALESCE(l.sentido, 'não informado')
ORDER BY total_acidentes DESC, sentido;


-- 19. KMs com mais mortes
SELECT 
    l.km AS km,
    SUM(COALESCE(f.mortos, 0)) AS total_mortos
FROM fato_acidentes f
INNER JOIN dim_localizacao l 
    ON f.id_localizacao = l.id_localizacao
WHERE l.km IS NOT NULL
GROUP BY l.km
ORDER BY total_mortos DESC, l.km
LIMIT 10;


-- 20. KMs com mais vítimas
SELECT 
    l.km AS km,
    SUM(COALESCE(f.total_vitimas, 0)) AS total_vitimas
FROM fato_acidentes f
INNER JOIN dim_localizacao l 
    ON f.id_localizacao = l.id_localizacao
WHERE l.km IS NOT NULL
GROUP BY l.km
ORDER BY total_vitimas DESC, l.km
LIMIT 10;