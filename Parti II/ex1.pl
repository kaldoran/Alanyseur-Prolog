/* ---------------------------------------------------------------------- */
/* VERBES.                                                                */
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
/* TYPES.                                                                 */
/* ---------------------------------------------------------------------- */

estverbe_n(X) :- X \== 'participe',X \== 'gerondif',X \== 'imperatif',X \== 'infinitif'.

% Liaisons
conjonction_sub                      --> [R],{conjonction_sub_(R, _, _, _, _, _)}.
conjonction_coor                     --> [R],{conjonction_coor_(R, _, _, _, _, _)}.

% Adjectif simple
adjectif(Type, Nombre)               --> [R],{adjectif_(R, Type, _, Nombre, _, _)}.

% Participe comme adjectif
adjectif('masculine', 'singular')    --> [R],{analyse(R, _, participe, passe, 1)}.
adjectif('feminine', 'singular')     --> [R],{analyse(R, _, participe, passe, 2)}.
adjectif('masculine', 'plurial')     --> [R],{analyse(R, _, participe, passe, 3)}.
adjectif('feminine', 'plurial')      --> [R],{analyse(R, _, participe, passe, 4)}.

% Autres
nom(Type, Nombre)                     --> [R],{nom_(R, Type, _, Nombre, _, _)}.
determinant(Type, Nombre)             --> [R],{determinant_(R, Type, _, Nombre, _, _)}.
adverbe                               --> [R],{adverbe_(R, _, _, _, _, _)}.
verbe_n(Mode, Personne, Aux)          --> [R],{estverbe_n(Mode),analyse(R, Aux, Mode, _, Personne),!}.
verbe_infinitif                       --> [R],{genere(_, R, infinitif, _, _)}.
pronom_perso(Type, Nombre, Personne)  --> [R],{pronom_perso_(R, Type, Nombre, Personne)}.
pronom(Type, Nombre, Personne)        --> [R],{pronom_(R, Type, _, Nombre, Personne, _)}.
pronom_perso_complement(Personne)     --> [R],{pronom_perso_complement_(R, Personne)}.
pronom_demonstratif(Nombre, Personne) --> [R],{pronom_demonstratif_(R, Nombre, Personne)}.
pronom_relatif(Type, Nombre)          --> [R],{pronom_relatif_(R, Type, Nombre)}.
pronom_relatif_inv                    --> [R],{pronom_relatif_inv_(R)}.
preposition                           --> [R],{preposition_(R)}.

% Negation
negation_1 --> ['n\''].
negation_1 --> [ne].
negation_2 --> [pas].

% Impératif
imperatif_s --> [R],{analyse(R, _, imperatif, _, 1)}.
imperatif_s --> [R],{analyse(R, _, imperatif, _, 2)}.
imperatif_s --> [R],{analyse(R, _, imperatif, _, 3)}.

/* ---------------------------------------------------------------------- */
/* PHRASES.                                                               */
/* ---------------------------------------------------------------------- */

separateur --> conjonction_coor,partie_phrase.

partie_phrase --> groupe_nominal_principal(T, N, P),groupe_verbal(T, N, P, _),separateur.
partie_phrase --> groupe_nominal_principal(T, N, P),groupe_verbal(T, N, P, _).

% Impératif
analyse_phrase --> imperatif_s,groupe_nominal(_, _, _).

% Phrases
analyse_phrase --> partie_phrase.

/* ---------------------------------------------------------------------- */
/* ADJECTIFS.                                                             */
/* ---------------------------------------------------------------------- */

suite_adjectifs(T, N) --> adjectif(T, N),suite_adjectifs(T, N).
suite_adjectifs(_, _) --> [].

/* ---------------------------------------------------------------------- */
/* GROUPE NOMINAL.                                                        */
/* ---------------------------------------------------------------------- */

groupe_nominal_opt(T, N, P) --> groupe_nominal(T, N, P),conjonction_coor_opt.
groupe_nominal_opt(_, _, _) --> [].

forme_adverbe_opt --> adverbe.
forme_adverbe_opt --> adverbe,groupe_nominal(_, _, _).
forme_adverbe_opt --> [].

groupe_nominal_principal(T, N, P) --> groupe_nominal(T, N, P).
groupe_nominal_principal(T, N, P) --> pronom_perso(T, N, P).

% Introduction proposition relative
groupe_nominal_principal(T, N, P) --> groupe_nominal(T, N, P),pronom_relatif(T, N),groupe_nominal_principal(T2, N2, P2),
                                      groupe_verbal(T2, N2, P2, _),groupe_nominal_opt(_, _, _).
groupe_nominal_principal(T, N, P) --> groupe_nominal(T, N, P),pronom_relatif_inv,
                                      groupe_verbal(T, N, P, _),groupe_nominal_opt(_, _, _).

