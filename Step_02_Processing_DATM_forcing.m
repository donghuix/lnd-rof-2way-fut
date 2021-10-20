clear;close all;clc;

scenarios = {'historical','ssp126','ssp370','ssp585'};

time_intervals1 = {'1981_1990','1991_2000','2001_2010'};
                  %'1911_1920','1921_1930','1931_1940','1941_1950','1951_1960', ...
                  %'1961_1970','1971_1980', '2011_2014'
                  
time_intervals2 = {'2071_2080','2081_2090','2091_2100'};
                  %'2015_2020','2021_2030','2031_2040','2041_2050','2051_2060', ...
                  %'2061_2070',

model = 'gfdl-esm4';

days_of_month = [31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31];

tag = {'Prec','Solr','TPQWL'};

if ~exist('hr_temp_diurnal.mat','file')
    hr_max = NaN(720,360,12);
    hr_min = NaN(720,360,12);
    for i = 1 : 12
        if i <10
            fname = ['/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/TPHWL3Hrly/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.2000-0' num2str(i) '.nc'];
        else
            fname = ['/compyfs/inputdata/atm/datm7/atm_forcing.datm7.GSWP3.0.5d.v1.c170516/TPHWL3Hrly/clmforc.GSWP3.c2011.0.5x0.5.TPQWL.2000-'  num2str(i) '.nc'];
        end
        disp(['Processing ' fname]);
        if i == 1
            hr_lon = ncread(fname,'LONGXY');
            hr_lat = ncread(fname,'LATIXY');
        end
        
        TBOT = ncread(fname,'TBOT');
        for i2 = 1 : 720
            disp(i2);
            for j2 = 1 : 360
                tbot = TBOT(i2,j2,:);
                tbot = reshape(tbot(:),[8,length(tbot(:))/8]);
                [~,tmp1] = max(tbot,[],1);
                [~,tmp2] = min(tbot,[],1);
                hr_max(i2,j2,i) = nanmean(tmp1);
                hr_min(i2,j2,i) = nanmean(tmp2);
            end
        end
    end
    save('hr_temp_diurnal.mat','hr_max','hr_min','hr_lon','hr_lat');
else
    load('hr_temp_diurnal.mat');
end

for i = 1 : length(scenarios)
    switch scenarios{i}
        case 'historical'
            time_intervals = time_intervals1;
        otherwise 
            time_intervals = time_intervals2;
    end
    for j = 1 : 2
        switch tag{j}
            case 'Prec'
                varnames = {'PRECTmms'};
                varread  = {'prAdjust'};
            case 'Solr'
                varnames = {'FSDS'};
                varread  = {'rsdsAdjust'};
        end
        
        for k = 1 : length(time_intervals)
            t1 = datenum(str2num(time_intervals{k}(1:4)),1,1,0,0,0);
            t2 = datenum(str2num(time_intervals{k}(6:9)),12,31,0,0,0);
            t  = t1 : t2;
            [yr,mo,da] = datevec(t);
            varall = cell(length(varread),1);
            for ivar = 1 : length(varread)
                filename = [scenarios{i} '/' varread{ivar} '/' model '_r1i1p1f1_w5e5_' scenarios{i} '_' varread{ivar} '_global_daily_' time_intervals{k} '.nc'];
                varall{ivar} = ncread(filename,varread{ivar});
                if i == 1 && j == 1 && k == 1 && ivar == 1
                    lon = ncread(filename,'lon');
                    lat = ncread(filename,'lat');
                    [longxy,latixy] = meshgrid(lon,lat); 
                    longxy = longxy';
                    latixy = latixy';
                end
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

