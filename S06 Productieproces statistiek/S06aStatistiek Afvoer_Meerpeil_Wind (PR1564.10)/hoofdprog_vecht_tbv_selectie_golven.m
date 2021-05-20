%==========================================================================
% Programma waarmee gedemonstreerd kan worden hoe golven kunnen worden
% geselecteerd met een bepaalde zichtduur.
% In dit geval worden golven voor de Overijsselse Vecht geselecteerd.
%
% Opmerkingen:
% 1. zB kan gewoon gelijk genomen worden aan de zichtduur zpot.
% 2. de "beta golfvorm" heeft feitelijk niets met de selectie te maken,
%    maar zit nog wel in de code.
% 3. Zie voor uitleg over de golvenselectie hoofdstuk 3 uit
%    Hydraulische Randvoorwaarden 2006 Vecht- en IJsseldelta - Statistiek IJsselmeerpeil, afvoeren en stormverlopen voor Hydra-VIJ. 
%    C.P.M. Geerse. RIZA-werkdocument 2006.036x. Rijkswaterstaat-RIZA. Lelystad, januari 2006.
%
% Door: Chris Geerse
% 1 dec 2008
%
%==========================================================================
clear
close all
%==========================================================================
%==========================================================================

%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
drempel = 200;          % variabele voor drempel waarde
zpot = 15;          %zichtduur
zB = 15;              %halve breedte van geselecteerde tijdreeks (default=zpot). NB zB>zpot
%kan soms crash geven bij aanpassing van golven tbv
%opschaling. Default zB = zpot.
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = 0;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen

%betaverdeling
a = 4.1;
b = 3.95;
nstapx_beta = 100;
nstapy_beta = 100;
Bbeta = 30;         %basisduur beta-golven


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
%plot_Vechtgolven_incltrapezium_top2dagen(golven);

