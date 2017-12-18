updateExtFibs <-
function(configdir='/Applications/Work/configure-7.10.Darwin'){
configdir=path.expand(configdir)
configdir=paste(configdir,'/data_files/',sep='')

check=try(download.file('ftp://ftp.aao.gov.au/pub/2df/2dF_distortion.map',destfile='temp'))
if(class(check)!='try-error'){file.rename(from='temp',to=paste(configdir,'2dF_distortion.map',sep=''))}

check=try(download.file('ftp://ftp.aao.gov.au/pub/2df/latest_config_files/tdFconstantsDF.sds',destfile='temp'))
if(class(check)!='try-error'){file.rename(from='temp',to=paste(configdir,'tdFconstantsDF.sds',sep=''))}

check=try(download.file('ftp://ftp.aao.gov.au/pub/2df/latest_config_files/tdFdistortion0.sds',destfile='temp'))
if(class(check)!='try-error'){file.rename(from='temp',to=paste(configdir,'tdFdistortion0.sds',sep=''))}

check=try(download.file('ftp://ftp.aao.gov.au/pub/2df/latest_config_files/tdFdistortion1.sds',destfile='temp'))
if(class(check)!='try-error'){file.rename(from='temp',to=paste(configdir,'tdFdistortion1.sds',sep=''))}

check=try(download.file('ftp://ftp.aao.gov.au/pub/2df/latest_config_files/tdFlinear0.sds',destfile='temp'))
if(class(check)!='try-error'){file.rename(from='temp',to=paste(configdir,'tdFlinear0.sds',sep=''))}

check=try(download.file('ftp://ftp.aao.gov.au/pub/2df/latest_config_files//tdFlinear1.sds',destfile='temp'))
if(class(check)!='try-error'){file.rename(from='temp',to=paste(configdir,'tdFlinear1.sds',sep=''))}

closeAllConnections()
}