for i = 1 : length(scenarios)
    switch scenarios{i}
        case 'historical'
            time_intervals = time_intervals1;
        otherwise 
            time_intervals = time_intervals2;
    end
    
    varnames = {'PSRF','TBOT','WIND','QBOT','FLDS'};
    varread  = {'psAdjust','tasAdjust','sfcWindAdjust','hussAdjust','rldsAdjust'};

    for k = 1 : length(time_intervals)
        t1 = datenum(str2num(time_intervals{k}(1:4)),1,1,0,0,0);
        t2 = datenum(str2num(time_intervals{k}(6:9)),12,31,0,0,0);
        t  = t1 : t2;
        [yr,mo,da] = datevec(t);
        varall = cell(length(varread),1);
        
        filename1 = [scenarios{i} '/psAdjust/'      model '_r1i1p1f1_w5e5_' scenarios{i} '_psAdjust_global_daily_'      time_intervals{k} '.nc'];
        filename2 = [scenarios{i} '/sfcWindAdjust/' model '_r1i1p1f1_w5e5_' scenarios{i} '_sfcWindAdjust_global_daily_' time_intervals{k} '.nc'];
        filename3 = [scenarios{i} '/hussAdjust/'    model '_r1i1p1f1_w5e5_' scenarios{i} '_hussAdjust_global_daily_'    time_intervals{k} '.nc'];
        filename4 = [scenarios{i} '/tasmaxAdjust/'  model '_r1i1p1f1_w5e5_' scenarios{i} '_tasmaxAdjust_global_daily_'  time_intervals{k} '.nc'];
        filename5 = [scenarios{i} '/tasminAdjust/'  model '_r1i1p1f1_w5e5_' scenarios{i} '_tasminAdjust_global_daily_'  time_intervals{k} '.nc'];
        
        psAdjust      = ncread(filename1,'psAdjust');
        sfcWindAdjust = ncread(filename2,'sfcWindAdjust');
        hussAdjust    = ncread(filename3,'hussAdjust');
        tasmaxAdjust  = ncread(filename4,'tasmaxAdjust');
        tasminAdjust  = ncread(filename5,'tasminAdjust');
        
        if i == 1 && k == 1 
            lon = ncread(filename1,'lon');
            lat = ncread(filename1,'lat');
            [longxy,latixy] = meshgrid(lon,lat); 
            longxy = longxy';
            latixy = latixy';
        end
            
        nyrs = length(unique(yr));
        
        for iy = min(yr) : max(yr)
            for im = 1 : 12
                if im < 10
                    datetag = [num2str(iy) '-0' num2str(im) '-01'];
                else
                    datetag = [num2str(iy) '-' num2str(im) '-01'];
                end
                P3h = NaN(720,360,days_of_month(im)*8);
                W3h = NaN(720,360,days_of_month(im)*8);
                Q3h = NaN(720,360,days_of_month(im)*8);
                T3h = NaN(720,360,days_of_month(im)*8);
                
                ind = find(yr == iy & mo == im);
                Pday    = psAdjust(:,:,ind);
                Wday    = sfcWindAdjust(:,:,ind);
                Qday    = hussAdjust(:,:,ind);
                Tmaxday = tasmaxAdjust(:,:,ind);
                Tminday = tasminAdjust(:,:,ind);
                numd = length(ind); 
                
                if im == 2
                    numd = 28;
                end
                
                t3h = 1/8/2 : 1/8 : numd - 1/8/2;
                
                for id = 1 : numd
                    P3h(:,:,(id-1)*8+1:id*8) = Pday(:,:,id);
                    W3h(:,:,(id-1)*8+1:id*8) = Wday(:,:,id);
                    Q3h(:,:,(id-1)*8+1:id*8) = Qday(:,:,id);
                    
                end
                

                folder = ['/compyfs/icom/xudo627/' model '/' scenarios{i} '/' tag{j}];
                if ~exist(folder,'dir')
                    mkdir(folder);
                end
                fname = [folder '/clmforc.' model '.' scenarios{i} '.c2107.0.5x0.5.' tag{j} '.' datetag(1:7) '.nc'];
                disp(['Generating ' fname]);
                if ~exist(fname,'file')
                    create_DATM(fname,longxy,latixy,datetag,t3h',varnames,vars);
                end
            end
        end
    end
end
