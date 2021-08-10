clear;close all;clc;

addpath('/qfs/people/xudo627/Setup-E3SM-Mac/matlab-scripts-for-mosart');
wkdir = '/compyfs/xudo627/e3sm_scratch/';
scenarios = {'GFDL_FUT_1way_LLR3_7e85a10.2021-07-13-145042', ...
             'GFDL_FUT_2way_LLR3_7e85a10.2021-07-13-142352', ...
             'GFDL_FUT_noinund_LLR3_7e85a10.2021-07-14-194034'};
tag = {'GFDL_FUT_1way','GFDL_FUT_2way','GFDL_FUT_noinund'};

for i = 1 : 2%length(scenarios)
    qd = NaN(720,360,365);
    fd = NaN(720,360,365);
    for iyr = 86
        if iyr < 10 
            files = dir([wkdir scenarios{i} '/run/*mosart.h1.000' num2str(iyr) '*.nc']);
        elseif iyr < 100
            files = dir([wkdir scenarios{i} '/run/*mosart.h1.00' num2str(iyr) '*.nc']);
        elseif iyr < 1000
            files = dir([wkdir scenarios{i} '/run/*mosart.h1.0' num2str(iyr) '*.nc']);
        end
        q2 = NaN(720,360,length(files),2);
        data = cat_mosart(files,{'RIVER_DISCHARGE_OVER_LAND_LIQ','RIVER_DISCHARGE_TO_OCEAN_LIQ','FLOODPLAIN_FRACTION'}); % ,'FLOODPLAIN_FRACTION'
        q2(:,:,:,1) = data.RIVER_DISCHARGE_OVER_LAND_LIQ;
        q2(:,:,:,2) = data.RIVER_DISCHARGE_TO_OCEAN_LIQ;
        qd = nanmean(q2,4);
        %[qmax(:,:,iyr),tmax(:,:,iyr)] = max(q2,[],3);
        fd = data.FLOODPLAIN_FRACTION;
    end
    if ~exist('data','dir')
        mkdir('data');
    end
    save(['data/' tag{i} '_' num2str(iyr) '.mat'],'qd','fd');
end