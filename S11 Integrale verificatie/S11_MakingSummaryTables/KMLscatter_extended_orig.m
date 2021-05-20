function varargout = KMLscatter_extended(inpData,varargin)
%Based on KMLscatter, but extended for special case to make Bretschneider
%input tables
%
%   kmlscatter(lat,lon,c,<keyword,value>)
%
% where can can be one scaler or an array of size(lon)
% where - amongst others - the following <keyword,value> pairs have been implemented:
%
%  * filename               = []; % file name
%  * kmlname                = []; % name that appears in Google Earth places list
%  * CBcolorMap             = colormap (default @(m) jet(m));
%  * CBcolorSteps           = number of colors in colormap (default 20);
%  * CBcLim                 = cLim aka caxis (default [min(c) max(c)]);
%  * name                   = cellstr with name per point (shown when highlighted)
%                             by default empty.
%  * html                   = cellstr with text per point (shown when highlighted)
%                             by default equal to value of c
%  * OPT.iconnormalState    = marker, default 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png'
%  * OPT.iconhighlightState = http://www.mymapsplus.com/Markers
%                             http://www.visual-case.it/cgi-bin/vc/GMapsIcons.pl
%                             http://www.benjaminkeen.com/?p=105
%                             http://code.google.com/p/google-maps-icons/
%                             http://www.scip.be/index.php?Page=ArticlesGE02&Lang=EN
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = kmlscatter()
%
%See also: GOOGLEPLOT, KMLanimatedicon, KMLmarker, KMLtext, SCATTER, PLOTC
% based on
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLscatter.m $

%% wind directions
dryCode = inpData.dryCode;
blevel = inpData.bottom;
minWL = inpData.minWL;

lat = inpData.lat;
lon = inpData.lon;
Xid = inpData.X;
Yid = inpData.Y; 

c = inpData.c;
region = inpData.region;
locname = inpData.id;

%% process options

% get colorbar options first

OPT                     = mergestructs(KMLcolorbar(),KML_header());
% rest of the options
OPT.fileName            =  '';
OPT.openInGE            =  0;
OPT.markerAlpha         =  1;
OPT.html                = [];
OPT.name                = [];
OPT.snippets            = '';
OPT.debug               = 0;

OPT.iconnormalState     = 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
OPT.iconhighlightState  = 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
OPT.iconnormalState     = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png';
OPT.iconhighlightState  = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png';
OPT.scalenormalState    =  1.0;
OPT.scalehighlightState =  1.0;

OPT.CBcolorMap          =  [1 0 0];
OPT.CBcolorSteps        =  1;
OPT.CBcLim              =  [];
OPT.colorbar            =  0;
OPT.CBinterpreter       =  'tex';

eol = char(10);

if nargin==0
    varargout = {OPT};
    return
end

[OPT, Set, Default] = setproperty(OPT, varargin);

%% get filename, gui for filename, if not set yet

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kmz','Zipped KML file';'*.kml','KML file + separate image files'},'Save as',[mfilename,'.kmz']);
    OPT.fileName = fullfile(filePath,fileName);
end

%% set kmlName if it is not set yet

if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

%% set cLim

if isempty(OPT.CBcLim)
    OPT.CBcLim         = [min(c(:)) max(c(:))];
    if OPT.CBcLim(1)==OPT.CBcLim(2)
        OPT.CBcLim = OPT.CBcLim + 10.*[-eps eps];
    end
end

if isnumeric(OPT.CBcolorMap)
    OPT.CBcolorSteps = size(OPT.CBcolorMap,1);
end

%% pre-process data
%  make 1D and remove NaNs

if length(c)==1
    c = repmat( c,size(lon));
elseif ~length(c)==length(lon)
    error('c should have length 1 or have same size as lon')
end
mask   = find(~isnan(c(:)));
lon    = lon(mask);
lat    = lat(mask);
c      =   c(mask);
if ~isempty(OPT.name)
if ischar(OPT.name)
OPT.name = cellstr(OPT.name);
end
OPT.name = {OPT.name{mask}};
end
if ~isempty(OPT.snippets)
OPT.snippets = {OPT.snippets{mask}};
end

if isnumeric(OPT.CBcolorMap)
    OPT.CBcolorSteps = size(OPT.CBcolorMap,1);
end

if isa(OPT.CBcolorMap,'function_handle')
    colorRGB           = OPT.CBcolorMap(OPT.CBcolorSteps);
elseif isnumeric(OPT.CBcolorMap)
    if size(OPT.CBcolorMap,1)==1
        colorRGB         = repmat(OPT.CBcolorMap,[OPT.CBcolorSteps 1]);
    elseif size(OPT.CBcolorMap,1)==OPT.CBcolorSteps
        colorRGB         = OPT.CBcolorMap;
    else
        error(['size ''colorMap'' (=',num2str(size(OPT.CBcolorMap,1)),') does not match ''colorSteps''  (=',num2str(OPT.CBcolorSteps),')'])
    end
end

%% showing number next to scatter point makes iconhighlightState too SLOW,
%  so show values only in pop-up.

