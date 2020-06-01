use_module(library(csv)).


%NOTA: APAGAR ÚLTIMA LINHA DO CSV 01

:- dynamic adjacencia/4.
:- dynamic paragem/10.
:- dynamic adjacencia2/3.
:- dynamic estimativa_pre_existente/3.
:- dynamic estimativa_pre_existente2/2.


change_working_directory():-
    working_directory(_,'Universidade/3º Ano/2º Semestre/SRCR/').



carrega_todos_ficheiros():-
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
    processa_paragens(Data).


processa_adjacencias([fact(_,Gid,Latitude,Longitude,Carreira),
                        fact(Id2,Gid2,Latitude2,Longitude2,Carreira2)|T]):-
    not(existe(Gid,Gid2)),
    Gid \= Gid2,
    distancia_euclidiana(Latitude,Latitude2,Longitude,Longitude2,Distancia),
    assert(adjacencia(Gid,Gid2,Distancia,Carreira)),
    assert(adjacencia(Gid2,Gid,Distancia,Carreira)),
    assert(adjacencia2(Gid,Gid2,Distancia)),
    write(Gid),
    write("->"),
    write(Gid2),
    write(", "),
    write(Distancia),
    write("\n"),
    processa_adjacencias([fact(Id2,Gid2,Latitude2,Longitude2,Carreira2)|T]).

%caso seja repetido
processa_adjacencias([_,X|T]):-
    processa_adjacencias([X|T]).

processa_adjacencias([_]).


processa_paragens([fact(_,Gid,Latitude,Longitude,Estado,Tipo,Publicidade,Operador,Codigo_da_rua,Nome_da_rua,Freguesia)|T]):-
    assert(paragem(Gid,Latitude,Longitude,Estado,Tipo,Publicidade,Operador,Codigo_da_rua,Nome_da_rua,Freguesia)),
    write(Gid),write(" "),write(Estado),write(" "),write(Tipo), write(" "), write(Publicidade),
    write(" "), write(Operador), write(" "), write(Codigo_da_rua),write(" "), write(Nome_da_rua), write(" "), write(Freguesia),nl,
    processa_paragens(T).

processa_paragens([_]).


estima(Nodo1,Nodo2,Estimativa):-
    paragem(Nodo1,Latitude1,Longitude1,_,_,_,_,_,_,_),
    paragem(Nodo2,Latitude2,Longitude2,_,_,_,_,_,_,_),
    distancia_euclidiana(Latitude1,Latitude2,Longitude1,Longitude2,Estimativa).



% carrega um número menor de ficheiros
carrega_todos_ficheiros2():-
    %Lista_CSVs_Adjacencia = ["01.csv","02.csv","06.csv","07.csv"],
    Lista_CSVs_Adjacencia = ["01.csv","02.csv"],
    maplist(carrega_csv_adjacencias,Lista_CSVs_Adjacencia),
    carrega_csv_paragens().






carrega_csv_adjacencias2(Nome_CSV):-
    write(Nome_CSV),
    nl,nl,
    string_concat("trabalho_individual/dataset_processado/",Nome_CSV,CSV_path),
    csv_read_file(CSV_path, Data, [functor(fact), separator(0';),arity(5),match_arity(false)]),
    processa_adjacencias2(Data).

processa_adjacencias2([fact(_,Gid,Latitude,Longitude,_),
                        fact(Id2,Gid2,Latitude2,Longitude2,_)|T]):-
    not(existe(Gid,Gid2)),
    distancia_euclidiana(Latitude,Latitude2,Longitude,Longitude2,Distancia),
    Gid \=Gid2,
    assert(adjacencia2(Gid,Gid2,Distancia)),
    write(Gid),
    write("->"),
    write(Gid2),
    write(", "),
    write(Distancia),
    write("\n"),
    processa_adjacencias2([fact(Id2,Gid2,Latitude2,Longitude2,_)|T]).

processa_adjacencias2([_,X|T]):-
    processa_adjacencias2([X|T]).

processa_adjacencias2([_]).




conta(R):-
    findall((A,B), adjacencia(A,B,_,_), L),
    length(L,R).


conta2(R):-
    findall((A,B), adjacencia2(A,B,_), L),
    length(L,R).
    
    
%507->509
existe(X,Y):-
    adjacencia2(X,Y,_).

existe(X,Y):-
    adjacencia(X,Y,_,_).


distancia_euclidiana(X1,X2,Y1,Y2, R):- R is sqrt((X2-X1)^2 + (Y2-Y1)^2).



assert_estimativa_previa(Destino):-
    findall((GId),paragem(GId,_,_,_,_,_,_,_,_,_),ListaParagens),
    cria_estimativas(ListaParagens,Destino).

cria_estimativas([Gid|T],Destino):-
    paragem(Gid,Latitude1,Longitude1,_,_,_,_,_,_,_),
    paragem(Destino,Latitude2,Longitude2,_,_,_,_,_,_,_),
    distancia_euclidiana(Latitude1,Latitude2,Longitude1,Longitude2,Estimativa),
    assert(estimativa_pre_existente(Gid,Destino,Estimativa)),
    cria_estimativas(T,Destino).

cria_estimativas([],_).



