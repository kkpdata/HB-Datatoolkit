%==========================================================================
% Script uitintegreren onzekerheid wind
%
% Door:     Chris Geerse
% Project:  PR3216.10
% Datum:    november 2015 + januari 2016.
%
%
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

% Kies gewenste richting:
% 1 = N
% 2 = NNO
% ...
% ...
% 16 = NNW
% 17 = omni

% N	NNO	NO	ONO	O	OZO	ZO	ZZO	Z	ZZW	ZW	WZW	W	WNW	NW	NNW omni
% 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16  17

r_fig  = {'N','NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW','omni'};
rKeuze = 17;

% Station
% 1 = Schiphol
% 2 = Deelen

keuzeStation = 1;

% Windbestand:
if keuzeStation==1

    %    infileWindsnelheid = 'Wind speed Schiphol 16 directions.txt';
         infileWindsnelheid = 'Wind speed Schiphol 16 directions_inclOmni.txt';
    %    infileWindsnelheid  = 'Ovkanswind_Schiphol_Volkerfactor_2017_beginIsNoord.txt';
     infile_Pr           = 'Richtingskansen_Schiphol_2017beginN.txt';

%     infileWindsnelheid  = 'Ovkanswind_schiphol_12u_Caires2009_PR3140.txt';
%     infile_Pr           = 'Richtingskansen_Schiphol_2017beginN_PR3140.txt';

    sNaam              = 'Schiphol';

    % Parameters Y
    mu  = 1;
    sig = 0.047;


else

    infileWindsnelheid = 'Wind speed Deelen 16 directions.txt';
    infile_Pr          = 'Richtingskansen_Deelen_2017beginN.txt';
    sNaam              = 'Deelen';

    % Parameters Y
    mu  = 1;
    sig = 0.046;

end

disp(['Analyse voor ',sNaam,': r = ',num2str(rKeuze),', sigma = ',num2str(sig)]);

%% Inlezen overschrijdingskansen wind bij gekozen richting
ovkansenWind = load(infileWindsnelheid);
uInv         = ovkansenWind(:, 1);
uPovInv      = ovkansenWind(:, rKeuze + 1);

% Bepaal richtingskans
PrInv   = load(infile_Pr);
if rKeuze <= 16
    Pr      = PrInv(rKeuze, 2);
elseif rKeuze == 17  %omni
    Pr = 1;
end
% Label windrichting:
rLab = r_fig{rKeuze};


%% Uitintegreren onzekerheid (multiplicatief model, truncated)

% Model:
% V_incl = Vexcl * Y.
% Y ~ N(1, sig).
% NB. Verwaarloos de voorwaarde Y > 0



% Grid voor u-waarden
uSt   = 0.1;
uMin  = 0;
uMax  = 45;
uGrid = [uMin : uSt: uMax]';

% Grid voor y-waarden
ySt   = sig/100;
yMin  = mu - 4*sig;
yMax  = mu + 4*sig;
yGrid = [yMin : ySt: yMax]';

% Bereken overschrijdingskansen van windsnelheden incl. onzekerheid:

% Initialisatie:
uPovOnzeker = zeros(length(uGrid), 1);

for i = 1 : length(uGrid)

    % Bereken overschrijdingskans uGrid(i), incl. onzekerheid:
    PovHulp    = exp( interp1(uInv, log(uPovInv), uGrid(i)./yGrid, 'linear', 'extrap') );
    klassekans = normpdf(yGrid, mu, sig) * ySt;  %kans uit normale verdeling voor Y
    Som        = PovHulp' * klassekans;          % waarde van de integraal

    uPovOnzeker(i) = Som;

end

%% Figuren

OmrekenfactorOmni     = ones(17,1);
%OmrekenfactorOmni(17) = 1.2/2.0 * 12/16;   %Factor uit RW-model en andere sectorbreedte


% Figuur overschrijdingskans, zonder en met onzekerheid:
figure
semilogy(uInv, OmrekenfactorOmni(rKeuze)*uPovInv, 'g-','LineWidth',1.5);
hold on
semilogy(uGrid, OmrekenfactorOmni(rKeuze)*uPovOnzeker, 'r-','LineWidth',1.5);
grid on
title(['Conditionele overschrijdingskans windsnelheid ',sNaam,', r = ',rLab]);
xlabel('Windsnelheid [m/s]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Incl. onzekerheid');
ylim([1e-10, 1])

close all
% 
%% Figuur overschrijdingsfrequentie, zonder en met onzekerheid:
% 
Tkwantiel  = 1e4;

X =  1./(OmrekenfactorOmni(rKeuze)*360*Pr*uPovInv);
X = X + 1e-13*[1: 1: numel(X)]';

uTkwantiel = interp1( X, uInv, Tkwantiel, 'linear', 'extrap');

figure
semilogx(1./(OmrekenfactorOmni(rKeuze)*360*Pr*uPovInv), uInv, 'g-','LineWidth',1.5);
hold on
semilogx(1./(OmrekenfactorOmni(rKeuze)*360*Pr*uPovOnzeker), uGrid, 'r-','LineWidth',1.5);
grid on
%title(['Windsnelheid ',sNaam,', r = ', rLab, '; T = ', num2str(Tkwantiel),': u =  ', num2str((fix(100*uTkwantiel))/100),' m/s' ]);
title(['Windsnelheid ',sNaam,', r = ', rLab, '; T = ', num2str(Tkwantiel),': u =  ', num2str(uTkwantiel),' m/s' ]);
ylabel('Windsnelheid [m/s]');
xlabel('Terugkeertijd [jaar]');
legend('Zonder onzekerheid', 'Incl. onzekerheid', 'location', 'southeast');
xlim([1, 1e5])
