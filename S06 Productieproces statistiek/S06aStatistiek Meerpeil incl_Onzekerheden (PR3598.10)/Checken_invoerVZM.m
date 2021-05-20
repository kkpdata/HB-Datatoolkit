clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';

AA = load('Ovkans_Volkerakzoommeer_piekmeerpeil_PR3598.10.txt');    %in rapport 17 aug
BB = load('Ovkans_VZM_piekmeerpeil_BER-VZM.txt');                   % voor invoer Hydra-NL


figure
semilogy(AA(:,1), AA(:,2),'b-')
grid on; hold on
semilogy(BB(:,1), BB(:,2),'r--')

% Conclusie: precies dezelfde lijnen