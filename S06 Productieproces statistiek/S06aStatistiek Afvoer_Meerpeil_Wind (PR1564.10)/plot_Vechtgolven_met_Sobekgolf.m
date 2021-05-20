function [] = plot_Vechtgolven_met_Sobekgolf(SobekGolfMatrixNorm, golven);
%
% Aanpassing door Chris Geerse van module van Vincent Beijk.
% Versie met golven opgeslagen in structure en Sobek-golfvorm uit
% deelrapport 8
%
%==========================================================================
%
%==========================================================================
aantal_golven = max([golven.nr]);
z = (length([golven(1).tijd])-1)/2;
t_as = [golven(1).tijd];
% y = beta_normgolfvorm(:,2);         %0 <= y <= 1
% x = beta_normgolfvorm(:,1);         %0 <= x <= 1


figure
a = 1;
for n = 1:aantal_golven
    %    if n == 13 | n == 25 | n == 37 | n == 49 | n == 61 | n == 73
    rest = mod(n-1,12);
    if rest == 0 & n > 1    %als rest=0 is n-1 = K*12, met K geheel
        figure
        a = 1;
    end
    subplot(3,4,a)
    a = a + 1;
    plot(t_as, [golven(n).data])
    hold on
    grid on
    xlim([-z z])
    ylim([0 400])
    jaarn = golven(n).jaa;
    maandn = golven(n).mnd;
    dagn = golven(n).dag;
    piekdatumn = datenum(jaarn, maandn, dagn);
    title(['piek: ',datestr(piekdatumn)])
    % beta-golfvorm bepalen met juiste piekwaarde en basisduur
%     x_beta_normgolfvorm = x*Bbeta - Bbeta/2;
%     y_beta_normgolfvorm = y * golven(n).piek;
%     plot(x_beta_normgolfvorm, y_beta_normgolfvorm,'r')

    plot(SobekGolfMatrixNorm(:,1),golven(n).piek*SobekGolfMatrixNorm(:,2),'k')
    
end

end
