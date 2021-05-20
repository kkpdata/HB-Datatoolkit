function DatRes=BerekenDecimeringsHoogte( DatRes )
%Bereken de decimeringshoogten in de locaties

DatRes(5).dHW1 = DatRes(6).WS - DatRes(5).WS;
DatRes(5).dHW2 = DatRes(5).WS - DatRes(3).WS;
DatRes(5).dHW3 = (DatRes(5).WS - DatRes(5).WS_as) - (DatRes(3).WS - DatRes(3).WS_as);
DatRes(5).dHW = (abs(DatRes(6).WS - DatRes(5).WS) + abs(DatRes(5).WS - DatRes(3).WS))/2.;
if isfield(DatRes(5), 'HB1')
    DatRes(5).dHB1 = (abs(DatRes(6).HB1 - DatRes(5).HB1) + abs(DatRes(5).HB1 - DatRes(3).HB1))/2.;
    DatRes(5).dHB1W = DatRes(5).dHB1 ./ DatRes(5).dHW;
end
if isfield(DatRes(5), 'HB2')
    DatRes(5).dHB2 = (abs(DatRes(6).HB2 - DatRes(5).HB2) + abs(DatRes(5).HB2 - DatRes(3).HB2))/2.;
    DatRes(5).dHB2W = DatRes(5).dHB2 ./ DatRes(5).dHW;
end

end

