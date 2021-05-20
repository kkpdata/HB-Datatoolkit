%==========================================================================
% Statistiek VRM
% Door: Chris Geerse
% Tbv: PR3280.20

%==========================================================================
clc
clear
close all
addpath 'Hulproutines\' 'Invoer\';
%==========================================================================

%==========================================================================
%Inlezen van Promovera statistiek (uit project SPIJ afkomstig)
%==========================================================================

%Inlezen Promovera statistiek, respectievelijk:
%m, m+NAP; OF, 1/whjaar; OD, dag/whjaar;
[m_PR, OF_PR, OD_PR] = textread('VRM_SPIJ_statgegevens.txt','%f %f %f','delimiter',' ','commentstyle','matlab');


%==========================================================================
% Tabel maken
%==========================================================================
Treeks  = [10,25,50:50:1250, 1500, 1750, 2000:1000:20000, 30000:10000:100000]'; 
mpReeks = interp1(1./OF_PR, m_PR, Treeks, 'linear', 'extrap');

Tabel = [Treeks, mpReeks];


figure
semilogx(Tabel(:,1),Tabel(:,2),'r-');
hold on
grid on
title('Overschrijdingsfrequentie Veluwerandmeer')
xlabel('Terugkeertijd, jaar')
ylabel('Overschrijdingsfrequentie, 1/jaar')