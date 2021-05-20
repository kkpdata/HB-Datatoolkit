function [] = fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)

axespos = get(gca,'Position');

if ~isempty(fontsize)
  set(gca,'Fontsize',fontsize)
end
if ~isempty(linewidth)
  set(gca,'LineWidth',linewidth);
end
if ~isempty(ttxt)
  h = title(ttxt);
  nregel = size(ttxt,1);
  if nregel==1
    witveld = 0.4;
  elseif nregel==2
    witveld = 0.25;
  else
    witveld = 0.1;
  end
  set(h,'Units','normalized');
  ttxtpos    = get(h,'Position');
  ttxtpos(2) = 1 + witveld*(1-axespos(2)-axespos(4))/axespos(4);
  set(h,'Position',ttxtpos);
end
if ~isempty(xtxt)
  h = xlabel(xtxt);
  set(h,'Units','normalized');
  xtxtpos    = get(h,'Position');
  xtxtpos(2) = -0.5*axespos(2)/axespos(4);
  set(h,'Position',xtxtpos);
end
if ~isempty(ytxt)
  h = ylabel(ytxt);
  set(h,'Units','normalized');
  ytxtpos    = get(h,'Position');
  ytxtpos(1) = -0.6*axespos(1)/axespos(3);
  set(h,'Position',ytxtpos);
end
if ~isempty(ltxt)
  if isempty(lpos)
    lpos = 0;
  end
  legend(ltxt,lpos);
end
if ~isempty(Xtick)
  Xlim  = [min(Xtick) max(Xtick)];
  set(gca,'Xlim',Xlim,'Xtick',Xtick);
end
if ~isempty(Ytick)
  Ylim  = [min(Ytick) max(Ytick)];
  set(gca,'Ylim',Ylim,'Ytick',Ytick);
end
