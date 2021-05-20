function mPov = bepaalCondWbl(m, sigWbl, alfWbl, omeWbl, lamWbl)

mPov = lamWbl .* exp( -(m./sigWbl).^alfWbl + (omeWbl./sigWbl).^alfWbl );