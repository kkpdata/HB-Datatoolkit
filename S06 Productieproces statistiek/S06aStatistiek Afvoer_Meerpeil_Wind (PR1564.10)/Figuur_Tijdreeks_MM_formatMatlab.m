
plot(datum,data,'.');
grid on
hold on
title('Meerpeilen Markermeer');
xlabel('tijd, jaren');
ylabel('meerpeil, m+NAP');
datetick('x',10)
%datetick('x','keeplimits')
%datetick('x','keepticks')
ylim([-0.5,0.4])
%Ytick = -0.5:0.1:0.4;
%fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
