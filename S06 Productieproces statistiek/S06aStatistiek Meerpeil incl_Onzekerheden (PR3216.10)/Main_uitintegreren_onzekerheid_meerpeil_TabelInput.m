%==========================================================================
% Script uitintegreren onzekerheid meerpeilen
%
% De invoer is hier in de vorm van een tabel gegeven.
%
% Door: Chris Geerse
% PR3216.10
% Datum: november 2015.
%
% Conclusie: keuzes van Deltares reproduceren (vrijwel) de onzekerheid uit
% PR2829.20. Wel heb ik voor de allerlaagste meerpeilen hun getallen iets
% aangepast.
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

% Bestand met overschijdingskansen (tabelvorm):
infileIJsselmeer = 'Water level IJssel lake.txt';
infileMarkermeer = 'Water level Marker lake.txt';

% Geef gewenste meer op:
% 1 = IJsselmeer
% 2 = Markermeer

keuzeStation = 1;

if keuzeStation==1
    OmrekeningKansNaarFreq = 6;
else
    OmrekeningKansNaarFreq = 3;
end

% Inlezen invoer bij gekozen richting (laat zeespiegelstijging weg):
[sNaam, typeVerdeling, ovkansenMeerpeil, sSt, sMax]= bepaalStationGegevensMeerpeil(...
    keuzeStation, infileIJsselmeer, infileMarkermeer );

disp(['Analyse voor ',sNaam]);

sInv    = ovkansenMeerpeil(:,1);
sPovInv = ovkansenMeerpeil(:,2);

% Grid voor s-waarden
sMin    = min(sInv);
sGrid   = [sMin : sSt: sMax]';

% Bepaal ovkansen op sGrid
sPov    = exp( interp1( sInv, log(sPovInv), sGrid, 'linear', 'extrap') );

%% Uitintegreren onzekerheid (additief model)

% Model (V = inclusief onzekerheid):
% V = M + Y.
% Y ~ ln N(mMuNormaal, mSigNormaal), wel met nog een verschuivingsterm daarbij.

% Grid voor v-waarden (met onzekerheid)
%vSt   = sSt;
vSt   = 0.001;
vMin  = sMin;
vMax  = sMax;
vGrid = [vMin : vSt: vMax]';

% Bepaal mu, sigma en Eps als functie van s:
[sMu, sSig, sEps] = bepaalOnzekerheidMeerpeil(keuzeStation, sGrid);

% Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid:
[vPov] = bepaalUitgeintegreerdeOvkansen(sGrid, sPov, typeVerdeling, sMu, sSig, sEps, vGrid);

%% Figuren

% Bepaal gegevens uit [Chbab, 2015]:
[TreeksChbab, ovkansenMeerpeilExOnzHeidChbab, ovkansenMeerpeilMetOnzHeidChbab]= bepaalGegevensChbab2015(...
    keuzeStation);

% Figuur overschrijdingskans, zonder en met onzekerheid:
figure
semilogy(sGrid, sPov,'b-','LineWidth',1.5);
grid on; hold on
semilogy(vGrid, vPov,'r-','LineWidth',1.5);
title(['Overschrijdingskans ', sNaam]);
xlabel('Meerpeil [m+NAP]');
ylabel('Overschrijdingskans [-]');
legend('Zonder onzekerheid', 'Incl. onzekerheid');
ylim([1e-12, 1]);
print(gcf,'-dpng',['Figuren\meerpeil_',sNaam,'_periode.png']);

close all

% Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid:
figure
semilogx(1./(OmrekeningKansNaarFreq*sPov),sGrid,'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(OmrekeningKansNaarFreq*vPov),vGrid,'r-','LineWidth',1.5);
semilogx(TreeksChbab, ovkansenMeerpeilMetOnzHeidChbab,'k--','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
xlabel('Terugkeertijd [jaar]')
ylabel('Meerpeil [m+NAP]');
legend('Zonder onzekerheid', 'Incl. onzekerheid','Incl. onzekerheid [Chbab2015]','location', 'SouthEast');
xlim([1, 1e5]);
ylim([-0.20, 1.4])
print(gcf,'-dpng',['Figuren\meerpeil_',sNaam,'_jaar.png']);

% %% Export data naar Hydra-NL format
% 
%  vPov_kort = exp(interp1(vGrid,log(vPov),sInv));
%  X         = [sInv,vPov_kort];
% 
% wegschrijven_data('meerpeil',sNaam,X);


% Tbv tabel in tool waterstandsverlopen
Herhalingstijden                     = [1, 10, 30, 50:50:100000]';
% Bepaal bijbehorende meerpeilen met onz.heid, maar zorg dat je niet onder
% de lijn zonder onzekerheid komt:
MeerpeilenBijHerhalingstijdHulp      = interp1(1./(OmrekeningKansNaarFreq*vPov),vGrid, Herhalingstijden,'linear', 'extrap');
MeerpeilenBijHerhalingstijdZonderOnz = interp1(1./(OmrekeningKansNaarFreq*sPov),sGrid, Herhalingstijden,'linear', 'extrap');
MeerpeilenBijHerhalingstijd          = max(MeerpeilenBijHerhalingstijdHulp, MeerpeilenBijHerhalingstijdZonderOnz);

% Controlefiguur
figure
semilogx(1./(OmrekeningKansNaarFreq*sPov),sGrid,'b-','LineWidth',1.5);
grid on; hold on
semilogx(1./(OmrekeningKansNaarFreq*vPov),vGrid,'r-','LineWidth',1.5);
semilogx(TreeksChbab, ovkansenMeerpeilMetOnzHeidChbab,'k--','LineWidth',1.5);
semilogx(Herhalingstijden, MeerpeilenBijHerhalingstijd,'g--','LineWidth',1.5);
title(['Overschrijdingsfrequentie ', sNaam]);
xlabel('Terugkeertijd [jaar]')
ylabel('Meerpeil [m+NAP]');
legend('Zonder onzekerheid', 'Incl. onzekerheid','Incl. onzekerheid [Chbab2015]','Incl. onzekerheid na aanpas lagere deel ','location', 'SouthEast');
xlim([1, 1e7]);
ylim([-0.20, 1.8])
print(gcf,'-dpng',['Figuren\meerpeil_',sNaam,'_jaar.png']);

