clc
clear
close all

%% Invoer

sNaam = 'Deelen';

switch sNaam
    case 'Schiphol'
        
        Wbl        = load('Invoer\Windsnelheid_Schiphol_2017_12r_Wbl.txt');
        Pr         = load('Invoer\Richtingskansen_Schiphol_2017.txt');
        transTab   = xlsread('Invoer\Table_12r_naar_16r.xls');
        kansData   = xlsread('Invoer\Schiphol_16r_Deltares.xls');
        kansData   = kansData(2:end,:);
        cut        = xlsread('Invoer\data_cut.xls','Schiphol');

    case 'Deelen'

        Wbl        = load('Invoer\Windsnelheid_Deelen_2017_12r_Wbl.txt');
        Pr         = load('Invoer\Richtingskansen_Deelen_2017.txt');
        transTab   = xlsread('Invoer\Table_12r_naar_16r.xls');
        kansData   = xlsread('Invoer\Deelen_16r_Deltares.xls');
        kansData   = kansData(2:end,:);
        cut        = xlsread('Invoer\data_cut.xls','Deelen');
        
end

richting12 = 30:30:360;
richting16 = 22.5:22.5:360;
rVolker    = 225:22.5:360;

ind_r      = [2:16,1]; %order Deltares

% Grid voor windsnelheid
u          = 0:0.05:42;
% Grid voor Volker
uGrid      = 0:42;
% Grid voor wegschrijven
uDeltares  = [0,2:0.5:42];

%% Lees Weibull 12 r, jaar

for r = 1:length(richting12)

    sigWbl(r) = Wbl(r,5);
    alfWbl(r) = Wbl(r,4);
    omeWbl(r) = Wbl(r,2);
    lamWbl(r) = Wbl(r,3);

    uPov_12r_jaar(:,r) = bepaalCondWbl(u,sigWbl(r),alfWbl(r),omeWbl(r),lamWbl(r));

end

drempel_12r = [omeWbl(end),omeWbl];
drempel_16r = interp1(0:30:360,drempel_12r,22.5:22.5:360);

%% Transform 12 richtingen -> 16 richtingen

transTab = transTab(2:end,2:end);

for r = 1:length(richting16)

    transTab_BIG       = repmat(transTab(r,:),length(u),1);
    uPov_16r_jaar(:,r) = sum(transTab_BIG.*uPov_12r_jaar,2);
    uPov_16r_12u(:,r)  = uPov_16r_jaar(:,r)/(360*Pr(r,2));

end

%% Final

for r = 1:length(richting16)

    clear uPov1 uPov2 uPov3

    u1 = u(u<=cut(r,3));
    u2 = u(u>cut(r,4));
    u3 = u(u>cut(r,3) & u<=cut(r,4));

    uPov3Begin   = exp(interp1(kansData(:,1),log(kansData(:,1+ind_r(r))),u1(end)));
    uPov3End     = exp(interp1(u,log(uPov_16r_12u(:,r)),u2(1)));

    uPov1        = exp(interp1(kansData(:,1),log(kansData(:,1+ind_r(r))),u1)); %data (Deltares)
    uPov2        = exp(interp1(u,log(uPov_16r_12u(:,r)),u2)); %hoge windsnelheden (HKV)
    uPov3        = exp(interp1([u1(end),u2(1)],log([uPov3Begin,uPov3End]),u3)); %overgang

    uPovFin(:,r) = [uPov1,uPov3,uPov2]';

end

%% Gemiddelde 

%Gemiddelde volgens Geerse voor Schiphol!!!
Geerse_2002 = [6.1986,7.0452,7.275,6.2943,5.5297,5.7859,6.3549,6.876,8.2513,9.3199,9.609,9.4543,8.9212,8.1711,7.0978,5.887];

