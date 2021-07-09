clear;close all;clc;

% Change the defualt timeout time to 30s.
options = weboptions('Timeout',60);

vars = {'hursAdjust','hussAdjust','prAdjust','prsnAdjust','psAdjust', ...
        'rldsAdjust','rsdsAdjust','sfcWindAdjust','tasAdjust'};
scenarios = {'historical','ssp370','ssp585'};

time_intervals1 = {'1911_1920','1921_1930','1931_1940','1941_1950','1951_1960', ...
                   '1961_1970','1971_1980','1981_1990','1991_2000','2001_2010', ...
                   '2011_2014'};
time_intervals2 = {'2015_2020','2021_2030','2031_2040','2041_2050','2051_2060', ...
                   '2061_2070','2071_2080','2081_2090','2091_2100'};

str1 = 'http://esg.pik-potsdam.de/thredds/fileServer/isimip_dataroot/isimip3b/input/clim_atm_sim/W5E5-ISIMIP3BASD2-5-0/GFDL-ESM4/';
str2 = '/daily/v20210512/';
prefix = 'gfdl-esm4_r1i1p1f1_w5e5_';
suffix = '_global_daily_';
for i = 1 %: length(scenarios)
    if ~exist(['./' scenarios{i}],'dir')
        mkdir(['./' scenarios{i}]);
    end
    for j = 1 : length(vars)
        if ~exist(['./' scenarios{i} '/' vars{j}],'dir')
            mkdir(['./' scenarios{i} '/' vars{j}]);
        end
        if strcmp(scenarios{i},'historical')
            time_intervals = time_intervals1;
        else
            time_intervals = time_intervals2;
        end
        
        for k = 1 : length(time_intervals)
            url = [str1 scenarios{i} '/' vars{j} str2 prefix scenarios{i} '_' vars{j} suffix time_intervals{k} '.nc'];
            filename = ['./' scenarios{i} '/' vars{j} '/' prefix scenarios{i} '_' vars{j} suffix time_intervals{k} '.nc'];
            if ~exist(filename,'file')
                disp(['Downlowding ' filename]);
                outfilename = websave(filename,url,options);
            end
        end
    end
end
        