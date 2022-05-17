clear;close all;clc;

scenarios = {'historical','ssp126','ssp370','ssp585'};

time_intervals1 = {'1951_1960','1961_1970','1971_1980','1981_1990','1991_2000','2001_2010','2011_2014'};
                  %'1911_1920','1921_1930','1931_1940','1941_1950', ...
                  
time_intervals2 = {'2015_2020','2021_2030','2031_2040','2041_2050','2051_2060','2061_2070','2071_2080','2081_2090','2091_2100'};

model = 'gfdl-esm4';

parpool('local',7);

days_of_month = [31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31];

tag = {'Prec','Solr','TPQWL'};

domain = 'NLDAS';
% NLDAS extent
xmin = -125.75;
xmax = -66.25;
ymin = 24.25;
ymax = 53.75;
irow1 = 109;
irow2 = 228;
icol1 = 73;
icol2 = 132;

ele = ncread('/project/projectdirs/m3780/donghui/Runoff_Projection_Uncertainty/inputdata/MOSART_NLDAS_8th_c210129.nc','ele');

ele = nanmean(ele,3);
ele = ele(irow1:irow2,icol1:icol2);

days_of_month = [31;28;31;30;31;30;31;31;30;31;30;31];

if strcmp(domain,'NLDAS')
    if exist('sunrise_set_NLDAS.mat','file')
        load('sunrise_set_NLDAS.mat');
    else
    [m,n] = size(ele);
    hr_min = NaN(m,n,12,31);
    hr_max = NaN(m,n,12,31);
    longxy = ncread('/project/projectdirs/m3780/donghui/Runoff_Projection_Uncertainty/inputdata/domain.lnd.NLDAS_0.5x0.5_isimip.3b.c211109.nc','xc');
    latixy = ncread('/project/projectdirs/m3780/donghui/Runoff_Projection_Uncertainty/inputdata/domain.lnd.NLDAS_0.5x0.5_isimip.3b.c211109.nc','yc');
    for i2 = 1 : m
        for j2 = 1 : n
            for im = 1 : 12
                for id = 1 : days_of_month(im)
                    ymd = get_ymd(2010,im,id);

                    [srise,sset] = sunrise(latixy(i2,j2),longxy(i2,j2),ele(i2,j2),0,ymd);
                    [~,~,~,hr_rise,mi_rise] = datevec(srise);
                    [~,~,~,hr_set,mi_set] = datevec(sset);
                    hr_rise = hr_rise + mi_rise/60;
                    hr_set = hr_set + mi_set/60;
                    hr_min(i2,j2,im,id) = hr_rise;
                    hr_max(i2,j2,im,id) = hr_rise + 0.67*(hr_set - hr_rise);
                    
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
    for j = 1 : 2
        switch tag{j}
            case 'Prec'
                varnames = {'PRECTmms'};
                varread  = {'prAdjust'};
            case 'Solr'
                varnames = {'FSDS'};
                varread  = {'rsdsAdjust'};
        end
        
        parfor k = 1 : length(time_intervals)
            t1 = datenum(str2num(time_intervals{k}(1:4)),1,1,0,0,0);
            t2 = datenum(str2num(time_intervals{k}(6:9)),12,31,0,0,0);
            t  = t1 : t2;
            [yr,mo,da] = datevec(t);
            varall = cell(length(varread),1);
            process_this_file = 0;
            for iy = min(yr) : max(yr)
                for im = 1 : 12
                    [datetag,datetag2] = get_datetag(iy,im,scenarios{i});
                    folder = ['./data/forcings/' domain '/' model '/' scenarios{i} '/' tag{j}];
                    fname = [folder '/clmforc.' model '.' scenarios{i} '.c2107.0.5x0.5.' tag{j} '.' datetag(1:7) '.nc'];
                    %fname = [folder '/clmforc.' model '.' scenarios{i} '.' datetag(1:7) '.c2107.0.5x0.5.' tag{j} '.' datetag2(1:7) '.nc'];
                    if ~exist(fname,'file')
                        process_this_file = 1;
                    end
                end
            end
            
            if process_this_file
                
            fprintf([domain ' ' model ' ' scenarios{i} ' ' tag{j} ' ' time_intervals{k} ' is not processed yet... Start to process:\n']);
            
            for ivar = 1 : length(varread)
                filename = [upper(model) '/' scenarios{i} '/' varread{ivar} '/' model '_r1i1p1f1_w5e5_' scenarios{i} '_' varread{ivar} '_global_daily_' time_intervals{k} '.nc'];
                if strcmp(domain,'NLDAS')
                    varall{ivar} = ncread(filename,varread{ivar},[irow1,icol1,1],[irow2-irow1+1,icol2-icol1+1,inf]);
                else
                    varall{ivar} = ncread(filename,varread{ivar});
                end
                lon = ncread(filename,'lon');
                lat = ncread(filename,'lat');
                [longxy,latixy] = meshgrid(lon,lat); 
                longxy = longxy';
                latixy = latixy';
                if strcmp(domain,'NLDAS')
                    longxy = longxy(irow1:irow2,icol1:icol2);
                    latixy = latixy(irow1:irow2,icol1:icol2);
                end
            end
            nyrs = length(unique(yr));
            for iy = min(yr) : max(yr)
                for im = 1 : 12
                    [datetag,datetag2] = get_datetag(iy,im,scenarios{i});
                    vars = cell(length(varread),1);
                    ind = find(yr == iy & mo == im);
                    
                    if im == 2
                        numd = 28;
                    else
                        numd = length(ind);
                    end
                    tday = 0.5 : 1 : numd - 0.5;
                    
                    for ivar = 1 : length(varread)
                        tmp1 = varall{ivar}(:,:,ind);
                        % switch longitude
                        if im == 2
                            tmp1 = tmp1(:,:,1:28);
                        end
                        tmp = tmp1;
                        vars{ivar} = tmp;
                    end
                    folder = ['./data/forcings/' domain '/' model '/' scenarios{i} '/' tag{j}];
                    if ~exist(folder,'dir')
                        mkdir(folder);
                    end
                    fname = [folder '/clmforc.' model '.' scenarios{i} '.c2107.0.5x0.5.' tag{j} '.' datetag(1:7) '.nc'];
                    %fname = [folder '/clmforc.' model '.' scenarios{i} '.' datetag(1:7) '.c2107.0.5x0.5.' tag{j} '.' datetag2(1:7) '.nc'];
                    disp(['Generating ' fname]);
                    if ~exist(fname,'file')
                        create_DATM(fname,longxy,latixy,datetag,tday,varnames,vars);
                    end
                end
            end
            else
            fprintf([domain ' ' model ' ' scenarios{i} ' ' tag{j} ' ' time_intervals{k} ' is already processed!\n']);
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
    
    varnames = {'PSRF','TBOT','WIND','QBOT'};

    parfor k = 1 : length(time_intervals)
        t1 = datenum(str2num(time_intervals{k}(1:4)),1,1,0,0,0);
        t2 = datenum(str2num(time_intervals{k}(6:9)),12,31,0,0,0);
        t  = t1 : t2;
        [yr,mo,da] = datevec(t);
        
        process_this_file = 0;
        for iy = min(yr) : max(yr)
            for im = 1 : 12
                [datetag,datetag2] = get_datetag(iy,im,scenarios{i});
                folder = ['./data/forcings/' domain '/' model '/' scenarios{i} '/TPQWL'];
                fname = [folder '/clmforc.' model '.' scenarios{i} '.c2107.0.5x0.5.TPQWL.' datetag(1:7) '.nc'];
                %fname = [folder '/clmforc.' model '.' scenarios{i} '.' datetag(1:7) '.c2107.0.5x0.5.TPQWL.' datetag2(1:7) '.nc'];
                if ~exist(fname,'file')
                    process_this_file = 1;
                end
            end
        end
        
        if process_this_file
            
        fprintf([domain ' ' model ' ' scenarios{i} ' TPQWL ' time_intervals{k} ' is not processed yet... Start to process:\n']);
            
        filename1 = [upper(model) '/' scenarios{i} '/psAdjust/'      model '_r1i1p1f1_w5e5_' scenarios{i} '_psAdjust_global_daily_'      time_intervals{k} '.nc'];
        filename2 = [upper(model) '/' scenarios{i} '/sfcWindAdjust/' model '_r1i1p1f1_w5e5_' scenarios{i} '_sfcWindAdjust_global_daily_' time_intervals{k} '.nc'];
        filename3 = [upper(model) '/' scenarios{i} '/hussAdjust/'    model '_r1i1p1f1_w5e5_' scenarios{i} '_hussAdjust_global_daily_'    time_intervals{k} '.nc'];
        filename4 = [upper(model) '/' scenarios{i} '/tasmaxAdjust/'  model '_r1i1p1f1_w5e5_' scenarios{i} '_tasmaxAdjust_global_daily_'  time_intervals{k} '.nc'];
        filename5 = [upper(model) '/' scenarios{i} '/tasminAdjust/'  model '_r1i1p1f1_w5e5_' scenarios{i} '_tasminAdjust_global_daily_'  time_intervals{k} '.nc'];
        
        if strcmp(domain,'NLDAS')
            disp(['Reading ' filename1]);
            psAdjust      = ncread(filename1,'psAdjust',[irow1,icol1,1],[irow2-irow1+1,icol2-icol1+1,inf]);
            disp(['Reading ' filename2]);
            sfcWindAdjust = ncread(filename2,'sfcWindAdjust',[irow1,icol1,1],[irow2-irow1+1,icol2-icol1+1,inf]);
            disp(['Reading ' filename3]);
            hussAdjust    = ncread(filename3,'hussAdjust',[irow1,icol1,1],[irow2-irow1+1,icol2-icol1+1,inf]);
            disp(['Reading ' filename4]);
            tasmaxAdjust  = ncread(filename4,'tasmaxAdjust',[irow1,icol1,1],[irow2-irow1+1,icol2-icol1+1,inf]);
            disp(['Reading ' filename5]);
            tasminAdjust  = ncread(filename5,'tasminAdjust',[irow1,icol1,1],[irow2-irow1+1,icol2-icol1+1,inf]);
        else
            psAdjust      = ncread(filename1,'psAdjust');
            sfcWindAdjust = ncread(filename2,'sfcWindAdjust');
            hussAdjust    = ncread(filename3,'hussAdjust');
            tasmaxAdjust  = ncread(filename4,'tasmaxAdjust');
            tasminAdjust  = ncread(filename5,'tasminAdjust');
        end
        
        lon = ncread(filename1,'lon');
        lat = ncread(filename1,'lat');
        [longxy,latixy] = meshgrid(lon,lat); 
        longxy = longxy';
        latixy = latixy';
        if strcmp(domain,'NLDAS')
            longxy = longxy(irow1:irow2,icol1:icol2);
            latixy = latixy(irow1:irow2,icol1:icol2);
        end
        
        [m,n,~] = size(psAdjust);
        
        nyrs = length(unique(yr));
        
        for iy = min(yr) : max(yr)
            for im = 1 : 12
                [datetag,datetag2] = get_datetag(iy,im,scenarios{i});
                
                P3h = NaN(m,n,days_of_month(im)*8);
                W3h = NaN(m,n,days_of_month(im)*8);
                Q3h = NaN(m,n,days_of_month(im)*8);
                T3h = NaN(m,n,days_of_month(im)*8);
                
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
                    P3h(:,:,(id-1)*8+1:id*8) = repmat(Pday(:,:,id),1,1,8);
                    W3h(:,:,(id-1)*8+1:id*8) = repmat(Wday(:,:,id),1,1,8);
                    Q3h(:,:,(id-1)*8+1:id*8) = repmat(Qday(:,:,id),1,1,8);
                    for i2 = 1 : m
                        for j2 = 1 : n
                            t_min = round(hr_min(i2,j2,im,id)/3);
                            t_max = round(hr_max(i2,j2,im,id)/3);
                            T3h(i2,j2,(id-1)*8 + t_max) = Tmaxday(i2,j2,id);
                            T3h(i2,j2,(id-1)*8 + t_min) = Tminday(i2,j2,id);
                            if id == 1
                                T3h(i2,j2,(id-1)*8 + 1) = (Tmaxday(i2,j2,id) + Tminday(i2,j2,id))/2;
                            elseif id == numd
                                T3h(i2,j2,(id-1)*8 + 8) = (Tmaxday(i2,j2,id) + Tminday(i2,j2,id))/2;
                            end