pdetnom('singular', 3).
pdetnom('plural', 6).

complement_opt --> preposition,groupe_nominal(_, _, _).
complement_opt --> preposition,groupe_nominal_abs(_, _, _).
complement_opt --> [].

groupe_nominal_abs(T, N, P) --> suite_adjectifs(T, N),nom(T, N),suite_adjectifs(T, N),{pdetnom(N, P)},
                               forme_adverbe_opt,complement_opt.

% Déterminant + Adjectif? + Nom + Adjectif? + Adverbe?
groupe_nominal(T, N, P) --> determinant(T, N),groupe_nominal_abs(T, N, P).

% Pronom démonstratif + Adverbe?
groupe_nominal(_, N, P) --> pronom_demonstratif(N, P),forme_adverbe_opt.

/* ---------------------------------------------------------------------- */
/* GROUPE VERBAL.                                                         */
/* ---------------------------------------------------------------------- */

conjonction_coor_opt --> conjonction_coor,groupe_nominal_opt(_, _, _).
conjonction_coor_opt --> [].

adjectif_opt(T, N) --> adjectif(T, N),adjectif_complement(T, N).
adjectif_opt(_, _) --> [].

adverbe_opt --> adverbe.
adverbe_opt --> [].

adjectif_complement(T, N) --> conjonction_coor,adjectif(T, N).
adjectif_complement(_, _) --> [].

pronom_perso_complement_opt(P) --> pronom_perso_complement(P).
pronom_perso_complement_opt(_) --> [].

verbe_infinitif_opt --> verbe_infinitif.
verbe_infinitif_opt --> [].

aux(être).
aux(avoir).
notaux(A) :- A\==être,A\==avoir.

% Sous ensembles
ens_1(P, A) --> pronom_perso_complement_opt(P),verbe_n(_, P, A),adverbe_opt.
ens_2(T, N) --> adverbe_opt,adjectif_opt(T, N),groupe_nominal_opt(_, _, _).

ens_3 --> adverbe_opt,verbe_infinitif_opt,groupe_nominal_opt(_, _, _).

% Pronom_complement? + Verbe auxiliaire + adverbe? + adjectif (participe) + autre groupe nominal?
groupe_verbal_ens(T, N, P, A) --> ens_1(P, A),{aux(A)},ens_2(T, N).

% Pronom_complement? + Verbe + adverbe? + verbe infinitif? + autre groupe nominal?
groupe_verbal_ens(_, _, P, _) --> ens_1(P, A),{notaux(A)},ens_3.

% Même chose mais avec négation
groupe_verbal_ens(T, N, P, A) --> negation_1,ens_1(P, A),{aux(A)},negation_2,ens_2(T, N).
groupe_verbal_ens(T, N, P, A) --> negation_1,ens_1(P, A),{aux(A)},negation_2,ens_3.
groupe_verbal_ens(_, _, P, _) --> negation_1,ens_1(P, A),{notaux(A)},negation_2,ens_3.

groupe_verbal_p(T, N, P, A) --> groupe_verbal_ens(T, N, P, A).
groupe_verbal_p(T, N, P, A) --> groupe_verbal_ens(T, N, P, A),pronom_relatif_inv,groupe_verbal_ens(_, _,_,_).
groupe_verbal_p(T, N, P, A) --> groupe_verbal_ens(T, N, P, A),pronom_relatif(T, N),groupe_nominal_principal(T2, N2, P2),
                              groupe_verbal(T2, N2, P2, _).

pre_opt --> preposition,groupe_nominal(_, _, _).
pre_opt --> [].

groupe_verbal(T, N, P, A) --> groupe_verbal_p(T, N, P, A),pre_opt.

/* ---------------------------------------------------------------------- */
/* BASE.                                                                  */
/* ---------------------------------------------------------------------- */

% Chargement des bases
:- consult('data/n_mot').
:- consult('data/n_conjugaison.pl').
:- consult('data/n_terminaison.pl').
:- consult('data/pronom_perso.pl').
:- consult('data/pronom.pl').
:- consult('data/adjectif.pl').
:- consult('data/adverbe.pl').
:- consult('data/determinant.pl').
:- consult('data/nom.pl').
:- consult('data/preposition.pl').
:- consult('data/conjonction_coor.pl').
:- consult('data/conjonction_sub.pl').
:- consult('data/pronom_perso_complement.pl').
:- consult('data/pronom_demonstratif.pl').
:- consult('data/pronom_relatif.pl').

% A utiliser pour analyser une phrase
phrase(Phrase) :- atomic_list_concat(A, ' ', Phrase),analyse_phrase(A, []).

