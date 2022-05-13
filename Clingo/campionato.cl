     %ogni squadra fa riferimento ad una città, che offre la struttura in cui la squadra gioca gli incontri in casa;
%TEAM(TEAM,CITY).
team(milan,milano).
team(inter,milano).
team(napoli,napoli).
team(juventus,torino).
team(roma,roma).
team(lazio,roma).
team(lazio,roma).
team(fiorentina,firenze).
team(atalanta,bergamo).
team(verona,verona).
team(torino,torino).
team(sassuolo,sassuolo).
team(udinese,udine).
team(bologna,bologna).
team(empoli,empoli).
team(sampdoria,genova).
team(spezia,spezia).
team(cagliari,cagliari).
team(salernitana,salerno).
team(genoa,genova).
team(venezia,venezia).
%il campionato prevede 38 giornate, 19 di andata e 19 di ritorno NON %simmetriche, ossia la giornata 1 di ritorno non coincide necessariamente con la %giornata 1 di andata a campi invertiti; 

giornata(1..38).



1 {assegna(S,G):giornata(G)} 1:-team(S,_).


%ogni giornata deve avere 10 in cui 20 squadre affrontano insieme  
10{game(S1,S2,G):team(S1,_),team(S2,_), S1<>S2}10:-giornata(G).



%non è possibile che la stessa partita si disputi in giornata diverse
:- game(S1,S2,G), game(S1,S2,G2), G != G2.



%due squadre della stessa città condividono la stessa struttura di gioco, quindi,non possono giocare entrambe in casa nella stessa giornata;
:- game(S1,C,G), game(S2,C,G), S1 != S2, team(S1,C), team(S2,C).


% una squadra non può giocare più di due partite consecutive in casa
:- game(S,_,G), game(S,_,G+1), game(S,_,G+2).


% una squadra non può giocare più di due partite consecutive in trasferta
:- game(_,S,G), game(_,S,G+1), game(_,C,G+2).

%non è possibile che una squadra affronti due volte un'altra squadra nelle prime 3 giornate
:- game(S1,S2,G), game(S2,S1,G1), G <= 19, G1 <= 19.


#show game/3.