% HKV
for r = 1:length(richting16)

    NI      = 0;
    delta_u = 0.05;
    uMean   = 0:delta_u:42;

    for i = 1:length(uMean)

        prob1 = exp(interp1(u,log(uPovFin(:,r)),uMean(i),'linear','extrap'));
        prob2 = exp(interp1(u,log(uPovFin(:,r)),uMean(i)+delta_u,'linear','extrap'));
        NI    = NI+uMean(i)*(prob1-prob2);

    end

    mean_UHKV(r) = NI;

end

% Deltares
for r = 1:length(richting16)

    NI      = 0;
    delta_u = 0.05;
    uMean   = 0:delta_u:42;

    for i = 1:length(uMean)

        prob1 = exp(interp1(kansData(:,1),log(kansData(:,1+ind_r(r))),uMean(i),'linear','extrap'));
        prob2 = exp(interp1(kansData(:,1),log(kansData(:,1+ind_r(r))),uMean(i)+delta_u,'linear','extrap'));
        NI    = NI+uMean(i)*(prob1-prob2);

    end

    mean_UDelta(r) = NI;

end


figure
plot([0,richting16],[mean_UDelta(end),mean_UDelta],'r-o','LineWidth',1.5);
hold on
plot([0,richting16],[mean_UHKV(end),mean_UHKV],'k--o','LineWidth',1.5);
if strcmp(sNaam,'Schiphol')==1
    plot([0,richting16],[Geerse_2002(end),Geerse_2002],'g-o','LineWidth',1.5);
end
grid on
xlabel('Windrichting [graad]');
ylabel('Gemiddelde windsnelheid [12-uursperiod]');
legend('Volgens WTI2017 - Deltares','Keuze','location','NorthWest');
if strcmp(sNaam,'Schiphol')==1
    legend('Volgens WTI2017 - Deltares','Keuze','Volgens (Geerse, 2002)','location','NorthWest');
end
set(gca,'XTick',0:22.5:360);
xlim([0,360]);
title(['Gemiddelde windsnelheid station ',sNaam]);
print(gcf,'-dpng',['Figuren\mean_',sNaam,'.png']);

%% Vergelijking met windsnelheid Deltares