%                             if abs(hr_max(i2,j2,1) - hr_min(i2,j2,1)) <= 2
%                                 T3h(i2,j2,(id-1)*8 + 5) = Tmaxday(i2,j2,id);
%                                 T3h(i2,j2,(id-1)*8 + 2) = Tminday(i2,j2,id);
%                             else
%                                 T3h(i2,j2,(id-1)*8 + hr_max(i2,j2,im)) = Tmaxday(i2,j2,id);
%                                 T3h(i2,j2,(id-1)*8 + hr_min(i2,j2,im)) = Tminday(i2,j2,id);
%                             end
                        end
                    end
                end
                
                for i2 = 1 : m
                    for j2 = 1 : n
                        tmp = T3h(i2,j2,:); 
                        tmp = tmp(:);
                        inotnan = find(~isnan(tmp));
                        % Cubic Hermite Interpolating Polynomial
                        T3h(i2,j2,:) = pchip(t3h(inotnan),tmp(inotnan),t3h);
                        %T3h(i2,j2,:) = interp1(t3h(inotnan),tmp(inotnan),t3h,'spline','extrap');
                    end
                end
                
                vars = cell(4,1);
                vars{1} = P3h;
                vars{2} = T3h;
                vars{3} = W3h;
                vars{4} = Q3h;
                
                folder = ['./data/forcings/' domain '/' model '/' scenarios{i} '/TPQWL'];
                if ~exist(folder,'dir')
                    mkdir(folder);
                end
                fname = [folder '/clmforc.' model '.' scenarios{i} '.c2107.0.5x0.5.TPQWL.' datetag(1:7) '.nc'];
                %fname = [folder '/clmforc.' model '.' scenarios{i} '.' datetag(1:7) '.c2107.0.5x0.5.TPQWL.' datetag2(1:7) '.nc'];
                disp(['Generating ' fname]);
                if ~exist(fname,'file')
                    create_DATM(fname,longxy,latixy,datetag,t3h',varnames,vars);
                end
            end
        end
        fprintf([domain ' ' model ' ' scenarios{i} ' TPQWL ' time_intervals{k} ' is already processed!\n']);
        end
    end
end

if 0 
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

hr_max = round(hr_max);
hr_min = round(hr_min);
tmp = hr_max;
hr_max(1:360,:,:) = tmp(361:720,:,:);
hr_max(361:720,:,:) = tmp(1:360,:,:);
hr_max = flip(hr_max,2);

tmp = hr_min;
hr_min(1:360,:,:) = tmp(361:720,:,:);
hr_min(361:720,:,:) = tmp(1:360,:,:);
hr_min = flip(hr_min,2);
clear tmp;
end

