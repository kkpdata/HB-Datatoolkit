% script voor plotten uniforme verdeling in werkwijze stap 3


trekking1_2000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_2000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_2000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_2000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';

trekking1_4000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_4000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_4000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_4000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';

trekking1_6000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_6000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_6000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_6000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';


trekking1_8000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_8000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_8000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_8000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';

trekking1_10000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_10000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_10000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_10000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';

trekking1_12000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_12000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_12000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_12000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';

trekking1_14000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_14000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_14000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_14000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';

trekking1_16000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_16000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_16000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_16000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';

trekking1_18000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_18000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_18000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_18000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';

trekking1_20000 = [ -s1*abs(rand(1)), 0 ,  s1*abs(rand(1)) ]';
trekking2_20000 = [ -s2*abs(rand(1)), 0 ,  s2*abs(rand(1)) ]';
trekking3_20000 = [ -s3*abs(rand(1)), 0 ,  s3*abs(rand(1)) ]';
trekking4_20000 = [ -s4*abs(rand(1)), 0 ,  s4*abs(rand(1)) ]';


figure
plot(2000*ones(3,1), trekking1_2000,'b.', 'markersize', 10)
hold on; grid on
plot(2000*ones(3,1), trekking2_2000,'r*', 'markersize', 10)
plot(2000*ones(3,1), trekking3_2000,'ko', 'markersize', 10)
plot(2000*ones(3,1), trekking4_2000,'g+', 'markersize', 10)

plot(4000*ones(3,1), trekking1_4000,'b.', 'markersize', 10)
plot(4000*ones(3,1), trekking2_4000,'r*', 'markersize', 10)
plot(4000*ones(3,1), trekking3_4000,'ko', 'markersize', 10)
plot(4000*ones(3,1), trekking4_4000,'g+', 'markersize', 10)

plot(6000*ones(3,1), trekking1_6000,'b.', 'markersize', 10)
plot(6000*ones(3,1), trekking2_6000,'r*', 'markersize', 10)
plot(6000*ones(3,1), trekking3_6000,'ko', 'markersize', 10)
plot(6000*ones(3,1), trekking4_6000,'g+', 'markersize', 10)

plot(8000*ones(3,1), trekking1_8000,'b.', 'markersize', 10)
plot(8000*ones(3,1), trekking2_8000,'r*', 'markersize', 10)
plot(8000*ones(3,1), trekking3_8000,'ko', 'markersize', 10)
plot(8000*ones(3,1), trekking4_8000,'g+', 'markersize', 10)

plot(10000*ones(3,1), trekking1_10000,'b.', 'markersize', 10)
plot(10000*ones(3,1), trekking2_10000,'r*', 'markersize', 10)
plot(10000*ones(3,1), trekking3_10000,'ko', 'markersize', 10)
plot(10000*ones(3,1), trekking4_10000,'g+', 'markersize', 10)

plot(12000*ones(3,1), trekking1_12000,'b.', 'markersize', 10)
plot(12000*ones(3,1), trekking2_12000,'r*', 'markersize', 10)
plot(12000*ones(3,1), trekking3_12000,'ko', 'markersize', 10)
plot(12000*ones(3,1), trekking4_12000,'g+', 'markersize', 10)

plot(14000*ones(3,1), trekking1_14000,'b.', 'markersize', 10)
plot(14000*ones(3,1), trekking2_14000,'r*', 'markersize', 10)
plot(14000*ones(3,1), trekking3_14000,'ko', 'markersize', 10)
plot(14000*ones(3,1), trekking4_14000,'g+', 'markersize', 10)

plot(16000*ones(3,1), trekking1_16000,'b.', 'markersize', 10)
plot(16000*ones(3,1), trekking2_16000,'r*', 'markersize', 10)
plot(16000*ones(3,1), trekking3_16000,'ko', 'markersize', 10)
plot(16000*ones(3,1), trekking4_16000,'g+', 'markersize', 10)

plot(18000*ones(3,1), trekking1_18000,'b.', 'markersize', 10)
plot(18000*ones(3,1), trekking2_18000,'r*', 'markersize', 10)
plot(18000*ones(3,1), trekking3_18000,'ko', 'markersize', 10)
plot(18000*ones(3,1), trekking4_18000,'g+', 'markersize', 10)

plot(20000*ones(3,1), trekking1_20000,'b.', 'markersize', 10)
plot(20000*ones(3,1), trekking2_20000,'r*', 'markersize', 10)
plot(20000*ones(3,1), trekking3_20000,'ko', 'markersize', 10)
plot(20000*ones(3,1), trekking4_20000,'g+', 'markersize', 10)

legend('Variabele 1','Variabele 2','Variabele 3','Variabele 4') 
title('Voorbeeld resultaten locatie X')
xlabel('Afvoer, m^3/s')
ylabel('Waterstand t.o.v. middenwaarde, m')
xlim([0, 22000])
