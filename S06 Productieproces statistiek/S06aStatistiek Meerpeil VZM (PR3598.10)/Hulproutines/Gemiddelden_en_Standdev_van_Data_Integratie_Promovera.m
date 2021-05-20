mpgem_data = mean(data);
stdev_data = std(data);
mpgem_trap = sum(berek_trap.fy_mom*stapy .*berek_trap.y);
stdev_trap = (sum(berek_trap.fy_mom*stapy .*(berek_trap.y).^2) - mpgem_trap^2)^0.5;

%Momentane ov.kans Promovera
mom_ovkans_PROM   = OD_PROM/OD_PROM(1);
stap_PROM         = m_PROM(2)-m_PROM(1);
m_PROM_klasmidden = m_PROM + 0.5*stap_PROM;
klassekansen      = [-diff(mom_ovkans_PROM);0];  %geef laatste klassemidden kans 0
mpgem_PROM        = sum( klassekansen.*m_PROM_klasmidden );
stdev_PROM        = (sum( klassekansen.*(m_PROM_klasmidden.^2) ) - mpgem_PROM^2)^0.5;

disp(sprintf('gemiddelde data            = %6.3f m+NAP',mpgem_data));
disp(sprintf('standaardeviatie data      = %6.3f m+NAP',stdev_data));
disp(sprintf('gemiddelde trapezia        = %6.3f m+NAP',mpgem_trap));
disp(sprintf('standaardeviatie trapezia  = %6.3f m+NAP',stdev_trap));
disp(sprintf('gemiddelde Promovera       = %6.3f m+NAP',mpgem_PROM));
disp(sprintf('standaardeviatie Promovera = %6.3f m+NAP',stdev_PROM));
