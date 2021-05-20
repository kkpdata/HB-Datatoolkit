function [bpiek] = topduur(topduur_inv, piek)
%
%Door Chris Geerse
%Berekening van topduur b(y) bij gegeven y, dmv lineaire 
%interpolatie tussen aantal opgegeven puntenparen.
%
% Input:
% topduur_inv is een matrix met puntenparen (yi, b(yi)), met yi toenemend
%
% Output:
% topduur b(y)
%
%{
%==========================================================================
%Invoerparameters
%==========================================================================
%invoer b(y): eerste kolom is y, tweede is b(y).
topduur_inv = ...
    [0, 720;        %y moet toenemend zijn, voor b(y) geldt dat niet
    180, 48;
    900, 448];
%}


%==========================================================================
% Bepalen topduurfunctie b(y)
%==========================================================================
Ntraject = numel(topduur_inv(:,1));

if piek <= topduur_inv(1,1)
    bpiek = topduur_inv(1,2);
elseif piek <= topduur_inv(Ntraject,1)
    bpiek = interp1(topduur_inv(:,1),topduur_inv(:,2),piek);
else bpiek = topduur_inv(Ntraject,2);
end
