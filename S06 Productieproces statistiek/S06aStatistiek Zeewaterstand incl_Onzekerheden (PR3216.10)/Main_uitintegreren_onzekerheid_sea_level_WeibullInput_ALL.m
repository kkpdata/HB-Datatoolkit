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

r_fig  = [360,30,60,90,120,150,180,210,240,270,300,330];

sNaam = 'Hoek_van_Holland';
disp(['Analyse voor ',sNaam]);

% Windbestand:
infileZeewaterstand = 'Water level Hoek van Holland.txt';

% Inlezen invoer bij gekozen richting (laat zeespiegelstijging weg)

%dirnr	sigma	alpha	omega	lambda		Searise
wblPars = load(infileZeewaterstand);

%% Analyse voor 12 windrichtingen

for r = 1:12

    sigWbl(r)  = wblPars(r, 2);
    alfWbl(r)  = wblPars(r, 3);
    omeWbl(r)  = wblPars(r, 4);
    lamWbl(r)  = wblPars(r, 5);
    Pr(r)      = wblPars(r, 8);

    % BEVATTEN DEZE PARAMETERS ZEESPIEGELSTIJGING?

    % Uitintegreren onzekerheid (additief model)
    % Model:
    % V_incl = Vexcl + Y.
    % Y ~ N(mMu, mSig).

    % Grid voor m-waarden (zonder onzekerheid)
    mMin  = omeWbl(r);
    mSt   = 0.01;
    mMax  = 8;
    mGrid = [mMin : mSt: mMax]';

    % Grid voor v-waarden (met onzekerheid)
    vSt   = mSt;
    vMin  = mMin; %- 0.5;
    vMax  = mMax;
    vGrid = [vMin : vSt: vMax]';

    % Bepaal mu en sigma als functie van m:
    [mMu, mSig] = bepaalOnzekerheidNormaal(mGrid);

    % Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid:

    % Initialisatie:
    vPov{r}     = zeros(length(vGrid), 1);

    % Bapaal klassekansen: vector met waarden f(m)dm = P(M>m) - P(M>m+dm):
    % NB: bepaalCondWbl betreft P(M>m) voor m > omeWbl. I.h.b. geeft P(M > omeWbl).
    mPov{r}           = bepaalCondWbl( mGrid , sigWbl(r), alfWbl(r), omeWbl(r),lamWbl(r));
    klassekansen      = mPov{r} - circshift(mPov{r}, -1);
    klassekansen(end) = 0;  %maak laatste klasse 0

    for i = 1 : length(vPov{r})

        % Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
        PovHulp    = 1 - normcdf( vGrid(i) - mGrid, mMu, mSig);   %vector van formaat mGrid
        Som        = PovHulp' * klassekansen;                    % waarde van de integraal

        vPov{r}(i) = Som;

    end

    % Figuur overschrijdingskans, zonder en met onzekerheid:
    figure
    semilogy(mGrid, bepaalCondWbl( mGrid , sigWbl(r), alfWbl(r), omeWbl(r),lamWbl(r)),'b-','LineWidth',1.5);
    hold on
    semilogy(vGrid, vPov{r},'r-','LineWidth',1.5);
    grid on
    title(['Conditionele overschrijdingskans zeewaterstand Hoek van Holland, r = ', num2str(r_fig(r))]);
    xlabel('Zeewaterstand [m+NAP]');
    ylabel('Overschrijdingskans [-]');
    legend('Zonder onzekerheid', 'Incl. onzekerheid');
    ylim([1e-8, 1]);
    print(gcf,'-dpng',['Figuren\Hoek_van_Holland_',num2str(r_fig(r)),'_12uur.png']);

    % Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid:
    figure
    semilogy(mGrid, 360*Pr(r)*bepaalCondWbl( mGrid , sigWbl(r), alfWbl(r), omeWbl(r),lamWbl(r)),'b-','LineWidth',1.5);
    hold on
    semilogy(vGrid, 360*Pr(r)*vPov{r},'r-','LineWidth',1.5);
    grid on
    title(['Conditionele overschrijdingsfrequentie zeewaterstand Hoek van Holland, r = ', num2str(r_fig(r))]);
    xlabel('Zeewaterstand [m+NAP]');
    ylabel('Overschrijdingsfrequentie [1/jaar]');
    legend('Zonder onzekerheid', 'Incl. onzekerheid');
    ylim([1e-7, 1]);
    print(gcf,'-dpng',['Figuren\Hoek_van_Holland_',num2str(r_fig(r)),'_jaar.png']);

end

vPov = cell2mat(vPov);

%% Export data naar Hydra-NL format

X = [mGrid,vPov];
wegschrijven_data('zeewaterstand_Weibull',sNaam,X);