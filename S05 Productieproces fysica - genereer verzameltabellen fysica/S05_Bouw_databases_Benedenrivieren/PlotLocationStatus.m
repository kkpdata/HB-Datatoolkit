function PlotLocationStatus( n_oever, oeverStat)

figure;

for i = 1:n_oever
    if oeverStat(i).drycod ~= 1 && oeverStat(i).drywave ~= 1
        plot(oeverStat(i).x, oeverStat(i).y, 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g', 'Markersize', 10);
        hold on;
    end
    if oeverStat(i).drycod == 1 && oeverStat(i).drywave == 1
        plot(oeverStat(i).x, oeverStat(i).y, 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'Markersize', 10);
        hold on;
    end
    if oeverStat(i).drycod == 0 && oeverStat(i).drywave == 1
        plot(oeverStat(i).x, oeverStat(i).y, 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'Markersize', 10);
        hold on;
    end
    if oeverStat(i).drycod == 1 && oeverStat(i).drywave == 0
        plot(oeverStat(i).x, oeverStat(i).y, 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y', 'Markersize', 10);
        hold on;
    end
end

axis equal;

end