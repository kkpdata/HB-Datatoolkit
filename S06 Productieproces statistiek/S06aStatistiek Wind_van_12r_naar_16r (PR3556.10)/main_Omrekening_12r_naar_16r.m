%==========================================================================
% Script omrekenen 30-graden sectoren naar 22.5-sectoren voor wind
% Vlissingen (met en zonder aanpassing voor dragcoefficient).
% Ook keuze voor zeewaterstand OS11 is mogelijk, met m dan aangeduid door u
%
%
% Door:    Chris Geerse
% Project: PR3556.10
% Datum:   augustus 2017.
%
% Zie voor notatie rapportage PR3556.10
%
%==========================================================================

%% Invoer

clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

%% Geef gewenste bestandstype op:
% 1 = wind Vlissingen zonder aanpassing winddrag
% 2 = wind Vlissingen met aanpassing winddrag
% 3 = zeewaterstand OS11

keuzeBestand = 3;


%% Onderdelen voor grafieken
[alle_markers_r, alle_markers_w] = Bepaal_gewenste_markers();

rFig  = {'NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW','N','omni'};
wFig  = {'30','60','90','120','150','180','210','240','270','300','330','360','omni'};

% Kies de kleuren.
alle_kleuren      = hsv(63);
alle_kleuren      = flipud(alle_kleuren);   %geeft mooiere verdeling kleuren

%% Inlezen bestanden

% Bestand met overschijdingskansen P(U>u|w) voor 30-sectoren in tabelvorm:
switch keuzeBestand
    case 1
        Invoer30 = load('Ovkanswind_Vlissingen_2017.txt');
        lab      = 'Vlissingen';
        labFig   = 'Windsnelheid, m/s';
        labWegschrijf = 'Ovkansen potentiele windsnelheid Vlissingen';
        uMinFig  = 1;   %minimum windsnelheid voor figuren
        uMaxFig  = 40;  %maximum windsnelheid voor figuren
    case 2
        Invoer30 = load('Ovkanswind_Vlissingen_2017_metWindDrag.txt');
        lab      = 'Vlissingen (winddrag)';
        labFig   = 'Windsnelheid, m/s';
        labWegschrijf = 'Ovkansen potentiele windsnelheid Vlissingen met aanpassing voor winddrag';
        uMinFig  = 1;   %minimum windsnelheid voor figuren
        uMaxFig  = 40;  %maximum windsnelheid voor figuren
    case 3
        Invoer30 = load('CondPovOS11_12u_zichtjaar2017.txt');
        lab      = 'OS11';
        labFig   = 'Zeewaterstand, m+NAP';
        labWegschrijf = 'Ovkansen zeewaterstand OS11';
        uMinFig  = 1.5;   % NAP, minimum zeews voor figuren
        uMaxFig  = 6;   % NAP, maximum zeews voor figuren
end


% Bestand met richtingskansen w (30-sectoren); 30, 60,..., 360:
PwInv  = load('KansenWindrichting_OS_2017.txt');

%% Bewerkingen
Nw     = 12;
Nr     = 16;

w      = PwInv(:,1);   %kolom 12*1, bevat w = 30, 60,..., 360
Pw     = PwInv(:,2);   %kolom 12*1, bevat P(w)

uReeks       = Invoer30(:, 1);      % kolom  82*1,  bevat u
PuCon_w      = Invoer30(:, 2:end);  % matrix 82*12, bevat P(U>u|w)

