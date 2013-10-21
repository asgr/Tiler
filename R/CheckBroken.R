CheckBroken <-
function(plate=0,basedir='~/Work/R/GAMA/Tiling/',configdir="/Applications/Work/configure-7.10.Darwin/"){

dir.create(paste(basedir,'/Broken', sep=''),showWarnings=FALSE,recursive=TRUE)

data(brokengrid,package='Tiler')

runCONFIG(brokengrid[,1],brokengrid[,2],1:800,rep(1,800),rep(20,800),directory='Broken/',file='Fib',guides=TRUE,sky=FALSE,stanspec=FALSE,plate=plate,configdir=configdir,IPorig=rep(1,800),basedir=basedir)
templist=readLines(paste(basedir,'/Broken/FibP',plate,'.lis',sep=''))
startFibs=grep('\\*Fibre',templist)
tarIDs=grep('\\*.*G.*G.*',templist)-startFibs
guideIDs=grep('\\*.*guide',templist)-startFibs

return=list(workingMain=tarIDs,workingGuide=guideIDs,brokenMain=(1:400)[-c(tarIDs,seq(50,400,by=50))],brokenGuide=seq(50,400,by=50)[! seq(50,400,by=50) %in% guideIDs])
}
