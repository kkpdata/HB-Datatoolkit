%bepalen whjaar; noem bijvoorbeeld 1-10-2004 t/m 31-3-2005 whjaar = 2005
whjaar = jaar;  %init
F1 = find( maand == 10 | maand == 11 | maand == 12);
F2 = find( maand == 1 | maand == 2 | maand == 3);
whjaar(F1) = jaar(F1)+1;
whjaar(F2) = jaar(F2);

nrwhjaar = (min(whjaar):max(whjaar))';
whjaarmax = nrwhjaar;   %init
whjaargem = nrwhjaar;   %init
whjaarmin = nrwhjaar;   %init
for j = 1:numel(nrwhjaar)
    whjaarmax(j) = max(data(whjaar==nrwhjaar(j)));
    whjaargem(j) = mean(data(whjaar==nrwhjaar(j)));
    whjaarmin(j) = min(data(whjaar==nrwhjaar(j)));
end

%==========================================================================
%Diverse regressies (voor gem, max en min per whjaar)
%onafh = nummer van whjaar, afh = gemiddelde binnen whjaar
X=[ones(length(nrwhjaar),1), nrwhjaar];
Y= whjaargem;
[bgem,bintgem,rgem,rintgem,statsgem] = regress(Y,X);
stringgem = (['regressielijn gemiddelde: m = ',num2str(bgem(1)), ' + ',num2str(bgem(2)),' * m',]);
display(stringgem);
%{
Uitvoer: y = -2.401+ 0.001078x
b =
 -2.4007e+000
  1.0771e-003
stats =
  2.2623e-002  6.2497e-001  4.3609e-001  3.7682e-003    %0.436 is denk ik p-waarde voor coëfficient van x
%}
%regressie voor max
X=[ones(length(nrwhjaar),1), nrwhjaar];
Ymax= whjaarmax;
[bmax,bintmax,rmax,rintmax,statsmax] = regress(Ymax,X);
stringmax = (['regressielijn maxima: m = ',num2str(bmax(1)), ' + ',num2str(bmax(2)),' * m',]);
display(stringmax);

%regressie voor min
X=[ones(length(nrwhjaar),1), nrwhjaar];
Ymin= whjaarmin;
[bmin,bintmin,rmin,rintmin,statsmin] = regress(Ymin,X);
stringmin = (['regressielijn minima: m = ',num2str(bmin(1)), ' + ',num2str(bmin(2)),' * m',]);
display(stringmin);

%plotten van tijdsverlopen (inclusief regressielijnen) voor max, gem en min
figure
%tijdsverlopen
plot(nrwhjaar, whjaarmax,'r', nrwhjaar, whjaargem,'b',nrwhjaar, whjaarmin,'g')
hold on
grid on
%regressielijnen:
plot(nrwhjaar, bmax(1)+bmax(2)*nrwhjaar,'r-.')  
plot(nrwhjaar, bgem(1)+bgem(2)*nrwhjaar,'b-.')
plot(nrwhjaar, bmin(1)+bmin(2)*nrwhjaar,'g-.')
cltxt  = {'maxima','gemiddelde','minima'};
ltxt  = char(cltxt);
ttxt  = 'Trends IJsselmeer: regressielijnen';
xtxt  = 'whjaren';
ytxt  = 'meerpeil, m+NAP';
Xtick = 1975:5:2005;
Ytick = -0.6:0.2:0.6;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%--------------------------------------------------------------------------
%Bepalen lopende gemiddeldes voor gemiddelde binnen whjaar
%orde van lopend gemiddelde is 5
b = (1/5)*ones(1,5);
y5gem = filter(b,1,whjaargem);
nrwhjaar_deel5 = nrwhjaar(5:length(nrwhjaar));
y5gem_deel = y5gem(5:length(nrwhjaar));

%Bepalen lopende gemiddeldes voor maxima binnen whjaar
b = (1/5)*ones(1,5);
y5max = filter(b,1,whjaarmax);
nrwhjaar_deel5 = nrwhjaar(5:length(nrwhjaar));
y5max_deel = y5max(5:length(nrwhjaar));

%Bepalen lopende gemiddeldes voor minima binnen whjaar
b = (1/5)*ones(1,5);
y5min = filter(b,1,whjaarmin);
nrwhjaar_deel5 = nrwhjaar(5:length(nrwhjaar));
y5min_deel = y5min(5:length(nrwhjaar));

figure
plot(nrwhjaar, whjaarmax,'r')
hold on
grid on
plot(nrwhjaar, whjaargem,'b')
plot(nrwhjaar, whjaarmin,'g')
plot(nrwhjaar_deel5, y5max_deel,'r-.')
plot(nrwhjaar_deel5, y5gem_deel,'b-.')
plot(nrwhjaar_deel5, y5min_deel,'g-.')
%cltxt  = {'gemiddelde','5-jaarlijks lopend middelen'};
cltxt  = {'maxima','gemiddelde','minima'};
ltxt  = char(cltxt);
ttxt  = 'Trends IJsselmeer: lopende gemiddeldes (5-jaarlijks)';
xtxt  = 'whjaren';
ytxt  = 'meerpeil, m+NAP';
Xtick = 1975:5:2005;
Ytick = -0.6:0.2:.6;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


