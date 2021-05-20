%==========================================================================
% Hoofdprogramma correlaties
% Door: Chris Geerse
%
% Dit programma laat toe dat standaarddeviatie in getransformeerde ruimte
% een functie is van x.
%==========================================================================
clear
close all

%==========================================================================
%Diverse instelbare parameters
%==========================================================================

%Keuzemogelijkheden:
%Onafh I    Afh D       geval
%IJ         IJsm        1

geval = 1;  %GEEF HIER DE GEWENSTE KEUZE OP, hier altijd 1!
%--------------------------------------------------------------------------

%x-rooster en y-rooster tbv getransformeerde ruimte
xmn = 0; xst = 0.01; xmx = 25;
x = (xmn:xst:xmx)';

ymn = -15; yst = 0.1; ymx = 30;
y = (ymn:yst:ymx)';

%parameters voor integratie over x tbv berekening FYs(y). NB laagste x
%altijd 0
xint_st = 0.01;
xint_mx = 30;

% %invoeren verloop van s in getransformeerde ruimte, (x, s(x)).
sinv = [0, 1.2    %linksboven moet beginnen met x = 0; altijd minimaal 1 rij opgeven.
    30, 1.2]          %getal rechtsonder wordt ook voor hogere x aangenomen als constante

% %invoeren verloop van s in getransformeerde ruimte, (x, s(x)).
% sinv = [0, 0.2    %linksboven moet beginnen met x = 0; altijd minimaal 1 rij opgeven.
% 30, 9.8]          %getal rechtsonder wordt ook voor hogere x aangenomen als constante

%Gewenste percentages tbv percentielen in plaatjes
p1 = 0.1;
p2 = 0.5;
p3 = 0.9;

%==========================================================================
% Tbv goede plaatjes in Word.
%==========================================================================
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all

%==========================================================================
%Inlezen data en verdelingsfuncties onafhankelijke I en afhankelijke D (voorheen Q en M)
%==========================================================================

if geval == 1 %I = IJssel, D = IJsm
    [parenI, parenD] = textread('paren_IJ_IJsm_d0_definitief.txt','%f %f','delimiter',' ','commentstyle','matlab');
    [I1, FI2] = textread('F_IJssel.txt','%f %f','delimiter',' ','commentstyle','matlab');
    [D1, FD2] = textread('F_IJsselmeer.txt','%f %f','delimiter',' ','commentstyle','matlab');
    naamI = 'IJssel';
    naamD = 'IJsselmeer';
    %I-rooster en D-rooster tbv originele ruimte
    imn = min(I1); ist = 25; imx = 3000;
    dmn = min(D1); dst = 0.01; dmx = 1.8;
    %assen originele ruimte
    XtickI = 0:500:3000;
    YtickD = -0.4:.2:1;
end

FI = [I1, FI2]; clear I1 FI2;   %kolom 1:waarden; kolom 2 cumulatieve kansen
FD = [D1, FD2]; clear D1 FD2;   %kolom 1:waarden; kolom 2 cumulatieve kansen
data =[parenI, parenD];

%Plaatjes verdelingsfuncties I en D en van de puntenparen
figure
plot(FI(:,1),FI(:,2)); xlabel(naamI); ylabel('onderschr.kans')
figure
plot(FD(:,1),FD(:,2)); xlabel(naamD); ylabel('onderschr.kans')
figure
plot(data(:,1), data(:,2), 'b.'); xlabel(naamI); ylabel(naamD)
close all

%roosters voor I en D in originele ruimte
i = (imn:ist:imx)';
d = (dmn:dst:dmx)';



%==========================================================================
%Berekenen van FYs(y), met s = s(x).
%Betreft uitbreiding van fomule 1 op p 10 van [Beijk en Geerse, 2004], versie
%normale verdeling.
%==========================================================================

delta = -sinv(1,2)^2/2; %Kies delta gelijk aan s(x=0)
[FYs_y] = FYs_svar(y, sinv, delta, xint_st, xint_mx);

figure
plot(y, FYs_y); 
xlabel('y'); ylabel('FY_s(y)');
grid on
xlim([-2, 10])

figure
semilogy(y, 1-FYs_y, 'b', 'linewidth', 2); 
hold on
grid on
semilogy(y, exp(-y), 'r--', 'linewidth', 2); 
legend('1 - FY_s(y)','exp(-y)');
xlabel('Waarde y [-]')
ylabel('Overschrijdingskans [-]')
xlim([-10, 10])





%close all
%==========================================================================
%Transformatie data, en bepalen  Ji en Ksd, resp op i-rooster en d-rooster
%==========================================================================
FIdata = interp1q(FI(:,1), FI(:,2), data(:,1));
xdata = -log(1-FIdata);

