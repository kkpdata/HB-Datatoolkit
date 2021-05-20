function [] = plot_golven(golven, ref_niv, B, topduur_inv, ah, av, max_trapeziumplotjes);
%
% Door Chris Geerse (aanpassing module van Beijk)
% Versie met golven opgeslagen in structure
%
%==========================================================================
%
% Plaatjes worden gemaakt van de geselecteerde golven met het gekozen trapezium.
%
%Input:
%
%golven (betreft geselecteerde golven, opgeslagen in structure)
%ref_niv is basisniveau trapezium
%B is basisduur trapezium
%topduur_inv geeft invoergegevens topduur (n*2, k1 = mpniveaus, k2 = bijbehorende topduren
%
%Output:
%plaatjes
%==========================================================================
Ntraject = numel(topduur_inv(:,1));
aantal_golven = max([golven.nr]);
z = (length([golven(1).tijd])-1)/2;
t_as = [golven(1).tijd];

figure
a = 1;
for n = 1:aantal_golven
    %    if n == 13 | n == 25 | n == 37 | n == 49 | n == 61 | n == 73
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
    ylim([ref_niv, max_trapeziumplotjes ])
    jaarn = golven(n).jaa;
    maandn = golven(n).mnd;
    dagn = golven(n).dag;
    piekdatumn = datenum(jaarn, maandn, dagn);
    title(['piek: ',datestr(piekdatumn)])

    %toevoegen trapezium Zeeuwse wateren
    
    %Bepaal topduur b
    piek = golven(n).piek;
    if piek <= topduur_inv(1,1)
        b = topduur_inv(1,2);
    elseif piek <= topduur_inv(Ntraject,1)
        b = interp1(topduur_inv(:,1),topduur_inv(:,2),piek);
    else b = topduur_inv(Ntraject,2);
    end
    b = b/24;   %van uren naar dagen
    
    t1 = b/2 + ah*(1-av)*(B-b)/2;
    m1 = ref_niv + av*(piek - ref_niv);
    x = [-B/2, -t1, -b/2, b/2, t1, B/2]';
    y = [ref_niv, m1, piek, piek, m1, ref_niv]';
    plot(x,y,'r')
end

end
