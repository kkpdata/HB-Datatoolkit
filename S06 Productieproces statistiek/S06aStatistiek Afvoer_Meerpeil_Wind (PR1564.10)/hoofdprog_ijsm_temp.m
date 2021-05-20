%==========================================================================
% Hoofdprogramma IJsselmeer
% Door: Chris Geerse

%Versie met geknikte trapezia (20 maart 2009)

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

% %HR2001: T = 10000 jaar -> m = 1.08 m+NAP; T = 4000 jaar -> m = 0.96 m+NAP
% ovkanspiek_inv = ...       %DEFAULTKEUZE
%     [-0.4, 1;
%     0.05, 1.6667e-1;
%     0.4, 1.6667e-2
%     1.07, 1.6667e-5]

%Reproductie Hydra-M stat (zeer nauwkeurig)
ovkanspiek_inv = ...       
    [-0.4, 1;
    -0.33, 0.999;
    -0.24, 4.8/6;
     0.19, 0.8/6;
     0.24, 0.333/6;
     0.29, 0.09/6;
     0.78, 1.6667e-4;
     1.08, 1.6667e-5]


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
% selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
%     maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));

selectie = find((datum >= bedatum & datum <= eidatum));

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


data_temp = [jaar,maand,dag,data];
save([padnaam_uit,'IJsselmeer_dagwaarden.txt'],'data_temp','-ascii')



