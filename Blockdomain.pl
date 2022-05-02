%Ordered sets are lists with unique elements sorted to the standard order of terms
:-use_module(library(ordsets)).

block(A).
block(B).
block(C).
block(D).
block(E).
block(F).
block(G).
block(H).
block(I).

%list_to_ord_set(+List, -OrdSet),list_to_ord_set(List, OrdSet) Transform a list into an ordered set. This is the same as sorting the list.


initial_state(S):- 
    list_to_ord_set([on_table(F),clear(F),on_table(C),on(B,C),on(B,A),clear(A),on_table(E),on(D,E),clear(D),on_table(I),on(H,I),on(G,H),handempty],S).

goal(G):-
     list_to_ord_set([on_table(D),on(C,D),on(B,C),on(A,B),clear(A),on_table(G),on(F,G),on(E,F),clear(E),on_table(I),on(H,I),clear(H),handemty],G).


%ord_subset(+Sub, +Super)Is true if all elements of Sub are in Super
final_state(S):- 
    (goal(G), ord_subset(G,S)).


