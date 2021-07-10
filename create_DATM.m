function create_DATM(fname,longxy,latixy,date_tag,time,varnames,vars)
    ncid = netcdf.create(fname,'NETCDF4');
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%                           Define dimensions
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    [nlon,nlat,nt] = size(vars{1});
    dimid(1) = netcdf.defDim(ncid,'scalar',1);
    dimid(2) = netcdf.defDim(ncid,'lon', nlon);
    dimid(3) = netcdf.defDim(ncid,'lat', nlat);
    dimid(4) = netcdf.defDim(ncid,'time',nt);
    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%                           Define variables
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ivar = 1;
varid(1) = netcdf.defVar(ncid,'time','NC_FLOAT',[dimid(4)]); 
netcdf.putAtt(ncid,ivar-1,'calendar','noleap');
netcdf.putAtt(ncid,ivar-1,'units',['days since ' date_tag]);

ivar = 2;
varid(2) = netcdf.defVar(ncid,'LONGXY','NC_FLOAT',[dimid(2) dimid(3)]); 
netcdf.putAtt(ncid,ivar-1,'long_name','longitude');
netcdf.putAtt(ncid,ivar-1,'units','degrees_east');
netcdf.putAtt(ncid,ivar-1,'mode','time-invariant');

ivar = 3;
varid(3) = netcdf.defVar(ncid,'LATIXY','NC_FLOAT',[dimid(2) dimid(3)]); 
netcdf.putAtt(ncid,ivar-1,'long_name','latitude');
netcdf.putAtt(ncid,ivar-1,'units','degrees_north');
netcdf.putAtt(ncid,ivar-1,'mode','time-invariant');

ivar = 4;
varid(4) = netcdf.defVar(ncid,'EDGEE','NC_FLOAT',[dimid(1)]); 
netcdf.putAtt(ncid,ivar-1,'long_name','eastern edge in atmospheric data');
netcdf.putAtt(ncid,ivar-1,'units','degrees_east');
netcdf.putAtt(ncid,ivar-1,'mode','time-invariant');

ivar = 5;
varid(5) = netcdf.defVar(ncid,'EDGEW','NC_FLOAT',[dimid(1)]); 
netcdf.putAtt(ncid,ivar-1,'long_name','western edge in atmospheric data');
netcdf.putAtt(ncid,ivar-1,'units','degrees_east');
netcdf.putAtt(ncid,ivar-1,'mode','time-invariant');

ivar = 6;
varid(6) = netcdf.defVar(ncid,'EDGES','NC_FLOAT',[dimid(1)]); 
netcdf.putAtt(ncid,ivar-1,'long_name','southern edge in atmospheric data');
netcdf.putAtt(ncid,ivar-1,'units','degrees_east');
netcdf.putAtt(ncid,ivar-1,'mode','time-invariant');

ivar = 7;
varid(7) = netcdf.defVar(ncid,'EDGEN','NC_FLOAT',[dimid(1)]); 
netcdf.putAtt(ncid,ivar-1,'long_name','northern edge in atmospheric data');
netcdf.putAtt(ncid,ivar-1,'units','degrees_east');
netcdf.putAtt(ncid,ivar-1,'mode','time-invariant');

for i = 1 : length(varnames)
    switch varnames{i}
        case 'PRECTmms'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(2) dimid(3) dimid(4)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','PRECTmms total precipitation');
            netcdf.putAtt(ncid,ivar+i-1,'units','mm H2O / sec');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        case 'FSDS'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(2) dimid(3) dimid(4)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','total incident solar radiation');
            netcdf.putAtt(ncid,ivar+i-1,'units','W/m**2');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        case 'PSRF'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(2) dimid(3) dimid(4)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','surface pressure at the lowest atm level');
            netcdf.putAtt(ncid,ivar+i-1,'units','Pa');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        case 'TBOT'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(2) dimid(3) dimid(4)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','temperature at the lowest atm level');
            netcdf.putAtt(ncid,ivar+i-1,'units','K');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        case 'WIND'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(2) dimid(3) dimid(4)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','wind at the lowest atm level');
            netcdf.putAtt(ncid,ivar+i-1,'units','m/s');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        case 'QBOT'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(2) dimid(3) dimid(4)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','specific humidity at the lowest atm level');
            netcdf.putAtt(ncid,ivar+i-1,'units','kg/kg');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        case 'FLDS'
            varid(ivar+i) = netcdf.defVar(ncid,varnames{i},'NC_FLOAT',[dimid(2) dimid(3) dimid(4)]);
            netcdf.putAtt(ncid,ivar+i-1,'long_name','incident longwave radiation');
            netcdf.putAtt(ncid,ivar+i-1,'units','W/m**2');
            netcdf.putAtt(ncid,ivar+i-1,'mode','time-dependent');
            netcdf.defVarFill(ncid,ivar+i-1,false,1e36);
            netcdf.putAtt(ncid,ivar+i-1,'missing_value',1e36);
        otherwise
            error('No such variable');
    end
end
varid = netcdf.getConstant('GLOBAL');
[~,user_name]=system('echo $USER');
netcdf.putAtt(ncid,varid,'Created_by' ,user_name(1:end-1));
netcdf.putAtt(ncid,varid,'Created_on' ,datestr(now,'ddd mmm dd HH:MM:SS yyyy '));
netcdf.endDef(ncid);

netcdf.putVar(ncid,1-1,time);
netcdf.putVar(ncid,2-1,longxy);
netcdf.putVar(ncid,3-1,latixy);
netcdf.putVar(ncid,4-1,360);
netcdf.putVar(ncid,5-1,0);
netcdf.putVar(ncid,6-1,-90);
netcdf.putVar(ncid,7-1,90);
for i = 1 : length(varnames)
    netcdf.putVar(ncid,7+i-1,vars{i});
end

netcdf.close(ncid);
end