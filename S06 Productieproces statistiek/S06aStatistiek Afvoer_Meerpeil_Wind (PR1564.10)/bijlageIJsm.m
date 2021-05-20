%bijlageIJsm.m
%
%Door: Chris Geerse
%30 jan 2006
%
%
%Script om gevoeligheidsanalyses voor het IJsselmeer te doen.
%Runnen van hoofdprogramma is nodig om benodigde variabelen te
%maken; laat clear  aan begin hoofdprogramma dan weg.
%Let op dat alle parameters de juiste waarde hebben gekregen.
%

%==========================================================================
% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all

%{
%==========================================================================
%Gevoeligheid drempelwaarde
%==========================================================================

%Plotten gemiddelde vorm met midden vorm
v = standaardvorm.v;
vtot = [v; flipud(v)];

tn15= [standaardvormn15.tvoor; flipud([standaardvormn15.tachter])];
tn05 = [standaardvormn05.tvoor; flipud([standaardvormn05.tachter])];
tp05 = [standaardvormp05.tvoor; flipud([standaardvormp05.tachter])];
tp15 = [standaardvormp15.tvoor; flipud([standaardvormp15.tachter])];
tp24 = [standaardvormp24.tvoor; flipud([standaardvormp24.tachter])];

bpiek = 4;  %topduur (dagen) trapezium wordt hier tbv plaatje ingesteld.
x = [-B/2, -bpiek/2, bpiek/2, B/2]';
y = [0, 1, 1, 0]';

figure
plot(x,y,'r','Linewidth',3);
hold on
grid on
plot(tn15, vtot, 'g');
plot(tn05, vtot, 'c');
plot(tp05, vtot, 'b','Linewidth',3);
plot(tp15, vtot, 'k');
plot(tp24, vtot, 'y');
cltxt  = {'trapezium','gemiddelde, d=-0.15','gemiddelde, d=-0.05','gemiddelde, d= 0.05','gemiddelde, d= 0.15','gemiddelde, d= 0.24'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid drempelwaarde opschalingsmethode IJsselmeer']);
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
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
plot(x,y,'r','Linewidth',3);
hold on
grid on
plot(tzB15, vtot, 'b','Linewidth',3);
plot(tzB10, vtot, 'g');
plot(tzB5, vtot, 'k');
cltxt  = {'trapezium','zB = 15 dagen','zB = 10 dagen','zB = 5 dagen'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid verzamelduur zB opschalingsmethode IJsselmeer']);
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
%Gevoeligheid momentane kans voor topduur
%==========================================================================

close all

figure
plot(mom_obs.y,log(mom_obs.Gy),'g-','Linewidth',3)
hold on
grid on
plot(berek_traptop12.y,log(berek_traptop12.Gy_mom),'c-.')
plot(berek_traptop48.y,log(berek_traptop48.Gy_mom),'r-.')
plot(berek_traptop96.y,log(berek_traptop96.Gy_mom),'b-.','Linewidth',3)
plot(berek_traptop120.y,log(berek_traptop120.Gy_mom),'k-.')
cltxt  = {'observatie','(hoge) topduur = 12 uur','(hoge) topduur = 48 uur','(hoge) topduur = 96 uur','(hoge) topduur = 120 uur'};
ltxt  = char(cltxt);
ttxt  = (['Gevoeligheid momentane kans voor topduur vanaf 0.05 m+NAP IJsselmeer']);
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'ln momentane overschrijdingskans, [-]';
Xtick = -0.5:0.1:0.8;
Ytick = -10:1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%}

%==========================================================================
%Overschrijdingsduur per top
%==========================================================================

%close all
%gemiddelde topduur als quotiënt van B*P(M>m)/P(S>s).
figure
topduurgem_traptop96 = B*(berek_traptop96.Gy_mom)./berek_traptop96.Gy_piek;
topduurgem_traptop12 = B*(berek_traptop12.Gy_mom)./berek_traptop12.Gy_piek;
grid on
hold on
plot(berek_traptop96.y,topduurgem_traptop96,'b-.','Linewidth',3)
plot(berek_traptop12.y,topduurgem_traptop12,'g-.')
plot(m_HM, OD_HM./OF_HM,'k')
cltxt  = {'Hydra-VIJ','Hydra-VIJ met topduur hoge meerpeilen 12 uur','Hydra-M'};
ltxt  = char(cltxt);
ttxt  = 'Overschrijdingsduur per top Hydra-M en Hydra-VIJ IJsselmeer';
xtxt  = 'meerpeil, m+NAP';
ytxt  = 'topduur, dagen';
Xtick = -0.4:0.2:1.1;
Ytick = 0:3:30;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