%if isempty(OPT.html);OPT.html = cellstr(num2str(c(:)));end
if  ischar(OPT.html);OPT.html = cellstr(OPT.html  );end
%if isempty(OPT.name);OPT.name = cellstr(num2str(c(:)));end %  makes iconhighlightState too SLOW!
if  ischar(OPT.name);OPT.name = cellstr(OPT.name  );end

%% start KML

OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

OPT_header = struct(OPT);
OPT_header = rmfield(OPT_header,'timeIn');
OPT_header = rmfield(OPT_header,'timeOut');
output = KML_header(OPT_header);

if OPT.colorbar
    %OPT.CBkmlName = 'colorbar';
    OPT.CBvisible = OPT.visible;
    [clrbarstring,pngNames] = KMLcolorbar(OPT);
else
    pngNames = {};
    clrbarstring = '';
end

output = [output '<!--############################-->' eol];

%% STYLE

ii = 1;

OPT_stylePoly.name  = ['style' num2str(ii)];
temp                = dec2hex(round([OPT.markerAlpha, colorRGB(ii,:)].*255),2);
markerColor         = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];

% make table for input
inputtable = [' <BalloonStyle>' eol...
    ' <bgColor>ffffffbb</bgColor>' eol...
    ' <text>' eol...
    ' <![CDATA[' eol...
    ' <b><font color="#000000" size="+1">$[name]</font></b>' eol...
    ' <br/>' eol...
    ' <br/>' eol...
    ' <font face="Courier">$[description]</font>' eol...
    ' $[Locid], $[region], XY-coordinates: ($[Xid],$[Yid])' eol...
    ' <br/>' eol...
    ' <br/>' eol...
    ' <TABLE BORDER="1">' eol...
    ' <TR>' eol...
    ' <TH>Wet/Dry Code</TH>' eol...
    ' <TH>Bottom level [m+NAP]</TH>' eol...
    ' <TH>Minimum Local Water Level [m+NAP]</TH>' eol...
    ' </TR>' eol];


inputtable = [inputtable ' <TR>' eol...
    ' <TH>$[dryCode]</TH>' eol...
    ' <TD>$[blevel]</TD>' eol...
    ' <TD>$[minWL]</TD>' eol...
    ' </TR>' eol];

inputtable = [inputtable ...
        '</TABLE> ]]>' eol...
    ' </text></BalloonStyle>' eol];    

% write style
output = [output ...
    '<StyleMap id="cmarker_',num2str(ii,'%0.3d'),'map">' eol...
    ' <Pair><key>normal</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'n</styleUrl></Pair>' eol...
    ' <Pair><key>highlight</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'h</styleUrl></Pair>' eol...
    '</StyleMap>' eol...
    '<Style id="cmarker_',num2str(ii,'%0.3d'),'n">' eol...
    ' <IconStyle>' eol...
    ' <color>' markerColor '</color>' eol...
    ' <scale>' num2str(OPT.scalenormalState) '</scale>' eol...
    ' <Icon><href>'    OPT.iconnormalState '</href></Icon>' eol...
    ' </IconStyle>' eol...
    inputtable ...
    ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>' eol... % no text except when mouse hoover
    ' </Style>' eol...
    '<Style id="cmarker_',num2str(ii,'%0.3d'),'h">' eol...
    ' <IconStyle>' eol...
    ' <color>' markerColor '</color>' eol...
    ' <scale>' num2str(OPT.scalehighlightState) '</scale>' eol...
    ' <Icon><href>'    OPT.iconhighlightState '</href></Icon>' eol...
    ' </IconStyle>' eol...  
    inputtable ...
    ' <LabelStyle></LabelStyle>' eol...
    ' </Style>' eol];


%% print and clear output

output = [output '<!--############################-->' eol];
fprintf(OPT.fid,'%s',output);output = [];
fprintf(OPT.fid,'<Folder>');
fprintf(OPT.fid,'%s',['<name>',OPT.kmlName,'</name>']); % note format '%s' to allow % inside name
fprintf(OPT.fid,['  <open>',num2str(OPT.open),'</open>']); % TO DO 1

%% set time as wide as all samples, note that header also contains gtime already

% if 1 %OPT.timeWide
%     fprintf(OPT.fid,'<Camera>');
%     fprintf(OPT.fid,KML_timespan('timeIn',min(OPT.timeIn),'timeOut',max(OPT.timeOut),'dateStrStyle',OPT.dateStrStyle));
%     fprintf(OPT.fid,'</Camera>');
% end

output = repmat(char(1),1,1e5);
kk = 1;


%% pre process time for speed
if isnumeric(OPT.timeIn)
    OPT.timeIn  = datestr(OPT.timeIn ,OPT.dateStrStyle);
end
if isnumeric(OPT.timeOut)
    OPT.timeOut = datestr(OPT.timeOut,OPT.dateStrStyle);
end

%% Plot the points

