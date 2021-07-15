clear;close all;clc;

addpath('/qfs/people/xudo627/Setup-E3SM-Mac/matlab-scripts-for-mosart');
wkdir = '/compyfs/xudo627/e3sm_scratch/';
scenarios = {'GFDL_FUT_1way_LLR3_7e85a10.2021-07-13-145042', ...
             'GFDL_FUT_2way_LLR3_7e85a10.2021-07-13-142352'};
tag = {'GFDL_FUT_1way','GFDL_FUT_2way'};

for i = 1 : length(scenarios)
    qmax = NaN(720,360,86);
    tmax = NaN(720,360,86);
    fmax = NaN(720,360,86);
    for iyr = 1 : 86
        if iyr < 10 
            files = dir([wkdir scenarios{i} '/run/*mosart.h1.000' num2str(iyr) '*.nc']);
        elseif iyr < 100
            files = dir([wkdir scenarios{i} '/run/*mosart.h1.00' num2str(iyr) '*.nc']);
        elseif iyr < 1000
            files = dir([wkdir scenarios{i} '/run/*mosart.h1.0' num2str(iyr) '*.nc']);
        end
        q2 = NaN(720,360,length(files),2);
        data = cat_mosart(files,{'RIVER_DISCHARGE_OVER_LAND_LIQ','RIVER_DISCHARGE_TO_OCEAN_LIQ','FLOODPLAIN_FRACTION'});
        q2(:,:,:,1) = data.RIVER_DISCHARGE_OVER_LAND_LIQ;
        q2(:,:,:,2) = data.RIVER_DISCHARGE_TO_OCEAN_LIQ;
        q2 = nanmean(q2,4);
        [qmax(:,:,iyr),tmax(:,:,iyr)] = max(q2,[],3);
        fmax(:,:,iyr) = max(data.FLOODPLAIN_FRACTION,[],3);
    end
    if ~exist('data','dir')
        mkdir('data');
    end
    save(['data/' tag{i} '_dmax.mat'],'qmax','tmax','fmax');
end