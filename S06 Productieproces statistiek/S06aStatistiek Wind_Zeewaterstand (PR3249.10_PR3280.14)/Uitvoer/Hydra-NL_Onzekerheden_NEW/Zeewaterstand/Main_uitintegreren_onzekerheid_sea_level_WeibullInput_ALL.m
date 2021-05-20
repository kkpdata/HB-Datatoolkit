%==========================================================================
% Script uitintegreren onzekerheid zeewaterstand
%
% De invoer is hier in de vorm van Weibulls gegeven.
%
% Door: Chris Geerse, Karolina Wojciechowska
% PR3216.10
% Datum: feb. 2016.
%
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\' '..\';

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

sNaam = 'OS11';
disp(['Analyse voor ',sNaam]);

% Windbestand:
switch sNaam
    case 'Hoek_van_Holland'

        infileZeewaterstand = 'Water level Hoek van Holland.txt';
        naamFig             = 'Hoek_van_Holland';
        naamTitle           = 'Hoek van Holland';

    case 'OS11'

        infileZeewaterstand = 'Water level OS11.txt'; %begin is Noord
        naamFig             = 'OS11';
        naamTitle           = 'OS11';

        %Bron: Afleiding_zeewaterstandstatistiek.xls met richtingkansen uit
        %WTI2017, ov.kans per windrichting 12-uur, volgorde windrichtingen
        %correct (360 is de eerste)!
        tabel_HYNL          = xlsread('Invoer\OS11_HYDRANL_r.xls'); %begin is Noord

end

% Inlezen invoer bij gekozen richting (laat zeespiegelstijging weg)

%dirnr	sigma	alpha	omega	lambda		Searise
wblPars = load(infileZeewaterstand);

%% Analyse voor 12 windrichtingen

for r = 1:12

    sigWbl(r)  = wblPars(r,2);
    alfWbl(r)  = wblPars(r,3);
    omeWbl(r)  = wblPars(r,4);
    lamWbl(r)  = wblPars(r,5);
    Pr(r)      = wblPars(r,8);

    % BEVATTEN DEZE PARAMETERS ZEESPIEGELSTIJGING?

    % Uitintegreren onzekerheid (additief model)
    % Model:
    % V_incl = Vexcl + Y.
    % Y ~ N(mMu, mSig).

    % Grid voor m-waarden (zonder onzekerheid)
    %     mMin  = omeWbl(r);
    mMin  = 1.62;
    mSt   = 0.01;
    mMax  = 8;
    mGrid = [mMin:mSt:mMax]';
    mHulp = [mMin:0.1:mMax]';

    % Grid voor v-waarden (met onzekerheid)
    vSt   = mSt;
    vMin  = mMin; %- 0.5;
    vMax  = mMax;
    vGrid = [vMin:vSt:vMax]';

    % Bepaal mu en sigma als functie van m:
    [mMu,mSig] = bepaalOnzekerheidNormaal(mGrid,sNaam);

    %======================================================================
    % Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid
    % Weibull
    %======================================================================

    % Initialisatie:
    vPov{r}           = zeros(length(vGrid),1);

    % Bapaal klassekansen: vector met waarden f(m)dm = P(M>m) - P(M>m+dm):
    % NB: bepaalCondWbl betreft P(M>m) voor m > omeWbl. I.h.b. geeft P(M > omeWbl).
    mPovHulp{r}       = bepaalCondWbl(mHulp,sigWbl(r),alfWbl(r),omeWbl(r),lamWbl(r));
    
    % Correct
    mPovHulp{r}(1)    = 1;
    mPovHulp{r}(2:3)  = exp(interp1(mHulp([1,4]),log(mPovHulp{r}([1,4])),mHulp(2:3)));
    mPov{r}           = exp(interp1(mHulp,log(mPovHulp{r}),mGrid,'linear','extrap'));
    
    klassekansen      = mPov{r}-circshift(mPov{r}, -1);
    klassekansen(end) = 0;  %maak laatste klasse 0

    for i = 1:length(vPov{r})

        % Bereken overschrijdingskans voor vGrid(i), incl. onzekerheid:
        PovHulp    = 1 - normcdf( vGrid(i) - mGrid, mMu, mSig);   %vector van formaat mGrid
        Som        = PovHulp' * klassekansen;                    % waarde van de integraal

        vPov{r}(i) = Som;

    end
    
    % Correct
    vPov{r}(1) = 1;
    
    %======================================================================
    % Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid
    % Table (alleen voor OS11)
    %======================================================================

    if strcmp(sNaam,'OS11')==1

        mPov_tabel{r}    = exp(interp1(tabel_HYNL(:,1),log(tabel_HYNL(:,r+1)),mGrid,'linear','extrap'));

        % Bereken overschrijdingskansen van zeewaterstanden incl. onzekerheid:
        typeVerdeling    = 'normaal';
        mEps             = 0;
        vPov_tabel{r}    = bepaalUitgeintegreerdeOvkansen(mGrid,mPov_tabel{r},typeVerdeling,mMu,mSig,mEps,vGrid);

        % Correct
        vPov_tabel{r}(1) = 1;
        
    end
 