for ii=1:length(lon)
    if OPT.debug
        disp(num2str([ii, length(lon)],'%g / %g'))
    end
    %% preprocess timespan
    if ~isempty(OPT.timeIn)
        if size(OPT.timeIn,1)==1
            timeSpan = KML_timespan('timeIn',OPT.timeIn      ,'timeOut',OPT.timeOut      ,'dateStrStyle',OPT.dateStrStyle);
        else
            timeSpan = KML_timespan('timeIn',OPT.timeIn(ii,:),'timeOut',OPT.timeOut(ii,:),'dateStrStyle',OPT.dateStrStyle);
        end
    else
        timeSpan = '';
    end
    % convert color values into colorRGB index values
    cindex = round(((c(ii)-OPT.CBcLim(1))/(OPT.CBcLim(2)-OPT.CBcLim(1))*(OPT.CBcolorSteps-1))+1);
    cindex = min(cindex,OPT.CBcolorSteps);
    cindex = max(cindex,1); % style numbering is 1-based
    
    OPT_poly.styleName = ['cmarker_',num2str(cindex,'%0.3d'),'map'];
    
    if isempty(OPT.snippets)
       snippet = '';
    else
       snippet = OPT.snippets{ii};
    end
    
    %OPT.name{ii} = ['location ' num2str(ii)];
    OPT.name{ii} = locname{ii};
    
    outputtable = [' <ExtendedData>' eol...
        ' <Data name="Locid"><value>' OPT.name{ii} '</value></Data>' eol...
        ' <Data name="region"><value>' region '</value></Data>' eol...
        ' <Data name="Xid"><value>' num2str(Xid(ii),'%10.0f') '</value></Data>' eol...
        ' <Data name="Yid"><value>' num2str(Yid(ii),'%10.0f') '</value></Data>' eol];
    outputtable = [outputtable ...
        ' <Data name="dryCode"><value>' num2str(dryCode(ii)) '</value></Data>' eol...
        ' <Data name="blevel"><value>' num2str(blevel(ii)) '</value></Data>' eol...
        ' <Data name="minWL"><value>' num2str(minWL(ii)) '</value></Data>' eol];
    outputtable = [outputtable ' </ExtendedData>' eol];
    
    newOutput= sprintf([...
        '<Placemark>\n'...
        ' <name>%s</name>\n'...            % no names so we see just the scatter points
        ' <snippet>%s</snippet>\n'...    % prevent html from showing up in menu
        ' <visibility>%s</visibility>\n'...
        '%s',...                         % timeSpan
        outputtable ...
        ' <styleUrl>#%s</styleUrl>\n'... % styleName
        ' <Point><coordinates>% 2.8f,% 2.8f,0</coordinates></Point>\n'...
        ' </Placemark>\n'],...
        OPT.name{ii},...
        snippet,...
        num2str(OPT.visible),...
        timeSpan,...
        OPT_poly.styleName,...
        lon(ii),lat(ii));
    
    % add newOutput to output
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);
    
    % write output to file if output is full, and reset
    if kk>1e5
        fprintf(OPT.fid,'%s',output(1:kk-1));
        kk = 1;
        output = repmat(char(1),1,1e5);
    end
    
end

%% print and clear output

% print output

fprintf(OPT.fid,'%s',output(1:kk-1));

fprintf(OPT.fid,'</Folder>');

fprintf(OPT.fid,'%s',clrbarstring);

%% FOOTER

output = KML_footer;
fprintf(OPT.fid,'%s',output);

%% close KML

fclose(OPT.fid);


%% compress to kmz and include image fileds

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')

      % download/copy dot images for inclusion in kmz
      if isurl(OPT.iconnormalState   );
         pngNames{end+1} = fullfile(fileparts(OPT.fileName),filenameext(OPT.iconnormalState   ));
         urlwrite(OPT.iconnormalState   ,pngNames{end});
      else
         pngNames{end+1} = fullfile(fileparts(OPT.fileName),[filename(OPT.iconnormalState   ),'_copy',fileext(OPT.iconnormalState   )]);
         copyfile(OPT.iconnormalState   ,pngNames{end}); % always make copy, even from lcal file, due to delete below
      end
      
      if ~strcmpi(OPT.iconnormalState,OPT.iconhighlightState)
      if isurl(OPT.iconhighlightState);
         pngNames{end+1} = fullfile(fileparts(OPT.fileName),filenameext(OPT.iconhighlightState));
         urlwrite(OPT.iconhighlightState,pngNames{end});
      else
         pngNames{end+1} = fullfile(fileparts(OPT.fileName),[filename(OPT.iconhighlightState),'_copy',fileext(OPT.iconhighlightState)]);
         copyfile(OPT.iconnormalState   ,pngNames{end}); % always make copy, even from lcal file, due to delete below
      end
      end
   
      movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])      
      files = [{[OPT.fileName(1:end-3) 'kml']},pngNames];
      zip     ( OPT.fileName,files);
      for ii = 1:length(files)
          delete  (files{ii})
      end
      movefile([OPT.fileName '.zip'],OPT.fileName);
      
   end

%% openInGoogle?

   if OPT.openInGE
      system(OPT.fileName);
   end

%% Output

if nargout==1
    varargout = {pngNames};
end

%% EOF

