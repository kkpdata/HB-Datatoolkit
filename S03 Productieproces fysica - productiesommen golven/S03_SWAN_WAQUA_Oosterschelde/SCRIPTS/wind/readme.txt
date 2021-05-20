TO PRODUCE SPACE VARYING WINDFIELDS FOR SWAN AND WAQUA

WAQUA uses also time varying wind fields, SWAN not

1) Use the matlabfile MakeSwanWaquaWindfieldsv2_0.m to produce the files in WINDforSWAN and in WINDforWAQUA**
   
   The windgrid is originally made for SWAN, on this grid:
   [xx,yy]=meshgrid(-34000:12000:86000,354000:12000:474000);
   xxswan=xx';yyswan=yy';

     
   The waqua wind fields need to be in spherical coordinates.
   I used the gridpoint near the OSK (38000, 402000) and 12 km west and north to convertcoordinates from RD to latlon and to compute dlon and dlat.
   Next, I computed the lon0 and lat0 and lonend and latend, which are needed for waqua in the files WAQH_INU_205001010000_00000 etc.
   (For safety reasons, I added an extra row (=eastern column), but this is probably not necessary)
   
   NB!!!!!! The WAQUA wind files are made with ..\waterstanden\Archief_WAQUA_model\Matlab_generate_input\wind_v2\MakeSwanWaquaWindfieldsv2_1.m
   

2) In unix, run start-waqwnd. For an example, see p:\1230058-os\windfields\WAQUA\matlab\Wind_270_30\start-waqwnd
   you also need 'WindIdFile.txt' and 'windid'. The result is SDS-Wind**. The grid is non-staggered
   You may check this SDS-Wind with rsds.pl in linux (first do: module load simona). 
   SI> name='x0'
   SI> go
   SI> name='y0'
   SI> go
   SI> name='dx'
   SI> go
   SI> name='windx'
   SI> go
   etc
   
3) Next, you can start the WAQUA run, referring in the siminp to that SDS-Wind file; like 
	 SPACE_VAR_WIND
	               WCONVERSIONFACTOR= 1.0
	               WUNIT= 'm/s '
	               CHARNOCK, BETA= 0.025, HEIGHT= 10.0
	               SDS_SVWP= 'SDS-Wind_270_30'
	(I am not sure if these charnock values are the proper ones, but it is about the SDS-Wind now)


caroline 1 May 2017	
	
   
   
   
   
	