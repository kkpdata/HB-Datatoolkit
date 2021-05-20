close all; clear all; clc;
tic


%alle locaties openen uit de groep 'met gedeelte golven'

fid=fopen('c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HRDLocations\HRDLocations_met_gedeelte_golven.csv');
AAA=textscan(fid,'%d %s %f64 %f64','delimiter',',','Headerlines',1,'CollectOutput',1);
fclose(fid);



BBB=AAA{1,3};
CCC=round(BBB);                     % afronden van de coordinaten, aangezien dit ook gedaan is door Hydra-NL
[ddd,DDD]=unique(CCC,'rows');       % dubbele punten eruit halen
toc

fid2={
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\original_shape\Geometrie_17-1_original.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\original_shape\Geometrie_20-4_original.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\original_shape\Geometrie_21-2_original.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\original_shape\Geometrie_22-1_original.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\original_shape\Geometrie_22-2_original.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\original_shape\Geometrie_24-2_original.csv'
    };      %alle geometrieën met de original shape


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
