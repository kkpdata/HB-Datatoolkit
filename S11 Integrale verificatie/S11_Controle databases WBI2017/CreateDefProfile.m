function CreateDefProfile(dbname)

DirDijknormaal = 'c:\projects\RWS\Controle_Ringtoets\Testen met SQLite-databases\Dijknormalen\'; %'c:\projects\RWS\Controle_Ringtoets\WBI2017\Profielbestanden\Dijknormalen\'; %'c:\projects\RWS\Aanpassing ProfielGenerator\Dijknormalen\';
DirPLB = 'c:\projects\RWS\Controle_Ringtoets\Testen met SQLite-databases\Profielbestanden\'; %'c:\projects\RWS\Controle_Ringtoets\WBI2017\Profielbestanden\'; %'c:\projects\RWS\Aanpassing ProfielGenerator\Profielbestanden\';

GenerateDefPLB(DirDijknormaal, DirPLB,dbname);

end
