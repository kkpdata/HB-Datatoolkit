function [mom_obs] = turven_metingen(y, data);
%
%Door Chris Geerse
%Berekening van momentane kdf en ovkans door turven van waarnemingen.
%Versie met structure
%
% Input:
% equidistante vector y, die niveaus voor turven bevat
% datavector met waarnemingen
%
% Structure mom_obs met velden:
% vector met niveaus y waarvoor geturfd wordt
% kansdichtheid fy
% overschr.kans Gy
%
%==========================================================================
% Momentane kansen volgens de metingen
%==========================================================================

N = numel(data);    %aantal waarnemingen in geselecteerde periode
Gy_mom_obs = y;     %initialisatie
q = y;              %niveaus waarvoor geturfd wordt
for i = 1:numel(q)
    x = find(data >= q(i));
    ovwaarnemingen = numel(x);
    Gy_mom_obs(i) = ovwaarnemingen/N;
end
mom_obs.y = y;                  %bepalen veld mom_obs.y
mom_obs.Gy = Gy_mom_obs;        %bepalen veld mom_obs.Gy


stapy = y(2)-y(1);
fy_mom_obs = y;   %initialisatie
fy_mom_obs = -diff(Gy_mom_obs)/stapy;             %bepalen van momentane kansdichtheid
fy_mom_obs = [fy_mom_obs; Gy_mom_obs(numel(Gy_mom_obs))];   %laatste klasse krijgt overblijvende kans

mom_obs.fy = fy_mom_obs;        %bepalen veld mom_obs.fy
