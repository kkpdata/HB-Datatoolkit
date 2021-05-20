function [golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);
%
% Aanpassing door Chris Geerse van module van Vincent Beijk.
% Versie met uitvoer in structure
%
%
%==========================================================================
% Dit programma selecteert met zichtduur zpot die waarden uit een reeks die boven de
% aangegeven drempel uitkomen en zoekt hier omheen de
% gemeten golfvorm met naar links en rechts één duur zB.
% Het programma loopt met een venster (2*zpot + 1)
% over de gehele reeks en zoekt de hoogste waarde binnnen het venster.
% Slechts vensters - bestaande uit opeenvolgende dagen -
% die geheel binnen de reeks vallen worden beschouwd.
%
%Input:
%drempel is ondergrens in de selectie van de golven
%zpot is zichtduur in selectie van pieken
%zB is halve vensterduur van geselecteerde tijdreeks van pieken
%jaar behorende bij waarneming
%maand behorende bij waarneming
%dag behorende bij waarneming
%data bijvoorbeeld afvoeren in m3/s
%
%Output:
%golfkenmerken is matrix met kolommen met: nr_golf, jaar waarin piek, maand waarin piek,
%dag waarin piek, piekwaarde en rangnummer piekwaarde (hoogste = 1).
%Lengte kolommen is aantal golven.
%
%golven is een structure met velden:
%nr, jaa, mnd, dag, piek, rang, tijd, afv (datumvelden horen bij de
%oiekwaarde van de golf);
%tijd heeft verloop -zB,..., -1, 0, 1,...,zB
%data geeft met de tijdstippen corresponderende data (bijvoorbeeld een
%afvoer)
%
%WAARSCHUWING:
%AAN BEGIN EN EIND VAN DE REEKS KUNNEN NULLEN ZIJN TOEGEVOEGD INDIEN zB > zpot.
%

%==========================================================================
datum = datenum(jaar,maand,dag);
%Breidt data uit met zB nullen aan begin en eind (nodig om zB niet van invloed
%te laten zijn op aantal geselecteerde pieken
nullen = zeros(zB,1);
data_uit = [nullen; data; nullen];
index_tot_uit = [1:length(data_uit)]';

piekdatum = []; %initialisatie
golfnr = 0; %initialisatie
for m = zB+zpot+1:(length(data_uit)-zB-zpot)
    [datamax, i] = max(data_uit(m-zpot:m+zpot));    %NB: alleen het eerste maximum krijgt een i toegekend. 
                                                    %Hierdoor wordt bij 2 grootste waarden binnen de zichtduur alleen de eerste meegenomen!

    %criterium voor selectie.
    %voorwaarde is tevens dat venster in de 'werkelijke tijd'
    %aaneengesloten is (geen deel in maart en een deel in oktober)
    if i == zpot+1 & datamax > drempel &...
            (datum(m-zB+zpot)-datum(m-zB-zpot)==2*zpot)    %NB: m-zB levert tijdstip evt. piek.
        golfnr                        = golfnr + 1;
        index_all_venster(:,golfnr)   = index_tot_uit(m-zB:m+zB);     %indices van tijdreeks binnen venster bepalen
        piekdatum(golfnr,1)           = datum(m-zB);
        piekwaarde(golfnr,1)          = datamax;
        nr_golf(golfnr,1)             = golfnr;
        jaargolf(golfnr,1)            = jaar(m-zB);
        maandgolf(golfnr,1)           = maand(m-zB);
        daggolf(golfnr,1)             = dag(m-zB);
    end
end

%testen op aanwezigheid geselecteerde golven
if length(piekdatum)==0
    golfkenmerken = []
    golven = []
    display('Er zijn geen golven die aan de selectiecriteria voldoen');
    return; %HIER WORDT DE HELE FUNCTIE VERLATEN
end


%Als length(piekdatum)>= 1 verdergaan met de rest
golfkenmerken = [nr_golf, jaargolf, maandgolf, daggolf, piekwaarde]; %kenmerken geselecteerde golven

%extra kolom met rangnummers toevoegen aan golfkenmerken
aantal_golven = length(nr_golf);
rangnr = zeros(aantal_golven,1);    %initialisatie
[w,i] = sort(piekwaarde);
index = flipud(i);
for n = 1:length(index)
    %    golfkenmerken(index(n,1),6) = n;
    rangnr(index(n,1)) = n;
end
golfkenmerken(:,6) = rangnr;


%==========================================================================
%Maken structure golven(i) met velden nr, jaar van piek, maand van piek, dag van piek,
%piekwaarde, rang, tijd, data
%==========================================================================

for i = 1:aantal_golven
    golven(i).nr = nr_golf(i);
    golven(i).jaa = jaargolf(i);
    golven(i).mnd = maandgolf(i);
    golven(i).dag = daggolf(i);
    golven(i).piek = piekwaarde(i);
    golven(i).rang = rangnr(i);
    golven(i).tijd = (-zB:zB)';
    golven(i).data = data_uit(index_all_venster(:,i));
end

