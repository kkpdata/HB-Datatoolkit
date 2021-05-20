close all; clear all; clc;
tic

HS_csv={
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HS_BR_17-1.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HS_BR_20-4.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HS_BR_21-2.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HS_BR_22-1.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HS_BR_22-2.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HS_BR_24-2.csv'
    };


WL_csv={
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_17-1.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_20-4.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_21-2.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_22-1.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_22-2.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_24-2.csv'
    };


for icsv=1:length(HS_csv)

    HS_data=csvread(HS_csv{icsv},1,0);
    WL_data=csvread(WL_csv{icsv},1,0);
    toc


    [I,J]=find(WL_data(:,2)==HS_data(:,1));
    check_complete(icsv,1)=length(WL_data)-sum(J);

    total{icsv}=[WL_data HS_data(I,2)];

    HS_gt_0=find(total{icsv}(:,6)>0);
    ID_gt_0{icsv}=unique(total{icsv}(HS_gt_0,1));





    fid1=fopen([HS_csv{icsv}(1:end-4) '_locs_met_golven.dat'],'wt');
    fprintf(fid1,'%i\n',ID_gt_0{icsv}');
    fclose(fid1);
    fclose all;

    toc
    clear HS_gt_0 I J HS_data WL_data

end



