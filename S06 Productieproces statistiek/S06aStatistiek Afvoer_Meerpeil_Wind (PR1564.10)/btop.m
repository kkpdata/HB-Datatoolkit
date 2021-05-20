function [by] = btop(topduur_inv, y)
%
%Door Chris Geerse
%Berekening van topduur b(y) bij gegeven rij- of kolomvector y, dmv lineaire 
%interpolatie tussen aantal opgegeven puntenparen.
%
% Input:
% topduur_inv is een matrix met puntenparen (yi, b(yi)), met yi toenemend
% y is een vector
%
% Output:
% topduur b(y)
%

%{
%==========================================================================
%Invoerparameters tbv testen
%==========================================================================
clear all

%invoer b(y): eerste kolom is y, tweede is b(y).
topduur_inv = ...
    [0, 720;        %y moet toenemend zijn, voor b(y) geldt dat niet
    180, 48;
    900, 448];

y = (-100:5:1000);
%}

%==========================================================================
% Bepalen topduurfunctie b(y), per traject uit topduur_inv
%==========================================================================

s = size(y);
if (s(1,1)>=1 & s(1,2) > 1)     %maak van eventuele rijvector een kolomvector
    y = y';
end

by = [];      %initialisatie

%eerste traject met y < topduur_inv(1,1). Dit kan evt leeg zijn.
y0 = topduur_inv(1,1);
by0 = topduur_inv(1,2);
index_traject = find(y<y0);
by = y(index_traject)./y(index_traject).*by0;   %neem b(y) een vast getal gelijk aan eerste waarde

%middentrajecten
num_traject = size(topduur_inv,1);      %aantal trajecten met y > topduur_inv(1,1) waarop by bepaald moet worden
for i = 1:num_traject-1
    ylaag = topduur_inv(i,1);
    yhoog = topduur_inv(i+1,1);
    bylaag = topduur_inv(i,2);
    byhoog = topduur_inv(i+1,2);
    index_traject = find (y>=ylaag & y< yhoog);
    by_hulptraject = (bylaag - byhoog)*(yhoog-y(index_traject))/(yhoog-ylaag)+byhoog;
    by = [by; by_hulptraject];
end
%aanvullen met (eventueel) eindtraject; neem b(y) een vast getal gelijk aan
%laatste waarde
ylaatst = topduur_inv(num_traject,1);
bylaatst = topduur_inv(num_traject,2);
index_traject = find(y>=ylaatst);
by_eindtraject = y(index_traject)./y(index_traject).*bylaatst;
by = [by; by_eindtraject];

%{
close
plot(y,by)
grid on
hold on
xlim([min(y) max(max(y),ylaatst)]);
ylim([0 800]);
xlabel('hoogte y')
ylabel('topduur b(y)')

%}
