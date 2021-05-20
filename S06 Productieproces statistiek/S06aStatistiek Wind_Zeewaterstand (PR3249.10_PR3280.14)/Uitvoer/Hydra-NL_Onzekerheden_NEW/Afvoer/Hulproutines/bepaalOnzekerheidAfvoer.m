function [kMu, kSig, kEps] = bepaalOnzekerheidAfvoer(keuzeStation, kGrid);

% Bronnen: 
% Gegevens uit directory:
% "WTI2017 Stochastic data deliveries_via Karolina verkregen".

% [Chbab, 2015]
% Basisstochasten WTI-2017. Statistiek en statistische onzekerheid. 
% Houcine Cbab. Kenmerk 1209433-012-HYE-0007, 2 december 2015, voorlopig. 
% N.B. Status van dit rapport is volgens begeleidende mail �concept�.


switch keuzeStation

    case 1  %Lobith (normaal)
        %Value	Mean	St.dev.	Epsilon  Zelfde als [Chbab, 2015]
        A = [...
            5939.9	0	340 	0
            5940	0	340     0
            7970	0	440     0
            9130	0	500     0
            10910	0	600     0
            12770	0	700     0
            14000	0	560     0
            14840	0	620     0
            14970	0	640 	0
            15520	0	750     0
            16270	0	930 	0
            16960	0	1120	0
            17710	0	1350	0];

    case 2  %Olst (normaal). Zelfde als [Chbab, 2015], Tabel 5.9.

        A = [...
            786.9	0	46	0
            787     0	46	0
            1090	0	69	0
            1282	0	83	0
            1603	0	111	0
            1972	0	142	0
            2235	0	120	0
            2423	0	138	0
            2453	0	144	0
            2581	0	171	0
            2760	0	221	0
            2930	0	275	0
            3120	0	340	0];

    case 3  %Borgharen (normaal)    Zelfde als [Chbab, 2015]

        A = [...
            1439.9	0	85  	0
            1440	0	85      0
            1970	0	115     0
            2300	0	145     0
            2600	0	207.5	0
            2970	0	270     0
            3220	0	287.5	0
            3520	0	285     0
            3700	0	295     0
            3910	0	350     0
            4020	0	392.5	0
            4180	0	467.5	0
            4400	0	577.5	0
            4560	0	665     0
            4770	0	787.5	0
            4930	0	877.5	0];


    case 4  %Lith (normaal)  Zelfde als [Chbab, 2015]

        A = [...
            1408.9	0	75	0
            1409	0	75	0
            1880	0	102	0
            2177	0	130	0
            2448	0	188	0
            2785	0	247	0
            3014	0	264	0
            3291	0	263	0
            3458	0	274	0
            3653	0	326	0
            3756	0	367	0
            3906	0	438	0
            4113	0	544	0
            4264	0	629	0
            4463	0	748	0
            4616	0	837	0];

    case 5  %Dalfsen (lognormaal)     Zelfde als [Chbab, 2015]

        A = [...
            200	0	5.7682  	-116
            216	0	5.7682      -116
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

end


kMu  = interp1(A(:,1), A(:,2), kGrid, 'linear', 'extrap');
kSig = interp1(A(:,1), A(:,3), kGrid, 'linear', 'extrap');
kEps = interp1(A(:,1), A(:,4), kGrid, 'linear', 'extrap');
