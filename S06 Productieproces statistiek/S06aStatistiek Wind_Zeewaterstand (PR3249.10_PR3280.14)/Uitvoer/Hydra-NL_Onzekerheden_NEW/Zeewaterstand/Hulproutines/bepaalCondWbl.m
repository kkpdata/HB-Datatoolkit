function [mPov] = bepaalCondWbl(m, sigWbl, alfWbl, omeWbl, lamWbl);

% Betreft P(M>m) voor m > omeWbl. I.h.b. geeft P(M > omeWbl).

mPov = lamWbl .* exp( -(m./sigWbl).^alfWbl + (omeWbl./sigWbl).^alfWbl );