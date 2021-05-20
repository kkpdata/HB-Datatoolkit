function [gemiddelde] = gemiddelde_kolomvector_met_ovkans(x, ovkans);

% Gegeven een kolomvector x met als tweede kolom overschrijdingskansen van 
% de componenten.
% Dan wordt het gemiddelde bepaald van de getallen in de kolomvector x,
% waarbij de klassemiddens worden gewogen met de klassekansen.

% Door: Chris Geerse
% Datum: 15 april

%testinvoer
% x               = q_HB(1:20,1);
% ovkans          = qmom_HB(1:20,1);
% x               = q_HB;
% ovkans          = qmom_HB;


%==========================================================================
%Bepalen klassebreedtes en klassemiddens
%==========================================================================
%aantal elementen van x
N               = numel(x);

%getallen in x één positie naar boven schuiven (laatste wordt eerste getal)
xshift          = circshift(x, -1);

% %vector met klassebreedtes;
% klassebreedtes   = xshift - x;
% klassebreedtes(N)= 0;    %laatste element 0 maken

%vector met klassemiddens
klassemiddens   = (x+xshift)/2;
klassemiddens(N)= 0;    %laatste element 0 maken

%==========================================================================
%Bepalen klassekansen
%==========================================================================
%getallen in ovkans één positie naar boven schuiven (laatste wordt eerste getal)
ovkans_shift          = circshift(ovkans, -1);

%vector met klassekansen;
klassekansen   = ovkans - ovkans_shift ;
klassekansen(N)= 0;    %laatste element 0 maken

%==========================================================================
%Bepalen gemiddelde (laat kansinhoud laatste klasse weg)
%==========================================================================

gemiddelde = klassemiddens'*klassekansen;
%disp(['gemiddelde van kolomvector = ', num2str(gemiddelde)])



