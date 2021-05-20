%==========================================================================
% Hoofdprogramma Vecht
% Door: Chris Geerse
%==========================================================================
clear 
close all
%==========================================================================
% Uitvoer wegschrijven in
%padnaam_uit = 'Y:/Matlab_VIJ/Statistiek Hydra VIJ/Vecht02/'
%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
drempel = 100;          % variabele voor drempel waarde 
zpot = 15;          %zichtduur 
zB = 15;              %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = 0;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 1;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 1;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
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
%parameters afvoer
stapy = 5;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
%(NB hele kleine stapgrootte, zeg stapy = 1, geeft beste overeenkomst tussen trapezia en beta-vormen)
ymax = 900;     %maximum van vector
ovkanspiek_inv = ...
    [0, 1;
    180, 0.16667;
    550, 1.3333e-4]
if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)
t_per = 27;        % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)
%meetperiode bevat 01-01-1960 t/m 31-12-1983 en
%whjaren 01-10-1993 t/m 31-03-1994
%whjaren 01-10-1998 t/m 31-03-1999
%whjaren 01-10-2000 t/m 31-03-2001
%Beschouw  01-01-1960 t/m 31-12-1983 als 24 whjaren, waarvan eerste 3 maanden en laatste 3 maanden
%als het ware kunnen worden samengevoegd tot 1 whjaar.
%Totaal dan 27 whjaren (NB hier wordt voorbijgegaan aan de problematiek van hiaten).

%==========================================================================
%Inlezen data
%==========================================================================
%[jaar,maand,dag,data] = textread('Vechtafvoeren_1960_1983_dag.txt','%u %u %u %f','delimiter','','commentstyle','matlab');
[jaar,maand,dag,data] = textread('Vechtafvoeren_60_83_met_uitbreiding.txt','%u %u %u %f','delimiter','','commentstyle','matlab');
%geef hier desgewenst andere selectie aan:
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(jaar>=1960&jaar<=2001));

%==========================================================================
%Berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
jaar = jaar(selectie);
maand = maand(selectie);
dag = dag(selectie);
data = data(selectie);
datum = datenum(jaar,maand,dag);

ymin = ovkanspiek_inv(1,1);

% -------------------------------------------------------------------------
% Tbv goede plaatjes in Word.
% >>> keuze opmaak:
 figformat = 'doc';
