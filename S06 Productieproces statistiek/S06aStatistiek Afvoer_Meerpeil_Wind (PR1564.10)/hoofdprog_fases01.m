%==========================================================================
% Hoofdprogramma fases tussen IJssel, IJsselmeer en Vecht
% Door: Chris Geerse
%
% In een latere versie hiervan worden Olst en IJsm uit een ander bestand
% ingelezen.
% Daarbij bestaat ook de mogelijkheid Olst via de lags van Lobith te
% berekenen.
% Deze versie slechts bewaren voor testdoeleinden.
%
%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
padnaam_uit = 'c:/Matlab/Vecht_IJs_IJsm01/'
%save([padnaam_uit,'piek_datum_CG.txt'],'piek_datum','-ascii') is voorbeeldje
%==========================================================================
%==========================================================================
%Algemene invoer.
%==========================================================================
zpotI = 15;     %zichtduur voor selectie onafhankelijke pieken (piek op t is max op [t-zpot, t+zpot].
zBI = 15;       %halve breedte van geselecteerde tijdreeks (default=zpot). NB zB>zpot
%kan soms crash geven bij aanpassing van golven tbv
%opschaling. Default zB = zpot.
zD = 15;        %bij gegeven piek op tijd t wordt gezocht naar max van andere variabele in [t-zD,t+zD]
%default zD = zpotI

%Parameters voor plotten onafh (I) en afh (D) variabelen in multiplot met dubbele
%y-assen. (Geen parameters voor x-assen; die gaan automatisch.)
Npx = 3;     	%Npx:  aantal plaatjes in x-richting
Npy = 3;		%Npy:  aantal plaatjes in y-richting (totaal Npx*Npy plaatjes in multiplot).

%invoerfiles dagwaarden (jaar, maand, dag, data):
infileIJ = 'dagdebiet Olst 03jan60_23maa05.txt';
infileIJsm = 'meerpeil_ijsm_7604_dag_whj_mNAP.txt';
infileV = 'Vechtafvoeren_jan60_dec83_met_uitbr.txt';

%Keuzemogelijkheden:
%Onafh I    Afh D       geval
%IJ         IJsm        1
%V          IJsm        2
%IJ         V           3
geval = 1;  %GEEF HIER DE GEWENSTE KEUZE OP!

%==========================================================================
%Invoer beschouwde gevallen van on- en afhankelijke grootheden.
%==========================================================================
if geval == 1 %I = IJssel, D = IJsm
    drempelI = 800;       %drempelwaarde voor selectie pieken I

    %Parameters voor plotten onafh (I) en afh (D) variabelen in multiplot met dubbele
    %y-assen. (Geen parameters voor x-assen; die gaan automatisch.)
    SImn = 0;		%SImn: min van schaal onafh var
    SIst = 500;	    %SIst: stap in schaal onafh var
    SImx = 2000;	%SImx: max van schaal onafh var
    SDmn = -0.5;	%SDmn: min van schaal afh var
    SDst = 0.25;	%SDst: stap in schaal afh var
    SDmx = 0.5;	    %SDmx: max van schaal afh var

    %==========================================================================
    %Inlezen data onafhankelijke variabele (I)
    %==========================================================================
    [jaarI,maandI,dagI,dataI] = textread(infileIJ,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    datumI = datenum(jaarI,maandI,dagI);        %seriële datum

    %geef hier de gewenste periode aan:
    bejI = 1981; bemI = 1; bedI = 1;
    eijI = 2005; eimI = 12; eidI = 31;
    bedatumI = datenum(bejI,bemI,bedI); eidatumI = datenum(eijI,eimI,eidI);

    %==========================================================================
    %Inlezen afhankelijk variabele (D)
    %==========================================================================
    [jaarD,maandD,dagD,dataD] = textread(infileIJsm,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    datumD = datenum(jaarD,maandD,dagD);

elseif geval == 2 %I = Vecht, D = IJsm
    drempelI = 130;
    SImn = 0; SIst = 50; SImx = 400;
    SDmn = -0.5; SDst = 0.25; SDmx = 0.5;

    [jaarI,maandI,dagI,dataI] = textread(infileV,'%f %f %f %f','delimiter','','commentstyle','matlab');
    datumI = datenum(jaarI,maandI,dagI);        %seriële datum
    bejI = 1960; bemI = 1; bedI = 1;
    eijI = 2005; eimI = 12; eidI = 31;
    bedatumI = datenum(bejI,bemI,bedI); eidatumI = datenum(eijI,eimI,eidI);

    [jaarD,maandD,dagD,dataD] = textread(infileIJsm,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    datumD = datenum(jaarD,maandD,dagD);

elseif geval == 3 %I = IJssel, D = Vecht
    drempelI = 800;
    SImn = 0; SIst = 500; SImx = 2000;
    SDmn = 0; SDst = 50; SDmx = 400;

    [jaarI,maandI,dagI,dataI] = textread(infileIJ,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    datumI = datenum(jaarI,maandI,dagI);        %seriële datum
    bejI = 1981; bemI = 1; bedI = 1;
    eijI = 2005; eimI = 12; eidI = 31;
    bedatumI = datenum(bejI,bemI,bedI); eidatumI = datenum(eijI,eimI,eidI);

    [jaarD,maandD,dagD,dataD] = textread(infileV,'%f %f %f %f','delimiter','','commentstyle','matlab');
    datumD = datenum(jaarD,maandD,dagD);

end



%==========================================================================
%==========================================================================
%Selectie pieken I en algemene (globaal te gebruiken) variabelen.
%==========================================================================
selectieI = find(( maandI == 10 | maandI == 11 | maandI == 12 | maandI == 1 |...
    maandI == 2 | maandI == 3)&(datumI >= bedatumI & datumI <= eidatumI));

jaarI = jaarI(selectieI); maandI = maandI(selectieI); dagI = dagI(selectieI);
dataI = dataI(selectieI);
datumI = datenum(jaarI,maandI,dagI);
dagnrI = (1:numel(dataI))';

%==========================================================================
%Selecteren van golven I uit datareeks en bepalen geldige puntenparen (I,D)
%==========================================================================
[golfkenmerkenI, golvenI] = golfselectie(drempelI,zpotI,zBI,jaarI,maandI,dagI,dataI);
%golfkenmerken: matrix met gegevens van de golven
%1xaantal_golven struct array with fields:
%    nr
%    jaa
%    mnd
%    dag
%    piek
%    rang
%    tijd
%    data
%

[paren] = puntenparen(golvenI,zD,datumD, dataD);
%voor aantal_golven = N is dit een 1xN struct array with fields:
%     dtmI: seriële datum onafh piekwaarde I
%    dtmDx: seriële datum Dx ten tijde maximum afh var
%         I: onafh piekwaarde
%        Dx: maximum afh var
%        Dr: waarde afh var ten tijde van piek I
%[[paren.dtmI]' [paren.dtmDx]' [paren.I]' [paren.Dx]' [paren.Dr]']

%==========================================================================
% Tbv goede plaatjes in Word.
%==========================================================================
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)

%==========================================================================
% Plotten van geselecteerde golven I en bijbehorende verlopen D.
%==========================================================================
plot_verloopID(golvenI, paren, zD, datumD, dataD,...
    Npx, Npy, SImn, SIst, SImx, SDmn, SDst, SDmx);

%==========================================================================
% Plaatjes en berekeningen fases e.d.
%==========================================================================

fase_tovI = [paren.dtmDx] - [paren.dtmI];
Dx_minus_Dr = [paren.Dx]-[paren.Dr];

NparenI = numel([paren.I]);
Nparen_Dx_minus_Dr = numel([Dx_minus_Dr]);
gemfase_tovI_abs = mean(abs(fase_tovI));
gemfase_tovI_exabs = mean(fase_tovI);
gempiekD = mean([paren.Dx]);
gemDx_minus_Dr = mean(Dx_minus_Dr);
medDx_minus_Dr = median(Dx_minus_Dr);

%Berekenen van representatieve faseverschuiving:
B1=30;   %basisduur in dagen
if geval == 1 | geval ==2
    refniv1 = -0.4;
    b1=4;    %topduur IJsselmeergolven in dagen tbv faseberekening
elseif geval ==3
    refniv1 = 0;
    b1=2;    %topduur Vechtgolven in dagen tbv faseberekening
end
fase_repr = b1/2+medDx_minus_Dr/(gempiekD-refniv1)*(B1-b1)/2;

display(['drempel onafh var = ',num2str(drempelI),' [eenheid van I]']);
display(['aantal puntenparen = ',num2str(NparenI),' [-]']);
display(['gemiddelde van absoluut genomen fases tov onafh var I = ',num2str(gemfase_tovI_abs),' dagen']);
display(['gemiddelde van fases tov onafh var I = ',num2str(gemfase_tovI_exabs),' dagen']);
display(['gemiddelde van maximum afh var D = ',num2str(gempiekD),' [eenheid van D]']);
display(['gemiddelde van Dx - Dr = ',num2str(gemDx_minus_Dr),' [eenheid van D]']);
display(['mediaan van Dx - Dr = ',num2str(medDx_minus_Dr),' [eenheid van D]']);
display(['representatieve fase = ',num2str(fase_repr),' dagen]']);

%Wegschrijven puntenparen
data_paren = [[paren.I]',[paren.Dx]'];
if geval ==1
    save([padnaam_uit,'paren_IJ_IJsm.txt'],'data_paren','-ascii')
    display('paren_IJ_IJsm.txt gesaved')
end


%==========================================================================
% Plaatje puntenparen
%==========================================================================
close all
figure
plot([paren.I],[paren.Dx],'o');
hold on
grid on
plot([paren.I],[paren.Dr],'*');

if geval == 1 %I = IJssel, D = IJsm
    cltxt  = {'meerpeilmaximum','meerpeil tijdens piekafvoer'};
    ttxt  = 'Puntenparen IJssel en IJsselmeer';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'meerpeil, m+NAP';
    Xtick = 0:200:2000;
    Ytick = -0.4:0.1:0.6;
elseif geval == 2 %I = Vecht, D = IJsm
    cltxt  = {'meerpeilmaximum','meerpeil tijdens piekafvoer'};
    ttxt  = 'Puntenparen Vecht en IJsselmeer';
    xtxt  = 'afvoer Vecht, m3/s';
    ytxt  = 'meerpeil, m+NAP';
    Xtick = 0:50:400;
    Ytick = -0.4:0.1:0.6;
elseif geval == 3 %I = IJssel, D = Vecht
    cltxt  = {'Vechtmaximum','Vechtafvoer tijdens piekafvoer IJssel'};
    ttxt  = 'Puntenparen IJssel en Vecht';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'afvoer Vecht, m3/s';
    Xtick = 0:200:2000;
    Ytick = 0:50:400;
end
ltxt  = char(cltxt);
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%{
%==========================================================================
% Plaatje fases tegen onafhankelijke variabele
%==========================================================================
figure
plot([paren.I], fase_tovI,'+')
ltxt= [];
if geval == 1 %I = IJssel, D = IJsm
    ttxt  = 'fase IJsselmeer tov IJsselafvoer';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'fase, dagen';
    Xtick = 0:200:2000;
    Ytick = min(fase_tovI)-2:5:max(fase_tovI)+5;
elseif geval == 2 %I = Vecht, D = IJsm
    ttxt  = 'fase IJsselmeer tov Vechtafvoer';
    xtxt  = 'afvoer Vecht, m3/s';
    ytxt  = 'fase, dagen';
    Xtick = 0:50:400;
    Ytick = min(fase_tovI)-2:5:max(fase_tovI)+5;
elseif geval == 3 %I = IJssel, D = Vecht
    ttxt  = 'fase Vecht tov IJsselafvoer';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'fase, dagen';
    Xtick = 0:200:2000;
    Ytick = min(fase_tovI)-2:5:max(fase_tovI)+5;
end
grid on
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
%==========================================================================
% Plaatje Dx - Dr tegen onafhankelijke variabele
%==========================================================================
figure
plot([paren.I], Dx_minus_Dr,'+')
ltxt= [];
if geval == 1 %I = IJssel, D = IJsm
    ttxt  = 'verschil in meerpeilen tegen IJsselafvoer';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'verschil, m+NAP';
    Xtick = 0:200:2000;
    Ytick = 0:0.05:max(Dx_minus_Dr)+0.05;
elseif geval == 2 %I = Vecht, D = IJsm
    ttxt  = 'verschil in meerpeilen tegen Vechtafvoer';
    xtxt  = 'afvoer Vecht, m3/s';
    ytxt  = 'verschil, m+NAP';
    Xtick = 0:50:400;
    Ytick = 0:0.05:max(Dx_minus_Dr)+0.05;
elseif geval == 3 %I = IJssel, D = Vecht
    ttxt  = 'verschil in Vechtafvoeren tegen IJsselafvoer';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'verschil, m3/s';
    Xtick = 0:200:2000;
    Ytick = 0:10:max(Dx_minus_Dr)+10;
end
grid on
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%}