% 
% %Histogram meerpeilen
% figure
% hist(data)
% xlabel('IJsselmeerpeil, m+NAP');
% ylabel('aantal per klasse');
% 
% 
% %==========================================================================
% %Kleine trend analyse
% %==========================================================================
% % trendBepalen_IJsm; 
% 
% 
% %--------------------------------------------------------------------------
% %Trendcorrectie toepassen op de meerpeilen (neem de correctie binnen één
% %jaar steeds hetzelfde. Homogenisatie naar 1 jan van het zichtjaar.
% datum_zichtjaar = datenum(zichtjaar,1,1);
% delta_meerpeil = (datum_zichtjaar-datum)*stijging_per_jaar/365.25;
% data = data + delta_meerpeil;
% 
% 
% %==========================================================================
% %Selecteren van (niet aangepaste) golven uit datareeks
% %==========================================================================
% [golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);
% %golfkenmerken: matrix met gegevens van de golven
% %golven =
% %1xaantal_golven struct array with fields:
% %    nr
% %    jaa
% %    mnd
% %    dag
% %    piek
% %    rang
% %    tijd
% %    data
% %
% 
% %==========================================================================
% %Aanpassen van golven: piek/dal-verbreding en monotone voor- en
% %achterflanken maken door nevenpieken tegen hoofdpiek te plakken.
% %Resultaat: aangepaste golven (stijgende voor- en dalende achterflank) en (gemiddelde)
% %standaard(norm)golfgegevens.
% 
% [golven_aanpas, standaardvorm] = opschaling(...
% golven,ref_niv,piekduur,nstapv,fig_golven_verbreed,fig_golven_rel,fig_opschaling);
% 
% %golven_aanpas =
% %1*aantal_golven struct array with fields:
% %    nr
% %    jaa
% %    mnd
% %    dag
% %    piek
% %    rang
% %    tijd
% %    data
% 
% %standaardvorm =
% %          v: [11x1 double]
% %      tvoor: [11x1 double]
% %    tachter: [11x1 double]
% %         fv: [11x1 double]
% 
% %[standaardvorm.v standaardvorm.tvoor standaardvorm.tachter standaardvorm.fv]
% 
% %{
% %DISCRETE VERSIE VAN OPSCHALING (geeft bijna precies zelfde resultaten)
% [golven_aanpas_discreet, standaardvorm_discreet, tvoor_discreet, tachter_discreet] = opschaling_discreet(...
%     golven,ref_niv,nstapv,fig_golven_rel,fig_opschaling);
% %}
% 
% %==========================================================================
% % Plotten van geselecteerde golven tezamen met trapezium.
% %==========================================================================
% 
% plot_IJsmgolven(golven, ref_niv, B, topduur_inv);
% 
% % %==========================================================================
% % % Plotten van geselecteerde golven, standaardvorm en trapezium.
% % %==========================================================================
% % 
% %  
% % 
% % aantal_golven = max([golven.nr]);
% % v = standaardvorm.v;
% % figure
% % plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
% % hold on
% % grid on
% % %ook versie met dicreet geturfde overschr.uren:
% % %plot(standaardvorm_discreet.tvoor,v,'k',standaardvorm_discreet.tachter,v,'k');  
% % x = [-B/2, -bpiek/2, bpiek/2, B/2]';
% % y = [0, 1, 1, 0]';
% % plot(x,y,'r');
% % 
% % ltxt  = [];
% % ttxt  = 'Gemiddelde golf IJsselmeer met trapezium';
% % xtxt  = 'tijd, dagen';
% % ytxt  = 'relatief meerpeil, [-]';
% % Xtick = -15:5:15;
% % Ytick = 0:0.1:1;
% % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % 
% % %==========================================================================
% % % Momentane ov.kans volgens berekening met trapezia
% % %==========================================================================
% % %[berek_trap] = grootheden_trap(stapy, ymax, basis_niv, B, topduur_inv, ovkanspiek_inv);
% % 
% % [berek_trap] = grootheden_kniktrap(stapy, ymax, basis_niv, B, av, ah, topduur_inv, ovkanspiek_inv)
% % 
% % %         y: [13x1 double]
% % %         by: [13x1 double]
% % %    fy_piek: [13x1 double]
% % %    Gy_piek: [13x1 double]
% % %     fy_mom: [13x1 double]
% % %     Gy_mom: [13x1 double]
% % 
% % %[berek_trap.y,berek_trap.by, berek_trap.fy_piek, ...
% % %    berek_trap.Gy_piek, berek_trap.fy_mom, berek_trap.Gy_mom]
% % 
% % %wegschrijven onderschrijdingskans IJsselmeer tbv correlatiemodel
% % %onderschrijdkans_IJsselmeer = [berek_trap.y, 1-berek_trap.Gy_piek];
% % %save([padnaam_uit,'F_IJsselmeer.txt'],'onderschrijdkans_IJsselmeer','-ascii')
% % 
% % %Saven van momentane kansen naar een tabel
% % k_kolom = [-0.40:0.01:1.80]';   %Deze stapgroottes bij voorkeur niet veranderen
% % tabelmomkans = [k_kolom, interp1(berek_trap.y, berek_trap.Gy_mom, k_kolom)];
% % save([padnaam_uit,'momkans_IJsselmeer_berekend_met_stapy',num2str(stapy),'_ymax',num2str(ymax),'.txt'],'tabelmomkans','-ascii')
% % 
% % 
% % % close all
% % 
% % figure
% % plot(berek_trap.y,berek_trap.by, 'b')
% % grid on
% % hold on
% % ltxt  = []
% % ttxt  = 'Topduur trapezia IJsselmeer';
% % xtxt  = 'meerpeil, m+NAP';
% % ytxt  = 'topduur, uur';
% % Xtick = -0.4:0.2:1.2;
% % Ytick = 0:100:800;
% % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % 
% % 
% % 
% % 
% % % %==========================================================================
% % % % Momentane ov.kans volgens de metingen (observaties)
% % % %==========================================================================
% % % yturf = [(-0.6: stapy : ovkanspiek_inv(1,1))'; berek_trap.y];
% % % [mom_obs] = turven_metingen(yturf, data);
% % % %mom_obs =
% % % %     y: [13x1 double]       %vector met afvoerniveaus (= berek_trap.y)
% % % %    Gy: [13x1 double]       %momentane ov.kansen
% % % %    fy: [13x1 double]       %momentane kansdichtheid
% % % 
% % % %[mom_obs.y mom_obs.Gy mom_obs.fy ]
% % % 
% % % 
% % % %==========================================================================
% % % % Plotposities met werklijn
% % % %==========================================================================
% % % obs = golfkenmerken(:,5);   %piekwaarde
% % % r = golfkenmerken(:,6);     %rang van piekwaarde
% % % n = max(r);                 % aantal meegenomen extreme waarden
% % % t_per = numel(data)/182; % aantal meetjaren, gebruikt in de formule voor de plotposities (werklijn)
% % % 
% % % 
% % % figure
% % % plotpos = zeros(n,1);      %initialisatie
% % % for i = 1:n
% % % plotpos(i) = ((n+c)*t_per)/((r(i)+c+d-1)*n);
% % % end
% % % p1 = semilogx(plotpos,obs,'r*');
% % % hold on
% % % grid on
% % % 
% % % %wlijn: k1 = afvoer, k2 = T
% % % wlijn = [ovkanspiek_inv(:,1), 1./(6*ovkanspiek_inv(:,2))];
% % % plot(wlijn(:,2),wlijn(:,1));
% % % ltxt = [];
% % % ttxt  = ['werklijn en data IJsselmeer'];
% % % xtxt  = 'terugkeertijd, jaar';
% % % ytxt  = 'meerpeil, m+NAP';
% % % Xtick = [];
% % % Ytick = -.4:0.1:1.1;
% % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % 
% % % 
% % % % %==========================================================================
% % % % % Diverse plaatjes golven
% % % % %==========================================================================
% % % % %close all
% % % % figure
% % % % for i = 1:aantal_golven
% % % %     plot(golven(i).tijd, golven(i).data,'b-')
% % % %     hold on
% % % %     grid on
% % % % end
% % % % ltxt  = [];
% % % % ttxt  = 'Gemeten golven IJsselmeer';
% % % % xtxt  = 'tijd, dagen';
% % % % ytxt  = 'meerpeil, m+NAP';
% % % % Xtick = -15:5:15;
% % % % Ytick = -0.4:.2:0.6;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % figure
% % % % for i = 1:aantal_golven
% % % %     plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'b-')
% % % %     hold on
% % % %     grid on
% % % % end
% % % % ltxt  = [];
% % % % ttxt  = 'Aangepaste golven IJsselmeer';
% % % % xtxt  = 'tijd, dagen';
% % % % ytxt  = 'meerpeil, m+NAP';
% % % % Xtick = -15:5:15;
% % % % Ytick = -0.4:.2:0.6;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % 
% % % % %nu golven op 1 genormeerd
% % % % figure
% % % % for i = 1:aantal_golven
% % % %     plot(golven_aanpas(i).tijd, (golven_aanpas(i).data-ref_niv)./(max(golven_aanpas(i).data)-ref_niv),'b-')
% % % %     hold on
% % % %     grid on
% % % % end
% % % % ltxt  = [];
% % % % ttxt  = 'Aangepaste golven IJsselmeer na normering op 1';
% % % % xtxt  = 'tijd, dagen';
% % % % ytxt  = 'meerpeil, m+NAP';
% % % % Xtick = -15:5:15;
% % % % Ytick = 0:0.1:1;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % 
% % % % %==========================================================================
% % % % % Plaatjes momentane kansen volgens de metingen en volgens de integratie
% % % % %==========================================================================
% % % % %gemiddeld meerpeil
% % % % mpgem_data = mean(data)
% % % % stdev_data = std(data)
% % % % mpgem_trap = sum(berek_trap.fy_mom*stapy .*berek_trap.y)
% % % % stdev_trap = (sum(berek_trap.fy_mom*stapy .*(berek_trap.y).^2) - mpgem_trap^2)^0.5
% % % % 
% % % % 
% % % % figure
% % % % plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
% % % % grid on
% % % % hold on
% % % % cltxt  = {'observatie','integratie (trapezia)'};
% % % % ltxt  = char(cltxt);
% % % % ttxt  = 'Momentane kansen IJsselmeer';
% % % % xtxt  = 'meerpeil, m+NAP';
% % % % ytxt  = 'momentane overschrijdingskans, [-]';
% % % % Xtick = -0.5:0.1:0.8;
% % % % Ytick = 0:0.1:1;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % 
% % % % %close all
% % % % figure
% % % % plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
% % % % grid on
% % % % hold off
% % % % cltxt  = {'observatie','integratie (trapezia)'};
% % % % ltxt  = char(cltxt);
% % % % ttxt  = 'Momentane kansen IJsselmeer';
% % % % xtxt  = 'meerpeil, m+NAP';
% % % % ytxt  = 'ln momentane overschrijdingskans, [-]';
% % % % Xtick = -0.5:0.1:0.8;
% % % % Ytick = -10:1:1;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % 
% % % % %close all
% % % % %gemiddelde topduur als quotiënt van B*P(M>m)/P(S>s).
% % % % figure
% % % % topduurgem_trap = B*(berek_trap.Gy_mom)./berek_trap.Gy_piek;
% % % % plot(berek_trap.y,topduurgem_trap)
% % % % grid on
% % % % hold on
% % % % ltxt = [];
% % % % ttxt  = 'Overschrijdingsduur per top IJsselmeer';
% % % % xtxt  = 'IJsselmeerpeil, m+NAP';
% % % % ytxt  = 'topduur, dagen';
% % % % Xtick = -0.4:0.2:1.8;
% % % % Ytick = 0:2:32;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % 
% % % % 
% % % % close all
% % % % 
% % % % %==========================================================================
% % % % % Vergelijking Hydra-M en Hydra-VIJ statistiek
% % % % %==========================================================================
% % % % 
% % % % %Figuur topduur (herhaling van boven)
% % % % figure
% % % % plot(berek_trap.y,berek_trap.by, 'b')
% % % % grid on
% % % % hold on
% % % % ltxt  = []
% % % % ttxt  = 'Topduur trapezia IJsselmeer';
% % % % xtxt  = 'meerpeil, m+NAP';
% % % % ytxt  = 'topduur, uur';
% % % % Xtick = -0.4:0.2:1.2;
% % % % Ytick = 0:100:800;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % 
% % % % 
% % % % %werklijnen en data
% % % % figure
% % % % semilogx(plotpos,obs,'r*');
% % % % hold on
% % % % grid on
% % % % plot(wlijn(:,2),wlijn(:,1),'b');
% % % % plot(1./OF_HM, m_HM, 'k');
% % % % cltxt  = {'data','Hydra-VIJ','Hydra-M'};
% % % % ltxt  = char(cltxt);
% % % % ttxt  = ['werklijnen Hydra-M en Hydra-VIJ IJsselmeer'];
% % % % xtxt  = 'terugkeertijd, jaar';
% % % % ytxt  = 'meerpeil, m+NAP';
% % % % Xtick = [];
% % % % Ytick = -.4:0.1:1.1;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % %momentane kansen en data
% % % % %close all
% % % % figure
% % % % plot(mom_obs.y,mom_obs.Gy,'g-',berek_trap.y,berek_trap.Gy_mom,'b-.')
% % % % grid on
% % % % hold on
% % % % plot(m_HM, OD_HM/OD_HM(1),'k')
% % % % cltxt  = {'data','Hydra-VIJ','Hydra-M'};
% % % % ltxt  = char(cltxt);
% % % % ttxt  = 'Momentane kansen Hydra-M en Hydra-VIJ IJsselmeer';
% % % % xtxt  = 'meerpeil, m+NAP';
% % % % ytxt  = 'momentane overschrijdingskans, [-]';
% % % % Xtick = -0.5:0.1:0.8;
% % % % Ytick = 0:0.1:1;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % 
% % % % %close all
% % % % figure
% % % % plot(mom_obs.y,log(mom_obs.Gy),'g-',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
% % % % grid on
% % % % hold on
% % % % plot(m_HM, log(OD_HM/OD_HM(1)),'k')
% % % % cltxt  = {'data','Hydra-VIJ','Hydra-M'};
% % % % ltxt  = char(cltxt);
% % % % ttxt  = 'Momentane kansen Hydra-M en Hydra-VIJ IJsselmeer';
% % % % xtxt  = 'meerpeil, m+NAP';
% % % % ytxt  = 'ln momentane overschrijdingskans, [-]';
% % % % Xtick = -0.5:0.2:1.2;
% % % % Ytick = -15:1:1;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % 
% % % % %close all
% % % % %gemiddelde topduur als quotiënt van B*P(M>m)/P(S>s).
% % % % figure
% % % % topduurgem_trap = B*(berek_trap.Gy_mom)./berek_trap.Gy_piek;
% % % % grid on
% % % % hold on
% % % % plot(berek_trap.y,topduurgem_trap,'b-.')
% % % % plot(m_HM, OD_HM./OF_HM,'k')
% % % % cltxt  = {'Hydra-VIJ','Hydra-M'};
% % % % ltxt  = char(cltxt);
% % % % ttxt  = 'Overschrijdingsduur per top Hydra-M en Hydra-VIJ IJsselmeer';
% % % % xtxt  = 'meerpeil, m+NAP';
% % % % ytxt  = 'topduur, dagen';
% % % % Xtick = -0.4:0.2:1.1;
% % % % Ytick = 0:3:30;
% % % % fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% % % % 
% % % % %}
% % % % %}
