%==========================================================================
% Hoofdprogramma Borgharen
% Door: Chris Geerse
% 
% Aanpassing oude programmatuur t.b.v. PR2647.40
% Datum: augustus 2013
% 
% Opmerking:
% Werklijn is afgeleid op basis van gehomogeniseerde piekwaarden. Deze zijn volgens
% RIZA-werkdoc 2001.121x Bijlage C2 circa 80 m3/s hoger dan niet
% gehomogeniseerde pieken.

%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
padnaam_uit = 'D:\Users\geerse\Matlab\Stat_Rivieren_Meren_Wind'


%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
drempel = 1790;        % variabele voor drempel waarde (1700 m3/s -> 20 golven)
zpot    = 8;            % zichtduur voor selectie pieken
zB      = zpot;              %halve breedte van geselecteerde tijdreeks (default=zpot). NB zB>zpot
%kan soms crash geven bij aanpassing van golven tbv
%opschaling. Default zB = zpot.

homogenisatieWaarde = 0;   %waarde om hogere piekafvoeren te verlagen om pragmatisch effect homogenisatie te beoordelen.
ref_niv   = 0;       %referentieniveau van waaraf wordt opgeschaald
basis_niv = 0;     %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).

piekduur  = 4/24;              %welke duur is geschikt??? Duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.

nstapv    = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 1; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%parameters trapezia

B = 2*zpot;             %basisduur trapezia

topduur_inv = ...
    [0, B*24;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    1264.2, 24;
    6000, 24]
%parameters afvoer
stapy  = 25;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax   = 5000;        %maximum van vector

ovkanspiek_inv = ...        %hoort bij B = 30 (NB: wat is de bron hiervan???? Deze gegevens wijken af van memo PR1391.11)
  [   0.0      1.0
   1264.2      1.66667E-01
   1576.3      8.33333E-02
   3282.1      6.66667E-04
   3804.8      1.33333E-04]

%pragmatisch herberekenen om homogenisatie te simuleren
ovkanspiek_inv(2:5,1) =ovkanspiek_inv(2:5,1) - homogenisatieWaarde;

%aanpassing f(k) voor andere B dan 30 dagen
ovkanspiek_inv(2:5,2) = 6*ovkanspiek_inv(2:5,2)/(180/B);

if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
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
[datuminlees,qborg] = textread('Dagafvoer Borgharen, 01-01-1911_30-06-1999 excl uurtijdstip.txt','%f %f','delimiter',' ','commentstyle','matlab');

[jaar,maand,dag,datum] = datumconversiejjjjmmdd(datuminlees);

data = qborg;      %data gelijk maken aan afvoer Borgharen

%==========================================================================
%geef hier de gewenste selectie voor de analyses aan:
%==========================================================================
bej = 1911;
bem = 1;
bed = 1;
eij = 1999;
eim = 6;
eid = 30;

bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));
%selectie = find(datum >= bedatum & datum <= eidatum);

%==========================================================================
%Berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================

jaar        = jaar(selectie);
maand       = maand(selectie);
dag         = dag(selectie);
data        = data(selectie);
datum       = datenum(jaar,maand,dag);
dagnr       = (1:numel(data))';

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

%close all
%Discrete versie opschalingsmethode
%[golven_aanpas, standaardvorm] = opschaling_discreet(...
%    golven,ref_niv,nstapv,fig_golven_rel,fig_opschaling);


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
% Plotten van geselecteerde golven en trapezium.
%==========================================================================
plot_Borgharengolven(golven, ref_niv, B, topduur_inv);





% ==========================================================================
% Plotten van standaardvorm en trapezium.
% ==========================================================================

%close all

aantal_golven = max([golven.nr]);
v = standaardvorm.v;
figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on

%Toevoegen trapezium aan plot.
%bpiek = 1;  %topduur trapezium wordt hier tbv plaatje ingesteld.
bpiek = min(topduur_inv(:,2))/24;
x = [-B/2, -bpiek/2, bpiek/2, B/2]';
y = [0, 1, 1, 0]';
plot(x,y,'r');

ltxt  = [];
ttxt  = 'Gemiddelde golf Borgharen met trapezium';
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
% Diverse plaatjes golven
%==========================================================================

% Kies de kleuren.
% alle_kleuren      = hsv(aantal_golven);
alle_kleuren      = hsv(22);



% Gemeten golven als functie van de tijd.
figure
for i = 1:aantal_golven
%     plot(golven(i).tijd, golven(i).data,'b-')
    plot(golven(i).tijd, golven(i).data,'color',alle_kleuren(i,:),'Linewidth',1);   %,'MarkerSize',8);
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Gemeten golven Borgharen';
xtxt  = 'tijd, dagen';
ytxt  = 'Maasafvoer Borgharen, m3/s';
Xtick = -15:5:15;
Ytick = 0:500:3000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


