%==========================================================================
% Hoofdprogramma Veluwerandmeer
% Door: Chris Geerse
% Tbv: PR1322

%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
%padnaam_uit = 'D:\Users\geerse\Matlab\Stat_Rivieren_Meren_Wind\'
padnaam_uit = 'C:\Matlab\Stat_Rivieren_Meren_Wind\'

%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
%homogenisatieparameters
zichtjaar = 2011;        %homogenisatie naar 1 jan van zichtjaar
stijging_per_jaar = 0.00; %aangenomen stijging per jaar in m 

%geef hier de gewenste selectie aan:
bej = 1976; bem = 1; bed = 1;
%bej = 1976; bem = 10; bed = 1;
eij = 2008; eim = 4; eid = 1;

%Overige parameters
drempel = -0.14;         % variabele voor drempel waarde (drempel -0.14 levert 11 golven, drempel -0.15 levert ca 14 golven, met smallere toppen)
ref_niv = -0.4;          %referentieniveau van waaraf wordt opgeschaald
basis_niv = -0.4;        %hoogte waarop trapezium begint (meestal gelijk aan ref_niv).
piekduur = 0.9999;       %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;            %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 0;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 0;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet

%parameters trapezia
B     = 60;             %basisduur trapezia
zpot  = floor(B/2);     % zichtduur voor selectie pieken; NB: kies 15 dagen voor beoordelen werklijn (bij 30 dagen vallen er veel pieken weg)
zB    = floor(B/2);     %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven
bpiek = 4;  %topduur (dagen) trapezium wordt hier tbv topduur_inv en plaatje ingesteld.

topduur_inv = ...       %Keuze voor PR1371.30
    [-0.40, B*24;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    -0.22, bpiek*24;
    1.80, bpiek*24]

Ntrapezia      = 180/B;
ovkanspiek_inv = ...       %
    [-0.4, 1;
    -0.22, 1/Ntrapezia;    %traject van -0.22 tot 1.00 m+NAP volgens Hydra-M, wel gedeeld door aantal trapezia in whjaar
    1.00, 3.0419E-06/Ntrapezia]
%    1.55, 1.01e-8/Ntrapezia]

if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end
c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)

%parameters meerpeil
stapy = 0.05;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
ymax  = 0.8;        %maximum van vector
av = 0.3;     %niveau insnoering in verticale richting
ah = 0.4;     %mate insnoering in horizontale richting


%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all   %opdat geen lege figuur wordt getoond

%==========================================================================
%Inlezen van Hydra-M statistiek
%==========================================================================
%--------------------------------------------------------------------------
%Inlezen Hydra-M statistiek, respectievelijk:
%m, m+NAP; OF, 1/whjaar; OD, dag/whjaar; ODwest, dag/whjaar; ODoost, dag/whjaar
[m_HM, OF_HM, OD_HM, OD_HMwest, OD_HMoost] = textread('statistiek_Hydra_M_Markermeer.txt','%f %f %f %f %f','delimiter',' ','commentstyle','matlab');

%--------------------------------------------------------------------------
%Inlezen data
[dag, maand, jaar, data] = textread('Markermeermetingen.dat','%f %f %f %f','delimiter',' ','commentstyle','matlab');
datum                    = datenum(jaar,maand,dag); 

% Ontbrekende waarden zijn weergegeven als -999 (periode 3 juni - 31
% december 1981)
% Selecteer alleen geldige waarnemingen.
Fgeldig     = find(data > -999);
dag         = dag(Fgeldig);
maand       = maand(Fgeldig);
jaar        = jaar(Fgeldig);
data        = data(Fgeldig);
datum       = datum(Fgeldig);


%==========================================================================
%Selectie whjaren en berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
bedatum = datenum(bej,bem,bed);
eidatum = datenum(eij,eim,eid);

selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(datum >= bedatum & datum <= eidatum));
%selectie = find(datum >= bedatum & datum <= eidatum);

jaar = jaar(selectie); maand = maand(selectie); dag = dag(selectie); data = data(selectie);
datum = datenum(jaar,maand,dag);
dagnr = (1:numel(data))';