% >>> Initialisatie opmaak:
 [ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
% linewidth = 
% fontsize  = 
% >>> Definitie plot:
% x = 
% y =
% -------------------------------------------------------------------------


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
% Plaatje met standaard(norm)golf en beta-(norm)golfvorm
%==========================================================================

close all
aantal_golven = max([golven.nr]);
v = standaardvorm.v;
figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on
plot(Bbeta*beta_normgolfvorm(:,1)-Bbeta/2,beta_normgolfvorm(:,2),'r');
title(['drempel = ',num2str(drempel),', zpot = ',num2str(zpot),', zB = ',...
    num2str(zB),', aantal golven = ',num2str(aantal_golven),', piekduur = ',num2str(piekduur)]);
%    ......(aantal_golven),', piekduur =
%    ',num2str(round(piekduur*100)/100)]); voor afbeelden 0.9999 als 1
xlabel('tijd, dagen');
ylabel('relatieve hoogte, [-]');


%==========================================================================
% Plotten van alle geselecteerde golven inclusief beta-golven
%==========================================================================
plot_Vechtgolven(beta_normgolfvorm, golven, Bbeta);

%==========================================================================
% Momentane ov.kans volgens berekening met trapezia
%==========================================================================
[berek_trap] = grootheden_trap(stapy, ymax, basis_niv, B, topduur_inv, ovkanspiek_inv);
%         y: [13x1 double]
%         by: [13x1 double]
%    fy_piek: [13x1 double]
%    Gy_piek: [13x1 double]
%     fy_mom: [13x1 double]
%     Gy_mom: [13x1 double]

%[berek_trap.y,berek_trap.by, berek_trap.fy_piek, ...
%    berek_trap.Gy_piek, berek_trap.fy_mom, berek_trap.Gy_mom]

%==========================================================================
% Momentane ov.kans volgens berekening met beta-golven
%==========================================================================
[mombeta] = momkansen_beta(a, b, nstapx_beta, nstapy_beta, berek_trap);
%[mombeta] = momkansen_beta(a, b, nstapx_beta, nstapy_beta, berek_trap);
%    y: [13x1 double]       %vector met afvoerniveaus (= berek_trap.y)
%    Gy: [13x1 double]      %momentane ov.kansen afvoer, zoals berekend op
%                            basis van beta-golfvormen
%    fy: [13x1 double]      %momentane kansdichtheid afvoer, zoals berekend op
%                            basis van beta-golfvormen

%==========================================================================
% Momentane ov.kans volgens de metingen (observaties)
%==========================================================================
%[y, fy_mom_obs, Gy_mom_obs] = turven_metingen(y, data);
[mom_obs] = turven_metingen(berek_trap.y, data);
%mom_obs = 
%     y: [13x1 double]       %vector met afvoerniveaus (= berek_trap.y)
%    Gy: [13x1 double]       %momentane ov.kansen
%    fy: [13x1 double]       %momentane kansdichtheid

%[mom_obs.y mom_obs.Gy mom_obs.fy ]

%==========================================================================
% Plotposities met werklijn
%==========================================================================
obs = golfkenmerken(:,5);   %piekwaarde
r = golfkenmerken(:,6);     %rang van piekwaarde
n = max(r);                 % aantal meegenomen extreme waarden

figure
plotpos = zeros(n,1);      %initialisatie
for i = 1:n
    plotpos(i) = ((n+c)*t_per)/((r(i)+c+d-1)*n);
end
p1 = semilogx(plotpos,obs,'r*');
hold on
grid on

%wlijn: k1 = afvoer, k2 = T
wlijn = [ovkanspiek_inv(:,1), 1./(6*ovkanspiek_inv(:,2))];
plot(wlijn(:,2),wlijn(:,1));
ttxt  = ['Werklijn en data Dalfsen'];
xtxt  = 'Terugkeertijd, jaar';
ytxt  = 'afvoer Dalfsen, m3/s';
%Xtick = 1:100:10000;  wil niet met semilog-plot
Ytick = 0:50:550;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all
%plot(golfkenmerken(:,1),golfkenmerken(:,5))



%==========================================================================
% Plaatjes momentane kansen volgens de metingen en volgens de integratie
%==========================================================================
%close all
figure
plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.', mombeta.y, mombeta.Gy, 'r')
grid on
hold on
ltxt  = 'observatie','integratie (trapezia)','integratie (beta-golfvorm)'
ttxt  = 'Werklijn en data Dalfsen';
xtxt  = 'Vechtafvoer Dalfsen, m3/s';
ytxt  = 'momentane overschrijdingskans, [-]';
Xtick = 0:50:400;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%close all
figure
plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.', mombeta.y, log(mombeta.Gy), 'r')
grid on
hold off
xlim([0 500]);
ylim([-12 0]);
xlabel('Vechtafvoer Dalfsen, m3/s')
ylabel('ln momentane overschrijdingskans, [-]')
legend('observatie','integratie (trapezia)','integratie (beta-golfvorm)')

%close all
figure
plot(mom_obs.y,log(mom_obs.fy),'g-',berek_trap.y,log(berek_trap.fy_mom),'b-.')
grid on
hold on
xlim([0 400]);
%ylim([0 1]);
xlabel('Vechtafvoer Dalfsen, m3/s')
ylabel('ln momentane kansdichtheid, [-]')
legend('observatie','integratie (trapezia)')

%{
%}


%}
%tbv van manier van saven hier een voorbeeld:
%save([padnaam_uit,'piek_datum_CG.txt'],'piek_datum','-ascii')
%}