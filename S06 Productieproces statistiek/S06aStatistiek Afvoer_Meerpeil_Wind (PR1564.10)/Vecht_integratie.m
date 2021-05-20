%==========================================================================
%Door Chris Geerse
%==========================================================================
%clear all
%==========================================================================
%Algemene parameters
B = 30      %basisduur in dagen

%invoer b(k): eerste kolom is k, tweede is b(k) in uren.
topduur_inv = [0, 720;
    180, 48;
    1000, 48]

%invoer f(k): eerste kolom is k, tweede is overschrijdingskans piekwaarde.
%N.B. eerste getal moet laagste afvoer zijn, met overschr.kans 1, ofwel
%moet topduur_inv(1,1) zijn.
momovpiek_inv = [0, 1;
    180, 0.16667;
    550, 1.3333e-4]

stapk = 10       %stapgrootte piekwaarde integratie
kmax = 1000      %maximum voor integratie

%==========================================================================
% Bepalen topduurfunctie b(k)
%==========================================================================

laagste_afvoer = topduur_inv(1,1);   %laagste afvoer q0
kmin = laagste_afvoer;    
k = [kmin: stapk: kmax]';

bk = []      %startwaarde b(k)
num_traject = size(topduur_inv,1);      %aantal trajecten waarop bk bepaald moet worden

for i = 1:num_traject-1
    klaag = topduur_inv(i,1);
    khoog = topduur_inv(i+1,1);
    bklaag = topduur_inv(i,2);
    bkhoog = topduur_inv(i+1,2);
    index_traject = find (k>=klaag & k< khoog);
    bk_hulptraject = (bklaag - bkhoog)*(khoog-k(index_traject))/(khoog-klaag)+bkhoog;
    bk = [bk; bk_hulptraject];
end
%aanvullen met eindtraject (neem b(k) gelijk aan laatste waarde)
klaatst = topduur_inv(num_traject,1);
bklaatst = topduur_inv(num_traject,2);
index_traject = find(k>=klaatst);
bk_eindtraject = k(index_traject)./k(index_traject).*bklaatst;
bk = [bk; bk_eindtraject];

%plot(k, bk)

%==========================================================================
% Bepalen kansdichtheid f(k) en mom. ovkans piekafvoer in basisduur
%==========================================================================

fk = []      %startwaarde f(k)
momovpiek = []  %startwaarde mom. ovkans piekafvoer
num_fk_traject = size(momovpiek_inv,1);      %aantal trajecten waarop fk bepaald moet worden
for i = 1:num_fk_traject-1
    fk_klaag = momovpiek_inv(i,1);
    fk_khoog = momovpiek_inv(i+1,1);
    povlaag = momovpiek_inv(i,2);
    povhoog = momovpiek_inv(i+1,2);
    a(i)=(fk_khoog-fk_klaag)/(log(povlaag)-log(povhoog))
    b(i)=(fk_khoog*log(povlaag)-fk_klaag*log(povhoog))/(log(povlaag)-log(povhoog))
    index_fk_traject = find (k>=fk_klaag & k< fk_khoog);
    fk_hulptraject = exp((b(i)-k(index_fk_traject))/a(i))/a(i);
    momovpiek_hulptraject = exp((b(i)-k(index_fk_traject))/a(i));
    fk = [fk; fk_hulptraject];
    momovpiek = [momovpiek; momovpiek_hulptraject];
end

%aanvullen met eindtraject (zet laatste traject voort)
fk_klaatst = momovpiek_inv(num_fk_traject,1);
fk_laatst = momovpiek_inv(num_fk_traject,2);
index_fk_traject = find(k>=fk_klaatst);
fk_eindtraject = exp((b(num_fk_traject-1)-k(index_fk_traject))/a(num_fk_traject-1))/a(num_fk_traject-1);
fk = [fk; fk_eindtraject];
momovpiek_eindtraject= exp((b(num_fk_traject-1)-k(index_fk_traject))/a(num_fk_traject-1));
momovpiek = [momovpiek; momovpiek_eindtraject];

%exacte normering kansen op 1
fk = fk/sum(fk*stapk);
momovpiek = momovpiek/momovpiek(1);

%plaatjes
plot(k, log(fk))
hold on
plot(k, log(momovpiek))

%==========================================================================
% Bepalen mom.ov kans voor q-niveaus (berekening dmv integratie)
%==========================================================================
momovkansq =[];
q = [kmin: stapk: kmax]';
for i = 1:numel(k)
    groterdanqi = (k>=q(i));
    Lqk = ((bk + (B*24-bk).*(k-q(i))./(k+eps)).*groterdanqi)/24;    %overschrijdingsduur niveau q(i) in dagen
    momovkansq(i) = stapk/B*sum(fk.*Lqk);   %berekening van de integraal
end
momovkansq = momovkansq';
%display('q,momovkansq')
%[q, momovkansq']

%==========================================================================
% Momentane kans volgens de metingen
%==========================================================================
%aantal meetjaren is 26 met uitbreiding en 23 jaar zonder uitbreiding

[jaar,maand,dag,afvoer] = textread('Vechtafvoeren_60_83_met_uitbreiding.txt','%f %f %f %f','delimiter','\t','commentstyle','matlab');
%[jaar,maand,dag,afvoer] = textread('Vechtafvoeren_1960_1983_dag.txt','%f %f %f %f','delimiter','\t','commentstyle','matlab');
whj = find( maand == 10 | maand == 11 | maand == 12 | maand == 1 | maand == 2 | maand == 3);

N = numel((whj>=0));  %aantal dagen in winterhalfjaren
p=[];
q = [kmin:stapk:kmax]';
for i = 1:numel(q)
    x = find(afvoer(whj)>= q(i));
    ovdagen = numel(x);
    p(i) = ovdagen/N; 
end
momovkansq_obs = [q, p']

%==========================================================================
% Plaatje momentane kans volgens de metingen en volgens de integratie
%==========================================================================

close
plot(q,momovkansq_obs(:,2),'g-',q,momovkansq,'b-.')
grid on
hold on
xlim([0 200]);
ylim([0 1]);
xlabel('Vechtafvoer Dalfsen, m3/s')
ylabel('momentane overschrijdingskans, [-]')
legend('observatie','integratie')


