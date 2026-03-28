-- =========================================
-- CONSULTAS ANALÍTICAS - DW ACIDENTES
-- =========================================

-- 1. Evolução de acidentes ao longo do tempo
SELECT 
    d.ano,
    d.mes,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
JOIN dim_data d ON f.id_data = d.id_data
GROUP BY d.ano, d.mes
ORDER BY d.ano, d.mes;


-- 2. Tipos de acidentes mais comuns
SELECT 
    o.tipo_de_acidente,
    COUNT(*) AS total
FROM fato_acidentes f
JOIN dim_ocorrencia o ON f.id_ocorrencia = o.id_ocorrencia
GROUP BY o.tipo_de_acidente
ORDER BY total DESC
LIMIT 10;


-- 3. Análise de gravidade dos acidentes
SELECT 
    f.gravidade_acidente,
    COUNT(*) AS total
FROM fato_acidentes f
GROUP BY f.gravidade_acidente
ORDER BY total DESC;


-- 4. Locais mais perigosos (KM)
SELECT 
    l.km,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
JOIN dim_localizacao l ON f.id_localizacao = l.id_localizacao
GROUP BY l.km
ORDER BY total_acidentes DESC
LIMIT 10;


-- 5. Horários mais perigosos
SELECT 
    EXTRACT(HOUR FROM f.horario) AS hora,
    COUNT(*) AS total
FROM fato_acidentes f
GROUP BY hora
ORDER BY total DESC;


-- 6. Dias da semana com mais acidentes
SELECT 
    d.dia_semana,
    COUNT(*) AS total
FROM fato_acidentes f
JOIN dim_data d ON f.id_data = d.id_data
GROUP BY d.dia_semana
ORDER BY total DESC;


-- 7. Total de vítimas por período
SELECT 
    d.ano,
    SUM(f.total_vitimas) AS total_vitimas
FROM fato_acidentes f
JOIN dim_data d ON f.id_data = d.id_data
GROUP BY d.ano
ORDER BY d.ano;


-- 8. Tipos de veículos mais envolvidos
SELECT 
    SUM(f.automovel) AS automovel,
    SUM(f.moto) AS moto,
    SUM(f.caminhao) AS caminhao,
    SUM(f.onibus) AS onibus,
    SUM(f.bicicleta) AS bicicleta,
    SUM(f.utilitarios) AS utilitarios,
    SUM(f.outros) AS outros,
    SUM(f.tracao_animal) AS tracao_animal,
    SUM(f.transporte_de_cargas_especiais) AS transporte_de_cargas_especiais,
    SUM(f.trator_maquinas) AS trator_maquinas
FROM fato_acidentes f;


-- 9. Relação veículos x gravidade
SELECT 
    f.gravidade_acidente,
    AVG(f.total_veiculos_envolvidos) AS media_veiculos
FROM fato_acidentes f
GROUP BY f.gravidade_acidente
ORDER BY media_veiculos DESC;


-- 10. Top trechos + gravidade combinada
SELECT 
    l.trecho,
    f.gravidade_acidente,
    COUNT(*) AS total
FROM fato_acidentes f
JOIN dim_localizacao l ON f.id_localizacao = l.id_localizacao
GROUP BY l.trecho, f.gravidade_acidente
ORDER BY total DESC;


-- 11. Total de mortos por ano
SELECT 
    d.ano,
    SUM(f.mortos) AS total_mortos
FROM fato_acidentes f
JOIN dim_data d ON f.id_data = d.id_data
GROUP BY d.ano
ORDER BY d.ano;


-- 12. Total de feridos graves por ano
SELECT 
    d.ano,
    SUM(f.gravemente_feridos) AS total_feridos_graves
FROM fato_acidentes f
JOIN dim_data d ON f.id_data = d.id_data
GROUP BY d.ano
ORDER BY d.ano;


-- 13. Média de vítimas por acidente
SELECT 
    AVG(f.total_vitimas) AS media_vitimas_por_acidente
FROM fato_acidentes f;


-- 14. Média de veículos por acidente
SELECT 
    AVG(f.total_veiculos_envolvidos) AS media_veiculos_por_acidente
FROM fato_acidentes f;


-- 15. Tipos de ocorrência mais frequentes
SELECT 
    o.tipo_de_ocorrencia,
    COUNT(*) AS total
FROM fato_acidentes f
JOIN dim_ocorrencia o ON f.id_ocorrencia = o.id_ocorrencia
GROUP BY o.tipo_de_ocorrencia
ORDER BY total DESC;


-- 16. Acidentes por trimestre
SELECT 
    d.ano,
    d.trimestre,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
JOIN dim_data d ON f.id_data = d.id_data
GROUP BY d.ano, d.trimestre
ORDER BY d.ano, d.trimestre;


-- 17. Total de acidentes por trecho
SELECT 
    l.trecho,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
JOIN dim_localizacao l ON f.id_localizacao = l.id_localizacao
GROUP BY l.trecho
ORDER BY total_acidentes DESC;


-- 18. Total de acidentes por sentido
SELECT 
    l.sentido,
    COUNT(*) AS total_acidentes
FROM fato_acidentes f
JOIN dim_localizacao l ON f.id_localizacao = l.id_localizacao
GROUP BY l.sentido
ORDER BY total_acidentes DESC;


-- 19. KMs com mais mortes
SELECT 
    l.km,
    SUM(f.mortos) AS total_mortos
FROM fato_acidentes f
JOIN dim_localizacao l ON f.id_localizacao = l.id_localizacao
GROUP BY l.km
ORDER BY total_mortos DESC
LIMIT 10;


-- 20. KMs com mais vítimas
SELECT 
    l.km,
    SUM(f.total_vitimas) AS total_vitimas
FROM fato_acidentes f
JOIN dim_localizacao l ON f.id_localizacao = l.id_localizacao
GROUP BY l.km
ORDER BY total_vitimas DESC
LIMIT 10;