%sono iscritte 20 squadre
teams(milan,inter,napoli,juventus,roma,
lazio,fiorentina,atalanta,verona,torino,sassuolo,udinese,
bologna,empoli,sampdoria,spezia,cagliari,salernitana,genoa,venezia).


%ogni squadra fa riferimento ad una città, che offre la struttura in cui la squadra
%gioca gli incontri in casa;
in(milan,milano).
in(inter,milano).
in(napoli,napoli).
in(juventus,torino).
in(roma,roma).
in(lazio,roma).
in(fiorentina,firenze).
in(atalanta,bergamo).
in(verona,verona).
in(torino,torino).
in(sassuolo,sassuolo).
in(udinese,udine).
in(bologna,bologna).
in(empoli,empoli).
in(sampdoria,genova).
in(spezia,spezia).
in(cagliari,cagliari).
in(salernitana,salerno).
in(genoa,genova).
in(venezia,venezia).
%il campionato prevede 38 giornate, 19 di andata e 19 di ritorno NON
%simmetriche, ossia la giornata 1 di ritorno non coincide necessariamente con la
%giornata 1 di andata a campi invertiti; 
firstleg(1..19).
secondleg(1..19).

%all giornata have 10 games 
10{game(Hometeam,Guestteam,FL):teams(Hometeam),teams(Guestteam), Hometeam<>Guestteam}10:-firstleg(FL).
10{game(Hometeam,Guestteam,SL):teams(Hometeam),teams(Guestteam), Hometeam<>Guestteam}10:-secondleg(SL).