%--------------------------------------------------------------------------
%NB: voor VRM trendcorrectie 0 nemen!!
%Trendcorrectie toepassen op de meerpeilen (neem de correctie binnen één
%jaar steeds hetzelfde. Homogenisatie naar 1 jan van het zichtjaar.
datum_zichtjaar = datenum(zichtjaar,1,1);
delta_meerpeil = (datum_zichtjaar-datum)*stijging_per_jaar/365.25;
data = data + delta_meerpeil;


%==========================================================================
% Momentane ov.kans volgens berekening met trapezia
%==========================================================================

% [berek_trap] = grootheden_kniktrap(stapy, ymax, basis_niv, B, av, ah, topduur_inv, ovkanspiek_inv)
% %         y: [Nx1 double]
% %         by: [Nx1 double]
% %    fy_piek: [Nx1 double]
% %    Gy_piek: [Nx1 double]
% %     fy_mom: [Nx1 double]
% %     Gy_mom: [Nx1 double]
% 
% % [berek_trap.y,berek_trap.by, berek_trap.fy_piek, ...
% %    berek_trap.Gy_piek, berek_trap.fy_mom, berek_trap.Gy_mom];

display('begin berekening grootheden_kniktrap');

ymin = topduur_inv(1,1);   %laagste waarde van y
y = [ymin: stapy: ymax]';
berek_trap.y = y;        %berekening veld y

by = [];      %initialisatie
num_traject = size(topduur_inv,1);      %aantal trajecten waarop by bepaald moet worden

for i = 1:num_traject-1
    ylaag = topduur_inv(i,1);
    yhoog = topduur_inv(i+1,1);
    bylaag = topduur_inv(i,2);
    byhoog = topduur_inv(i+1,2);
    index_traject = find (y>=ylaag & y<yhoog);
    by_hulptraject = (bylaag - byhoog)*(yhoog-y(index_traject))/(yhoog-ylaag)+byhoog;
    by = [by; by_hulptraject];
end
%aanvullen met eindtraject (neem b(y) een vast getal gelijk aan laatste waarde)
ylaatst = topduur_inv(num_traject,1);
bylaatst = topduur_inv(num_traject,2);
index_traject = find(y>=ylaatst);
by_eindtraject = y(index_traject)./y(index_traject).*bylaatst;
by = [by; by_eindtraject];

berek_trap.by = by;        %berekening veld by

%==========================================================================
% Bepalen piekkansen fy_piek en Gy_piek als functie van y
%==========================================================================

fy_piek = [];      %initialisatie
Gy_piek = [];      %initialisatie
num_traject = size(ovkanspiek_inv,1);      %aantal trajecten waarop fy_piek en Gy_piek bepaald moet worden
for i = 1:num_traject-1
    fy_ylaag = ovkanspiek_inv(i,1);
    fy_yhoog = ovkanspiek_inv(i+1,1);
    povlaag = ovkanspiek_inv(i,2);
    povhoog = ovkanspiek_inv(i+1,2);
    a(i)=(fy_yhoog-fy_ylaag)/(log(povlaag)-log(povhoog));
    b(i)=(fy_yhoog*log(povlaag)-fy_ylaag*log(povhoog))/(log(povlaag)-log(povhoog));
    index_traject = find (y>=fy_ylaag & y<fy_yhoog);
    fy_hulptraject = exp((b(i)-y(index_traject))/a(i))/a(i);
    Gy_hulptraject = exp((b(i)-y(index_traject))/a(i));
    fy_piek = [fy_piek; fy_hulptraject];
    Gy_piek = [Gy_piek; Gy_hulptraject];
end

%aanvullen met eindtraject (zet laatste traject voort)
a(num_traject) = a(num_traject-1);
b(num_traject) = b(num_traject-1);
y_laatstetraject = ovkanspiek_inv(num_traject,1);
Gy_laatstetraject = ovkanspiek_inv(num_traject,2);
index_traject = find(y>=y_laatstetraject);
fy_eindtraject = exp((b(num_traject)-y(index_traject))/a(num_traject))/a(num_traject);
fy_piek = [fy_piek; fy_eindtraject];
Gy_eindtraject= exp((b(num_traject)-y(index_traject))/a(num_traject));
Gy_piek = [Gy_piek; Gy_eindtraject];

%exacte normering kansen op 1
fy_piek = fy_piek/sum(fy_piek*stapy);
Gy_piek = Gy_piek/Gy_piek(1);

berek_trap.fy_piek = fy_piek;        %berekening veld fy_piek
berek_trap.Gy_piek = Gy_piek;        %berekening veld Gy_piek

display('parameters a en b uit exponentieel verband Gy = exp((b-y)/a): ybeg, yend, a, b')
ybeg = ovkanspiek_inv(:,1);
yend = ybeg;    %initialisatie
for i = 1:numel(ybeg)-1
    yend(i) = ybeg(i+1);
end
yend(numel(ybeg)) = ymax;
[ybeg, yend, a', b']

display('parameters a0, b0 uit werklijn y = a0*ln(T)+b0 (180/B basisperioden/whj): ybeg, yend, a0, b0')
for i = 1:numel(ybeg)-1
    yend(i) = ybeg(i+1);
end
yend(numel(ybeg)) = ymax;
a0 = a;
b0 = b + a*log(180/B);
[ybeg, yend, a0', b0']

%==========================================================================
% Bepalen momentane kansen fy_mom en Gy_mom als functie van y
%==========================================================================

x = y;      %noem piekwaarden y en niveaus x (in formules geldt k=y, q = x(i))
Gx =[];
for i = 1:numel(x)
        
    %Berekening overschrijdingsduur niveau x(i) in dagen binnen trapezium met hoogte y (is berekening L(q,k)):
    %y is een vector, x(i) een skalar
    
    bp          = [berek_trap.by]                 %vector met duur piekniveau in uren
    y_tussen    = basis_niv + av*(y - basis_niv)  %vector met tussenniveaus
    bp_tussen   = bp + ah*(1-av)*(B*24-bp)        %vector met duur van het tussenniveau in uren
    
    %Lxy_boven is vector met waarden L(q,k), bij skalar q, die juiste duur geeft als
    %k zo hoog dat knikniveau boven q ligt, en 0 als knikniveau onder q ligt
    knikniv_bovenxi = (y_tussen >= x(i));     %waarden 1 als k-waarde zdd knik hoger dan x(i), anders waarden 0
    Lxy_boven       = (bp_tussen + (B*24-bp_tussen).*(y_tussen - x(i))./(y_tussen - basis_niv + eps)).*knikniv_bovenxi;
    [y,Lxy_boven]
    
    %Lxy_boven is vector met waarden L(q,k), bij skalar q, die juiste duur geeft als
    %k zo laag dat knikniveau onder q ligt, en 0 als knikniveau boven q ligt
    knikniv_onderxi = (y_tussen < x(i));     %waarden 1 als k-waarde zdd knik onder x(i), anders waarden 0
    Lxy_onder       = (bp + (bp_tussen - bp).*(y - x(i))./(y - y_tussen + eps)).*knikniv_onderxi;
    
    %vector met waarden L(q,k), in dagen, bij skalar q, die 0-waarden heeft onder niveau q
    groterdanxi     = (y>=x(i));
    Lxy_dag         = ((Lxy_boven + Lxy_onder).*groterdanxi)/24;  
    Gx(i)           = stapy/B*sum([berek_trap.fy_piek].*Lxy_dag);   %berekening van de integraal
end

Gx = Gx';
fx = -diff(Gx)/stapy;       %bepalen van momentane kansdichtheid
fx = [fx; Gx(numel(Gx))];   %nu fx en Gx even lang; laatste klasse krijgt overblijvende kans

%exacte normering kansen op 1
fx = fx/sum(fx*stapy);
Gx = Gx/Gx(1);

%nu weer niveaus y noemen:
berek_trap.fy_mom = fx;        %berekening veld fy_mom
berek_trap.Gy_mom = Gx;        %berekening veld Gy_mom

display('eind berekening grootheden_kniktrap');



%==========================================================================
% Momentane ov.kans volgens de metingen (observaties)
%==========================================================================
yturf = [(-0.5: stapy : ovkanspiek_inv(1,1))'; berek_trap.y];
[mom_obs] = turven_metingen(yturf, data);
%mom_obs =
%     y: [Nx1 double]       %vector met afvoerniveaus (= berek_trap.y)
%    Gy: [Nx1 double]       %momentane ov.kansen
%    fy: [Nx1 double]       %momentane kansdichtheid

%[mom_obs.y mom_obs.Gy mom_obs.fy ]


%==========================================================================
% Plaatjes momentane kansen volgens de metingen en volgens de integratie
%==========================================================================
% %gemiddeld meerpeil
% mpgem_data = mean(data)
% stdev_data = std(data)
% mpgem_trap = sum(berek_trap.fy_mom*stapy .*berek_trap.y)
% stdev_trap = (sum(berek_trap.fy_mom*stapy .*(berek_trap.y).^2) - mpgem_trap^2)^0.5



%close all
figure
plot(mom_obs.y,log(mom_obs.Gy),'r',berek_trap.y,log(berek_trap.Gy_mom),'b-.')
grid on
hold on
plot(m_HM, log(OD_HM/OD_HM(1)),'k-')
cltxt  = {'op basis geturfde data','Hydra-VIJ','Hydra-M'};
ltxt  = char(cltxt);
ttxt  = 'Momentane kansen Markermeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = -0.4:0.1:0.2;
Ytick = -9:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

disp('[y, berek_trap.by, bp, bp_tussen, berek_trap.fy_mom, berek_trap.Gy_mom]')

[y, berek_trap.by, bp, bp_tussen,...
  berek_trap.fy_mom, berek_trap.Gy_mom]

