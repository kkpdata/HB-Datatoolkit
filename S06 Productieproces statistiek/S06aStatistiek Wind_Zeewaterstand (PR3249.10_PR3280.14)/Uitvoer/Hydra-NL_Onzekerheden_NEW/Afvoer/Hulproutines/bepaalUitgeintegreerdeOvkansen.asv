function [vPov] = bepaalUitgeintegreerdeOvkansen(kGrid, kPov, typeVerdeling, kMu, kSig, kEps, vGrid, bovengrens, kappa);


% Bereken overschrijdingskansen van de (piek)afvoer incl. onzekerheid:
% Initialisatie:
vPov = zeros(length(vGrid), 1);

% Bapaal klassekansen: vector met waarden f(k)dk = P(K>k) - P(K>k+dk):
klassekansen      = kPov - circshift(kPov, -1);
klassekansen(end) = 0;  %maak laatste klasse 0



if bovengrens == 0                        % Situatie ZONDER bovengrens

    for i = 1 : length(vPov)

        % Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
        if strcmp(typeVerdeling, 'normaal')
            PovHulp     = 1 - normcdf( vGrid(i) - kGrid, kMu, kSig);   %vector van formaat mGrid

        elseif strcmp(typeVerdeling, 'lognormaal')
            kSigNormaal  = sqrt( log(1 + kSig.^2./(-kEps).^2) );
            kMuNormaal   = log( -kEps ) - 0.5 * kSigNormaal.^2;
            PovHulp     = 1 - normcdf( log(vGrid(i) - kGrid -kEps ), kMuNormaal, kSigNormaal);   %vector van formaat mGrid
        end

        Som         = PovHulp' * klassekansen;                    % waarde van de integraal
        vPov(i)     = Som;

    end


elseif bovengrens == 1                    % Situatie MET bovengrens

    %Maak k-grid dat loopt tot aan kappa, met bijbehorende grootheden
    Ind           = (kGrid <= kappa);
    kGrid0        = kGrid(Ind);
    %    kPov0         = kPov (Ind);
    klassekansen0 = klassekansen(Ind);
    kMu0          = kMu  (Ind);
    kSig0         = kSig (Ind);
    kEps0         = kEps (Ind);

    % Overschrijdingskans kappa:
    PovKappa = exp( interp1(kGrid, log(kPov), kappa, 'linear', 'extrap') );

    %Maak v-grid dat loopt tot aan kappa, met bijbehorende grootheden
    vGridTotKappa = vGrid(vGrid <= kappa);
    N             = length(vGridTotKappa);
    vPovTotKappa  = zeros(N,1);             %initialisatie


    % Berekening van integraal tot aan kappa, en toevoegen bijdrage boven kappa.

    for i = 1 : N

        % Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
        if strcmp(typeVerdeling, 'normaal')
            PovHulp0      = 1 - normcdf( vGridTotKappa(i) - kGrid0, kMu0, kSig0);   %vector van formaat mGrid
            % Bijdrage boven kappa
            BovenKappa    = PovKappa * (1 - normcdf( vGridTotKappa(end) - kappa, kMu0(end), kSig0(end)));

        elseif strcmp(typeVerdeling, 'lognormaal')
            kSigNormaal0  = sqrt( log(1 + kSig0.^2./(-kEps0).^2) );
            kMuNormaal0   = log( -kEps0 ) - 0.5 * kSigNormaal0.^2;
            PovHulp0      = 1 - normcdf( log(vGrid(i) - kGrid0 -kEps0 ), kMuNormaal0, kSigNormaal0);   %vector van formaat mGrid
            % Bijdrage boven kappa
            BovenKappa    = PovKappa * ( 1 - normcdf( log(vGridTotKappa(end) - kappa -kEps0(end) ), kMuNormaal0(end), kSigNormaal0(end)) );

        end

        % Integraal + bijdrage boven kappa
        Som0            = PovHulp0' * klassekansen0;       % waarde van de integraal tot aan kappa
        vPovTotKappa(i) = Som0 + BovenKappa;

    end
    
    % Vul de complete vector van langte vGrid:
    vPov(1:N) = vPovTotKappa(1:N);
    vPov(vGrid > kappa) = 1e-11;    %geef v boven kappa een heel kleine kans

end