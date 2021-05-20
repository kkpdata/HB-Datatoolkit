function [stormkenmerken, stormen] = stormselectie(drempel,zpot,zB,jaar,maand,dag,uur,u,r,r1,r2,trshift);
%
% Aanpassing door Chris Geerse van module van Vincent Beijk.
% Versie met uitvoer in structure
%
%Aanpassing op 29 sep 2006 door Chris Geerse:
%selectie ivm r1 en r2 aangepast op zo'n manier dat bijvoorbeeld
%r1 = 345 en r2 = 15 graden mogelijk wordt.
%
% Opmerking:
% Als het maximum wordt gevolgd door een uurwaarde met dezelfde grootte,
% wordt alleen de eerste waarde geselecteerd.
% Bijvoorbeeld voor z = 2: u(t) = 20, 22.3, 23.6, 23.6, 18, 16.4, dan wordt slechts
% één storm geselecteerd, namelijk 20, 22.3, 23.6, 23.6, 18.
%
%==========================================================================
% Dit programma selecteert met zichtduur zpot die waarden uit de u-reeks die boven de
% aangegeven drempel uitkomen en zoekt hier omheen de
% gemeten stormvorm met naar links en rechts één duur zB.
% Het programma loopt met een venster (2*zpot + 1)
% over de gehele reeks en zoekt de hoogste waarde binnnen het venster.
% Slechts vensters - bestaande uit opeenvolgende dagen -
% die geheel binnen de reeks vallen worden beschouwd.
% Het is ook mogelijk een deelselectie te doen door alleen stormen te 
% selecteren waarvan op tijd trshift ná het tijdstip waarop de 
% piek valt de richting ligt tussen r1 en r2.
%
%Input:
%drempel is ondergrens in de selectie van de stormen
%zpot is zichtduur in selectie van pieken
%zB is halve vensterduur van geselecteerde tijdreeks van pieken
%jaar behorende bij waarneming
%maand behorende bij waarneming
%dag behorende bij waarneming
%u is windsnelheid
%r is windrichting
%r1 ondergrens voor te selecteren piekrichtingen op tijd trshift na
%piektijdstip.
%r2 bovengrens voor te selecteren piekrichtingen  op tijd trshift na
%piektijdstip.
%trshift: tijdsduur na piektijdstip waarop gekeken wordt of richting r_trshift ligt tussen
%r1 en r2 (r1 <= r_trshift <= r2). NB: trshift <= zpot
%
%Output:
%stormkenmerken is matrix met kolommen met: nr_storm, jaar waarin piek, maand waarin piek,
%dag waarin piek, piekwaarde, richting tijdens stormpiek en rangnummer piekwaarde (hoogste = 1).
%Lengte kolommen is aantal stormen.
%
%stormen is een structure met velden:
%nr, jaa, mnd, dag, piek, rpiek, rang, tijd, data, rdata
%tijd heeft verloop -zB,..., -1, 0, 1,...,zB
%data geeft met de tijdstippen corresponderende windsnelheidsdata
%rdata geeft met de tijdstippen corresponderende richtingsdata
%
%WAARSCHUWING:
%AAN BEGIN EN EIND VAN DE REEKS KUNNEN 'MINUS NEGENS' ZIJN TOEGEVOEGD INDIEN zB > zpot.
%DAT GEBEURT ALS OP EXTRA TIJDSTIPPEN GEEN DATA AANWEZIG ZIJN.
%
%
%{
%==========================================================================
%Oude invoer tbv testen.
%==========================================================================
clear
close all
%==========================================================================
%==========================================================================
%Invoerparameters
%==========================================================================
%Parameters voor selectie stormen
%==========================================================================
drempel = 22;        % variabele voor drempel waarde
zpot = 20;            % zichtduur voor selectie pieken
zB = 20;              %halve breedte van geselecteerde tijdreeks (default=zpot) NB zB>zpot kan soms crash geven

%==========================================================================
%Inlezen data
%==========================================================================
%[jjjjmmdd,uur,r,qdd,snelheid,upd] = textread('s240_test.asc','%u %u %u %u %u %u','delimiter',',','headerlines',22);
[jjjjmmdd,uur,r,qdd,snelheid,upd] = textread('s240.asc','%u %u %u %u %u %u','delimiter',',','headerlines',22);
%s240.asc: 1 maart 1950 (vanaf uur 1) t/m 1 jan 2003 (t/m uur 24)
u = snelheid/10;    %omrekening van dm/s naar m/s
jaar = floor(jjjjmmdd/10000);
maand = floor((jjjjmmdd-jaar*10000)/100);
dag = floor(jjjjmmdd-jaar*10000-maand*100);
datum = datenum(jaar,maand,dag,uur,0,0);        %seriële datum

%geef hier de gewenste selectie aan:
bej = 1950;
bem = 3;
bed = 1;
beu = 1;
eij = 2005;
eim = 1;
eid = 1;
eiu = 24
bedatum = datenum(bej,bem,bed,beu,0,0);
eidatum = datenum(eij,eim,eid,eiu,0,0);
selectie = find(datum >= bedatum & datum <= eidatum);

%==========================================================================
%Berekenen van algemene (globaal te gebruiken) variabelen
%==========================================================================
jaar = jaar(selectie);
maand = maand(selectie);
dag = dag(selectie);
uur = uur(selectie);
r = r(selectie);
u = u(selectie);
datum = datenum(jaar,maand,dag,uur,0,0);
casenr = (1:numel(u))';

%plot(casenr,u)
%grid on

%Haal weg bij grote dataset!!!!!!!!!!!!!!!!!!!!!!!
%[datum, jaar, maand, dag, uur, r, 10*u]
%[jaar, maand, dag, uur, r, 10*u]

plot(casenr,u,casenr,r);
[AX,H1,H2] = plotyy(casenr,u,casenr,r,'plot');
grid on

r1 = 310;
r2 = 360;
%}

