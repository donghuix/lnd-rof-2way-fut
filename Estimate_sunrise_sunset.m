clear;close all;clc;

ele = ncread('/global/cfs/cdirs/e3sm/inputdata/rof/mosart/MOSART_Global_half_20210422.nc','ele5');
[m,n] = size(ele);
hr_min = NaN(m,n,12);
hr_max = NaN(m,n,12);
longxy = ncread('/project/projectdirs/m3780/donghui/Runoff_Projection_Uncertainty/inputdata/domain.lnd.360x720_isimip.3b.c211109.nc','xc');
latixy = ncread('/project/projectdirs/m3780/donghui/Runoff_Projection_Uncertainty/inputdata/domain.lnd.360x720_isimip.3b.c211109.nc','yc');
frac   = ncread('/project/projectdirs/m3780/donghui/Runoff_Projection_Uncertainty/inputdata/domain.lnd.360x720_isimip.3b.c211109.nc','frac');
days_of_month = [31;28;31;30;31;30;31;31;30;31;30;31];

parpool('local',32);
for i2 = 1 : m
    for j2 = 1 : n
        disp(['i = ' num2str(i2) ', j = ' num2str(j2)]);
        tic;
        parfor im = 1 : 12
            id = 15;
            ymd = get_ymd(2010,im,id);

            [srise,sset] = sunrise(latixy(i2,j2),longxy(i2,j2),ele(i2,j2),0,ymd);
            [~,~,~,hr_rise,mi_rise] = datevec(srise);
            [~,~,~,hr_set,mi_set]   = datevec(sset);
            hr_rise = hr_rise + mi_rise/60;
            hr_set  = hr_set  + mi_set/60;
            hr_min(i2,j2,im) = hr_rise;
            hr_max(i2,j2,im) = hr_rise + 0.67*(hr_set - hr_rise);

        end
        toc;
    end
end

save('sunrise_set.mat','hr_min','hr_max');