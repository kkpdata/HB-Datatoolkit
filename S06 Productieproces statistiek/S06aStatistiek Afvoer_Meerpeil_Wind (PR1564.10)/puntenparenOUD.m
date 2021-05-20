function [paren] = puntenparen(golvenI, zD, datumD, dataD);
%
%Door: Chris Geerse
%
%
%
%==========================================================================
%Bij ingelezen pieken I van de onafhankelijke variabele wordt steeds het maximum
%van de afhankelijke variabele Dx gezocht, binnen venster (t-zD, t+zD)
%waarbij t het tijdstip is van piek I. Daarnaast wordt ook de waarde Dr van
%de afhankelijke variabele gezocht.
%(Notatie: I = independent, D = dependent, x = max, r = recht.)
%
%Input:
%golvenI: structure met gegevens geselecteerde onafhankelijke pieken I
%zD: halve breedte weergavevenster afh variabele
%datumD: seriële datums van meetreeks afh variabele
%dataD: waarden in de meetreeks van de afh variabele
%
%Output:
%structure paren:
%voor aantal_golven = N struct array with fields:
%     dtmI: [Nx1 double]: seriële datum onafh piekwaarde
%    dtmDx: [Nx1 double]: seriële datum ten tijde maximum afh var
%         I: [Nx1 double]: onafh piekwaarde
%        Dx: [Nx1 double]: maximum afh var
%        Dr: [Nx1 double]: waarde afh var ten tijde van piek
%
%==========================================================================
%Begin van de functie.
%==========================================================================
NI = max([golvenI.rang]);       %aantal golven onafhankelijke variabele
piekdtmI = zeros(NI,1);         %initialisatie seriële datums pieken onafh variabele
for i = 1:NI
    piekdtmI(i) = datenum(golvenI(i).jaa,golvenI(i).mnd,golvenI(i).dag);
end

%initialisaties
I = zeros(NI,1);          %piekwaardes onafh variabele
Dx = zeros(NI,1);         %maxima afh variabele rond pieken onafh variabele
Dr = zeros(NI,1);         %waardes afh variabele tijdens pieken onafh variabele
piekdtmD = zeros(NI,1);   %seriële datums maxima afh variabele
critsel = zeros(NI,1);    %criteriumvariabele: 0 is geen geldig puntenpaar en 1 is wel
Nparen = 0;               %aantal geldige puntenparen

for n = 1:NI
    i = find(datumD == piekdtmI(n));
    if (datumD(i) - datumD(i-zD) == zD & datumD(i+zD) - datumD(i) == zD)
        critsel(n) = 1;
        i = find(datumD == piekdtmI(n));
        v = [i-zD:i+zD];
        [Dx(n), imaxD] = max(dataD(v));
        piekdtmD(n) = datumD(i+imaxD-zD-1);
        Dr(n) = dataD(i);
        I(n) = golvenI(n).piek;
        Nparen = Nparen+1;
    end
end

%{
for n = 1:NI
    if (piekdtmI(n) >= bedatumD+zD & piekdtmI(n) <= eidatumD-zD)

        critsel(n) = 1;
        i = find(datumD == piekdtmI(n));
        v = [i-zD:i+zD];
        [Dx(n), imaxD] = max(dataD(v));
        piekdtmD(n) = datumD(i+imaxD-zD-1);
        Dr(n) = dataD(i);
        I(n) = golvenI(n).piek;
        Nparen = Nparen+1;
    end
end
%}
%Bepalen definitieve (geldige) puntenparen (waarvoor beide variabelen tot meetreeks
%behoren) en vullen van structure met gegevens.
F = (critsel==1);
I1 = piekdtmI(F);     %seriële datums van geldige pieken
I2 = piekdtmD(F);     %seriële datums van bijbehorende maxima
I3 = I(F);
I4 = Dx(F);
I5 = Dr(F);

for i = 1:Nparen
    paren(i).dtmI = I1(i);      %seriële datums van pieken
    paren(i).dtmDx = I2(i);     %seriële datums van bijbehorende maxima
    paren(i).I = I3(i);
    paren(i).Dx = I4(i);
    paren(i).Dr = I5(i);
end
%[[paren.dtmI]' [paren.dtmDx]' [paren.I]' [paren.Dx]' [paren.Dr]']



