%==========================================================================
% Hoofdprogramma fases tussen IJssel, IJsselmeer en Vecht
% Door: Chris Geerse
%
%==========================================================================
clear
close all
%==========================================================================
% Uitvoer wegschrijven in
padnaam_uit = 'd:\users\geerse\Matlab\Stat_Rivieren_Meren_Wind/';
%padnaam_uit = 'Y:/Matlab/Vecht_IJs_IJsm_Sch01/';
%save([padnaam_uit,'piek_datum_CG.txt'],'piek_datum','-ascii') is voorbeeldje

%==========================================================================
%==========================================================================
%Algemene invoer.
%==========================================================================
%OPMERKING: zpotI, zBI, zD moeten (vermoedelijk) allemaal gehele getallen zijn.
zpotI = 15;     %zichtduur voor selectie onafhankelijke pieken (piek op t is max op [t-zpotI, t+zpotI]).
zBI = 15;       %halve breedte van geselecteerde tijdreeks (default=zpotI). NB zBI>zpotI
%kan soms crash geven bij aanpassing van golven tbv
%opschaling.
zD = 15;        %bij gegeven piek op tijd t wordt gezocht naar max van andere variabele in [t-zD,t+zD]
%default zD = zpotI

%Parameters voor plotten onafh (I) en afh (D) variabelen in multiplot met dubbele
%y-assen. (Geen parameters voor x-assen; die gaan automatisch.)
Npx = 3;     	%Npx:  aantal plaatjes in x-richting
Npy = 4;		%Npy:  aantal plaatjes in y-richting (totaal Npx*Npy plaatjes in multiplot).

%invoerfiles dagwaarden (jaar, maand, dag, data):

