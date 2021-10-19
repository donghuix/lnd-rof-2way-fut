clear;close all;clc;

% Change the defualt timeout time to 30s.
options = weboptions('Timeout',60);

vars = {'hussAdjust',   ... % Specific humidty     [kg kg-1]
        'prAdjust',     ... % Precipitation flux   [kg m-2 s-1]
        'prsnAdjust',   ... % Snowfall flux        [kg m-2 s-1]
        'psAdjust',     ... % Surface air pressure [Pa]
        'rsdsAdjust',   ... % Surface downwelling shortwave flux in air [W m-2]
        'sfcWindAdjust',... % Wind speed           [m s-1]
        'tasAdjust',    ... % Air temperature      [k]
        'tasmaxAdjust', ... % Max air temperature
        'tasminAdjust'};    % Min air temperature 
    
scenarios = {'historical','ssp126','ssp370','ssp585'};

time_intervals1 = {'1951_1960', '1961_1970','1971_1980','1981_1990','1991_2000','2001_2010'}; 
                  % '1911_1920','1921_1930','1931_1940','1941_1950','2011_2014'
time_intervals2 = {'2031_2040','2041_2050','2051_2060', '2061_2070','2071_2080','2081_2090','2091_2100'};
                  % '2015_2020','2021_2030',

Climate_forcing = {'GFDL-ESM4','IPSL-CM6A-LR','MPI-ESM1-2-HR','MRI-ESM2-0','UKESM1-0-LL'};

iCf = 1;
str1 = ['http://esg.pik-potsdam.de/thredds/fileServer/isimip_dataroot/isimip3b/input/clim_atm_sim/W5E5-ISIMIP3BASD2-5-0/' Climate_forcing{iCf} '/'];
str2 = '/daily/v20210512/';
prefix = [lower(Climate_forcing{iCf}) '_r1i1p1f1_w5e5_'];
suffix = '_global_daily_';
for i = 1 : length(scenarios)
    for j = 1 : length(vars)
        if ~exist(['./'  Climate_forcing{iCf} '/' scenarios{i} '/' vars{j}],'dir')
            mkdir(['./'  Climate_forcing{iCf} '/' scenarios{i} '/' vars{j}]);
        end
        if strcmp(scenarios{i},'historical')
            time_intervals = time_intervals1;
        else
            time_intervals = time_intervals2;
        end
        
        for k = 1 : length(time_intervals)
            url = [str1 scenarios{i} '/' vars{j} str2 prefix scenarios{i} '_' vars{j} suffix time_intervals{k} '.nc'];
            filename = ['./'  Climate_forcing{iCf} '/' scenarios{i} '/' vars{j} '/' prefix scenarios{i} '_' vars{j} suffix time_intervals{k} '.nc'];
            if ~exist(filename,'file')
                disp(['Downlowding ' filename]);
                outfilename = websave(filename,url,options);
	    else
		disp([filename ' is already downloaded!']);
            end
        end
    end
end
        
