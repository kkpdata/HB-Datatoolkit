%Maken figuur geknikte trapezia
%Er staan geen eenheden op de verticale as.

%Door: Chris Geerse


%==========================================================================
% Algemeen voorbeeld geknikte trapezia
%==========================================================================

%Algemene instellingen
B=30;
av = 1;   %insnoering verticaal
%av = 1;
ah = 1;   %insnoering horizontaal


%Trapezium 1
s  = 12;
b  = 3;
S1 = [0, av*s, s]';
T1 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 2
s  = 10;
b  = 3;
S2 = [0, av*s, s]';
T2 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 3
s  = 7;
b  = 6;
S3 = [0, av*s, s]';
T3 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 4
s  = 4;
b  = 15;
S4 = [0, av*s, s]';
T4 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 5
s  = 13;
b  = 3;
S5 = [0, av*s, s]';
T5 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 6
s  = 5;
b  = 10;
S6 = [0, av*s, s]';
T6 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

% Tbv goede plaatjes in Word.
figformat = 'doc';
[ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth] = fig_opmaak_a(figformat)
close all   %opdat geen lege figuur wordt getoond

figure 
plot([B/2-T1; B/2+flipud(T1); 1.5*B-T2;1.5*B+flipud(T2); 2.5*B-T3;2.5*B+flipud(T3); 3.5*B-T4;3.5*B+flipud(T4); 4.5*B-T5;4.5*B+flipud(T5); 5.5*B-T6;5.5*B+flipud(T6)],...
    [S1;flipud(S1); S2;flipud(S2); S3;flipud(S3); S4;flipud(S4); S5;flipud(S5); S6;flipud(S6)]);
hold on
ltxt  = [];
%ttxt  = 'Geknikte trapezia';
ttxt  = 'Meerpeilgolven geschematiseerd door geknikte trapezia';
xtxt  = 'tijd, dagen';
ytxt  = 'meerpeil, [m+NAP]';
Xtick = 0:30:180;
Ytick = 0:20:20;
%Ytick = [];
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


%==========================================================================
% Geknikte trapezia met parameters volgens Hydra-M HR2006 (=HR2001)
%==========================================================================

%clear all

%Algemene instellingen
B=30;
av = 0.2;   %insnoering verticaal
ah = 0.025;   %insnoering horizontaal

topduur_inv = ...       %Ten behoeve reproductie Hydra-M
  [-0.40, 720;        %eerste kolom moet toenemend zijn, voor tweede geldt dat niet
   -0.20, 500;
    0.15, 170;
    0.25, 36;
    0.30, 24;
    0.35, 12;
    1.80, 12]

m0 = -0.4;


%Trapezium 1
s  = -0.12;
b  = topduur(topduur_inv, s)/24;
s  = s - m0;        %tov ref. niveau gerekend
S1 = [0, av*s, s]';
T1 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 2
s  = 0.22;
b  = topduur(topduur_inv, s)/24;
s  = s - m0;        %tov ref. niveau gerekend
S2 = [0, av*s, s]';
T2 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 3
s  = -0.35;
b  = topduur(topduur_inv, s)/24;
s  = s - m0;        %tov ref. niveau gerekend
S3 = [0, av*s, s]';
T3 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 4
s  = -0.04;
b  = topduur(topduur_inv, s)/24;
s  = s - m0;        %tov ref. niveau gerekend
S4 = [0, av*s, s]';
T4 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 5
s  = 0.37;
b  = topduur(topduur_inv, s)/24;
s  = s - m0;        %tov ref. niveau gerekend
S5 = [0, av*s, s]';
T5 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

%Trapezium 6
s  = 0.1;
b  = topduur(topduur_inv, s)/24;
s  = s - m0;        %tov ref. niveau gerekend
S6 = [0, av*s, s]';
T6 = [B/2, b/2 + ah*interp1( [0,s], [B/2-b/2, 0], av*s), b/2]';

t_as = [B/2-T1; B/2+flipud(T1); 1.5*B-T2;1.5*B+flipud(T2); 2.5*B-T3;2.5*B+flipud(T3); 3.5*B-T4;3.5*B+flipud(T4); 4.5*B-T5;4.5*B+flipud(T5); 5.5*B-T6;5.5*B+flipud(T6)];

%tov ref-niv gerekend, laagste waarde is 0:
m_as = [S1;flipud(S1); S2;flipud(S2); S3;flipud(S3); S4;flipud(S4); S5;flipud(S5); S6;flipud(S6)]; 
%nu in m+NAP, laagste waarde is m0:
m_as = m0 + m_as;


close all

figure 
plot(t_as, m_as);
grid on
hold on
ltxt  = [];
lpos  = [];
ttxt  = 'Geknikte trapezia voor reproductie Hydra-M statistiek';
xtxt  = 'tijd, dagen';
ytxt  = 'meerpeil, [m+NAP]';
Xtick = 0:30:180;
Ytick = -.40:0.2:0.4;
fig_opmaak_b(ttxt,xtxt,ytxt,ltxt,lpos,Xtick,Ytick,fontsize,linewidth)


