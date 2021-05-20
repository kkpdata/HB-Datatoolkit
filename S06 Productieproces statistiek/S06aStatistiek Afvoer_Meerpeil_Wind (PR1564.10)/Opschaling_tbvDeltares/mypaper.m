function [] = mypaper(orientation) 

gcf1 = 1;
figure(gcf1);
clf reset;
%orient tall;
set(gcf1, ...
  'PaperType','a4letter', ...
  'PaperUnits','normalized',...
  'Color','white');
if orientation=='P'
  orient portrait;
elseif orientation=='L'
  orient landscape;
end