:- dynamic fine2/1, final/1, finale/1, uguale/2, trasforma/3, applicabile/2, fine/1, inizio/1.
%ricerca in profondita
solution(Solution):-
    inizio(S),
    solve(S,[],Solution).

solve(S,_,[]):- fine(S),!.

solve(S,Visitati,[Op|Resto]):-
    
    applicabile(Op,S),
    trasforma(Op,S,Nuovo_S),
    \+(visitato(Nuovo_S,Visitati)),
    %write('inizio2'),
    solve(Nuovo_S,[S|Visitati],Resto).

visitato(S,[S1|_]):-uguale(S,S1),!.
visitato(S,[_|Resto]):-visitato(S,Resto).

%ricercaprof
cercasol(ListaAzioni):-
    inizio(S),
    profondita(S,ListaAzioni,[]).

profondita(S,[],_):-fine(S),!.
profondita(S,[Az|ListaAzioni],Visitati):-
    applicabile(Az,S),
    trasforma(Az,S,SNuovo),
    \+member(SNuovo,Visitati),
    profondita(SNuovo,ListaAzioni,[S|Visitati]).
