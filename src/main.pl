use_module(library(csv)).


pai(a,b).

load_info():-  
    csv_read_file('dataset/paragens_encoding_correto.csv', Data, [functor(fact), separator(0';),arity(12),match_arity(false)]),
    maplist(funcao_auxiliar, Data).

funcao_auxiliar(fact(A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12)):-
    %write(fact(A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12)),
    write(A9),
    write("\n").


distancia_euclidiana(X1,X2,Y1,Y2, R):- R is sqrt((X2-X1)^2 + (Y2-Y1)^2).