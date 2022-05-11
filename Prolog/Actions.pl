applicable(pickup(X),S):-
	block(X),
	ord_memberchk(ontable(X),S),
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).
	
applicable(putdown(X),S):-
	block(X),
	ord_memberchk(holding(X),S).
	
applicable(stack(X,Y),S):-
	block(X), block(Y), X\=Y,
	ord_memberchk(holding(X),S),
	ord_memberchk(clear(Y),S).

applicable(unstack(X,Y),S):-
	block(X), block(Y), X\=Y,
	ord_memberchk(on(X,Y),S),
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).


transform(pickup(X),S1,S2):-
	block(X),
	list_to_ord_set([ontable(X),clear(X),handempty],DLS),
	ord_subtract(S1,DLS,S),
	list_to_ord_set([holding(X)],ALS),
	ord_union(S,ALS,S2).
	
transform(putdown(X),S1,S2):-
	block(X),
	list_to_ord_set([holding(X)],DLS),
	ord_subtract(S1,DLS,S),
	list_to_ord_set([ontable(X),clear(X),handempty],ALS),
	ord_union(S,ALS,S2).

transform(stack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([holding(X),clear(Y)],DLS),
	ord_subtract(S1,DLS,S),
	list_to_ord_set([on(X,Y),clear(X),handempty],ALS),
	ord_union(S,ALS,S2).

transform(unstack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([on(X,Y),clear(X),handempty],DLS),
	ord_subtract(S1,DLS,S),
	list_to_ord_set([holding(X),clear(Y)],ALS),
	ord_union(S,ALS,S2).