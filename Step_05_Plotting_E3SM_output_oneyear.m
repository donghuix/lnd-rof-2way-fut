clear;close all;clc;

area = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','area');
rlen = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','rlen');
rwid = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','rwid');
rdep = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','rdep');
fch  = rwid.*rlen./area;

areaTotal = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','areaTotal2');
areaTotal(isnan(areaTotal)) = 0;
a = sort(areaTotal(:),'descend');
ind = find(areaTotal == a(2));

data1 = load('data/GFDL_FUT_1way_86.mat');
data2 = load('data/GFDL_FUT_2way_86.mat');

[ir,ic] = ind2sub([720,360],ind);

r = nanmean(data2.qd,3)./nanmean(data1.qd,3);
ind = find(r > 1.1 & r > 0);
[ir,ic] = ind2sub([720,360],ind(2));

qamaz1 = data1.qd(ir,ic,:); qamaz1 = qamaz1(:);
qamaz2 = data2.qd(ir,ic,:); qamaz2 = qamaz2(:);

famaz1 = data1.fd(ir,ic,:); famaz1 = famaz1(:);
famaz2 = data2.fd(ir,ic,:); famaz2 = famaz2(:);


figure;
plot(qamaz1,'r-','LineWidth',1);
hold on;
plot(qamaz2,'b--','LineWidth',1);

figure;
plot(famaz1,'r-','LineWidth',1);
hold on;
plot(famaz2,'b--','LineWidth',1);
figure;
plot(famaz2 - famaz1);