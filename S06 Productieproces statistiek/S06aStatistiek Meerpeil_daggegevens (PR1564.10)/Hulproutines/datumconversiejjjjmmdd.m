function [jaar,maand,dag,datum] = datumconversiejjjjmmdd(datuminlees);
%
%Door: Chris Geerse
%
%==========================================================================
%Berekent uit datumvariabele met formaat jjjjmmdd het jaar, maand, dag en
%de seri�le datum.
%
%==========================================================================
%Begin van de functie.
%==========================================================================
jaar    = [];
maand   = [];
dag     = [];
datum   = [];       %seri�le datum

jaar    = floor(datuminlees/10000);
maand   = floor((datuminlees-jaar*10000)/100);
dag     = floor(datuminlees-jaar*10000-maand*100);
datum   = datenum(jaar,maand,dag); 
