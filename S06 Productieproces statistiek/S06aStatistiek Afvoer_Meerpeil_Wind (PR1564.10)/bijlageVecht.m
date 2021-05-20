%bijlageVecht.m
%
%Door: Chris Geerse
%30 jan 2006
%
%
%Script om gevoeligheidsanalyses voor de Vecht te doen.
%Runnen van hoofdprogramma is nodig om benodigde variabelen te
%maken; laat clear all aan begin hoofdprogramma dan weg.
%Let op dat alle parameters de juiste waarde hebben gekregen.
%

%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all


%==========================================================================
%Gevoeligheid drempelwaarde
%==========================================================================

%Plotten gemiddelde vorm met midden vorm
v = standaardvorm.v;
vtot = [v; flipud(v)];

t150= [standaardvorm150.tvoor; flipud([standaardvorm150.tachter])];
t180 = [standaardvorm180.tvoor; flipud([standaardvorm180.tachter])];
t210 = [standaardvorm210.tvoor; flipud([standaardvorm210.tachter])];
t240 = [standaardvorm240.tvoor; flipud([standaardvorm240.tachter])];

figure
plot(Bbeta*beta_normgolfvorm(:,1)-Bbeta/2,beta_normgolfvorm(:,2),'r','Linewidth',3);
hold on
grid on
plot(t150, vtot, 'g');
plot(t180, vtot, 'b','Linewidth',3);
plot(t210, vtot, 'c');
plot(t240, vtot, 'k');
cltxt  = {'gefitte golfvorm','gemiddelde, d=150','gemiddelde, d=180','gemiddelde, d=210','gemiddelde, d=240'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid drempelwaarde opschalingsmethode Dalfsen']);
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
%Xtick = -8:2:8;
%Ytick = 0.7:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
%Gevoeligheid zB
%==========================================================================

%Plotten gemiddelde vorm met midden vorm
v = standaardvorm.v;
vtot = [v; flipud(v)];

tzB15 = [standaardvormzB15.tvoor; flipud([standaardvormzB15.tachter])];
tzB10 = [standaardvormzB10.tvoor; flipud([standaardvormzB10.tachter])];
tzB5 = [standaardvormzB5.tvoor; flipud([standaardvormzB5.tachter])];

figure
plot(Bbeta*beta_normgolfvorm(:,1)-Bbeta/2,beta_normgolfvorm(:,2),'r','Linewidth',3);
hold on
grid on
plot(tzB15, vtot, 'b','Linewidth',3);
plot(tzB10, vtot, 'g');
plot(tzB5, vtot, 'k');
cltxt  = {'gefitte golfvorm','zB = 15 dagen','zB = 10 dagen','zB = 5 dagen'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid verzamelduur zB opschalingsmethode Dalfsen']);
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
%Xtick = -8:2:8;
%Ytick = 0.7:0.05:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
%Gevoeligheid momentane kans voor topduur
%==========================================================================

close all
F = find(mombeta.y >= 180);

figure
plot(mom_obs.y,log(mom_obs.Gy),'g-')
hold on
grid on
plot(mombeta.y(F), log(mombeta.Gy(F)), 'r','Linewidth',3)
plot(berek_traptop48.y,log(berek_traptop48.Gy_mom),'b-.','Linewidth',3)
plot(berek_traptop24.y,log(berek_traptop24.Gy_mom),'c-.')
plot(berek_traptop72.y,log(berek_traptop72.Gy_mom),'k-.')
cltxt  = {'observatie','gefitte golf','(hoge) topduur = 48 uur','(hoge) topduur = 24 uur','(hoge) topduur = 72 uur'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid momentane kans voor topduur vanaf 180 m3/s Dalfsen']);
xtxt  = 'Vechtafvoer Dalfsen, m3/s';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = 0:50:500;
Ytick = -10:2:0;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)






