function [golfkenmerken, golven] = pieken_selectie(drempel,zpot,zB,jaar,maand,dag,uur,X,Y,Z);
%
% Door: Chris Geerse (bewerking van oude module van Vincent Beijk)
% Datum: 9 maart 2011
%
%
%==========================================================================
% Dit programma selecteert met zichtduur zpot die waarden uit de X-reeks 
% van uurmetingen die boven de aangegeven drempel uitkomen en zoekt hier omheen de
% gemeten golfvorm met naar links en rechts één duur zB.
%
% Het programma loopt met een venster (2*zpot + 1)
% over de gehele reeks en zoekt de hoogste X-waarde binnnen het venster.
% Slechts vensters - bestaande uit opeenvolgende uren -
% die geheel binnen de reeks vallen worden beschouwd.
%
% Naast de X-reeks worden van een Y- en een Z-reeks de gegevens tijdens de
% X-golven weggeschreven (Y en Z bijvoorbeeld de windsnelheid en
% windrichting tijdens waterstandpiek X.
% Y en Z moeten voor dezelfde uurtijdstippen gegeven zijn als de X-reeks.


% Input:
% drempel is ondergrens in de selectie van de golven
% zpot is zichtduur in selectie van pieken
% zB is halve vensterbreedte van geselecteerde tijdreeks van pieken
% jaar behorende bij waarneming
% maand behorende bij waarneming
% dag behorende bij waarneming
% X is variabele waarvan pieken worden geselecteerd uit gegeven tijdreeks
% Y is tweede tijdreeks, waarvan eveneens de gegevens worden geselecteerd
%  (maar dus niet via drempel)
% Z is derde tijdreeks, waarvan eveneens de gegevens worden geselecteerd
%  (maar dus niet via drempel)


% Output:
% golfkenmerken is matrix met kolommen met: 
% nr_golf, jaar waarin piek, maand waarin piek, dag waarin piek, uur waarin piek,
% piekwaarde, rangnummer piekwaarde (hoogste = 1), Y tijdens piek, Z tijdens piek.
%
% NB: Lengte kolommen is aantal X-golven.
 
% golven is een structure met velden:
% nr, jaa, mnd, dag, uur, piek, Y_bij_piek, Z_bij_piek, rang, tijd, Xdata,
% Ydata, Zdata
%
% tijd heeft verloop -zB,..., -1, 0, 1,...,zB
% Xdata geeft met de tijdstippen corresponderende X-data
% Ydata en Zdata hebben analoge betekenis
% 
% WAARSCHUWING:
% AAN BEGIN EN EIND VAN DE REEKS KUNNEN 'MINUS NEGENS' ZIJN TOEGEVOEGD INDIEN zB > zpot.
% DAT GEBEURT ALS OP EXTRA TIJDSTIPPEN GEEN DATA AANWEZIG ZIJN.
% 
% 
%==========================================================================
%Hier begint de eigenlijke functie
%==========================================================================
datum = datenum(jaar,maand,dag,uur,0,0);
%Breidt data uit met zB maal -999's aan begin en eind (nodig om zB niet van invloed
%te laten zijn op aantal geselecteerde pieken
negens = 999*ones(zB,1);
Xuit = [-1*negens; X; -1*negens];
Yuit = [-1*negens; Y; -1*negens];
Zuit = [-1*negens; Z; -1*negens];
indextot = [1:length(Xuit)]';

piekdatum = []; %initialisatie
golfnr    = 0; %initialisatie
for m = zB+zpot+1:(length(Xuit)-zB-zpot)
    [Xmax, i] = max(Xuit(m-zpot:m+zpot));

    %criterium voor selectie.
    %voorwaarde is tevens dat venster in de 'werkelijke tijd'
    %aaneengesloten is (geen deel in maart en een deel in oktober)
    if i == zpot+1 & Xmax > drempel &&...
            (24*datum(m-zB+zpot)-24*datum(m-zB-zpot)==2*zpot)    %NB: m-zB levert tijdstip evt. piek.
        golfnr              = golfnr + 1;
        index_all_venster(:,golfnr) = indextot(m-zB:m+zB);     %indices van tijdreeks binnen venster bepalen
        piekdatum(golfnr,1) = datum(m-zB);
        piekwaarde(golfnr,1)= Xmax;
        nr_golf(golfnr,1)   = golfnr;
        Y_bij_piek(golfnr,1)= Y(m-zB);
        Z_bij_piek(golfnr,1)= Z(m-zB);        
        jaargolf(golfnr,1)  = jaar(m-zB);
        maandgolf(golfnr,1) = maand(m-zB);
        daggolf(golfnr,1)   = dag(m-zB);
        uurgolf(golfnr,1)   = uur(m-zB);
    end
end

%testen op aanwezigheid geselecteerde golven
if length(piekdatum)==0
    golfkenmerken = [];
    golven = [];
    display('Er zijn geen golven die aan de selectiecriteria voldoen');
    return; %HIER WORDT DE HELE FUNCTIE VERLATEN
end
%Als length(piekdatum)>= 1 wordt verdergegaan met de rest


%bepalen rangnummers van X-golven
aantal_golven = length(nr_golf);
rangnr        = zeros(aantal_golven,1);    %initialisatie
[w,i]         = sort(piekwaarde);
index         = flipud(i);
for n = 1:length(index)
    rangnr(index(n,1)) = n;
end

%kenmerken geselecteerde golven in matrix opslaan
golfkenmerken = [nr_golf, jaargolf, maandgolf, daggolf, uurgolf, piekwaarde,...
    rangnr, Y_bij_piek, Z_bij_piek]; 


%==========================================================================
% Maken structure golven(i) met velden die staan voor:
% nr van piek, jaar van piek, maand van piek, dag van piek, uur van piek,
% piekwaarde, Y tijdens piekwaarde, Z tijdens piekwaarde, rang van piekwaarde,
% tijdrange van golf, X-data tijdens golf, Y-data tijdens golf, Z-data tijdens golf 
%==========================================================================

for i = 1:aantal_golven
    golven(i).nr            = nr_golf(i);
    golven(i).jaa           = jaargolf(i);
    golven(i).mnd           = maandgolf(i);
    golven(i).dag           = daggolf(i);
    golven(i).uur           = uurgolf(i);
    golven(i).piek          = piekwaarde(i);
    golven(i).Y_bij_piek    = Y_bij_piek(i);
    golven(i).Z_bij_piek    = Z_bij_piek(i);   
    golven(i).rang          = rangnr(i);
    golven(i).tijd          = (-zB:zB)';
    golven(i).Xdata         = Xuit(index_all_venster(:,i));
    golven(i).Ydata         = Yuit(index_all_venster(:,i));
    golven(i).Zdata         = Zuit(index_all_venster(:,i));    
end

%aantal_golven

