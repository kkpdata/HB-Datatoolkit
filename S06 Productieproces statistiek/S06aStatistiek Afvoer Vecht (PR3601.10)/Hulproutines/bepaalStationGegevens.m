function [sNaam, typeVerdeling, ovkansenAfvoer, kSt, kMax]= bepaalStationGegevens(...
    infileDalfsen );




sNaam            = 'Dalfsen';
typeVerdeling    = 'lognormaal';
ovkansenAfvoer   = load(infileDalfsen);
kSt              = 20;
kMax             = 900;



