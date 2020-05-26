hora_do_dia(Hora,DiaDaSemana) :-    
    get_time(TimeStamp),
    stamp_date_time(TimeStamp, DateTime, local),
    date_time_value(hour, DateTime, Hora),
    date_time_value(date, DateTime, Data).

    

% Data uma hora do dia, devolve a velocidade média dos transportes públicos a esssa hora
%hora de pico
% usados dados de Boston que reportam uma queda de 40%
% https://www.geotab.com/gridlocked-cities/#

%Dias da semana
%hora de ponta
%velocidade em metros/h para facilitar calculos
velocidade_media(Hora,DiaDaSemana,30000):-
    member(DiaDaSemana,[1,2,3,4,5]), %um dia da semana de trabalho
    member(Hora,[8,9,17,18]).
    %VelocidadeMedia is 30000.

%horas com elevado tráfego
velocidade_media(Hora,DiaDaSemana,35000):-
    member(DiaDaSemana,[1,2,3,4,5]), %um dia da semana de trabalho
    member(Hora,[10,13,14,16,19]).
    %VelocidadeMedia is 35000.

%fim de semana em hora de ponta
velocidade_media(Hora,DiaDaSemana,40000):-
    member(DiaDaSemana,[6,7]), %um dia ddo fim de semana
    member(Hora,[8,9,16,17,18]). %na hora de ponta a velocidade desce um pouco mas não tanto como nos dias úteis
   % VelocidadeMedia is 40000.
% no resto das hpras
velocidade_media(Hora,DiaDaSemana,45000):- %45
    (( member(DiaDaSemana,[1,2,3,4,5]),
    \+ member(Hora,[8,9,10,13,14,16,17,18,19]));
    (member(DiaDaSemana,[6,7]),
    \+ member(Hora,[8,9,16,17,18]))).
   % VelocidadeMedia is 45000.


%calcula quanto tempo demora a percorrer a dada distância
distancia_para_tempo(Distancia,(Horas,Minutos)):-
    hora_do_dia(Hora,DiaDaSemana),
    velocidade_media(Hora,DiaDaSemana,VelocidadeMedia),
    DistanciaArredondada is round(Distancia),
    Horas is DistanciaArredondada//VelocidadeMedia,
    DistanciaRestante is DistanciaArredondada - Horas*VelocidadeMedia,
    Minutos is round((60*DistanciaRestante)/VelocidadeMedia).
