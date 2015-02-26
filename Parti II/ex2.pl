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
conjonction_sub(csub(R))   --> [R],{conjonction_sub_(R, _, _, _, _, _)}.
conjonction_coor(ccoor(R)) --> [R],{conjonction_coor_(R, _, _, _, _, _)}.

% Adjectif simple
adjectif(adj(R), Type, Nombre) --> [R],{adjectif_(R, Type, _, Nombre, _, _)}.

% Participe comme adjectif
adjectif(adj(R), 'masculine', 'singular') --> [R],{analyse(R, _, participe, passe, 1)}.
adjectif(adj(R), 'feminine', 'singular')  --> [R],{analyse(R, _, participe, passe, 2)}.
adjectif(adj(R), 'masculine', 'plurial')  --> [R],{analyse(R, _, participe, passe, 3)}.
adjectif(adj(R), 'feminine', 'plurial')   --> [R],{analyse(R, _, participe, passe, 4)}.

% Autres
nom(n(R), Type, Nombre)                              --> [R],{nom_(R, Type, _, Nombre, _, _)}.
determinant(det(R), Type, Nombre)                    --> [R],{determinant_(R, Type, _, Nombre, _, _)}.
adverbe(adv(R))                                      --> [R],{adverbe_(R, _, _, _, _, _)}.
verbe_n(v(Aux, Mode, Personne), Mode, Personne, Aux) --> [R],{estverbe_n(Mode),analyse(R, Aux, Mode, _, Personne),!}.
verbe_infinitif(vi(R))                               --> [R],{genere(_, R, infinitif, _, _)}.
pronom_perso(pperso(R), Type, Nombre, Personne)      --> [R],{pronom_perso_(R, Type, Nombre, Personne)}.
pronom(p(R), Type, Nombre, Personne)                 --> [R],{pronom_(R, Type, _, Nombre, Personne, _)}.
pronom_perso_complement(ppersoc(R), Personne)        --> [R],{pronom_perso_complement_(R, Personne)}.
pronom_demonstratif(pdem(R), Nombre, Personne)       --> [R],{pronom_demonstratif_(R, Nombre, Personne)}.
pronom_relatif(prel(R), Type, Nombre)                --> [R],{pronom_relatif_(R, Type, Nombre)}.
pronom_relatif_inv(preli(R))                         --> [R],{pronom_relatif_inv_(R)}.
preposition(pre(R))                                  --> [R],{preposition_(R)}.

% Negation
negation_1 --> ['n\''].
negation_1 --> [ne].
negation_2 --> [pas].

% Impératif
imperatif_s(imp(R)) --> [R],{analyse(R, _, imperatif, _, 1)}.
imperatif_s(imp(R)) --> [R],{analyse(R, _, imperatif, _, 2)}.
imperatif_s(imp(R)) --> [R],{analyse(R, _, imperatif, _, 3)}.

/* ---------------------------------------------------------------------- */
/* PHRASES.                                                               */
/* ---------------------------------------------------------------------- */

separateur(sep(C, P)) --> conjonction_coor(C),partie_phrase(P).

partie_phrase(part(GN, GV, SEP)) --> groupe_nominal_principal(GN, T, N, P),groupe_verbal(GV, T, N, P, _),separateur(SEP).
partie_phrase(part(GN, GV, ''))  --> groupe_nominal_principal(GN, T, N, P),groupe_verbal(GV, T, N, P, _).

% Impératif
analyse_phrase(anphr(I, GN)) --> imperatif_s(I),groupe_nominal(GN, _, _, _).

% Phrases
analyse_phrase(anphr(P)) --> partie_phrase(P).

/* ---------------------------------------------------------------------- */
/* ADJECTIFS.                                                             */
/* ---------------------------------------------------------------------- */

suite_adjectifs(sadj(A, S), T, N)   --> adjectif(A, T, N),suite_adjectifs(S, T, N).
suite_adjectifs(sadj('', ''), _, _) --> [].

/* ---------------------------------------------------------------------- */
/* GROUPE NOMINAL.                                                        */
/* ---------------------------------------------------------------------- */

groupe_nominal_opt(gnopt(GN, C), T, N, P) --> groupe_nominal(GN, T, N, P),conjonction_coor_opt(C).
groupe_nominal_opt(gnopt('', ''), _, _, _) --> [].

forme_adverbe_opt(fadv(ADV, '')) --> adverbe(ADV).
forme_adverbe_opt(fadv(ADV, GN)) --> adverbe(ADV),groupe_nominal(GN, _, _, _).
forme_adverbe_opt(fadv('', ''))  --> [].

groupe_nominal_principal(gnp(GN, '', '', '', ''), T, N, P) --> groupe_nominal(GN, T, N, P).
groupe_nominal_principal(gnp(GN, '', '', '', ''), T, N, P) --> pronom_perso(GN, T, N, P).

% Introduction proposition relative
groupe_nominal_principal(gnp(GN, PREL, GNP, GV, GNO), T, N, P) --> groupe_nominal(GN, T, N, P),pronom_relatif(PREL, T, N),
                                                                   groupe_nominal_principal(GNP, T2, N2, P2),
                                                                   groupe_verbal(GV, T2, N2, P2, _),groupe_nominal_opt(GNO, _, _, _).

