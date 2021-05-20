%==========================================================================
% Hoofdprogramma Markermeer
% Door: Chris Geerse
% Tbv: PR1322

%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
%padnaam_uit = 'D:\Users\geerse\Matlab\Stat_Rivieren_Meren_Wind\'
padnaam_uit = 'C:\Matlab\Stat_Rivieren_Meren_Wind\'

%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
%homogenisatieparameters
zichtjaar = 2011;        %homogenisatie naar 1 jan van zichtjaar
stijging_per_jaar = 0.00; %aangenomen stijging per jaar in m 

%geef hier de gewenste selectie aan:
bej = 1976; bem = 1; bed = 1;
%bej = 1976; bem = 10; bed = 1;
eij = 2008; eim = 4; eid = 1;

%Overige parameters
drempel = -0.14;         % variabele voor drempel waarde (drempel -0.14 levert 11 golven, drempel -0.15 levert ca 14 golven, met smallere toppen)
ref_niv = -0.4;          %referentieniveau van waaraf wordt opgeschaald
basis_niv = -0.4;        %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999;       %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;            %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet

%parameters trapezia
B     = 60;             %basisduur trapezia
zpot  = floor(B/2);     % zichtduur voor selectie pieken; NB: kies 15 dagen voor beoordelen werklijn (bij 30 dagen vallen er veel pieken weg)
zB    = floor(B/2);     %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven
bpiek = 4;              %topduur (dagen) trapezium wordt hier tbv topduur_inv en plaatje ingesteld. DEFAULT 4 dagen
% av = 0.8;     %niveau insnoering in verticale richting
% ah = 0.025;     %mate insnoering in horizontale richting
av = 0.9999;     %niveau insnoering in verticale richting
ah = 0.9999;     %mate insnoering in horizontale richting

if (ah > 1/(1-av))
    disp(['ah      = ', num2str(ah)])
    hulp = 1/(1-av); disp(['1/(1-av = ', num2str(hulp)])
    disp('FOUT: Er dient voldaan te zijn aan ah <= 1/(1-av)!')
    disp('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end


topduur_inv = ...       %Keuze voor PR1371.30
    [-0.40, B*24;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    -0.22, bpiek*24;
    1.80, bpiek*24]

Ntrapezia      = 180/B;
ovkanspiek_inv = ...       %Keuze voor PR1371.30
    [-0.4, 1;
    -0.22, 1/Ntrapezia;    %traject van -0.22 tot 1.00 m+NAP volgens Hydra-M, wel gedeeld door aantal trapezia in whjaar
    1.00, 3.0419E-06/Ntrapezia]
%    1.55, 1.01e-8/Ntrapezia]

% topduur_inv = ...       %tbv verkrijgen dagenlijn Hydra-M
%     [-0.40, B*24;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
%     -0.22, 2*96;
%     -0.10, 1.5*96;
%     0.2,   2*48;
%     0.4,  24;
%     1.80, 12]
Nrijen = numel(topduur_inv(:,1));
bpiek  = topduur_inv(Nrijen,2);

if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)

%parameters meerpeil
stapy = 0.01;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax  = 1.6;        %maximum van vector

%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all   %opdat geen lege figuur wordt getoond

%==========================================================================
%Inlezen van Hydra-M statistiek
%==========================================================================
%--------------------------------------------------------------------------
%Inlezen Hydra-M statistiek, respectievelijk:
%m, m+NAP; OF, 1/whjaar; OD, dag/whjaar; ODwest, dag/whjaar; ODoost, dag/whjaar
[m_HM, OF_HM, OD_HM, OD_HMwest, OD_HMoost] = textread('statistiek_Hydra_M_Markermeer.txt','%f %f %f %f %f','delimiter',' ','commentstyle','matlab');

%--------------------------------------------------------------------------
%Inlezen data
[dag, maand, jaar, data] = textread('Markermeermetingen.dat','%f %f %f %f','delimiter',' ','commentstyle','matlab');
datum                    = datenum(jaar,maand,dag); 

