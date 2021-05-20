function [] = plot_stormen(stormen,B,b,fig_ur,fig_utrap,Npx,Npy,Stst,Sumn,Sust,Sumx,Srmn,Srst,Srmx);
%
% Door Chris Geerse
%
%
%==========================================================================
%
%Plaatjes worden gemaakt van de geselecteerde stormen met ofwel
%richtingsverloop erbij, ofwel trapezium erbij.
%
%Input:
%stormen: structure met gegevens geselecteerde stormen
%B is basisduur trapezium
%b is topduur trapezium
%
%Parameters voor subplots met u, r en trapezia
%Er zijn Npx*Npy plaatjes in één figuur:
%Npx  aantal plaatjes in x-richting
%Npy  aantal plaatjes in y-richting
%Stst stapgrootte tijd
%Sumn min van windsnelheid
%Sust stapgrootte in windsnelheid
%Sumx max van windsnelheid
%Srmn min van richting
%Srst stapgrootte in richting
%Srmx max van richting
%
%Output:
%als fig_ur = 1: subplots met u en r als functie van t
%als fig_utrap = 1: subplots met u en trapezium als functie van t
%als fig_ur en fig_utrap beide ongelijk 1, dan geen output
%

%==========================================================================
%Begin van de functie
%==========================================================================

Nstormen = max([stormen.rang]);
z = (length([stormen(1).tijd])-1)/2;
t_as = [stormen(1).tijd];

%parameters trapezium tbv plotten
traptijd =[-B/2 -b/2 b/2 B/2];
trapu_norm =[0 1 1 0];

%Plotten van u en r als functie van t
if fig_ur == 1
    figure
    a = 1;
    for j = 1:Nstormen
        rest = mod(j-1,Npx*Npy);
        if rest == 0 & j > 1    %als rest=0 is j-1 = K*Npx*Npy, met K geheel
            figure
            a = 1;
        end
        subplot(Npy,Npx,a)
        a = a + 1;
        %plotten u-reeks en r-reeks in storm j
        [AX,H1,H2] = plotyy(t_as, [stormen(j).data],t_as, [stormen(j).rdata],'plot');
        set(AX(1),'Xlim',[-z z],'Xtick',[-z:Stst:z],'Ylim',[Sumn Sumx],'Ytick',[Sumn:Sust:Sumx]);
        set(AX(2),'YColor','r','Xlim',[-z z],'Xtick',[-z:Stst:z],'Ylim',[Srmn Srmx],'Ytick',[Srmn:Srst:Srmx]);
        set(H2,'LineStyle','--','Color','r');
        grid on
        title(['piek: ',num2str(stormen(j).dag), '-',num2str(stormen(j).mnd), '-', num2str(stormen(j).jaa), ' uur: ', num2str(stormen(j).uur)])
    end
end

%Plotten van u als functie van t met trapezium erbij (exclusief de richtingen)
if fig_utrap ==1
    figure
    a = 1;
    for j = 1:Nstormen
        rest = mod(j-1,Npx*Npy);
        if rest == 0 & j > 1    %als rest=0 is j-1 = K*Npx*Npy, met K geheel
            figure
            a = 1;
        end
        subplot(Npy,Npx,a)
        a = a + 1;
        %plotten u-reeks en trapezium
        plot(t_as, [stormen(j).data],traptijd, trapu_norm*[stormen(j).piek]);
        set(gca,'Xlim',[-z z],'Xtick',[-z:Stst:z],'Ylim',[Sumn Sumx],'Ytick',[Sumn:Sust:Sumx]);
        grid on
        title(['piek: ',num2str(stormen(j).dag), '-',num2str(stormen(j).mnd), '-', num2str(stormen(j).jaa), ' uur: ', num2str(stormen(j).uur)])
    end
end
