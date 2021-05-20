%==========================================================================
% Scrpt voor illustratie Rak Noord workshop 5 maart 2019
%
% Door: Chris Geerse
% PR3598.10
% Datum: maart 2019.
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
bej = 1971; bem = 10; bed = 1;
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

%% Inlezen Hydra-NL uitvoer; uit PR3615 Doorwerking modelonzekerheid waterstanden
% Dus met statistische onzekerheid (zie rapport PR3615.10).
Berek_zonz =...
    [1.600000       1.778455    
   1.700000       1.085441    
   1.800000      0.6507403    
   1.900000      0.3873264    
   2.000000      0.2290083    
   2.100000      0.1240745    
   2.200000      4.5631103E-02
   2.300000      1.6580056E-02
   2.400000      5.6126551E-03
   2.500000      1.7936878E-03
   2.600000      4.7543150E-04
   2.700000      1.8473098E-04
   2.800000      9.1159163E-05
   2.900000      4.9929426E-05
   3.000000      2.8404203E-05
   3.100000      1.6423568E-05
   3.200000      9.5881460E-06
   3.300000      5.6347631E-06
   3.400000      3.3277606E-06
   3.500000      1.9689824E-06
   3.600000      1.1677744E-06
   3.700000      6.9413096E-07
   3.800000      4.1750201E-07];

Berek_monz =...         %; uit PR3615 Doorwerking modelonzekerheid waterstanden
  [ 1.600000       2.411663    
   1.700000       1.832332    
   1.800000       1.334707    
   1.900000      0.9328457    
   2.000000      0.6241534    
   2.100000      0.4020835    
   2.200000      0.2446032    
   2.300000      0.1457494    
   2.400000      8.2016535E-02
   2.500000      4.3307401E-02
   2.600000      2.2934556E-02
   2.700000      1.0889041E-02
   2.800000      5.0037773E-03
   2.900000      2.2279210E-03
   3.000000      7.7435374E-04
   3.100000      2.6635238E-04
   3.200000      9.6089760E-05
   3.300000      3.5791123E-05
   3.400000      1.4531532E-05
   3.500000      7.5213693E-06
   3.600000      4.2270694E-06
   3.700000      2.4477481E-06
   3.800000      1.4363432E-06];


wsHNL_zonz = 100*Berek_zonz(:,1);
T_HNL_zonz = 1./Berek_zonz(:,2);

wsHNL_monz = 100*Berek_monz(:,1);
T_HNL_monz = 1./Berek_monz(:,2);


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


% data, zonder onz.heid
figure
semilogx(plotposT_whj, obs_sort_whj, 'r*');
hold on
semilogx(T_HNL_zonz, wsHNL_zonz, 'b-', 'linewidth', 1.5);
grid on
title(['Waterstandsfrequentielijnen Rak Noord, zichtduur = ', num2str(zpot/24),' dagen'])
xlabel('Terugkeertijd, jaar')
ylabel('Waterstand, cm+NAP')
%xlim([1, 1e5]);
%ylim([150, 350])
xlim([1, 1e5]);
ylim([140, 340])

legend(['Data ', num2str(bej),' - ',num2str(eij),' winterhalfjaren'],...
    'Hydra-NL met stat.onz, zonder mod.onzheid',...
    'location', 'SouthEast')


close all


% met en zonder onz.heid
figure
semilogx(plotposT_whj, obs_sort_whj/100, 'r*');
hold on
semilogx(T_HNL_zonz, wsHNL_zonz/100, 'b-', 'linewidth', 1.5);
semilogx(T_HNL_monz, wsHNL_monz/100, 'g-', 'linewidth', 1.5);
grid on
%title(['Frequnecy lines and data Rak Noord, zichtduur = ', num2str(zpot/24),' dagen'])
title(['Frequency lines and data Rak Noord (at the sluices)'])
xlabel('Recurrence time, year')
ylabel('Water level, m+NAP')
%xlim([1, 1e5]);
%ylim([150, 350])
xlim([1, 1e5]);
ylim([1.40, 3.40])
legend(['Data ', num2str(bej),' - ',num2str(eij),' winter half years'],...
    'Hydra-NL without uncertainty',...
    'Hydra-NL, uncertainty: {\sigma} = 0.30 m', 'location', 'SouthEast')

% legend(['Data ', num2str(bej),' - ',num2str(eij),' winterhalfjaren'],...
%     'Hydra-NL met stat.onz, zonder mod.onzheid',...
%     'Hydra-NL met stat.onz, mod.onz: {\sigma} = 30 cm', 'location', 'SouthEast')

