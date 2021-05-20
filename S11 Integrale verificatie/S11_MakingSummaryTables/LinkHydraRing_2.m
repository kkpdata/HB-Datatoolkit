clc
clear all
close all

% links old locations from Hydra-Zoet/Hydra-K with Hydra Ring locations for
% regions where there are new databases (i.e. room for the river measures 
% occuring)

% Regions
% 1 non-tidal river reaches Rhine,
% 2 non-tidal river reaches Meuse,
% 3 tidal river reaches Rhine,
% 4 tidal river reaches Meuse,
% 5 IJssel delta,
% 6 Vecht delta,
% 7 lake IJssel,
% 8 lake Marken,
% 9 Wadden Sea east,
% 10 Wadden Sea west,
% 11 the northern part of the Dutch coast,
% 12 the central part of the Dutch coast,
% 13 the southern part of the Dutch coast,
% 14 Easternscheldt,
% 15 Westernscheldt,
% 16 the Dutch sandy coasts (dunes),
% 17 Europoort
% 18 Non-tidal Meuse (infinitely high quays) 

RegionNames={'benedenmaas', 'benedenrijn', 'bovenmaas', 'bovenmaas_hk', 'bovenrijn', 'europoort', 'ijsseldelta', 'vechtdelta', 'oosterschelde', 'ExtraLoc'};
SQLName={'WTI_export_oever_RMM', 'WTI_export_oever_RMM', 'WTI_export_oever_Maas', 'WTI_export_oever_Maas_mknov', 'WTI_export_oever_Rijn', 'NotSure', 'WTI_export_oever_IJVD', 'WTI_export_oever_IJVD', 'NotSure', 'NotSure'};
RegionAddition=[400000, 300000,200000,1800000, 100000,1700000, 500000, 600000,1400000, 0];
zoom_x=[1.08e5 1.6e5;0.6e5 1.61e5;1e5 2.3e5;1e5 2.3e5;1e5 2.2e5;6.5e4 8.3e4;1.7e5 2.1e5;1.85e5 2.25e5; 3e4 7.5e4];
zoom_y=[4.1e5 4.3e5;4e5 4.5e5;3.1e5 4.3e5;3.1e5 4.3e5;4.2e5 5.2e5;4.3e5 4.48e5;4.8e5 5.15e5;5e5 5.2e5; 3.8e5 4.15e5];
addition='oever';

DirCSV='p:\1230087-hydraulische-belastingen\1. Hydraulische Randvoorwaarden\4. MakingSummaryTables\uitvoerlocaties\';
load('p:\1230087-hydraulische-belastingen\1. Hydraulische Randvoorwaarden\4. MakingSummaryTables\HRING_locations_and_IDS\HRING_ID_NAME_X_Y_selection.mat')
FetchFile='p:\1230087-hydraulische-belastingen\1. Hydraulische Randvoorwaarden\4. MakingSummaryTables\Hydra_Locations.xlsx';


%% Do for updated regions
[values string]=xlsread(FetchFile,'Hydra-Zoet');
X2=values(:,1); Y2=values(:,2); Orient=values(:,3);
AllDatabases=string(2:end,1); AllLocations=string(2:end,2);
[values string]=xlsread(FetchFile,'Markermeer');
X2=[X2;values(:,1)]; Y2=[Y2;values(:,2)]; Orient=[Orient;values(:,3)];
AllDatabases=[AllDatabases;string(2:end,1)]; AllLocations=[AllLocations;string(2:end,2)];
[values string]=xlsread(FetchFile,'Hydra-K');
X2=[X2;values(:,2)]; Y2=[Y2;values(:,3)]; Orient=[Orient;values(:,4)];
AllDatabases=[AllDatabases;string(2:end,1)]; AllLocations=[AllLocations;num2cell(values(1:end,1))];
[values string]=xlsread(FetchFile,'IJsselVect');
XIV2=[values(:,1);X2]; YIV2=[values(:,2);Y2]; IVData=[string(2:end,1);AllDatabases]; IVLocations=[string(2:end,2);AllLocations];

figure;
plot(X2, Y2, '.k'); axis equal;
[C, ia, ic]=unique([X2 Y2], 'rows');
X4=X2(ia); Y4=Y2(ia);

[C, ia, ic]=unique([XIV2 YIV2], 'rows'); % special for IJssel-Vecht
XIV4=XIV2(ia); YIV4=YIV2(ia);

