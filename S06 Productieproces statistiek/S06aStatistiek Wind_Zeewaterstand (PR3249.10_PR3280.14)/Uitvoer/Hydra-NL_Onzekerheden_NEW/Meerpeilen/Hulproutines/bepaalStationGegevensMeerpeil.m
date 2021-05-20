function [sNaam, typeVerdeling, ovkansenMeerpeil, sSt, sMax]= bepaalStationGegevensMeerpeil(...
    keuzeStation, infileIJsselmeer, infileMarkermeer );


switch keuzeStation
    case 1
        sNaam = 'IJsselmeer';
        typeVerdeling    = 'lognormaal';

        kansenInv             = load(infileIJsselmeer);
        ovkansenMeerpeil(:,1) = kansenInv(:,1); %meerpeilniveaus uit de invoer
        % omrekening van T (in maanden) naar ovkansen in basisduur (30 dagen):
        ovkansenMeerpeil(:,2) = 1./(kansenInv(:,2)+eps); 
        % Maak eerste kans precies gelijk aan 1:
        ovkansenMeerpeil(1,2) = 1;    
        
        sSt   = 0.01;      %stapgrootte grid, moet veel kleiner zijn dan de sigma uit de geassocieerde normale verdeling
        sMax  = 2.4;       %maximum grid

    case 2
        sNaam = 'Markermeer';
        typeVerdeling      = 'lognormaal';
        
        kansenInv             = load(infileMarkermeer);
        ovkansenMeerpeil(:,1) = kansenInv(:,1); %meerpeilniveaus uit de invoer
        % omrekening van T (in maanden) naar ovkansen in basisduur (60 dagen):
        ovkansenMeerpeil(:,2) = 1./(kansenInv(:,2)+eps); 
        % Maak eerste kans precies gelijk aan 1:
        ovkansenMeerpeil(1,2) = 1;    

        sSt   = 0.010;     %stapgrootte grid
        sMax  = 2.0;       %maximum grid

 
end

