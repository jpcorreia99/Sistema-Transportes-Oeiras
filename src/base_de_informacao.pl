use_module(library(csv)).

%NOTA: APAGAR ÚLTIMA LINHA DO CSV 01

:- dynamic adjacencia/4.
:- dynamic paragem/10.


change_working_directory():-
    working_directory(_,'Universidade/3º Ano/2º Semestre/SRCR/').



carregar_todos_ficheiros():-
    Lista_CSVs_Adjacencia = ["01.csv","02.csv","06.csv","07.csv",
                  "10.csv","11.csv","12.csv","13.csv",
                  "15.csv","23.csv","101.csv","102.csv",
                  "106.csv","108.csv","111.csv","112.csv",
                  "114.csv","115.csv","116.csv","117.csv",
                  "119.csv","122.csv","125.csv","129.csv",
                  "158.csv","162.csv","171.csv","184.csv",
                  "201.csv","467.csv","468.csv","470.csv",
                  "471.csv","479.csv","714.csv","748.csv",
                  "750.csv","751.csv","776.csv"],
    maplist(carrega_csv_adjacencias,Lista_CSVs_Adjacencia),
    carrega_csv_paragens().


carrega_csv_adjacencias(Nome_CSV):-
    string_concat("trabalho_individual/dataset_processado/",Nome_CSV,CSV_path),
    csv_read_file(CSV_path, Data, [functor(fact), separator(0';),arity(5),match_arity(false)]),
    processa_adjacencias(Data).


carrega_csv_paragens():-
    string_concat("trabalho_individual/dataset_processado/","paragens.csv",CSV_path),
    csv_read_file(CSV_path, Data, [functor(fact), separator(0';),arity(11),match_arity(false)]),
    write(Data),
    processa_paragens(Data).


processa_adjacencias([fact(_,Gid,Latitude,Longitude,Carreira),
                        fact(Id2,Gid2,Latitude2,Longitude2,Carreira2)|T]):-
    distancia_euclidiana(Latitude,Latitude2,Longitude,Longitude2,Distancia),
    assert(adjacencia(Gid,Gid2,Distancia,Carreira)),
    write(Gid),
    write("->"),
    write(Gid2),
    write(", "),
    write(Distancia),
    write("\n"),
    processa_adjacencias([fact(Id2,Gid2,Latitude2,Longitude2,Carreira2)|T]).

processa_adjacencias([_]).


processa_paragens([fact(_,Gid,Latitude,Longitude,Estado,Tipo,Publicidade,Operador,Codigo_da_rua,Nome_da_rua,Freguesia)|T]):-
    assert(paragem(Gid,Latitude,Longitude,Estado,Tipo,Publicidade,Operador,Codigo_da_rua,Nome_da_rua,Freguesia)),
    write(Gid),write(" "),write(Estado),write(" "),write(Tipo), write(" "), write(Publicidade),
    write(" "), write(Operador), write(" "), write(Codigo_da_rua),write(" "), write(Nome_da_rua), write(" "), write(Freguesia),nl,
    processa_paragens(T).

processa_paragens([_]).


distancia_euclidiana(X1,X2,Y1,Y2, R):- R is sqrt((X2-X1)^2 + (Y2-Y1)^2).


estima(Nodo1,Nodo2,Estimativa):-
    paragem(Nodo1,Latitude1,Longitude1,_,_,_,_,_,_,_),
    paragem(Nodo2,Latitude2,Longitude2,_,_,_,_,_,_,_),
    distancia_euclidiana(Latitude1,Latitude2,Longitude1,Longitude2,Estimativa).
