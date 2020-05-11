use_module(library(csv)).

:- dynamic adjacencia/2.

adjacencia(1,2).
adjacencia(2,1).
adjacencia(2,3).

change_working_directory():-
    working_directory(_,'Universidade/3º Ano/2º Semestre/SRCR/').



carregar_todos_ficheiros():-
    Lista_CSVs = ["01.csv","02.csv","06.csv","07.csv",
                  "10.csv","11.csv","12.csv","13.csv",
                  "15.csv","23.csv","101.csv","102.csv",
                  "106.csv","108.csv","111.csv","112.csv",
                  "114.csv","115.csv","116.csv","117.csv",
                  "119.csv","122.csv","125.csv","129.csv",
                  "158.csv","162.csv","171.csv","184.csv",
                  "201.csv","467.csv","468.csv","470.csv",
                  "471.csv","479.csv","714.csv","748.csv",
                  "750.csv","751.csv","776.csv"],
    maplist(carrega_csv,Lista_CSVs).


carrega_csv(Nome_CSV):-
    string_concat("trabalho_individual/dataset_processado/",Nome_CSV,CSV_path),
    csv_read_file(CSV_path, Data, [functor(fact), separator(0';),arity(12),match_arity(false)]),
    processa_adjacencias(Data).
%    maplist(funcao_auxiliar, Data).



processa_adjacencias([fact(Id,Gid,Latitude,Longitude,Estado,Tipo,Publicidade,Operador,Carreia,Codigo,Nome,Freguesia),
                        fact(Id2,Gid2,Latitude2,Longitude2,Estado2,Tipo2,Publicidade2,Operador2,Carreia2,Codigo2,Nome2,Freguesia2)|T]):-
                        assert(adjacencia(Gid,Gid2)),
                        write(Gid),
                        write("->"),
                        write(Gid2),
                        write("\n"),
                        processa_adjacencias([fact(Id2,Gid2,Latitude2,Longitude2,Estado2,Tipo2,Publicidade2,Operador2,Carreia2,Codigo2,Nome2,Freguesia2)|T]).

processa_adjacencias([_]).





resolve_df( Start, End ,Solution)  :-
    depthfirst( [], Start, End,Solution1),
    reverse(Solution1,Solution).

  
  % depthfirst( Path, Node, Solution):
  %   extending the path [Node | Path] to a goal gives Solution
  
depthfirst( Path, End, End, [End | Path] ).

depthfirst( Path, Node, End, Sol)  :-
adjacencia( Node, Node1),
\+ member( Node1, Path),
depthfirst( [Node | Path], Node1,End,Sol).
  

inverte_lista([],Z,Z).
inverte_lista([Head|Tail],Z,Acc) :- inverte_lista(Tail,Z,[Head|Acc]).


dfTodasSolucoes(L,Start,End):- findall((S),(resolve_df(Start,End,S)),L).


distancia_euclidiana(X1,X2,Y1,Y2, R):- R is sqrt((X2-X1)^2 + (Y2-Y1)^2).
