%function [v, tvoor, tachter] = aanpassing_golfverloop(...
 %   jaar,maand,dag,data,drempel,zpot,zB,ref_niv,piekduur,nstapv,...
  %  fig_golven_verbreed,fig_golven_rel);
%Aanpassing door Chris Geerse van module door Vincent Beijk
%XXXXXXXX
%Calls:
%golfselectie(drempel,z,jaar,maand,dag,data)


close all;
clear;

%==========================================================================
drempel = 180;     % variabele voor drempel waarde 
zpot = 15;            % zichtduur 
zB = 23;
ref_niv = 0;       %referentieniveau van waaraf wordt opgeschaald
piekduur = 0.9999; %duur waarmee pieken/dalen worden verbreed, 0<= piekduur <1.
nstapv = 100;      %interval [0,1] wordt opgevuld met nstapv deelintervallen
fig_golven_verbreed = 0; %indien 1 wel plaatjes verbrede golven, indien 0 dan niet
fig_golven_rel = 1;      %indien 1 wel plaatje relatieve golven, indien 0 dan niet

%==========================================================================
% inlezen van de data welke aangeleverd moet zijn in het voorgeschreven
% format
%==========================================================================
[jaar,maand,dag,data] = textread('Vechtafvoeren_60_83_met_uitbreiding.txt','%u %u %u %f','delimiter','','commentstyle','matlab');
%geef hier desgewenst andere selectie aan:
selectie = find(( maand == 10 | maand == 11 | maand == 12 | maand == 1 |...
    maand == 2 | maand == 3)&(jaar>=1962&jaar<=1962));

%In hoofdprogramma altijd beschikbare variabelen:
jaar = jaar(selectie);
maand = maand(selectie);
dag = dag(selectie);
data = data(selectie);
datum = datenum(jaar,maand,dag);



%==========================================================================
%Begin van de eigenlijke functie
%==========================================================================
datum = datenum(jaar,maand,dag);
[golfkenmerken, golven] = golfselectie(drempel,zpot,zB,jaar,maand,dag,data);

aantal_golven = length(golfkenmerken(:,1));
jaarp = golfkenmerken(:,2); %grootheden voor piekwaarden, lengte vectoren is aantal golven
maandp = golfkenmerken(:,3);
dagp = golfkenmerken(:,4);
piekdatum = datenum(jaarp,maandp,dagp);    %datum als getal, lengte vector is aantal golven

theta1 = 1E-10;    %max(v) = 1 wordt tijdelijk verlaagd met theta1 omdat voor v=1 numerieke problemen
theta2 = 1E-10;    %vermingvuldigingsfactor om te voorkomen dat lijnstukken exact horizontaal gaan lopen

%==========================================================================
tind = (1:length(data))';       %tbv testen uitvoer hier ingevoerd
%{
WEG
i_piek = (1:aantal_golven)';    %initialisatie
for n = 1:aantal_golven
    i_piek(n,1) = find(datum == piekdatum(n,1));
end
%}
data_ref_niv = data - ref_niv;
i = find(data_ref_niv(:,1) < 0);            
data_ref_niv(i,1) = 0;     %negatieve waarden verhogen naar 0

%interval [0,1] opvullen met nstapv deelintervallen met lengte stapv

v = linspace(0,1,nstapv+1)';   
stapv = 1/(nstapv);
v(numel(v)) = 1 - theta1;    %tijdelijke aanpassing omdat v = 1 numerieke problemen geeft.
%{
stapv = 1/(nstapv);
v=(0:stapv:1-stapv);
%}

tijdas = [-zB:zB]';
tijdas_nieuw = [-zB+0.5:zB-0.5]';



%==========================================================================
% stormverloop aanpassen om te voorkomen dat de toppen en dalen een duur 0 krijgen
% een piekduur van een half uur geeft een beter beeld dan een topduur van 1
% uur!!! 
%==========================================================================

for nr = 1:aantal_golven;
%    nr = 4;
    clear piek t_piek
    DG = golven(:, nr+1) - ref_niv;   %data binnen actuele golf tov referentieniveau
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
    figure
    plot(tijdas,DG+ref_niv,'*-')
    hold on
    plot(golf_aangepast(:,1),golf_aangepast(:,2)+ref_niv,'r*-')     %Hier heeft de verbreding plaatsgevonden!!!
    golf_op_index = find(golf_aangepast(:,1) < 0);
    golf_neer_index = find(golf_aangepast(:,1) > 0);
    golf_op = golf_aangepast(golf_op_index,:);  %voorflank: tijden (op tussenrooster) en afvoeren
    golf_neer = golf_aangepast(golf_neer_index,:);  %naflank: tijden (op tussenrooster) en afvoeren

    %normeren op 1 en toevoegen verticale flanken
    DG_rel_op = [golf_op(1,1)-stapv, 0; golf_op(:,1), golf_op(:,2)/max(golf_op(:,2))];
    DG_rel_neer = [golf_neer(:,1), golf_neer(:,2)/max(golf_neer(:,2)); golf_neer(end,1)+stapv, 0];
    DG_rel_op(:,2) = DG_rel_op(:,2)+(DG_rel_op(:,1)*theta2);   %voorkomen horizontale delen
    DG_rel_neer(:,2) = DG_rel_neer(:,2)-(DG_rel_neer(:,1)*theta2);
    figure      %voor alle aangepaste golven in één plaatje figure weglaten!!!
    plot_aangepast_op = plot(DG_rel_op(:,1),DG_rel_op(:,2),'*-');
    set(gca,'ylim',[0 1]);    
    hold on
    plot_aangepast_neer = plot(DG_rel_neer(:,1),DG_rel_neer(:,2),'*-r'); 

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
        plot(grens_punt_neer,v(o,1) .* ones(size(grens_punt_neer)),'k.')
        hold on
        plot(grens_punt,v(o,1) .* ones(size(grens_punt)),'r.')
        hold on
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

%==========================================================================
%Per niveau v voor elke golf de duur in de voorflank en de duur in de
%achterflank (achterflank is negatief getal en voorflank positief!!)
%(NB volgens mij (Chris) moeten de tekens worden omgedraaid.
%Eerst kolommen met de voorflanken en daarna de kolommen met
%de achterflanken.
%OUD
%resultaat = [duur_stap duur_stap_neer]; 

%maak maximum van v exact gelijk aan 1
v(numel(v)) = 1;    %duren voor v=1 blijven gelijk aan die voor oude max(v)
%tijden nu met juiste tekens van de duren
tvoor = [v, -duur_stap];
tachter = [v, -duur_stap_neer];

%==========================================================================
%PLAATJES
%==========================================================================
if fig_golven_verbreed == 1
elseif  fig_golven_verbreed == 0
    close all;
end

%Tijdsverlopen 'monotone' golven in één plaatje
%close all;
if fig_golven_rel == 1
    figure;
for i = 1:aantal_golven
    plot(tvoor(:,i+1), v,'b', tachter(:,i+1), v, 'b');
    grid on;
    hold on;
    xlim([-zB zB]);
    ylim([0 1]);
    xlabel('tijd, dagen');
    ylabel('relatieve hoogte, [-]');
end
elseif  fig_golven_verbreed == 0
end

%==========================================================================
%padnaam_uit = 'C:/Matlab/Vecht01/';
%save([padnaam_uit,'resultaat.txt'],'resultaat','-ascii')

display('Procedure ''aanpassing_golfverloop'' is gerund');

