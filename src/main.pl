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






dfTodasSolucoes(L,Start,End):- findall((S),(resolve_df(Start,End,S,_)),L).





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