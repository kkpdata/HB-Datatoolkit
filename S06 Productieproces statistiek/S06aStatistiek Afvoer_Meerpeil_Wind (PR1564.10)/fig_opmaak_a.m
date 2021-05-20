function [ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)

% Dit script is handig om een matlab-figuur op te maken voor opname in een word
% document of powerpoint presentatie. Dit gaat echter alleen goed voor
% enkelvoudige plots; waarschijnlijk niet voor figuren met subplots.
% Aanwijzingen voor gebruik in ander script:
%
% -------------------------------------------------------------------------
% >>> keuze opmaak:
% figformat = 'doc' OF 'ppt' 
% 
% >>> Initialisatie opmaak:
% [ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
% linewidth = 
% fontsize  = 
% 
% >>> Definitie plot:
% x = 
% y =
% plot(x,y,'Linewidth',linewidth)
% 
% >>>Nadere invulling opmaak:
% ttxt  = 
% ttxt  = 
% xtxt  = 
% ytxt  = 
% ltxt  = 
% lpos  = 
% Xtick = 
% Ytick = 
% 
% >>>Toepassing opmaak:
% fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)
% -------------------------------------------------------------------------

ttxt  = [];
xtxt  = [];
ytxt  = [];
ltxt  = [];
lpos  = [];
Xtick = [];
Ytick = [];
ytxtsmal = 0;


mypaper('L');
if figformat == 'ppt'
  clf
  axes('Units','normalized', ...
    'Position',[0.2 0.2 0.6 0.6]);
  set(gcf,'Color','none');
  fontsize  = 18;
  linewidth =  2;
elseif figformat == 'doc'
  clf
  if ytxtsmal
    axes('Units','normalized', ...
      'Position',[0.10 0.15 0.80 0.70]);
  else
    axes('Units','normalized', ...
      'Position',[0.15 0.15 0.75 0.70]);
  end  
  set(gcf,'Color','w');
  fontsize  = 18;
  linewidth =  2;
end

