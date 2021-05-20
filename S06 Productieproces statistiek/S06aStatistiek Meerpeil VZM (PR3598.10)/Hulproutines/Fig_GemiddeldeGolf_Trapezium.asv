aantal_golven = max([golven.nr]);
v             = standaardvorm.v;
bpiek_fig     = topduur_inv(Nrijen,2)/24; %topduur tbv figuur in dagen

figure
plot(standaardvorm.tvoor,v,'b',standaardvorm.tachter,v,'b');
hold on
grid on

t1 = bpiek_fig/2 + ah*(1-av)*(B-bpiek_fig)/2;
x  = [-B/2, -t1, -bpiek_fig/2, bpiek_fig/2, t1, B/2]';
y  = [0, av, 1, 1, av, 0]';
plot(x,y,'r');
title(['Gemiddelde golf ', stationsnaam,' met trapezium']);
xlabel('tijd, dagen');
ylabel('relatief meerpeil, [-]')
xlim([-B/2 B/2]);
ylim([0 1]);
