function SortRes=Rearrange( DatRes )
%Rearrange the struct such that locations are in order

for i = 1:size(DatRes(5).name,2)
    locname = DatRes(5).name{i};
    ind = strfind(locname,'_');
    locnum = str2num(locname(ind(end)+1:end));
    if locnum < 1000
        DatRes(5).name{i} = [locname(1:ind(end)), num2str(locnum,'%04d')];
    end
end     

[SortRes(5).name, ipiv] = sort(DatRes(5).name);

SortRes(5).x = DatRes(5).x(ipiv);
SortRes(5).y = DatRes(5).y(ipiv);
for i = 1:6
    if isfield(DatRes(i),'WS') SortRes(i).WS = DatRes(i).WS(ipiv); end
    if isfield(DatRes(i),'HS') SortRes(i).HS = DatRes(i).HS(ipiv); end
    if isfield(DatRes(i),'TM') SortRes(i).TM = DatRes(i).TM(ipiv); end
    if isfield(DatRes(i),'HB1') SortRes(i).HB1 = DatRes(i).HB1(ipiv); end
    if isfield(DatRes(i),'HB2') SortRes(i).HB2 = DatRes(i).HB2(ipiv); end
end