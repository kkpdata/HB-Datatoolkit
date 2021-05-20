
%versie 2.0: dd 2017 05 01
%manier van wegschrijven windvelden voor waqua is iets gewijzigd door caroline gautier


% Open Earth Tools Matlab Utilities
if isempty(which('convertCoordinates.m'))
    addpath p:\delta\svn.oss.deltares.nl\openearthtools\matlab\;
    oetsettings;
end

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
[xx,yy]        = wlgrid('read','wind_grid_noRotation.grd'); %read wind grid coordinates for interpolation
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

for uu=1:length(wind_dirs)
    factors = new_facs(:,uu);
    for ee=1:length(wind_speed)
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

%BELOW IT IS ABOUT THE MAKING OF THE WAQUA FILES (WHICH ARE TIME DEPENDENT)
clearvars -except all_wind_speed all_wind_u all_wind_v wind_dirs wind_potential


%[lonwaq,latwaq,logs]    =convertCoordinates(38000,402000,'CS1.code',28992,'CS2.code',4326)
%[lonwaqdx,latwaqdx,logs]=convertCoordinates(26000,402000,'CS1.code',28992,'CS2.code',4326)
%[lonwaqdy,latwaqdy,logs]=convertCoordinates(38000,414000,'CS1.code',28992,'CS2.code',4326)
%dlon=lonwaq-lonwaqdx;%0.173107911464752
%dlat=latwaqdy-latwaq;%0.107824309682258
%lon0=lonwaq-6*dlon;%2.659942541813464
%lat0=latwaq-4*dlat;%51.163397587001107
%lonend=lon0+11*dlon;%4.564129567925736
%latend=lat0+10*dlat;%52.241640683823682

getijfase =	 -5.33333; %=320 minutes (see also report B1 Belastingmodel by HKV)...
t         = [-51.34:0.5:48.66]; %times (hours) based on HW and so on... we run 100 hours with timestep 30 minutes.

lat0      = 51.1633975 *1000; %LowerLeft corner; times 1000 because is millidegrees
lon0      = 2.65994254 *1000; %LowerLeft corner; times 1000 because is millidegrees
latend    = 52.2416407 *1000; %UpperRight corner; times 1000 because is millidegrees
lonend    = 4.56412957 *1000; %UpperRight corner; times 1000 because is millidegrees

for uu=12%1:size(all_wind_speed,1)    %12 and 5 is to check a reference direciton + wind speed
    for ii=[2 7]%:size(all_wind_speed,2)  %12 and 5 is to check a reference direciton + wind speed
%        OutputDir = sprintf('WINDforWAQUA_%0.0f_%0.0f/',wind_dirs(uu),wind_potential(ii));
        OutputDir = ['WINDforWAQUA_' num2str(wind_dirs(uu)) '_' num2str(wind_potential(ii)) '\'];

        mkdir(OutputDir);
        
	time      = datenum(2050,01,01); %reference time
	TimeFile  = time;

        for ee=1:length(t)
            WindSpeed = all_wind_speed(uu,ii).data/ (1 + (2.*abs(t(ee) - getijfase + 6)/26.8).^(1/0.84) );
            
            md = 270 -wind_dirs(uu);
            wind_u = WindSpeed .* cosd(md);
            wind_v = WindSpeed .* sind(md);
            
            %% ADD EXTRA ROW OF CELLS
            wind_u = [wind_u;wind_u(end,:)];           
            wind_v = [wind_v;wind_v(end,:)];
            
			%header lines are taken from section 5.3 of the WAQWIND manual
            %% Wind U
            FileName = ['WAQH_INU_',datestr(TimeFile,'yyyymmddHHMM'),'_00000'];
            %             disp(FileName);
            fid = fopen([OutputDir,FileName],'w');
            fprintf(fid,'19 11 132\n'); 
            fprintf(fid,['99 4 255 128 33 105 10 ',datestr(TimeFile,'yyyy mm dd HH MM'),' 1\n']);
            fprintf(fid,'0      0      1      0      0     21\n');
            fprintf(fid,'0 %d %d %0.2f %0.2f 128 %0.2f %0.2f 26000 15000 96\n',[size(wind_u,1) size(wind_u,2) lat0 lon0 latend lonend]);
            fprintf(fid,[repmat('%0.2f ',1,size(wind_u',1)),'\n'],wind_u');
            fclose(fid);
            
            %% Wind V
            FileName = ['WAQH_INV_',datestr(TimeFile,'yyyymmddHHMM'),'_00000'];
            fid = fopen([OutputDir,FileName],'w');
            fprintf(fid,'19 11 132\n');
            fprintf(fid,['99 4 255 128 34 105 10 ',datestr(TimeFile,'yyyy mm dd HH MM'),' 1\n']);
            fprintf(fid,'0      0      1      0      0     21\n');
            fprintf(fid,'0 %d %d %0.2f %0.2f 128 %0.2f %0.2f 26000 15000 96\n',[size(wind_u,1) size(wind_u,2) lat0 lon0 latend lonend]);
            fprintf(fid,[repmat('%0.2f ',1,size(wind_u',1)),'\n'],wind_v');
            fclose(fid);
            
            %% Pressure
            FileName = ['WAQH_INP_',datestr(TimeFile,'yyyymmddHHMM'),'_00000'];
            fid = fopen([OutputDir,FileName],'w');
            fprintf(fid,'19 11 132\n');
            fprintf(fid,['99 4 255 128 001 105 10 ',datestr(TimeFile,'yyyy mm dd HH MM'),' 1\n']);
            fprintf(fid,'0      0      1      0      0     21\n');
            fprintf(fid,'0 %d %d %0.2f %0.2f 128 %0.2f %0.2f 26000 15000 96\n',[size(wind_u,1) size(wind_u,2) lat0 lon0 latend lonend]);
            fprintf(fid,[repmat('%0.2f ',1,size(wind_u',1)),'\n'],103000+0.*wind_v');
            fclose(fid);

	    TimeFile = TimeFile + 0.5/24;
 
        end
    end
end

