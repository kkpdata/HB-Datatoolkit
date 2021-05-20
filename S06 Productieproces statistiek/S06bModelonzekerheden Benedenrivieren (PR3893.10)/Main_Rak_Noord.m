%==========================================================================
% Script voor snelle analyse Rak Noord
%
% Door: Chrs Geerse
% PR3598.10
% Datum: me 2017.
%
%
%==========================================================================
%==========================================================================
% Algemeen
%==========================================================================

clc
clear
close all
addpath 'Hulproutines\' 'invoer\';

%==========================================================================
% nvoer
%==========================================================================

A = load('Waterstand RakNoord_1nov1970tm12dec1993.txt');
%A = load('Waterstand RakNoord_1nov1970tm12dec1993_test.txt');

% %jaar	maand	dag	uur	min	wat.st. cmNAP
% 1970	11	1	0	0	-42
% 1970	11	1	1	0	-59


jaar   = A(:,1);
maand  = A(:,2);
dag    = A(:,3);
uur    = A(:,4);
minuut = A(:,5);
wsOrig = A(:,6);

% Maak uurwaarden; kes waarde op muut 0.
F      = find(minuut ==0);
jaar   = jaar(F);
maand  = maand(F); 
dag    = dag(F);   
uur    = uur(F);   
minuut = minuut(F);
ws     = wsOrig(F);

[ws_max, index] = max(ws);
min(ws);

% Gegevens maximum:
jaar(index)
maand(index)
dag(index)
uur(index)
%[jaar, maand, uur, ws]

Datum = datenum(jaar,maand,dag, uur,0, 0);
%nr    = jaar*1000000 + maand*10000 + dag*100 + uur;

figure
plot(Datum, ws)
grid on
title('Tijdsverloop waterstand Rak Noord')
xlabel('Datum')
ylabel('Waterstand, cm+NAP')
datetick('x',10)

