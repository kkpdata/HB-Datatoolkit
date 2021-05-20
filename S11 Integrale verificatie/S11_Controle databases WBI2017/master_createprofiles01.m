close all; clear all; clc;
tic
% addpath('l:\C03061\C03061.000303_controle databases wbi2017\04_Work\Matlab\');


traject={
    'R_14-1'
    'R_14-2'
    'R_14-3'
    'R_15-1'
    'R_15-2'
    'R_15-3'
    'R_16-1'
    'R_16-2'
    'R_16-3'
    'R_16-4'
    'R_17-1'
    'R_17-2'
    'R_17-3'
    'R_18-1'
    'R_19-1_208_209'    %'R_19-1_209_N10'
    'R_20-3'
    'R_20-4'
    'R_210'
    'R_211'
    'R_21-1'
    'R_212'
    'R_21-2'
    'R_213'
    'R_215'
    'R_22-1'
    'R_22-2'
    'R_224'
    'R_23-1'     %     'R_23-1'      %geen dijknormalen
    'R_24-2'
    'R_24-3'
    'R_25-2'
    'R_34-1'
    'R_34-2'
    'R_34a-1'
    'R_35-2'
    'R_38-1'
    'R_40-1'
    'R_41-2'
    'R_43-5'
    'R_43-6'
    'R_44-1'};
%    'R_43-6'};

for i=1:length(traject)
    dbname{i,1}=['GR2017_Benedenrijn' traject{i}(2:end) '_v01'];
    CreateProfile(traject{i}, dbname{i});
end
toc




