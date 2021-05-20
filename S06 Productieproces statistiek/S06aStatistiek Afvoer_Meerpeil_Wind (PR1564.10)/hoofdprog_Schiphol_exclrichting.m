%==========================================================================
% Hoofdprogramma Schiphol
% Door: Chris Geerse
%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
%padnaam_uit = 'c:/Matlab/Vecht_IJs_IJsm01/'

%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
drempel = 22;        % variabele voor drempel waarde
zpot = 23;            % zichtduur voor selectie pieken
zB = 23;              %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = 0;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%parameters trapezia
B = 48;             %basisduur trapezia

topduur_inv = ...       %DEFAULTKEUZE
    [0, 2;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    50, 2]

%parameters windsnelheid
stapy = 0.01;      %stapgrootte voor kansvectoren (y is bijv pieksnelheid)
ymax = 40;        %maximum van vector

c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)

%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all

%==========================================================================
%Inlezen data
%==========================================================================

%{
% TIME IN GMT
% DD  = WIND DIRECTION IN DEGREES NORTH
% QQD = QUALITY CODE DD
% UP  = POTENTIAL WIND SPEED IN 0.1 M/S
% QUP = QUALITY CODE UP
%
%  DATE,TIME, DD,QDD, UP,QUP
19500301,01,  0,  2,  2,  2
19500301,02,250,  2,  6,  2
%}

%==========================================================================
%Inlezen data
%==========================================================================
[jjjjmmdd,uur,r,qdd,snelheid,upd] = textread('s240_test.asc','%u %u %u %u %u %u','delimiter',',','headerlines',22);
[jjjjmmdd,uur,r,qdd,snelheid,upd] = textread('s240.asc','%u %u %u %u %u %u','delimiter',',','headerlines',22);
%s240.asc: 1 maart 1950 (vanaf uur 1) t/m 1 jan 2003 (t/m uur 24)
u = snelheid/10;    %omrekening van dm/s naar m/s
jaar = floor(jjjjmmdd/10000);
maand = floor((jjjjmmdd-jaar*10000)/100);
dag = floor(jjjjmmdd-jaar*10000-maand*100);
datum = datenum(jaar,maand,dag,uur,0,0);        %seriële datum

%geef hier de gewenste selectie aan:
bej = 1950;
bem = 3;
bed = 1;
beu = 1;
eij = 2003;
eim = 1;
eid = 1;
eiu = 24
bedatum = datenum(bej,bem,bed,beu,0,0);
eidatum = datenum(eij,eim,eid,eiu,0,0);
selectie = find(datum >= bedatum & datum <= eidatum);

%==========================================================================
%Berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
jaar = jaar(selectie);
maand = maand(selectie);
dag = dag(selectie);
uur = uur(selectie);
r = r(selectie);
u = u(selectie);
datum = datenum(jaar,maand,dag,uur,0,0);
casenr = (1:numel(u))';

%plot(casenr,u)
%grid on

%Haal weg bij grote dataset!!!!!!!!!!!!!!!!!!!!!!!
%[datum, jaar, maand, dag, uur, r, 10*u]
%[jaar, maand, dag, uur, r, 10*u]

plot(casenr,u,casenr,r);
[AX,H1,H2] = plotyy(casenr,u,casenr,r,'plot');
grid on
%{
set(AX(1),'Xlim',[-zmx zmx],'Xtick',[-zmx:zmx:zmx],'Ylim',[SImn SImx],'Ytick',[SImn:SIst:SImx]);
set(AX(2),'YColor','r','Xlim',[-zmx zmx],'Xtick',[-zmx:zmx:zmx],'Ylim',[SDmn SDmx],'Ytick',[SDmn:SDst:SDmx]);
set(H2,'LineStyle','--','Color','r');
grid on
%}
%HAAL WEG BIJ GROTE DATASET
%[datum, jaar, maand, dag, uur, r, 10*u]
%[jaar, maand, dag, uur, r, 10*u]

[stormkenmerken, stormen] = stormselectie(drempel,zpot,zB,jaar,maand,dag,uur,u,r);
%Structure stormen:
%1xn struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    uur
%    upiek
%    rpiek
%    rang
%    tijd
%    udata
%    rdata

%==========================================================================
%Plotten van stormen
%==========================================================================

%function [] = plot_verloopID(golvenI, paren, zD, datumD, dataD,...
%    Npx, Npy, SImn, SIst, SImx, SDmn, SDst, SDmx);


%Er zijn Npx*Npy plaatjes in één figuur:
%Npx: aantal plaatjes in x-richting
%Npy: aantal plaatjes in y-richting
%Sumn: min van schaal onafh var
%Sust: stap in schaal onafh var
%Sumx: max van schaal onafh var
%Srmn: min van schaal afh var
%Srst: stap in schaal afh var
%Srmx: max van schaal afh var
Npx = 2;
Npy = 2;
Stst = 10;
Sumn = 0;
Sust = 5;
Sumx = 30;
Srmn = 0;
Srst = 60
Srmx = 360;

Nstormen = max([stormen.rang]);

%{
stormdtm = zeros(Nstormen,1);     %init seriële datums alle stormen
for i = 1:Nstormen
    stormdtm(i) = datenum(stormen(i).jaa, stormen(i).mnd, stormen(i).dag,stormen(i).uur,0,0);
end
%}
z = (length([stormen(1).tijd])-1)/2;
t_as = [stormen(1).tijd];

traptijd =[-23 -1 1 23];
trapu_norm =[0 1 1 0];

figure
a = 1;
for j = 1:Nstormen
    rest = mod(j-1,Npx*Npy);
    if rest == 0 & j > 1    %als rest=0 is j-1 = K*Npx*Npy, met K geheel
        figure
        a = 1;
    end
    subplot(Npy,Npx,a)
    a = a + 1;

    %plotten u-reeks en r-reeks in storm j
    [AX,H1,H2] = plotyy(t_as, [stormen(j).udata],traptijd, trapu_norm*stormen(j).upiek,'plot');
    set(AX(1),'Xlim',[-z z],'Xtick',[-z:Stst:z],'Ylim',[Sumn Sumx],'Ytick',[Sumn:Sust:Sumx]);
%    set(AX(2),'YColor','r','Xlim',[-z z],'Xtick',[-z:Stst:z],'Ylim',[Srmn Srmx],'Ytick',[Srmn:Srst:Srmx]);
    set(H2,'LineStyle','-','Color','r');
    grid on
    title(['piek: ',num2str(stormen(j).dag), '-',num2str(stormen(j).mnd), '-', num2str(stormen(j).jaa), ' uur :', num2str(stormen(j).uur)])

end



%}