% Ontbrekende waarden zijn weergegeven als -999 (periode 3 juni - 31
% december 1981)
% Selecteer alleen geldige waarnemingen.
Fgeldig     = find(data > -999);
dag         = dag(Fgeldig);
maand       = maand(Fgeldig);
jaar        = jaar(Fgeldig);
data        = data(Fgeldig);
datum       = datum(Fgeldig);


%==========================================================================
%Selectie whjaren en berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);

selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));
%selectie = find(datum >= bedatum & datum <= eidatum);

jaar = jaar(selectie); maand = maand(selectie); dag = dag(selectie); data = data(selectie);
datum = datenum(jaar,maand,dag);
dagnr = (1:numel(data))';

%Plaatje van tijdreeks
%Figuur_Tijdreeks_MM_formatMatlab
Figuur_Tijdreeks_MM     %In Word geen goede weergave, maar geprint wel!

%==========================================================================
%Kleine trend analyse
%==========================================================================
trendBepalen_MM;

%--------------------------------------------------------------------------
%NB: voor VRM trendcorrectie 0 nemen!!
%Trendcorrectie toepassen op de meerpeilen (neem de correctie binnen één
%jaar steeds hetzelfde. Homogenisatie naar 1 jan van het zichtjaar.
datum_zichtjaar = datenum(zichtjaar,1,1);
delta_meerpeil = (datum_zichtjaar-datum)*stijging_per_jaar/365.25;
data = data + delta_meerpeil;

%close all
%==========================================================================
%Selecteren van (niet aangepaste) golven uit datareeks
%==========================================================================
[golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);
%golfkenmerken: matrix met gegevens van de golven
%golven =
%1xaantal_golven struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    piek
%    rang
%    tijd
%    data
%
% 


%==========================================================================
%Aanpassen van golven: piek/dal-verbreding en monotone voor- en
%achterflanken maken door nevenpieken tegen hoofdpiek te plakken.
%Resultaat: aangepaste golven (stijgende voor- en dalende achterflank) en (gemiddelde)
%standaard(norm)golfgegevens.

[golven_aanpas, standaardvorm] = opschaling(...
golven,ref_niv,piekduur,nstapv,fig_golven_verbreed,fig_golven_rel,fig_opschaling);

%golven_aanpas =
%1*aantal_golven struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    piek
%    rang
%    tijd
%    data

%standaardvorm =
%          v: [Nx1 double]
%      tvoor: [Nx1 double]
%    tachter: [Nx1 double]
%         fv: [Nx1 double]
%[standaardvorm.v standaardvorm.tvoor standaardvorm.tachter standaardvorm.fv]

%==========================================================================
% Plotten van geselecteerde golven tezamen met trapezium.
%==========================================================================

plot_MMgolven(golven, ref_niv, B, topduur_inv);


%==========================================================================
% Plotten van geselecteerde golven, standaardvorm en trapezium.
%==========================================================================

aantal_golven = max([golven.nr]);
v = standaardvorm.v;


%close all

figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on
%ook versie met dicreet geturfde overschr.uren:
%plot(standaardvorm_discreet.tvoor,v,'k',standaardvorm_discreet.tachter,v,'k');  
x = [-B/2, -bpiek/2, bpiek/2, B/2]';
%x = [-B/2, -bpiek/2+1.5, bpiek/2+1.5, B/2]'; %tijdelijk
y = [0, 1, 1, 0]';
plot(x,y,'r');

ltxt  = [];
ttxt  = 'Gemiddelde golf Markermeer met trapezium';
xtxt  = 'tijd, dagen';
ytxt  = 'relatief meerpeil, [-]';
Xtick = -B/2:5:B/2;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



%==========================================================================
% Momentane ov.kans volgens berekening met trapezia
%==========================================================================

%[berek_trap] = grootheden_trap(stapy, ymax, basis_niv, B, topduur_inv, ovkanspiek_inv);

[berek_trap] = grootheden_kniktrap(stapy, ymax, basis_niv, B, av, ah, topduur_inv, ovkanspiek_inv)
%         y: [Nx1 double]
%         by: [Nx1 double]
%    fy_piek: [Nx1 double]
%    Gy_piek: [Nx1 double]
%     fy_mom: [Nx1 double]
%     Gy_mom: [Nx1 double]

[berek_trap.y,berek_trap.by, berek_trap.fy_piek, ...
   berek_trap.Gy_piek, berek_trap.fy_mom, berek_trap.Gy_mom];

%wegschrijven onderschrijdingskans MM tbv correlatiemodel
%onderschrijdkans_MM = [berek_trap.y, 1-berek_trap.Gy_piek];
%save([padnaam_uit,'F_MM.txt'],'onderschrijdkans_MM','-ascii')

%Saven van momentane kansen naar een tabel
k_kolom = [-0.40:0.01:1.80]';   %Deze stapgroottes bij voorkeur niet veranderen
tabelmomkans = [k_kolom, interp1(berek_trap.y, berek_trap.Gy_mom, k_kolom)];
%save([padnaam_uit,'momkans_MM_berekend_met_stapy',num2str(stapy),'_ymax',num2str(ymax),'.txt'],'tabelmomkans','-ascii')

figure
plot(berek_trap.y,berek_trap.by, 'b')
grid on
hold on
ltxt  = []
ttxt  = 'Topduur trapezia Markermeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'topduur, uur';
Xtick = -0.4:0.2:1.0;
Ytick = 0:200:1600;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)




