%==========================================================================
% Hoofdprogramma Schiphol
% Door: Chris Geerse (gemaakt bij RIZA-WSH)
%==========================================================================

%Dit bestand kan door Deltares gebruikt worden als voorbeeld voor de
%analyse van stormopzetduren. 

%Zie voor uitleg van de analyses hoofdstuk 8 uit [Geerse, 2006]:
%Hydraulische Randvoorwaarden 2006 Vecht- en IJsseldelta - Statistiek IJsselmeerpeil, 
%afvoeren en stormverlopen voor Hydra-VIJ. C.P.M. Geerse. RIZA-werkdocument 2006.036x. 
%Rijkswaterstaat-RIZA. Lelystad, januari 2006.


%==========================================================================
%clear          %clear lijkt niet echt nodig (niet volledig gecheckt)
close all
%==========================================================================



%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
drempel = 22;        % variabele voor drempel waarde
zpot = 20;            % zichtduur voor selectie pieken
zB = 20;              %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven
r1 = 0;          %r1 ondergrens voor te selecteren piekrichtingen (r1 wordt ook geselecteerd)
r2 = 360;          %r2 bovengrens voor te selecteren piekrichtingen (r2 wordt ook geselecteerd)
trshift = 0;       %trshift: tijdsduur n� piektijdstip waarop gekeken wordt of de dan geldende richting
                   %r_trshift ligt tussen r1 en r2 (r1 <= r_trshift <= r2). NB: |trshift| <= zpot
                   %NB: op 29 sep 2006 is functie 'stormselectie.m'
                   %aangepast zodat ook r1 > r2 mogelijk wordt.
                   
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = 0;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_ur = 0;        %indien 1 wel plaatjes met u en r, indien 0 dan niet
fig_utrap = 0;     %indien 1 wel plaatjes met u en trapezia, indien 0 dan niet
fig_stormen_verbreed = 0; %indien 1 wel plaatjes verbrede stormen, indien 0 dan niet
fig_stormen_rel = 0;      %indien 1 wel plaatje relatieve stormen, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%parameters trapezia (middenvorm)
B = 48;             %basisduur trapezia
b = 1;              %topduur trapezia (voorflank heeft duur (B-b)/2)
pm = .45;    %kans op MIDDENvorm

%smalle vorm
Bs = 21;
bs = 1;
ps = .45;    %kans op smalle vorm
%brede vorm
Bb = 76;
bb = 3;
pb = 1-pm-ps;    %kans op  brede vorm

%Parameters voor subplots met u en r en trapezia
%Er zijn Npx*Npy plaatjes in ��n figuur:
Npx = 3;	  % aantal plaatjes in x-richting
Npy = 3;	  % aantal plaatjes in y-richting
Stst = 10;	  % stapgrootte tijd
Sumn = 0;	  % min van windsnelheid
Sust = 10;	  % stapgrootte in windsnelheid
Sumx = 30;	  % max van windsnelheid
Srmn = 0;	  % min van richting
Srst = 60	  % stapgrootte in richting
Srmx = 360;	  % max van richting


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
[jjjjmmdd,uur,r,qdd,snelheid,qup] = textread('s240_download23jan2006.asc','%u %u %u %u %u %u','delimiter',',','headerlines',22);

u = snelheid/10;    %omrekening van dm/s naar m/s
jaar = floor(jjjjmmdd/10000);
maand = floor((jjjjmmdd-jaar*10000)/100);
dag = floor(jjjjmmdd-jaar*10000-maand*100);
datum = datenum(jaar,maand,dag,uur,0,0);        %seri�le datum