end

%% Export data naar Hydra-NL format

%Export zonder onzekerheid Weibull
if strcmp(sNaam,'OS11')==1
    for r = 1:12
        mPov_Wbl_export(:,r) = exp(interp1(mGrid,log(mPov{r}),mHulp));
        vPov_Wbl_export(:,r) = exp(interp1(vGrid,log(vPov{r}),mHulp));
    end

    ind_exp = [2:12,1];
    X = [mHulp,mPov_Wbl_export(:,ind_exp)];
    wegschrijven_data('zeewaterstand_Weibull','2017',sNaam,X,10,0);

    X = [mHulp,vPov_Wbl_export(:,ind_exp)];
    wegschrijven_data('zeewaterstand_Weibull','2017_metOnzHeid',sNaam,X,10,1);
end

%Export zonder onzekerheid Tabel
if strcmp(sNaam,'OS11')==1
    for r = 1:12
        mPov_tab_export(:,r) = exp(interp1(mGrid,log(mPov_tabel{r}),mHulp));
        vPov_tab_export(:,r) = exp(interp1(vGrid,log(vPov_tabel{r}),mHulp));
    end

    ind_exp = [2:12,1];
    X = [mHulp,mPov_tab_export(:,ind_exp)];
%     wegschrijven_data('zeewaterstand_Weibull','_TAB_2017',sNaam,X,10,0);

    X = [mHulp,vPov_tab_export(:,ind_exp)];
%     wegschrijven_data('zeewaterstand_Weibull','_TAB_2017_metOnzHeid',sNaam,X,10,1);
end

%% Figuren

for r = 1:12

    % Figuur overschrijdingskans, zonder en met onzekerheid
    figure
    semilogy(mGrid,mPov{r},'b-','LineWidth',1.5); %zonder
    hold on
%     semilogy(vGrid,vPov{r},'r-','LineWidth',1.5); %met
    if strcmp(sNaam,'OS11')==1
        semilogy(mGrid,mPov_tabel{r},'c-o'); %met
%         semilogy(vGrid,vPov_tabel{r},'m-o'); %met
    end
    grid on
    title(['Conditionele overschrijdingskans zeewaterstand ',naamTitle,', r = ', num2str(r_fig(r))]);
    xlabel('Zeewaterstand [m+NAP]');
    ylabel('Overschrijdingskans [-]');
