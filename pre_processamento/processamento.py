import pandas as pd
import numpy as np
from pandas import Series



def muda_encoding_paragens(df):
    lista_colunas = ['Nome da Rua','Freguesia'] #colunas em que existe corrupção de caracteres

    for coluna in lista_colunas:
        df[coluna] = df[coluna].str.replace('Ã£','ã')
        df[coluna] = df[coluna].str.replace('Ã³','ó')
        df[coluna] = df[coluna].str.replace('Ã©','é')
        df[coluna] = df[coluna].str.replace('Ã¢','â')
        df[coluna] = df[coluna].str.replace('Ã§','ç')
        df[coluna] = df[coluna].str.replace('Ãª','ê')
        df[coluna] = df[coluna].str.replace('Ãº','ú')
        df[coluna] = df[coluna].str.replace('Ã¡','á')
        df[coluna] = df[coluna].str.replace('Ã','Á')
        df[coluna] = df[coluna].str.replace('Ã','í')

    return df

#devolve um dataframe apenas com as colunas desejadas, no dataframe das adjacências
def seleciona_colunas_adjacencia(df):
    colunas_a_manter = ["gid","latitude","longitude","Carreira"]
    df = df[colunas_a_manter]
    return df


def seleciona_colunas_paragens(df):
    colunas_a_manter = ["gid","latitude","longitude","Estado de Conservacao","Tipo de Abrigo",
    "Abrigo com Publicidade?","Operadora", "Codigo de Rua",
    "Nome da Rua","Freguesia"]
    df = df[colunas_a_manter]
    return df

# tratará dos valores desconhecidos nas colunas nos exceis das adjacencias da forma que se julge relevante
def processa_nans_adjacencias(df):
    colunas_onde_se_elimina = ["gid","latitude","longitude","Carreira"]

    df = df.dropna(subset = colunas_onde_se_elimina)
    # nas restantes colunas substitui por Desconhecido
    df = df.replace(np.nan,'Desconhecido', regex=True)

    return df


def processa_nans_paragens(df):
    colunas_onde_se_elimina = ["gid","latitude","longitude"]

    df = df.dropna(subset = colunas_onde_se_elimina)
    # nas restantes colunas substitui por Desconhecido
    df = df.replace(np.nan,'Desconhecido', regex=True)

    return df


# Função responsável por resolver o encoding no ficheiro de paragens
def processa_excel_paragens():
    df = pd.read_excel("dataset_nao_processado/paragem_autocarros_oeiras_processado_4.xlsx")
    df = seleciona_colunas_paragens(df)
    df = muda_encoding_paragens(df)
    df = processa_nans_paragens(df)
    df.to_csv("dataset_processado/paragens.csv", header=False, sep=";")


def processa_excel_adjacencia():
    ficheiro_excel = pd.ExcelFile('dataset_nao_processado/lista_adjacencias_paragens(3).xlsx')
    nome_das_sheets = ficheiro_excel.sheet_names
    for nome_de_sheet in nome_das_sheets:
        df = ficheiro_excel.parse(nome_de_sheet)  
        df = seleciona_colunas_adjacencia(df)
        df = processa_nans_adjacencias(df)
        df.to_csv("dataset_processado/"+nome_de_sheet+".csv", header=False, sep=";")




def processa_exceis():
    processa_excel_adjacencia()
    processa_excel_paragens()

processa_exceis()