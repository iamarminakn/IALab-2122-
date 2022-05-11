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
gironeAndata(1..19).
gironeRitorna(20..38).

%all giornata have 10 games 
1{game(S1,S2,G):team(S1,_),team(S2,_), S1<>S2}1:-gironeAndata(G).
1{game(S1,S2,G):team(S1,_),team(S2,_), S1<>S2}1:-gironeRitorna(G).



%due squadre della stessa città condividono la stessa struttura di gioco, quindi,non possono giocare entrambe in casa nella stessa giornata;
:- game(S1,G), game(S2,G), S1 != S2, teams(S1,C), teams(S2,C).


#show game/3.