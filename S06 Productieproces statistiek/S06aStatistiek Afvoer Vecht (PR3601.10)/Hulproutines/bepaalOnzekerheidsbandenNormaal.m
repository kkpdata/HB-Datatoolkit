function [bandOnderNorm, bandMiddenNorm, bandBovenNorm] = bepaalOnzekerheidsbandenNormaal(kGrid, kMuNorm, kSigNorm, pCI);


bandOnderNorm   = kGrid + kMuNorm + kSigNorm .* norminv((1-pCI)/2, 0, 1);
bandMiddenNorm  = kGrid + kMuNorm + kSigNorm .* norminv(0.5, 0, 1);
bandBovenNorm   = kGrid + kMuNorm + kSigNorm .* norminv(1-(1-pCI)/2, 0, 1);


