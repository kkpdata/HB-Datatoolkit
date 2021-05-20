%==========================================================================
% Scrindexpt voor snelle analyse Rak Noord
%
% Door: Chris Geerse
% PR3598.10
% Datum: mei 2017.
%
%
%==========================================================================
%==========================================================================
% Algemeen
%==========================================================================

clc
clear all
close all
addpath 'Hulproutines\' 'invoer\';

%==========================================================================
% Algemene invoer
%==========================================================================

drempel     = 100;    %cm+NAP
zpot        = 15*24;     %voor wind in plaatjes bijv. 24 nemen; voor afvoeren 15*24
zB          = zpot;   %halve breedte venster

% Tbv plotposities:
c = 0.12;   %Gringorton
d = 0.44;


%% Lees data in:
A      = load('id1-RAKND.mat');
Datum  = A.data.t;
wsOrig = A.data.h;
clear A;

figure
plot(Datum, wsOrig)
grid on
title('Tijdsverloop waterstand Rak Noord')
xlabel('Datum')
ylabel('Waterstand, cm+NAP')
datetick('x',1)

% close all

%% Maak uurwaarden
DatumInfo = datevec(Datum);
jaar   = DatumInfo(:,1);
maand  = DatumInfo(:,2);
dag    = DatumInfo(:,3);
uur    = DatumInfo(:,4);
minuut = DatumInfo(:,5);

% Maak uurwaarden; waarde op minuut 0.
F      = find(minuut ==0);
jaar   = jaar(F);
maand  = maand(F); 
dag    = dag(F);   
uur    = uur(F);   
minuut = minuut(F);
ws     = wsOrig(F);
Datum  = Datum(F);

% Trendcorrectie
trendPerJaar = 0.2/100;
ws = ws + (2017 - jaar)*trendPerJaar;
ws = 100*ws;    %Maak eenheid cm+NAP

%==========================================================================
% Selectie meetperiode
%==========================================================================

%geef hier de gewenste selectie aan:
bej = 2000; bem = 10; bed = 1;
eij = 2016; eim = 3; eid = 31;

bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(Datum >= bedatum & Datum <= eidatum));


jaar   = jaar(selectie);
maand  = maand(selectie);
dag    = dag(selectie);
ws     = ws(selectie);
uur    = uur(selectie);
minuut = minuut(selectie);
nn     = length(ws);
Datum  = datenum(jaar,maand,dag, uur, minuut, zeros(nn,1));
dagnr  = (1:numel(ws))';



figure
plot(Datum, ws)
grid on
title('Tijdsverloop waterstand Rak Noord (incl. trendcorrectie)')
xlabel('Tijd')
ylabel('Waterstand, m+NAP')
datetick('x',10)

%% Inlezen Hydra-NL uitvoer
Berek_zonz =...
   [2.000000      0.2494814    
   2.100000      0.1375687    
   2.200000      5.1929861E-02
   2.300000      1.9196482E-02
   2.400000      6.5202471E-03
   2.500000      2.0206189E-03
   2.600000      4.6597893E-04
   2.700000      1.6106773E-04
   2.800000      7.5357042E-05
   2.900000      4.0701609E-05
   3.000000      2.3048229E-05
   3.100000      1.3237445E-05
   3.200000      7.6665001E-06];

Berek_monz =...
   [2.300000      0.1458158    
   2.400000      8.2067505E-02
   2.500000      4.3332212E-02
   2.600000      2.2932358E-02
   2.700000      1.0883286E-02
   2.800000      4.9801855E-03
   2.900000      2.2104853E-03
   3.000000      7.6054083E-04
   3.100000      2.5383569E-04
   3.200000      8.8241854E-05
   3.300000      3.0381703E-05
   3.400000      1.1208922E-05
   3.500000      5.6719928E-06];

Berek_zonz_EP1 =...
   [2.100000     0.1516171    
   2.200000      9.0394974E-02
   2.300000      5.3182404E-02
   2.400000      3.1280834E-02
   2.500000      1.8549673E-02
   2.600000      1.1096720E-02
   2.700000      6.6787833E-03
   2.800000      4.0392997E-03
   2.900000      2.4472636E-03
   3.000000      1.4845659E-03
   3.100000      9.0143213E-04
   3.200000      5.4991920E-04
   3.300000      3.3784000E-04
   3.400000      2.0908948E-04
   3.500000      1.3024578E-04
   3.600000      8.1492712E-05
   3.700000      5.1075687E-05
   3.800000      3.2026172E-05
   3.900000      2.0150414E-05
   4.000000      1.2765450E-05
   4.100000      8.1657363E-06];

Berek_monz_EP1 =...
   [2.300000      0.1604536    
   2.400000      9.6611515E-02
   2.500000      5.7611682E-02
   2.600000      3.4211136E-02
   2.700000      2.0290617E-02
   2.800000      1.2036746E-02
   2.900000      7.1579209E-03
   3.000000      4.2689540E-03
   3.100000      2.5564521E-03
   3.200000      1.5405397E-03
   3.300000      9.3493308E-04
   3.400000      5.7096482E-04
   3.500000      3.5086603E-04
   3.600000      2.1698770E-04
   3.700000      1.3507124E-04
   3.800000      8.4672844E-05
   3.900000      5.3474654E-05
   4.000000      3.4034769E-05
   4.100000      2.1832882E-05
   4.200000      1.4113155E-05
   4.300000      9.1894399E-06];


