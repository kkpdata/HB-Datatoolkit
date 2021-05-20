function [sMu, sSig, sSigBreed, sEps, A, Abreed] = bepaalOnzekerheidMeerpeil(keuzeStation, sGrid);

% sEps is minus de verschuiving die Y moet ondergaan om W te krijgen;
% sMu, sSig zijn de parameters van de verdeling Y uit par 3.6.3 van
% rapport [Geerse, 2016], PR3262.10.


% Decimeringswaarden van de meren:
dIJM = 0.223;   %m
dMM  = 0.222;
dVRM = 0.230;
dVZM = 0.178;
dGRV = 0.060;


switch keuzeStation
    
    case 1  %IJsselmeer (lognormaal)
        %Value	Mean	St.dev.	Epsilon
        A = [...
            -0.4    0   0.00001   0       %later toegevoegd tbv PR3280.20
            %0.29	0	0.03052	-0.69   %oude std en eps: 0.03052, -0.79
            0.39	0	0.03052	-0.79
            0.62	0	0.06704	-1.02
            0.84	0	0.13628	-1.24
            1.07	0	0.23125	-1.47
            1.3     0	0.34973	-1.70];
        
        % Voor eventuele verbreding van de banden
        Abreed = A;   %Voor dit meer geen verbreding
        
    case 2  %Markermeer (lognormaal)
        A = [...
            -0.4    0   0.00001   0       %begin veranderd t.b.v. PR3280.20
            %-0.1    0	0.02354	-0.4
            0       0	0.02354	-0.4
            0.22	0	0.06898	-0.62
            0.44	0	0.13608	-0.84
            0.66	0	0.22613	-1.06
            0.89	0	0.34757	-1.29];
        
        Abreed = A;   %Voor dit meer geen verbreding
        
    case 3  %VRM (lognormaal); kies sigma per T hetzefde als Markermeer. Kies eps = -s + streefpeil
        A = [...
            -0.3    0   0.00001    0
            0.06    0	0.02354	 -0.36      %T = 10 jaar
            0.29	0	0.06898	 -0.59      %T = 100 jaar
            0.52	0	0.13608	 -0.82      %T = 1000 jaar
            0.75	0	0.22613	 -1.05      %T = 10^4 jaar
            0.98	0	0.34757	 -1.28];     %T = 10^5 jaar
        %Corrigeer voor andere decimeringswaarde:
        A(:,3) = dVRM/dMM*A(:,3);
        
        Abreed = A;   %Voor dit meer geen verbreding
        
    case 4  %VZM (lognormaal); tune op Markermeer
%         % Keuze uit PR3280.10
%                 A = [...
%                     -0.1    0   0.00001    0
%                     0.40	0	0.02354	-0.500
%                     0.58	0	0.06898	-0.68
%                     0.76	0	0.13608	-0.86
%                     0.93	0	0.22613	-1.03
%                     1.11	0	0.34757	-1.21];
%                 %Corrigeer voor andere decimeringswaarde:
%                 A(:,3) = dVZM/dMM*A(:,3);
%         
%                 % Voeg vergroting toe door onzekerheid streefpeil:
%                 Abreed      = A;    %Maak vooreerst gelijk aan A
%                 % Keuzes voor 0.2 m extra bredere banden:
%                 Abreed(:,3) = A(:,3) + [0.0, 0.0515, 0.0515, 0.0515, 0.052, 0.0525]';
        
       
%         % Keuze PR3598.10 van 16 augustus (0.93 -> 0.94 en 1.11 -> 1.12)
%         Abreed = [...
%             0.05	0	0.0000	0.00
%             0.40	0	0.0705	-0.35
%             0.58	0	0.1071	-0.53
%             0.76	0	0.1617	-0.71
%             0.94	0	0.2311	-0.89
%             1.12	0	0.3113	-1.07];
%         A = Abreed;
        % Uitbreiding voor meer extreme meerpeilen op 17 aug:
                Abreed = [...
            0.05	0	0.0000	0.00
            0.40	0	0.0705	-0.35
            0.58	0	0.1071	-0.53
            0.76	0	0.1617	-0.71
            0.94	0	0.2311	-0.89
            1.12	0	0.3113	-1.07
            1.84    0   0.7     -1.79];
        A = Abreed; %alleen om programma niet vast te laten lopen
                              
        
    case 5  %GRV (lognormaal); tune op Markermeer
        A = [...
            -0.23   0   0.00001    0
            0.00	0	0.02354	-0.23    %T = 10 jaar
            0.06	0	0.06898	-0.29    %T = 10^2 jaar
            0.12	0	0.13608	-0.35    %T = 10^3 jaar
            0.18	0	0.22613	-0.41    %T = 10^4 jaar
            0.24	0	0.34757	-0.47];  %T = 10^5 jaar
        
        %Corrigeer voor andere decimeringswaarde:
        A(:,3) = dGRV/dMM*A(:,3);
        
        % Voeg vergroting toe door onzekerheid streefpeil:
        Abreed      = A;    %Maak vooreerst gelijk aan A
        % Keuzes voor extra bredere banden:
        Abreed(:,3) = A(:,3) + [0.0, 0.0515, 0.0515, 0.0515, 0.052, 0.0525]';
        
        
end

% %snelle weergave op scherm
% A
% Abreed

sMu       = interp1(A(:,1), A(:,2), sGrid, 'linear', 'extrap');
sSig      = interp1(A(:,1), A(:,3), sGrid, 'linear', 'extrap');
sEps      = interp1(A(:,1), A(:,4), sGrid, 'linear', 'extrap');
sSigBreed = interp1(Abreed(:,1), Abreed(:,3), sGrid, 'linear', 'extrap');

