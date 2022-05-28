;;;   Dream House Sample Problem
;;;
;;;     house: The house EXpert system.
;;;     This example selects an appropriate house
;;;     to drink with a meal.
;;;
;;;     CLIPS Version 6.0 Example
;;;
;;;     To execute, merely load, reset and run.
;;;======================================================

(defmodule MAIN (export ?ALL))

;;****************
;;* DEFFUNCTIONS *
;;****************
(deffunction MAIN::ask-question (?question ?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) then (bind ?answer (lowcase ?answer))))
   ?answer)
   
;;*****************
;;* INITIAL STATE *
;;*****************

(deftemplate MAIN::attribute
   (slot name)
   (slot value)
   (slot certainty (default 100.0))) 

(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus QUESTIONS CHOOSE-QUALITIES HOUSES PRINT-RESULTS))

(defrule MAIN::combine-certainties ""
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (- (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))
  
  
;;******************
;;* QUESTION RULES *
;;******************

(defmodule QUESTIONS (import MAIN ?ALL) (export ?ALL))

(deftemplate QUESTIONS::question
   (slot attribute (default ?NONE))
   (slot the-question (default ?NONE))
   (multislot valid-answers (default any))
   (slot already-asked (default FALSE))
   (multislot precursors (default ?DERIVE)))
   
(defrule QUESTIONS::ask-a-question
   ?f <- (question (already-asked FALSE)
                   (precursors)
                   (the-question ?the-question)
                   (attribute ?the-attribute)
                   (valid-answers $?valid-answers))
   =>
   (modify ?f (already-asked TRUE))
   (assert (attribute (name ?the-attribute)
                      (value (ask-question ?the-question ?valid-answers)))))

(defrule QUESTIONS::precursor-is-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is ?value $?rest))
         (attribute (name ?name) (value ?value))
   =>
   (if (eq (nth 1 ?rest) and) 
    then (modify ?f (precursors (rest$ ?rest)))
    else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-is-not-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is-not ?value $?rest))
         (attribute (name ?name) (value ~?value))
   =>
   (if (eq (nth 1 ?rest) and) 
    then (modify ?f (precursors (rest$ ?rest)))
    else (modify ?f (precursors ?rest))))
   
;;==================
;; House Questions =
;;==================

(defmodule HOUSE-QUESTIONS (import QUESTIONS ?ALL))

(deffacts HOUSE-QUESTIONS::question-attributes

  (question (attribute which-city)
		 (the-question "Which City do you want live? ")
		 (valid-answers torino  asti  alba  cuneo  moncalieri))	
		 
  (question (attribute howmuch-budget)
		 (the-question "How much is your budget? ")
		 (valid-answers 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 unknown))
		 
  (question (attribute house-meter)
		 (the-question "How many meters do you want the house to be? ")
		 (valid-answers 15 20 30 40 50 60 70 80 90 100 110 120 130 140 unknown))
		 		 
  (question (attribute howmany-room)
		 (the-question "How many rooms do you want? ")
		 (valid-answers 1 2 3 4 5 unknown))
		 
  (question (attribute num-piano)
		 (the-question "Which flat do you consider to live? ")
		 (valid-answers rialzato 1 2 3 4 5  unknown))
  
  (question (attribute has-ascensore)
		 (the-question "Do you need an apartment with an ascensore? ")
		 (valid-answers yes no unknown))
		 
  (question (attribute has-box)
		 (the-question "Do you need parking? ")
		 (valid-answers yes no unknown))
		 
  (question (attribute has-terrazzino)
		 (the-question "Do you also want a balcony?  ")
		 (valid-answers yes no unknown))
		 
)

;;******************
;; The RULES module
;;******************

(defmodule RULES (import MAIN ?ALL) (export ?ALL))

(deftemplate RULES::rule
  (slot certainty (default 100.0))
  (multislot if)
  (multislot then))

(defrule RULES::throw-away-ands-in-antecedent
  ?f <- (rule (if and $?rest))
  =>
  (modify ?f (if ?rest)))

(defrule RULES::throw-away-ands-in-consequent
  ?f <- (rule (then and $?rest))
  =>
  (modify ?f (then ?rest)))

