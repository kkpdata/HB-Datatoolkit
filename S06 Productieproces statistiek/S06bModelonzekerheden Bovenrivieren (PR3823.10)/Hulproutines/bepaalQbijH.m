function [q_h] = bepaalQbijH(h, QH_relatie);

q_h = interp1(QH_relatie(:,2), QH_relatie(:,1), h, 'linear', 'extrap');