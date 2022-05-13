:-['dominio.pl','azioni.pl','ricerca.pl'].

/*
?- inizio(S).

?- inizio(S),findall(Azione, applicabile(Azione,S),AzioniApplicabili).
S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)],
AzioniApplicabili = [move_to_table(c), move_from_table(b, b), move_from_table(b, c), move(c, b), move(c, c)].

--------------------------------------APPLICABILI-----------------------------------------
?- inizio(S),applicabile(move_to_table(c),S).
S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)].

3 ?- inizio(S),applicabile(move_from_table(b,c),S).
S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)].

4 ?- inizio(S),applicabile(move(c,b),S).
S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)] ;




--------------------------------------TRASFORMA-------------------------------------------
?-inizio(S),trasforma(move_to_table(c),S,[on_table(c),clear(a)|S1]).
S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)],
S1 = [on_table(b), clear(b), on_table(a), clear(c)].

?- inizio(S),trasforma(move_from_table(b,c),S,[on(b,c)|S2]).
S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)],
S2 = [clear(b), on_table(a), on(c, a)].

inizio(S),trasforma(move(b,c),S,[on(b,c),clear(a)|S2]).
S = [on_table(b), clear(b), on_table(a), on(c, a), clear(c)],
S2 = [on_table(b), clear(b), on_table(a), on(c, a)].



















*/