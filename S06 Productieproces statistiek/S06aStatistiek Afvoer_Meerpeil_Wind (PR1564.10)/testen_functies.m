
clear all;
%invoer b(y): eerste kolom is y, tweede is b(y).


stapy = 5;      %stapgrootte (NB hele kleine stapgrootte geeft beste overeenkomst tussen trapezia en beta-vormen)
ymax = 900;     %maximum van vector
B = 30;

topduur_inv = ...
    [0, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
    180, 48;
    1000, 48]

ovkanspiek_inv = ...
    [0, 1;
    180, 0.16667;
    550, 1.3333e-4]

%==========================================================================
%Parameters beta-verdeling
%==========================================================================
%defaultwaarden
a = 4.1;
b = 3.95;
nstapx_beta = 1000;
nstapy_beta = 1000;

%padnaam_uit = 'c:/Matlab/Vecht02/';
%padnaam_uit = 'Y:/Matlab_VIJ/Statistiek Hydra VIJ/Vecht02/'
%[beta_normgolfvorm, beta_normgolfduur] = beta_normgolf(a, b, nstapx_beta,
%nstapy_beta);

if (ovkanspiek_inv(1,1) ~= topduur_inv(1,1))
    display('FOUT: laagste waarde volgens topduur en ovkanspiek moet overeenstemmen!')
    display('Geef enter om door te gaan.')
    pause
end

[by, fy_piek, Gy_piek, fy_mom, Gy_mom] = grootheden_trap(stapy, ymax, B, topduur_inv, ovkanspiek_inv);


[fy_mombeta, Gy_mombeta] = momkansen_beta(a, b, nstapx_beta, nstapy_beta, Gy_piek);
%[fy_mombeta(:,1) fy_mombeta(:,2)*stapy, Gy_mombeta]

y = by(:,1);
%[youd, fyoud, Gyoud] = piekkansen(ovkanspiek_inv, stapy, ymax);  %tbv bepalen fy
%[y-youd, fy_piek(:,2)-fyoud, Gy_piek(:,2)-Gyoud]

%checken dat oude en nieuwe berekening hetzelfde. OK, behalve dat
%grootheden_trap exacte normering van fy_mom gebruikt en momkansen_trap niet.
%[xoud, fxoud, Gxoud] = momkansen_trap(stapy, ymax, B, topduur_inv, ovkanspiek_inv);
%[y-xoud, fy_mom(:,2)-fxoud, Gy_mom(:,2)-Gxoud]

close all
%plot(y,by(:,2))

%plot(y,log(Gy_mom(:,2)),'r',y,log(Gy_piek(:,2)), 'b')
%legend('mom', 'piek')
%xlim([0,700])
%ylim([0, 0.02])

%==========================================================================
% Momentane kans volgens de metingen
%==========================================================================
%aantal meetjaren is 26 met uitbreiding en 23 jaar zonder uitbreiding

[jaar,maand,dag,afvoer] = textread('Vechtafvoeren_60_83_met_uitbreiding.txt','%f %f %f %f','delimiter','\t','commentstyle','matlab');
%[jaar,maand,dag,afvoer] = textread('Vechtafvoeren_1960_1983_dag.txt','%f %f %f %f','delimiter','\t','commentstyle','matlab');
%geef hier analyseperiode aan:
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 | maand == 2 | maand == 3)&(jaar>=1900&jaar<=2010));
%[jaar(selectie),maand(selectie),dag(selectie),afvoer(selectie)]


N = numel((selectie));  %aantal dagen in winterhalfjaren
p=[];
q = y;
for i = 1:numel(q)
    x = find(afvoer(selectie)>= q(i));
    ovdagen = numel(x);
    p(i) = ovdagen/N; 
end
Gy_mom_obs = p';

fy_mom_obs = -diff(Gy_mom_obs)/stapy;             %bepalen van momentane kansdichtheid
fy_mom_obs = [fy_mom_obs; Gy_mom_obs(numel(Gy_mom_obs))];   %laatste klasse krijgt overblijvende kans


%==========================================================================
% Plaatje momentane kans volgens de metingen en volgens de integratie
%==========================================================================

close all
plot(y,Gy_mom_obs,'g-',y,Gy_mom(:,2),'b-.', y, Gy_mombeta(:,2), 'r')
grid on
hold on
xlim([0 400]);
ylim([0 1]);
xlabel('Vechtafvoer Dalfsen, m3/s')
ylabel('momentane overschrijdingskans, [-]')
legend('observatie','integratie','uit beta-golfvorm')

close all
plot(y,log(Gy_mom_obs+eps),'g-',y,log(Gy_mom(:,2)+eps),'b-.', y, log(Gy_mombeta(:,2)), 'r')
grid on
hold on
xlim([100 400]);
ylim([-9 -2]);
xlabel('Vechtafvoer Dalfsen, m3/s')
ylabel('ln momentane overschrijdingskans, [-]')
legend('observatie','integratie','uit beta-golfvorm')


close all
plot(y,log(fy_mom_obs+eps),'g-',y,log(fy_mom(:,2)+eps),'b-.')
grid on
hold on
xlim([0 400]);
%ylim([0 1]);
xlabel('Vechtafvoer Dalfsen, m3/s')
ylabel('ln momentane kansdichtheid, [-]')
legend('observatie','integratie')

close all
plot(y,fy_mom_obs,'g-',y,fy_mom(:,2),'b-.')
grid on
hold on
xlim([0 400]);
%ylim([0 1]);
xlabel('Vechtafvoer Dalfsen, m3/s')
ylabel('momentane kansdichtheid, [-]')
legend('observatie','integratie')