(defrule RULES::remove-is-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is ?value $?rest))
  (attribute (name ?attribute) 
             (value ?value) 
             (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::remove-is-not-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is-not ?value $?rest))
  (attribute (name ?attribute) (value ~?value) (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::perform-rule-consequent-with-certainty
  ?f <- (rule (certainty ?c1) 
              (if) 
              (then ?attribute is ?value with certainty ?c2 $?rest))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) 
                     (value ?value)
                     (certainty (/ (* ?c1 ?c2) 100)))))

(defrule RULES::perform-rule-consequent-without-certainty
  ?f <- (rule (certainty ?c1)
              (if)
              (then ?attribute is ?value $?rest))
  (test (or (eq (length$ ?rest) 0)
            (neq (nth 1 ?rest) with)))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) (value ?value) (certainty ?c1))))

;;*******************************
;;* CHOOSE house QUALITIES RULES *
;;*******************************

(defmodule CHOOSE-QUALITIES (import RULES ?ALL)
                            (import QUESTIONS ?ALL)
                            (import MAIN ?ALL))

(defrule CHOOSE-QUALITIES::startit => (focus RULES))

(deffacts the-house-rules

	;finding best matches for torino.
	
(rule (if which-city is torino)
 	(then best-citta is torino))

	;finding best matches for torino Mq.
	
(rule (if house-meter is 15 and which-city is torino)
	(then best-meter is 26 with certainty 60))

(rule (if house-meter is 20 and which-city is torino)
	(then best-meter is 26 with certainty 70))
	
(rule (if house-meter is 30 and which-city is torino)
	(then best-meter is 26 with certainty 80))
  
(rule (if house-meter is 30 and which-city is torino)
	(then best-meter is 26 with certainty 80))
	
(rule (if house-meter is 40 and which-city is torino)
	(then best-meter is 26 with certainty 30 
	 and best-meter is 53 with certainty 40))

(rule (if house-meter is 50 and which-city is torino)
	(then best-meter is 26 with certainty 20 
	 and best-meter is 53 with certainty 80))
	
(rule (if house-meter is 60 and which-city is torino)
	(then best-meter is 26 with certainty 10 and best-meter is 53 with certainty 60))
	
(rule (if house-meter is 70 and which-city is torino)
	(then best-meter is 26 with certainty 10 
	and best-meter is 53 with certainty 40 
	and best-meter is 74 with certainty 90))
	
(rule (if house-meter is 80 and which-city is torino)
	(then best-meter is 53 with certainty 10 
	 and best-meter is 74 with certainty 60 
	 and best-meter is 87 with certainty 90))
	 
(rule (if house-meter is 90 and which-city is torino)
	(then best-meter is 53 with certainty 10 
	 and best-meter is 74 with certainty 50 
	 and best-meter is 87 with certainty 90))
	 
(rule (if house-meter is 100 and which-city is torino)
	(then best-meter is 74 with certainty 30 
	 and best-meter is 87 with certainty 60 
	 and best-meter is 140 with certainty 20))
	 
(rule (if house-meter is 110 and which-city is torino)
	(then best-meter is 74 with certainty 20 
	 and best-meter is 87 with certainty 50 
	 and best-meter is 140 with certainty 30))

(rule (if house-meter is 120 and which-city is torino)
	(then best-meter is 74 with certainty 10 
	 and best-meter is 87 with certainty 40 
	 and best-meter is 140 with certainty 50))

(rule (if house-meter is 130 and which-city is torino)
	(then best-meter is 74 with certainty 10 
	 and best-meter is 87 with certainty 30 
	 and best-meter is 140 with certainty 70))
	 
(rule (if house-meter is 140 and which-city is torino)
	(then best-meter is 74 with certainty 10 
	 and best-meter is 87 with certainty 30 
	 and best-meter is 140 with certainty 100))
	 
(rule (if house-meter is unknown and which-city is torino)
	(then best-meter is 26 with certainty 20
	 and best-meter is 74 with certainty 20 
	 and best-meter is 87 with certainty 20 
	 and best-meter is 140 with certainty 20))
  



;finding best matches for torino Rooms.

(rule (if which-city is torino)
      (then best-citta is torino))

(rule (if howmany-room is 1 and which-city is torino)
	(then best-room is 1))

(rule (if howmany-room is 2 and which-city is torino)
	(then best-room is 2))
	
(rule (if howmany-room is 3 and which-city is torino)
	(then best-room is 3))
  
(rule (if howmany-room is 4 and which-city is torino)
	(then best-room is 4))
	
(rule (if howmany-room is 5 and which-city is torino)
	(then best-room is 5))

(rule (if howmany-room is unknown and which-city is torino)
       (then best-room is 1 with certainty 20 
	 and best-room is 2 with certainty 20
	 and best-room is 3 with certainty 20
	 and best-room is 4 with certainty 20
	 and best-room is 5 with certainty 20))
	 
;finding best matches for torino Flats.

(rule (if which-city is torino)
      (then best-citta is torino))

(rule (if num-piano is 1 and which-city is torino)
	(then best-piano is 1))

(rule (if num-piano is 2 and which-city is torino)
	(then best-piano is 2))
	
(rule (if num-piano is 3 and which-city is torino)
	(then best-piano is 3))
  
(rule (if num-piano is 4 and which-city is torino)
	(then best-piano is 4))
	
(rule (if num-piano is 5 and which-city is torino)
	(then best-piano is 5))

(rule (if num-piano is unknown and which-city is torino)
       (then best-piano is 1 with certainty 20 
	 and best-piano is 2 with certainty 20
	 and best-piano is 3 with certainty 20
	 and best-piano is 4 with certainty 20
	 and best-piano is 5 with certainty 20))

           
;finding best matches for torino Budget.


(rule (if howmuch-budget is 300 and which-city is torino)
	(then best-prezzo is 320))

(rule (if howmuch-budget is 400 and which-city is torino)
	(then best-prezzo is 320 with certainty 80
	  and best-prezzo is 510 with certainty 20))
	
(rule (if howmuch-budget is 500 and which-city is torino)
	(then best-prezzo is 3
	best-prezzo is 320 with certainty 20
	and best-prezzo is 510 with certainty 80
	and best-prezzo is 570 with certainty 50))
  
(rule (if howmuch-budget is 600 and which-city is torino)
	(then best-prezzo is 510 with certainty 50
	 and best-prezzo is 570 with certainty 60
	 and best-prezzo is 690 with certainty 30)) 
	
(rule (if howmuch-budget is 700 and which-city is torino)
	(then best-prezzo is 570 with certainty 30
	 and best-prezzo is 690 with certainty 80))
	
(rule (if howmuch-budget is 800 and which-city is torino)
	(then best-prezzo is 690 with certainty 40))
	
(rule (if howmuch-budget is 900 and which-city is torino)
	(then best-prezzo is 690 with certainty 40
	 and best-prezzo is 1320 with certainty 10))
	
(rule (if howmuch-budget is 1000 and which-city is torino)
	(then best-prezzo is 690 with certainty 30
	 and best-prezzo is 1320 with certainty 50))
	
(rule (if howmuch-budget is 1100 and which-city is torino)
	(then best-prezzo is 690 with certainty 30
	 and best-prezzo is 1320 with certainty 60))
	
(rule (if howmuch-budget is 1200 and which-city is torino)
	(then best-prezzo is 690 with certainty 20
	 and best-prezzo is 1320 with certainty 60))
	
(rule (if howmuch-budget is 1300 and which-city is torino)
	(then best-prezzo is 690 with certainty 20
	 and best-prezzo is 1320 with certainty 90))
	
(rule (if howmuch-budget is 1400 and which-city is torino)
	(then best-prezzo is 690 with certainty 20
	 and best-prezzo is 1320 with certainty 80))

(rule (if num-piano is unknown and which-city is torino)
       (then best-prezzo is 320 with certainty 20 
	 and best-prezzo is 510 with certainty 20
	 and best-prezzo is 570 with certainty 20
	 and best-prezzo is 690 with certainty 20
	 and best-prezzo is 1320 with certainty 20))
	 
	 
;finding best matches for torino if house has an ascensore.

(rule (if has-ascensore is yes and which-city is torino)
	(then best-ascensore is yes))
	
(rule (if has-ascensore is no and which-city is torino)
	(then best-ascensore is no))

(rule (if has-ascensore is unknown and which-city is torino)
       (then best-ascensore is yes with certainty 20 
	 and best-ascensore is no with certainty 20))
	 
;finding best matches for torino if house has a Terrace.

(rule (if has-terrazzino is yes and which-city is torino)
	(then best-terrazzino is yes))
	
(rule (if has-terrazzino is no and which-city is torino)
	(then best-terrazzino is no))

(rule (if has-terrazzino is unknown and which-city is torino)
       (then best-terrazzino is yes with certainty 20 
	 and best-terrazzino is no with certainty 20))

;finding best matches for torino if house has a Box.

(rule (if has-box is yes and which-city is torino)
	(then best-terrazzino is yes))
	
(rule (if has-box is no and which-city is torino)
	(then best-terrazzino is no))

(rule (if has-box is unknown and which-city is torino)
       (then best-Auto is yes with certainty 20 
	 and best-Auto is no with certainty 20))
	 
	 
	 

) 
;;************************
;; house SELECTION RULES *
;;************************

