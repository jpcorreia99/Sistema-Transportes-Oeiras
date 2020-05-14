use_module(library(csv)).

%NOTA: APAGAR ÚLTIMA LINHA DO CSV 01
%TODO: corrigir excel grande, eliminar quando a carreira é desconhecida e "talvez" operadora
% ligações a pé?

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


                        
resolve_df( Start, End ,Solution,Custo)  :-
    depthfirst( [], Start, End,Solution1,Custo),
    reverse(Solution1,Solution).

  

depthfirst( Path, Node, End, [(End,"Fim"), (Node,Carreira) | Path],Custo):-
        adjacencia(Node,End,Custo,Carreira).


depthfirst( Path, Node, End, Sol,Custo)  :-
    adjacencia( Node, Node1,Distancia,Carreira),
    write(Node1),nl,
    \+ member( Node1, Path),
    depthfirst( [(Node,Carreira) | Path], Node1,End,Sol,Custo1),
    Custo is Distancia + Custo1.
  



dfTodasSolucoes(L,Start,End):- findall((S),(resolve_df(Start,End,S,_)),L).


estima(Nodo1,Nodo2,Estimativa):-
    paragem(Nodo1,Latitude1,Longitude1,_,_,_,_,_,_,_),
    paragem(Nodo2,Latitude2,Longitude2,_,_,_,_,_,_,_),
    distancia_euclidiana(Latitude1,Latitude2,Longitude1,Longitude2,Estimativa).





goal(182).

resolve_gulosa(Partida, Destino,Caminho/Custo) :-
	estima(Partida,Destino ,Estimativa),
	agulosa([[Partida]/0/Estimativa],Destino,InvCaminho/Custo/_),
	reverse(InvCaminho, Caminho).

agulosa(Caminhos, Destino ,Caminho) :-
	obtem_melhor_g(Caminhos, Caminho),
    Caminho = [Nodo|_]/_/_
    ,Nodo == Destino.

agulosa(Caminhos, Destino ,SolucaoCaminho) :-
	obtem_melhor_g(Caminhos,MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_gulosa(MelhorCaminho, ExpCaminhos,Destino),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        agulosa(NovoCaminhos,Destino ,SolucaoCaminho).	


expande_gulosa(Caminho, ExpCaminhos, Destino) :-
    findall(NovoCaminho, adjacente(Caminho,NovoCaminho,Destino), ExpCaminhos).


adjacente([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est,Destino) :-
    adjacencia(Nodo, ProxNodo, PassoCusto,_),\+ member(ProxNodo, Caminho),
    NovoCusto is Custo + PassoCusto,
    estima(ProxNodo,Destino ,Est).


seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).


obtem_melhor_g([Caminho], Caminho) :- !.

obtem_melhor_g([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Est1 =< Est2, !,
	obtem_melhor_g([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
	
obtem_melhor_g([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor_g(Caminhos, MelhorCaminho).