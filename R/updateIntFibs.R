updateIntFibs <-
function(configdir='/Applications/Work/configure-7.10.Darwin',basedir='~/Work/R/GAMA/Tiling/'){
configdir=path.expand(configdir)
configdir=paste(configdir,'/',sep='')
print('UPDATING INTERNAL FIBRE LIST!!! THIS WILL TAKE ABOUT 3 MINUTES.')
dir.create(paste(basedir,'Broken',sep=''),showWarnings=FALSE,recursive=TRUE)
P0=CheckBroken(0,configdir=configdir,basedir=basedir)
P1=CheckBroken(1,configdir=configdir,basedir=basedir)
P2=list(workingMain=P0$workingMain[P0$workingMain %in% P1$workingMain],workingGuide=P0$workingGuide[P0$workingGuide %in% P1$workingGuide])
P2=c(P2,list(brokenMain=(1:400)[-c(P2$workingMain,seq(50,400,by=50))],brokenGuide=seq(50,400,by=50)[! seq(50,400,by=50) %in% P2$workingGuide]))
assign('Fibres',list(P0=P0,P1=P1,P2=P2,date=file.info(paste(configdir,'tdFdistortion0.sds',sep=''))[,'ctime']),envir=.GlobalEnv)}
