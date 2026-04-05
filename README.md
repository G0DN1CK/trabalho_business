# Projeto Data Warehouse – Análise de Acidentes

## Descrição

Este projeto tem como objetivo a construção de um **Data Warehouse (DW)** para análise de acidentes, utilizando dados públicos armazenados em arquivo CSV e carregados em um banco **PostgreSQL** por meio de um processo de **ETL em Python**.

O projeto foi desenvolvido com foco em apoio à análise de dados e visualização em ferramentas de BI, como **Metabase** e **Power BI**, permitindo identificar padrões temporais, gravidade, localização e características dos acidentes registrados.

---

## Objetivo

O principal objetivo deste projeto é transformar dados brutos de acidentes em uma estrutura analítica organizada, permitindo responder perguntas como:

- Em quais períodos ocorreram mais acidentes?
- Quais são os tipos de acidentes mais frequentes?
- Quais locais apresentam maior concentração de ocorrências?
- Em quais horários há mais acidentes?
- Qual a relação entre acidentes e gravidade?
- Quais sentidos da via concentram mais ocorrências?

---

## Fonte dos Dados

Os dados utilizados neste projeto foram obtidos a partir de um arquivo CSV contendo informações sobre acidentes, com atributos como:

- data
- horário
- número da ocorrência
- tipo de ocorrência
- tipo de acidente
- km
- trecho
- sentido
- veículos envolvidos
- número de vítimas
- gravidade

Esses dados foram tratados antes da carga no Data Warehouse para corrigir inconsistências, valores nulos e categorias duplicadas.

---

## Tecnologias Utilizadas

- **Python**
- **Pandas**
- **PostgreSQL**
- **Metabase**
- **Git/GitHub**

---

## Estrutura do Projeto


ACIDENTES_LITORALSUL/
│
├── etl_dw_acidentes.py
├── dw_acidentes.sql
├── consultas.sql
├── README.md
└── demostrativo_acidentes_als.csv



## STAR SCHEMA

                    +------------------+
                    |     dim_data     |
                    |------------------|
                    | id_data (PK)     |
                    | data_completa    |
                    | dia              |
                    | mes              |
                    | ano              |
                    | trimestre        |
                    | dia_semana       |
                    +------------------+
                             |
                             |
                             |
+---------------------+      |      +----------------------+
|   dim_localizacao   |      |      |    dim_ocorrencia    |
|---------------------|      |      |----------------------|
| id_localizacao (PK) |      |      | id_ocorrencia (PK)   |
| km                  |      |      | n_da_ocorrencia      |
| trecho              |      |      | tipo_de_ocorrencia   |
| sentido             |      |      | tipo_de_acidente     |
+---------------------+      |      +----------------------+
            \                |                /
             \               |               /
              \              |              /
               \             |             /
                \            |            /
                 +----------------------------------+
                 |         fato_acidentes           |
                 |----------------------------------|
                 | id_fato (PK)                     |
                 | id_data (FK)                     |
                 | id_localizacao (FK)              |
                 | id_ocorrencia (FK)               |
                 | horario                          |
                 | automovel                        |
                 | bicicleta                        |
                 | caminhao                         |
                 | moto                             |
                 | onibus                           |
                 | outros                           |
                 | tracao_animal                    |
                 | transporte_de_cargas_especiais   |
                 | trator_maquinas                  |
                 | utilitarios                      |
                 | ilesos                           |
                 | levemente_feridos                |
                 | moderadamente_feridos            |
                 | gravemente_feridos               |
                 | mortos                           |
                 | total_veiculos_envolvidos        |
                 | total_vitimas                    |
                 | gravidade_acidente               |
                 +----------------------------------+