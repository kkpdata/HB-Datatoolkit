%==========================================================================
% Hoofdprogramma correlaties
% Door: Chris Geerse
%
%==========================================================================
clear
close all

%==========================================================================
%Diverse instelbare parameters
%==========================================================================

s = 1.2;    %keuze standaarddeviatie

%y-rooster tbv getransformeerde ruimte
ymn = -15;
yst = 0.1;
ymx = 25;
y = (ymn:yst:ymx)';

%parameters voor integratie over x tbv berekening FYs
xint_st = 0.01;    
xint_mx = 30;

%q-rooster tbv originele ruimte
qmn = 0;
qst = 5;
qmx = 900;
q = (qmn:qst:qmx)';

%m-rooster tbv originele  ruimte
mmn = -0.4;
mst = 0.01;
mmx = 1.8;
m = (mmn:mst:mmx)';



%==========================================================================
% Tbv goede plaatjes in Word.
%==========================================================================
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all

%==========================================================================
%Inlezen data en verdelingsfuncties Q en M
%==========================================================================
%[qV, qIJsm] = textread('paren_V_IJsm_drempel0_ex2000_incl550__n40.txt','%f %f','delimiter',' ','commentstyle','matlab');
[qV, qIJsm] = textread('paren_V_IJsm_drempel0_ex2000.txt','%f %f','delimiter',' ','commentstyle','matlab');
data =[qV, qIJsm];
[a, b] = textread('F_Vecht.txt','%f %f','delimiter',' ','commentstyle','matlab');
FQ = [a, b]; clear a b;
[a, b] = textread('F_IJsselmeer.txt','%f %f','delimiter',' ','commentstyle','matlab');
FM = [a, b]; clear a b;

figure
plot(FQ(:,1),FQ(:,2))
figure
plot(FM(:,1),FM(:,2))
figure
plot(qV, qIJsm, 'b.')
close all

%==========================================================================
%Berekenen van FYs(y), fomule 1 op p 10 van [Beijk en Geerse, 2004], versie
%normale verdeling, met meestal de keuze delta = -s^2/2.
%==========================================================================

delta = -s^2/2;
[FYs_y] = FYs(y, s, delta, xint_st, xint_mx);

figure
plot(y, FYs_y)

close all
%==========================================================================
%Transformatie data
%==========================================================================
FQdata = interp1q(FQ(:,1), FQ(:,2), data(:,1));
xdata = -log(1-FQdata);

%Vergelijking: FYs(ydata_j) = FM(mj), zie formule 1 op p 11 en formule 1 op p12
FMdata = interp1q(FM(:,1), FM(:,2), data(:,2)); %vector met de FM(mj)
ydata = interp1q(FYs_y, y, FMdata);             %vector met de ydata_j

%==========================================================================
%Percentielen in getransformeerde ruimte met plaatje
%==========================================================================
p1 = 0.1;
p2 = 0.5;
p3 = 0.9;
z1 = norminv(p1, 0, 1);
z2 = norminv(p2, 0, 1);
z3 = norminv(p3, 0, 1);

xmn = 0;
xst = 0.1;
xmx = 20;
x = (xmn:xst:xmx)';

figure
plot(xdata, ydata,'b.');
hold on
grid on
plot(x, x+delta+z1*s,'r');
plot(x, x+delta+z2*s,'r');
plot(x, x+delta+z3*s,'r');
cltxt  = {'data','percentiellijnen'};
ltxt  = char(cltxt);
ttxt  = 'GETRANSFORMEERDE RUIMTE';
xtxt  = 'x [-]';
ytxt  = 'y [-]';
Xtick = 0:1:10;
Ytick = -4:1:10;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%==========================================================================
%Originele ruimte
%==========================================================================

FQq = interp1q(FQ(:,1), FQ(:,2), q);
Jq = -log(1-FQq);

FMm = interp1q(FM(:,1), FM(:,2), m);

Ksm = interp1q(FYs_y, y, FMm);
Ksm(1) = -10;   %anders waarde NaN

m1 = interp1q(Ksm, m, s*z1+Jq+delta);
m2 = interp1q(Ksm, m, s*z2+Jq+delta);
m3 = interp1q(Ksm, m, s*z3+Jq+delta);


figure
plot(data(:,1), data(:,2), 'b.');
hold on
grid on
plot(q, m1,'r');
plot(q, m2,'r');
plot(q, m3,'r');
cltxt  = {'data','percentiellijnen'};
ltxt  = char(cltxt);
ttxt  = 'ORIGINELE RUIMTE';
xtxt  = 'afvoer Vecht, m3/s';
ytxt  = 'meerpeil, m+NAP';
Xtick = 0:50:550;
Ytick = -0.4:.2:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
%Subplotjes Originele en getransformeerde ruimte
%==========================================================================

close all

figure
subplot(1,2,1)
plot(data(:,1), data(:,2), 'b.');
hold on
grid on
plot(q, m1,'r');
plot(q, m2,'r');
plot(q, m3,'r');
ltxt  = [];
%ttxt  = 'Originele en getransformeerde ruimte';
ttxt  = (['Originele ruimte', ', s = ',num2str(s)]);
%xtxt  = 'afvoer Vecht, m3/s';
%ytxt  = 'meerpeil, m+NAP';
xtxt = [];
ytxt = [];
Xtick = 0:100:600;
Ytick = -0.4:.2:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

subplot(1,2,2)
plot(xdata, ydata,'b.');
hold on
grid on
plot(x, x+delta+z1*s,'r');
plot(x, x+delta+z2*s,'r');
plot(x, x+delta+z3*s,'r');
ltxt  = [];
ttxt  = (['Getransformeerde ruimte', ', s = ',num2str(s)]);
%xtxt  = 'x [-]';
%ytxt  = 'y [-]';
xtxt = [];
ytxt = [];
Xtick = 0:1:7;
Ytick = -1:1:8;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)



