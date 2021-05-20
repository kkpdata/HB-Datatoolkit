
% Open Earth Tools Matlab Utilities
if isempty(which('convertCoordinates.m'))
    addpath p:\delta\svn.oss.deltares.nl\openearthtools\matlab\;
    oetsettings;
end

addpath('p:\1230058-os\SwanWaquaWindfields\');

outdir = 'WINDforSWAN';
mkdir(outdir);

%select wind speed
wind_potential = [10,20,24,28,30,34,38,42,46,50];
alfa           = 0.0185;
wind_speed     = Upot2Uow_Charnock(wind_potential,alfa);
wind_dirs      = [22.5:22.5:360];

%STATIONS: vlissingen, oosterschelde, tholen, euro, LE, Raan
%Factors (average local windspeed in relation to the windspeed at Vlissingen) based on KNMI observations 1981-2015 in combination with Harmonie windfields 1979-2013
%per station per direction (N,S,E,W)
stations       = [1   , 1   , 1   ,1     ;...
	              1.25, 1   , 1.05, 1    ;...
				  1   , 0.90, 0.95, 0.95 ;...
				  1.25, 1.10, 1.10, 1    ;...
				  1.25, 1   , 1.05, 1    ;...
				  1.25, 1   , 1.05, 1    ];

%coordiantes of the stations:
% 310,   30475,    385125,  27.0,   8.0,    Vlissingen
% 312,   32824,    421369,  16.5,   0.0,    Oosterschelde
% 331,   72030,    388524,  16.5,   0.0,    Tholen
% 321,   10044,    447580,  29.1,   0.0,    Europlatform
% 320,   36662,    437913,  38.3,   0.0,    L.E. Goeree
% 313,    6038,    392714,  16.5,   0.0,    Vlakte van de Raan

xq_ori         = [30475, 32824, 72030, 10044, 36662, 6038];   %X bouy coordinates
yq_ori         = [385125,421369,388524,447580,437913,392714]; %Y bouy coordiantes

%% no rotation!
[xx,yy]        = wlgrid('read','p:\1230058-os\SwanWaquaWindfields\wind_grid_noRotation.grd'); %read wind grid coordinates for interpolation
grid_rotation  = 0; %wind grid rotation

%Add additional Tholen value to east boundary locations to make the
%interpolation of the wind field better.
xq_east=[xx(11,2:4)];
yq_east=[yy(11,2:4)];
for uu=1:size(xq_east,2)
    stations_east(uu,:)=stations(3,:);%Tholen
end
xq=[xq_ori,xq_east];
yq=[yq_ori,yq_east];
stations_up=[stations;stations_east];

for n = 1:size(stations_up,1);
    dirs = [0 180 90 270 360];
    facs = [stations_up(n,:),stations_up(n,1)];
    new_facs(n,:) = interp1(dirs,facs,wind_dirs);
end

for uu=12%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1:length(wind_dirs)
    factors = new_facs(:,uu);
    for ee=2%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1:length(wind_speed)
        %corresponding winds per locations given an input wind speed.
        vq=wind_speed(ee)*factors; %wind speeds per location
        
        %extrapolation of wind speed to wind grid
        vv     = griddata(xq,yq,vq,xx,yy,'linear');
        vv_a   = vv(vv>0);x_a = xx(vv>0);y_a = yy(vv>0);
        vv2    = griddata(x_a,y_a,vv_a,xx,yy,'nearest');
               
        md     = 270 - grid_rotation - wind_dirs(uu);%50 corresponds to the wind rotation
        wind_u = vv2 .* cosd(md);
        wind_v = vv2 .* sind(md);
        
        all_wind_u(uu,ee).data=wind_u;
        all_wind_v(uu,ee).data=wind_v;
        all_wind_speed(uu,ee).data=vv2;
        
        %write SWAN wind files.
        % wldep('write',[outdir '\WIND_' num2str(wind_potential(ee)) '_' sprintf('%3.0d',floor(wind_dirs(uu))) '.wnd'],wind_u,wind_v);
    end
end

figure;
pcolor(xx/1000,yy/1000,pyth(wind_u,wind_v))
colorbar
caxis([39.5 44]);
hold on
load outlnederland;pp=plot(xnl./1000,ynl./1000,'k');
scatter(xq./1000,yq./1000,50,vq,'filled');
pp=plot(xq/1000,yq/1000,'ok','markersize',8);
locname={'Vlissingen','Oosterschelde','Tholen','EPL','LEG','Raan'};
for i=1:length(locname)
	text(4+xq_ori(i)./1000,yq_ori(i)./1000,locname{i});
end
if uu==16
	caxis([39.5 56]);
end
if uu==12 & ee==2
	caxis([20.6 21.55]);
end

title(['Windveld U10 [m/s];    U10_{Vlissingen}=' num2str(wind_speed(ee),3) ' m/s, U_{pot Vlissingen}=' num2str(wind_potential(ee),3) ' m/s, Dir=' num2str(wind_dirs(uu)) '^oN']);

shading interp;eval(['print -dpng ShadInter_D' num2str(wind_dirs(uu)) 'U' num2str(wind_speed(ee),2) '.png'])
shading faceted;eval(['print -dpng ShadFacet_D' num2str(wind_dirs(uu)) 'U' num2str(wind_speed(ee),2) '.png'])