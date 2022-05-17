function ymd = get_ymd(iy,im,id)
    if im < 10
        mm = ['0' num2str(im)];
    else
        mm = num2str(im);
    end
    if id < 10
        dd = ['0' num2str(id)];
    else
        dd = num2str(id);
    end
    
    ymd = [num2str(iy) '-' mm '-' dd];
    
end