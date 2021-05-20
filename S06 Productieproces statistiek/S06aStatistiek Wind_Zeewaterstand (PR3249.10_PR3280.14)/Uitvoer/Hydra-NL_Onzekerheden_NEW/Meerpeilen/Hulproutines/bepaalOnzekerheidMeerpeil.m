function [sMu, sSig, sEps] = bepaalOnzekerheidMeerpeil(keuzeStation, sGrid);



switch keuzeStation

    case 1  %IJsselmeer (lognormaal)
        %Value	Mean	St.dev.	Epsilon
        A = [...
            0.29	0	0.03052	-0.79
            0.39	0	0.03052	-0.79
            0.62	0	0.06704	-1.02
            0.84	0	0.13628	-1.24
            1.07	0	0.23125	-1.47
            1.3     0	0.34973	-1.7];

    case 2  %Markermeer (lognormaal)
        A = [...
            -0.1	0	0.02354	-0.4
            0       0	0.02354	-0.4
            0.22	0	0.06898	-0.62
            0.44	0	0.13608	-0.84
            0.66	0	0.22613	-1.06
            0.89	0	0.34757	-1.29];


end


sMu  = interp1(A(:,1), A(:,2), sGrid, 'linear', 'extrap');
sSig = interp1(A(:,1), A(:,3), sGrid, 'linear', 'extrap');
sEps = interp1(A(:,1), A(:,4), sGrid, 'linear', 'extrap');
