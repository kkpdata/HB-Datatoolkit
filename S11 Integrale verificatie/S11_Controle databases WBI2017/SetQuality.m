function DatRes=SetQuality( logfile, dbname, DatRes )
%Doe de testen en zet de quality code

flog=fopen(logfile, 'a');

Hsmin = 0.15;
Tmmin = 0.15;
Hsmax = 5.0;
Tmmax = 20.0;
WSmax = 15.0;
HBmax = 20.0;
dWSmax = 0.20;
dHBmax = 0.50;
dHSmax = 0.40;
dTMmax = 1.0;

DatRes(5).Qcode(1:size(DatRes(5).x,2)) = 0;

%check for non existing results (errors during computation)
DatRes(5).Qcode(find(DatRes(5).WS == -99)) = 1;
DatRes(5).Qcode(find(DatRes(5).HS == -99)) = 1;
DatRes(5).Qcode(find(DatRes(5).TM == -99)) = 1;
DatRes(5).Qcode(find(DatRes(5).HB1 == -99)) = 1;
DatRes(5).Qcode(find(DatRes(5).HB2 == -99)) = 1;

%resultaat NaN
DatRes(5).Qcode(find(isnan(DatRes(5).WS) & DatRes(5).Qcode == 0)) = 1;
DatRes(5).Qcode(find(isnan(DatRes(5).HB1) & DatRes(5).Qcode == 0)) = 1;
DatRes(5).Qcode(find(isnan(DatRes(5).HB2) & DatRes(5).Qcode == 0)) = 1;
DatRes(5).Qcode(find(isnan(DatRes(5).HS) & DatRes(5).Qcode == 0)) = 1;
DatRes(5).Qcode(find(isnan(DatRes(5).TM) & DatRes(5).Qcode == 0)) = 1;

DatRes(5).Qcode(find(DatRes(5).dHW1 < 0.05 & DatRes(5).Qcode == 0)) = 2;
DatRes(5).Qcode(find(DatRes(5).dHW2 < 0.05 & DatRes(5).Qcode == 0)) = 3;

DatRes(5).Qcode(find(DatRes(5).dHB1W < 0.95 & DatRes(5).Qcode == 0)) = 6;
DatRes(5).Qcode(find(DatRes(5).dHB2W < 0.95 & DatRes(5).Qcode == 0)) = 6;

%monotoon stijgend bij afnemende frequentie
DatRes(5).Qcode(find(DatRes(2).WS - DatRes(1).WS <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(3).WS - DatRes(2).WS <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(4).WS - DatRes(3).WS <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(5).WS - DatRes(4).WS <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(6).WS - DatRes(5).WS <= 0 & DatRes(5).Qcode == 0)) = 7;

DatRes(5).Qcode(find(DatRes(2).HB1 - DatRes(1).HB1 <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(3).HB1 - DatRes(2).HB1 <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(4).HB1 - DatRes(3).HB1 <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(5).HB1 - DatRes(4).HB1 <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(6).HB1 - DatRes(5).HB1 <= 0 & DatRes(5).Qcode == 0)) = 7;

DatRes(5).Qcode(find(DatRes(2).HB2 - DatRes(1).HB2 <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(3).HB2 - DatRes(2).HB2 <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(4).HB2 - DatRes(3).HB2 <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(5).HB2 - DatRes(4).HB2 <= 0 & DatRes(5).Qcode == 0)) = 7;
DatRes(5).Qcode(find(DatRes(6).HB2 - DatRes(5).HB2 <= 0 & DatRes(5).Qcode == 0)) = 7;

%geen golven
DatRes(5).Qcode(find(DatRes(5).HS < Hsmin & DatRes(5).Qcode == 0)) = 8;
DatRes(5).Qcode(find(DatRes(5).TM < Tmmin & DatRes(5).Qcode == 0)) = 8;

%onrealistische waarden
DatRes(5).Qcode(find(DatRes(5).HS > Hsmax & DatRes(5).Qcode == 0)) = 9;
DatRes(5).Qcode(find(DatRes(5).TM > Tmmax & DatRes(5).Qcode == 0)) = 9;
DatRes(5).Qcode(find(DatRes(5).WS > WSmax & DatRes(5).Qcode == 0)) = 9;
DatRes(5).Qcode(find(DatRes(5).HB1 > HBmax & DatRes(5).Qcode == 0)) = 9;
DatRes(5).Qcode(find(DatRes(5).HB2 > HBmax & DatRes(5).Qcode == 0)) = 9;

%naastliggende locaties
DatRes(5).dl_WS(1) = 0;
DatRes(5).dl_HB1(1) = 0;
DatRes(5).dl_HB2(1) = 0;
DatRes(5).dl_HS(1) = 0;
DatRes(5).dl_TM(1) = 0;
for i = 2:size(DatRes(5).x,2)
    dx = DatRes(5).x(i) - DatRes(5).x(i-1);
    dy = DatRes(5).y(i) - DatRes(5).y(i-1);
    dl = sqrt(dx^2 + dy^2);
    DatRes(5).dl_WS(i) = NaN;
    DatRes(5).dl_HB1(i) = NaN;
    DatRes(5).dl_HB2(i) = NaN;
    DatRes(5).dl_HS(i) = NaN;
    DatRes(5).dl_TM(i) = NaN;
    if dl < 300.
        DatRes(5).dl_WS(i) = abs(DatRes(5).WS(i) - DatRes(5).WS(i-1));
        DatRes(5).dl_HB1(i) = abs(DatRes(5).HB1(i) - DatRes(5).HB1(i-1));
        DatRes(5).dl_HB2(i) = abs(DatRes(5).HB2(i) - DatRes(5).HB2(i-1));
        DatRes(5).dl_HS(i) = abs(DatRes(5).HS(i) - DatRes(5).HS(i-1));
        DatRes(5).dl_TM(i) = abs(DatRes(5).TM(i) - DatRes(5).TM(i-1));
        if  DatRes(5).dl_WS(i)  > dWSmax*dl/100. && DatRes(5).Qcode(i-1) && DatRes(5).Qcode(i) == 0
            DatRes(5).Qcode(i) = 10;
        end
        if  DatRes(5).dl_HB1(i) > dHBmax*dl/100. && DatRes(5).Qcode(i-1) && DatRes(5).Qcode(i) == 0
            DatRes(5).Qcode(i) = 11;
        end
        if  DatRes(5).dl_HB2(i) > dHBmax*dl/100. && DatRes(5).Qcode(i-1) && DatRes(5).Qcode(i) == 0
            DatRes(5).Qcode(i) = 11;
        end
        if  DatRes(5).dl_HS(i) > dHSmax*dl/100. && DatRes(5).Qcode(i-1) && DatRes(5).Qcode(i) == 0
            DatRes(5).Qcode(i) = 12;
        end
        if  DatRes(5).dl_TM(i) > dTMmax*dl/100. && DatRes(5).Qcode(i-1) && DatRes(5).Qcode(i) == 0
            DatRes(5).Qcode(i) = 13;
        end
    else
        fprintf(flog,'%s,%s,%8.2f,%8.2f,%s\r\n', dbname, char(DatRes(5).name(i)), DatRes(5).x(i), DatRes(5).y(i), 'Distance greater than 300 m');
    end
end

DatRes(5).Qcode(find(DatRes(5).dHW3 > 0.10 & DatRes(5).Qcode == 0)) = 4;    %% 0.05

DatRes(5).Qcode(find(abs(DatRes(5).WS - DatRes(5).WS_as) > 0.15 & DatRes(5).Qcode == 0)) = 5;  %% 0.15

fclose(flog);

end


        