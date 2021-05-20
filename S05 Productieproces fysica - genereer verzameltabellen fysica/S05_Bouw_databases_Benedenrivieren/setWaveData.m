function oeverStat = setWaveData( fname, n_oever, oeverStat)
%find the waveheights of the oever locations

S=load(fname, 'Xp', 'Yp', 'Hsig');

for i = 1:n_oever
    xi = oeverStat(i).x;
    yi = oeverStat(i).y;    
    
    dx = 10;
    dy = 10;
    next = 1;
    while (next == 1 && (dx>0.1 && dy>0.1 && dx<500. && dy<500.))
        [i0,j0]=find(S.Xp<xi+dx & S.Xp>xi-dx & S.Yp<yi+dy & S.Yp>yi-dy);
        next = 0;
        if size(i0,1) == 0
            dx = 1.5*dx;
            next = 1;
        end
        if size(j0,1) == 0
            dy = 1.5*dy;
            next = 1;
        end
        if size(i0,1) > 1 || size(j0,1) > 1
            i00 = unique(i0);
            j00 = unique(j0);

%%            [i1,j1]=find(((S.Xp(i00,j00)<xi & S.Xp(i00+1,j00)>xi) | abs(S.Xp(i00,j00)-xi) < 2) & (S.Yp(i00,j00)<yi & S.Yp(i00,j00+1)>yi) | abs(S.Yp(i00,j00)-yi) < 2  );
%%            i0=i00(i1);
%%            j0=j00(j1);
            quit = false;
%%            dx = 1.5*dx;
%%            dy = 1.5*dy;
            next = 2;
            for s1 = 1:size(i00,1)
                for s2 = 1:size(j00,1)
                    xpol = [S.Xp(i00(s1),j00(s2)), S.Xp(i00(s1)+1,j00(s2)), S.Xp(i00(s1)+1,j00(s2)+1), S.Xp(i00(s1),j00(s2)+1)];
                    ypol = [S.Yp(i00(s1),j00(s2)), S.Yp(i00(s1)+1,j00(s2)), S.Yp(i00(s1)+1,j00(s2)+1), S.Yp(i00(s1),j00(s2)+1)];
                    if inpolygon(xi, yi, xpol,ypol)
                        i0=i00(s1);
                        j0=j00(s2);
                        quit = true;
                        next = 0;
                        break;
                    end
                    xpol = [S.Xp(i00(s1),j00(s2)), S.Xp(i00(s1)-1,j00(s2)), S.Xp(i00(s1)-1,j00(s2)-1), S.Xp(i00(s1),j00(s2)-1)];
                    ypol = [S.Yp(i00(s1),j00(s2)), S.Yp(i00(s1)-1,j00(s2)), S.Yp(i00(s1)-1,j00(s2)-1), S.Yp(i00(s1),j00(s2)-1)];
                    if inpolygon(xi, yi, xpol,ypol)
                        i0=i00(s1);
                        j0=j00(s2);
                        quit = true;
                        next = 0;
                        break;
                    end
                    xpol = [S.Xp(i00(s1),j00(s2)), S.Xp(i00(s1)+1,j00(s2)), S.Xp(i00(s1)+1,j00(s2)-1), S.Xp(i00(s1),j00(s2)-1)];
                    ypol = [S.Yp(i00(s1),j00(s2)), S.Yp(i00(s1)+1,j00(s2)), S.Yp(i00(s1)+1,j00(s2)-1), S.Yp(i00(s1),j00(s2)-1)];
                    if inpolygon(xi, yi, xpol,ypol)
                        i0=i00(s1);
                        j0=j00(s2);
                        quit = true;
                        next = 0;
                        break;
                    end
                    xpol = [S.Xp(i00(s1),j00(s2)), S.Xp(i00(s1)-1,j00(s2)), S.Xp(i00(s1)-1,j00(s2)+1), S.Xp(i00(s1),j00(s2)+1)];
                    ypol = [S.Yp(i00(s1),j00(s2)), S.Yp(i00(s1)-1,j00(s2)), S.Yp(i00(s1)-1,j00(s2)+1), S.Yp(i00(s1),j00(s2)+1)];
                    if inpolygon(xi, yi, xpol,ypol)
                        i0=i00(s1);
                        j0=j00(s2);
                        quit = true;
                        next = 0;
                        break;
                    end
                end
                if quit
                    break;
                end
            end
        end
    end
    
    if next==2
        disp(strcat(['Error no cell found for point ',num2str(xi), ' ', num2str(yi)]) );
        oeverStat(i).drywave = 2;
    else
        %interpolate to location (2-D)
        Hx1 = S.Hsig(i0,j0) + (xi-S.Xp(i0,j0))/(S.Xp(i0+1,j0)-S.Xp(i0,j0))*(S.Hsig(i0+1,j0)-S.Hsig(i0,j0));
        Hx2 = S.Hsig(i0,j0+1) + (xi-S.Xp(i0,j0+1))/(S.Xp(i0+1,j0+1)-S.Xp(i0,j0+1))*(S.Hsig(i0+1,j0+1)-S.Hsig(i0,j0+1));
        yp1 = S.Yp(i0,j0) + (xi-S.Xp(i0,j0))/(S.Xp(i0+1,j0)-S.Xp(i0,j0))*(S.Yp(i0+1,j0)-S.Yp(i0,j0));
        yp2 = S.Hsig(i0,j0+1) + (xi-S.Xp(i0,j0+1))/(S.Xp(i0+1,j0+1)-S.Xp(i0,j0+1))*(S.Yp(i0+1,j0+1)-S.Yp(i0,j0+1));
        if isnan(Hx1) && isnan(Hx2) 
            Hs = NaN;
        elseif isnan(Hx1)
            Hs = Hx2;
        elseif isnan(Hx2)
            Hs = Hx1;
        else
            Hs  = Hx1 + (yi-yp1)/(yp2-yp1)*(Hx2-Hx1);
        end
    
        if isnan(Hs)
            oeverStat(i).drywave = 1;
        else
            oeverStat(i).drywave = 0;
        end
        oeverStat(i).Hsig = Hs;
    end
    disp(i);
end

end