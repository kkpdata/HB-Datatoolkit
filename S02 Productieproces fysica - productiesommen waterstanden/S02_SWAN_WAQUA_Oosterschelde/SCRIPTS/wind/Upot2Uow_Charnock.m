function [Uow] = Upot2Uow_Charnock(Upot,alfa)

% Functie: omrekening potentiele wind naar open water wind o.b.v. Charnock
%
% Uow    = open water wind (m/s)
% Upot   = potentiele wind (m/s)
% alfa   = Charnock constante (-)

nU        = length(Upot);
Uow(1:nU) = 0;

Karman  =  0.4;
z0ref   =  0.03;
%z0ini   =  0.0002;
zmeet   = 10;
Tacc    =  0.001;

Tow     = 1;
%CDini   = (Karman / log(zmeet/z0ini)) .^2;
TELLER  = log(60./z0ref) / log(zmeet/z0ref);

for i=1:nU
  if Upot(i)>=0
    Uow(i) = Upot(i) * Tow;
    j      = 0;
    iter   = 1;
    while iter
      j      = j + 1;
      Towoud = Tow;
      CD     = Cz_Charnock(zmeet,Uow(i),alfa);
      Tow    = TELLER / (1.+ log(6.)*sqrt(CD)/Karman);
      Uow(i) = Upot(i) * Tow;
      iter   = (abs(Tow-Towoud)>Tacc) & (j<=20);
    end
  else
    Uow(i)  = Upot(i);
  end
end