%==========================================================================
% Momentane ov.kans volgens de metingen (observaties)
%==========================================================================
yturf = [(-0.5: stapy : ovkanspiek_inv(1,1))'; berek_trap.y];
[mom_obs] = turven_metingen(yturf, data);
%mom_obs =
%     y: [Nx1 double]       %vector met afvoerniveaus (= berek_trap.y)
%    Gy: [Nx1 double]       %momentane ov.kansen
%    fy: [Nx1 double]       %momentane kansdichtheid

%[mom_obs.y mom_obs.Gy mom_obs.fy ]

%==========================================================================
% Plotposities met werklijn
%==========================================================================
obs = golfkenmerken(:,5);   %piekwaarde
r = golfkenmerken(:,6);     %rang van piekwaarde
n = max(r);                 % aantal meegenomen extreme waarden
t_per = numel(data)/182; % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)

%close all

figure
plotpos = zeros(n,1);      %initialisatie
for i = 1:n
plotpos(i) = ((n+c)*t_per)/((r(i)+c+d-1)*n);
end
p1 = semilogx(plotpos,obs,'r*');
hold on
grid on

%wlijn: k1 = afvoer, k2 = T
wlijn = [ovkanspiek_inv(:,1), 1./(Ntrapezia*ovkanspiek_inv(:,2))];
plot(wlijn(:,2),wlijn(:,1));
ltxt = [];
ttxt  = ['werklijn en data Markermeer'];
xtxt  = 'terugkeertijd, jaar';
ytxt  = 'meerpeil, m+NAP';
Xtick = [];
Ytick = -.4:0.1:1.1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
% Diverse plaatjes golven
%==========================================================================
%close all
figure
for i = 1:aantal_golven
    plot(golven(i).tijd, golven(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Gemeten golven Markermeer';
xtxt  = 'tijd, dagen';
ytxt  = 'meerpeil, m+NAP';
Xtick = -floor(B/2):5:floor(B/2);
Ytick = -0.4:.2:0.2;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven Markermeer';
xtxt  = 'tijd, dagen';
ytxt  = 'meerpeil, m+NAP';
Xtick = -floor(B/2):5:floor(B/2);
Ytick = -0.4:.2:0.2;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%nu golven op 1 genormeerd
figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, (golven_aanpas(i).data-ref_niv)./(max(golven_aanpas(i).data)-ref_niv),'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven Markermeer na normering op 1';
xtxt  = 'tijd, dagen';
ytxt  = 'relatief meerpeil, [-]';
Xtick = -floor(B/2):5:floor(B/2);
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all

%==========================================================================
% Plaatjes momentane kansen volgens de metingen en volgens de integratie
%==========================================================================
%gemiddeld meerpeil
mpgem_data = mean(data)
stdev_data = std(data)
mpgem_trap = sum(berek_trap.fy_mom*stapy .*berek_trap.y)
stdev_trap = (sum(berek_trap.fy_mom*stapy .*(berek_trap.y).^2) - mpgem_trap^2)^0.5

%close all

figure
plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
grid on
hold on
cltxt  = {'observatie','integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Markermeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = -0.5:0.1:0.8;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all
figure
plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold off
cltxt  = {'observatie','integratie (trapezia)'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Markermeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = -0.5:0.1:0.8;
Ytick = -10:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all
%gemiddelde topduur als quotiënt van B*P(M>m)/P(S>s).
figure
topduurgem_trap = B*(berek_trap.Gy_mom)./berek_trap.Gy_piek;
plot(berek_trap.y,topduurgem_trap)
grid on
hold on
ltxt = [];
ttxt  = 'Overschrijdingsduur per top Markermeer';
xtxt  = 'Markermeer peil, m+NAP';
ytxt  = 'topduur, dagen';
Xtick = -0.5:0.2:1.1;
Ytick = 0:2:32;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



%close all

%==========================================================================
% Vergelijking Hydra-M en Hydra-VIJ statistiek
%==========================================================================

%werklijnen en data
figure
semilogx(wlijn(:,2),wlijn(:,1),'b-.');
hold on
grid on
plot(1./OF_HM, m_HM, 'k');
semilogx(plotpos,obs,'r*');
cltxt  = {'Hydra-VIJ','Hydra-M','data'};
ltxt  = char(cltxt);
ttxt  = ['werklijnen Hydra-M en Hydra-VIJ Markermeer'];
xtxt  = 'terugkeertijd, jaar';
ytxt  = 'meerpeil, m+NAP';
Xtick = [];
Ytick = -0.4:0.2:0.8;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

close all

% %Zelfde plaatje, maar andere layout
% figure
% semilogx(wlijn(:,2),wlijn(:,1),'b-.');
% hold on
% grid on
% plot(1./OF_HM, m_HM, 'k');
% semilogx(plotpos,obs,'r*');
% title('Frequentielijnen en data Markermeer');
% xlabel('terugkeertijd, jaar');
% ylabel('meerpeil, m+NAP');
% xlim([1e-1 1e4])
% ylim([-0.4 0.8]);
% legend('Hydra-VIJ','Hydra-M','data')
% 


%momentane kansen en data
%close all

% figure
% plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
% grid on
% hold on
% plot(m_HM, OD_HM/OD_HM(1),'k')
% cltxt  = {'data','Hydra-VIJ','Hydra-M'};
% ltxt  = char(cltxt);
% ttxt  = 'Momentane kansen Hydra-M en Hydra-VIJ Markermeer';
% xtxt  = 'meerpeil, m+NAP';
% ytxt  = 'momentane overschrijdingskans, [-]';
% Xtick = -0.5:0.1:0.8;
% Ytick = 0:0.1:1;
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all
figure
plot(mom_obs.y,log(mom_obs.Gy),'r',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold on
plot(m_HM, log(OD_HM/OD_HM(1)),'k-')
cltxt  = {'op basis geturfde data','Hydra-VIJ','Hydra-M'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Markermeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = -0.4:0.1:0.7;
Ytick = -16:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



%close all
%gemiddelde topduur als quotiënt van B*P(M>m)/P(S>s).
figure
topduurgem_trap = B*(berek_trap.Gy_mom)./berek_trap.Gy_piek;
grid on
hold on
plot(berek_trap.y,topduurgem_trap,'b-.')
plot(m_HM, OD_HM./OF_HM,'k')
cltxt  = {'Hydra-VIJ','Hydra-M'};
ltxt  = char(cltxt);
ttxt  = 'Overschrijdingsduur per top Hydra-M en Hydra-VIJ Markermeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'topduur, dagen';
Xtick = -0.4:0.1:0.8;
Ytick = 0:5:50;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

figure
topduurgem_trap = B*(berek_trap.Gy_mom)./berek_trap.Gy_piek;
grid on
hold on
plot(berek_trap.y,topduurgem_trap,'b-.')
plot(m_HM, OD_HM./OF_HM,'k')
legend('Hydra-Zoet','Hydra-M');
ltxt  = char(cltxt);
title('Overschrijdingsduur per top Hydra-M en Hydra-Zoet Markermeer');
xlabel('Meerpeil, m+NAP');
ylabel('Topduur, dagen');
xlim([-0.2 1.0])




% aantal_golven

disp('EIND')