
plot(datum,data,'.');
grid on
hold on
ltxt  = []
ttxt  = 'Meerpeilen Veluwe Randmeer';
xtxt  = 'tijd, jaren';
ytxt  = 'meerpeil, m+NAP';
datetick('x',10)
%datetick('x','keeplimits')
%datetick('x','keepticks')
Ytick = -0.4:0.1:0.4;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
