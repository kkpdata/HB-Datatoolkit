%==========================================================================
% Hoofdprogramma IJsselmeer
% Door: Chris Geerse

%Versie met geknikte trapezia (20 maart 2009)
%Ten behoeve reproductie Hydra-M

%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
%padnaam_uit = 'd:/Matlab/Vecht_IJs_IJsm_Sch_VRM/'
padnaam_uit = 'D:\Users\geerse\Matlab\Stat_Rivieren_Meren_Wind\'

%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
%homogenisatieparameters
zichtjaar = 2011;       %homogenisatie naar 1 jan van zichtjaar



stijging_per_jaar = 0.0; %aangenomen stijging per jaar in m (regressie van gem geeft 0.0011)




drempel = 0.15;        % variabele voor drempel waarde
ref_niv = -0.4;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = -0.4;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 1;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet

%geef hier de gewenste selectie aan:
bej = 1976; bem = 10; bed = 1;
%bej = 1990; bem = 10; bed = 1;
eij = 2005; eim = 3; eid = 31;

%parameters trapezia
B         = 30;             %basisduur trapezia
zpot      = floor(B/2);     % zichtduur voor selectie pieken; NB: kies 15 dagen voor beoordelen werklijn (bij 30 dagen vallen er veel pieken weg)
zB        = floor(B/2);     %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven

av        = 0.20;          %niveau insnoering in verticale richting NB (0.001<= av <=1): av=0 geeft rare antwoorden (av = 0.001 niet)
ah        = 0.025;          %factor insnoering in horizontale richting (ah = 1 is geen insnoering)

if (ah > 1/(1-av))
    disp(['ah      = ', num2str(ah)])
    hulp = 1/(1-av); disp(['1/(1-av = ', num2str(hulp)])
    disp('FOUT: Er dient voldaan te zijn aan ah <= 1/(1-av)!')
    disp('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
Ntrapezia = 180/B;

bpiek = 0.5;          %topduur in dagen

topduur_inv = ...       %Ten behoeve reproductie Hydra-M
  [-0.40, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
   -0.20, 500;
    0.15, 170;
    0.25, 36;
    0.30, 24;
    0.35, 12;
    1.80, bpiek*24]


%parameters meerpeil
stapy = 0.001;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax = 2.5;        %maximum van vector

%HR2001: T = 10000 jaar -> m = 1.08 m+NAP; T = 4000 jaar -> m = 0.96 m+NAP
ovkanspiek_inv = ...       %DEFAULTKEUZE
    [-0.4, 1;
    0.05, 1.6667e-1;
    0.4, 1.6667e-2
    1.07, 1.6667e-5;
    1.07+0.223 1.6667e-6]

% %Reproductie Hydra-M stat (zeer nauwkeurig)
% ovkanspiek_inv = ...       
%     [-0.4, 1;
%     -0.33, 0.999;
%     -0.24, 4.8/6;
%      0.19, 0.8/6;
%      0.24, 0.333/6;
%      0.29, 0.09/6;
%      0.78, 1.6667e-4;
%      1.08, 1.6667e-5]


if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de posities (werklijn)

%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all   %opdat geen lege figuur wordt getoond

%==========================================================================
%Inlezen van Hydra-M statistiek (bijlage 8 en 9 deelrapport 2) en van de data
%==========================================================================
%--------------------------------------------------------------------------
%Inlezen Hydra-M statistiek, respectievelijk:
%m, m+NAP; OF, 1/whjaar; OD, dag/whjaar; ODwest, dag/whjaar; ODoost, dag/whjaar
[m_HM, OF_HM, OD_HM, OD_HMwest, OD_HMoost] = textread('statistiek_Hydra_M_IJsselmeer.txt','%f %f %f %f %f','delimiter',' ','commentstyle','matlab');

%--------------------------------------------------------------------------
%Inlezen data
%[jaar,maand,dag,data] = textread('meerpeil_ijsm_7604_dag_whj_mNAP.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');
[datuminlees,mp,qlob,qolst] = textread('Statistieken Geerse IJsm_Lob_Olst.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');

%--------------------------------------------------------------------------
[jaar,maand,dag,datum] = datumconversiejjjjmmdd(datuminlees);

data = mp/100;      %bepalen meerpeilen in m+NAP
clear mp qlob qolst;

%==========================================================================
%Selectie data en berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));

jaar = jaar(selectie);
maand = maand(selectie);
dag = dag(selectie);
data = data(selectie);
datum = datenum(jaar,maand,dag);
dagnr = (1:numel(data))';
%plot(dagnr, data);
%plot(dagnr, cumsum(data-mean(data)));

plot(datum,data,'.');
grid on
hold on
ltxt  = []
ttxt  = 'Meerpeilen IJsselmeer';
xtxt  = 'tijd, jaren';
ytxt  = 'meerpeil, m+NAP';
datetick('x',10)
%datetick('x','keeplimits')
%datetick('x','keepticks')
Ytick = -0.6:0.2:0.6;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%Histogram meerpeilen
figure
hist(data)
xlabel('IJsselmeerpeil, m+NAP');
ylabel('aantal per klasse');

close all

%% Bepalen gemiddelde meerpeil (zonder trendcorrectie) per maand
clc
gemiddelden = [];
for ii = 1 : 12
    F           = find(maand == ii);
    data_sel    = data(F);
    hulp        = mean(data_sel);
    gemiddelden = [gemiddelden; hulp];
end
disp(gemiddelden)
