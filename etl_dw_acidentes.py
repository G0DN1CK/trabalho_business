import re
import pandas as pd
from sqlalchemy import create_engine, text

# ==========================================
# CONFIGURAÇÃO DO BANCO
# ==========================================
DB_USER = "postgres"
DB_PASS = "masterkey"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "dw_acidentes"

CSV_PATH = "demostrativo_acidentes_als.csv"

engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# ==========================================
# FUNÇÕES AUXILIARES
# ==========================================
def normalizar_texto(valor):
    if pd.isna(valor):
        return None

    valor = str(valor).strip().lower()

    if valor in {"", "nan", "none", "null"}:
        return None

    # remove espaços duplicados
    valor = re.sub(r"\s+", " ", valor)

    return valor


def normalizar_tipo_ocorrencia(valor):
    valor = normalizar_texto(valor)

    if valor is None:
        return "não informado"

    if "2 -" in valor or valor == "2 - aciden" or "sem vítima" in valor or "sem vitima" in valor:
        return "sem vítima"

    if "3 -" in valor or valor == "3 - aciden" or "com vítima" in valor or "com vitima" in valor:
        return "com vítima"

    if "sem" in valor and "vit" in valor:
        return "sem vítima"

    if "com" in valor and "vit" in valor:
        return "com vítima"

    return valor


def normalizar_tipo_acidente(valor):
    valor = normalizar_texto(valor)

    if valor is None:
        return "não informado"

    substituicoes = {
        'colis�o traseira': 'colisão traseira',
        'colis�o lateral': 'colisão lateral',
        'colis�o transversal': 'colisão transversal',
        'saida de pista': 'saída de pista',
        'choque - defensa, barreira ou submarino""': 'choque - defensa, barreira ou submarino',
        'atropelamento - ambulante': 'atropelamento - ambulante',
        'queda de moto': 'queda de moto',
        'capotamento': 'capotamento',
        'engavetamento': 'engavetamento',
        'atropelamento de animal': 'atropelamento de animal',
        'choque - objeto sobre a pista': 'choque - objeto sobre a pista'
    }

    valor = substituicoes.get(valor, valor)

    # limpeza extra de aspas duplicadas
    valor = valor.replace('""', '"').strip('"').strip()

    return valor if valor else "não informado"


def normalizar_sentido(valor):
    valor = normalizar_texto(valor)
    return valor if valor else "não informado"


def limpar_trecho(valor):
    if pd.isna(valor):
        return pd.NA

    valor = str(valor).strip()

    if valor in {"", "nan", "None", "null"}:
        return pd.NA

    # extrai apenas número, caso venha texto misturado
    match = re.search(r"(\d+)", valor)
    if match:
        return int(match.group(1))

    return pd.NA


def limpar_km(valor):
    if pd.isna(valor):
        return None

    valor = str(valor).strip().replace(",", ".")

    if valor in {"", "nan", "None", "null"}:
        return None

    try:
        return round(float(valor), 2)
    except ValueError:
        return None


# ==========================================
# 1. EXTRACT
# ==========================================
def extract(csv_path: str) -> pd.DataFrame:
    print("Lendo arquivo CSV...")

    df = pd.read_csv(
        csv_path,
        sep=";",
        encoding="latin1"
    )

    print(f"Arquivo carregado com sucesso. Total de registros: {len(df)}")
    print("\nColunas encontradas:")
    print(df.columns.tolist())

    return df


