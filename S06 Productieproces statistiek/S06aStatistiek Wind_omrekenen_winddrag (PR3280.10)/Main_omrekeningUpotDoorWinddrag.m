%% Script om sleutelwaarden database IJsselmeer aan te passen
% N.B. Markermeer wordt niet aangepast.

% Door:     Chris Geerse
% Datum:    2 september 2016.
% Project:  PR3280.20.

% Uitgangspunt zijn sleutelwaarden:
sleutelwaarden = [...
0
14
19
22
25
28
30
31
34
38
42];


%% Gegevens voor aanpassing Upot (mail Van Vledder 29 maart 2016):
% N.B. Deze waarden vervangen een eerdere relatie van Van Vledder
% waarin gegevens voor U10 werden vervangen.
% Maar we moeten dus Upot aanpassen; vandaar dat de berekeningen opnieuw
% worden gedaan.


GegevensVanVledder = [... 
   1.000   1.000 
   2.000   2.000 
   3.000   3.000 
   4.000   4.000 
   5.000   5.000 
   6.000   6.000 
   7.000   7.000 
   8.000   8.000 
   9.000   9.000 
  10.000  10.000 
  11.000  11.000 
  12.000  12.000 
  13.000  13.000 
  14.000  14.000 
  15.000  15.000 
  16.000  16.000 
  17.000  17.000 
  18.000  18.000 
  19.000  19.000 
  20.000  20.000 
  21.000  21.000 
  22.000  22.000 
  23.000  23.000 
  24.000  24.000 
  25.000  25.000 
  26.000  26.000 
  27.000  27.000 
  28.000  28.000 
  29.000  28.787 
  30.000  29.515 
  31.000  30.288 
  32.000  31.055 
  33.000  31.816 
  34.000  32.572 
  35.000  33.323 
  36.000  34.070 
  37.000  34.811 
  38.000  35.548 
  39.000  36.280 
  40.000  37.008 
  41.000  37.732 
  42.000  38.452 
  43.000  39.168 
  44.000  39.880 
  45.000  40.589 
  46.000  41.294 
  47.000  41.995 
  48.000  42.693 
  49.000  43.389 
  50.000  44.080 
  51.000  44.769 
  52.000  45.455 
  53.000  46.138 
  54.000  46.818 
  55.000  47.495 
  56.000  48.170 
  57.000  48.842 
  58.000  49.511 
  59.000  50.178 
  60.000  50.842];

% N.B. Bij oude sleutelwaarde moet juist een HOGERE windsnelheid komen (let 
% dus op de volgorde van de te interpoleren kolommen):
sleutelwaardenNieuwOpUpot = interp1(GegevensVanVledder(:,2), GegevensVanVledder(:,1), sleutelwaarden, 'linear', 'extrap');
Tabel                     = [sleutelwaarden, sleutelwaardenNieuwOpUpot];
disp('Nieuwe sleutelwaarden bij aanpassing Upot')
Tabel

figure
grid on; hold on
plot(Tabel(:,1), Tabel(:,1),'b','linewidth', 1.5)
plot(Tabel(:,2), Tabel(:,1),'r--','linewidth', 1.5)
title('Aanpassing sleutelwaarden (in termen van Upot')
legend('1-1 lijn', 'Aaanpassing','location', 'SouthWest')
xlabel('Upot, m/s')
xlabel('Aangepaste waarde Upot, m/s')


%% N.B. Ton Botterhuis heeft in de vervolganalyse al met de nieuwe gegevens
% gerekend, zie PR3249.10 ijsselmeer en markermeer. 
% Daarbij heeft hij de sleutelwaarden voor de
% oude relatie vervangen door de nieuwe (zie onder).
% Maar straks worden deze nieuwe gegevens alleen gebruikt voor het
% IJsselmeer en niet voor het Markermeer.
%
% Omzetting sleutelwaarden door Ton, gebruikt in PR3249.10.
% UPDATE Resultaat SET s3 = 30.6 WHERE s3=30; 
% UPDATE Resultaat SET s3 = 31.9 WHERE s3=31.4; 
% UPDATE Resultaat SET s3 = 35.9 WHERE s3=35.6; 
% UPDATE Resultaat SET s3 = 41.3 WHERE s3=41.4; 
% UPDATE Resultaat SET s3 = 47.0 WHERE s3=47.6;
%
% Maar we gaan in het vervolg de omrekening doen op basis van de originele
% sleutelwaarden, berekend in Tabel.