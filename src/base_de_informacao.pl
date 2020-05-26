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
    distancia_euclidiana(Latitude,Latitude2,Longitude,Longitude2,Distancia),
    assert(adjacencia(Gid,Gid2,Distancia,Carreira)),
    assert(adjacencia(Gid2,Gid,Distancia,Carreira)),
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


estima(Nodo1,Nodo2,Estimativa):-
    paragem(Nodo1,Latitude1,Longitude1,_,_,_,_,_,_,_),
    paragem(Nodo2,Latitude2,Longitude2,_,_,_,_,_,_,_),
    distancia_euclidiana(Latitude1,Latitude2,Longitude1,Longitude2,Estimativa).



% experimentos científicos


carrega_todos_ficheiros2():-
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
    maplist(carrega_csv_adjacencias2,Lista_CSVs_Adjacencia),
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


resolve_df2( Comeco, Destino ,Solucao,Distancia)  :-
    depthfirst2( [], Comeco, Destino,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao).

  

depthfirst2( Caminho, Paragem, Destino, [Destino, Paragem | Caminho],Distancia):-
        adjacencia2(Paragem,Destino,Distancia).


depthfirst2( Caminho, Paragem, End, Solucao,Distancia)  :-
    adjacencia2( Paragem, ProxParagem,DistanciaParagem),
    write(ProxParagem),nl,
    \+ member( ProxParagem, Caminho),
    depthfirst2( [Paragem | Caminho], ProxParagem,End,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.
  

/*

resolve_gulosa2(Partida, Destino,Caminho/Custo) :-
	estimativa_pre_existente(Partida,Destino ,Estimativa),
	agulosa2([[Partida]/0/Estimativa],Destino,InvCaminho/Custo/_),
	reverse(InvCaminho, Caminho).

agulosa2(Caminhos, Destino ,Caminho) :-
	obtem_melhor_g2(Caminhos, Caminho),
    Caminho = [Nodo|_]/_/_
    ,Nodo == Destino.

agulosa2(Caminhos, Destino ,SolucaoCaminho) :-
	obtem_melhor_g2(Caminhos,MelhorCaminho),
	seleciona2(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_gulosa2(MelhorCaminho, ExpCaminhos,Destino),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        agulosa2(NovoCaminhos,Destino ,SolucaoCaminho).	


expande_gulosa2(Caminho, ExpCaminhos, Destino) :-
    findall(NovoCaminho, adjacente2(Caminho,NovoCaminho,Destino), ExpCaminhos).


adjacente2([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est,Destino) :-
    adjacencia2(Nodo, ProxNodo, PassoCusto),\+ member(ProxNodo, Caminho),
    NovoCusto is Custo + PassoCusto,
    estimativa_pre_existente(ProxNodo,Destino ,Est).


seleciona2(E, [E|Xs], Xs).
seleciona2(E, [X|Xs], [X|Ys]) :- seleciona2(E, Xs, Ys).


obtem_melhor_g2([Caminho], Caminho) :- !.

obtem_melhor_g2([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Est1 =< Est2, !,
	obtem_melhor_g2([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
	
obtem_melhor_g2([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor_g2(Caminhos, MelhorCaminho).*/


%183,606
/*caminho(Comeco,Destino,Caminho):-
    caminhoAux(Comeco,[(Destino,"Fim")],Caminho).

%constroi o caminho a partir do fim
caminhoAux(Comeco,[(Comeco,Carreira),(Y,_)|T],[(Comeco,Carreira)|T]):-
    adjacencia(Comeco,Y,_,Carreira). 

caminhoAux(Comeco,[(Y,CarreiraSucessor)|T],P) :-
    adjacencia(ParagemPrevia,Y,_,Carreira), 
    write(ParagemPrevia),nl,
    \+ member((ParagemPrevia,_),[(Y,CarreiraSucessor)|T]), 
    caminhoAux(Comeco,[(ParagemPrevia,Carreira),(Y,CarreiraSucessor)|T],P).*/

/*

estima2(1,20).
estima2(2,10).
estima2(3,40).
estima2(4,1).
estima2(5,6).


move(1,2,3).
move(1,3,5).
move(3,5,15).
move(2,3,12).
move(1,4,1).
move(4,5,3).


goal(5).*/

goal(89).

quantas_estimativas(R):-
    findall((S),estimativa_pre_existente2(S,_),L),
    length(L,R).

assert_estimativa_previa2(Destino):-
    findall((GId),paragem(GId,_,_,_,_,_,_,_,_,_),ListaParagens),
    cria_estimativas2(ListaParagens,Destino).

cria_estimativas2([Gid|T],Destino):-
    paragem(Gid,Latitude1,Longitude1,_,_,_,_,_,_,_),
    paragem(Destino,Latitude2,Longitude2,_,_,_,_,_,_,_),
    distancia_euclidiana(Latitude1,Latitude2,Longitude1,Longitude2,Estimativa),
    assert(estimativa_pre_existente2(Gid,Estimativa)),
    cria_estimativas2(T,Destino).

cria_estimativas2([],_).

seleciona2(E, [E|Xs], Xs).
seleciona2(E, [X|Xs], [X|Ys]) :- seleciona2(E, Xs, Ys).

resolve_aestrela2(Nodo, Caminho/Custo) :-
    estimativa_pre_existente2(Nodo, Estima),
    aestrela2([[Nodo]/0/Estima], InvCaminho/Custo/_),
    reverse(InvCaminho, Caminho).

aestrela2(Caminhos, SolucaoCaminho) :-
    obtem_melhor2(Caminhos, MelhorCaminho),
    seleciona2(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrela2(MelhorCaminho, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela2(NovoCaminhos, SolucaoCaminho).	


expande_aestrela2(Caminho, ExpCaminhos) :-
    findall(NovoCaminho, move_aestrela2(Caminho,NovoCaminho), ExpCaminhos).

move_aestrela2([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est) :-
    adjacencia2(Nodo, ProxNodo, PassoCusto),\+ member(ProxNodo, Caminho),
    NovoCusto is Custo + PassoCusto,
    estimativa_pre_existente2(ProxNodo, Est).	
    

obtem_melhor2([Caminho], Caminho) :- !.

obtem_melhor2([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
    Custo1 + Est1 =< Custo2 + Est2, !, % custo 1 é a soma dos caminhos até aí
    obtem_melhor2([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
    
obtem_melhor2([_|Caminhos], MelhorCaminho) :- 
    obtem_melhor2(Caminhos, MelhorCaminho).


aestrela2(Caminhos, Caminho) :-
    obtem_melhor2(Caminhos, Caminho),
    Caminho = [Nodo|_]/_/_,goal(Nodo).
    