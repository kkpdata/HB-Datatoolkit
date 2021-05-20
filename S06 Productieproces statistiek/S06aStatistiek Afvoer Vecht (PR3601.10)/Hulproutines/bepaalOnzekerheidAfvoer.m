function [kMu, kSig, kEps] = bepaalOnzekerheidAfvoer(kGrid);

% Bronnen: 
% Gegevens uit directory:
% "WTI2017 Stochastic data deliveries_via Karolina verkregen".

% [Chbab, 2015]
% Basisstochasten WTI-2017. Statistiek en statistische onzekerheid. 
% Houcine Cbab. Kenmerk 1209433-012-HYE-0007, 2 december 2015, definitief. 
% 
%             200	0	5.7682  	-116
%             216	0	5.7682      -116
%             263	0	10.30396	-163
%             299	0	14.10251	-199
%             335	0	35.80128	-235
%             383	0	46.32343	-283
%             419	0	63.58193	-319
%             466	0	84.17529	-366
%             502	0	97.67887	-402
%             550	0	117.03963	-450
%             574	0	127.75738	-474
%             610	0	140.96913	-510
%             658	0	159.4284	-558
%             694	0	171.70035	-594
%             741	0	193.47115	-641
%             777	0	202.843     -677];

%Dalfsen (lognormaal)     Aanpassing van  [Chbab, 2015]

        A = [...
            100	0	0.01    	0
            200	0	5.7682      -100
            216	0	5.7682      -116    %vanaf 216 m3/s gegevens uit [Chbab, 2015]
            263	0	10.30396	-163
            299	0	14.10251	-199
            335	0	35.80128	-235
            383	0	46.32343	-283
            419	0	63.58193	-319
            466	0	84.17529	-366
            502	0	97.67887	-402
            550	0	117.03963	-450
            574	0	127.75738	-474
            610	0	140.96913	-510
            658	0	159.4284	-558
            694	0	171.70035	-594
            741	0	193.47115	-641
            777	0	202.843     -677];

kMu  = interp1(A(:,1), A(:,2), kGrid, 'linear', 'extrap');
kSig = interp1(A(:,1), A(:,3), kGrid, 'linear', 'extrap');
kEps = interp1(A(:,1), A(:,4), kGrid, 'linear', 'extrap');
