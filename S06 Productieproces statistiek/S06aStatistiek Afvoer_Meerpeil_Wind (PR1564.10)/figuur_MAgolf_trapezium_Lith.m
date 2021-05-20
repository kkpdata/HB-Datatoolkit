%nummer maatgevende golf
MA              = 3650;
iMA             = 26;   %handmatig opgezocht (levert 3647.1 ipv MA = 3650)
topduurMA       = interp1(topduur_inv(:,1),topduur_inv(:,2),MA/max([golven_HB(iMA).piek])*golven_HB(iMA).piek);
fac_voorflank   = 0.5;
xx              = [-fac_voorflank*B, -0.5*topduurMA/24, 0.5*topduurMA/24, (1-fac_voorflank)*B]';
yy              = [basis_niv, MA, MA, basis_niv]';

figure
plot([golven_HB(iMA).tijd], [golven_HB(iMA).afv],'g')
hold on
grid on
plot(xx,yy,'r');
ttxt  = 'Maatgevende afvoergolf Lith met trapezium';
xtxt  = 'tijd, dagen';
ytxt  = 'afvoer, m^3/s';
ltxt = []
Xtick = -10:5:15;
Ytick = 1750:250:3750;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
