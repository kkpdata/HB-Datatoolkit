function wegschrijven_data(type_data,text_data,sNaam,X,r,onzType)

switch type_data
    case 'afvoer'

        fid = fopen(['Ovkans_',text_data,'_piekafvoer_Hydra-NL_met_SO.txt'],'wt');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n',['* Overschrijdingskansen piekwaarde ',text_data]);
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n',['* Piekwaarde ',text_data,'           overschrijdingskans']);
        fprintf(fid,'%s\n','*          [m3/s]                   [-]');

        fprintf(fid,'            %6.1f            %10.8f \n',X');

        fclose all;

    case 'meerpeil'

        fid = fopen(['Ovkans_',text_data,'_peakmeerpeil_met_SO.txt'],'wt');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n',['* Overschrijdingskansen piekwaarde ',text_data]);
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n',['* Piekwaarde ',text_data,'       overschrijdingskans']);
        fprintf(fid,'%s\n','*          [m+NAP]                    [-]');

        fprintf(fid,'            %6.1f                   %10.8f \n',X');

        fclose all;

    case 'wind'

        fid = fopen(['Ovkanswind_',text_data,'.txt'],'wt');
        fprintf(fid,'%s\n','*');
        
        if onzType==0
            fprintf(fid,'%s\n',['* Overschrijdingskansen potentiele windsnelheid ',sNaam,'. Zonder statistische onzekerheid.']);
        elseif onzType==1
            fprintf(fid,'%s\n',['* Overschrijdingskansen potentiele windsnelheid ',sNaam,'. Met statistische onzekerheid.']);
        end
        
        fprintf(fid,'%s\n','* WTI2017: 12-uursmaxima, gegeven windrichting');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','* Door: Chris Geerse van HKV lijn in water');
        fprintf(fid,'%s\n','* Project: PR3556.10');
        fprintf(fid,'%s\n','* Datum: augustus 2017');
        fprintf(fid,'%s\n','*');
        
        if r == 16
            fprintf(fid,'%s\n','* u         NNO            NO             ONO            O              OZO            ZO             ZZO            Z              ZZW            ZW             WZW            W              WNW            NW             NNW            N');
            fprintf(fid,['%6.2f',repmat('      %1.3e',1,16),' \n'],X');
        elseif r == 12
            fprintf(fid,'%s\n','* u (m/s)   30              60              90              120             150             180             210             240             270             300             330             360');
            fprintf(fid,['%6.2f',repmat('      %1.3e',1,12),' \n'],X');
        end

        fclose all;

    case 'zeewaterstand_Tabel'

        fid = fopen('ConditionelePovZeestandenMM_12u_1985_met_SO.txt','wt');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','* Conditionele overschrijdingskans zeewaterstand Maasmond 1985, per windrichting, voor 12-uursperioden.');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','*');
        fprintf(fid,'%s\n','%m+NAP  NNO            NO             ONO            O              OZO            ZO             ZZO            Z              ZZW            ZW             WZW            W              WNW            NW             NNW            N');

        fprintf(fid,['%6.1f',repmat('      %1.2e',1,16),' \n'],X');

        fclose all;

    case 'zeewaterstand_Weibull'
% weggehaald...


end