%==========================================================================
% Hoofdprogramma Vecht
% Door: Chris Geerse
%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
%padnaam_uit = 'Y:/Matlab/Vecht_IJs_IJsm_Sch01/';
padnaam_uit = 'D:\Users\geerse\Matlab\Vecht_IJs_IJsm_Sch_VRM_Rijn_Maas\'
%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
drempel = 180;          % variabele voor drempel waarde
zpot = 15;          %zichtduur
zB = 15;              %halve breedte van geselecteerde tijdreeks (default=zpot). NB zB>zpot
%kan soms crash geven bij aanpassing van golven tbv
%opschaling. Default zB = zpot.
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = 0;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%betaverdeling
a = 4.1;
b = 3.95;
nstapx_beta = 100;
nstapy_beta = 100;
Bbeta = 30;         %basisduur beta-golven
%parameters trapezia
B = 30;             %basisduur trapezia
topduur_inv = ...
    [0, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    180, 48;
    1000, 48]
%{
%om betere fit aan P(Q>q) te krijgen.
topduur_inv = ...
    [0, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    80, 400;
    120, 110;
    129, 40;
    130, 0;
    170, 0;
    180, 48;
    1000, 48]
%}
%parameters afvoer
stapy = 1;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
%(NB hele kleine stapgrootte, zeg stapy = 1, geeft beste overeenkomst tussen trapezia en beta-vormen)
ymax = 1500;     %maximum van vector
ovkanspiek_inv = ...
    [0, 1;
    180, 0.16667;
    550, 1.3333e-4]
%    657.8 1.6667e-5]   %laatste regel om plaatje van de werklijn tot hoge afvoeren te laten lopen
if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)


%==========================================================================
%Inlezen data
%==========================================================================
%meetperiode bevat 01-01-1960 t/m 31-12-1983 en
%whjaren 01-10-1993 t/m 31-03-1994
%whjaren 01-10-1998 t/m 31-03-1999
%whjaren 01-10-2000 t/m 31-03-2001
%Beschouw  01-01-1960 t/m 31-12-1983 als 24 whjaren, waarvan eerste 3 maanden en laatste 3 maanden
%als het ware kunnen worden samengevoegd tot 1 whjaar.
%Totaal dan 27 whjaren (NB hier wordt voorbijgegaan aan de problematiek van hiaten).

%NB Het jaar 2000 wordt bij het bepalen van de momentane kansen wel
%meegenomen.
[jaar,maand,dag,data] = textread('Vechtafvoeren_jan60_dec83_met_uitbr.txt','%u %u %u %f','delimiter','','commentstyle','matlab');
datum = datenum(jaar,maand,dag);        %seriële datum

%geef hier de gewenste selectie aan:
bej = 1960;
bem = 1;
bed = 1;
eij = 2001;
%eij = 1970;
eim = 3;
eid = 31;
bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));

%==========================================================================
%Berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
jaar = jaar(selectie);
maand = maand(selectie);
dag = dag(selectie);
data = data(selectie);
datum = datenum(jaar,maand,dag);

nr = (1:1:length(data))';
ymin = ovkanspiek_inv(1,1);


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
%          v: [11x1 double]
%      tvoor: [11x1 double]
%    tachter: [11x1 double]
%         fv: [11x1 double]

%[standaardvorm.v standaardvorm.tvoor standaardvorm.tachter standaardvorm.fv]


%==========================================================================
% Bepalen van genormeerde standaardgolfvorm Vecht (golven volgens beta-verdeling).
%==========================================================================
[beta_normgolfvorm, beta_normgolfduur] = beta_normgolf(a, b, nstapx_beta, nstapy_beta);
%beta_normgolfvorm: ybeta met piek = 1 als functie van x (0<=x<=1)
%beta_normgolfduur: duur op relatieve hoogte v (0<=v<=1)
%
%==========================================================================
% Plotten van alle geselecteerde golven inclusief beta-golven
%==========================================================================
plot_Vechtgolven(beta_normgolfvorm, golven, Bbeta);

%==========================================================================
% Plotten van alle geselecteerde golven met SOBEK-golven deelrapport 8.
% Vooreerst de T= 10 jaar golf opgeschaald.
%==========================================================================

[dagSobek, qSobek] = textread('SOBEKgolf_deelrapport8.txt','%f %f ','delimiter','','commentstyle','matlab');

qSobekNorm       = qSobek/max(qSobek);

SobekGolfMatrixNorm  = [dagSobek, qSobekNorm];
% figure
% plot(dag, qSobekNorm)


close all
plot_Vechtgolven_met_Sobekgolf(SobekGolfMatrixNorm, golven);
%plot(SobekGolfMatrixNorm(:,1),SobekGolfMatrixNorm(:,2))



