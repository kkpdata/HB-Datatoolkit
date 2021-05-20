function [kMuNorm, kSigNorm] = bepaalOnzekerheidAfvoerNieuw(kGrid);


%Dalfsen nieuw (normaal), keuze Chris Geerse

A = [...
    0       0       0.0001
    216.0	0	    8
    263.5	0	    12
    299.5	0	    15
    335.4	0    	27
    383.0	0	    42
    419.0	0   	55
    458.8	0   	60
    489.5	10  	60
    530.2	20   	50
    551.1	16  	47
    581.9	11	    42
    609.4	7   	37
    623.4	4	    35
    636.7	0	    32
    642.6	0    	30
    661.6	0   	30
    1000    0       30];


kMuNorm  = interp1(A(:,1), A(:,2), kGrid, 'linear', 'extrap');
kSigNorm = interp1(A(:,1), A(:,3), kGrid, 'linear', 'extrap');

