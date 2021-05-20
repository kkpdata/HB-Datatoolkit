%Door: Chris Geerse
%Betreft analyse stormduur. Nog niet erg uitgewerkt.
%Run eerst hoofdprogramma Schiphol!!

figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)

%tbv indeling in klassen
stap = 2;
grenzen = [0:stap:30]';
grenzenrel = [0:0.2:4]';    %klassegroottes voor duur gedeeeld door gemiddelde duur

%Histogrammen maken voor aantal niveaus v
v= tvoor(:,1);
I = find(v==0.75);
duur75 = (tachter(I,2:size(tvoor,2)) - tvoor(I,2:size(tvoor,2)))'
his75 = histc(duur75,grenzen);
duurgem75 = mean(duur75);
his75rel = histc(duur75/duurgem75,grenzenrel);

v= tvoor(:,1);
I = find(v==0.80);
duur80 = (tachter(I,2:size(tvoor,2)) - tvoor(I,2:size(tvoor,2)))'
his80 = histc(duur80,grenzen);
duurgem80 = mean(duur80);
his80rel = histc(duur80/duurgem80,grenzenrel);

v= tvoor(:,1);
I = find(v==0.85);
duur85 = (tachter(I,2:size(tvoor,2)) - tvoor(I,2:size(tvoor,2)))'
his85 = histc(duur85,grenzen);
duurgem85 = mean(duur85);
duurgem85 = mean(duur85);
his85rel = histc(duur85/duurgem85,grenzenrel);

v= tvoor(:,1);
I = find(v==0.90);
duur90 = (tachter(I,2:size(tvoor,2)) - tvoor(I,2:size(tvoor,2)))'
his90 = histc(duur90,grenzen);
duurgem90 = mean(duur90);
v= tvoor(:,1);
duurgem90 = mean(duur90);
his90rel = histc(duur90/duurgem90,grenzenrel);

I = find(v==0.95);
duur95 = (tachter(I,2:size(tvoor,2)) - tvoor(I,2:size(tvoor,2)))'
his95 = histc(duur95,grenzen);
duurgem95 = mean(duur95);
duurgem95 = mean(duur95);
his95rel = histc(duur95/duurgem95,grenzenrel);

close all
%Plotjes
figure
plot(grenzen+0.5*stap,100*his75/Nstormen,'y');
hold on
plot(grenzen+0.5*stap,100*his80/Nstormen,'b');
plot(grenzen+0.5*stap,100*his85/Nstormen,'r');
plot(grenzen+0.5*stap,100*his90/Nstormen,'g');
plot(grenzen+0.5*stap,100*his95/Nstormen,'k');

grid on
ltxt  = [];
ttxt  = (['N=',num2str(Nstormen),', drempel=',num2str(drempel),' m/s, zpot=',num2str(zpot),' uur, zB=',num2str(zB)]);
xtxt  = 'winsnelheidsklassen, m/s';
ytxt  = 'percentage, [%]';
Xtick = grenzen;
Ytick = 0:5:50;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

figure
plot(grenzenrel,100*his75rel/Nstormen,'y');
hold on
grid on
plot(grenzenrel,100*his80rel/Nstormen,'b');
plot(grenzenrel,100*his85rel/Nstormen,'r');
plot(grenzenrel,100*his90rel/Nstormen,'g');
plot(grenzenrel,100*his95rel/Nstormen,'k');

figure
cdfplot(duur90/duurgem90)
title('CDF duur90/duurgem90');
figure
cdfplot(duur85/duurgem85)
title('CDF duur85/duurgem85');

%Voorlopige conclusies stormduren:
%1. Lagere niveaus v hebben iets minder
%lange staarten van de verdeling van de stormduur (tov gem.stormduur).
%Scheelt echter niet veel!
%2. Verschil tussen stormen uit NW-hoek (270 t/m 360)en die uit ZW-hoek (180 t/m 260)
%lijkt niet groot;
%de laatste stormen zijn (bij drempel 18 m/s) iets breder dan die uit
%NW-hoek.
%3. Verschil in staarten tov gem.stormduur tussen NW-hoek en ZW-hoek lijkt
%niet groot. (Dus extreem lange stormduren komen bij alle typen stormen
%voor, ook al lijkt in eerste instantie dat stormen uit NW-hoek langere
%staarten hebben.

%{
rommel
m=100;
y=rand(m,1);

edges = [0:.1:.5]';
n = histc(y,edges);

plot(edges,n)
bar(edges,n)
%bar([1:10:1000],y)

%}