# ==========================================
# 2. TRANSFORM
# ==========================================
def transform(df: pd.DataFrame) -> pd.DataFrame:
    print("Transformando dados...")

    # Padronizar nomes das colunas
    df.columns = [col.strip().lower() for col in df.columns]

    # --------------------------
    # Data e horário
    # --------------------------
    df["data"] = pd.to_datetime(df["data"], format="%d/%m/%Y", errors="coerce")

    df["horario"] = pd.to_datetime(
        df["horario"],
        format="%H:%M:%S",
        errors="coerce"
    ).dt.time

    # --------------------------
    # Campos de localização
    # --------------------------
    df["trecho"] = df["trecho"].apply(limpar_trecho).astype("Int64")
    df["km"] = df["km"].apply(limpar_km)
    df["sentido"] = df["sentido"].apply(normalizar_sentido)

    # --------------------------
    # Campos textuais
    # --------------------------
    df["tipo_de_ocorrencia"] = df["tipo_de_ocorrencia"].apply(normalizar_tipo_ocorrencia)
    df["tipo_de_acidente"] = df["tipo_de_acidente"].apply(normalizar_tipo_acidente)

    # --------------------------
    # Campos numéricos
    # --------------------------
    numeric_cols = [
        "n_da_ocorrencia",
        "automovel",
        "bicicleta",
        "caminhao",
        "moto",
        "onibus",
        "outros",
        "tracao_animal",
        "transporte_de_cargas_especiais",
        "trator_maquinas",
        "utilitarios",
        "ilesos",
        "levemente_feridos",
        "moderadamente_feridos",
        "gravemente_feridos",
        "mortos"
    ]

    for col in numeric_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    # métricas vazias viram 0
    metric_cols = [
        "automovel",
        "bicicleta",
        "caminhao",
        "moto",
        "onibus",
        "outros",
        "tracao_animal",
        "transporte_de_cargas_especiais",
        "trator_maquinas",
        "utilitarios",
        "ilesos",
        "levemente_feridos",
        "moderadamente_feridos",
        "gravemente_feridos",
        "mortos"
    ]

    for col in metric_cols:
        df[col] = df[col].fillna(0)

    # ocorrência sem número não serve para a dimensão
    df["n_da_ocorrencia"] = df["n_da_ocorrencia"].fillna(0).astype("int64")

    # remover linhas sem data válida
    df = df.dropna(subset=["data"]).copy()

    # --------------------------
    # Colunas derivadas
    # --------------------------
    df["dia"] = df["data"].dt.day.astype(int)
    df["mes"] = df["data"].dt.month.astype(int)
    df["ano"] = df["data"].dt.year.astype(int)
    df["trimestre"] = df["data"].dt.quarter.astype(int)
    df["dia_semana"] = df["data"].dt.day_name()

    traducao_dias = {
        "Monday": "segunda-feira",
        "Tuesday": "terça-feira",
        "Wednesday": "quarta-feira",
        "Thursday": "quinta-feira",
        "Friday": "sexta-feira",
        "Saturday": "sábado",
        "Sunday": "domingo"
    }
    df["dia_semana"] = df["dia_semana"].replace(traducao_dias)

    colunas_veiculos = [
        "automovel",
        "bicicleta",
        "caminhao",
        "moto",
        "onibus",
        "outros",
        "tracao_animal",
        "transporte_de_cargas_especiais",
        "trator_maquinas",
        "utilitarios"
    ]
    df["total_veiculos_envolvidos"] = df[colunas_veiculos].sum(axis=1).astype(int)

    colunas_vitimas = [
        "ilesos",
        "levemente_feridos",
        "moderadamente_feridos",
        "gravemente_feridos",
        "mortos"
    ]
    df["total_vitimas"] = df[colunas_vitimas].sum(axis=1).astype(int)

    def classificar_gravidade(row):
        if row["mortos"] > 0:
            return "fatal"
        if row["gravemente_feridos"] > 0:
            return "grave"
        if row["moderadamente_feridos"] > 0 or row["levemente_feridos"] > 0:
            return "com feridos"
        return "sem vítimas"

    df["gravidade_acidente"] = df.apply(classificar_gravidade, axis=1)

    # logs de conferência
    print("\nValores únicos de tipo_de_ocorrencia:")
    print(sorted(df["tipo_de_ocorrencia"].dropna().unique().tolist()))

    print("\nResumo do trecho:")
    print(f"Preenchidos: {df['trecho'].notna().sum()}")
    print(f"Nulos: {df['trecho'].isna().sum()}")

    print("\nExemplos de trecho:")
    print(df["trecho"].dropna().head(20))

    print("\nTransformação concluída.")
    return df


# ==========================================
# 3. BUILD DIMENSIONS
# ==========================================
def build_dimensions(df: pd.DataFrame):
    print("Montando dimensões em memória...")

    # DIM DATA
    dim_data = (
        df[["data", "dia", "mes", "ano", "trimestre", "dia_semana"]]
        .drop_duplicates()
        .sort_values("data")
        .reset_index(drop=True)
        .copy()
    )
    dim_data = dim_data.rename(columns={"data": "data_completa"})
    dim_data.insert(0, "id_data", range(1, len(dim_data) + 1))

    # DIM LOCALIZACAO
    dim_localizacao = (
        df[["km", "trecho", "sentido"]]
        .drop_duplicates()
        .sort_values(["sentido", "trecho", "km"], na_position="last")
        .reset_index(drop=True)
        .copy()
    )
    dim_localizacao.insert(0, "id_localizacao", range(1, len(dim_localizacao) + 1))

    # trocar <NA> por None para persistência
    dim_localizacao["trecho"] = dim_localizacao["trecho"].where(
        dim_localizacao["trecho"].notna(),
        None
    )

    # DIM OCORRENCIA
    dim_ocorrencia = (
        df[["n_da_ocorrencia", "tipo_de_ocorrencia", "tipo_de_acidente"]]
        .dropna(subset=["n_da_ocorrencia"])
        .sort_values("n_da_ocorrencia")
        .drop_duplicates(subset=["n_da_ocorrencia"], keep="first")
        .reset_index(drop=True)
        .copy()
    )
    dim_ocorrencia["n_da_ocorrencia"] = dim_ocorrencia["n_da_ocorrencia"].astype("int64")
    dim_ocorrencia.insert(0, "id_ocorrencia", range(1, len(dim_ocorrencia) + 1))

    print(f"dim_data pronta com {len(dim_data)} registros.")
    print(f"dim_localizacao pronta com {len(dim_localizacao)} registros.")
    print(f"dim_ocorrencia pronta com {len(dim_ocorrencia)} registros.")

    return dim_data, dim_localizacao, dim_ocorrencia


