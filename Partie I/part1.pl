% Une phrase
phrase --> groupe_nominal,groupe_verbal.

% Groupe nominal de base
groupe_nominal --> determinant,nom.

% Groupe nominal + Groupe prépositionnel
groupe_nominal --> groupe_nominal,groupe_nominal_prep.

% Groupe prépositionnel
groupe_nominal_prep --> preposition,groupe_nominal.

% Verbe simple
groupe_verbal --> verbe.

% Verbe + COD
groupe_verbal --> verbe,groupe_nominal.

% Verbe + COI
groupe_verbal --> verbe,groupe_nominal_prep.

% Verbe + COD + COI
groupe_verbal --> verbe,groupe_nominal,groupe_nominal_prep.
