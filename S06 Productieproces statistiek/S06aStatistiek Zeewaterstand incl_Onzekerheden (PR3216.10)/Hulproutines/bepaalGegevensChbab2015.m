function [TreeksChbab, ovkansenZeeExOnzHeidChbab, ovkansenZeeMetOnzHeidChbab]= bepaalGegevensChbab2015();


% Betreft Hoek van Holland (p 77/78 uit rapport Chbab):
tabelChbab =[...
    10      2.9348	2.9     2.98	0	0.02	2.9341
    100     3.5694	3.45	3.71	0	0.065	3.5712
    1000	4.2567	4       4.57	0	0.1425	4.2723
    10000	4.9953	4.54	5.57	0	0.2575	5.0525
    100000	5.7843	5.07	6.74	0	0.4175	5.9271];

TreeksChbab                  = tabelChbab(:,1);

%Verschuiving om Maasmond te krijgen
verschuiving                 = -0.02;   %m
ovkansenZeeExOnzHeidChbab    = tabelChbab(:,2)  + verschuiving;   
ovkansenZeeMetOnzHeidChbab   = tabelChbab(:,end)+ verschuiving;   