%==========================================================================
% Hoofdprogramma Vecht
% Door: Chris Geerse
%==========================================================================
clear 
close all
%==========================================================================
% Uitvoer wegschrijven in       %waarom mag er geen ; achter?
padnaam_uit = 'Y:/Matlab_VIJ/Statistiek Hydra VIJ/Vecht02/'
%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie golven en opschaling
drempel = 180;          % variabele voor drempel waarde 
zpot = 15;          %zichtduur 
zB = 15;              %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
piekduur = 0.0001; %duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 1; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 1;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet
fig_opschaling = 1;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%betaverdeling
a = 4.1;
b = 3.95;
nstapx_beta = 100;
nstapy_beta = 100;
Bbeta = 30;         %basisduur beta-golven
%parameters trapezia
B = 30;             %basisduur trapezia
topduur_inv = ...
    [0, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    180, 60;
    1000, 60]
%parameters afvoer
stapy = 5;      %stapgrootte voor kansvectoren (y is bijv piekafvoer of afvoerniveau)
%(NB hele kleine stapgrootte, zeg stapy = 1, geeft beste overeenkomst tussen trapezia en beta-vormen)
ymax = 900;     %maximum van vector
ovkanspiek_inv = ...
    [0, 1;
    180, 0.16667;
    550, 1.3333e-4]
if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan (dan met foute resultaten).')
    pause
end

%==========================================================================
%Inlezen data
%==========================================================================
%[jaar,maand,dag,data] = textread('Vechtafvoeren_1960_1983_dag.txt','%u %u %u %f','delimiter','','commentstyle','matlab');
[jaar,maand,dag,data] = textread('Vechtafvoeren_60_83_met_uitbreiding.txt','%u %u %u %f','delimiter','','commentstyle','matlab');
%geef hier desgewenst andere selectie aan:
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(jaar>=1960&jaar<=2002));

%==========================================================================
%Berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
jaar = jaar(selectie);
maand = maand(selectie);
dag = dag(selectie);
data = data(selectie);
datum = datenum(jaar,maand,dag);

ymin = ovkanspiek_inv(1,1);

%==========================================================================
%Selecteren van (niet aangepaste) golven uit datareeks
%==========================================================================
[golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);




% %==========================================================================
% %Aanpassen van golven: piek/dal-verbreding en monotone voor- en
% %achterflanken maken door nevenpieken tegen hoofdpiek te plakken.
% %Resultaat is opgeschaalde standaardgolf.
% 
% [v, tvoor, tachter, fv] = opschaling(...
%     golfkenmerken,golven,ref_niv,piekduur,nstapv,fig_golven_verbreed,fig_golven_rel,fig_opschaling);
% 
% 
% %==========================================================================
% % Bepalen van genormeerde standaardgolfvorm Vecht (golven volgens beta-verdeling).
% %==========================================================================
% [beta_normgolfvorm, beta_normgolfduur] = beta_normgolf(a, b, nstapx_beta, nstapy_beta);
% 
% %==========================================================================
% % Bepalen gemiddelde vorm (opschalingsmethode)
% %==========================================================================
% aantal_golven = length(golfkenmerken(:,1));
% tvgem = [v, mean(tvoor(:,2:aantal_golven),2)];  %mean(A,2) geeft gemiddelde per rij uit matrix A
% tagem = [v, mean(tachter(:,2:aantal_golven),2)];
% 
% close all
% figure
% plot(tvgem(:,2),v,'b',tagem(:,2),v,'b');
% hold on
% grid on
% plot(Bbeta*beta_normgolfvorm(:,1)-Bbeta/2,beta_normgolfvorm(:,2),'r');
% title(['drempel = ',num2str(drempel),', zpot = ',num2str(zpot),', zB = ',...
%     num2str(zB),', aantal golven = ',num2str(aantal_golven),', piekduur = ',num2str(piekduur)]);
% %    ......(aantal_golven),', piekduur =
% %    ',num2str(round(piekduur*100)/100)]); voor afbeelden 0.9999 als 1
% xlabel('tijd, dagen');
% ylabel('relatieve hoogte, [-]');
% 
% 
% %==========================================================================
% % Plotten van alle geselecteerde golven inclusief beta-golven
% %==========================================================================
% plot_Vechtgolven(beta_normgolfvorm, golfkenmerken, golven, Bbeta);
% 
% 
% 
% 
% % 
% % %==========================================================================
% % % Momentane ov.kans volgens berekening met trapezia en beta-golven
% % %==========================================================================
% % 
% % [y, by, fy_piek, Gy_piek, fy_mom, Gy_mom] = grootheden_trap(stapy, ymax, B, topduur_inv, ovkanspiek_inv);
% % 
% % [fy_mombeta, Gy_mombeta] = momkansen_beta(a, b, nstapx_beta, nstapy_beta, Gy_piek);
% % %[fy_mombeta(:,1) fy_mombeta(:,2)*stapy, Gy_mombeta]
% % 
% % %==========================================================================
% % % Momentane ov.kans volgens de metingen
% % %==========================================================================
% % [y, fy_mom_obs, Gy_mom_obs] = turven_metingen(y, data);
% % 
% % %==========================================================================
% % % Plaatjes momentane kansen volgens de metingen en volgens de integratie
% % %==========================================================================
% % 
% % %close all
% % figure
% % plot(y,Gy_mom_obs(:,2),'g-',y,Gy_mom(:,2),'b-.', y, Gy_mombeta(:,2), 'r')
% % grid on
% % hold on
% % xlim([0 400]);
% % ylim([0 1]);
% % xlabel('Vechtafvoer Dalfsen, m3/s')
% % ylabel('momentane overschrijdingskans, [-]')
% % legend('observatie','integratie','uit beta-golfvorm')
% % 
% % close all
% % plot(y,log(Gy_mom_obs+eps),'g-',y,log(Gy_mom(:,2)+eps),'b-.', y, log(Gy_mombeta(:,2)), 'r')
% % grid on
% % hold on
% % xlim([0 500]);
% % ylim([-12 0]);
% % xlabel('Vechtafvoer Dalfsen, m3/s')
% % ylabel('ln momentane overschrijdingskans, [-]')
% % legend('observatie','integratie','uit beta-golfvorm')
% % 
% % %{
% % close all
% % plot(y,log(fy_mom_obs+eps),'g-',y,log(fy_mom(:,2)+eps),'b-.')
% % grid on
% % hold on
% % xlim([0 400]);
% % %ylim([0 1]);
% % xlabel('Vechtafvoer Dalfsen, m3/s')
% % ylabel('ln momentane kansdichtheid, [-]')
% % legend('observatie','integratie')
% % 
% % close all
% % plot(y,fy_mom_obs,'g-',y,fy_mom(:,2),'b-.')
% % grid on
% % hold on
% % xlim([0 400]);
% % %ylim([0 1]);
% % xlabel('Vechtafvoer Dalfsen, m3/s')
% % ylabel('momentane kansdichtheid, [-]')
% % legend('observatie','integratie')
% % %}
% % 
% % 
% % %tbv van manier van saven hier een voorbeeld:
% % %save([padnaam_uit,'piek_datum_CG.txt'],'piek_datum','-ascii')
% % 
