clear;close all;clc;

data1way = load('data/GFDL_FUT_1way_dmax.mat');
data2way = load('data/GFDL_FUT_2way_dmax.mat');
data     = load('data/GFDL_FUT_noinund_dmax.mat');
q1 = data1way.qmax(:,:,57:86);
q2 = data2way.qmax(:,:,57:86);
q3 = data.qmax(:,:,57:86);

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

r3 = max(data2way.fmax(:,:,1:86),[],3) ./ max(data1way.fmax(:,:,1:86),[],3);
rtmp = r3;
r3(1:360,:)   = rtmp(361:720,:);
r3(361:720,:) = rtmp(1:360,:);
figure;
imagesc(flipud(r3')); colorbar;
caxis([0.9 1.1]); colormap(blue2red(121));

r4 = nanmean(data2way.tmax(:,:,1:86) - data1way.tmax(:,:,1:86),3);
rtmp = r4;
r4(1:360,:)   = rtmp(361:720,:);
r4(361:720,:) = rtmp(1:360,:);
figure;
imagesc(flipud(r4')); colorbar;
caxis([-7 7]); colormap(blue2red(121));