%==========================================================================
%Hier begint de eigenlijke functie
%==========================================================================
datum = datenum(jaar,maand,dag,uur,0,0);
%Breidt u-data en r-data uit met zB -9's aan begin en eind (nodig om zB niet van invloed
%te laten zijn op aantal geselecteerde pieken
negens = 9*ones(zB,1);
uuit = [-1*negens; u; -1*negens];
ruit = [-1*negens; r; -1*negens];
indextot = [1:length(uuit)]';

piekdatum = []; %initialisatie
stormnr = 0; %initialisatie

% %OUD
% for m = zB+zpot+1:(length(uuit)-zB-zpot)
%     [umax, i] = max(uuit(m-zpot:m+zpot));
% 
%     %criterium voor selectie.
%     %voorwaarde is tevens dat venster in de 'werkelijke tijd'
%     %aaneengesloten is (geen deel in maart en een deel in oktober)
%     if i == zpot+1 & umax > drempel &...
%             (24*datum(m-zB+zpot)-24*datum(m-zB-zpot)==2*zpot)    %NB: m-zB levert tijdstip evt. piek.
%         if (r(m-zB+trshift) >= r1 & r(m-zB+trshift) <= r2)
%             stormnr = stormnr + 1;
%             index_all_venster(:,stormnr) = indextot(m-zB:m+zB);     %indices van tijdreeks binnen venster bepalen
%             piekdatum(stormnr,1) = datum(m-zB);
%             piekwaarde(stormnr,1) = umax;
%             nr_storm(stormnr,1) = stormnr;
%             rpiek(stormnr,1) = r(m-zB);
%             jaarstorm(stormnr,1) = jaar(m-zB);
%             maandstorm(stormnr,1) = maand(m-zB);
%             dagstorm(stormnr,1) = dag(m-zB);
%             uurstorm(stormnr,1) = uur(m-zB);
%         end
%     end
% end

%Aanpassing 29 sep 2006.
for m = zB+zpot+1:(length(uuit)-zB-zpot)
    [umax, i] = max(uuit(m-zpot:m+zpot));       %NB: als umax 2 keer voorkomt wordt door max alleen de index van het eerste maximum gegeven!!!

    %criterium voor selectie.
    %voorwaarde is tevens dat venster in de 'werkelijke tijd'
    %aaneengesloten is (geen deel in maart en een deel in oktober)
    if i == zpot+1 & umax > drempel &...
            (24*datum(m-zB+zpot)-24*datum(m-zB-zpot)==2*zpot)    %NB: m-zB levert tijdstip evt. piek.
        rr = r(m-zB+trshift);   %richting waarmee de selectie plaatsvindt  
        if (r1<=r2 & rr>=r1 & rr<=r2)|...
                ( r1>r2 & ( (rr >= r1 & rr <= 360)|(rr >= 0 & rr <= r2) ) )
            stormnr = stormnr + 1;
            index_all_venster(:,stormnr) = indextot(m-zB:m+zB);     %indices van tijdreeks binnen venster bepalen
            piekdatum(stormnr,1) = datum(m-zB);
            piekwaarde(stormnr,1) = umax;
            nr_storm(stormnr,1) = stormnr;
            rpiek(stormnr,1) = r(m-zB);
            jaarstorm(stormnr,1) = jaar(m-zB);
            maandstorm(stormnr,1) = maand(m-zB);
            dagstorm(stormnr,1) = dag(m-zB);
            uurstorm(stormnr,1) = uur(m-zB);
        end
    end
end


%testen op aanwezigheid geselecteerde stormen
if length(piekdatum)==0
    stormkenmerken = []
    stormen = []
    display('Er zijn geen stormen die aan de selectiecriteria voldoen');
    return; %HIER WORDT DE HELE FUNCTIE VERLATEN
end


%Als length(piekdatum)>= 1 wordt verdergegaan met de rest
stormkenmerken = [nr_storm, jaarstorm, maandstorm, dagstorm, uurstorm, 10*piekwaarde, rpiek]; %kenmerken geselecteerde stormen, met tbv display u in dm/s

%extra kolom met rangnummers toevoegen aan stormkenmerken
aantal_stormen = length(nr_storm);
rangnr = zeros(aantal_stormen,1);    %initialisatie
[w,i] = sort(piekwaarde);
index = flipud(i);
for n = 1:length(index)
    rangnr(index(n,1)) = n;
end
stormkenmerken(:,size(stormkenmerken,2)+1) = rangnr;


%==========================================================================
%Maken structure stormen(i) met velden nr, jaar van piek, maand van piek, dag van piek,
%piekwaarde, rang, tijd, u
%==========================================================================

for i = 1:aantal_stormen
    stormen(i).nr = nr_storm(i);
    stormen(i).jaa = jaarstorm(i);
    stormen(i).mnd = maandstorm(i);
    stormen(i).dag = dagstorm(i);
    stormen(i).uur = uurstorm(i);
    stormen(i).piek = piekwaarde(i);
    stormen(i).rpiek = rpiek(i);
    stormen(i).rang = rangnr(i);
    stormen(i).tijd = (-zB:zB)';
    stormen(i).data = uuit(index_all_venster(:,i));
    stormen(i).rdata = ruit(index_all_venster(:,i));
end

%aantal_stormen

