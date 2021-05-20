%==========================================================================
% Script uitintegreren onzekerheid zeewaterstand
%
% De invoer is hier in de vorm van Weibulls gegeven.
% 
% Door: Chris Geerse
% PR3216.10
% Datum: november 2015.
%
% 
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

% Kies gewenste richting:
% 1	 =	360
% 2	 =	30
% 3	 =	60
% 4	 =	90
% 5	 =	120
% 6	 =	150
% 7	 =	180
% 8	 =	210
% 9  =	240
% 10 =	270
% 11 =	300
% 12 =	330

rKeuze = 10;
r_fig  = [360,30,60,90,120,150,180,210,240,270,300,330]; 

% Windbestand:
infileZeewaterstand = 'Water level Hoek van Holland.txt';
disp('Analyse voor Hoek van Holland');

% Inlezen invoer bij gekozen richting (laat zeespiegelstijging weg)

%dirnr	sigma	alpha	omega	lambda		Searise
wblPars = load(infileZeewaterstand);

sigWbl  = wblPars(rKeuze, 2);
alfWbl  = wblPars(rKeuze, 3);
omeWbl  = wblPars(rKeuze, 4);
lamWbl  = wblPars(rKeuze, 5);
Pr      = wblPars(rKeuze, 8);

% BEVATTEN DEZE PARAMETERS ZEESPIEGELSTIJGING?

%% Uitintegreren onzekerheid (additief model)

% Model:
% V_incl = Vexcl + Y.
% Y ~ N(mMu, mSig).

% Grid voor m-waarden (zonder onzekerheid)
mMin  = omeWbl;
mSt   = 0.01;
mMax  = 8;
mGrid = [mMin : mSt: mMax]';

% Grid voor v-waarden (met onzekerheid)
vSt   = mSt;
vMin  = mMin; %- 0.5;
vMax  = mMax;
vGrid = [vMin : vSt: vMax]';

% Bepaal mu en sigma als functie van m:
[mMu, mSig]   = bepaalOnzekerheidNormaal(mGrid);

% Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid:

% Initialisatie:
vPov = zeros(length(vGrid), 1);

% Bapaal klassekansen: vector met waarden f(m)dm = P(M>m) - P(M>m+dm):
% NB: bepaalCondWbl betreft P(M>m) voor m > omeWbl. I.h.b. geeft P(M > omeWbl).
mPov              = bepaalCondWbl( mGrid , sigWbl, alfWbl, omeWbl,lamWbl);
klassekansen      = mPov - circshift(mPov, -1);
klassekansen(end) = 0;  %maak laatste klasse 0

for i = 1 : length(vPov)
    
    % Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
    PovHulp = 1 - normcdf( vGrid(i) - mGrid, mMu, mSig);   %vector van formaat mGrid
    Som     = PovHulp' * klassekansen;                    % waarde van de integraal
    
    vPov(i) = Som;
    
end

%% Figuren

% Figuur overschrijdingskans, zonder en met onzekerheid:
figure
semilogy(mGrid, bepaalCondWbl( mGrid , sigWbl, alfWbl, omeWbl,lamWbl),'b-','LineWidth',1.5);
hold on
semilogy(vGrid, vPov,'r-','LineWidth',1.5);
grid on
title(['Conditionele overschrijdingskans zeewaterstand Hoek van Holland, r = ', num2str(r_fig(rKeuze))]);
xlabel('Zeewaterstand [m+NAP]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Incl. onzekerheid');
ylim([1e-8, 1]);

% Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid:
figure
semilogy(mGrid, 360*Pr*bepaalCondWbl( mGrid , sigWbl, alfWbl, omeWbl,lamWbl),'b-','LineWidth',1.5);
hold on
semilogy(vGrid, 360*Pr*vPov,'r-','LineWidth',1.5);
grid on
title(['Conditionele overschrijdingsfrequentie zeewaterstand Hoek van Holland, r = ', num2str(r_fig(rKeuze))]);
xlabel('Zeewaterstand [m+NAP]');
ylabel('Overschrijdingsfrequentie [1/jaar]');
legend('Zonder onzekerheid', 'Incl. onzekerheid');
ylim([1e-7, 1]);