% Gemeten genormeerde golven als functie van de tijd.
figure
for i = 1:aantal_golven
    plot(golven(i).tijd, golven(i).data./max(golven_aanpas(i).data),'color',alle_kleuren(i,:),'Linewidth',1);%,'b-')
    hold on
    grid on
end
hold on
plot(standaardvorm.tvoor,v,'r',standaardvorm.tachter,v,'r');
ltxt  = [];
ttxt  = 'Gemeten golven Borgharen';
xtxt  = 'tijd, dagen';
ytxt  = 'Maasafvoer Borgharen, m3/s';
Xtick = -5:1:3;
Ytick = 0.6:.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



% %Nu aangepaste golven.
% figure
% for i = 1:aantal_golven
%     plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'color',alle_kleuren(i,:),'Linewidth',1);
%     hold on
%     grid on
% end
% ltxt  = [];
% ttxt  = 'Aangepaste golven Borgharen';
% xtxt  = 'tijd, dagen';
% ytxt  = 'Maasafvoer Borgharen, m3/s';
% Xtick = -15:5:15;
% Ytick = 0:500:3000;
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% 


close all

%Nu aangepaste golven op 1 genormeerd
figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data./max(golven_aanpas(i).data),'color',alle_kleuren(i,:),'Linewidth',1);
    hold on
    grid on
end
hold on
plot(standaardvorm.tvoor,v,'r',standaardvorm.tachter,v,'r');
ltxt  = [];
ttxt  = 'Aangepaste golven Borgharen na normering op 1';
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer Borgharen, [-]';
Xtick = -5:1:5;
Ytick = 0.75:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%==========================================================================
%==========================================================================
% Bepalen breedteklassen voor de golven
%==========================================================================
%==========================================================================

% Bepaal duur per golf op relatieve hoogte:
vh       = 0.85;    %moet beslist 0.85 zijn.

duur_v   = zeros(aantal_golven,1);
duur_a   = zeros(aantal_golven,1);

for i = 1 : aantal_golven
    
    %Bepaal tijdsduur voorflank
    tijdas    = golven_aanpas(i).tijd;
    Iv        = find(tijdas <= 0);
    tijdas1   = tijdas(Iv);

    vwaarden  = golven_aanpas(i).data./max(golven_aanpas(i).data);
    vwaarden1 = vwaarden(Iv);
    
    duur_v(i) = -24 * interp1( vwaarden1, tijdas1, vh); %in uren
    
    %Bepaal tijdsduur achterflank
    tijdas    = golven_aanpas(i).tijd;
    Ia        = find(tijdas > 0);
    tijdas1   = tijdas(Ia);

    vwaarden  = golven_aanpas(i).data./max(golven_aanpas(i).data);
    vwaarden1 = vwaarden(Ia);
    
    duur_a(i) = 24 * interp1( vwaarden1, tijdas1, vh);

end
% totale duur per golf, op niveau vh:
duur_tot      = duur_v + duur_a;
duur_tot_sort = sort(duur_tot); %gemakshalve sorteren.

disp('  ')
disp(['aantal golven = ', num2str(aantal_golven)])
disp(['gemiddelde duur volgens analyse op niveau v  = ', num2str(vh),' is ', num2str( mean(duur_tot_sort) ),' uur'])


%==========================================================================
% Indeling in klassen maken.
%==========================================================================


% DIVERSE GEGEVENS OPGEVEN.
% Geef aantal klassen op. N.B: stem keuze_klassekansen goed af op n, anders een crash.
n          = 5;

% Kies hier kansen voor HR2006-golf (1) of spitsere golf (0).
keuze_HR2006_of_spitser    = 0;

if keuze_HR2006_of_spitser == 1     %HR2006 (deze heeft uniforme verdeling)
    keuze_klassekansen   = 1/n*ones(1,n);
elseif keuze_HR2006_of_spitser == 0  %spitse golf
%     keuze_klassekansen   = [0.42, 0.25, 0.21, 0.08, 0.04];    %hier n = 5, reproductie d = 46.4 uur (46.38 uur).
     keuze_klassekansen   = [0.26, 0.23, 0.19, 0.17, 0.15];    %hier n = 5, reproductie d = 58 uur (57.9 uur).
%      keuze_klassekansen   = [0, 1, 0, 0, 0];    %hier n = 5, reproductie 58.0 uur zonder spreiding.
%      keuze_klassekansen   = [0, 1, 0, 0, 0];    %hier n = 5, reproductie 46.4 uur zonder spreiding.
end


% percentielen voor de klassen bepalen (pbins bevat de bovengrenzen van de klassen, uitgezonderd die van de laatste klasse).
hulpvector   = cumsum( keuze_klassekansen );
pbins        = hulpvector(1:end-1)';        %bijv.: pbins = [0.2, 0.4, 0.6, 0.8]';
kwant        = quantile(duur_tot_sort,pbins);

