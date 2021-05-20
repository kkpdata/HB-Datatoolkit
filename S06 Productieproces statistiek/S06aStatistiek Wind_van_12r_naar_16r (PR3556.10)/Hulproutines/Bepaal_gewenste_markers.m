function [alle_markers_r, alle_markers_w] = Bepaal_gewenste_markers();

% 
% % Geef "zinvolle" markers, met za een gestreepte lijn.
% 
% Door: Chris Geerse
% Datum:oktober 2012


alle_markers_r  = {...
    '-',...		%	1	    'NNO'	
    '--',...		%	2	    'NO'	
    '-',...		%	3	    'ONO'	
    'o--',...		%	4	    'O'	
    '-',...		%	5	    'OZO'	
    '--',...		%	6	    'ZO'	
    '-',...		%	7	    'ZZO'	
    'o--',...		%	8	    'Z'	
    '-',...		%	9	    'ZZW'	
    '--',...		%	10	    'ZW'	
    '-',...		%	11	    'WZW'	
    'o--',...		%	12	    'W'	
    '-',...		%	13	    'WNW'	
    '--',...		%	14	    'NW'	
    '-',...		%	15	    'NNW'	
    'o--',...		%	16	    'N'	
    '--'};      %   omni    'OMNI'

alle_markers_w  = {...
    '-',...		%	1	    '30'	
    '--',...		%	2	    '60'	
    'o-',...		%	3	    '90'	
    '--',...		%	4	    '120'	
    '-',...		%	5	    '150'	
    'o--',...		%	6	    '180'	
    '-',...		%	7	    '210'	
    '--',...		%	8	    '240'	
    'o-',...		%	9	    '270'	
    '--',...		%	10	    '300'	
    '-',...		%	11	    '330'	
    'o--',...		%	12	    '360'	
    '--'};      %   omni    'OMNI'
