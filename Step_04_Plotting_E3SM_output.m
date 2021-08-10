clear;close all;clc;

area = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','area');
rlen = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','rlen');
rwid = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','rwid');
rdep = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/MOSART_2way_LLR3_c210112_GSWP3.nc','rdep');
fch  = rwid.*rlen./area;

frac = ncread('/Users/xudo627/projects/land-river-two-way-coupling-new-inundation/domain.lnd.r05_oEC60to30v3.190418_GSWP3.nc','frac');

data1way = load('data/GFDL_FUT_1way_dmax.mat');
data2way = load('data/GFDL_FUT_2way_dmax.mat');
data     = load('data/GFDL_FUT_noinund_dmax.mat');
q1 = data1way.qmax(:,:,15:86);
q2 = data2way.qmax(:,:,15:86);
q3 = data.qmax(:,:,15:86);
f1 = data1way.fmax(:,:,15:86) - fch; f1(f1 <= 0) = NaN;
f2 = data2way.fmax(:,:,15:86) - fch; f2(f2 <= 0) = NaN;
ind = find(nanmean(f2,3) > 0.05);
OPT = 1;

if OPT == 1
%     q1 = q1.*86400.*365.*area./1000.*frac./1e9;
%     q2 = q2.*86400.*365.*area./1000.*frac./1e9;
%     q3 = q3.*86400.*365.*area./1000.*frac./1e9;
    f1 = f1.*area.*frac./1e6;
    f2 = f2.*area.*frac./1e6;
    
    qg1 = NaN(size(q1,3),1);
    qg2 = NaN(size(q1,3),1);
    qg3 = NaN(size(q1,3),1);
    fg1 = NaN(size(q1,3),1);
    fg2 = NaN(size(q1,3),1);
    for i = 1 : size(q1,3)
        tmp = q1(:,:,i);
        qg1(i) = nanmean(tmp(ind));
        tmp = q2(:,:,i);
        qg2(i) = nanmean(tmp(ind));
        tmp = q3(:,:,i);
        qg3(i) = nanmean(tmp(ind));
        
        tmp = f1(:,:,i);
        fg1(i) = nansum(tmp(ind));
        tmp = f2(:,:,i);
        fg2(i) = nansum(tmp(ind));
        
    end
    
    figure;
    plot(qg1,'r-','LineWidth',2); hold on; grid on;
    plot(qg2,'b-','LineWidth',2);
    plot(qg3,'k--','LineWidth',2);
    
    figure;
    plot(fg1,'r-','LineWidth',2); hold on; grid on;
    plot(fg2,'b-','LineWidth',2);
    
    tr = zeros(720,360);
    z = NaN(720,360);
    for i = 1 : 720
        disp(i);
        for j = 1 : 360
            tmp = f1(i,j,:);
            tmp(tmp <= 0) = NaN;
            if ~all(isnan(tmp))
                [z(i,j), trend, h, p] = mk_test(tmp(:));
                if strcmp(trend,'increasing')
                    tr(i,j) = 1;
                elseif strcmp(trend,'decreasing')
                    tr(i,j) = -1;
                end
            end
        end
    end
    figure;
    rtmp = tr;
    tr(1:360,:)   = rtmp(361:720,:);
    tr(361:720,:) = rtmp(1:360,:);
    imagesc(flipud(tr')); colorbar;
    
    figure;
    rtmp = z;
    z(1:360,:)   = rtmp(361:720,:);
    z(361:720,:) = rtmp(1:360,:);
    imagesc(flipud(z')); colorbar;
    caxis([-5 5]); colormap(blue2red(121));
    
    rtmp = nanmean(q3,3);
    q(1:360,:)   = rtmp(361:720,:);
    q(361:720,:) = rtmp(1:360,:);
    imagesc(flipud(q')); colorbar;
    
elseif OPT == 2
    for i = 1 : 720
        disp(i);
        for j = 1 : 360
            tmp1 = q1(i,j,:); tmp1 = tmp1(:);
            tmp2 = q2(i,j,:); tmp2 = tmp2(:);
            if ~all(isnan(tmp1))
                parmhat1 = evfit(tmp1);
                parmhat2 = evfit(tmp2);
                x = evinv(0.99,parmhat1(1),parmhat1(2));
                flood2_100(i,j) = evcdf(x,parmhat2(1),parmhat2(2));
            end
        end
    end

    r1 = max(data2way.qmax(:,:,57:86),[],3) ./ max(data.qmax(:,:,57:86),[],3);

    rtmp = r1;
    r1(1:360,:)   = rtmp(361:720,:);
    r1(361:720,:) = rtmp(1:360,:);

    rtmp = max(data2way.qmax(:,:,57:86),[],3);
    qm1(1:360,:)   = rtmp(361:720,:);
    qm1(361:720,:) = rtmp(1:360,:);

    rtmp = max(data.qmax(:,:,57:86),[],3);
    qm2(1:360,:)   = rtmp(361:720,:);
    qm2(361:720,:) = rtmp(1:360,:);

    figure;
    imagesc(flipud(r1')); colorbar;
    caxis([0.5 1.5]); colormap(blue2red(121));

    figure;
    imagesc(flipud(qm1')); colorbar;

    figure;
    imagesc(flipud(qm2')); colorbar;


    r2 = std(data2way.qmax(:,:,1:86),[],3) ./ std(data1way.qmax(:,:,1:86),[],3);

    rtmp = r2;
    r2(1:360,:)   = rtmp(361:720,:);
    r2(361:720,:) = rtmp(1:360,:);
    figure;
    imagesc(flipud(r2')); colorbar;
    caxis([0.9 1.1]); colormap(blue2red(121));

    rtmp = flood2_100;
    flood2_100(1:360,:)   = rtmp(361:720,:);
    flood2_100(361:720,:) = rtmp(1:360,:);
    figure;
    imagesc(flipud(1./(1-flood2_100)')); colorbar; caxis([0 200]); colormap(blue2red(11));

    r3 = (nanmean(f2,3) - nanmean(f1,3)) ./ nanmean(f1,3);
    rtmp = r3;
    r3(1:360,:)   = rtmp(361:720,:);
    r3(361:720,:) = rtmp(1:360,:);
    figure;
    imagesc(flipud(r3')); colorbar;
    caxis([-0.1 0.1]); colormap(blue2red(121));

    r4 = nanmean(data2way.tmax(:,:,1:86) - data1way.tmax(:,:,1:86),3);
    rtmp = r4;
    r4(1:360,:)   = rtmp(361:720,:);
    r4(361:720,:) = rtmp(1:360,:);
    figure;
    imagesc(flipud(r4')); colorbar;
    caxis([-7 7]); colormap(blue2red(121));
end