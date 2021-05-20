%bijlagestormen.m
%
%Door: Chris Geerse
%25 jan 2006
%
%
%Script om gevoeligheidsanalyses voor stormen te doen.
%Runnen van hoofdprogramma Schiphol is nodig om benodigde variabelen te
%maken; laat clear all aan begin hoofdprogramma dan weg.
%Let op dat alle parameters de juiste waarde hebben gekregen.
%

%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all

B = 48;
b = 1;
traptijd =[-B/2 -b/2 b/2 B/2]; %parameters trapezium tbv plotten
trapu_norm =[0 1 1 0];


%==========================================================================
%Gevoeligheid drempelwaarde
%==========================================================================

%Plotten gemiddelde vorm met midden vorm
v = standaardvorm.v;
vtot = [v; flipud(v)];

t16 = [standaardvorm16.tvoor; flipud([standaardvorm16.tachter])];
t18 = [standaardvorm18.tvoor; flipud([standaardvorm18.tachter])];
t20 = [standaardvorm20.tvoor; flipud([standaardvorm20.tachter])];
t22 = [standaardvorm22.tvoor; flipud([standaardvorm22.tachter])];
t23_5 = [standaardvorm23_5.tvoor; flipud([standaardvorm23_5.tachter])];

figure
plot(traptijd, trapu_norm,'g','Linewidth',3);  % trapezium
hold on
grid on
plot(t16, vtot, 'r');
plot(t18, vtot, 'y');
plot(t20, vtot, 'c');
plot(t22, vtot, 'b','Linewidth',3);
plot(t23_5, vtot, 'k');
cltxt  = {'trap top 1 uur','16 m/s','18 m/s','20 m/s','22 m/s','23.5 m/s'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid drempelwaarde opschalingsmethode Schiphol']);
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
%Xtick = -8:2:8;
%Ytick = 0.7:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%==========================================================================
%Gevoeligheid zichtduur
%==========================================================================

%Plotten gemiddelde vorm met midden vorm
v = standaardvorm.v;
vtot = [v; flipud(v)];

tz20 = [standaardvormz20.tvoor; flipud([standaardvormz20.tachter])];
tz48 = [standaardvormz20.tvoor; flipud([standaardvormz48.tachter])];
tz76 = [standaardvormz20.tvoor; flipud([standaardvormz76.tachter])];

figure
plot(traptijd, trapu_norm,'g','Linewidth',3);  % trapezium
hold on
grid on
plot(tz20, vtot, 'b','Linewidth',3);
plot(tz48, vtot, 'r');
plot(tz76, vtot, 'k');

cltxt  = {'trap top 1 uur','20 uur','48 uur','76 uur'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid zichtduur opschalingsmethode Schiphol']);
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
Xtick = -8:2:8;
Ytick = 0.7:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%{
%==========================================================================
%Gevoeligheid zB
%==========================================================================

%Plotten gemiddelde vorm met midden vorm
v = standaardvorm.v;
vtot = [v; flipud(v)];

tzB10 = [standaardvormzB10.tvoor; flipud([standaardvormzB10.tachter])];
tzB15 = [standaardvormzB15.tvoor; flipud([standaardvormzB15.tachter])];
tzB20 = [standaardvormzB20.tvoor; flipud([standaardvormzB20.tachter])];

figure
plot(traptijd, trapu_norm,'g','Linewidth',3);  % trapezium
hold on
grid on
plot(tzB10, vtot, 'r');
plot(tzB15, vtot, 'y');
plot(tzB20, vtot, 'b','Linewidth',3);
cltxt  = {'trap top 1 uur','zB = 10 uur','zB = 15 uur','zB = 20 uur'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid verzamelduur zB opschalingsmethode Schiphol']);
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
%Xtick = -8:2:8;
%Ytick = 0.7:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
%Gevoeligheid stormbreedte van piekrichting
%==========================================================================

%Plotten gemiddelde vorm met midden vorm
v = standaardvorm.v;
vtot = [v; flipud(v)];

talle = [standaardvormalle.tvoor; flipud([standaardvormalle.tachter])];
tNW = [standaardvormNW.tvoor; flipud([standaardvormNW.tachter])];
tZW= [standaardvormZW.tvoor; flipud([standaardvormZW.tachter])];
tOost= [standaardvormOost.tvoor; flipud([standaardvormOost.tachter])];

figure
plot(traptijd, trapu_norm,'g','Linewidth',3);  % trapezium
hold on
grid on
plot(talle, vtot, 'b','Linewidth',3);
plot(tNW, vtot, 'r');
plot(tZW, vtot, 'y');
plot(tOost, vtot, 'k');
cltxt  = {'trap top 1 uur','alle','280 t/m 360','210 t/m 270','10 t/m 200'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid piekrichting opschalingsmethode Schiphol']);
xtxt  = 'tijd, uur';
ytxt  = 'relatieve windsnelheid, [-]';
Xtick = -20:10:20;
Ytick = 0:0.1:1;
Xtick = -8:2:8;
Ytick = 0.7:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%}