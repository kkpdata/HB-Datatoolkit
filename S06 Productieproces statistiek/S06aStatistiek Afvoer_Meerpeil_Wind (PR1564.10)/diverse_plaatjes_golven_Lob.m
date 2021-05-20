figure
for i = 1:aantal_golven
    plot(golven(i).tijd, golven(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Gemeten golven Lobith';
xtxt  = 'tijd, dagen';
ytxt  = 'Rijnafvoer Lobith, m3/s';
Xtick = -15:5:15;
Ytick = 0:2500:13000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data,'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven Lobith';
xtxt  = 'tijd, dagen';
ytxt  = 'Rijnafvoer Lobith, m3/s';
Xtick = -15:5:15;
Ytick = 0:2500:13000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

%nu golven op 1 genormeerd
figure
for i = 1:aantal_golven
    plot(golven_aanpas(i).tijd, golven_aanpas(i).data./max(golven_aanpas(i).data),'b-')
    hold on
    grid on
end
ltxt  = [];
ttxt  = 'Aangepaste golven Lobith na normering op 1';
xtxt  = 'tijd, dagen';
ytxt  = 'relatieve afvoer Lobith, [-]';
Xtick = -15:5:15;
Ytick = 0:0.1:1;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
