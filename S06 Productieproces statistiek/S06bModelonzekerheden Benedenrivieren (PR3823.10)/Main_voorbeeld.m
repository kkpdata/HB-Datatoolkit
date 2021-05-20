%% script als hulp bijj werkwaijze BER

clc
close all


%%
A = load('InvoerVoorbeeldlocatie.txt');

afvoer = [2000 : 2000 : 20000]';

% Variabelen
s1   = 0.05;
s2   = 0.15;
s3   = 0.32;
s4   = 0.08;

%PlotNormaleVerdeling

PlotUniformeVerdeling
PlotUniformeVerdeling_versprongenVariabelen


close all

%% plaatje normale verdeling

x = [-4 : 0.1 :4]';
y = normpdf(x);


xlinks       = norminv(0.3, 0, 1);
xrechts       = norminv(0.7, 0, 1);
xlinks_klasse = norminv(0.15, 0, 1);
xrechts_klasse = norminv(0.85, 0, 1);

xBen  = [xlinks, xlinks;
         0, normpdf(xlinks)]';
xBov  = [xrechts, xrechts;
         0, normpdf(xrechts)]';
xBenKlasse  = [xlinks_klasse, xlinks_klasse;
         0, normpdf(xlinks_klasse)]';
xBovKlasse  = [xrechts_klasse, xrechts_klasse;
         0, normpdf(xrechts_klasse)]';
% xBenGrens  = [-1, -1;
%          0, normpdf(-1)]';
% xBovGrens  = [1, 1;
%          0, normpdf(1)]';

     
     
figure
plot(x,y,'b-', 'linewidth', 2)
grid on; hold on
plot(xBen(:,1), xBen(:,2),'r--', 'linewidth', 2)
plot(xBov(:,1), xBov(:,2),'r-', 'linewidth', 2)
plot(xBenKlasse(:,1), xBenKlasse(:,2),'k--', 'linewidth', 2)
plot(xBovKlasse(:,1), xBovKlasse(:,2),'k-', 'linewidth', 2)
plot([0, 0], [0,normpdf(0)], 'b-', 'linewidth', 2)
title('Normale verdeling met klassegrenzen')
%legend('Normale verdeling', 'Grens laagste 30 procent', 'Grens hoogste 30 procent','X_{midden} -\Delta','X_{midden} +\Delta')
legend('Normale verdeling', 'Grens laagste 30 procent', 'Grens hoogste 30 procent','Grens laagste 15 procent','Grens hoogste 15 procent')
xlabel('Variabele x/{\sigma}')
ylabel('Kansdichtheid')
ylim([0, 0.6])