wsHNL_zonz = 100*Berek_zonz(:,1);
T_HNL_zonz = 1./Berek_zonz(:,2);

wsHNL_monz = 100*Berek_monz(:,1);
T_HNL_monz = 1./Berek_monz(:,2);

wsHNL_zonz_EP1 = 100*Berek_zonz_EP1(:,1);
T_HNL_zonz_EP1 = 1./Berek_zonz_EP1(:,2);

wsHNL_monz_EP1 = 100*Berek_monz_EP1(:,1);
T_HNL_monz_EP1 = 1./Berek_monz_EP1(:,2);

%==========================================================================
% Selecteren van waterstandpieken (met zichtduur)
%==========================================================================

X = ws;
Y = ws; %dummy
Z = ws; %dummy
[golfkenmerken, golven] = piekenselectie(drempel,zpot,zB,jaar,maand,dag,uur,X,Y,Z);


%% Bepaal frequentielijn met plotposities
obs      = [golven.piek]';   %kolomvector met maxima
N        = numel(obs);
obs_sort = sort(obs, 'descend');
t_per    = jaar(end) - jaar(1);


% Plotpositie voor ovfreq en terugkeertijd:
plotposFreq  = N/(N+c)*([1:N]'+c+d-1)/t_per;
plotposT     = 1./plotposFreq;

close all

figure
semilogx(plotposT, obs_sort, 'r*');
hold on
semilogx(T_HNL_zonz, wsHNL_zonz, 'b-', 'linewidth', 1.5);
semilogx(T_HNL_monz, wsHNL_monz, 'g-', 'linewidth', 1.5);
semilogx(T_HNL_zonz_EP1, wsHNL_zonz_EP1, 'b--', 'linewidth', 1.5);
semilogx(T_HNL_monz_EP1, wsHNL_monz_EP1, 'g--', 'linewidth', 1.5);
grid on
title(['Waterstandsfrequentielijnen Rak Noord, zichtduur = ', num2str(zpot/24),' dagen'])
xlabel('Terugkeertijd, jaar')
ylabel('Waterstand, cm+NAP')
xlim([1, 1e5]);
ylim([100, 400])
legend('Data 1971 tm 2016, hele jaren',...
    'Hydra-NL zonder enige onzheid',...
    'Hydra-NL met onzheid, s = 30 cm',...
    'Hydra-NL zonder enige onzheid p_{EP}=1',...
    'Hydra-NL met onzheid, s = 30 cm p_{EP}=1', 'location', 'SouthEast')

%% Selectie whjaar
% golfkenmerken(:,3) is de maand
mnd                = golfkenmerken(:,3);
Index_whj          = (mnd >= 10 | mnd <= 3);
golfkenmerken_whj  = golfkenmerken(Index_whj,:);
golfnummers_whj    = golfkenmerken_whj(:,1);
golven_whj         = golven(golfnummers_whj)

%% Bepaal frequentielijn met plotposities
obs_whj      = [golven_whj.piek]';   %kolomvector met maxima
N_whj        = numel(obs_whj);
obs_sort_whj = sort(obs_whj, 'descend');
t_per        = jaar(end) - jaar(1);

% Plotpositie voor ovfreq en terugkeertijd:
plotposFreq_whj  = N_whj/(N_whj+c)*([1:N_whj]'+c+d-1)/t_per;
plotposT_whj     = 1./plotposFreq_whj;

close all

figure
semilogx(plotposT_whj, obs_sort_whj, 'r*');
hold on
semilogx(T_HNL_zonz, wsHNL_zonz, 'b-', 'linewidth', 1.5);
semilogx(T_HNL_monz, wsHNL_monz, 'g-', 'linewidth', 1.5);
semilogx(T_HNL_zonz_EP1, wsHNL_zonz_EP1, 'b--', 'linewidth', 1.5);
semilogx(T_HNL_monz_EP1, wsHNL_monz_EP1, 'g--', 'linewidth', 1.5);
grid on
title(['Waterstandsfrequentielijnen Rak Noord, zichtduur = ', num2str(zpot/24),' dagen'])
xlabel('Terugkeertijd, jaar')
ylabel('Waterstand, cm+NAP')
%xlim([1, 1e5]);
%ylim([150, 350])
% xlim([1, 100]);
% ylim([150, 250])

legend(['Data ', num2str(bej),' tm ',num2str(eij),' whjaren'],...
    'Hydra-NL zonder enige onzheid',...
    'Hydra-NL met onzheid, {\sigma} = 30 cm',...
    'Hydra-NL zonder enige onzheid p_{EP}=1',...
    'Hydra-NL met onzheid, {\sigma} = 30 cm p_{EP}=1', 'location', 'SouthEast')


%% Presentatie 30 september KNMI De Bilt