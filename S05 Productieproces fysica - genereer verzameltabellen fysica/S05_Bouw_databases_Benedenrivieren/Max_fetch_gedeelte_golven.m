% Script #
close all; clear all; clc;
tic

% geom=csvread('c:\Projects\C03061.000391_Bouw_databases\Brettschneider\Waves\Geometrie.csv',1,0);
% %col1 = X
% %col2 = Y
% %col3 = dir
% %col4 = Bottom depth
% %col5 = Effective Fetch
% %col6 = HRDlocationId
%
% toc




Arc_shape={
    %'l:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Gedeelte_golven\16-1_v03_arcadis_loc.csv'
    'l:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Gedeelte_golven\16-2_v04_arcadis_loc.csv'
    %'l:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Gedeelte_golven\24-2_v04_arcadis_loc.csv'
    %'l:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Gedeelte_golven\35-2_v04_arcadis_loc.csv'
    };

geom_tot=[];

for icsv=1:length(Arc_shape)

    geom=csvread(Arc_shape{icsv},0,0);



    d1 = sortrows(geom,[6 5]);
    [not_used1,ii] = unique(d1(:,6), 'last');
    geom_max = d1(ii,:);

    geom_tot=[geom_tot;geom_max];

    clear geom d1 ii geom_max
    toc
end


x2=geom_tot(:,1)+cosd(90-geom_tot(:,3)).*geom_tot(:,5);
y2=geom_tot(:,2)+sind(90-geom_tot(:,3)).*geom_tot(:,5);
geom_tot=[geom_tot,x2,y2];


fid3=fopen('l:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Gedeelte_golven\gedeelte_golven_16-2_max_fetch_Arcadis.csv','wt');
fprintf(fid3,'%s\n','x,y,richting,B,FE,ID,x2,y2');
fprintf(fid3,'%.0f,%.0f,%.1f,%.6f,%.6f,%i,%.3f,%.3f\n',geom_tot');
fclose(fid3);
fclose all;



% Ori_shape


