clear;close all;clc;

scenarios = {'historical','ssp370','ssp585'};

time_intervals1 = {'1911_1920','1921_1930','1931_1940','1941_1950','1951_1960', ...
                   '1961_1970','1971_1980','1981_1990','1991_2000','2001_2010', ...
                   '2011_2014'};
time_intervals2 = {'2015_2020','2021_2030','2031_2040','2041_2050','2051_2060', ...
                   '2061_2070','2071_2080','2081_2090','2091_2100'};

longxy = ncread('/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/Precip/clmforc.GSWP3.c2011.0.5x0.5.Prec.1912-05.nc','LONGXY');
latixy = ncread('/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/Precip/clmforc.GSWP3.c2011.0.5x0.5.Prec.1912-05.nc','LATIXY');

model = 'gfdl-esm4';

tag = {'Prec','Solr','TPQWL'};

for i = 1 : length(scenarios)
    switch scenarios{i}
        case 'historical'
            time_intervals = time_intervals1;
        otherwise 
            time_intervals = time_intervals2;
    end
    for j = 1 : length(tag)
        switch tag{j}
            case 'Prec'
                varnames = {'PRECTmms'};
                varread  = {'prAdjust'};
            case 'Solr'
                varnames = {'FSDS'};
                varread  = {'rsdsAdjust'};
            case 'TPQWL'
                varnames = {'PSRF','TBOT','WIND','QBOT','FLDS'};
                varread  = {'psAdjust','tasAdjust','sfcWindAdjust','hussAdjust','rldsAdjust'};
        end
        
        for k = 1 : length(time_intervals)
            t1 = datenum(str2num(time_intervals{k}(1:4)),1,1,0,0,0);
            t2 = datenum(str2num(time_intervals{k}(6:9)),12,31,0,0,0);
            t  = t1 : t2;
            [yr,mo,da] = datevec(t);
            varall = cell(length(varread),1);
            for ivar = 1 : length(varread)
                varall{ivar} = ncread([scenarios{i} '/' varread{ivar} '/' model '_r1i1p1f1_w5e5_' scenarios{i} '_' varread{ivar} '_global_daily_' time_intervals{k} '.nc'],varread{ivar});
            end
            nyrs = length(unique(yr));
            for iy = min(yr) : max(yr)
                for im = 1 : 12
                    if im < 10
                        datetag = [num2str(iy) '-0' num2str(im) '-01'];
                    else
                        datetag = [num2str(iy) '-' num2str(im) '-01'];
                    end
                    vars = cell(length(varread),1);
                    ind = find(yr == iy & mo == im);
                    for ivar = 1 : length(varread)
                        tmp1 = varall{ivar}(:,:,ind);
                        % switch longitude
                        if im == 2
                            tmp1 = tmp1(:,:,1:28);
                        end
                        tmp = tmp1;
                        tmp(1:360,:,:) = tmp1(361:720,:,:);
                        tmp(361:720,:,:) = tmp1(1:360,:,:);
                        vars{ivar} = tmp;
                    end
                    folder = ['/compyfs/icom/xudo627/' model '/' scenarios{i} '/' tag{j}];
                    if ~exist(folder,'dir')
                        mkdir(folder);
                    end
                    fname = [folder '/clmforc.' model '.' scenarios{i} '.c2107.0.5x0.5.' tag{j} '.' datetag(1:7) '.nc'];
                    disp(['Generating ' fname]);
                    if ~exist(fname,'file')
                        create_DATM(fname,longxy,latixy,datetag,0:size(tmp,3)-1,varnames,vars);
                    end
                end
            end
        end
    end
end