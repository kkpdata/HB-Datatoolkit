function [piekkansen] = piekkansen_basisduur(stapy, ymax, ovkanspiek_inv);
%
%Door Chris Geerse
%Berekening van kansdichtheid en overschrijdingskans voor de piekwaarde
%in de basisduur B.
%Versie met output in structure
%
% Input:
% stapy is stapgrootte in y
% ymax is hoogste waarde van y
% B is basisduur in dagen
% ovkanspiek_inv is invoer middels puntenparen overschr.kansen piekwaarden
%
% Output:
% Structure piekkansen met velden:
% y: equidistante vector (eventueel is laatste klasse afwijkend in
%       stapgrootte)
% fy_piek: kansdichtheid piekafvoer in basisduur
% Gy_piek: overschr.kans piekafvoer in basisduur
%
% NB: laagste y is gelijk aan ovkanspiek_inv(1,1)
%
% Waarden a en b uit exponentiële trajecten worden afgebeeld op scherm.
%
%

%==========================================================================
%Oude invoer tbv testen
%==========================================================================

stapy = 50;      %stapgrootte
ymax = 600;     %maximum van vector

ovkanspiek_inv = ...
    [0, 1;
    180, 0.16667;
    550, 1.3333e-4]

%==========================================================================
% Bepalen topduurfunctie by als functie van y
%==========================================================================

display('begin functie piekkansen_basisduur');

ymin = ovkanspiek_inv(1,1);   %laagste waarde van y
y = [ymin: stapy: ymax]';
piekkansen.y = y;             %berekening 1-ste veld

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

piekkansen.fy_piek = fy_piek;        %berekening veld fy_piek
piekkansen.Gy_piek = Gy_piek;        %berekening veld Gy_piek

display('parameters a en b uit exponentieel verband Gy = exp((b-y)/a): ybeg, yend, a, b')
ybeg = ovkanspiek_inv(:,1);
yend = ybeg;    %initialisatie
for i = 1:numel(ybeg)-1
    yend(i) = ybeg(i+1);
end
yend(numel(ybeg)) = ymax;
[ybeg, yend, a', b']


display('eind functie piekkansen_basisduur');