% Script als hulp bij begin bestand piekafvoer


clear
close all

%==========================================================================
% Olst
%==========================================================================

% HR2006
AA =[...
  200 1.0
  800 0.16666667
  2720 1.3333E-04];

%Oud
kReeks  = AA(:,1);
pReeks  = AA(:,2);
kint    = 600;
pint    = exp(interp1(AA(:,1), log(AA(:,2)), kint, 'linear', 'extrap'));


%Nieuw
BB =[...
  200 1.0
  600 0.303
  787 0.083333333
  1090	0.033333333
  1282	0.016666667];

pintNw   = exp(interp1(BB(:,1), log(BB(:,2)), kint, 'linear', 'extrap'));
kReeksNw = BB(:,1);
pReeksNw = BB(:,2);

figure
semilogy(kReeks, 6*pReeks,'-b')
hold on; grid on
semilogy(kReeksNw, 6*pReeksNw,'-r')
semilogy(kint, 6*pint,'*b')
semilogy(kint, 6*pintNw,'*r')
title(['Begin statistiekbestand, kint = ', num2str(kint),' heeft pOud = ', num2str(pint)])
xlabel('Afvoer')
ylabel('Ov. Frequentie')
legend('Oud', 'Nieuw')
xlabel([200, 1400])

close all
%==========================================================================
%Lith
% HR2006
AA =[...
500	0.55
1315.1	0.16667];

%Oud
kReeks  = AA(:,1);
pReeks  = AA(:,2);
kint    = 1000;
pint    = exp(interp1(AA(:,1), log(AA(:,2)), kint, 'linear', 'extrap'));