%geef hier de gewenste selectie aan:
bej = 1950;
bem = 3;
bed = 1;
beu = 1;
eij = 2005;
eim = 1;
eid = 1;
eiu = 24
bedatum = datenum(bej,bem,bed,beu,0,0);
eidatum = datenum(eij,eim,eid,eiu,0,0);
selectie = find(datum >= bedatum & datum <= eidatum);
%selectie = find((datum >= bedatum & datum <= eidatum) & (qdd==2 & upd==2);  %kwaliteitscode 2 is goede data OF ook 0????

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

%==========================================================================
%Selecteren van (niet aangepaste) stormen uit datareeks
%==========================================================================

[stormkenmerken, stormen] = stormselectie(drempel,zpot,zB,jaar,maand,dag,uur,u,r,r1,r2,trshift);
%Structure stormen:
%1xn struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    uur
%    piek
%    rpiek
%    rang
%    tijd
%    data
%    rdata

%==========================================================================
%Plotten van stormen: subplotjes van u,r en u met trapezium
%==========================================================================

plot_stormen(stormen,B,b,fig_ur,fig_utrap,Npx,Npy,Stst,Sumn,Sust,Sumx,Srmn,Srst,Srmx);

%==========================================================================
%Aanpassen van stormen: piek/dal-verbreding en monotone voor- en
%achterflanken maken door nevenpieken tegen hoofdpiek te plakken.
%Resultaat: aangepaste stormen (stijgende voor- en dalende achterflank) en (gemiddelde)
%standaard(norm)golfgegevens.
%==========================================================================

[stormen_aanpas, standaardvorm, tvoor, tachter] = opschaling(...
    stormen,ref_niv,piekduur,nstapv,fig_stormen_verbreed,fig_stormen_rel,fig_opschaling);

Nstormen = max([stormen.rang])

%stormen_aanpas =
%1*aantal_stormen struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    piek
%    rang
%    tijd
%    symtijd    %symmetrisch gemaakte stormen
%    data

%standaardvorm =
%          v: [11x1 double]
%      tvoor: [11x1 double]
%    tachter: [11x1 double]
%         fv: [11x1 double]


%%==========================================================================
% %Hier volgt de versie van de standaardvorm dmv turven discrete uurwaarden
% %voor niveau v.
%%==========================================================================
% 
% [stormen_aanpas_discreet, standaardvorm_discreet, tvoor_discreet, tachter_discreet] = opschaling_discreet(...
%     stormen,ref_niv,nstapv,fig_stormen_rel,fig_opschaling);





%==========================================================================
%Allerlei stormenplaatjes
%==========================================================================

%close all

%Variabelen tbv plotten
Nstormen = max([stormen.rang]);
t_as = [stormen(1).tijd];
z = (length(t_as)-1)/2; %totale t_as heeft lengte z + 1 + z.

%Middenvorm
traptijd =[-B/2 -b/2 b/2 B/2]; %parameters trapezium tbv plotten
trapu_norm =[0 1 1 0];
%smalle vorm
trapstijd =[-Bs/2 -bs/2 bs/2 Bs/2];
trapsu_norm =[0 1 1 0];
%brede vorm
trapbtijd =[-Bb/2 -bb/2 bb/2 Bb/2]; 
trapbu_norm =[0 1 1 0];
%gewogen gemiddelde van de trapezia
Bw = ps*Bs+pm*B+pb*Bb;
bw = ps*bs+pm*b+pb*bb;
trapwtijd =[-Bw/2 -bw/2 bw/2 Bw/2];
trapwu_norm =[0 1 1 0];

%close all
%==========================================================================
%Plotten gemiddelde vorm met midden vorm
v = standaardvorm.v;
figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on
%ook versie met dicreet geturfde overschr.uren toevoegen:
%plot(standaardvorm_discreet.tvoor,v,'r',standaardvorm_discreet.tachter,v,'r');
plot(traptijd, trapu_norm,'g');  %toevoegen trapezium
ltxt  = [];
ttxt  = (['Gemiddelde storm Schiphol met trapezia (uur) ', num2str((B-b)/2),'-', num2str(b),'-' num2str((B-b)/2)]);
%ttxt  = (['N=',num2str(Nstormen),', drempel=',num2str(drempel),' m/s, zpot=',num2str(zpot),' uur, zB=',num2str(zB),' uur, trap: ',...
%    num2str((B-b)/2),'-', num2str(b),'-' num2str((B-b)/2),' uur']);
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
Xtick = -8:2:8;
Ytick = 0.7:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%gemiddelde vorm met smalle, midden en brede trapezium; inclusief gewogen
%gemiddelde van de drie trapezia
figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
%plot(-standaardvorm.fv/2, v,'b',standaardvorm.fv/2, v,'b'); %symmetrische versie van gemiddelde
hold on
grid on
plot(traptijd, trapu_norm,'g');  %toevoegen trapezium
plot(trapstijd, trapsu_norm,'g');
plot(trapbtijd, trapbu_norm,'g');
plot(trapwtijd, trapwu_norm,'r');
ltxt  = [];
ttxt  = (['Gemiddelde met trapezia: p=',...
    num2str(ps),', ', num2str((Bs-bs)/2),'-', num2str(bs),'-' num2str((Bs-bs)/2),'; p=',...
    num2str(pm),', ', num2str((B-b)/2),'-', num2str(b),'-' num2str((B-b)/2),'; p=',...
    num2str(pb),', ', num2str((Bb-bb)/2),'-', num2str(bb),'-' num2str((Bb-bb)/2)]);
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%Aangepaste stormen na normering op 1, inclusief diverse trapezia.
figure
for i = 1:Nstormen
    plot(stormen_aanpas(i).tijd, stormen_aanpas(i).data/max([stormen_aanpas(i).data]),'b-')
    hold on
    grid on
end
%plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b','Linewidth',3);    %standaardvorm
plot(traptijd, trapu_norm,'g','Linewidth',3);  %toevoegen trapezium
plot(trapstijd, trapsu_norm,'g','Linewidth',3);
plot(trapbtijd, trapbu_norm,'g','Linewidth',3);
plot(trapwtijd, trapwu_norm,'r','Linewidth',3);
ltxt  = [];
ttxt  = (['Aanpas stormen met trapezia: p=',...
    num2str(ps),', ', num2str((Bs-bs)/2),'-', num2str(bs),'-' num2str((Bs-bs)/2),'; p=',...
    num2str(pm),', ', num2str((B-b)/2),'-', num2str(b),'-' num2str((B-b)/2),'; p=',...
    num2str(pb),', ', num2str((Bb-bb)/2),'-', num2str(bb),'-' num2str((Bb-bb)/2)]);
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%Aangepaste symmetrisch gemaakte stormen na normering op 1, inclusief diverse trapezia.
figure
for i = 1:Nstormen
    plot(stormen_aanpas(i).symtijd, stormen_aanpas(i).data/max([stormen_aanpas(i).data]),'b-')
    hold on
    grid on
end
plot(traptijd, trapu_norm,'g','Linewidth',3);  %toevoegen trapezium
plot(trapstijd, trapsu_norm,'g','Linewidth',3);
plot(trapbtijd, trapbu_norm,'g','Linewidth',3);
plot(trapwtijd, trapwu_norm,'r','Linewidth',3);
ltxt  = [];
ttxt  = (['Aanpas symm stormen: p=',...
    num2str(ps),', ', num2str((Bs-bs)/2),'-', num2str(bs),'-' num2str((Bs-bs)/2),'; p=',...
    num2str(pm),', ', num2str((B-b)/2),'-', num2str(b),'-' num2str((B-b)/2),'; p=',...
    num2str(pb),', ', num2str((Bb-bb)/2),'-', num2str(bb),'-' num2str((Bb-bb)/2)]);
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -10:2:10;
Ytick = 0.75:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
%Gemeten stormen (exclusief normering)
figure
for i = 1:Nstormen
    plot(t_as, stormen(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Gemeten stormen Schiphol';
xtxt  = 'tijd, uur';
ytxt  = 'windsnelheid, m/s';
Xtick = -20:10:20;
Ytick = 0:5:Sumx;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%==========================================================================
%Gemeten stormen na normering op 1.
figure
for i = 1:Nstormen
    plot(t_as, stormen(i).data/max([stormen(i).data]),'b-')
    hold on
    grid on
end
%plot(traptijd, trapu_norm,'g','Linewidth',3);  %toevoegen trapezium
ltxt  = [];
ttxt  = 'Gemeten stormen Schiphol na normering op 1';
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%==========================================================================
%Plotten aangepaste stormen
figure
for i = 1:Nstormen
    plot(stormen_aanpas(i).tijd, stormen_aanpas(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste stormen Schiphol';
xtxt  = 'tijd, uur';
ytxt  = 'windsnelheid, m/s';
Xtick = -20:10:20;
Ytick = 0:5:30;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%==========================================================================
%Aangepaste stormen na normering op 1.
figure
for i = 1:Nstormen
    plot(stormen_aanpas(i).tijd, stormen_aanpas(i).data/max([stormen_aanpas(i).data]),'b-')
    hold on
    grid on
end
plot(traptijd, trapu_norm,'g','Linewidth',3);  %toevoegen trapezium
ltxt  = [];
ttxt  = 'Aangepaste stormen Schiphol na normering op 1';
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
