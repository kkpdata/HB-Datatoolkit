function [sNaam, typeVerdeling, TgrensOnzHeid, ovkansenMeerpeil, sSt, sMax, pCI]= bepaalStationGegevensMeerpeil(...
    keuzeStation, infileIJsselmeer, infileMarkermeer, infileVRM, infileVZM, infileGRV);


% Keuze voor betrouwbaarheidsinterval normale of lognormale verdeling
pCI      = 0.95;    %1-pCI wordt gelijk verdeeld over onder- en bovenkant; default 0.95


switch keuzeStation
    case 1
        sNaam = 'IJsselmeer';
        typeVerdeling    = 'lognormaal';
        TgrensOnzHeid    = 30; %T (jaar) waaronder geen onzekerheid wordt beschouwd.
        % Reden: bij lage meerpeilen willen we geen afwijkingen
        % van de situatie zonder onzekerheid.
        
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
        TgrensOnzHeid    = 30;
        
        kansenInv             = load(infileMarkermeer);
        ovkansenMeerpeil(:,1) = kansenInv(:,1); %meerpeilniveaus uit de invoer
        % omrekening van T (in maanden) naar ovkansen in basisduur (60 dagen):
        ovkansenMeerpeil(:,2) = 1./(kansenInv(:,2)+eps);
        % Maak eerste kans precies gelijk aan 1:
        ovkansenMeerpeil(1,2) = 1;
        
        sSt   = 0.01;     %stapgrootte grid
        sMax  = 2.0;       %maximum grid
        
    case 3
        sNaam = 'VRM';
        typeVerdeling    = 'lognormaal';
        TgrensOnzHeid    = 30;
        
        kansenInv             = load(infileVRM);
        ovkansenMeerpeil(:,1) = kansenInv(:,1); %meerpeilniveaus uit de invoer
        ovkansenMeerpeil(:,2) = kansenInv(:,2);
        sSt   = 0.01;     %stapgrootte grid
        sMax  = 2.0;       %maximum grid
        
    case 4
        sNaam = 'VZM';
        typeVerdeling    = 'lognormaal';
        TgrensOnzHeid    = 30;
        
        kansenInv             = load(infileVZM);
        ovkansenMeerpeil(:,1) = kansenInv(:,1); %meerpeilniveaus uit de invoer
        ovkansenMeerpeil(:,2) = kansenInv(:,2);
        sSt   = 0.01;     %stapgrootte grid
        sMax  = 1.5;       %maximum grid
        
    case 5
        sNaam = 'GRV';
        typeVerdeling    = 'lognormaal';
        TgrensOnzHeid    = 30;
        
        kansenInv             = load(infileGRV);
        ovkansenMeerpeil(:,1) = kansenInv(:,1); %meerpeilniveaus uit de invoer
        ovkansenMeerpeil(:,2) = kansenInv(:,2);
        sSt   = 0.01;     %stapgrootte grid
        sMax  = 1.0;       %maximum grid
        
end

