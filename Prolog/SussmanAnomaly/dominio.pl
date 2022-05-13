/*
stato iniziale                 
             _______
             |     |                                                             
             |  C  |
  ______     |_____|
  |    |     |     |    
  | B  |     |  A  |
__|____|_____|_____|___

stato finale
     _______
     |     |
     |  A  |
     |_____|
     |     |
     |  B  |
     |_____|     
     |     |    
     |  C  |
_____|_____|___
*/


on_table(X). % il blocco x è sul tavolo
on(X,Y). % il blocco x è sul blocco y
clear(X). % il blocco x non ha blocchi sopra di se

inizio([on_table(b),clear(b),on_table(a),on(c,a),clear(c)]). %stato iniziale
fine([on_table(c),on(b,c),on(a,b),clear(a)]). %stato finale

finale(S) :-
     member(on_table(c),S),
     member(on(b,c), S),
     member(on(a,b),S),
     member(clear(a),S),!.


/*
per testare scrivere in console

-member(on_table(c),[on_table(b), clear(b), on_table(a), on(c, a), clear(c)]). ---> false.
-member(on_table(b),[on_table(b), clear(b), on_table(a), on(c, a), clear(c)]). ---> true .

*/











/*
stato iniziale                 
            _______
            |     |                                                             
            |  C  |
  _____     |_____|
  |   |     |     |    
  | B |     |  A  |
__|___|_____|_____|___

stato finale
     _______
     |     |
     |  A  |
     |_____|
     |     |
     |  B  |
     |_____|     
     |     |    
     |  C  |
_____|_____|___

*/




