function [sNaam, typeVerdeling, ovkansenAfvoer, kSt, kMax, bovengrens, kappa]= bepaalStationGegevens(...
    keuzeStation, infileLobith, infileOlst, infileBorgharen, infileLith, infileDalfsen );


switch keuzeStation
    case 1
        sNaam = 'Lobith';
        typeVerdeling    = 'normaal';
        ovkansenAfvoer   = load(infileLobith);
        kSt   = 10;     %stapgrootte afvoergrid
        kMax  = 25000;  %maximum afvoergrid
        bovengrens = 0; %vlag voor aanwezigheid reele bovengrens
        kappa = 1e8;    %waarde bovengrens
        
    case 2
        sNaam = 'Olst';
        typeVerdeling    = 'normaal';
        ovkansenAfvoer   = load(infileOlst);
        kSt   = 2;     
        kMax  = 5000;  
        bovengrens = 0;
        kappa = 1e8;   
        
    case 3
        sNaam = 'Borgharen';
        typeVerdeling    = 'normaal';
        ovkansenAfvoer = load(infileBorgharen);
        kSt   = 2;     
        kMax  = 7000;  
        bovengrens = 0;
        kappa = 1e8;           
        
    case 4
        sNaam = 'Lith';
        typeVerdeling    = 'normaal';
        ovkansenAfvoer = load(infileLith);
        kSt   = 2;     
        kMax  = 7000;  
        bovengrens = 0;
        kappa = 1e8;   
        
    case 5
        sNaam = 'Dalfsen';
        typeVerdeling    = 'lognormaal';
        ovkansenAfvoer = load(infileDalfsen);
        kSt   = 1;     
        kMax  = 1200; 
                bovengrens = 1;
        kappa = 800;    %waarde bovengrens

end

