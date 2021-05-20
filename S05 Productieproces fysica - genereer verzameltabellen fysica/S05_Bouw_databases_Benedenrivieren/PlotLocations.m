function PlotLocations( n_oever, n_as, oeverStat, asStat)

figure;
for i = 1:n_as
    if asStat(i).drycod == 0
        plot(asStat(i).x, asStat(i).y, 'v', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'Markersize', 5);
    else
        plot(asStat(i).x, asStat(i).y, 'v', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c', 'Markersize', 5);
    end
    hold on;
end

for i = 1:n_oever
    plot(oeverStat(i).x, oeverStat(i).y, 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'Markersize', 10);
    hold on;
    line([oeverStat(i).x, asStat(oeverStat(i).ind_as).x], [oeverStat(i).y, asStat(oeverStat(i).ind_as).y], 'Color', 'black', 'LineWidth', 2);
    hold on;
end

axis equal;

end