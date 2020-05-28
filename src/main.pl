:-include("base_de_informacao.pl").
:-include("predicados_auxiliares").

% 01: 183->182
% 01-> 02: 78 -> 147


% METER CARREIRAS NOS DOIS SENTIDOS
%Nota: os algoritmos de usar abrigado e com publicidade ignoram
%ex 1           
resolve_df( Comeco, Destino ,Solucao,Distancia,Tempo)  :-
    depthfirst( [], Comeco, Destino,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    distancia_para_tempo(Distancia,Tempo).


depthfirst( Caminho, Paragem, Destino, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
        adjacencia(Paragem,Destino,Distancia,Carreira).


depthfirst( Caminho, Paragem, Destino, Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    \+ member( (ProxParagem,_), Caminho),
    depthfirst( [(Paragem,Carreira) | Caminho], ProxParagem,Destino,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.
  

%ex2 Selecionar apenas algumas paragens

%183->182 : Vimeca

resolve_df_seleciona_operadores( Comeco, Destino,ListaOperadores ,Solucao,Distancia,Tempo)  :-
    depth_first_seleciona_operadores( [], Comeco, Destino,ListaOperadores,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    distancia_para_tempo(Distancia,Tempo).

  

depth_first_seleciona_operadores( Caminho, Paragem, Destino,ListaOperadores, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
        adjacencia(Paragem,Destino,Distancia,Carreira),
        paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
        member(Operador,ListaOperadores).


depth_first_seleciona_operadores( Caminho, Paragem, End,ListaOperadores,Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
    write(ProxParagem),nl,
    member(Operador,ListaOperadores),
    \+ member( ProxParagem, Caminho),
    depth_first_seleciona_operadores([(Paragem,Carreira) | Caminho], ProxParagem,End,ListaOperadores,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.



%ex3 Não escolher certas paragens

%183->182 : Vimeca

resolve_df_exclui_operadores( Comeco, Destino,ListaOperadores ,Solucao,Distancia,Tempo)  :-
    depth_first_exclui_operadores( [], Comeco, Destino,ListaOperadores,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    distancia_para_tempo(Distancia,Tempo).

  

depth_first_exclui_operadores( Caminho, Paragem, Destino,ListaOperadores, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
        adjacencia(Paragem,Destino,Distancia,Carreira),
        paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
        \+ member(Operador,ListaOperadores).


depth_first_exclui_operadores( Caminho, Paragem, End,ListaOperadores,Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
    \+ member(Operador,ListaOperadores),
    \+ member( ProxParagem, Caminho),
    depth_first_exclui_operadores([(Paragem,Carreira) | Caminho], ProxParagem,End,ListaOperadores,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.



%ex 4
identifica_maior_carreiras(Comeco, Destino,Solucao,Distancia,ListaOrdenadaPorNumeroDeCarreiras,Tempo):-
    depthfirst( [], Comeco, Destino,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    maplist(converte_tuplo_para_n_carreiras, Solucao,ListaASerOrdenada),
    sort(2,  @>=, ListaASerOrdenada,  ListaOrdenadaPorNumeroDeCarreiras),
    distancia_para_tempo(Distancia,Tempo).
    
    

%em vez de usar o csv das paragens é melhor contar a quantas outras paragens uma paragem está diretamente ligada
quantas_carreiras(GID,NumeroCarreiras):- findall((GID),(adjacencia(GID,_,_,_)),L),
                            length(L,NumeroCarreiras).


converte_tuplo_para_n_carreiras((GID,_),(GID,NCarreiras)):-
    quantas_carreiras(GID,NCarreiras).


% ex5 
% DF 

menor_caminho_distancia(Comeco, Destino,MenorCaminho,Distancia,Tempo):-
    findall((Solucao,Distancia),resolve_df2(Comeco,Destino,Solucao,Distancia),L),
    sort(2,  @<, L,  ListaOrdenadaPorDistancia),
    nth0(0,ListaOrdenadaPorDistancia,(MenorCaminho,Distancia)),
    distancia_para_tempo(Distancia,Tempo).


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



% A*
seleciona2(E, [E|Xs], Xs).
seleciona2(E, [X|Xs], [X|Ys]) :- seleciona2(E, Xs, Ys).

resolve_aestrela(Nodo, Destino, Caminho,Custo,Tempo) :-
    estima(Nodo,Destino,Estima),
    aestrela2([[Nodo]/0/Estima], Destino,InvCaminho/Custo/_),
    reverse(InvCaminho, Caminho),    
    distancia_para_tempo(Custo,Tempo).

aestrela2(Caminhos,Destino, SolucaoCaminho) :-
    obtem_melhor2(Caminhos, MelhorCaminho),
    seleciona2(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrela2(MelhorCaminho, Destino,ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela2(NovoCaminhos, Destino,SolucaoCaminho).	


aestrela2(Caminhos,Destino, Caminho) :-
    obtem_melhor2(Caminhos, Caminho),
    Caminho = [Nodo|_]/_/_,
    Nodo==Destino.

expande_aestrela2(Caminho,Destino, ExpCaminhos) :-
    findall(NovoCaminho, move_aestrela2(Caminho,Destino,NovoCaminho), ExpCaminhos).

move_aestrela2([Nodo|Caminho]/Custo/_, Destino,[ProxNodo,Nodo|Caminho]/NovoCusto/Est) :-
    adjacencia2(Nodo, ProxNodo, PassoCusto),\+ member(ProxNodo, Caminho),
    NovoCusto is Custo + PassoCusto,
    estima(ProxNodo,Destino,Est).	
    

obtem_melhor2([Caminho], Caminho) :- !.

obtem_melhor2([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
    Custo1 + Est1 > Custo2 + Est2, !, % custo 1 é a soma dos caminhos até aí
    obtem_melhor2([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
    
obtem_melhor2([_|Caminhos], MelhorCaminho) :- 
    obtem_melhor2(Caminhos, MelhorCaminho).



% Greedy search

resolve_gulosa(Partida, Destino,Caminho,Custo,Tempo) :-
	estima(Partida,Destino ,Estimativa),
	agulosa([[Partida]/0/Estimativa],Destino,InvCaminho/Custo/_),
    reverse(InvCaminho, Caminho),
    distancia_para_tempo(Custo,Tempo).

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
    adjacencia2(Nodo, ProxNodo, PassoCusto),\+ member(ProxNodo, Caminho),
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

%ex 6

menor_caminho_paragens(Comeco, Destino,MenorCaminho,DistanciaCaminho,Tempo,NumeroParagens):-
    findall((Solucao,Distancia),resolve_df2(Comeco,Destino,Solucao,Distancia),L),
    maplist(adiciona_numero_paragens,L,ListaComNumeroParagens),
    sort(2,  @<, ListaComNumeroParagens,  ListaOrdenadaPorDistancia),
    nth0(0,ListaOrdenadaPorDistancia,(MenorCaminho,DistanciaCaminho,NumeroParagens)),
    distancia_para_tempo(DistanciaCaminho,Tempo).

adiciona_numero_paragens((Caminho,Distancia),(Caminho,Distancia,NParagens)):-
    length(Caminho,NParagens).


%ex 7

resolve_df_com_publicidade(Comeco,Destino,Solucao,Distancia,Tempo):-
    depth_first_publicidade( [], Comeco, Destino,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    distancia_para_tempo(Distancia,Tempo).


depth_first_publicidade( Caminho, Paragem, Destino, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
    adjacencia(Paragem,Destino,Distancia,Carreira).


depth_first_publicidade( Caminho, Paragem, End, Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    paragem(ProxParagem,_,_,_,_,'Yes',_,_,_,_),
    \+ member( ProxParagem, Caminho),
    depth_first_publicidade( [(Paragem,Carreira) | Caminho], ProxParagem,End,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.
  


%ex 8 
resolve_df_abrigos(Comeco,Destino,Solucao,Distancia,Tempo):-
    depth_first_abrigos( [], Comeco, Destino,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    distancia_para_tempo(Distancia,Tempo).


depth_first_abrigos( Caminho, Paragem, Destino, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
    adjacencia(Paragem,Destino,Distancia,Carreira).


depth_first_abrigos( Caminho, Paragem, Destino, Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    paragem(ProxParagem,_,_,_,TipoAbrigo,_,_,_,_,_),
    member(TipoAbrigo,['Aberto dos Lados','Fechado dos Lados']),
    \+ member( ProxParagem, Caminho),
    depth_first_abrigos( [(Paragem,Carreira) | Caminho], ProxParagem,Destino,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.


%ex 9
contem_paragens([Paragem|T],Caminho):-
    member((Paragem,_),Caminho),
    contem_paragens(T,Caminho).

contem_paragens([],_).

resolve_df_com_paragens(Comeco,Destino,Paragens,Solucao,Distancia,Tempo):-
    depthfirst( [], Comeco, Destino,SolucaoInvertida,Distancia),
    contem_paragens(Paragens,SolucaoInvertida),
    reverse(SolucaoInvertida,Solucao),
    distancia_para_tempo(Distancia,Tempo).




%goal(182).






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






%183,606
%ex1
caminho_novo(Comeco,Destino,Caminho,Distancia,Tempo):-
    caminho_novo_aux(Comeco,0,[(Destino,"Fim")],Caminho,Distancia),
    distancia_para_tempo(Distancia,Tempo).

%constroi o caminho a partir do fim
%caso base em que já chegou ao inicio
caminho_novo_aux(Comeco,AcumuladorDistancia,[(Comeco,Carreira),(NodoAtual,CarreiraAtual)|T],
                [(Comeco,Carreira),(NodoAtual,CarreiraAtual)|T],AcumuladorDistancia):-
    adjacencia(Comeco,NodoAtual,_,Carreira).

caminho_novo_aux(Comeco,AccDistancia,[(ParagemAtual,CarreiraAtual)|T],P,Distancia) :-
    adjacencia(ParagemPrevia,ParagemAtual,DistanciaParagem,Carreira), 
    write(ParagemPrevia),write(" "),write(DistanciaParagem),nl,
    \+ member((ParagemPrevia,_),[(ParagemAtual,CarreiraAtual)|T]), 
    NovaDistancia is AccDistancia + DistanciaParagem,
    caminho_novo_aux(Comeco,NovaDistancia,[(ParagemPrevia,Carreira),(ParagemAtual,CarreiraAtual)|T],P,Distancia).


%ex2

caminho_operadores(Comeco,Destino,ListaOperadores,Caminho,Distancia,Tempo):-
    caminho_operadores_aux(Comeco,0,ListaOperadores,[(Destino,"Fim")],Caminho,Distancia),
     distancia_para_tempo(Distancia,Tempo).


caminho_operadores_aux(Comeco,AcumuladorDistancia,ListaOperadores,[(Comeco,Carreira),(NodoSeguinte,CarreiraSeguinte)|T],
                [(Comeco,Carreira),(NodoSeguinte,CarreiraSeguinte)|T],AcumuladorDistancia):-
    adjacencia(Comeco,NodoSeguinte,_,Carreira),
    paragem(NodoSeguinte,_,_,_,_,_,Operador,_,_,_),
    member(Operador,ListaOperadores).

caminho_operadores_aux(Comeco,AccDistancia,ListaOperadores,[(Y,CarreiraSucessor)|T],P,Distancia) :-
    adjacencia(ParagemPrevia,Y,DistanciaParagem,Carreira), 
    paragem(Y,_,_,_,_,_,Operador,_,_,_),
    member(Operador,ListaOperadores),
    \+ member((ParagemPrevia,_),[(Y,CarreiraSucessor)|T]), 
    NovaDistancia is AccDistancia + DistanciaParagem,
    caminho_operadores_aux(Comeco,NovaDistancia,ListaOperadores,[(ParagemPrevia,Carreira),(Y,CarreiraSucessor)|T],P,Distancia).


% ex3

caminho_exclui_operadores(Comeco,Destino,ListaOperadores,Caminho,Distancia,Tempo):-
    caminho_exclui_operadores_aux(Comeco,0,ListaOperadores,[(Destino,"Fim")],Caminho,Distancia),
     distancia_para_tempo(Distancia,Tempo).


caminho_exclui_operadores_aux(Comeco,AcumuladorDistancia,ListaOperadores,[(Comeco,Carreira),(NodoSeguinte,CarreiraSeguinte)|T],
                [(Comeco,Carreira),(NodoSeguinte,CarreiraSeguinte)|T],AcumuladorDistancia):-
    adjacencia(Comeco,NodoSeguinte,_,Carreira),
    paragem(NodoSeguinte,_,_,_,_,_,Operador,_,_,_),
    \+ member(Operador,ListaOperadores).

caminho_exclui_operadores_aux(Comeco,AccDistancia,ListaOperadores,[(ParagemAtual,CarreiraAtual)|T],P,Distancia) :-
    adjacencia(ParagemPrevia,ParagemAtual,DistanciaParagem,Carreira), 
    paragem(ParagemAtual,_,_,_,_,_,Operador,_,_,_),
    \+ member(Operador,ListaOperadores),
    \+ member((ParagemPrevia,_),[(ParagemAtual,CarreiraAtual)|T]), 
    NovaDistancia is AccDistancia + DistanciaParagem,
    caminho_exclui_operadores_aux(Comeco,NovaDistancia,ListaOperadores,[(ParagemPrevia,Carreira),(ParagemAtual,CarreiraAtual)|T],P,Distancia).


%ex4 
caminho_maior_carreiras(Comeco, Destino,Caminho,Distancia,ListaOrdenadaPorNumeroDeCarreiras,Tempo):-
    caminho_novo_aux(Comeco,0,[(Destino,"Fim")],Caminho,Distancia),
    maplist(converte_tuplo_para_n_carreiras, Caminho,ListaASerOrdenada),
    sort(2,  @>=, ListaASerOrdenada,  ListaOrdenadaPorNumeroDeCarreiras),
    distancia_para_tempo(Distancia,Tempo).


%ex 7
caminho_com_publicidade(Comeco,Destino,Caminho,Distancia,Tempo):-
    caminho_com_publicidade_aux(Comeco,0,[(Destino,"Fim")],Caminho,Distancia),
    distancia_para_tempo(Distancia,Tempo).

%constroi o caminho a partir do fim
%caso base em que já chegou ao inicio
caminho_com_publicidade_aux(Comeco,AcumuladorDistancia,[(Comeco,Carreira),(NodoAtual,CarreiraAtual)|T],
                [(Comeco,Carreira),(NodoAtual,CarreiraAtual)|T],AcumuladorDistancia):-
    adjacencia(Comeco,NodoAtual,_,Carreira).

caminho_com_publicidade_aux(Comeco,AccDistancia,[(ParagemAtual,CarreiraAtual)|T],P,Distancia) :-
    adjacencia(ParagemPrevia,ParagemAtual,DistanciaParagem,Carreira), 
    paragem(ParagemPrevia,_,_,_,_,'Yes',_,_,_,_),
    \+ member((ParagemPrevia,_),[(ParagemAtual,CarreiraAtual)|T]), 
    NovaDistancia is AccDistancia + DistanciaParagem,
    caminho_com_publicidade_aux(Comeco,NovaDistancia,[(ParagemPrevia,Carreira),(ParagemAtual,CarreiraAtual)|T],P,Distancia).

%ex 8 
caminho_com_abrigos(Comeco,Destino,Caminho,Distancia,Tempo):-
    caminho_com_publicidade_aux(Comeco,0,[(Destino,"Fim")],Caminho,Distancia),
    distancia_para_tempo(Distancia,Tempo).

%constroi o caminho a partir do fim
%caso base em que já chegou ao inicio
caminho_com_abrigos_aux(Comeco,AcumuladorDistancia,[(Comeco,Carreira),(NodoAtual,CarreiraAtual)|T],
                [(Comeco,Carreira),(NodoAtual,CarreiraAtual)|T],AcumuladorDistancia):-
    adjacencia(Comeco,NodoAtual,_,Carreira).

caminho_com_abrigos_aux(Comeco,AccDistancia,[(ParagemAtual,CarreiraAtual)|T],P,Distancia) :-
    adjacencia(ParagemPrevia,ParagemAtual,DistanciaParagem,Carreira), 
    paragem(ParagemPrevia,_,_,_,TipoAbrigo,_,_,_,_,_),
    member(TipoAbrigo,['Aberto dos Lados','Fechado dos Lados']),
    \+ member((ParagemPrevia,_),[(ParagemAtual,CarreiraAtual)|T]), 
    NovaDistancia is AccDistancia + DistanciaParagem,
    caminho_com_abrigos_aux(Comeco,NovaDistancia,[(ParagemPrevia,Carreira),(ParagemAtual,CarreiraAtual)|T],P,Distancia).

%ex9
caminho_com_paragens(Comeco,Destino,Paragens,Caminho,Distancia,Tempo):-
    caminho_novo_aux(Comeco,0,[(Destino,"Fim")],Caminho,Distancia),
    contem_paragens(Paragens,Caminho),
    distancia_para_tempo(Distancia,Tempo).