% Linker- en rechtergrenzen van de klassen, en opslaan in 1 matrix
bingr_l = [min(duur_tot); kwant];
bingr_r = [kwant; max(duur_tot)];
bingr   = [bingr_l, bingr_r];

% Bepaal gemiddelde per klasse
duur_gem_per_klasse     = zeros(n,1);
Nklasse      = zeros(n,1);

for j = 1 : n

    % Indices bepalen voor niet overlappende klassen:
    if j == 1
        Fj_geen_overlap = find( duur_tot_sort >= bingr(j,1) & duur_tot_sort <= bingr(j,2) ); %zorg dat laagste waarde van duur_tot_sort wordt meegenomen
    elseif j >= 2
        Fj_geen_overlap = find( duur_tot_sort > bingr(j,1) & duur_tot_sort <= bingr(j,2) );
    end
    
    duur_gemj   = duur_tot_sort(Fj_geen_overlap);
    duur_gem_per_klasse(j) = mean(duur_gemj);
    Nklasse(j)  = numel(duur_gemj);

end

%==========================================================================
% Empirische kansverdeling
%==========================================================================

% Bepaal kansen (plotposities) voor de klassemiddens
if keuze_HR2006_of_spitser == 1
    kansen_klassemiddens = cumsum(keuze_klassekansen)-0.5/n;  %HR2006 (gelijke kansen per klasse)

elseif keuze_HR2006_of_spitser == 0                           %spitse golf
    kansen_klassemiddens(1,1) = keuze_klassekansen(1)/2;    
    for j = 2:n
        hulp = cumsum( keuze_klassekansen(1:j-1) );
        kansen_klassemiddens(j,1) = hulp(end) + keuze_klassekansen(j)/2;    %spitse golf
    end
end

% Keuze van de klasses:
duur_gem_keuze       = [30, 46.4, 58.0, 70, 110]';       %handmatig; 2-e en 3-e klasse volgens spitse golf en verwachtingswaarde.



figure
plot( duur_tot_sort,  [1:aantal_golven]/(aantal_golven+1),'b.');
grid on
hold on
plot( duur_gem_per_klasse, kansen_klassemiddens,'r*')          %volgens analyse
plot( duur_gem_keuze, kansen_klassemiddens,'g*')    %volgens keuze

% % breng klassegrenzen in beeld
% for ii = 1 : n
%     plot( [bingr_l(ii), bingr_l(ii)], [0, 1], 'k','Linewidth', 1);
% end

% breng klassekansen in beeld:
for ii = 1 : n-1
    plot(  [20, 140], [pbins(ii), pbins(ii)], 'k','Linewidth', 1);
end

gemiddelde_duur_in_keuze = keuze_klassekansen*duur_gem_keuze;
title(['Empirische verdeling overschrijdingsduren, gem. duur keuze = ',num2str(gemiddelde_duur_in_keuze),' uur'])
xlabel('Duur, uur')
ylabel('Overschrijdingskans, [-]')
legend('data', 'middens analyse', 'middens keuze','Location', 'SouthEast')
disp('  ')
disp(['Gemiddelde duur volgens keuze van klassemiddens = ', num2str(gemiddelde_duur_in_keuze),' uur'])


%==========================================================================
% Bepaal gemiddelde duur op niveau v = 0.85 Borgharen volgens golfvormgenerator (versie HR2006).
%==========================================================================

% verwachtingswaarde golfvormgenerator.
A_verw_op   = [3185, -27.33;
               3420, -19.88];
A_verw_neer = [3185, 34.30;
               3420, 22.99];
Golfvormgen_verw_vh = - interp1(A_verw_op(:,1), A_verw_op(:,2), vh*3800)+...
                      interp1(A_verw_neer(:,1), A_verw_neer(:,2), vh*3800);

% 2.5%-golf golfvormgenerator.
A_smal_op   = [3185, -6.70;
               3420, -4.11];
A_smal_neer = [3185, 13.27;
               3420, 8.59];
Golfvormgen_smal_vh = - interp1(A_smal_op(:,1), A_smal_op(:,2), vh*3800)+...
                      interp1(A_smal_neer(:,1), A_smal_neer(:,2), vh*3800);

% Borgharen, perc = 43.5.
A_spits_op   = [3185, -20.38;
               3420, -14.07];
A_spits_neer = [3185, 29.05;
               3420, 19.30];
Golfvormgen_spits_vh = - interp1(A_spits_op(:,1), A_spits_op(:,2), vh*3800)+...
                      interp1(A_spits_neer(:,1), A_spits_neer(:,2), vh*3800);

sum(keuze_klassekansen)
                  
                