groupe_nominal_principal(gnp(GN, PREL, '', GV, GNO), T, N, P)  --> groupe_nominal(GN, T, N, P),pronom_relatif_inv(PREL),
                                                                   groupe_verbal(GV, T, N, P, _),groupe_nominal_opt(GNO, _, _, _).

pdetnom('singular', 3).
pdetnom('plural', 6).

complement_opt(copt(P, GN))  --> preposition(P),groupe_nominal(GN, _, _, _).
complement_opt(copt(P, GN))  --> preposition(P),groupe_nominal_abs(GN, _, _, _).
complement_opt(copt('', '')) --> [].

groupe_nominal_abs(gnabs(S1, NC, S2, ADV, C), T, N, P) --> suite_adjectifs(S1, T, N),nom(NC, T, N),suite_adjectifs(S2, T, N),
                                                           {pdetnom(N, P)},forme_adverbe_opt(ADV),complement_opt(C).

% Déterminant + Adjectif? + Nom + Adjectif? + Adverbe?
groupe_nominal(gn(D, GN), T, N, P) --> determinant(D, T, N),groupe_nominal_abs(GN, T, N, P).

% Pronom démonstratif + Adverbe?
groupe_nominal(gn(PR, ADV), _, N, P) --> pronom_demonstratif(PR, N, P),forme_adverbe_opt(ADV).

/* ---------------------------------------------------------------------- */
/* GROUPE VERBAL.                                                         */
/* ---------------------------------------------------------------------- */

conjonction_coor_opt(ccooropt(C, GN))  --> conjonction_coor(C),groupe_nominal_opt(GN, _, _, _).
conjonction_coor_opt(ccooropt('', '')) --> [].

adjectif_opt(adjopt(A, AC), T, N)  --> adjectif(A, T, N),adjectif_complement(AC, T, N).
adjectif_opt(adjopt('', ''), _, _) --> [].

adverbe_opt(advopt(A))  --> adverbe(A).
adverbe_opt(advopt('')) --> [].

adjectif_complement(adjc(C, A), T, N)   --> conjonction_coor(C),adjectif(A, T, N).
adjectif_complement(adjc('', ''), _, _) --> [].

pronom_perso_complement_opt(ppersocopt(T), P)  --> pronom_perso_complement(T, P).
pronom_perso_complement_opt(ppersocopt(''), _) --> [].

verbe_infinitif_opt(viopt(V)) --> verbe_infinitif(V).
verbe_infinitif_opt(viopt('')) --> [].

aux(être).
aux(avoir).
notaux(A) :- A\==être,A\==avoir.

% Sous ensembles
ens_1(en1(POP, V, ADV), P, A)  --> pronom_perso_complement_opt(POP, P),verbe_n(V, _, P, A),adverbe_opt(ADV).
ens_2(en2(ADV, ADJ, GN), T, N) --> adverbe_opt(ADV),adjectif_opt(ADJ, T, N),groupe_nominal_opt(GN, _, _, _).
ens_3(en3(ADV, VI, GN))        --> adverbe_opt(ADV),verbe_infinitif_opt(VI),groupe_nominal_opt(GN, _, _, _).

% Pronom_complement? + Verbe auxiliaire + adverbe? + adjectif (participe) + autre groupe nominal?
groupe_verbal_ens(gven(pos, E1, E2), T, N, P, A) --> ens_1(E1, P, A),{aux(A)},ens_2(E2, T, N).

% Pronom_complement? + Verbe + adverbe? + verbe infinitif? + autre groupe nominal?
groupe_verbal_ens(gven(pos, E1, E3), _, _, P, _) --> ens_1(E1, P, A),{notaux(A)},ens_3(E3).

% Même chose mais avec négation
groupe_verbal_ens(gven(neg, E1, E2), T, N, P, A) --> negation_1,ens_1(E1, P, A),{aux(A)},negation_2,ens_2(E2, T, N).
groupe_verbal_ens(gven(neg, E1, E3), T, N, P, A) --> negation_1,ens_1(E1, P, A),{aux(A)},negation_2,ens_3(E3).
groupe_verbal_ens(gven(neg, E1, E3), _, _, P, _) --> negation_1,ens_1(E1, P, A),{notaux(A)},negation_2,ens_3(E3).

groupe_verbal_p(gvps(G, '', '', ''), T, N, P, A) --> groupe_verbal_ens(G, T, N, P, A).

groupe_verbal_p(gvps(G, PR, GV, ''), T, N, P, A) --> groupe_verbal_ens(G, T, N, P, A),pronom_relatif_inv(PR),
                                                     groupe_verbal_ens(GV, _, _, _, _).

groupe_verbal_p(gvps(G, PR, GN, GV), T, N, P, A) --> groupe_verbal_ens(G, T, N, P, A),pronom_relatif(PR, T, N),
                                                     groupe_nominal_principal(GN, T2, N2, P2),groupe_verbal(GV, T2, N2, P2, _).

pre_opt(prepnopt(P, GN)) --> preposition(P),groupe_nominal(GN, _, _, _).
pre_opt(prepnopt('', '')) --> [].

groupe_verbal(gv(GV, POP), T, N, P, A) --> groupe_verbal_p(GV, T, N, P, A),pre_opt(POP).

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
