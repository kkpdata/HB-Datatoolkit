close all; clear all; clc;
tic

%alle locaties openen uit de groep 'zonder golven'

fid=fopen('l:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\2_Coupled_HRDLocID\HRDLocations\Zonder_golven\HRDLocations_zonder_golven.csv');
AAA=textscan(fid,'%d %s %f64 %f64','delimiter',';','Headerlines',1,'CollectOutput',1);
fclose(fid);

BBB=AAA{1,3};
CCC=round(BBB);                     % afronden van de coordinaten, aangezien dit ook gedaan is door Hydra-NL
[ddd,DDD]=unique(CCC,'rows');       % dubbele punten eruit halen
toc

fid2={
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\1_Hydra_output\Zonder_golven\16-3_v03_original.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\1_Hydra_output\Zonder_golven\15-2_v03_original.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\1_Hydra_output\Zonder_golven\15-1_v03_original.csv'
'L:\C03061\C03061.000391_Bouw_databases_Benedenrivieren\03_work\04_Bretschneider_feb2018\csv\1_Hydra_output\Zonder_golven\24-3_v03_original.csv'
    };      %alle geometrieën met de originele hydra-nl shape

for i=1:length(fid2)
    fid2new{i}=[fid2{i}(1:end-4) '_loc.csv'];
end

for i=1:length(fid2)

    fid2b = fopen(fid2{i},'r');    %opening
    inter = textscan(fid2b,'%s','delimiter','\n');
    lines= inter{1,1};
    close all;
    
    %Import depth file
    %Arc{i} = dlmread(fid2{i},',',1,0);
    Arc{i}=csvread(fid2{i},1,0);    % LET OP: Vanwege een vreemde tekencombinatie in de eerste regel van de csv's heb ik de eerste regel
        %uit de csv's gekopieerd naar de 2e regel en sla ik de eerste over!
        
    [idxa, idxb] = ismember(Arc{i}(:,[1 2]), CCC(:,[1 2]),'rows');
    Arc{i}(:,6)=AAA{1}(idxb);

    fid3=fopen(fid2new{i},'wt');
    %fprintf(fid3,'%s\n',lines{1});
    fprintf(fid3,'%.0f,%.0f,%.1f,%.6f,%.6f,%i\n',Arc{i}');
    fclose(fid3);
    fclose all;

    clear lines inter idxa idxb
    toc
end

toc
