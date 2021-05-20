function [TreeksChbab, ovkansenMeerpeilExOnzHeidChbab, ovkansenMeerpeilMetOnzHeidChbab]= bepaalGegevensChbab2015(...
    keuzeStation);


switch keuzeStation
    case 1  %IJsselmeer
        tabelChbab =[...
            10      0.39	0   	0.031	-0.79	-0.236	0.039	0.39
            100     0.62	0       0.067	-1.02	0.018	0.066	0.63
            1000	0.84	0   	0.136	-1.24	0.209	0.11	0.89
            10000	1.07	0       0.231	-1.47	0.373	0.156	1.2
            100000	1.3     0       0.35	-1.7	0.51	0.204	1.59];

    case 2  %Markermeer
        tabelChbab =[...
            10      0       0	0.024	-0.4	-0.918	0.059	0
            100     0.22	0	0.069	-0.62	-0.484	0.111	0.23
            1000	0.44	0	0.136	-0.84	-0.187	0.161	0.49
            10000	0.66	0	0.226	-1.06	0.036	0.211	0.8
            100000	0.89	0	0.348	-1.29	0.22	0.265	1.19];


end

TreeksChbab                     = tabelChbab(:,1);
ovkansenMeerpeilExOnzHeidChbab    = tabelChbab(:,2);
ovkansenMeerpeilMetOnzHeidChbab   = tabelChbab(:,end);