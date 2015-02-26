/* ---------------------------------------------------------------------- */
/* ANALYSE ET GENERATION                                                  */
/* ---------------------------------------------------------------------- */

decoupe(S1, S2, S) :- name(S, L),append(L1, L2, L),name(S1, L1), name(S2, L2).

analyse(Mot, MotCanonique, Mode, Temps, Personne) :-
  decoupe(Vpref, Vterm, Mot),terminaison(Nterm, Personne, Vterm),mot(Nconjug, MotCanonique, Npref, Vpref),
  conjugaison(Nconjug, Mode, Temps, Nterm, Personne, Npref).

genere(Mot, MotCanonique, Mode, Temps, Personne) :-
  mot(Nconjug, MotCanonique, Npref, Vpref),terminaison(Nterm, Personne, Vterm),
  conjugaison(Nconjug, Mode, Temps, Nterm, Personne, Npref),
  name(Vterm, Lterm),name(Vpref, Lpref),append(Lpref, Lterm, Lmot),name(Mot, Lmot).

/* ---------------------------------------------------------------------- */
/* AFFICHAGE                                                              */
/* ---------------------------------------------------------------------- */

% Affichage du type.
test_type('masculin').
test_type('feminin').
test_type('').

affiche_type(T, 1) :- test_type(T),write('nom ').
affiche_type(T, 2) :- test_type(T),write('adjectif ').
affiche_type(T, 3) :- test_type(T),write('adverbe ').
affiche_type(T, 4) :- test_type(T),write('conjonction ').
affiche_type(T, 5) :- test_type(T),write('preposition ').
affiche_type(_, _) :- write('verbe '). % Tout ce qui est != à adjectif/nom est supposé être un verbe.

% Cas spécifique : Impératif.
affiche_personne(imperatif, 1) :- write(', 3ème personne du singulier').
affiche_personne(imperatif, 2) :- write(', 1ère personne du pluriel').
affiche_personne(imperatif, 3) :- write(', 2ème personne du pluriel').

% Aucune personne pour les 3 cas suivants.
affiche_personne(participe, _).
affiche_personne(infinitif, _).
affiche_personne(gerondif, _).

% Adjectif/Nom.
affiche_personne(adjectif, Personne) :- write(Personne).
affiche_personne(nom, Personne) :- write(Personne).

% Toutes les autres conjugaisons de verbes.
affiche_personne(T, _) :- test_type(T).

affiche_personne(_, 1) :- write(', 1ère personne du singulier').
affiche_personne(_, 2) :- write(', 2ème personne du singulier').
affiche_personne(_, 3) :- write(', 3ème personne du singulier').
affiche_personne(_, 4) :- write(', 1ère personne du pluriel').
affiche_personne(_, 5) :- write(', 2ème personne du pluriel').
affiche_personne(_, 6) :- write(', 3ème personne du pluriel').

% Mode/Temps
affiche_mode('').
affiche_mode(M) :- write(', '),write(M).

affiche_temps('').
affiche_temps(T) :- write(', '),write(T).

% Affichage général.
affiche_bis(Mot, MotCanonique, Mode, Temps, Personne) :-
  write(Mot),write(' -> '),affiche_type(Mode, Personne),
  write(MotCanonique),affiche_mode(Mode),affiche_temps(Temps),
  affiche_personne(Mode, Personne),write('.'),!,nl.

affiche_analyse(Mot) :-
  analyse(Mot, MotCanonique, Mode, Temps, Personne),affiche_bis(Mot, MotCanonique, Mode, Temps, Personne).

affiche_analyse(_) :- write('Aucun résultat pour ce mot.'),nl.

/* ---------------------------------------------------------------------- */
/* BASE.                                                                  */
/* ---------------------------------------------------------------------- */

% Chargement des bases
:- consult('n_mot').
:- consult('n_conjugaison.pl').
:- consult('n_terminaison.pl').
