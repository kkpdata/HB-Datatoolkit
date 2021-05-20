%==========================================================================
% Hoofdprogramma Vecht
% Door: Chris Geerse
%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
%padnaam_uit = 'Y:/Matlab/Vecht_IJs_IJsm_Sch01/';
padnaam_uit = 'D:\Users\geerse\Matlab\Stat_Rivieren_Meren_Wind'
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
datum = datenum(jaar,maand,dag);        %seri�le datum

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

plot(datum,data,'.');
grid on
hold on
ltxt  = []
ttxt  = 'Afvoeren Dalfsen';
xtxt  = 'tijd, jaren';
ytxt  = 'Vechtafvoer Dalfsen, m3/s';
datetick('x',10)
%datetick('x','keeplimits')
%datetick('x','keepticks')
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

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
%plot_Vechtgolven_incltrapezium_top2dagen(golven);



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

%Saven van momentane kansen naar een tabel
k_kolom = [0:5:900]';   %Deze stapgroottes bij voorkeur niet veranderen
tabelmomkans = [k_kolom, interp1(berek_trap.y, berek_trap.Gy_mom, k_kolom)];
save([padnaam_uit,'momkans_Dalfsen_berekend_met_stapy',num2str(stapy),'_ymax',num2str(ymax),'.txt'],'tabelmomkans','-ascii')


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

close all

%==========================================================================
% Plotposities met werklijn
%==========================================================================
obs = golfkenmerken(:,5);   %piekwaarde
r = golfkenmerken(:,6);     %rang van piekwaarde
n = max(r);                 % aantal meegenomen extreme waarden
t_per = numel(data)/182;        % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)

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
%cltxt  = {'data','werklijn','Waquagolven'};
%ltxt  = char(cltxt);
ltxt = [];
ttxt  = ['Overschrijdingsfrequentie en data Dalfsen'];
xtxt  = 'terugkeertijd, jaar';
ytxt  = 'afvoer Dalfsen, m3/s';
%Xtick = 1:100:10000;  wil niet met semilog-plot
Ytick = 0:100:700;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



close all

%==========================================================================
% Plaatjes golven
%==========================================================================
%==========================================================================
% Plaatje met standaard(norm)golf en beta-(norm)golfvorm
%==========================================================================

%close all
aantal_golven = max([golven.nr]);
v = standaardvorm.v;
figure
plot(standaardvorm.tvoor,v,'k',standaardvorm.tachter,v,'k');
hold on
grid on
% plot(Bbeta*beta_normgolfvorm(:,1)-Bbeta/2,beta_normgolfvorm(:,2),'r');
xx = [-15, -1, 1, 15];
yy = [0,  1,  1,  0];
plot(xx, yy,'r');
txt  = [];
ttxt  = 'Gemiddelde golf Dalfsen en gekozen trapezium';
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



