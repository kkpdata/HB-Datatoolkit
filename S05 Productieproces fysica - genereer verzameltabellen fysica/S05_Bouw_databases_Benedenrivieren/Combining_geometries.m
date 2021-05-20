close all; clear all; clc;
tic

Arc_csv={
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Arcadis_shape\Geometrie_17-1_Arcadis_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Arcadis_shape\Geometrie_20-4_Arcadis_loc.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Arcadis_shape\Geometrie_21-2_Arcadis_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Arcadis_shape\Geometrie_22-1_Arcadis_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Arcadis_shape\Geometrie_22-2_Arcadis_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Arcadis_shape\Geometrie_24-2_Arcadis_loc.csv'
    };

ori_csv={
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Original_shape\Geometrie_17-1_original_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Original_shape\Geometrie_20-4_original_loc.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Original_shape\Geometrie_21-2_original_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Original_shape\Geometrie_22-1_original_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Original_shape\Geometrie_22-2_original_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Original_shape\Geometrie_24-2_original_loc.csv'
    };

%col1 = X
%col2 = Y
%col3 = dir
%col4 = Bottom depth
%col5 = Effective Fetch
%col6 = HRDlocationId

%col7 = Bottom depth ori
%col8 = Effective Fetch ori

for icsv=1:length(Arc_csv)

    Arc_data=csvread(Arc_csv{icsv},1,0);
    ori_data=csvread(ori_csv{icsv},1,0);

    [idxa, idxb] = ismember(Arc_data(:,[6 3]), ori_data(:,[6 3]),'rows');
    total_data=Arc_data;
    total_data(:,[7:8])=ori_data(idxb,[4:5]);

    diff_fetch{icsv}=total_data(:,8)-total_data(:,5);
    FE_0_Arc{icsv}=find(total_data(:,5)==0);
    FE_diff{icsv}=find(diff_fetch{icsv}~=0);
    BE_0_Arc{icsv}=find(total_data(:,4)==0);
    BE_0_Ori{icsv}=find(total_data(:,7)==0);



    if isempty(BE_0_Arc{icsv})
        comb_data{icsv}=total_data(:,1:6);
    else
        comb_data{icsv}=total_data(:,1:6);
        comb_data{icsv}(BE_0_Arc{icsv},4)=total_data(BE_0_Arc{icsv},7);
    end

fid3=fopen(['c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\' Arc_csv{icsv}(105:end) ],'wt');
fprintf(fid3,'%s\n','x,y,richting,B,FE,ID');
fprintf(fid3,'%.0f,%.0f,%.1f,%.6f,%.6f,%i\n',comb_data{icsv}');
fclose(fid3);
fclose all;
    

    clear total_data idxa idxb Arc_data ori_data fid3
    toc
end