/* ---------------------------------------------------------------------- */
/* EXEMPLES.                                                              */
/* ---------------------------------------------------------------------- */

/* Imperatif */
/*

?- analyse_phrase([dors, la, nuit], []).
true 

?- analyse_phrase([mange, la, pomme], []).
true 

?- analyse_phrase([suis, la, lumière], []).
true 

?- analyse_phrase([suis, le, lumière], []).
false.

?- analyse_phrase([regarde, ces, gens], []).
true 

?- analyse_phrase([mange, ces, délicieuses, frites], []).
true .

*/

/* Adverbes + accords */
/*

?- analyse_phrase([les, gens, devant, la, maison, mange], []).
false.

?- analyse_phrase([les, gens, devant, la, maison, mangent], []).
true 

?- analyse_phrase([la, personne, devant, la, maison, mangent], []).
false.

?- analyse_phrase([la, personne, devant, la, maison, mange], []).
true 

?- analyse_phrase([la, personne, mange, devant, la, maison], []).
true .

*/

/* Adjectifs (avec participes avec être/avoir) + adverbes */
/*

?- analyse_phrase([le, mètre, cube, mangeait, un, bon, gros, gâteau, calorique], []).
true

?- analyse_phrase([la, table, est, lentement, tombée, et, je, teste, 'avec bonheur', les, adverbes], []).
true

*/

/* Conjonctions de coordinations */
/*

?- analyse_phrase([je, suis, tendrement, grand, et, beau, mais, je, regarde, les, vaches], []).
true .

*/

/* Pronoms compléments (leur, lui, vous, nous, te, me...) */
/*

?- analyse_phrase([elles, vous, donnent, et, vous, leur, donnez], []).
true .

?- analyse_phrase([je, suis, un, nain, compris, et, je, le, dis], []).
true .

*/

/* Négation : On autorise le familier "pas" seul ainsi que la forme ne-pas */
/*

?- analyse_phrase([je, suis, un, requin], []).
true .

?- analyse_phrase([je, ne, suis, un, requin], []).
false.

?- analyse_phrase([je, suis, pas, un, requin], []).
true .

?- analyse_phrase([je, ne, suis, pas, un, requin], []).
true .

*/

/* Pronom démonstratif, nouveau sujet ! */
/*

?- phrase('celle-ci mange du pain mais elle ne connaît pas les bonnes manières').
true .

?- phrase('ils sont grands et velus car je suis omniscient mais eux-mêmes ne comprennent pas ces insignifiants propos').
true .

*/

/* Verbes infinitifs après un verbe conjugué. */
/*

?- phrase('je suis pleurer ces gens').
false.

?- phrase('je regarde pleurer ces gens').
true .

*/

/** Proposition relative. */
/*

?- analyse_phrase([la, personne, 'à laquelle', il, fait, une, bise, fait, des, crêpes], []).
true .

?- analyse_phrase([la, personne, 'à laquelle', il, fait, une, bise, vous, fait, des, crêpes], []).
true .

?- analyse_phrase([la, personne, 'à laquelle', il, fait, une, bise, se, fait, des, crêpes], []).
true .

?- analyse_phrase([les, hommes, auxquels, ils, racontent, leurs, vies, sont, barbus, et, tendres], []).
true .

?- analyse_phrase([le, navire, où, il, est, est, grand], []).
true .

?- phrase('les cieux où les oiseaux volent sont joyeux').
true .

*/

/** Prépositions. */
/*

?- phrase('ce vilain chat de garagiste mange vulgairement la confiture de fraises').
true .

?- phrase('les poules se sont postées le long de ce lac mais elles se sont malheureusement noyées').
true .

?- phrase('les poules se sont postées le long de ce lac mais elles se sont noyées vers une cabane').
true .

?- phrase('la confiture est à ta mère mais le pain est à ce bûcheron').
true .

*/

/* Divers */
/*

?- phrase('les clients voluptueusement ne boivent pas devant le bar mais ils se frottent les verres').
true .

?- phrase('le grand chat bleu qui est très rapide mange la belle petite souris blanche qui était pourtant très mignonne').
true .

?- phrase('le grand chat bleu qui est très rapide mange la belle petite souris blanche que je regardais').
true .

?- phrase('le grand chat bleu est tellement rapide que je le regarde').
true .

?- phrase('ils sont devant la maison').
true .

?- phrase('les étoiles auxquelles je pense qui tombent doucement des cieux sont rouges et brillantes').
true .

?- phrase('tu as chassé ce grand chien qui est allemand mais il a mordu ton canard à la montagne de cette forêt verdoyante qui sent le fromage').
true .

?- phrase('cette phrase que je mange a pas un sens véritable mais elle est syntaxiquement correcte car je le vérifie par ce terminal').
true .

*/