%     legend('WTI2017 Weibull excl.', 'WTI2017 Weibull incl.','WTI2017 tabel excl.','WTI2017 tabel incl.');
    legend('WTI2017 Weibull excl.', 'WTI2017 tabel excl.');
    ylim([1e-8, 1]);
    print(gcf,'-dpng',['Figuren\',naamFig,'_',num2str(r_fig(r)),'_12uur.png']);

    % Figuur overschrijdingsfrequentie/jaar, zonder en met onzekerheid
%     figure
%     semilogy(mGrid, 360*Pr(r)*mPov{r},'b-','LineWidth',1.5); %zonder
%     hold on
%     semilogy(vGrid, 360*Pr(r)*vPov{r},'r-','LineWidth',1.5); %met
%     if strcmp(sNaam,'OS11')==1
%         semilogy(mGrid,360*Pr(r)*mPov_tabel{r},'c-o'); %met
%         semilogy(vGrid,360*Pr(r)*vPov_tabel{r},'m-o'); %met
%     end
%     grid on
%     title(['Overschrijdingsfrequentie zeewaterstand ',naamTitle,' voor r = ', num2str(r_fig(r))]);
%     xlabel('Zeewaterstand [m+NAP]');
%     ylabel('Overschrijdingsfrequentie [1/jaar]');
%     legend('WTI2017 Weibull excl.', 'WTI2017 Weibull incl.','WTI2017 tabel excl.','WTI2017 tabel incl.');
%     ylim([1e-7, 1]);
%     print(gcf,'-dpng',['Figuren\',naamFig,'_',num2str(r_fig(r)),'_jaar.png']);

end

%% Check export

for r = 1:12

    % Figuur overschrijdingskans, zonder en met onzekerheid
    figure
    semilogy(mGrid,mPov{r},'b-'); %zonder
    hold on
    semilogy(mHulp,mPov_Wbl_export(:,r),'b-o'); %zonder
    semilogy(vGrid,vPov{r},'r-'); %met
    semilogy(mHulp,vPov_Wbl_export(:,r),'r-o'); %met
    if strcmp(sNaam,'OS11')==1
        semilogy(mGrid,mPov_tabel{r},'c-'); %met
        semilogy(mHulp,mPov_tab_export(:,r),'c-o'); %met
        semilogy(vGrid,vPov_tabel{r},'m-'); %met
        semilogy(mHulp,vPov_tab_export(:,r),'m-o'); %met
    end
    grid on
    title(['Conditionele overschrijdingskans zeewaterstand ',naamTitle,', r = ', num2str(r_fig(r))]);
    xlabel('Zeewaterstand [m+NAP]');
    ylabel('Overschrijdingskans [-]');
    legend('WTI2017 Weibull excl.', 'WTI2017 Weibull incl.','WTI2017 tabel excl.','WTI2017 tabel incl.');
    ylim([1e-8, 1]);
 
end

%% Extra may be needed later

%     clear ind_one
%     ind_one = find(mPov{r}>1);
% 
%     if length(ind_one)>0
%         r
%         mPov{r}(ind_one(1))     = 1;
%         mPov{r}(ind_one(2:end)) = interp1(mGrid([ind_one(1),ind_one(end)+1]),[mPov{r}(ind_one(1)),mPov{r}(ind_one(end)+1)],mGrid(ind_one(2:end)));
%     end
% 
%     clear ind_one
%     ind_one = find(vPov{r}>1);
% 
%     if length(ind_one)>0
%         r
%         vPov{r}(ind_one(1))     = 1;
%         vPov{r}(ind_one(2:end)) = interp1(vGrid([ind_one(1),ind_one(end)+1]),[vPov{r}(ind_one(1)),vPov{r}(ind_one(end)+1)],vGrid(ind_one(2:end)));
%     end
%     
%     if strcmp(sNaam,'OS11')==1
% 
%         clear ind_one
%         ind_one = find(mPov_tabel{r}>1);
% 
%         if length(ind_one)>0
%             r
%             mPov_tabel{r}(ind_one(1))     = 1;
%             mPov_tabel{r}(ind_one(2:end)) = interp1(mGrid([ind_one(1),ind_one(end)+1]),[mPov_tabel{r}(ind_one(1)),mPov_tabel{r}(ind_one(end)+1)],mGrid(ind_one(2:end)));
%         end
% 
%         clear ind_one
%         ind_one = find(vPov_tabel{r}>1);
% 
%         if length(ind_one)>0
%             r
%             vPov_tabel{r}(ind_one(1))     = 1;
%             vPov_tabel{r}(ind_one(2:end)) = interp1(vGrid([ind_one(1),ind_one(end)+1]),[vPov_tabel{r}(ind_one(1)),vPov_tabel{r}(ind_one(end)+1)],vGrid(ind_one(2:end)));
%         end
% 
%     end