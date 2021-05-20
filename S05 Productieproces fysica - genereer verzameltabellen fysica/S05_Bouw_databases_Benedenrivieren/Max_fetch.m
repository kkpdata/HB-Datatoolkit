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
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_17-1_combined_loc.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_20-4_combined_loc.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_21-2_combined_loc.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_22-1_combined_loc.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_22-2_combined_loc.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_24-2_combined_loc.csv'
    };

geom_tot=[];

for icsv=1:length(Arc_shape)

    geom=csvread(Arc_shape{icsv},1,0);



    d1 = sortrows(geom,[6 5]);
    [not_used1,ii] = unique(d1(:,6));
    geom_max = d1(ii,:);

    geom_tot=[geom_tot;geom_max];

    clear geom d1 ii geom_max
    toc
end

    excludelocs_1=load('c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HRDLocations\Locations_met_golven.dat');
    excludelocs_2=[170300050 19020005 200300084 210200184];
    excludelocs=[excludelocs_1; excludelocs_2'];
    index_excl=ismember(geom_tot(:,6), excludelocs);
    geom_tot=geom_tot(~index_excl,:);



x2=geom_tot(:,1)+cosd(90-geom_tot(:,3)).*geom_tot(:,5);
y2=geom_tot(:,2)+sind(90-geom_tot(:,3)).*geom_tot(:,5);
geom_tot=[geom_tot,x2,y2];


fid3=fopen('met_gedeelte_golven_max_fetch_combined.csv','wt');
fprintf(fid3,'%s\n','x,y,richting,B,FE,ID,x2,y2');
fprintf(fid3,'%.0f,%.0f,%.1f,%.6f,%.6f,%i,%.3f,%.3f\n',geom_tot');
fclose(fid3);
fclose all;



% Ori_shape


