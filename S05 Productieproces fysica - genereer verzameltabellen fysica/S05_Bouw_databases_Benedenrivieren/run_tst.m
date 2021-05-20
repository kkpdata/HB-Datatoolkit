fid_prt = fopen('c:\projects\RWS\Bouwen_databases\run01\run01_tst1.csv','w');
fid_log = fopen('c:\projects\RWS\Bouwen_databases\run01\run01_tst.log','w');
%
%%load 'c:\projects\RWS\Bouwen_databases\run01\workspace_Selectie01.mat'
ier=ProcessComputation('wRMM-Q04U11D225ZP604','_riv_001',fid_log, fid_prt,n_tst,tstStat,'g:\WBI_data\RMM\1.Waterstanden\','c:\projects\RWS\Bouwen_databases\workdir\');
ier=ProcessComputation('wRMM-Q01U11D247ZP604','_riv_001',fid_log, fid_prt,n_tst,tstStat,'g:\WBI_data\RMM\1.Waterstanden\','c:\projects\RWS\Bouwen_databases\workdir\');
ier=ProcessComputation('wRMM-Q01U11D270ZP604','_riv_001',fid_log, fid_prt,n_tst,tstStat,'g:\WBI_data\RMM\1.Waterstanden\','c:\projects\RWS\Bouwen_databases\workdir\');
ier=ProcessComputation('wRMM-Q01U11D292ZP604','_riv_001',fid_log, fid_prt,n_tst,tstStat,'g:\WBI_data\RMM\1.Waterstanden\','c:\projects\RWS\Bouwen_databases\workdir\');
ier=ProcessComputation('wRMM-Q01U11D360ZP604','_riv_001',fid_log, fid_prt,n_tst,tstStat,'g:\WBI_data\RMM\1.Waterstanden\','c:\projects\RWS\Bouwen_databases\workdir\');

fclose(fid_prt);
fclose(fid_log);