for r = 1:length(richting16)

    figure
    semilogy(u,uPov_16r_12u(:,r),'b','LineWidth',1.5);
    hold on
    semilogy(kansData(:,1),kansData(:,1+ind_r(r)),'r','LineWidth',1.5);
    semilogy(u,uPovFin(:,r),'k--','LineWidth',1.5);
    semilogy([drempel_16r(r),drempel_16r(r)],[10^(-6),1],'k','LineWidth',1.5);
    grid on
    ylim([1e-6 1]);
    xlabel('Windsnelheid [m/s]');
    ylabel('Overschrijdingskans [1/12 uur]');
    title([sNaam,': conditionele overschrijdingskans windsnelheid, r = ',num2str(richting16(r))]);
    legend('Weging met frequenties','Volgens WTI2017 - Deltares','Keuze');
    print(gcf,'-dpng',['Figuren\',sNaam,'_Pov_',num2str(richting16(r)),'_verg.png']);

    figure
    semilogx(1./(uPov_16r_12u(:,r)*360*Pr(r,2)),u,'b','LineWidth',1.5);
    hold on
    semilogx(1./(kansData(:,1+ind_r(r))*360*Pr(r,2)),kansData(:,1),'r','LineWidth',1.5);
    semilogx(1./(uPovFin(:,r)*360*Pr(r,2)),u,'k--','LineWidth',1.5);
    grid on
    xlim([0 1e6]);
    xlabel('Terugkeertijd [jaar]');
    ylabel('Windsnelheid [m/s]');
    title([sNaam,': overschrijdingskans windsnelheid, r = ',num2str(richting16(r))]);
    legend('Weging met frequenties','Volgens WTI2017 - Deltares','Keuze','location','NorthWest');
    print(gcf,'-dpng',['Figuren\',sNaam,'_T_',num2str(richting16(r)),'_verg.png']);


end

%% Volkerfactor voor Schiphol

if strcmp(sNaam,'Schiphol')

    for r = 1:length(richting16)

        uPovFin_12(:,r) = exp(interp1(u,log(uPovFin(:,r)),uGrid));

        if ismember(richting16(r),rVolker)==1

            % Uit Main_verwerken_Volkerfactor.m
            % Bepaal de windsnelheid met T = 1 jaar
            uTkt(r) = interp1(log(uPovFin_12(:,r)),uGrid,log(1/(360*Pr(r,2))));

            % Rond overgangswindsnelheid af naar boven!
            uOvergang(r) = ceil(uTkt(r));

            % Bepaal aangepaste kansen (zie [Geerse et al, 2002] par 8.1).
            Factoren                            = ones(numel(uGrid), 1);
            Factoren(uGrid == uOvergang(r) - 1) = 0.9;
            Factoren(uGrid == uOvergang(r)    ) = 0.8;
            Factoren(uGrid == uOvergang(r) + 1) = 0.7;
            Factoren(uGrid == uOvergang(r) + 2) = 0.6;
            Factoren(uGrid >  uOvergang(r) + 2) = 0.5;

            % Nieuwe ovkansen inclusief Volkerfactor
            uPovVolk(:,r) = uPovFin_12(:,r).*Factoren;

        else

            uPovVolk(:,r) = uPovFin_12(:,r);

        end

    end

end

%% Opslaan data + present

for r = 1:length(richting16)

    uPov(:,r)  = exp(interp1(u,log(uPovFin(:,r)),uDeltares));
    
    if strcmp(sNaam,'Schiphol')
        uPovV(:,r) = exp(interp1(uGrid,log(uPovVolk(:,r)),uDeltares));
        
        %correct voor discretisatie
        if ismember(richting16(r),rVolker)==0 
           
            uPovV(:,r) = uPov(:,r);
            
        end
    end

end

for r = 1:length(richting16)

    figure
    semilogy(uDeltares,uPov(:,r),'k','LineWidth',1.5);
    hold on
    if strcmp(sNaam,'Schiphol')
        semilogy(uDeltares,uPovV(:,r),'g','LineWidth',1.5);
    end
    grid on
    ylim([1e-6 1]);
    xlabel('Windsnelheid [m/s]');
    ylabel('Overschrijdingskans [1/12 uur]');
    title([sNaam,': conditionele overschrijdingskans windsnelheid, r = ',num2str(richting16(r))]);
    if strcmp(sNaam,'Schiphol')
        legend('WTI2017 aangepast','Met Volkerfactor');
    else
        legend('WTI2017 aangepast');
    end
    print(gcf,'-dpng',['Figuren\',sNaam,'_Pov_',num2str(richting16(r)),'_final.png']);
    
    figure
    semilogx(1./(uPov(:,r)*360*Pr(r,2)),uDeltares,'k','LineWidth',1.5);
    hold on
    if strcmp(sNaam,'Schiphol')
        semilogx(1./(uPovV(:,r)*360*Pr(r,2)),uDeltares,'g','LineWidth',1.5);
    end
    grid on
    xlim([0 1e6]);
    xlabel('Terugkeertijd [jaar]');
    ylabel('Windsnelheid [m/s]');
    title([sNaam,': overschrijdingskans windsnelheid, r = ',num2str(richting16(r))]);
    if strcmp(sNaam,'Schiphol')
        legend('WTI2017 aangepast','Met Volkerfactor','location','NorthWest');
    else
        legend('WTI2017 aangepast','location','NorthWest');
    end
    print(gcf,'-dpng',['Figuren\',sNaam,'_T_',num2str(richting16(r)),'_final.png']);

end

if strcmp(sNaam,'Schiphol')==1
    save('Wind_Schiphol_2017_WFREQ','uDeltares','uPov','uPovV');
elseif strcmp(sNaam,'Deelen')==1
    save('Wind_Deelen_2017_WFREQ','uDeltares','uPov');
end

close all