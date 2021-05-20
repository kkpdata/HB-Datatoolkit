function [golven_aanpas, standaardvorm] = opschaling(...
    golven,ref_niv,piekduur,nstapv,fig_golven_verbreed,fig_golven_rel,fig_opschaling);
%
%
% Aanpassing door Chris Geerse van module van Vincent Beijk.
% Versie met uitvoer deels in structure
%
%
%==========================================================================
%Dit programma doet de volgende zaken:
%Aanpassen van golven: piek/dal-verbreding en monotone voor- en
%achterflanken maken door nevenpieken tegen hoofdpiek te plakken.
%Met als resultaat: aangepaste golven (stijgende voor- en dalende achterflank)
%en gemiddelde standaardgolfgegevens.
%
%Input:
%golven: structure berekend door functie golfselectie.m met geselecteerde golven
%referentieniveau van waaraf wordt opgeschaald
%piekduur is duur waarmee pieken/dalen worden verbreed, 0< piekduur <1; default 0.9999.
%nstapv is aantal deelintervallen verticale discretisatie;
%   interval [0,1] wordt opgevuld met nstapv deelintervallen
%fig_golven_verbreed: indien 1 wel plaatjes verbrede golven, indien 0 dan niet
%fig_golven_rel: indien 1 wel plaatje relatieve golven, indien 0 dan niet
%fig_opschaling: indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet
%
%Output:
%golven_aanpas is een structure met de aangepaste golven;
%   velden: v, tvoor, tachter
%standaardvorm is een structure met de standaardvormgegevens (gemiddelde
%   van aangepaste golven);
%   velden: v, tvoor, tachter, fv (duur op niveau v)
%
%Calls:
%geen


%Golven moeten moeten op equidistant tijdrooster zijn gegeven, met
%piek in t = 0. (Denk ik)

%{
%==========================================================================
%Oude invoer tbv testen.
%==========================================================================

close all;
clear;

%==========================================================================
drempel = 180;     % variabele voor drempel waarde
zpot = 15;            % zichtduur
zB = 15;            %kies zB <= zpot, anders mogelijk crash (indien nevenpiek hoger dan geselecteerde)
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0<= piekduur <1.
nstapv = 10;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 1; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 1;      %indien 1 wel één plaatje met alle relatieve golven, indien 0 dan niet
fig_opschaling = 1;      %indien 1 wel plaatje standaardgolf uit opschaling, indien 0 dan niet

%==========================================================================
% inlezen van de data welke aangeleverd moet zijn in het voorgeschreven
% format
%==========================================================================
[jaar,maand,dag,data] = textread('Vechtafvoeren_60_83_met_uitbreiding.txt','%u %u %u %f','delimiter','','commentstyle','matlab');
%geef hier desgewenst andere selectie aan:
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
maand == 2 | maand == 3)&(jaar>=1998&jaar<=1999));

%In hoofdprogramma altijd beschikbare variabelen:
jaar = jaar(selectie);
maand = maand(selectie);
dag = dag(selectie);
data = data(selectie);
datum = datenum(jaar,maand,dag);

%[golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);
[golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);  %versie met structure

clear jaar maand dag data datum zpot zB drempel
%}


%==========================================================================
%Begin van de eigenlijke functie
%==========================================================================

golven_aanpas = []; %init
standaardvorm = []; %init
aantal_golven = max([golven.rang]);

%checken of sprake is van geldige golven voor opschalingsprocedure
geldig = 1; %init; geldig = 1 als alle golven geldig zijn, en 0 indien er niet-geldige golven zijn.
for i = 1:aantal_golven
    if max([golven(i).data]) > golven(i).piek
        geldig = 0;
        display('FOUT: Nevenpiek is hoger dan de centrale piek.');
        display(['Betreft o.a. piek ',num2str(golven(i).jaa)...
            ,'-',num2str(golven(i).mnd),'-',num2str(golven(i).dag)]);
    end
end
if geldig == 0
    display('Opschaling kan niet worden uitgevoerd!!');
end

