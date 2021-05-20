function [] = plot_verloopID(golvenI, paren, zD, datumD, dataD,...
    Npx, Npy, SImn, SIst, SImx, SDmn, SDst, SDmx);
%
% Door Chris Geerse
%
%
%==========================================================================
%
%Plaatjes worden gemaakt van de geselecteerde golven (onafh variabele I)
%met bijbehorende verlopen van afh variabele D. Bijvoorbeeld onafh is
%IJssel en afh is IJsselmeer.
%
%Input:
%golvenI: structure met gegevens geselecteerde onafh variabele
%paren: structure met gegevens geldige puntenparen (I,Dx) en (I,Dr)
%zD: halve breedte weergavevenster afh variabele
%datumD: seriële datums van meetreeks afh variabele
%dataD: waarden in de meetreeks van de afh variabele
%
%Er zijn Npx*Npy plaatjes in één figuur:
%Npx: aantal plaatjes in x-richting
%Npy: aantal plaatjes in y-richting
%SImn: min van schaal onafh var
%SIst: stap in schaal onafh var
%SImx: max van schaal onafh var
%SDmn: min van schaal afh var
%SDst: stap in schaal afh var
%SDmx: max van schaal afh var
%
%Output:
%plaatjes
%
%==========================================================================
%Begin functie
%==========================================================================
NallegolvenI = max([golvenI.rang]);
Ialle_dtm = zeros(NallegolvenI,1);     %init seriële datums alle golven
for i = 1:NallegolvenI
    Ialle_dtm(i) = datenum(golvenI(i).jaa, golvenI(i).mnd, golvenI(i).dag);
end

Nparen = numel([paren.I]);
z = (length([golvenI(1).tijd])-1)/2;
t_as = [golvenI(1).tijd];

figure
a = 1;
for j = 1:Nparen
    %    if j == 13 | j == 25 | j == 37 | j == 49
    rest = mod(j-1,Npx*Npy);
    if rest == 0 & j > 1    %als rest=0 is j-1 = K*Npx*Npy, met K geheel
        figure
        a = 1;
    end
    subplot(Npy,Npx,a)
    a = a + 1;

    %plotten geldige waarden onafh var
    k = find(Ialle_dtm == paren(j).dtmI);
    jaark = golvenI(k).jaa;
    maandk = golvenI(k).mnd;
    dagk = golvenI(k).dag;
    piekdatumk = datenum(jaark, maandk, dagk);

    %plotten geldige waarden afh var
    F = find(datumD == paren(j).dtmI);
    v = [F-zD:F+zD];
    zmx = max(z,zD);
    [AX,H1,H2] = plotyy(t_as, [golvenI(k).data],[-zD:zD]', dataD(v),'plot');
    set(AX(1),'Xlim',[-zmx zmx],'Xtick',[-zmx:zmx:zmx],'Ylim',[SImn SImx],'Ytick',[SImn:SIst:SImx]);
    set(AX(2),'YColor','r','Xlim',[-zmx zmx],'Xtick',[-zmx:zmx:zmx],'Ylim',[SDmn SDmx],'Ytick',[SDmn:SDst:SDmx]);
    set(H2,'LineStyle','--','Color','r');
    grid on
    title(['piek: ',datestr(piekdatumk)])

    
    %tbv checken of I en D goed in het
    %plaatje staan (werkt alleen voor zD = 15); NB zoek wel juiste k op behorend bij beschouwde j.
%    if k == 6
%    display('t_as, [golvenI(nr).data], [-zD:zD]'', dataD(v)')
%    [t_as, [golvenI(k).data, [-zD:zD]', dataD(v)]]
    end
    
end
