plot(datum,data,'.');
grid on
hold on
ltxt  = []
ttxt  = 'Meerpeilen IJsselmeer';
xtxt  = 'tijd, jaren';
ytxt  = 'meerpeil, m+NAP';
datetick('x',10)
%datetick('x','keeplimits')
%datetick('x','keepticks')
Ytick = -0.6:0.2:0.6;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