%[datuminlees,mp,qlob,qolst] = textread('Statistieken Geerse
%IJsm_Lob_Olst.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');

infileIJ   = 'Statistieken Geerse IJsm_Lob_Olst.txt';
infileIJsm = 'Statistieken Geerse IJsm_Lob_Olst.txt';
%infileV = 'Vechtafvoeren_jan60_dec83_met_uitbr.txt';
infileV_ex2000 = 'Vechtafvoeren_jan60_dec83_uitbr excl 2000.txt';

%Keuzemogelijkheden:
%Onafh I    Afh D       geval
%IJ         IJsm        1
%V          IJsm        2
%IJ         V           3
%V          IJ          4
%IJsm       V           5   %toegevoegd tbv PR2092 op 18 april 2011, door Chris Geerse

geval = 2;  %GEEF HIER DE GEWENSTE KEUZE OP!

%==========================================================================
%Invoer beschouwde gevallen van on- en afhankelijke grootheden.
%==========================================================================
if geval == 1 %I = IJssel, D = IJsm
    drempelI = 200;       %drempelwaarde voor selectie pieken I (825 geef 27 paren)

    %Parameters voor plotten onafh (I) en afh (D) variabelen in multiplot met dubbele
    %y-assen. (Geen parameters voor x-assen; die gaan automatisch.)
    SImn = 0;		%SImn: min van schaal onafh var
    SIst = 500;	    %SIst: stap in schaal onafh var
    SImx = 2000;	%SImx: max van schaal onafh var
    SDmn = -0.5;	%SDmn: min van schaal afh var
    SDst = 0.5;     %SDst: stap in schaal afh var
    SDmx = 0.5;	    %SDmx: max van schaal afh var
    %==========================================================================
    %Inlezen data onafhankelijke variabele (I)
    %==========================================================================
    [datuminleesI,mp,qlob,qolst] = textread(infileIJ,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    [jaarI,maandI,dagI,datumI] = datumconversiejjjjmmdd(datuminleesI);
    dataI = qolst;      %data gelijk maken aan afvoer Olst
    clear mp qlob qolst;

    %==========================================================================
    %Inlezen afhankelijk variabele (D)
    %==========================================================================
    [datuminleesD,mp,qlob,qolst] = textread(infileIJsm,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    [jaarD,maandD,dagD,datumD] = datumconversiejjjjmmdd(datuminleesD);
    dataD = mp/100;      %bepalen meerpeilen in m+NAP
    clear mp qlob qolst;

    %geef hier de gewenste periode aan:
    bejI = 1981; bemI = 1; bedI = 1;
    eijI = 2005; eimI = 3; eidI = 31;
    bedatumI = datenum(bejI,bemI,bedI); eidatumI = datenum(eijI,eimI,eidI);
    selectieI = find(( maandI == 10 | maandI == 11 | maandI == 12 | maandI == 1 |...
        maandI == 2 | maandI == 3)&(datumI >= bedatumI & datumI <= eidatumI));
    %selectieI = find(datumI >= bedatumI & datumI <= eidatumI);

    bejD = 1976; bemD = 1; bedD = 1;
    eijD = 2005; eimD = 3; eidD = 31;
    bedatumD = datenum(bejD,bemD,bedD); eidatumD = datenum(eijD,eimD,eidD);

elseif geval == 2 %I = Vecht, D = IJsm  (Vechtreeks bevat grote hiaten)
    %    drempelI = 167;  %127.99 -> 28 puntenparen, 128 -> 25 paren
    drempelI = 0;
    SImn = 0; SIst = 100; SImx = 400;
    SDmn = -0.5; SDst = 0.5; SDmx = 0.5;

    %    [jaarI,maandI,dagI,dataI] = textread(infileV,'%f %f %f %f','delimiter','','commentstyle','matlab');
    [jaarI,maandI,dagI,dataI] = textread(infileV_ex2000,'%f %f %f %f','delimiter','','commentstyle','matlab');
    datumI = datenum(jaarI,maandI,dagI);        %seriële datum

    [datuminleesD,mp,qlob,qolst] = textread(infileIJsm,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    [jaarD,maandD,dagD,datumD] = datumconversiejjjjmmdd(datuminleesD);
    dataD = mp/100;      %bepalen meerpeilen in m+NAP
    clear mp qlob qolst;

    bejI = 1960; bemI = 1; bedI = 1;
    eijI = 2001; eimI = 3; eidI = 31;
    bedatumI = datenum(bejI,bemI,bedI); eidatumI = datenum(eijI,eimI,eidI);
    selectieI = find(( maandI == 10 | maandI == 11 | maandI == 12 | maandI == 1 |...
        maandI == 2 | maandI == 3)&(datumI >= bedatumI & datumI <= eidatumI));

    bejD = 1976; bemD = 1; bedD = 1;
    eijD = 2005; eimD = 3; eidD = 31;
    bedatumD = datenum(bejD,bemD,bedD); eidatumD = datenum(eijD,eimD,eidD);


elseif geval == 3 %I = IJssel, D = Vecht (omdat weinig overlap bestaat, wordt Olst deels uit Lobith berekend)
    drempelI = 400; %830 -> 27 paren
    SImn = 0; SIst = 500; SImx = 2000;
    SDmn = 0; SDst = 100; SDmx = 400;

    [datuminleesI,mp,qlob,qolst] = textread(infileIJ,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    %Berekening qloblags, zijnde gemiddelde van lags Lobith van 1 en 2 dagen
    %eerder. qloblags heeft dezelfde lengte als de vectoren
    %datuminlees, mp, qlob en qolst
    qloblag1 = circshift(qlob,1);
    qloblag1(1) = -999;
    qloblag2 = circshift(qlob,2);
    qloblag2(1:2) = -999;
    qloblags = (circshift(qlob,1)+circshift(qlob,2))/2;   %gemiddelde van lags Lobith
    qloblags(1:2) = qlob(1:2);   %eerste twee lags zijn niet te berekenen,
    %vandaar dat qloblags dan gelijk wordt genomen aan de originele Lobith waarden.

    [jaarI,maandI,dagI,datumI] = datumconversiejjjjmmdd(datuminleesI);

    %Geef hier aan welk (aansluitend) deel Olst uit Lobith moet worden berekend.
    bejOL = 1901; bemOL = 1; bedOL = 1;
    eijOL = 1980; eimOL = 12; eidOL = 31;
    bedatumOL = datenum(bejOL,bemOL,bedOL);
    eidatumOL = datenum(eijOL,eimOL,eidOL);
    FOL = find(datumI >= bedatumOL & datumI <= eidatumOL);
    %Lineair verband Olst uit lags Lobith: qolst = A1*qloblags + B1
    A1 = 0.16;
    B1 = 0.0;
    qolst(FOL) = A1*qloblags(FOL) + B1; %Hier is qolst deels vervangen door uit Lobith berekende waarden

    dataI = qolst;      %data gelijk maken aan afvoer Olst
    clear mp qlob qolst qloblag1 qloblag2 qloblags;

    %==========================================================================
    [jaarD,maandD,dagD,dataD] = textread(infileV_ex2000,'%f %f %f %f','delimiter','','commentstyle','matlab');
    datumD = datenum(jaarD,maandD,dagD);

    %Selectieperiode analyses
    bejI = 1960; bemI = 1; bedI = 1;
    eijI = 2005; eimI = 3; eidI = 31;
    bedatumI = datenum(bejI,bemI,bedI); eidatumI = datenum(eijI,eimI,eidI);
    selectieI = find(( maandI == 10 | maandI == 11 | maandI == 12 | maandI == 1 |...
        maandI == 2 | maandI == 3)&(datumI >= bedatumI & datumI <= eidatumI));

    bejD = 1960; bemD = 1; bedD = 1;
    eijD = 2005; eimD = 3; eidD = 31;
    bedatumD = datenum(bejD,bemD,bedD); eidatumD = datenum(eijD,eimD,eidD);

elseif geval == 4 %I = Vecht, D = IJssel (omdat weinig overlap bestaat, wordt Olst deels uit Lobith berekend)
    drempelI = 0;
    SImn = 0; SIst = 100; SImx = 400;
    SDmn = 0; SDst = 500; SDmx = 2000;

    [jaarI,maandI,dagI,dataI] = textread(infileV_ex2000,'%f %f %f %f','delimiter','','commentstyle','matlab');
    datumI = datenum(jaarI,maandI,dagI);        %seriële datum

    [datuminleesD,mp,qlob,qolst] = textread(infileIJ,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    qloblag1 = circshift(qlob,1);
    qloblag1(1) = -999;
    qloblag2 = circshift(qlob,2);
    qloblag2(1:2) = -999;
    qloblags = (circshift(qlob,1)+circshift(qlob,2))/2;   %gemiddelde van lags Lobith
    qloblags(1:2) = qlob(1:2);

    [jaarD,maandD,dagD,datumD] = datumconversiejjjjmmdd(datuminleesD);

    %Geef hier aan welk (aansluitend) deel Olst uit Lobith moet worden berekend.
    bejOL = 1901; bemOL = 1; bedOL = 1;
    eijOL = 1980; eimOL = 12; eidOL = 31;
    bedatumOL = datenum(bejOL,bemOL,bedOL);
    eidatumOL = datenum(eijOL,eimOL,eidOL);
    FOL = find(datumD >= bedatumOL & datumD <= eidatumOL);
    A = 0.16;
    B = 0.0;
    qolst(FOL) = A*qloblags(FOL) + B; %Hier is qolst deels vervangen door uit Lobith berekende waarden

    dataD = qolst;      %data gelijk maken aan afvoer Olst
    clear mp qlob qolst qloblag1 qloblag2 qloblags;

    %==========================================================================

    %Selectieperiode analyses
    bejI = 1960; bemI = 1; bedI = 1;
    eijI = 2005; eimI = 3; eidI = 31;
    bedatumI = datenum(bejI,bemI,bedI); eidatumI = datenum(eijI,eimI,eidI);
    selectieI = find(( maandI == 10 | maandI == 11 | maandI == 12 | maandI == 1 |...
        maandI == 2 | maandI == 3)&(datumI >= bedatumI & datumI <= eidatumI));

    bejD = 1960; bemD = 1; bedD = 1;
    eijD = 2005; eimD = 3; eidD = 31;
    bedatumD = datenum(bejD,bemD,bedD); eidatumD = datenum(eijD,eimD,eidD);
    
elseif geval == 5 %I = IJsm, D = Vecht  (Vechtreeks bevat grote hiaten)
    drempelI = -0.6;
    SImn = -0.5; SIst = 0.5; SImx = 0.5;
    SDmn = 0; SDst = 100; SDmx = 400;
 
    [datuminleesI,mp,qlob,qolst] = textread(infileIJsm,'%f %f %f %f','delimiter',' ','commentstyle','matlab');
    [jaarI,maandI,dagI,datumI] = datumconversiejjjjmmdd(datuminleesI);
    dataI = mp/100;      %bepalen meerpeilen in m+NAP
    clear mp qlob qolst;

    [jaarD,maandD,dagD,dataD] = textread(infileV_ex2000,'%f %f %f %f','delimiter','','commentstyle','matlab');
    datumD = datenum(jaarD,maandD,dagD);        %seriële datum

    %IJsm
    bejI = 1976; bemI = 1; bedI = 1;
    eijI = 2005; eimI = 3; eidI = 31;
    bedatumI = datenum(bejI,bemI,bedI); eidatumI = datenum(eijI,eimI,eidI);
    selectieI = find(( maandI == 10 | maandI == 11 | maandI == 12 | maandI == 1 |...
        maandI == 2 | maandI == 3)&(datumI >= bedatumI & datumI <= eidatumI));

    %Vecht
    bejD = 1960; bemD = 1; bedD = 1;
    eijD = 2001; eimD = 3; eidD = 31;
    bedatumD = datenum(bejD,bemD,bedD); eidatumD = datenum(eijD,eimD,eidD);
end



%==========================================================================
%==========================================================================
%Berekenen van selectie pieken I, tijdsperiode D, en algemene (globaal te gebruiken) variabelen.
%==========================================================================

jaarI = jaarI(selectieI); maandI = maandI(selectieI); dagI = dagI(selectieI);
dataI = dataI(selectieI);
datumI = datenum(jaarI,maandI,dagI);
dagnrI = (1:numel(dataI))';

selectieD = find(datumD >= bedatumD & datumD <= eidatumD);  %afhankelijke metingen mogen buiten whj vallen
jaarD = jaarD(selectieD); maandD = maandD(selectieD); dagD = dagD(selectieD);
dataD = dataD(selectieD);
datumD = datenum(jaarD,maandD,dagD);

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
close all

%==========================================================================
% Plotten van geselecteerde golven I en bijbehorende verlopen D.
%==========================================================================
plot_verloopID(golvenI, paren, zD, datumD, dataD,...
    Npx, Npy, SImn, SIst, SImx, SDmn, SDst, SDmx);


%close all


% %==========================================================================
% % Plaatjes en berekeningen fases e.d.
% %==========================================================================
% 
% fase_tovI = [paren.dtmDx] - [paren.dtmI];
% Dx_minus_Dr = [paren.Dx]-[paren.Dr];
% 
% NparenI = numel([paren.I]);
% Nparen_Dx_minus_Dr = numel([Dx_minus_Dr]);
% gemfase_tovI_abs = mean(abs(fase_tovI));
% gemfase_tovI_exabs = mean(fase_tovI);
% gempiekD = mean([paren.Dx]);
% gemDx_minus_Dr = mean(Dx_minus_Dr);
% medDx_minus_Dr = median(Dx_minus_Dr);
% 
% %Berekenen van representatieve faseverschuiving:
% B1=30;   %basisduur in dagen
% if geval == 1 | geval ==2
%     refniv1 = -0.4;
%     b1=4;    %topduur IJsselmeergolven in dagen tbv faseberekening
% elseif geval ==3
%     refniv1 = 0;
%     b1=2;    %topduur Vechtgolven in dagen tbv faseberekening
% elseif geval ==4
%     refniv1 = 0;
%     b1=1;    %topduur IJsselgolven in dagen tbv faseberekening
% elseif geval ==5
%     refniv1 = 0;
%     b1=2;    %topduur Vechtgolven in dagen tbv faseberekening
% end
% 
% fase_repr = b1/2+gemDx_minus_Dr/(gempiekD-refniv1)*(B1-b1)/2;
% 
% display(['drempel onafh var = ',num2str(drempelI),' [eenheid van I]']);
% display(['aantal puntenparen = ',num2str(NparenI),' [-]']);
% display(['gemiddelde van absoluut genomen fases tov onafh var I = ',num2str(gemfase_tovI_abs),' dagen']);
% display(['gemiddelde van fases tov onafh var I = ',num2str(gemfase_tovI_exabs),' dagen']);
% display(['gemiddelde van maximum afh var D = ',num2str(gempiekD),' [eenheid van D]']);
% display(['gemiddelde van Dx - Dr = ',num2str(gemDx_minus_Dr),' [eenheid van D]']);
% display(['mediaan van Dx - Dr = ',num2str(medDx_minus_Dr),' [eenheid van D]']);
% display(['representatieve fase = ',num2str(fase_repr),' dagen]']);

%Wegschrijven puntenparen
data_paren = [[paren.I]',[paren.Dx]'];
if geval ==1
    save([padnaam_uit,'paren_IJ_IJsm_d',num2str(drempelI),'.txt'],'data_paren','-ascii')
    display(['paren_IJ_IJsm_d',num2str(drempelI),'.txt'])
elseif geval ==2
    save([padnaam_uit,'paren_V_IJsm_d',num2str(drempelI),'.txt'],'data_paren','-ascii')
    display(['paren_V_IJsm_d',num2str(drempelI),'.txt'])
elseif geval ==3
    save([padnaam_uit,'paren_IJ_V_d',num2str(drempelI),'.txt'],'data_paren','-ascii')
    display(['paren_IJ_V_d',num2str(drempelI),'.txt'])
elseif geval ==4
    save([padnaam_uit,'paren_V_IJ_d',num2str(drempelI),'.txt'],'data_paren','-ascii')
    display(['paren_V_IJ_d',num2str(drempelI),'.txt'])
elseif geval ==5
    disp('nog niet geïplementeerd')    
end


%==========================================================================
% Plaatjes puntenparen
%==========================================================================
%close all


%--------------------------------------------------------------------------
%I. Alleen de maxima Dx weergegeven, maar niet de waarden Dr:
figure
plot([paren.I],[paren.Dx],'o');
hold on
grid on
if geval == 1 %I = IJssel, D = IJsm
    cltxt  = {'meerpeilmaximum'};
    ttxt  = 'Puntenparen IJssel en IJsselmeer';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'meerpeil, m+NAP';
    Xtick = 0:200:2000;
    Ytick = -0.4:0.1:0.6;
elseif geval == 2 %I = Vecht, D = IJsm
    cltxt  = {'meerpeilmaximum'};
    ttxt  = 'Puntenparen Vecht en IJsselmeer';
    xtxt  = 'afvoer Vecht, m3/s';
    ytxt  = 'meerpeil, m+NAP';
    Xtick = 0:50:400;
    Ytick = -0.4:0.1:0.6;
elseif geval == 3 %I = IJssel, D = Vecht
    cltxt  = {'Vechtmaximum',};
    ttxt  = 'Puntenparen IJssel en Vecht';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'afvoer Vecht, m3/s';
    Xtick = 0:200:2000;
    Ytick = 0:50:400;
elseif geval == 4 %I = Vecht, D = IJssel
    cltxt  = {'IJsselmaximum',};
    ttxt  = 'Puntenparen Vecht en IJssel';
    xtxt  = 'afvoer Vecht, m3/s';
    ytxt  = 'afvoer IJssel, m3/s';
    Xtick = 0:50:400;
    Ytick = 0:200:2000;
elseif geval == 5 %I = IJsselmeer, D = Vecht
    cltxt  = {'Vechtmaximum',};
    ttxt  = 'Puntenparen IJsselmeer en Vecht';
    xtxt  = 'IJsselmeerpeil, m+NAP';
    ytxt  = 'afvoer Vecht, m3/s';
    Xtick = -0.6:0.1:0.4;
    Ytick = 0:50:400;

end
ltxt  = char(cltxt);
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)




%--------------------------------------------------------------------------
%II. Alleen de waarden Dr weergeven, maar niet de waarden Dx:
figure
plot([paren.I],[paren.Dr],'o');
hold on
grid on
if geval == 1 %I = IJssel, D = IJsm
    cltxt  = {'meerpeil tijdens piekafvoer'};
    ttxt  = 'Puntenparen IJssel en IJsselmeer';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'meerpeil, m+NAP';
    Xtick = 0:200:2000;
    Ytick = -0.4:0.1:0.6;
elseif geval == 2 %I = Vecht, D = IJsm
    cltxt  = {'meerpeil tijdens piekafvoer'};
    ttxt  = 'Puntenparen Vecht en IJsselmeer';
    xtxt  = 'afvoer Vecht, m3/s';
    ytxt  = 'meerpeil, m+NAP';
    Xtick = 0:50:400;
    Ytick = -0.4:0.1:0.6;
elseif geval == 3 %I = IJssel, D = Vecht
    cltxt  = {'Vechtafvoer tijdens piekafvoer IJssel'};
    ttxt  = 'Puntenparen IJssel en Vecht';
    xtxt  = 'afvoer IJssel, m3/s';
    ytxt  = 'afvoer Vecht, m3/s';
    Xtick = 0:200:2000;
    Ytick = 0:50:400;
elseif geval == 4 %I = Vecht, D = IJssel
    cltxt  = {'IJsselafvoer tijdens piekafvoer Vecht'};
    ttxt  = 'Puntenparen Vecht en IJssel';
    xtxt  = 'afvoer Vecht, m3/s';
    ytxt  = 'afvoer IJssel, m3/s';
    Xtick = 0:50:400;
    Ytick = 0:200:2000;
elseif geval == 5 %I = IJsselmeer, D = Vecht
    cltxt  = {'Vechtafvoer tijdens piek IJsselmeerpeil'};
    ttxt  = 'Puntenparen IJsselmeer en Vecht';
    xtxt  = 'IJsselmeerpeil, m+NAP';
    ytxt  = 'afvoer Vecht, m3/s';
    Xtick = -0.6:0.1:0.4;
    Ytick = 0:50:400;

end
ltxt  = char(cltxt);
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
