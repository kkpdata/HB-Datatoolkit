function [rLab] = bepaalLabelRichting(rKeuze);

switch rKeuze
    case 1
        rLab = 'ZW';
    case 2
        rLab = 'WZW';
    case 3
        rLab = 'W';
    case 4
        rLab = 'WNW';
    case 5
        rLab = 'NW';
    case 6
        rLab = 'NNW';
    case 7
        rLab = 'N';
    case 8
        rLab = 'omni';

end        