% read in CSV files
Ids=[];
Name={};
X=[];
Y=[];
for i=10%:length(RegionNames)

    [val str]=xlsread([DirCSV, RegionNames{i}, '_', addition, '_locs.csv'] );
    Ids=val(:,1)+RegionAddition(i);
    Store.HR_name=[str(2:end,2)];
    X=[val(:,3)];
    Y=[val(:,4)];
    Store.sql_name=SQLName{i};
    
    if strcmp(RegionNames{i}, 'oosterschelde');
        Ids=val(:,1);
        Store.HR_name=[str(2:end,3)];
        X=val(:,4);
        Y=val(:,5);
    end
    
    % link with fetch
    temp=griddata(X4,Y4, [1:length(X4)]', X,Y, 'nearest');
    
    if strcmp(RegionNames{i}, 'ijsseldelta')
        tempIV=griddata(XIV4,YIV4, [1:length(XIV4)]', X,Y, 'nearest');
        for j=1:length(X)
            LinkIV(j)=find(XIV4(tempIV(j))==XIV2 & YIV4(tempIV(j))==YIV2, 1,'first');
        end
    end
    
    for j=1:length(X)
        Link(j)=find(X4(temp(j))==X2 & Y4(temp(j))==Y2, 1,'first');
    end
    
    Store.X=X;
    Store.Y=Y;
    Store.Ids=Ids;
    if ~strcmp(RegionNames{i}, 'ijsseldelta')
        Store.distance=sqrt((X-X2(Link)).^2 +(Y-Y2(Link)).^2);
        Store.HydraK_HydraZ_database=AllDatabases(Link);
        Store.HydraK_HydraZ_location=AllLocations(Link);
    else
        Store.distance=sqrt((X-XIV2(LinkIV)).^2 +(Y-YIV2(LinkIV)).^2);
        Store.HydraK_HydraZ_database=IVData(LinkIV);
        Store.HydraK_HydraZ_location=IVLocations(LinkIV);
    end
    Store.dike_orientation=Orient(Link);
   
    if strcmp(RegionNames{i}, 'benedenmaas')==1 | strcmp(RegionNames{i}, 'bovenmaas')==1  | strcmp(RegionNames{i}, 'bovenmaas_hk')==1
        
        Index=find(~cellfun(@isempty,strfind(Store.HR_name, 'AF_60m')));
        Store.HR_name(Index)=[];
        Store.X(Index)=[];
        Store.Y(Index)=[];
        Store.Ids(Index)=[];
        Store.distance(Index)=[];
        Store.dike_orientation(Index)=[];
        Store.HydraK_HydraZ_database(Index)=[];
        Store.HydraK_HydraZ_location(Index)=[];
        X(Index)=[];
        Y(Index)=[];
        Link(Index)=[];
        
    end
    
    if strcmp(RegionNames{i}, 'benedenrijn')==1 
        
        Index=find(X>9.93e4 & X<1.1e5 & Y >4.3678e5 & Y< 4.47e5);
        Store.HR_name(Index)=[];
        Store.X(Index)=[];
        Store.Y(Index)=[];
        Store.Ids(Index)=[];
        Store.distance(Index)=[];
        Store.dike_orientation(Index)=[];
        Store.HydraK_HydraZ_database(Index)=[];
        Store.HydraK_HydraZ_location(Index)=[];
        X(Index)=[];
        Y(Index)=[];
        Link(Index)=[];
        
    end
    
    
    
    if ~strcmp(RegionNames{i}, 'ijsseldelta')
        figure;
        plot(X2, Y2, '.k', 'markersize', 6); axis equal; hold on;
        plot(X,Y, '.g', 'markersize', 4); hold on;
        
        for j=1:length(X)
            plot([X(j) X2(Link(j))], [Y(j) Y2(Link(j))],'r');
        end
    else
        figure;
        plot(XIV2, YIV2, '.k', 'markersize', 6); axis equal; hold on;
        plot(X,Y, '.g', 'markersize', 4); hold on;
        for j=1:length(X)
            plot([X(j) XIV2(LinkIV(j))], [Y(j) YIV2(LinkIV(j))],'r');
        end
    end
    
    title(RegionNames{i});
    axis([zoom_x(i,1) zoom_x(i,2) zoom_y(i,1) zoom_y(i,2)])
    clear Link LinkIV

saveas(gcf, ['MetaInfo/Figures/Links/', RegionNames{i}]);
saveas(gcf, ['MetaInfo/Figures/Links/', RegionNames{i}, '.png']);
end







