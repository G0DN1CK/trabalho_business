
DROP TABLE IF EXISTS fato_acidentes CASCADE;
DROP TABLE IF EXISTS dim_data CASCADE;
DROP TABLE IF EXISTS dim_localizacao CASCADE;
DROP TABLE IF EXISTS dim_ocorrencia CASCADE;


CREATE TABLE dim_data (
    id_data SERIAL PRIMARY KEY,
    data_completa DATE NOT NULL UNIQUE,
    dia INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    dia_semana VARCHAR(20) NOT NULL
);


CREATE TABLE dim_localizacao (
    id_localizacao SERIAL PRIMARY KEY,
    km NUMERIC(10,2),
    trecho INTEGER,
    sentido VARCHAR(50),
    UNIQUE (km, trecho, sentido)
);


CREATE TABLE dim_ocorrencia (
    id_ocorrencia SERIAL PRIMARY KEY,
    n_da_ocorrencia BIGINT NOT NULL UNIQUE,
    tipo_de_ocorrencia VARCHAR(150),
    tipo_de_acidente VARCHAR(150)
);


CREATE TABLE fato_acidentes (
    id_fato SERIAL PRIMARY KEY,

    id_data INTEGER NOT NULL,
    id_localizacao INTEGER NOT NULL,
    id_ocorrencia INTEGER NOT NULL,

    horario TIME,

    automovel INTEGER DEFAULT 0,
    bicicleta INTEGER DEFAULT 0,
    caminhao INTEGER DEFAULT 0,
    moto INTEGER DEFAULT 0,
    onibus INTEGER DEFAULT 0,
    outros INTEGER DEFAULT 0,
    tracao_animal INTEGER DEFAULT 0,
    transporte_de_cargas_especiais INTEGER DEFAULT 0,
    trator_maquinas INTEGER DEFAULT 0,
    utilitarios INTEGER DEFAULT 0,

    ilesos INTEGER DEFAULT 0,
    levemente_feridos INTEGER DEFAULT 0,
    moderadamente_feridos INTEGER DEFAULT 0,
    gravemente_feridos INTEGER DEFAULT 0,
    mortos INTEGER DEFAULT 0,

    total_veiculos_envolvidos INTEGER DEFAULT 0,
    total_vitimas INTEGER DEFAULT 0,
    gravidade_acidente VARCHAR(50),

    CONSTRAINT fk_fato_data
        FOREIGN KEY (id_data)
        REFERENCES dim_data(id_data),

    CONSTRAINT fk_fato_localizacao
        FOREIGN KEY (id_localizacao)
        REFERENCES dim_localizacao(id_localizacao),

    CONSTRAINT fk_fato_ocorrencia
        FOREIGN KEY (id_ocorrencia)
        REFERENCES dim_ocorrencia(id_ocorrencia)
);


CREATE INDEX idx_dim_data_data_completa
    ON dim_data(data_completa);

CREATE INDEX idx_dim_localizacao_km
    ON dim_localizacao(km);

CREATE INDEX idx_dim_ocorrencia_numero
    ON dim_ocorrencia(n_da_ocorrencia);

CREATE INDEX idx_fato_id_data
    ON fato_acidentes(id_data);

CREATE INDEX idx_fato_id_localizacao
    ON fato_acidentes(id_localizacao);

CREATE INDEX idx_fato_id_ocorrencia
    ON fato_acidentes(id_ocorrencia);