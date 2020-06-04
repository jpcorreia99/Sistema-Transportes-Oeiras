:-include("base_de_informacao.pl").
:-include("predicados_auxiliares").

% 01: 183->182
% 01-> 02: 78 -> 147

% set_prolog_stack(global, limit(10 000 000 000)).
/*caminho_depth_first(583,732,S,D,T).
caminho_depth_first(583,178,S,D,T).
caminho_depth_first(583,817,S,D,T).
caminho_depth_first(583,1009,S,D,T). 
caminho_depth_first(97,526,S,D,T). 
caminho_depth_first(583,712,S,D,T).  // inverter para o bf
caminho_depth_first(583,59,S,D,T).*/

%ex 1           
caminho_depth_first( Comeco, Destino ,Solucao,Distancia,Tempo)  :-
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
%resolve_df_seleciona_operadores(183,182,['Vimeca','SCoTTURB'],H,J,K).
resolve_df_seleciona_operadores( Comeco, Destino,ListaOperadores ,Solucao,Distancia,Tempo)  :-
    depth_first_seleciona_operadores( [], Comeco, Destino,ListaOperadores,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    distancia_para_tempo(Distancia,Tempo).

  

depth_first_seleciona_operadores( Caminho, Paragem, Destino,ListaOperadores, [(Destino,"Fim"), (Paragem,Carreira) | Caminho],Distancia):-
        adjacencia(Paragem,Destino,Distancia,Carreira),
        paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
        member(Operador,ListaOperadores).


depth_first_seleciona_operadores( Caminho, Paragem, Destino,ListaOperadores,Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    paragem(ProxParagem,_,_,_,_,_,Operador,_,_,_),
    member(Operador,ListaOperadores),
    \+ member( (ProxParagem,_), Caminho),
    depth_first_seleciona_operadores([(Paragem,Carreira) | Caminho], ProxParagem,Destino,ListaOperadores,Solucao,DistanciaAcumulada),
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


depth_first_exclui_operadores( Caminho, Paragem, Destino,ListaOperadores,Solucao,Distancia)  :-
    adjacencia( Paragem, ProxParagem,DistanciaParagem,Carreira),
    paragem(Paragem,_,_,_,_,_,Operador,_,_,_),
    \+ member(Operador,ListaOperadores),
    \+ member( (ProxParagem,_), Caminho),
    depthfirst( [(Paragem,Carreira) | Caminho], ProxParagem,Destino,Solucao,DistanciaAcumulada),
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


%ex 5

menor_caminho_paragens(Comeco, Destino,MenorCaminho,DistanciaCaminho,Tempo,NumeroParagens):-
    findall((Solucao,Distancia),resolve_df2(Comeco,Destino,Solucao,Distancia),L),
    maplist(adiciona_numero_paragens,L,ListaComNumeroParagens),
    sort(2,  @<, ListaComNumeroParagens,  ListaOrdenadaPorDistancia),
    nth0(0,ListaOrdenadaPorDistancia,(MenorCaminho,DistanciaCaminho,NumeroParagens)),
    distancia_para_tempo(DistanciaCaminho,Tempo).

adiciona_numero_paragens((Caminho,Distancia),(Caminho,Distancia,NParagens)):-
    length(Caminho,NParagens).


% ex6
% DF 
% 183, 609
% set_prolog_stack(global, limit(100 00 000 000)).

menor_caminho_distancia(Comeco, Destino,MenorCaminho,Distancia,Tempo):-
    statistics(runtime,[Start|_]),
    findall((Solucao,Distancia),resolve_df2(Comeco,Destino,Solucao,Distancia),L),
    sort(2,  @<, L,  ListaOrdenadaPorDistancia),
    nth0(0,ListaOrdenadaPorDistancia,(MenorCaminho,Distancia)),
    distancia_para_tempo(Distancia,Tempo),
    statistics(runtime,[Stop|_]),
    Runtime is Stop-Start,
    write("Tempo: "),write(Runtime).


resolve_df2( Comeco, Destino ,Solucao,Distancia)  :-
    depthfirst2( [], Comeco, Destino,Solucao,Distancia).
   % reverse(SolucaoInvertida,Solucao).


depthfirst2( Caminho, Paragem, Destino, [Destino, Paragem | Caminho],Distancia):-
    adjacencia2(Paragem,Destino,DistanciaParagem),
    Distancia = DistanciaParagem.

depthfirst2( Caminho, Paragem, End, Solucao,Distancia)  :-
    adjacencia2( Paragem, ProxParagem,DistanciaParagem),
    \+ member( ProxParagem, Caminho),
    depthfirst2( [Paragem | Caminho], ProxParagem,End,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.




% A*
seleciona2(E, [E|Xs], Xs).
seleciona2(E, [X|Xs], [X|Ys]) :- seleciona2(E, Xs, Ys).

resolve_aestrela(Nodo, Destino, Caminho,Custo,Tempo) :-
    statistics(runtime,[Start|_]),
    estima(Nodo,Destino,Estima),
    aestrela2([[Nodo]/0/Estima], Destino,InvCaminho/Custo/_),
    reverse(InvCaminho, Caminho),    
    distancia_para_tempo(Custo,Tempo),
    statistics(runtime,[Stop|_]),
    Runtime is Stop-Start,
    write("Tempo: "),write(Runtime).

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
    Custo1 + Est1 >= Custo2 + Est2, !, % custo 1 é a soma dos caminhos até aí
    obtem_melhor2([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
    
obtem_melhor2([_|Caminhos], MelhorCaminho) :- 
    obtem_melhor2(Caminhos, MelhorCaminho).



% Greedy search

resolve_gulosa(Partida, Destino,Caminho,Custo,Tempo) :-
    statistics(runtime,[Start|_]),
	estima(Partida,Destino ,Estimativa),
	agulosa([[Partida]/0/Estimativa],Destino,InvCaminho/Custo/_),
    reverse(InvCaminho, Caminho),
    distancia_para_tempo(Custo,Tempo),
    statistics(runtime,[Stop|_]),
    Runtime is Stop-Start,
    write("Tempo: "),write(Runtime).

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

obtem_melhor_g([Caminho1/Custo1/Est1,_/_/Est2|Caminhos], MelhorCaminho) :-
	Est1 =< Est2, !,
	obtem_melhor_g([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
	
obtem_melhor_g([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor_g(Caminhos, MelhorCaminho).


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
    \+ member( (ProxParagem,_), Caminho),
    depth_first_publicidade( [(Paragem,Carreira) | Caminho], ProxParagem,End,Solucao,DistanciaAcumulada),
    Distancia is DistanciaParagem + DistanciaAcumulada.
  


%ex 8 
% 262,513
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
    \+ member( (ProxParagem,_), Caminho),
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




% extra: Devolve a lista das frguesias por onde passa
%183->487
resolve_df_lista_ruas_e_freguesias(Comeco,Destino,Solucao,Distancia,Tempo,ListaRuas,ListaFreguesias):-
    depthfirst( [], Comeco, Destino,SolucaoInvertida,Distancia),
    reverse(SolucaoInvertida,Solucao),
    distancia_para_tempo(Distancia,Tempo),
    cria_lista_ruas_e__Freguesias(Solucao,ListaRuasComDuplicados,ListaFreguesiasComDuplicados),
    sort(ListaFreguesiasComDuplicados,ListaFreguesias),
    sort(ListaRuasComDuplicados,ListaRuas).



cria_lista_ruas_e__Freguesias([(Paragem,_)|T],[Rua|T2],[Freguesia|T3]):-
    paragem(Paragem,_,_,_,_,_,_,_,Rua,Freguesia),
    cria_lista_ruas_e__Freguesias(T,T2,T3).

cria_lista_ruas_e__Freguesias([],[],[]).

%goal(182).




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


%breadth_first


breadth_first( Comeco, Destino, Caminho,Distancia,Tempo):- 
    breadth_first_aux( Destino, [[Comeco]], Caminho),
    calcula_distancia_caminho(Caminho,Distancia),
    distancia_para_tempo(Distancia,Tempo).



breadth_first_aux(Destino, [[Destino|Visitados]|_], Path):- 
    Visitados = [Start|_], 
    adjacencia2(Start,Destino,_),  
    reverse([Destino|Visitados], Path).

breadth_first_aux( Destino, [Visitados|Restantes], Path) :-                     % take one from front
    Visitados = [Start|_],            
    Start \== Destino,
    findall( X,
        ( adjacencia2(Start,X,_), \+ member(X, Visitados) ),
        [T|Extendido]),
    maplist( adiciona_queue(Visitados), [T|Extendido], VisitadosExtendido),      % make many
    append( Restantes, VisitadosExtendido, QueueAtualizada),   % put them at the end
    breadth_first_aux( Destino, QueueAtualizada, Path ).


adiciona_queue( A, B, [B|A]).


calcula_distancia_caminho([Gid1,Gid2|T],Distancia):-
    adjacencia2(Gid1,Gid2,DistanciaLigacao),
    calcula_distancia_caminho([Gid2|T],DistanciaAcumulada),
    Distancia is DistanciaLigacao + DistanciaAcumulada.
  
calcula_distancia_caminho([_],0).
calcula_distancia_caminho([],0).