import pandas as pd
from pandas import Series



def muda_encoding(df):
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

# Função responsável por resolver o encoding no ficheiro de paragens
def processa_excel_paragens():
    df = pd.read_excel("dataset_nao_processado/paragem_autocarros_oeiras_processado_4.xlsx")
    df = muda_encoding(df)
    df.to_csv("dataset_processado/paragens_encoding_correto.csv", header=False, sep=";")
    print(df.head())
    print(len(df.index))


def processa_excel_adjacencia():
    ficheiro_excel = pd.ExcelFile('dataset_nao_processado/lista_adjacencias_paragens(3).xlsx')
    nome_das_sheets = ficheiro_excel.sheet_names
    for nome_de_sheet in nome_das_sheets:
        df = ficheiro_excel.parse(nome_de_sheet)  
        df = muda_encoding(df)
        df.to_csv("dataset_processado/"+nome_de_sheet+".csv", header=False, sep=";")


processa_excel_adjacencia()


#processa_excel_paragens()