(defmodule HOUSES (import MAIN ?ALL))

(deffacts any-attributes
	(attribute (name best-meter) (value any))
	(attribute (name best-room) (value any))
	(attribute (name best-piano) (value any))
	(attribute (name best-citta) (value any))
	(attribute (name best-ascensore) (value any))
	(attribute (name best-Auto) (value any))
	(attribute (name best-terrazzino) (value any))
	(attribute (name best-prezzo) (value any)))

(deftemplate HOUSES::house 
	(slot name (default ?NONE))
	(multislot metri-quadri (default any))
	(multislot numero-vani (default any))
	(multislot numero-piano (default any))
	(multislot citta (default any))
	(multislot ascensore (default any))
	(multislot Box-Auto (default any))
	(multislot terrazzino (default any))
	(multislot prezzo-richiesto (default any)))
	

(deffacts HOUSES::the-house-list
  (house (name 100-torino) (metri-quadri 26) (numero-vani 1) (numero-piano 4) (citta torino) (ascensore no) (terrazzino no) (Box-Auto no) (prezzo-richiesto 320))
  (house (name 110-torino) (metri-quadri 74) (numero-vani 2) (numero-piano 1) (citta torino) (ascensore yes) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 510))
  (house (name 120-torino) (metri-quadri 87) (numero-vani 3) (numero-piano 3) (citta torino) (ascensore no) (terrazzino no) (Box-Auto no) (prezzo-richiesto 690))
  (house (name 130-torino) (metri-quadri 140) (numero-vani 5) (numero-piano 5) (citta torino) (ascensore yes) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 1320))
  (house (name 140-torino) (metri-quadri 53) (numero-vani 4) (numero-piano 2) (citta torino) (ascensore yes) (terrazzino yes) (Box-Auto no) (prezzo-richiesto 570))
  
  (house (name 210-cuneo) (metri-quadri 100) (numero-vani 4) (numero-piano 5) (citta cuneo) (ascensore yes) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 1000))
  (house (name 220-cuneo) (metri-quadri 19) (numero-vani 1) (numero-piano rialzato) (citta cuneo) (ascensore no) (terrazzino no) (Box-Auto no) (prezzo-richiesto 420))
  (house (name 230-cuneo) (metri-quadri 64) (numero-vani 2) (numero-piano 4) (citta cuneo) (ascensore yes) (terrazzino yes) (Box-Auto no) (prezzo-richiesto 430))
  (house (name 240-cuneo) (metri-quadri 53) (numero-vani 3) (numero-piano 1) (citta cuneo) (ascensore no) (terrazzino no) (Box-Auto yes) (prezzo-richiesto 500))
  
  (house (name 310-moncalieri) (metri-quadri 120) (numero-vani 5) (numero-piano 2) (citta moncalieri) (ascensore yes) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 1200))
  (house (name 320-moncalieri) (metri-quadri 53) (numero-vani 3) (numero-piano 5) (citta moncalieri) (ascensore yes) (terrazzino no) (Box-Auto no) (prezzo-richiesto 760))
  (house (name 330-moncalieri) (metri-quadri 110) (numero-vani 4) (numero-piano 4) (citta moncalieri) (ascensore yes) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 1100))
  (house (name 340-moncalieri) (metri-quadri 70) (numero-vani 3) (numero-piano 1) (citta moncalieri) (ascensore yes) (terrazzino no) (Box-Auto no) (prezzo-richiesto 650))
  
  (house (name 410-asti) (metri-quadri 92) (numero-vani 4) (numero-piano 1) (citta asti) (ascensore no) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 640))
  (house (name 420-asti) (metri-quadri 47) (numero-vani 2) (numero-piano 3) (citta asti) (ascensore yes) (terrazzino no) (Box-Auto no) (prezzo-richiesto 490))
  (house (name 430-asti) (metri-quadri 100) (numero-vani 4) (numero-piano 2) (citta asti) (ascensore yes) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 640))
  (house (name 440-asti) (metri-quadri 80) (numero-vani 3) (numero-piano 3) (citta asti) (ascensore no) (terrazzino no) (Box-Auto yes) (prezzo-richiesto 760))
  
  (house (name 510-alba) (metri-quadri 26) (numero-vani 1) (numero-piano 2) (citta alba) (ascensore yes) (terrazzino no) (Box-Auto no) (prezzo-richiesto 370))
  (house (name 520-alba) (metri-quadri 36) (numero-vani 2) (numero-piano 4) (citta alba) (ascensore yes) (terrazzino no) (Box-Auto no) (prezzo-richiesto 400))
  (house (name 530-alba) (metri-quadri 79) (numero-vani 3) (numero-piano 1) (citta alba) (ascensore no) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 500))
  (house (name 540-alba) (metri-quadri 130) (numero-vani 2) (numero-piano 4) (citta alba) (ascensore yes) (terrazzino yes) (Box-Auto yes) (prezzo-richiesto 1250)))


