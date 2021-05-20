ncfile = 'id1-RAKND.nc';

data.t = nc_varget(ncfile,'time');
data.h = nc_varget(ncfile,'sea_surface_height');
data.t = data.t+datenum(1970,1,1,0,0,0);