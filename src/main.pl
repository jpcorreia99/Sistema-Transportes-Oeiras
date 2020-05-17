:-include("base_de_informacao.pl").


% 01: 183->182
% 01-> 02: 78 -> 147

%ex 1           
resolve_df( Comeco, Destino ,Solucao,Distancia)  :-
    depthfirst( [], Comeco, Destino,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao).

  

depthfirst( Caminho, Paragem, Destino, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
        adjacencia(Paragem,Destino,Distancia,Carreira).


depthfirst( Caminho, Paragem, End, Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    write(ProxParagem),nl,
    \+ member( ProxParagem, Caminho),
    depthfirst( [(Paragem,Carreira) | Caminho], ProxParagem,End,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.
  

%ex2 Selecionar apenas algumas paragens

%183->182 : Vimeca

resolve_df_seleciona_operadores( Comeco, Destino,ListaOperadores ,Solucao,Distancia)  :-
    depth_first_seleciona_operadores( [], Comeco, Destino,ListaOperadores,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao).

  

depth_first_seleciona_operadores( Caminho, Paragem, Destino,ListaOperadores, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
        adjacencia(Paragem,Destino,Distancia,Carreira),
        paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
        member(Operador,ListaOperadores).


depth_first_seleciona_operadores( Caminho, Paragem, End,ListaOperadores,Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
    member(Operador,ListaOperadores),
    write(ProxParagem),nl,
    \+ member( ProxParagem, Caminho),
    depth_first_seleciona_operadores([(Paragem,Carreira) | Caminho], ProxParagem,End,ListaOperadores,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.



%ex3 Não escolher certas paragens

%183->182 : Vimeca

resolve_df_exclui_operadores( Comeco, Destino,ListaOperadores ,Solucao,Distancia)  :-
    depth_first_exclui_operadores( [], Comeco, Destino,ListaOperadores,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao).

  

depth_first_exclui_operadores( Caminho, Paragem, Destino,ListaOperadores, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
        adjacencia(Paragem,Destino,Distancia,Carreira),
        paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
        \+ member(Operador,ListaOperadores).


depth_first_exclui_operadores( Caminho, Paragem, End,ListaOperadores,Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
    \+ member(Operador,ListaOperadores),
    write(ProxParagem),nl,
    \+ member( ProxParagem, Caminho),
    depth_first_exclui_operadores([(Paragem,Carreira) | Caminho], ProxParagem,End,ListaOperadores,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.



%ex 4
identifica_maior_carreiras(Comeco, Destino,Solucao,Distancia,ListaOrdenadaPorNumeroDeCarreiras):-
    depthfirst( [], Comeco, Destino,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    maplist(converte_tuplo_para_n_carreiras, Solucao,ListaASerOrdenada),
    sort(2,  @>=, ListaASerOrdenada,  ListaOrdenadaPorNumeroDeCarreiras).
    
    

%em vez de usar o csv das paragens é melhor contar a quantas outras paragens uma paragem está diretamente ligada
quantas_carreiras(GID,NumeroCarreiras):- findall((GID),(adjacencia(GID,_,_,_)),L),
                            length(L,NumeroCarreiras).


converte_tuplo_para_n_carreiras((GID,_),(GID,NCarreiras)):-
    quantas_carreiras(GID,NCarreiras).

                        






%goal(182).

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





/*
adjacencia(183,791,87.63541293336934,1).
adjacencia(791,595,87.63541293336934,1).
adjacencia(595,182,421.9863463431075,1).
adjacencia(182,499,2003.3340491291042,1).

paragem(183,-103678.36,-96590.26,'Bom','Fechado dos Lados','Yes','Vimeca',286,'Rua Aquilino Ribeiro','Carnaxide e Queijas').
paragem(791,-103705.46,-96673.6,'Bom','Fechado dos Lados','Yes','Vimeca',286,'Rua Aquilino Ribeiro','Carnaxide e Queijas').
paragem(595,-103725.69,-95975.2,'Bom','Fechado dos Lados','Yes','Vimeca',286,'Rua Aquilino Ribeiro','Carnaxide e Queijas').
paragem(182,-103746.76,-96396.66,'Bom','Fechado dos Lados','Yes','Vimeca',286,'Rua Aquilino Ribeiro','Carnaxide e Queijas').
paragem(499,-103758.44,-94393.36,'Bom','Fechado dos Lados','Yes','Vimeca',286,'Rua Aquilino Ribeiro','Carnaxide e Queijas').*/


%goal(499).

% hipóteses
% apenas inserir adjacencia(X,Y,Custo)
% dar assert das estimativas de todos os novos ao nodo e depois remove para poupar chamadas na altura de avalair

resolve_aestrela(Nodo, Destino,Caminho/Custo) :-
	estima(Nodo, Destino,Estima),
	aestrela([[Nodo]/0/Estima],Destino ,InvCaminho/Custo/_),
	reverse(InvCaminho, Caminho).

aestrela(Caminhos,Destino,SolucaoCaminho) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela(MelhorCaminho,Destino,ExpCaminhos),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
	aestrela(NovoCaminhos,Destino ,SolucaoCaminho).	

aestrela(Caminhos,Destino ,Caminho) :-
        obtem_melhor(Caminhos, Caminho),
        Caminho = [Node|_]/_/_,
        Node == Destino.

expande_aestrela(Caminho,Destino ,ExpCaminhos) :-
	findall(NovoCaminho, move_aestrela(Caminho,Destino,NovoCaminho), ExpCaminhos).

move_aestrela([Nodo|Caminho]/Custo/_,Destino ,[ProxNodo,Nodo|Caminho]/NovoCusto/Est) :-
	adjacencia(Nodo, ProxNodo, PassoCusto,_),\+ member(ProxNodo, Caminho),
	NovoCusto is Custo + PassoCusto,
	estima(ProxNodo,Destino ,Est).	
	

obtem_melhor([Caminho], Caminho) :- !.

obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Custo1 + Est1 =< Custo2 + Est2, !, % custo 1 é a soma dos caminhos até aí
	obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
	
obtem_melhor([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor(Caminhos, MelhorCaminho).


