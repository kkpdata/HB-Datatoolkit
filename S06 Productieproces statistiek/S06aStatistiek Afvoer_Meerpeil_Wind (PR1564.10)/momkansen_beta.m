function [mombeta] = momkansen_beta(a, b, nstapx_beta, nstapy_beta, berek_trap);
%
%Door Chris Geerse
%Berekening van momentane kansdichtheid en overschrijdingskans uitgaande
%van beta-golfvormen voor de afvoer en gegeven overschr.kansen.
%Versie met structure
%
% Input:
% a en b zijn parameters voor de beta-verdeling
% nstapx_beta is aantal klassen voor interval [0,1] op x-as van genormeerde
%       beta-golf (piek = 1)
% nstapy_beta is aantal klassen voor interval [0,1] op y-as van genormeerde
%       beta-golf (piek = 1)
% berek_trap (velden y en Gy_piek)
%
% Output:
% Structure mombeta met velden:
% vector met niveaus y
% kansdichtheid fy
% overschr.kans Gy
%
% Calls naar:
% beta_normgolf(a, b, nstapx_beta, nstapy_beta)
%
%{
%==========================================================================
%Invoerparameters
%==========================================================================

clear all;

a = 4.1;
b = 3.95;
nstapx_beta = 100;
nstapy_beta = 100;

stapy = 50;      %stapgrootte
ymax = 600;     %maximum van vector
B = 30;
topduur_inv = ...
    [0, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    180, 48;
    550, 48]
ovkanspiek_inv = ...
    [0, 1;
    180, 0.16667;
    550, 1.3333e-4]

[berek_trap] = grootheden_trap(stapy, ymax, B, topduur_inv, ovkanspiek_inv);
Gy_piek = [berek_trap.y, berek_trap.Gy_piek];

%[by, fy_piek, Gy_piek, fy_mom, Gy_mom] = grootheden_trap(stapy, ymax, B, topduur_inv, ovkanspiek_inv);
%}

%==========================================================================
%Begin feitelijke functie
%==========================================================================
%==========================================================================
%Bepalen van Gy_mombeta
%==========================================================================
display('begin functie momkansen_beta');

[beta_normgolfvorm, beta_normgolfduur] = beta_normgolf(a, b, nstapx_beta, nstapy_beta);
GD = beta_normgolfduur;

%y = Gy_piek(:,1);
y = berek_trap.y; 
mombeta.y = y;          %bepalen van 1-ste veld

%Gy = Gy_piek(:,2);     %ovkans als vector ipv matrix
Gy = berek_trap.Gy_piek;     %ov.kans voor piekwaarde trapezia

%tbv testen tijdelijk iets veranderen
%y = y.^0.5;

%bepalen klassebreedtes corresponderend met Gy (nodig verderop)
%ykb(1) is y(2)-y(1), ykb(2) is y(3)-y(2),... laatste getal wordt gelijk
%aan een na laatste breedte genomen
yshift = circshift(y, -1);        %alle getallen 1 naar boven schuiven
yshift(numel(yshift))= 0;         %laatste getal 0 maken
ykb = yshift-y;                   %klassebreedte (laatste klopt niet)
ykb(numel(ykb)) = ykb(numel(ykb)-1);     %maak laatste klassebreedte gelijk aan voorgaande
%[y yshift ykb]

%klassekans bepalen voor Gy
Gyshift = circshift(Gy, -1);        %alle getallen 1 naar boven schuiven
Gyshift(numel(Gyshift))= 0;         %laatste getal 0 maken
Pk = Gy-Gyshift;                    %klassekans (laatste klasse bevat ov.kans van laatste niveau)
%Pk(numel(Pk)) = Pk(numel(Pk)-1);    %maak laatste klassekans gelijk aan voorgaande MOET JE DUS NIET DOEN
%Pk = Pk/sum(Pk);     %exacte normering kansen op 1 IS NIET NODIG
%[Gy Gyshift Pk]

x = y;      %noem vooreerst niveaus x ipv y

Gy_mb = x; %initialisatie
for i = 1:numel(x)
    F = find(y>=x(i));
    Gy_mb(i) = sum(Pk(F).*interp1(GD(:,1),GD(:,2), x(i)./(y(F)+eps)));  %integraal berekenen
end
% Voor laatste x(i) wordt berekend interp1(GD(:,1),GD(:,2), 1) wat een
% zeer klein negatief getal oplevert, wat onwenselijk is
Gy_mb(numel(x)) = 0;    %geef laatste niveau ov.kans 0
Gy_mb = Gy_mb/Gy_mb(1);   %exacte normering op 1

%Gy_mombeta = [y Gy_mb];     %2-de output argument van functie bepalen
mombeta.Gy = Gy_mb;         %bepalen van 2-de veld

%==========================================================================
%Bepalen van fy_mombeta
%==========================================================================

%klassekans bepalen voor Gy_mb
Gy_mbs = circshift(Gy_mb, -1);         %alle getallen 1 naar boven schuiven
Gy_mbs(numel(Gy_mb))= 0;               %laatste getal 0 maken
Pk_mb = Gy_mb-Gy_mbs;                  %klassekans (laatste klassekans klopt omdat laatste getal uit Gy_mb 0 is)
%Pk_mb = Pk_mb/sum(Pk_mb);                  %exacte normering kansen op 1 HOEFT NIET
%[Gy_mb Gy_mbs Pk_mb]

fy_mb = Pk_mb./ykb;

%display('y, ykb ykb.*fy_mb Gy_mb');
%[y, ykb ykb.*fy_mb Gy_mb]

%fy_mombeta = [y fy_mb];     %1-ste output argument van functie bepalen
mombeta.fy = fy_mb;         %bepalen van 3-de veld


%[fy_mombeta(:,1) fy_mombeta(:,2).*ykb Gy_mombeta ]


display('eind functie momkansen_beta');