%Vergelijking: FYs(ydata_j) = FD(mj), zie formule 1 op p 11 en formule 1 op p12
FDdata = interp1q(FD(:,1), FD(:,2), data(:,2)); %vector met de FD(mj)
ydata = interp1q(FYs_y, y, FDdata);             %vector met de ydata_j

FIi = interp1q(FI(:,1), FI(:,2), i);
Ji = -log(1-FIi);

FDd = interp1q(FD(:,1), FD(:,2), d);
Ksd = interp1q(FYs_y, y, FDd);
Ksd(1) = -10;   %anders waarde NaN

%==========================================================================
%Bepalen percentielen d1, d2, d3 in originele ruimte
%==========================================================================

%Bepalen s = s(x) op x-rooster
Nx = length(x);
sinv_xmx = max(sinv(:,1));

if size(sinv,1) == 1    %slechts één rij, zodat s(x) = constant moet worden
    s = sinv(1,2)*ones(Nx,1);
elseif sinv_xmx < max(x)    %nu moet sinv eerst aangevuld worden tbv interpolaties
    L = size(sinv,1);
    sinv(L+1, 1) = max(x);
    sinv(L+1, 2) = sinv(L, 2);
    s = interp1(sinv(:,1), sinv(:,2), x);
else
    s = interp1(sinv(:,1), sinv(:,2), x);
end

%z-waarden voor gekozen percentages
z1 = norminv(p1, 0, 1);
z2 = norminv(p2, 0, 1);
z3 = norminv(p3, 0, 1);

%Bij gegeven Ji steeds de drie percentielen d1, d2, d3 in originele ruimte bepalen
%Bepaal eerst sJi = s(Ji) = vector met format van vector i
sJi = interp1(x, s, Ji);
d1 = interp1q(Ksd, d, sJi*z1+Ji+delta);
d2 = interp1q(Ksd, d, sJi*z2+Ji+delta);
d3 = interp1q(Ksd, d, sJi*z3+Ji+delta);


close all

%==========================================================================
%Subplotjes originele en getransformeerde ruimte
%==========================================================================

figure
subplot(1,2,1)
plot(data(:,1), data(:,2), 'b.');
hold on
grid on
plot(i, d1,'r');
plot(i, d2,'r');
plot(i, d3,'r');
ltxt  = [];
ttxt  = ([naamD,' tegen ',naamI]);
xtxt = [];
ytxt = [];
Xtick = XtickI;
Ytick = YtickD;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

subplot(1,2,2)
plot(xdata, ydata,'b.');
hold on
grid on
plot(x, x+delta+z1*s,'r');
plot(x, x+delta+z2*s,'r');
plot(x, x+delta+z3*s,'r');
ltxt  = [];
if max(sinv(:,2)) == min(sinv(:,2))
    ttxt  = (['y tegen x', ', \sigma = ',num2str(sinv(1,2))]);  %indien vaste sigma
else
    ttxt  = (['y tegen x', ', \sigma_0=',num2str(sinv(1,2)),', \sigma_5=',num2str(interp1(x,s,5))]); %indien variabele sigma
end
xtxt = [];
ytxt = [];
%Xtick = [];
%Ytick = [];
Xtick = 0:1:9;
Ytick = -1:1:8;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%==========================================================================
%Figuur originele en fysische ruimte tbv Overzichtsdoc HV en HB
%==========================================================================

%close all

%Fysische ruimte
figure
plot(data(:,1), data(:,2), 'b.');
hold on
grid on
plot(i, d1,'r');
plot(i, d2,'r');
plot(i, d3,'r');
if geval==1
    xlim([0 3000])
    ylim([-0.4 1])
    title(['Puntenparen IJssel en IJsselmeer'])
    xlabel('afvoer IJssel, m3/s')
    ylabel('meerpeil, m+NAP')
elseif geval==2
    xlim([0 600])
    ylim([-0.4 1])
    title(['Puntenparen Vecht en IJsselmeer'])
    xlabel('afvoer Vecht, m3/s')
    ylabel('meerpeil, m+NAP')
end
%legend('metingen','volgens formule');

figure
plot(xdata, ydata,'b.');
hold on
grid on
plot(x, x+delta+z1*s,'r');
plot(x, x+delta+z2*s,'r');
plot(x, x+delta+z3*s,'r');
if geval==1
    xlim([0 7])
    ylim([-2 7])
    title(['Puntenparen IJssel en IJsselmeer in getransformeerde ruimte'])
    xlabel('x: getransformeerde afvoer IJssel [-]')
    ylabel('y: getransformeerde meerpeil [-]')
elseif geval==2
    xlim([0 7])
    ylim([-2 7])
    title(['Puntenparen Vecht en IJsselmeer in getransformeerde ruimte'])
    xlabel('x: getransformeerde afvoer Vecht [-]')
    ylabel('y: getransformeerde meerpeil [-]')
end