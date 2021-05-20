function watisklaar

welkedir='RUN';

tic
runidlist=[];
mainpath=['p:\11200556-os\golven\SWAN01\' welkedir '\'];
outfile= ['p:\11200556-os\golven\SWAN01\CONTROL\checkbulk\watisklaar' datestr(now,'yyyymmddHHMM') '.png'];

cd(mainpath);
d1=dir('D*');
for i1=1:length(d1);
	cd(d1(i1).name);
	d2=dir('U*O*');
	for i2=1:length(d2);
		if d2(i2).isdir==1
			cd(d2(i2).name);
			d3=dir('*01.TAB');
			if ~isempty(d3);
				runidname=d3.name(1:14);
				runidlist=[runidlist; runidname];
			end
			cd ..
		end
	end
	cd ..
end
cd ../SCRIPTS/ProcChecks

z=repmat(0,51,136);
u=[10 20 24 28 30 34 38];
for i=1:length(u)
	z(:,i:7:112)=u(i);
end
u=[42 46 50];
for i=1:length(u)
	z(:,112+i:3:137)=u(i);
end
figure;pcolor(z);hold on
axis equal;axis([-2 138 -2 53]);
cb=colorbar;set(get(cb,'title'),'string','U10 [m/s]');clim([0 50]);set(cb,'Ytick',[10 20 24 28 30 34 38 42 46 50]);
set(gca,'xtick',[5:7:112,114:3:135],'xticklabel',[22.5:22.5:360 202.5:22.5:360]);
set(gca,'ytick',[1.5:1:51],'yticklabel',[-2:0.25:2.75, 2.99 3:0.5:6.5 0:0.25:2.75, 2.99 3:0.5:6.5],'fontsize',8)
plot([-5,141],[30 30],'k','linewidth',2);
pp=plot([57,57],[30 53],'k','linewidth',2);
patch([1 57 57 1],[30 30 51 51],'k')
ylabel([' waterstand OSK OPEN                                                        waterstand OSK DICHT']);
xlabel(['wind richting [^oN]']);
zready=z;

z=zready.*0;
figure;pcolor(z);hold on;
axis equal;axis([-1 138 -1 52]);
cb=colorbar;set(get(cb,'title'),'string','U10 [m/s]');clim([0 50]);set(cb,'Ytick',[10 20 24 28 30 34 38 42 46 50]);
set(gca,'xtick',[5:7:112,114:3:135],'xticklabel',[22.5:22.5:360 202.5:22.5:360]);
set(gca,'ytick',[1.5:1:51],'yticklabel',[-2:0.25:2.75, 2.99 3:0.5:6.5 0:0.25:2.75, 2.99 3:0.5:6.5],'fontsize',8)
plot([-5,141],[30 30],'k','linewidth',2);
pp=plot([57,57],[30 53],'k','linewidth',2);
patch([1 57 57 1],[30 30 51 51],'k')
ylabel([' waterstand OSK OPEN                                                        waterstand OSK DICHT']);
xlabel(['wind richting [^oN]']);

u10value=[10 20 24 28 30 34 38 42 46 50];
wlvalue=[-2:0.25:2.75, 2.99 3:0.5:6.5 ];

welkelist=[];
for ii=1:size(runidlist,1)
	runid=runidlist(ii,:);
	uu=str2num(runid(2:3));u=find(u10value==uu);
	dd=str2num(runid(5:7));d=round(dd/22.5);
	wl=str2num(runid(10:12))/100;if runid(9)=='m';wl=-wl;end;
	if runid(14)=='O'
		l=find(wlvalue==wl);
	else
		l=find(wlvalue==wl) + 29 - 8;
	end
		
	if uu<42
		welke = (d-1)*51*7 + (u-1)*51  +  l;
	else
		welke = 5712 + (d-9)*51*3 + (u-8)*51  +  l;
	end
	welkelist=[welkelist,welke];
end

z(welkelist)=zready(welkelist);
pcolor(z);
patch([1 57 57 1],[30 30 51 51],'k');
alle=((16*7)+(8*3))*28  +  (8*10)*20;perc=100*length(welkelist)/alle;
title([mainpath ': Donker blauw heeft nog geen *.prt file;                                                                       '  num2str(length(welkelist)) ' van de ' num2str(alle) ' sommen zijn klaar (= ' num2str(perc,'%3.1f') '%)']);
set(gcf,'paperposition',[0.05 0.25 20 10],'Position',[200 200 1600 800]);
set(gca,'Position',[0.07 0.04 0.86 0.85])
print('-dpng',outfile)
toc



