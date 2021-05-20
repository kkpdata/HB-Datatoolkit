IDsFile = 'p:\1230087-hydraulische-belastingen\1. Hydraulische Randvoorwaarden\4. MakingSummaryTables\MetaInfo\20170623_locIDs_x_y_loctype_semicolon.csv';
matFileDir  = 'D:\checkouts\hring_scripts\matlab\RingToets_LocationDefaults\matFiles';

GenerateSettingsMatFiles_BOR(IDsFile, matFileDir)                % Bovenrivieren 1 2 18
GenerateSettingsMatFiles_BER_sep(IDsFile, matFileDir)            % Benedenrivieren 3
GenerateSettingsMatFiles_BER_04(IDsFile, matFileDir)             % Benedenrivieren 4
GenerateSettingsMatFiles_IJVD_IJsseldelta(IDsFile, matFileDir)   % IJsseldelta 5
GenerateSettingsMatFiles_IJVD_Vechtdelta(IDsFile, matFileDir)    % Vechtdelta 6
GenerateSettingsMatFiles_Meren(IDsFile, matFileDir)              % Meren 7 8
GenerateSettingsMatFiles_KUST(IDsFile, matFileDir)               % Kust 9 10 11 12 13 15
GenerateSettingsMatFiles_OS(IDsFile, matFileDir)                 % Oosterschelde 14
GenerateSettingsMatFiles_Duinen(IDsFile, matFileDir)             % Duinen 16
GenerateSettingsMatFiles_Europoort(IDsFile, matFileDir)          % Europoort 17
GenerateSettingsMatFiles_Grevelingen(IDsFile, matFileDir)          % Grevelingen 19
GenerateSettingsMatFiles_Veluwerandmeren(IDsFile, matFileDir)      % Veluwerandmeren 20

GenerateSettingsCSVFiles % Convert all .mat files to csv files used to generate -config.sqlite dbs

