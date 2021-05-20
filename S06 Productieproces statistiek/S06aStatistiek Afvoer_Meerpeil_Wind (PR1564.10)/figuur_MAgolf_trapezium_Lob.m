%nummer maatgevende golf
iMA             = 22;   %handmatig opgezocht
topduurMA       = interp1(topduur_inv(:,1),topduur_inv(:,2),golven_HB(iMA).piek);
fac_voorflank   = 0.5;
xx              = [-fac_voorflank*B, -0.5*topduurMA/24, 0.5*topduurMA/24, (1-fac_voorflank)*B]';
yy              = [basis_niv, 16000, 16000, basis_niv]';

figure
plot([golven_HB(iMA).tijd], [golven_HB(iMA).afv],'g')
hold on
grid on
plot(xx,yy,'r');
ttxt  = 'Maatgevende afvoergolf Lobith met trapezium';
xtxt  = 'tijd, dagen';
ytxt  = 'afvoer, m^3/s';
ltxt = []
Xtick = -10:5:15;
Ytick = 8000:1000:17000;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
