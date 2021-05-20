
fac_voorflank   = 0.5;      %verdeling over voor- en achterflank

figure
for i = 22:27;
    %Hydra-B golven
    plot([golven_HB(i).tijd], [golven_HB(i).afv],'g')
    hold on
    grid on
    
    %trapezia toevoegen
    topduur_i         = interp1(topduur_inv(:,1),topduur_inv(:,2),golven_HB(i).piek);
    xx_i              = [-fac_voorflank*B, -0.5*topduur_i/24, 0.5*topduur_i/24, (1-fac_voorflank)*B]';
    yy_i              = [basis_niv, golven_HB(i).piek, golven_HB(i).piek, basis_niv]';
    plot(xx_i,yy_i,'r');
    hold on
end
ttxt  = 'Afvoergolven Lith met trapezia';
xtxt  = 'tijd, dagen';
ytxt  = 'afvoer, m^3/s';
ltxt  = []
Xtick = [-20:5:20];
Ytick = [0:500:4000];
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)