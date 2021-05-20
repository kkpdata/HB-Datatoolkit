function [TreeksChbab, ovkansenAfvoerExOnzHeidChbab, ovkansenAfvoerMetOnzHeidChbab]= bepaalGegevensChbab2015(...
    keuzeStation);


switch keuzeStation
    case 1  %Lobith
        tabelChbab =[...
            2       5940	5280	6600	0	340 	5941
            5       7970	7110	8840	0	440     7949
            10      9130	8160	10100	0	500     9172
            30      10910	9730	12080	0	600 	10978
            100     12770	11400	14150	0	700     12854
            300     14000	12910	15100	0	560     14107
            1000	14840	13620	16050	0	620 	15035
            1250	14970	13720	16230	0	640     15191
            3000	15520	14060	16980	0	750 	15802
            10000	16270	14450	18100	0	930     16682
            30000	16960	14750	19160	0	1120	17535
            100000	17710	15060	20350	0	1350	18516];

    case 2  %Olst
        tabelChbab =[...
            2   	787     697     881     0	46	787
            5       1090	956     1233	0	69	1088
            10  	1282	1121	1453	0	83	1289
            30      1603	1387	1831	0	111	1616
            100     1972	1697	2268	0	142	1989
            300     2235	2001	2483	0	120	2256
            1000	2423	2152	2707	0	138	2463
            1250	2453	2174	2750	0	144	2499
            3000	2581	2248	2935	0	171	2642
            10000	2760	2335	3221	0	221	2852
            30000	2930	2403	3503	0	275	3063
            100000	3120	2474	3834	0	340	3312];

    case 3  %Borgharen
        tabelChbab =[...
            2       1440	1270	1610	0	85	1440
            5   	1970	1740	2200	0	115	1965
            10  	2300	2010	2590	0	145	2297
            20  	2600	2190	3020	0	208	2608
            50  	2970	2430	3510	0	270	3013
            100 	3220	2650	3800	0	288	3294
            250 	3520	2950	4090	0	285	3611
            500     3700	3110	4290	0	295	3818
            1250   	3910	3210	4610	0	350	4073
            2000	4020	3240	4810	0	393	4206
            4000	4180	3250	5120	0	468	4413
            10000	4400	3240	5550	0	578	4717
            20000	4560	3230	5890	0	665	4971
            50000	4770	3200	6350	0	788	5331
            100000	4930	3180	6690	0	878	5616];

    case 4  %Lith
        tabelChbab =[...
            2   	1409	1259	1559	0	75	1409
            5       1880	1675	2086	0	102	1876
            10      2177	1916	2439	0	130	2174
            20  	2448	2077	2831	0	188	2455
            50  	2785	2294	3282	0	247	2824
            100 	3014	2493	3551	0	264	3082
            250 	3291	2767	3822	0	263	3374
            500     3458	2913	4009	0	274	3566
            1250	3653	3005	4312	0	326	3804
            2000	3756	3032	4502	0	367	3928
            4000	3906	3042	4797	0	438	4122
            10000	4113	3032	5211	0	544	4409
            20000	4264	3023	5541	0	629	4650
            50000	4463	2996	5990	0	748	4991
            100000	4616	2977	6325	0	837	5264];

    case 5  %Dalfsen
        tabelChbab =[...
            2   	216	0	5.77	-116	4752	0.05	216
            5   	263	0	10.3	-163	5092	0.063	263
            10  	299	0	14.1	-199	5291	0.071	296
            20  	335	0	35.8	-235	5448	0.151	333
            50      383	0	46.32	-283	5632	0.163	389
            100 	419	0	63.58	-319	5746	0.197	432
            250 	466	0	84.18	-366	5877	0.227	494
            500     502	0	97.68	-402	5968	0.24	545
            1250	550	0	117.04	-450	6077	0.256	619
            2000	574	0	127.76	-474	6126	0.265	658
            4000	610	0	140.97	-510	6198	0.271	719
            10000	658	0	159.43	-558	6285	0.28	804
            20000	694	0	171.7	-594	6347	0.283	872
            50000	741	0	193.47	-641	6419	0.295	966
            100000	777	0	202.84	-677	6475	0.293	1040];

end

TreeksChbab                     = tabelChbab(:,1);
ovkansenAfvoerExOnzHeidChbab    = tabelChbab(:,2);
ovkansenAfvoerMetOnzHeidChbab   = tabelChbab(:,end);