# ==========================================
# 4. BUILD FACT
# ==========================================
def build_fact(
    df: pd.DataFrame,
    dim_data: pd.DataFrame,
    dim_localizacao: pd.DataFrame,
    dim_ocorrencia: pd.DataFrame
) -> pd.DataFrame:
    print("Montando tabela fato em memória...")

    fato = df.copy()

    dim_localizacao_merge = dim_localizacao.copy()
    dim_localizacao_merge["trecho"] = pd.to_numeric(
        dim_localizacao_merge["trecho"],
        errors="coerce"
    ).astype("Int64")

    fato = fato.merge(
        dim_data[["id_data", "data_completa"]],
        left_on="data",
        right_on="data_completa",
        how="left"
    )

    fato = fato.merge(
        dim_localizacao_merge[["id_localizacao", "km", "trecho", "sentido"]],
        on=["km", "trecho", "sentido"],
        how="left"
    )

    fato = fato.merge(
        dim_ocorrencia[["id_ocorrencia", "n_da_ocorrencia"]],
        on="n_da_ocorrencia",
        how="left"
    )

    if fato["id_data"].isna().any():
        raise ValueError("Falha no relacionamento com dim_data.")
    if fato["id_localizacao"].isna().any():
        raise ValueError("Falha no relacionamento com dim_localizacao.")
    if fato["id_ocorrencia"].isna().any():
        raise ValueError("Falha no relacionamento com dim_ocorrencia.")

    fato_final = fato[[
        "id_data",
        "id_localizacao",
        "id_ocorrencia",
        "horario",
        "automovel",
        "bicicleta",
        "caminhao",
        "moto",
        "onibus",
        "outros",
        "tracao_animal",
        "transporte_de_cargas_especiais",
        "trator_maquinas",
        "utilitarios",
        "ilesos",
        "levemente_feridos",
        "moderadamente_feridos",
        "gravemente_feridos",
        "mortos",
        "total_veiculos_envolvidos",
        "total_vitimas",
        "gravidade_acidente"
    ]].copy()

    int_cols = [
        "id_data",
        "id_localizacao",
        "id_ocorrencia",
        "automovel",
        "bicicleta",
        "caminhao",
        "moto",
        "onibus",
        "outros",
        "tracao_animal",
        "transporte_de_cargas_especiais",
        "trator_maquinas",
        "utilitarios",
        "ilesos",
        "levemente_feridos",
        "moderadamente_feridos",
        "gravemente_feridos",
        "mortos",
        "total_veiculos_envolvidos",
        "total_vitimas"
    ]

    for col in int_cols:
        fato_final[col] = pd.to_numeric(
            fato_final[col],
            errors="coerce"
        ).fillna(0).astype(int)

    print(f"fato_acidentes pronta com {len(fato_final)} registros.")
    return fato_final


# ==========================================
# 5. LIMPEZA AUTOMÁTICA DO BANCO
# ==========================================
def truncate_tables():
    print("Limpando tabelas do banco...")

    with engine.begin() as conn:
        conn.execute(text("""
            TRUNCATE TABLE
                fato_acidentes,
                dim_data,
                dim_localizacao,
                dim_ocorrencia
            RESTART IDENTITY CASCADE
        """))


# ==========================================
# 6. LOAD
# ==========================================
def load_to_postgres(
    dim_data: pd.DataFrame,
    dim_localizacao: pd.DataFrame,
    dim_ocorrencia: pd.DataFrame,
    fato_acidentes: pd.DataFrame
):
    print("Carregando dados no PostgreSQL...")

    truncate_tables()

    dim_data.to_sql("dim_data", engine, if_exists="append", index=False)
    dim_localizacao.to_sql("dim_localizacao", engine, if_exists="append", index=False)
    dim_ocorrencia.to_sql("dim_ocorrencia", engine, if_exists="append", index=False)
    fato_acidentes.to_sql("fato_acidentes", engine, if_exists="append", index=False)

    print("Carga concluída no PostgreSQL.")


# ==========================================
# 7. MAIN
# ==========================================
def main():
    try:
        print("Iniciando ETL do Data Warehouse de Acidentes...\n")

        df = extract(CSV_PATH)
        df = transform(df)

        dim_data, dim_localizacao, dim_ocorrencia = build_dimensions(df)
        fato_acidentes = build_fact(df, dim_data, dim_localizacao, dim_ocorrencia)

        load_to_postgres(
            dim_data=dim_data,
            dim_localizacao=dim_localizacao,
            dim_ocorrencia=dim_ocorrencia,
            fato_acidentes=fato_acidentes
        )

        print("\nETL concluído com sucesso!")

    except Exception as e:
        print(f"\nErro durante o ETL: {e}")


if __name__ == "__main__":
    main()