%Volgende betreft de geldige golven.
if geldig ==1;
    %grootheden voor piekwaarden, lengte vectoren is aantal golven
    %initialisaties
    jaarp = zeros(aantal_golven,1);
    maandp = zeros(aantal_golven,1);
    dagp = zeros(aantal_golven,1);

    for i = 1:aantal_golven
        jaarp(i) = golven(i).jaa;
        maandp(i) = golven(i).mnd;
        dagp(i) = golven(i).dag;
    end

    theta1 = 1E-10;    %max(v) = 1 wordt tijdelijk verlaagd met theta1 omdat voor v=1 numerieke problemen
    theta2 = 1E-10;    %vermingvuldigingsfactor om te voorkomen dat lijnstukken exact horizontaal gaan lopen
    theta3 = 0.001;     %tijdas_nieuw wordt naar links en rechts uitgebreid met stap theta3, met afvoerwaarde 0

    %==========================================================================
    %interval [0,1] opvullen met nstapv deelintervallen met lengte stapv
    v = linspace(0,1,nstapv+1)';
    stapv = 1/(nstapv);
    v(numel(v)) = 1 - theta1;    %tijdelijke aanpassing omdat v = 1 numerieke problemen geeft.

    tijdas = [golven(1).tijd(1):golven(1).tijd(end)]';    %NB golven moeten allemaal zelfde tijdstappen hebben
    tijdas_nieuw = [tijdas(1)+0.5:tijdas(end)-0.5]';


    %======================================================================
    %====
    % stormverloop aanpassen om te voorkomen dat de toppen en dalen een duur 0 krijgen
    % een piekduur van een half uur geeft een beter beeld dan een topduur van 1
    % uur!!!
    %==========================================================================

    for nr = 1:aantal_golven;
        %    nr = 4;
        clear piek t_piek
        DG = golven(nr).data - ref_niv;   %data binnen actuele golf tov referentieniveau, vector 1dim
        ind = find(DG < 0);
        DG(ind) = 0;     %negatieve waarden verhogen naar 0

        %tbv testen dat horizontaal niveau goede verbrede duur krijgt OK
        %if nr == aantal_golven
        %   DG(10:11)= max(DG);
        %end
        golf_orig = [tijdas DG];
        for m = 2:length(tijdas)
            DG_nieuw(m-1,1) = (DG(m-1,1)+DG(m,1))/2;
        end
        golf_nieuw = [tijdas_nieuw DG_nieuw];   %kolom 1: -14.5, -13.5,..., 14.5; kolom 2: herziene afvoer
        %-------------------------------------------------
        % bepalen van de tijdstippen waarop de pieken en
        % dalen vallen
        %NB lengte van index_DG is totaal aantal pieken en dalen binnen actuele golf DG
        %(inclusief aantal tijdstippen met 'horizontale delen')
        %-------------------------------------------------
        i=1;
        for k = 2:length(DG)-1
            %waar -> top. gevallen (s=stijgend h=horizontaal d=dalend): sd, sh, hd, hh
            if DG(k-1,1) <= DG(k,1) & DG(k,1) >= DG(k+1,1)
                index_DG(i,1) = k;
                i = i+1;
                %waar -> dal. gevallen (s=stijgend h=horizontaal d=dalend): hs, dh, ds
            elseif DG(k-1,1) >= DG(k,1) & DG(k,1) <= DG(k+1,1)
                index_DG(i,1) = k;
                i = i+1;
            end
        end
        %-------------------------------------------------
        % pieken en dalen verbreden om topduur 0 te voorkomen
        %-------------------------------------------------
        for p=1:length(index_DG)
            piek = golf_orig(index_DG(p,1),2);
            t_piek = golf_orig(index_DG(p,1),1);
            piek_aangepast_voor(p,:) = [t_piek-(piekduur/2) piek];
            piek_aangepast_na(p,:)= [t_piek+(piekduur/2) piek];
            piek_aangepast = cat(1,piek_aangepast_voor,piek_aangepast_na);  %knoopt beide matrices aan elkaar (2-de komt onder eerste)
        end
        %-------------------------------------------------
        %Hier is de verbrede golf berekend, met dus verbrede pieken/dalen.
        golf_aangepast = sortrows(cat(1,piek_aangepast,golf_nieuw(:,1:2)),1); %juiste tijdsordening
        %-------------------------------------------------
        %PLAATJES MET ORIGINELE EN VERBREDE GOLVEN
        if fig_golven_verbreed == 1
            figure
            plot(tijdas,DG+ref_niv,'*-')
            hold on
            plot(golf_aangepast(:,1),golf_aangepast(:,2)+ref_niv,'r*-')     %Hier heeft de verbreding plaatsgevonden!!!
        end
        golf_op_index = find(golf_aangepast(:,1) < 0);
        golf_neer_index = find(golf_aangepast(:,1) > 0);
        golf_op = golf_aangepast(golf_op_index,:);  %voorflank: tijden (op tussenrooster) en afvoeren
        golf_neer = golf_aangepast(golf_neer_index,:);  %naflank: tijden (op tussenrooster) en afvoeren

        %normeren op 1 en toevoegen verticale flanken
        DG_rel_op = [golf_op(1,1)-theta3, 0; golf_op(:,1), golf_op(:,2)/max(golf_op(:,2))];
        DG_rel_neer = [golf_neer(:,1), golf_neer(:,2)/max(golf_neer(:,2)); golf_neer(end,1)+theta3, 0];
        DG_rel_op(:,2) = DG_rel_op(:,2)+(DG_rel_op(:,1)*theta2);   %voorkomen horizontale delen
        DG_rel_neer(:,2) = DG_rel_neer(:,2)-(DG_rel_neer(:,1)*theta2);
        if fig_golven_verbreed == 1
            figure      %voor alle aangepaste golven in één plaatje figure weglaten!!!
            plot_aangepast_op = plot(DG_rel_op(:,1),DG_rel_op(:,2),'*-');
            set(gca,'ylim',[0 1]);
            hold on
            plot_aangepast_neer = plot(DG_rel_neer(:,1),DG_rel_neer(:,2),'*-r');
        end
        %Bepalen van snijpunten golven met horizontale lijnen met onderlinge
        %afstanden gelijk aan stapv
        for o = 1:length(v)
            clear grens_punt grens grens_DG grens_t d_duur
            clear grens_punt_neer grens_neer grens_DG_neer grens_t_neer
            grens_punt(1,1) = tijdas(1,1);
            grens_punt_neer(1,1) = tijdas(end,1);
            for m = 1:length(DG_rel_op)-1
                grens_DG(m,:) = [DG_rel_op(m,2), DG_rel_op(m+1,2)];       %tweede kolom is eerste met 1 stap naar boven geschoven
                grens_t(m,:) = [DG_rel_op(m,1), DG_rel_op(m+1,1)];
                grens = [grens_DG grens_t];
            end
            for m = 1:length(DG_rel_neer)-1
                grens_DG_neer(m,:) = [DG_rel_neer(m,2) DG_rel_neer(m+1,2)];
                grens_t_neer(m,:) = [DG_rel_neer(m,1) DG_rel_neer(m+1,1)];
                grens_neer = [grens_DG_neer grens_t_neer];
            end
            i=1;
            for m = 1:length(grens_DG)
                domein = [grens_DG(m,1), grens_DG(m,2)]';
                if v(o,1) >= min(domein) & v(o,1) <= max(domein)
                    DG_span([1:2],1) = grens(m,[1:2])';
                    t_span([1:2],1) = grens(m,[3:4])';
                    lijn = sortrows([DG_span t_span],1);
                    %bepalen van snijpunt voorflank met horizontale lijn binnen
                    %interval 'domein'.
                    %grens_punt is 1dim vector met
                    %respectievelijke tijdstippen van snijpunten binnen
                    %voorflank; length(grenspunt) is aantal snijpunten.
                    %                grens_punt(i,:) = interp1q(lijn(:,1),lijn(:,2),v(o,1));%oud
                    grens_punt(i,1) = interp1q(lijn(:,1),lijn(:,2),v(o,1)); %nieuw
                    i = i+1;
                end
            end
            i=1;
            for m = 1:length(grens_DG_neer)
                domein_neer = [grens_DG_neer(m,1) grens_DG_neer(m,2)]';
                if v(o,1) >= min(domein_neer) & v(o,1) <= max(domein_neer)
                    DG_span_neer([1:2],1) = grens_neer(m,[1:2])';
                    t_span_neer([1:2],1) = grens_neer(m,[3:4])';
                    lijn_neer = sortrows([DG_span_neer t_span_neer],1);
                    %                grens_punt_neer(i,:) = interp1q(lijn_neer(:,1),lijn_neer(:,2),v(o,1)); %oud
                    grens_punt_neer(i,1) = interp1q(lijn_neer(:,1),lijn_neer(:,2),v(o,1));%nieuw
                    i = i+1;
                end
            end
            if fig_golven_verbreed == 1
                plot(grens_punt_neer,v(o,1) .* ones(size(grens_punt_neer)),'k.')
                hold on
                plot(grens_punt,v(o,1) .* ones(size(grens_punt)),'r.')
                hold on
            end
            %-------------------------------------------------
            % berekenen van de duur op het niveau v
            %-------------------------------------------------
            grens_punt(end+1,1) = 0;
            grens_punt_neer = [0;grens_punt_neer];
            if length(grens_punt) == 2
                duur_stap(o,nr) = abs(grens_punt(1,1))-abs(grens_punt(2,1));
            elseif length(grens_punt) > 2
                d_duur = reshape(grens_punt,2,length(grens_punt)/2);
                clear duur_s
                for k = 1:length(d_duur)
                    duur_s(k,1) = abs(d_duur(1,k))-abs(d_duur(2,k));
                end
                duur_stap(o,nr) = sum(duur_s);
            end
            if length(grens_punt_neer) == 2
                duur_stap_neer(o,nr) = abs(grens_punt_neer(1,1))-abs(grens_punt_neer(2,1));
            elseif length(grens_punt_neer) > 2
                d_duur_neer = reshape(grens_punt_neer,2,length(grens_punt_neer)/2);
                clear duur_s_neer
                for k = 1:length(d_duur_neer)
                    duur_s_neer(k,1) = abs(d_duur_neer(1,k))-abs(d_duur_neer(2,k));
                end
                duur_stap_neer(o,nr) = sum(duur_s_neer);
            end
        end
    end

    %if fig_golven_verbreed == 1 %weghalen plaatje als geen plaatje verbrede golven is gewenst
    %elseif  fig_golven_verbreed == 0
    %    close all;
    %end

    %==========================================================================
    %Per niveau v voor elke golf de duur in de voorflank en de duur in de
    %achterflank (achterflank is negatief getal en voorflank positief!!)
    %(NB volgens mij (Chris) moeten de tekens worden omgedraaid.
    %Eerst kolommen met de voorflanken en daarna de kolommen met
    %de achterflanken.

    %maak maximum van v exact gelijk aan 1
    v(numel(v)) = 1;    %duren voor v=1 blijven gelijk aan die voor oude max(v)
    %tijden nu met juiste tekens van de duren
    tvoor = [v, -duur_stap];
    tachter = [v, -duur_stap_neer];

    %==========================================================================
    %Vullen van structure 'golven_aanpas' met allerlei velden:
    %==========================================================================

    aantal_golven = length(golven);

    for i = 1:aantal_golven
        golven_aanpas(i).nr = golven(i).nr;
        golven_aanpas(i).jaa = golven(i).jaa;
        golven_aanpas(i).mnd = golven(i).mnd;
        golven_aanpas(i).dag = golven(i).dag;
        golven_aanpas(i).piek = golven(i).piek;
        golven_aanpas(i).rang = golven(i).rang;
        golven_aanpas(i).tijd = [tvoor(:,i+1); flipud(tachter(:,i+1))];   %tijdsverloop ongenormeerde golven
        golven_aanpas(i).data = [v; flipud(v)]*golven(i).piek;            %data corresponderend met tijdsverloop
        %nu volgen grootheden corresponderend bij genormeerde golven
        %    golven_aanpas(i).v = v;
        %    golven_aanpas(i).fv = tachter(:,i+1)-tvoor(:,i+1);
        %    golven_aanpas(i).tvoor_v = tvoor(:,i+1);
        %    golven_aanpas(i).tachter_v = tachter(:,i+1);
    end

    %==========================================================================
    %PLAATJES met aangepaste golven
    %==========================================================================


    %Tijdsverlopen 'monotone' genormeerde golven in één plaatje
    %close all;
    if fig_golven_rel == 1
        figure;
        for i = 1:aantal_golven
            plot(golven_aanpas(i).tijd, golven_aanpas(i).data/max([golven_aanpas(i).data]), 'b');
            grid on;
            hold on;
            xlim([tijdas(1) tijdas(end)]);
            ylim([0 1]);
            xlabel('tijd, dagen');
            ylabel('relatieve hoogte, [-]');
        end
    elseif  fig_golven_rel == 0
    end


    %==========================================================================
    % Bepalen gemiddelde vorm (opschalingsmethode)
    %==========================================================================

    standaardvorm.v = v;
    standaardvorm.tvoor = mean(tvoor(:,2:aantal_golven+1),2);  %mean(A,2) geeft gemiddelde per rij uit matrix A
    standaardvorm.tachter = mean(tachter(:,2:aantal_golven+1),2);
    standaardvorm.fv = standaardvorm.tachter - standaardvorm.tvoor;


    %Tijdsverloop opgeschaalde golf in plaatje
    %close all;
    if fig_opschaling == 1
        figure;
        plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
        grid on
        xlabel('tijd, dagen');
        ylabel('relatieve hoogte, [-]');
        title('standaardgolf uit opschaling');
    elseif  fig_opschaling == 0
    end
    display('Procedure ''opschaling'' is gerund');
end

%padnaam_uit = 'C:/Matlab/Vecht01/';
%save([padnaam_uit,'resultaat.txt'],'resultaat','-ascii')
