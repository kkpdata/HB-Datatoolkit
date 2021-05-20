close all; clear all; clc;
tic

% Combineren van de locaties zonder golven met de Arcadis en original shapefile

Arc_csv={
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Zonder_golven\24-3_v03_arcadis_loc.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Zonder_golven\15-1_v03_arcadis_loc.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Zonder_golven\15-2_v03_arcadis_loc.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Zonder_golven\16-3_v03_arcadis_loc.csv'
    };

ori_csv={
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Zonder_golven\24-3_v03_original_loc.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Zonder_golven\15-1_v03_original_loc.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Zonder_golven\15-2_v03_original_loc.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\Zonder_golven\16-3_v03_original_loc.csv'
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

    Arc_data=csvread(Arc_csv{icsv},0,0);
    ori_data=csvread(ori_csv{icsv},0,0);

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

    fid3=fopen(['l:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\3_Combined\Zonder_golven\' Arc_csv{icsv}(126:end)],'wt');
    fprintf(fid3,'%s\n','x,y,richting,B,FE,ID');
    fprintf(fid3,'%.0f,%.0f,%.1f,%.6f,%.6f,%i\n',comb_data{icsv}');
    fclose(fid3);
    fclose all;
    
    clear total_data idxa idxb Arc_data ori_data fid3
    toc
end



