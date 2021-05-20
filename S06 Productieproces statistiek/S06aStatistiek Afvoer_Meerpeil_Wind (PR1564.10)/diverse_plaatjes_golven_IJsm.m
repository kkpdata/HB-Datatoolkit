
figure
for i = 1:aantal_golven
    plot(golven(i).tijd, golven(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Gemeten golven IJsselmeer';
xtxt  = 'tijd, dagen';
ytxt  = 'meerpeil, m+NAP';
Xtick = -15:5:15;
Ytick = -0.4:.2:0.6;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven IJsselmeer';
xtxt  = 'tijd, dagen';
ytxt  = 'meerpeil, m+NAP';
Xtick = -15:5:15;
Ytick = -0.4:.2:0.6;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%nu golven op 1 genormeerd
figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, (golven_aanpas(i).data-ref_niv)./(max(golven_aanpas(i).data)-ref_niv),'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven IJsselmeer na normering op 1';
xtxt  = 'tijd, dagen';
ytxt  = 'meerpeil, m+NAP';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