(defrule HOUSES::generate-houses
  (house (name ?name)
  	 (metri-quadri $? ?metri $?)
         (numero-vani $? ?room $?)
         (numero-piano $? ?piano $?)
         (citta $? ?citta $?)
         (ascensore $? ?ascensore $?)
         (Box-Auto $? ?box $?)
         (terrazzino $? ?terrazzino $?)
         (prezzo-richiesto $? ?prezzo $?))
         
 (attribute (name best-meter) (value ?metri) (certainty ?certainty-1))
 (attribute (name best-room) (value ?room) (certainty ?certainty-2))
 (attribute (name best-citta) (value ?citta) (certainty ?certainty-3))
 (attribute (name best-ascensore) (value ?ascensore) (certainty ?certainty-4))
 (attribute (name best-Auto) (value ?box) (certainty ?certainty-5))
 (attribute (name best-terrazzino) (value ?terrazzino) (certainty ?certainty-6))
 (attribute (name best-prezzo) (value ?prezzo) (certainty ?certainty-7))
 (attribute (name best-piano) (value ?piano) (certainty ?certainty-8))
  =>
  (assert (attribute (name house) (value ?name) 
  		     (certainty (max ?certainty-1 ?certainty-2 
  		?certainty-3 ?certainty-4 ?certainty-5 ?certainty-6 ?certainty-7 ?certainty-8)))))
  
;;*****************************
;;* PRINT SELECTED house RULES *
;;*****************************

(defmodule PRINT-RESULTS (import MAIN ?ALL))

(defrule PRINT-RESULTS::header ""
   (declare (salience 10))
   =>
   (printout t t)
   (printout t "SELECTED house" t t)
   (printout t " house      CERTAINTY" t)
   (printout t " -------------------------------" t)
   (assert (phase print-houses)))

(defrule PRINT-RESULTS::print-house ""
  ?rem <- (attribute (name house) (value ?name) (certainty ?per))		  
  (not (attribute (name house) (certainty ?per1&:(> ?per1 ?per))))
  =>
  (retract ?rem)
  (format t " %-24s %2d%%%n" ?name ?per))

(defrule PRINT-RESULTS::remove-poor-house-choices ""
  ?rem <- (attribute (name house) (certainty ?per&:(< ?per 20)))
  =>
  (retract ?rem))

(defrule PRINT-RESULTS::end-spaces ""
   (not (attribute (name house)))
   =>
   (printout t t))
