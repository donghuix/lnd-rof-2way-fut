function [datetag,datetag2] = get_datetag(iy,im,scenario)
    if im < 10
        datetag = [num2str(iy) '-0' num2str(im) '-01'];
        switch scenario
            case 'historical'
                datetag2 = [num2str(iy) '-0' num2str(im) '-01'];
            case 'ssp126'
                datetag2 = [num2str(iy-60) '-0' num2str(im) '-01'];
            case 'ssp370'
                datetag2 = [num2str(iy-30) '-0' num2str(im) '-01'];
            case 'ssp585'
                datetag2 = [num2str(iy) '-0' num2str(im) '-01'];
            otherwise 
                error('This scenario is not selected!');
        end
    else
        datetag = [num2str(iy) '-' num2str(im) '-01'];
        switch scenario
            case 'historical'
                datetag2 = [num2str(iy) '-' num2str(im) '-01'];
            case 'ssp126'
                datetag2 = [num2str(iy-60) '-' num2str(im) '-01'];
            case 'ssp370'
                datetag2 = [num2str(iy-30) '-' num2str(im) '-01'];
            case 'ssp585'
                datetag2 = [num2str(iy) '-' num2str(im) '-01'];
            otherwise 
                error('This scenario is not selected!');
        end
    end
end