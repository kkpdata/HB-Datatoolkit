[datuminlees,mp,qlob,qolst] = textread('Statistieken Geerse IJsm_Lob_Olst.txt','%f %f %f %f','delimiter',' ','commentstyle','matlab');

jaar = floor(datuminlees/10000);
maand = floor((datuminlees-jaar*10000)/100);
dag = floor(datuminlees-jaar*10000-maand*100);
datum = datenum(jaar,maand,dag);        %seriële datum

plot(qlob,mp)
