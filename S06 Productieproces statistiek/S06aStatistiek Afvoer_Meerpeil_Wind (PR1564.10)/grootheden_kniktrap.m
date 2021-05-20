function [berek_trap] = grootheden_kniktrap(stapy, ymax, basis_niv, B, av, ah, topduur_inv, ovkanspiek_inv);
%
%Door Chris Geerse
%Berekening van diverse grootheden die aan trapezia met basisduur B zijn gerelateerd.
%Versie met output in structure
%
% Input:
% stapy is stapgrootte in y
% ymax is hoogste waarde van y
% B is basisduur in dagen
% av is verticaal relatief niveau insnoering
% ah horizontale factor van insnoering (1 = geen insnoering)
% topduur_inv is invoer middels puntenparen topduur
% ovkanspiek_inv is invoer middels puntenparen overschr.kansen piekwaarden
%
% Output:
% Structure berek_trap met velden:
% equidistante vector y (eventueel is laatste klasse afwijkend in
%       stapgrootte)
% topduur by,
% kansdichtheid fy_piek,
% overschr.kans Gy_piek,
% momentane kansdichtheid fy_mom,
% momentane overschr.kans Gy_mom,
% NB: laagste y is gelijk aan topduur_inv(1,1) = ovkanspiek(1,1)
%
% Waarden a en b uit exponentiële trajecten worden afgebeeld op scherm.
%
%

%==========================================================================
% Bepalen topduurfunctie by als functie van y
%==========================================================================

display('begin functie grootheden_kniktrap');

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

%OUD (ZONDER INSNOERING)
% x = y;      %noem piekwaarden y en niveaus x
% Gx =[];
% for i = 1:numel(x)
%     groterdanxi = (y>=x(i));
%     %overschrijdingsduur niveau x(i) in dagen binnen trapezium:
%     bp = berek_trap.by;
%     Lxy = (([bp] + (B*24-[bp]).*(y-x(i))./(y-basis_niv+eps)).*groterdanxi)/24;  %vector met waarden L(q,k), bij skalar q, die 0=waarden heeft onder q
%     Gx(i) = stapy/B*sum([berek_trap.fy_piek].*Lxy);   %berekening van de integraal
% end

%NIEUW
x = y;      %noem piekwaarden y en niveaus x (in formules geldt k=y, q = x(i))
Gx =[];
for i = 1:numel(x)
        
    %Berekening overschrijdingsduur niveau x(i) in dagen binnen trapezium met hoogte y (is berekening L(q,k)):
    %y is een vector, x(i) een skalar
    
    bp          = [berek_trap.by];                 %vector met duur piekniveau in uren
    y_tussen    = basis_niv + av*(y - basis_niv);  %vector met tussenniveaus
    bp_tussen   = bp + ah*(1-av)*(B*24-bp);        %vector met duur van het tussenniveau in uren
    
    %Lxy_boven is vector met waarden L(q,k), bij skalar q, die juiste duur geeft als
    %k zo hoog dat knikniveau boven q ligt, en 0 als knikniveau onder q ligt
    knikniv_bovenxi = (y_tussen >= x(i));     %waarden 1 als k-waarde zdd knik hoger dan x(i), anders waarden 0
    Lxy_boven       = (bp_tussen + (B*24-bp_tussen).*(y_tussen - x(i))./(y_tussen - basis_niv + eps)).*knikniv_bovenxi;
    
    %Lxy_onder is vector met waarden L(q,k), bij skalar q, die juiste duur geeft als
    %k zo laag dat knikniveau onder q ligt, en 0 als knikniveau boven q ligt
    knikniv_onderxi = (y_tussen < x(i));     %waarden 1 als k-waarde zdd knik onder x(i), anders waarden 0
    Lxy_onder       = (bp + (bp_tussen - bp).*(y - x(i))./(y - y_tussen + 1e-10)).*knikniv_onderxi;
    
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

display('eind functie grootheden_kniktrap');

