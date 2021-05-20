function [berekeningen_trap] = grootheden_trap(stapy, ymax, B, topduur_inv, ovkanspiek_inv);
%
%Door Chris Geerse
%Berekening van diverse grootheden die aan trapezia met basisduur B zijn gerelateerd.
%Versie met output in structure
%
% Input:
% stapy is stapgrootte in y
% ymax is hoogste waarde van y
% B is basisduur in dagen
% topduur_inv is invoer middels puntenparen topduur
% ovkanspiek_inv is invoer middels puntenparen overschr.kansen piekwaarden
%
% Output:
% Structure berekeningen_trap met velden:
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
%{
%==========================================================================
%Oude invoer tbv testen
%==========================================================================

stapy = 50;      %stapgrootte
ymax = 600;     %maximum van vector
B = 30;

topduur_inv = ...
    [0, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    300, 408;
    1000, 48]

ovkanspiek_inv = ...
    [0, 1;
    180, 0.16667;
    550, 1.3333e-4]


%}
%==========================================================================
%checken consistentie invoer
if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (wel met verkeerde resultaten).')
    pause
end

%==========================================================================
% Bepalen topduurfunctie by als functie van y
%==========================================================================

display('begin functie grootheden_trap');

ymin = topduur_inv(1,1);   %laagste waarde van y
y = [ymin: stapy: ymax]';
berekeningen_trap.y = y;        %berekening veld y

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

berekeningen_trap.by = by;        %berekening veld by

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

berekeningen_trap.fy_piek = fy_piek;        %berekening veld fy_piek
berekeningen_trap.Gy_piek = Gy_piek;        %berekening veld Gy_piek

display('parameters a en b uit exponentieel verband Gy = exp((b-y)/a): ybeg, yend, a, b')
ybeg = ovkanspiek_inv(:,1);
yend = ybeg;    %initialisatie
for i = 1:numel(ybeg)-1
    yend(i) = ybeg(i+1);
end
yend(numel(ybeg)) = ymax;
[ybeg, yend, a', b']

%==========================================================================
% Bepalen momentane kansen fy_mom en Gy_mom als functie van y
%==========================================================================

x = y;      %noem piekwaarden y en niveaus x
Gx =[];
for i = 1:numel(x)
    groterdanxi = (y>=x(i));
    %overschrijdingsduur niveau x(i) in dagen binnen trapezium:
    Lxy = (([berekeningen_trap.by] + (B*24-[berekeningen_trap.by]).*(y-x(i))./(y+eps)).*groterdanxi)/24;
    Gx(i) = stapy/B*sum([berekeningen_trap.fy_piek].*Lxy);   %berekening van de integraal
end

Gx = Gx';
fx = -diff(Gx)/stapy;       %bepalen van momentane kansdichtheid
fx = [fx; Gx(numel(Gx))];   %nu fx en Gx even lang; laatste klasse krijgt overblijvende kans

%exacte normering kansen op 1
fx = fx/sum(fx*stapy);
Gx = Gx/Gx(1);

%nu weer niveaus y noemen:
berekeningen_trap.fy_mom = fx;        %berekening veld fy_mom
berekeningen_trap.Gy_mom = Gx;        %berekening veld Gy_mom

display('eind functie grootheden_trap');