Nu           = numel(uReeks);
PwReplicated = repmat(Pw',Nu,1);
PuCombi_w    = PwReplicated.*PuCon_w; % matrix 82*12, bevat P(U>u,w)

% Bepaal ook omnidirectionele P(U>u) voor 30-sectoren
PuOmni_w = sum(PuCombi_w, 2);


%% Bepaal nieuwe richtingskansen P(r)

% Inlezen wegingsfactoren:
wegingInv  =  load('Wegingsfactoren_opdeling_12r_naar16r.txt');
r          = wegingInv(2:end, 1);
Mweging    = wegingInv(2:end, 2:end);   %alleen de factoren zelf, in een matrixvorm

Pr         = Mweging*Pw;

figure
plot(w, Pw, 'r*-', 'markersize', 7)
hold on; grid on
plot(r, Pr, 'bo-', 'markersize', 7)
plot(r, 30/22.5*Pr, 'ko-', 'markersize', 7)
title(['Richtingskansen ', lab])
xlabel('Windrichting, graden')
ylabel('Kansen, [-]')
legend('30-sectoren P(w)', '22.5-sectoren P(r)','P(r)*30/22.5')



%% Voer de weging uit om P(U>u,r) te krijgen:

% initialisatie
PuCombi_r = zeros(Nu, 16);

for i = 1 : Nu
    
    uHulp  = uReeks(i);
    PuHulp = PuCombi_w(i, :);   % rijvector 12*1
    
    % Bepaal P(U>uHulp , r):
    PuHulpCombi_r    = Mweging*PuHulp';   % rijvector 1*16
    
    % Bouw de volledige matrix op:
    PuCombi_r(i,:)   = PuHulpCombi_r;
    
end

% Bepaal ook omnidirectionele P(U>u) voor 22.5
PuOmni_r = sum(PuCombi_r, 2);

%% Bepaal de conditionele kansen P(U>u|r):

PrReplicated = repmat(Pr', Nu, 1);
PuCon_r      = PuCombi_r./PrReplicated;       % matrix 82*16, bevat P(U>u|r)
TabelPuCon_r = [[999,r'];[uReeks, PuCon_r]];  % zet ook richtingen  en windsnelheden er bij


%% Bepaal de ovfrequenties
N              = 360;
FuCombi_r      = N * PuCombi_r;  % matrix 82*16, bevat F(U>u,r)
TabelFuCombi_r = [[999,r'];[uReeks, FuCombi_r]];   % zet ook richtingen  en windsnelheden er bij

FuCombi_w = N * PuCombi_w;  % matrix 82*12, bevat F(U>u,r)
TabelFuCombi_w = [[999,w'];[uReeks, FuCombi_w]];   % zet ook richtingen  en windsnelheden er bij


%% Figuren voor kansen P(U>u,w) en P(U>u,r)

figure
for i = 1 : Nw
    semilogy(uReeks, PuCombi_w(:, i),alle_markers_w{i},'color',alle_kleuren(4*(Nw+1)-4*i,:),'Linewidth',1,'MarkerSize',4);
    hold on; grid on
end
semilogy(uReeks,PuOmni_w, 'k--', 'linewidth', 2)
title(['Combinatiekansen, 30-sectoren ', lab])
xlim([uMinFig, uMaxFig])
ylim([1e-8, 1])
xlabel(labFig)
ylabel('Overschrijdingskans, [-]')
legend(wFig,'Location', 'NorthEastOutside'); %'NorthWest');

figure
for i = 1 : Nr
    semilogy(uReeks, PuCombi_r(:, i),alle_markers_r{i},'color',alle_kleuren(3*(Nr+1)-3*i,:), 'Linewidth',1,'MarkerSize',4);
    hold on; grid on
end
semilogy(uReeks,PuOmni_r, 'k--', 'linewidth', 2)
title(['Combinatiekansen, 22.5-sectoren ', lab])
xlim([uMinFig, uMaxFig])
ylim([1e-8, 1])
xlabel(labFig)
ylabel('Overschrijdingskans, [-]')
legend(rFig,'Location', 'NorthEastOutside'); %'NorthWest');


%% Figuren voor kansen P(U>u|w) en P(U>u|r)
figure
for i = 1 : Nw
    semilogy(uReeks, PuCon_w(:, i),alle_markers_w{i},'color',alle_kleuren(4*(Nw+1)-4*i,:),'Linewidth',1,'MarkerSize',4);
    hold on; grid on
end
semilogy(uReeks,PuOmni_w, 'k--', 'linewidth', 2)
title(['Conditionele kansen, 30-sectoren ', lab])
xlim([uMinFig, uMaxFig])
ylim([1e-8, 1])
xlabel(labFig)
ylabel('Overschrijdingskans, [-]')
legend(wFig,'Location', 'NorthEastOutside'); %'NorthWest');

figure
for i = 1 : Nr
    semilogy(uReeks, PuCon_r(:, i),alle_markers_r{i},'color',alle_kleuren(3*(Nr+1)-3*i,:), 'Linewidth',1,'MarkerSize',4);
    hold on; grid on
end
semilogy(uReeks,PuOmni_r, 'k--', 'linewidth', 2)
title(['Conditionele kansen, 22.5-sectoren ', lab])
xlim([uMinFig, uMaxFig])
%xlim([1.50, 6])
ylim([1e-8, 1])
xlabel(labFig)
ylabel('Overschrijdingskans, [-]')
legend(rFig,'Location', 'NorthEastOutside'); %'NorthWest');


%% Figuren voor frequenties
figure
for i = 1 : Nw
    semilogy(uReeks, FuCombi_w(:, i),alle_markers_w{i},'color',alle_kleuren(4*(Nw+1)-4*i,:),'Linewidth',1,'MarkerSize',4);
    hold on; grid on
end
semilogy(uReeks,N*PuOmni_w, 'k--', 'linewidth', 2)
title(['Frequentie 30-sectoren ', lab])
xlim([uMinFig, uMaxFig])
ylim([1e-6, 0.1])
xlabel(labFig)
ylabel('Overschrijdingsfrequentie, 1/jaar')
legend(wFig,'Location', 'NorthEastOutside');

figure
for i = 1 : Nr
    semilogy(uReeks, FuCombi_r(:, i),alle_markers_r{i},'color',alle_kleuren(3*(Nr+1)-3*i,:), 'Linewidth',1,'MarkerSize',4);
    hold on; grid on
end
semilogy(uReeks,N*PuOmni_r, 'k--', 'linewidth', 2)
title(['Frequentie 22.5-sectoren ', lab])
xlim([uMinFig, uMaxFig])
% xlim([2, 6])
ylim([1e-6, 0.1])
xlabel(labFig)
ylabel('Overschrijdingsfrequentie, 1/jaar')
legend(rFig,'Location', 'NorthEastOutside');


%% Bepaal E(U|w) en E(U|r)

for i = 1 : 12
    Pu_ov         = PuCon_w(:, i);
    
    hulpkans      = circshift(Pu_ov, -1);
    hulpkans(end) = 0;
    klassekansen  = Pu_ov - hulpkans;
    klassemiddens = (uReeks + circshift(uReeks, -1))/2;
    klassemiddens(end) = klassemiddens(end-1);     %compenseer voor rare laatste klasse
    
    E_U_gegevenW(1,i)  = sum(klassemiddens.*klassekansen);
end

for i = 1 : 16
    Pu_ov         = PuCon_r(:, i);
    
    hulpkans      = circshift(Pu_ov, -1);
    hulpkans(end) = 0;
    klassekansen  = Pu_ov - hulpkans;
    klassemiddens = (uReeks + circshift(uReeks, -1))/2;
    klassemiddens(end) = klassemiddens(end-1);     %compenseer voor rare laatste klasse
    
    E_U_gegevenR(1,i)  = sum(klassemiddens.*klassekansen);
end


figure
i = 1;  %truucje om legenda simpel te houden
plot(w(i), E_U_gegevenW(1,i), 'r*-')
hold on; grid on
plot(r(i), E_U_gegevenR(1,i), 'bo-')

plot(w, E_U_gegevenW(1,:), 'r*-')
plot(r, E_U_gegevenR(1,:), 'bo-')
title(['12-uurs gemiddelde per richting ',lab])
xlabel('Windrichting, graden')
ylabel(labFig)
%ylim([1.6,2])
legend('30-sectoren', '22.5-sectoren', 'location', 'northwest')

% close all


%% Toevoegen kwantielen

% Tkwant = [10, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7]';
Tkwant = [10, 1e2, 1e3, 1e4]';


for i = 1 : 12
    % laat laagste deel weg, vanwege niet-monotoon zijn
    uKwant_w(:,i) = interp1(log(1./FuCombi_w(10:end, i)), uReeks(10:end), log(Tkwant), 'linear', 'extrap');
end

for i = 1 : 16
    % laat laagste deel weg, vanwege niet-monotoon zijn
    uKwant_r(:,i) = interp1(log(1./FuCombi_r(10:end, i)), uReeks(10:end), log(Tkwant), 'linear', 'extrap');
end


figure
i = 1;  %truucje om legenda simpel te houden
plot(w(i), uKwant_w(1,i), 'r*-')
hold on; grid on
plot(r(i), uKwant_r(1,i), 'bo-')
for j = 1 : numel(Tkwant)
    plot(w, uKwant_w(j,:), 'r*-')
    plot(r, uKwant_r(j,:), 'bo-')
end
title(['Kwantielen ',lab])
xlabel('Windrichting, graden')
ylabel(labFig)
xlim([0, 360]);
%ylim([2, 5]);
% ylim([10, 40]);
legend('30-sectoren', '22.5-sectoren', 'location', 'northwest')


%% Wegschrijven conditionele kansen

switch keuzeBestand
    case 1
        fid = fopen(['Ovkanswind_Vlissingen_16sectoren_2017.txt'],'wt');
    case 2
        fid = fopen(['Ovkanswind_Vlissingen_16sectoren_2017_metWindDrag.txt'],'wt');
    case 3 %CondPovOS11_12u_zichtjaar2017.txt
        fid = fopen(['CondPovOS11_16sectoren_12u_zichtjaar2017.txt'],'wt');
end
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n',['* ', labWegschrijf]);
fprintf(fid,'%s\n','* WBI2017: 12-uursmaxima, gegeven windrichting');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* Project: PR3556.10');
fprintf(fid,'%s\n','* Door:    Chris Geerse van HKV lijn in water');
fprintf(fid,'%s\n','* Datum:   augustus 2017');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','*');
switch keuzeBestand
    case {1, 2}
        fprintf(fid,'%s\n','* u, m/s    NNO            NO             ONO            O              OZO            ZO             ZZO            Z              ZZW            ZW             WZW            W              WNW            NW             NNW            N');
    case 3
        fprintf(fid,'%s\n','* m, m+NAP  NNO            NO             ONO            O              OZO            ZO             ZZO            Z              ZZW            ZW             WZW            W              WNW            NW             NNW            N');
end
%fprintf(fid,['%6.2f',repmat('      %1.3e',1,16),' \n'],X');
fprintf(fid,['%6.2f',repmat('      %1.3e',1,16),' \n'],TabelPuCon_r(2:end,:)');
fclose all;


