function [mMu, mSig] = bepaalSigmaNormaal(m);

% m = zeewaterstand zonder onzekerheid

% BRON:
% Status data	Final: 27-08-15	
% Directions:	Omnidirectional	
% Type of uncertainty:	Additional	
% Distribution type:	Normal	
% 
% Distribution parameters:		
% Value	Mean	Standard deviation
% 2.83	0	0.02
% 2.93	0	0.02
% 3.57	0	0.065
% 4.26	0	0.1425
% 5.00	0	0.2575
% 5.78	0	0.4175


% Bepaal mu
mMu = 0;


% Bepaal sigma
A = [...
2.83	0.02
2.93	0.02
3.57	0.065
4.26	0.1425
5.00	0.2575
5.78	0.4175];

mSig = interp1(A(:,1), A(:,2), m, 'linear', 'extrap');



