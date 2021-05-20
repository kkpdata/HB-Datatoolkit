function [] = plot_verloopqm(golvenq, paren, zc, datumm, datam);
%
% Door Chris Geerse
% 
%
%==========================================================================
%
%Plaatjes worden gemaakt van de geselecteerde afvoergolven (onafh variabele)
%met bijbehorende meerpeilverlopen (afh variabele).
%
%Input:
%golvenq: structure met gegevens geselecteerde afvoerpieken k
%paren: structure met gegevens geldige puntenparen (k,sx) en (k,sr)
%zc: halve breedte zoekvenster
%datumm: seriële datums van meetreeks afh variabele s
%datam: waarden in de meetreeks van de afh variabele s
%
%Output:
%plaatjes
%
%==========================================================================
%Begin functie
%==========================================================================
Nallegolvenk = max([golvenq.rang]);
kalle_sdtm = zeros(Nallegolvenk,1);     %init seriële datums alle golven
for i = 1:Nallegolvenk 
    kalle_sdtm(i) = datenum(golvenq(i).jaa, golvenq(i).mnd, golvenq(i).dag);
end

Nparen = numel([paren.k]);
z = (length([golvenq(1).tijd])-1)/2;
t_as = [golvenq(1).tijd];

figure
a = 1;
for j = 1:Nparen
%    if j == 13 | j == 25 | j == 37 | j == 49
    rest = mod(j-1,12);
    if rest == 0 & j > 1    %als rest=0 is j-1 = K*12, met K geheel
        figure
        a = 1;
    end
    subplot(3,4,a)
    a = a + 1;
    
    %plotten geldige waarden onafh var
    nr = find(kalle_sdtm == paren(j).sdtmk)
    jaarnr = golvenq(nr).jaa;
    maandnr = golvenq(nr).mnd;
    dagnr = golvenq(nr).dag;
    piekdatumnr = datenum(jaarnr, maandnr, dagnr);
    plot(t_as, [golvenq(nr).data])
    hold on
    grid on
    xlim([-z z])
    ymx = 2000;
    ylim([0 ymx])
    title(['piek: ',datestr(piekdatumnr)])
    
    %plotten afh var
    F = find(datumm == paren(j).sdtmk);
    v = [F-zc:F+zc];
    datam_plot = 0.9*ymx/(max(datam) - min(datam))*(datam(v) - min(datam));
    plot([-zc:zc], datam_plot,'r')
end
