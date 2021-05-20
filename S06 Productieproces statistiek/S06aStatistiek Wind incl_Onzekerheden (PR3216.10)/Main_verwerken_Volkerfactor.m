%==========================================================================
% Script voor verwerken Volkerfactor in de wind voor Schiphol
%
% Door: Chris Geerse
% PR3216.10 (moet later nog extra worden betaald)
% Datum: november 2015.
%
%
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

infileWindsnelheid    = 'Ovkanswind_Schiphol_2017_ZWtmN.txt';
infileRichtingskansen = 'Richtingskansen_Schiphol_2017_ZWtmN.txt';
sNaam                 = 'Schiphol';


% Kies gewenste richting:
% ZW WZW W	WNW	NW	NNW N
% 1	 2	 3	4	5	6	7
r_fig  = {'ZW','WZW','W','WNW','NW','NNW','N'};


% Grid voor u-waarden
uSt   = 1;
uMin  = 0;
uMax  = 42;
uGrid = [uMin : uSt: uMax]';

% Aantal 12-uursblokken whjaar
N     = 360;

% Terugkeertijd voor overgangstraject naar Volkerfactor
Tkt   = 1;



for rKeuze = 1:7

    disp(['Analyse voor ',sNaam,': r = ',num2str(rKeuze)]);

    % Inlezen overschrijdingskansen wind bij gekozen richting
    ovkansenWind = load(infileWindsnelheid);
    uInv         = ovkansenWind(:, 1);
    uPovInv      = ovkansenWind(:, rKeuze + 1);

    % Inlezen richtingskansen bij gekozen richting
    rKansen      = load(infileRichtingskansen);
    Pr           = rKansen(rKeuze, 2);

    %% Bepaal de ovkansen op uGrid
    uPov = exp( interp1(uInv, log(uPovInv), uGrid, 'linear', 'extrap') );

    %% Bepaal de windsnelheid met T = 1 jaar
    Freq  = 1/Tkt;  %Freq = N*P(r)* P(U>u|r)
    uTkt  = interp1(log(uPov), uGrid, log(Freq/(N*Pr)), 'linear', 'extrap');
    % Rond overgangswindsnelheid af naar boven!
    uOvergang = ceil(uTkt);

    %% Bepaal aangepaste kansen (zie [Geerse et al, 2002] par 8.1).
    Factoren  = ones(numel(uGrid), 1);
    Factoren(uGrid == uOvergang - 1) = 0.9;
    Factoren(uGrid == uOvergang    ) = 0.8;
    Factoren(uGrid == uOvergang + 1) = 0.7;
    Factoren(uGrid == uOvergang + 2) = 0.6;
    Factoren(uGrid >  uOvergang + 2) = 0.5;

    % Nieuwe ovkansen inclusief Volkerfactor:
    uPovVolk  = uPov.*Factoren;

    % Sla gegevens op in een tabel
    uPovVolkTabel(:, rKeuze) = uPovVolk;

end

%% Bepaal de Volkerkansen op het originele grid

uPovVolk_OpOrigineelGrid = exp( interp1(uGrid, log(uPovVolkTabel), uInv, 'linear', 'extrap') );

%% Figuren

% Figuren overschrijdingskans, zonder en met Volkerfactor:

for rKeuze = 1 : 7
    figure
    semilogy(uInv, ovkansenWind(:, rKeuze + 1),'b-','LineWidth',1.5);
    hold on
    semilogy(uInv, uPovVolk_OpOrigineelGrid(:, rKeuze),'g-','LineWidth',1.5);
    grid on
    title(['Conditionele overschrijdingskans windsnelheid ',sNaam,', r = ',r_fig{rKeuze}]);
    xlabel('Windsnelheid [m/s]');
    ylabel('Overschrijdingskans [-]');
    legend('Origineel', 'Met Volkerfactor');
    ylim([1e-6, 1])
end