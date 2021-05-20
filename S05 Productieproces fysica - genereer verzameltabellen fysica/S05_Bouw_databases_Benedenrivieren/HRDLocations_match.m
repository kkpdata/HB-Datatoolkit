close all; clear all; clc;
tic


%alle locaties openen uit de groep 'zonder golven'

fid=fopen('c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\HRDLocations\HRDLocations_zonder_golven.csv');
AAA=textscan(fid,'%d %s %f64 %f64','delimiter',',','Headerlines',1,'CollectOutput',1);
fclose(fid);



BBB=AAA{1,3};
CCC=round(BBB);                     % afronden van de coordinaten, aangezien dit ook gedaan is door Hydra-NL
[ddd,DDD]=unique(CCC,'rows');       % dubbele punten eruit halen
toc

fid2={
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_209b_Arcadis.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_208b_Arcadis.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_20-3_Arcadis.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_19-1b_Arcadis.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_18-1_Arcadis.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_17-3_Arcadis.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_17-2_Arcadis.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_14-3_Arcadis.csv'
    'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\zonder_golven\Geometrie_14-2_Arcadis.csv'
    };


for i=1:length(fid2)
    fid2new{i}=[fid2{i}(1:end-4) '_loc.csv'];
end


for i=1:length(fid2)

    fid2b = fopen(fid2{i},'r');    %opening
    inter = textscan(fid2b,'%s','delimiter','\n');
    lines= inter{1,1};
    close all;

    %     for iline=2:length(inter{1})
    %         geom = cellfun(@(x) textscan(x,'%s','delimiter',','), inter{1}{iline}, 'UniformOutput', true);
    %     end

    Arc{i}=csvread(fid2{i},1,0);
    [idxa, idxb] = ismember(Arc{i}(:,[1 2]), CCC(:,[1 2]),'rows');
    Arc{i}(:,6)=AAA{1}(idxb);

    fid3=fopen(fid2new{i},'wt');
    fprintf(fid3,'%s\n',lines{1});
    fprintf(fid3,'%.0f,%.0f,%.1f,%.6f,%.6f,%i\n',Arc{i}');
    fclose(fid3);
    fclose all;

    clear lines inter idxa idxb
    toc
end


toc















toc
