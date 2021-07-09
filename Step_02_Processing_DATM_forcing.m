clear;close all;clc;

scenarios = {'historical','ssp370','ssp585'};

time_intervals1 = {'1911_1920','1921_1930','1931_1940','1941_1950','1951_1960', ...
                   '1961_1970','1971_1980','1981_1990','1991_2000','2001_2010', ...
                   '2011_2014'};
time_intervals2 = {'2015_2020','2021_2030','2031_2040','2041_2050','2051_2060', ...
                   '2061_2070','2071_2080','2081_2090','2091_2100'};
               
model = 'gfdl-esm4';

tag = {'Prec','Solr','TPQWL'};

for i = 1 : length(scenarios)
    switch scenarios{i}
        case 'historical'
            time_intervals = times_intervals1;
        otherwise 
            time_intervals = times_intervals2;
    end
    for j = 1 : length(tag)
        switch tag{j}
            case 'Prec'
                varnames = {'PRECTmms'};
                var      = {'prAdjust'};
            case 'Solr'
                varnames = {'FSDS'};
                var      = {'rsdsAdjust'};
            case 'TPQWL'
                varnames = {'PSRF','TBOT','WIND','QBOT','FLDS'};
                var      = {'psAdjust','tasAdjust','sfcWindAdjust','hussAdjust','rldsAdjust'};
        end
        
        for k = 1 : length(time_intervals)
            t1 = datenum(str2num(time_intervals{k}(1:4)),1,1,0,0,0);
            t2 = datenum(str2num(time_intervals{k}(6:9)),31,1,0,0,0);
            t  = t1 : t2;
            [yr,mo,da] = datevec(t);
        end
    end
end