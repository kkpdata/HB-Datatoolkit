


% tabel = [berek_trap.y, berek_trap.Gy_mom, berek_trap.Gy_mom];
tabel = [berek_trap.y'; berek_trap.Gy_mom'; berek_trap.Gy_mom'];

% inhoud_tabel_VZM  = [jaar_nw, maand_nw, dag_nw, mp_max];
% save([uitvoerpad,'mp_dagmaxima_VZM_1998_2011.txt'],'inhoud_tabel_VZM','-ascii')

% x = 0:.1:1; y = [x; exp(x)];
% fid = fopen('exp.txt','wt');
% fprintf(fid,'%6.2f  %12.8f\n',y);
% fclose(fid);


fid = fopen([uitvoerpad,'momkansen_VZM_v01.txt'],'wt');
fprintf(fid,'%10.2f             %1.3E             %1.3E\n', tabel);
fclose(fid);