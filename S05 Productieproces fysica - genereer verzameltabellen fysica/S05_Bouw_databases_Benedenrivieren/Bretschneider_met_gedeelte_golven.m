close all; clear all; clc;
tic

Up2U10=load('c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\Up2U10.dat');


geom_files={
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_17-1_combined_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_20-4_combined_loc.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_21-2_combined_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_22-1_combined_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_22-2_combined_loc.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\Geometrie_combined\Geometrie_24-2_combined_loc.csv'
    };

data_files={
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_17-1.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_20-4.csv'
'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_21-2.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_22-1.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_22-2.csv'
% 'c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\WL_BR_24-2.csv'
    };


matnames={
% 'BR_17-1.mat'
% 'BR_20-4.mat'
'BR_21-2.mat'
% 'BR_22-1.mat'
% 'BR_22-2.mat'
% 'BR_24-2.mat'
};




for icsv=1:length(geom_files)

    geom=csvread(geom_files{icsv},1,0);
    %col1 = X
    %col2 = Y
    %col3 = dir
    %col4 = Bottom depth
    %col5 = Effective Fetch
    %col6 = HRDlocationId

    data=csvread(data_files{icsv},1,0);
    toc
    %col1 = HRDlocationId
    %col2 = HydroDynamicId
    %col3 = windspeed
    %col4 = winddir
    %col5 = WL

    excludelocs_1=load('c:\Projects\C03061.000391_Bouw_databases\Bretschneider_dec2017\matlab\met_gedeelte_golven\HRDLocations\Locations_met_golven.dat');
    excludelocs_2=[170300050 19020005 200300084 210200184];
    excludelocs=[excludelocs_1; excludelocs_2'];
    index_excl=ismember(data(:,1), excludelocs);
    data=data(~index_excl,:);


    U10 = INTERP1(Up2U10(:,1),Up2U10(:,2),data(:,3),'linear');

    save(matnames{icsv});
    toc
    clear data geom U10
    disp(['writing ' matnames{icsv} ' complete']);
    
end

%%

for icsv=1:length(geom_files)

    load(matnames{icsv});

    toc

%     excludelocs=[170300050 19020005 200300084];
%     index_excl=ismember(data(:,1), excludelocs);
%     data=data(~index_excl,:);

    [idxa, idxb] = ismember(data(:,[1 4]), geom(:,[6 3]),'rows');



    data(:,[6:7])=geom(idxb,[4:5]);
    data(:,8)=U10';
    data(:,9)=data(:,5)-data(:,6);
    data(data(:,9)<0,9)=0;





    g=9.81;
    Dslang=data(:,9)*g./(data(:,8).^2);
    Fslang=data(:,7)*g./(data(:,8).^2);
    Q=tanh(0.53*(Dslang.^0.75));
    R=0.0125*(Fslang.^0.42)./Q;
    Hslang=0.283.*Q.*tanh(R);


    X=tanh(0.833.*(Dslang.^0.375));
    Y=0.077*(Fslang.^0.25)./X;
    Tslang=2.4*pi.*X.*tanh(Y);

    Hs=Hslang.*(data(:,8).^2)/g;
    Tp=1.08.*data(:,8).*Tslang/g;

    data(:,10)=Hs;
    data(:,11)=Tp;
    data(:,12)=Tp/1.10;

    data(isnan(data))=0;


    HDRdata1=zeros(size(data,1),3);
    HDRdata2=zeros(size(data,1),3);
    HDRdata3=zeros(size(data,1),3);
    HDRdata4=zeros(size(data,1),3);


    HDRdata1(:,1)=data(:,2);
    HDRdata1(:,2)=2;
    HDRdata1(:,3)=data(:,10);

    HDRdata2(:,1)=data(:,2);
    HDRdata2(:,2)=3;
    HDRdata2(:,3)=data(:,11);

    HDRdata3(:,1)=data(:,2);
    HDRdata3(:,2)=4;
    HDRdata3(:,3)=data(:,12);

    HDRdata4(:,1)=data(:,2);
    HDRdata4(:,2)=5;
    HDRdata4(:,3)=data(:,4);

    HDRdata=[HDRdata1;HDRdata2;HDRdata3;HDRdata4];

    toc

    fout=fopen([matnames{icsv}(1:end-4) '_HydroDynamicResultData.csv'],'wt');
    fprintf(fout,'%s\n','HydroDynamicDataId,HRDResultColumnId,Value');
    fprintf(fout,'%i,%i,%.3f\n',HDRdata');
    fclose(fout);
    fclose all;
    toc
    clear data geom U10 HDRdata1 HDRdata2 HDRdata3 HDRdata4 Hs Tp Dslang Fslang Q R Hslang X Y

    disp(['writing ' [matnames{icsv}(1:end-4) '_HydroDynamicResultData.csv'] ' complete']);
    
end
toc

