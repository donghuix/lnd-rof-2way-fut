clear;close all;clc;

model     = 'ukesm1-0-ll';

scenarios = {'ssp126','ssp370'};

vars      = {'Prec','Solr','TPQWL'};

for i = 1 : length(scenarios)
    for j = 1 : length(vars)
        scenario = scenarios{i};
        var      = vars{j};
        
        for ii = 2015 : 2100
            for jj = 1 : 12
                if jj < 10
                    mon = ['0' num2str(jj)];
                    datetag = ['days since ' num2str(ii) '-0' num2str(jj) '-01'];
                else
                    mon = num2str(jj);
                    datetag = ['days since ' num2str(ii) '-' num2str(jj) '-01'];
                end
                
                filename = ['./data/forcings/NLDAS/' model '/' scenario '/' var '/clmforc.' model '.' scenario '.c2107.0.5x0.5.' var '.' num2str(ii) '-' mon '.nc'];
                
                disp(filename);
                disp(datetag);
                
                ncwriteatt(filename,'time','units',datetag);
                
            end
        end
        
    end
end