% 
% figure
% for i = 1:aantal_golven
%     plot(golven(i).tijd, golven(i).data,'b-')
%     hold on
%     grid on
% end
% ltxt  = [];
% ttxt  = 'Gemeten golven Dalfsen';
% xtxt  = 'tijd, dagen';
% ytxt  = 'Vechtafvoer Dalfsen, m3/s';
% Xtick = -15:5:15;
% Ytick = 0:50:400;
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% figure
% for i = 1:aantal_golven
%     plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'b-')
%     hold on
%     grid on
% end
% ltxt  = [];
% ttxt  = 'Aangepaste golven Dalfsen';
% xtxt  = 'tijd, dagen';
% ytxt  = 'Vechtafvoer Dalfsen, m3/s';
% Xtick = -15:5:15;
% Ytick = 0:50:400;
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% %nu golven op 1 genormeerd
% figure
% for i = 1:aantal_golven
%     plot(golven_aanpas(i).tijd, golven_aanpas(i).data./max(golven_aanpas(i).data),'b-')
%     hold on
%     grid on
% end
% ltxt  = [];
% ttxt  = 'Aangepaste golven Dalfsen na normering op 1';
% xtxt  = 'tijd, dagen';
% ytxt  = 'relatieve afvoer Dalfsen, [-]';
% Xtick = -15:5:15;
% Ytick = 0:0.1:1;
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% %plaatje topduur
% 
% figure
% plot(berek_trap.y,berek_trap.by, 'b')
% grid on
% hold on
% ltxt  = []
% ttxt  = 'Topduur trapezia Dalfsen';
% xtxt  = 'piekafvoer Dalfsen, m3/s';
% ytxt  = 'topduur, uur';
% Xtick = 0:100:700;
% Ytick = 0:100:800;
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% 
% % close all
% % 
% % %trapezium met topduur 48 uur tezamen met de fit
% % figure
% % x = [-15,-1,1,15];
% % y = [0,1,1,0];
% % plot(x,y,'k');
% % hold on
% % grid on
% % plot(Bbeta*beta_normgolfvorm(:,1)-Bbeta/2,beta_normgolfvorm(:,2),'r');
% % ltxt  = [];
% % ttxt  = 'Gefitte golf en trapezium Dalfsen';
% % xtxt  = 'tijd, dagen';
% % ytxt  = 'relatieve afvoer, [-]';
% % Xtick = -15:5:15;
% % Ytick = 0:0.1:1;
% % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % 
% % %illustratie van L(q,k)
% % figure
% % plot(Bbeta*beta_normgolfvorm(:,1)-Bbeta/2,beta_normgolfvorm(:,2),'r');
% % ltxt  = [];
% % ttxt  = []
% % xtxt  = 'tijd, dagen';
% % ytxt  = 'relatieve afvoer, [-]';
% % Xtick = -15:5:15;
% % Ytick = 0:0.1:1.2;
% % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 
% 
% % %==========================================================================
% % % Plaatjes momentane kansen volgens de metingen en volgens de integratie
% % %==========================================================================
% % 
% % figure
% % plot(mom_obs.y,mom_obs.Gy,'g-')
% % grid on
% % hold on
% % ltxt  = []
% % ttxt  = 'Momentane kans uit metingen Dalfsen';
% % xtxt  = 'Vechtafvoer Dalfsen, m3/s';
% % ytxt  = 'momentane overschrijdingskans, [-]';
% % Xtick = 0:50:400;
% % Ytick = 0:0.1:1;
% % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % 
% % 
% % figure
% % F = find(mombeta.y >= 180);
% % plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.', mombeta.y(F), mombeta.Gy(F), 'r')
% % grid on
% % hold on
% % cltxt  = {'observatie','integratie (trapezia)','integratie (gefitte golfvorm)'};
% % ltxt  = char(cltxt);
% % ttxt  = 'Momentane kansen Dalfsen';
% % xtxt  = 'Vechtafvoer Dalfsen, m3/s';
% % ytxt  = 'momentane overschrijdingskans, [-]';
% % Xtick = 0:50:400;
% % Ytick = 0:0.1:1;
% % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % 
% % close all
% % 
% % figure
% % plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.', mombeta.y(F), log(mombeta.Gy(F)), 'r')
% % grid on
% % hold off
% % cltxt  = {'observatie','integratie (trapezia)','integratie (gefitte golfvorm)'};
% % ltxt  = char(cltxt);
% % ttxt  = 'Momentane kansen Dalfsen';
% % xtxt  = 'Vechtafvoer Dalfsen, m3/s';
% % ytxt  = 'ln momentane overschrijdingskans, [-]';
% % Xtick = 0:50:500;
% % Ytick = -10:2:0;
% % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % 
% % 
% % close all
% % 
% % %Voor rapport HR2006 modellen
% % figure
% % %plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.', mombeta.y(F), log(mombeta.Gy(F)), 'r')
% % semilogy(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
% % grid on
% % hold off
% % xlim([0 500])
% % ylim([1e-5 1])
% % title(['Momentane kansen Dalfsen'])
% % xlabel('Vechtafvoer Dalfsen, m3/s')
% % ylabel('momentane overschrijdingskans, [-]')
% % legend('metingen','volgens formule');
% % 
% % 
% % % %close all
% % % figure
% % % plot(mom_obs.y,log(mom_obs.fy),'g-',berek_trap.y,log(berek_trap.fy_mom),'b-.')
% % % grid on
% % % hold on
% % % xlim([0 400]);
% % % %ylim([0 1]);
% % % xlabel('Vechtafvoer Dalfsen, m3/s')
% % % ylabel('ln momentane kansdichtheid, [-]')
% % % legend('observatie','integratie (trapezia)')
% % 
% % 
% % %tbv van manier van saven hier een voorbeeld:
% % %save([padnaam_uit,'piek_datum_CG.txt'],'piek_datum','-ascii')
% % %}
% % 
% % %}
% % %}
% % %}