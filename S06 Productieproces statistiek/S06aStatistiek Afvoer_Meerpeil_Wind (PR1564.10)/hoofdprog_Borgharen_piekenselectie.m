%==========================================================================
% Script om pieken te selecteren met een zichtduur voor Borgharen.
% Dat wordt hier gedaan voor een bepaald databestand; uiteraard kan dat ook
% anders worden gekozen.
%
% Door: Chris Geerse, 11 januari 2018


%==========================================================================
clear
clc
close all
addpath 'Invoer' 'Huilproutines'
%==========================================================================


%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
%==========================================================================
drempel = 400;         % variabele voor drempel POT-reeks (1700 m3/s -> 20 golven).
                        % Kies voor goede frequentielijn bijvoorbeeld
                        % drempel 400 m3/s (dan geen plaatjes voor golven)
                        
zpot    = 15;           % zichtduur voor selectie pieken
zB      = zpot;         % deze niet aanpassen!

c = 0.12;          % constante Gringorton in de formule voor de plotposities (werklijn)
d = 0.44;          % constante Gringorton in de formule voor de plotposities (werklijn)


%==========================================================================
%Inlezen data
%==========================================================================
[datuminlees,qborg]    = textread('Dagafvoer Borgharen, 01-01-1911_30-06-1999 excl uurtijdstip.txt','%f %f','delimiter',' ','commentstyle','matlab');

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
selectie = find(datum >= bedatum & datum <= eidatum);

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
% Plotten van geselecteerde golven (tenzij meer dan 20
%==========================================================================

N           = numel(golven);    % aantal pieken

if N <= 20
    aantal_golven = max([golven.nr]);
    z             = (length([golven(1).tijd])-1)/2;
    t_as          = [golven(1).tijd];
    
    figure
    a = 1;
    for n = 1:N
        rest = mod(n-1,12);
        if rest == 0 & n > 1    %als rest=0 is n-1 = K*12, met K geheel
            figure
            a = 1;
        end
        subplot(3,4,a)
        a = a + 1;
        plot(t_as, [golven(n).data])
        hold on
        grid on
        xlim([-z z])
        ylim([0 3000])
        jaarn  = golven(n).jaa;
        maandn = golven(n).mnd;
        dagn   = golven(n).dag;
        piekdatumn = datenum(jaarn, maandn, dagn);
        title(['piek: ',datestr(piekdatumn)])
    end
end

%==========================================================================
% Maak frequentielijn (hier voor hele jaar)
%==========================================================================
pieken      = [golven.piek]';   % maak vector van de piekwaarden

pieken_sort = sort(pieken,'descend');   %sorteer van groot naar klein
t_per       = max(jaar) - min(jaar) +1;
plotposT    = ((N+c)*t_per)./(([1:N]+c+d-1)*N);
plotposFreq = 1./plotposT;

figure
semilogy(pieken_sort, plotposFreq,'r*')
hold on; grid on
title('Overschrijdingsfrequentie Borgharen')
xlabel('Afvoer, m^3/s')
ylabel('Overschrijdingsfrequentie, 1/jaar')