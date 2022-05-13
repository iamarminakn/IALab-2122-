:- dynamic delete1/3, clear/1.
move_to_table(X). % sposta X dalla cima di una pila al tavolo
move_from_table(X,Y).%sposta X dal tavolo alla cima della pila che ha Y come cima
move(X,Y).%sposta X dalla cima di una pila alla cima di un’altra pila che ha Y come cima

%è possibile spostare il blocco X dalla cima di una pila al tavolo?? si, solo se
applicabile(move_to_table(X),S):-
    member(clear(X), S), % il blocco X non ha blocchi sopra di se
    member(on(X,Y), S).  % il blocco X è sul blocco Y

%è possibile spostare il blocco X dal tavolo alla cima della pila che ha Y come cima?? si, solo se
applicabile(move_from_table(X,Y), S):-
    X \= Y,
    member(on_table(X), S), % il blocco X è sul tavolo
    member(clear(X), S), % il blocco X non ha nulla sopra 
    member(clear(Y), S). % il blocco Y non ha nulla sopra

%è possibile spostare X dalla cima di una pila alla cima di un’altra pila che ha Y come cima?? si, solo se
applicabile(move(X,Y), S):-
    member(clear(X), S),  % il blocco X non ha nulla sopra 
    member(on(X,Z), S),   % il blocco X è sul blocco Z 
    member(clear(Y), S).  % il blocco Y non ha nulla sopra

/* per testare i 3 applica scrivere in console:

-inizio(S),applicabile(move_to_table(a),S).      ---> false  
-inizio(S),applicabile(move_to_table(c),S).      ---> S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)] . NB QUESTA RISPOSTA VUOL DIRE TRUE
-inizio(S),applicabile(move_from_table(c,b),S).  ---> false.
-inizio(S),applicabile(move_from_table(b,c),S).  ---> S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)] . ---> true

TUTTE LE AZIONI APPLICABILI A PARTIRE DALLO STATO INIZIALE
?- inizio(S),findall(Azione, applicabile(Azione,S),AzioniApplicabili).
    S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)],
    AzioniApplicabili = [move_to_table(c), move_from_table(b, b), move_from_table(b, c)].

QUALE AZIONE È APPLICABILE PER ARRIVARE A QUESTO RISULTATO? RISULTATO=[on_table(b),clear(b)|_]
applicabile(Az,[on_table(b),clear(b)|_]).
Az = move_to_table(b) .


*/

tra(move_to_table(X),S,S1):-
    member(on(X,Y), S),
    delete(S,on(X,Y),S1),!.
%questo funziona,ho modificato l'ordine di delete rispetto gli altri trasforma
trasforma(move_to_table(X),S,[on_table(X),clear(Y)|S1] ):-
    delete(S,on(X,Y),S1).

trasforma(move_from_table(X,Y),S,[on(X,Y)|S2] ):-
    delete(S,on_table(X),S1),
    delete(S1,clear(Y),S2).

trasforma(move(X,Y),S,[on(X,Y),clear(Z)|S2] ):-
    delete(S,clear(Y),S1),
    delete(S1,on(X,Z),S2).




/*
non funziona il delete

trasforma2(move_to_table(X),S,[on_table(X),clear(Y)|S1] ):-
    delete(on(X,Y), S, S1).

trasforma2(move_from_table(X,Y),S,[on(X,Y)|S2] ):-
    delete(on_table(X),S,S1),
    delete(clear(Y),S1,S2).

trasforma2(move(X,Y),S,[on(X,Y),clear(Z)|S2] ):-
    delete(clear(Y),S,S1),
    delete(on(X,Z),S1,S2).
*/

uguale([],[]).
uguale([X|Rest1],S2):-
    member(X,S2),
    delete1(S2,X,Rest2),
    uguale(Rest1,Rest2).