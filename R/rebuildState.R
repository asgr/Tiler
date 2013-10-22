rebuildState <-
function(directory='default', TileCat=TileV4f, inputfile=FALSE, position='g09', plate=0, denpri=8, minpri=1, bw=sqrt(2)/10, date='auto', report=FALSE, pdfopen=FALSE, movie=FALSE, updatefib=FALSE, byden=TRUE, basedir='~/Work/R/GAMA/Tiling/', configdir='/Applications/Work/configure-7.9.Darwin', convertdir='/sw/bin', latexdir='/usr/texbin', dvipsdir='/sw/bin',survey=1){
if(any(colnames(TileCat)=='CATAID')){colnames(TileCat)[colnames(TileCat)=='CATAID']='CATA_INDEX'}
options(scipen=999)
options(stringsAsFactors=FALSE)
continue=FALSE
tileplus='???'
start='???'
runfolder='???'
interact=FALSE
manual=FALSE

print(paste('Rebuilding survey state for',position))

info=read.table(paste(basedir,'/SurveyInfo.txt',sep=''),header=T)

if(directory=='default'){directory=paste(paste(position,collapse=''),'/Observed/',sep='')}

if(inputfile==FALSE){
	filelist=list.files(paste(basedir,'/',directory,sep=''))
	lissubset=grep(paste('.*tile.*lis',sep=''),filelist)
	#listloc={}
	filelist=filelist[lissubset]
	#for(i in 1:listlen){
	#listloc=c(listloc,grep(paste('tile',i,'-.*lis',sep=''),filelist))
	#}
	#filelist=filelist[listloc]
	}else{
filelist=readLines(paste(basedir,'/',directory,'/',inputfile,sep=''))}

print(paste('Files that will be used:',filelist))
	
#Checks the survey has been started when continue=TRUE.

#Checks whether the plate/date flag is a legal vector length, which is either 1 (in which case all plate codes are set to the same value for that run) or equal to tileplus

#Makes sure the directories have a trailing slash, doesn't matter if there are two.
directory=paste(directory,'/',sep='')
basedir=path.expand(basedir)
basedir=paste(basedir,'/',sep='')
configdir=path.expand(configdir)
configdir=paste(configdir,'/',sep='')
latexdir=path.expand(latexdir)
latexdir=paste(latexdir,'/',sep='')
dvipsdir=path.expand(dvipsdir)
dvipsdir=paste(dvipsdir,'/',sep='')

#Here I install (if required) and load the relevant packages
#if(!'fields' %in% installed.packages()[,'Package']){print('Installing required fields package');install.packages('fields')}
#if(!'plotrix' %in% installed.packages()[,'Package']){print('Installing required plotrix package');install.packages('plotrix')}
#library(fields,lib=.libPaths('/home/aatlxa/gama/R/x86_64-redhat-linux-gnu-library/2.9/'))
#library(plotrix,lib=.libPaths('/home/aatlxa/gama/R/x86_64-redhat-linux-gnu-library/2.9/'))
library(fields,lib=c('/home/aatlxa/gama/R/x86_64-redhat-linux-gnu-library/2.9/',.libPaths()))
library(plotrix,lib=c('/home/aatlxa/gama/R/x86_64-redhat-linux-gnu-library/2.9/',.libPaths()))
#Special function to cope with a sample size of only one value (i.e. it will only return that value)
resample <- function(x, size, ...)
  if(length(x) <= 1) { if(!missing(size) && size == 0) x[FALSE] else x
  } else sample(x, size, ...)
#Sets the now decided values for various parameters, i.e. byden=TRUE
comp=1
FFT=FALSE
shift=FALSE
#startrefs=TileCat[,'CATA_INDEX']

info=read.table(paste(basedir,'/SurveyInfo.txt',sep=''),header=T)

RAadd=min(TileCat[TileCat[,'POSITION']%in%position,'RA'])
Decadd=min(TileCat[TileCat[,'POSITION']%in%position,'DEC'])
raran=max(TileCat[TileCat[,'POSITION']%in%position,'RA'])-min(TileCat[TileCat[,'POSITION']%in%position,'RA'])
decran=max(TileCat[TileCat[,'POSITION']%in%position,'DEC'])-min(TileCat[TileCat[,'POSITION']%in%position,'DEC'])
loc=position
skirt=info[1,'Skirt']
year=info[1,'Year']
semester=info[1,'Sem']
run=info[1,'Run']
denpri=info[1,'Denpri']
minpri=info[1,'LoPclass']
survey=info[1,'MainSclass']
byden=info[1,'ByDen']
magbin=5
lolim=22

TileSub=TileCat[TileCat[,'POSITION']%in%position & TileCat[,'PRIORITY_CLASS']>=minpri,'CATA_INDEX']
AssignOrder=cbind(TileCat[TileCat[,'PRIORITY_CLASS']>=minpri & TileCat[,'POSITION']%in%position,'CATA_INDEX'])
AssignOrder=cbind(AssignOrder,rep(0,length(AssignOrder[,1])),TileCat[TileCat[,'CATA_INDEX'] %in% AssignOrder[,1],'PRIORITY_CLASS'])
MagLims={}
tilelim={}
arguments={}
fibstats={}
startrun=1

TileSub=AssignOrder[AssignOrder[,2]==0,1]

catname='Undefined (check)'

#Set colnames for tilelim

arguments=c(arguments,paste('Tiler(tileplus= ',tileplus,', position= ',position,', directory= ',directory,', plate= ',plate[1],', continue= ',continue,', interact= ',interact,', manual= ',manual,', start= ',start,', denpri= ',denpri,', minpri= ',minpri,', bw= ',bw,', TileCat= ',catname,', skirt= ',skirt,', date= ',date[1],', report= ',report,', pdfopen= ',pdfopen,', movie= ',movie,', updatefib= ',updatefib,', byden= ',byden,', basedir= ',basedir,', configdir= ',configdir,', convertdir= ',convertdir,', latexdir= ',latexdir,', dvipsdir= ',dvipsdir,')',sep=''))

#Generates an inner region to search within when choosing tile centres. From Full simulations of tiling G09 seem to indicate that a 0.4 degree inner skirt as about optimum

testgrid=expand.grid(seq(RAadd+skirt,RAadd+raran-skirt,by=0.1),seq(Decadd+skirt,Decadd+decran-skirt,by=0.1))

#Used to have (TileCat[,'S']>0 & TileCat[,'Q']>2), but I don't think we should have the latter 'Q'>2 since this is time dependent in effect
if(byden){
tempTilePos=TileCat[TileCat[,'SURVEY_CLASS']>=survey & TileCat[,'POSITION']%in%position,c('RA','DEC')]
tartestPos={}

sparsedists=try(fields.rdist.near(sph2car(as.matrix(testgrid),deg=T),sph2car(as.matrix(tempTilePos[,1:2]),deg=T),mean.neighbor=max(ceiling(c(100,length(tempTilePos[,1])/((raran*decran)/pi)))),delta=pi/180))
if(class(sparsedists)=='try-error'){
  sparsedists=try(fields.rdist.near(sph2car(as.matrix(testgrid),deg=T),sph2car(as.matrix(tempTilePos[,1:2]),deg=T),mean.neighbor=2*max(ceiling(c(100,length(tempTilePos[,1])/((raran*decran)/pi)))),delta=pi/180))
}
if(class(sparsedists)=='try-error'){
  sparsedists=try(fields.rdist.near(sph2car(as.matrix(testgrid),deg=T),sph2car(as.matrix(tempTilePos[,1:2]),deg=T),mean.neighbor=4*max(ceiling(c(100,length(tempTilePos[,1])/((raran*decran)/pi)))),delta=pi/180))
}
	
tartestPos=rep(0,length(testgrid[,1]))
sparsedists=table(sparsedists$ind[,1])
tartestPos[as.numeric(names(sparsedists))]=as.numeric(sparsedists)
}


dir.create(paste(basedir,directory,sep=''),showWarnings=FALSE,recursive=TRUE)

#Update internal fibre tiles
if(updatefib){
  updateExtFibs(configdir=configdir)
  updateIntFibs(configdir=configdir,basedir=basedir)
}

stopstate=list(assign=AssignOrder,maglim=MagLims,tilelim=tilelim,current=installed.packages()['Tiler','Version'],loc=loc,args=arguments,fibstats=fibstats)
try(save(stopstate,file=paste(basedir,directory,'stopstate.r',sep='')))

#First frames for tiling annimations generated here, but only when continue==FALSE, i.e. the first time a new tiling strategy is run
if(continue==FALSE){
png(paste(basedir,directory,'/RelCircDen000.png',sep=''),width=600,height=600)
tempden=MakeCircDen(stopstate,TileCat=TileCat,hirpet=lolim,res=0.05,assignlim=0,bw=bw,denpri=denpri,position=position,basedir=basedir)
dev.off()
tempden$z[is.na(tempden$z)]=1
}

MSsel=TileCat[,'SURVEY_CLASS']>=survey & TileCat[,'POSITION']%in%position

#The main loop starts here!!!!!!!!!!!!!!!!!!!!!!!!!
for(totruns in 1:length(filelist)){
#Checks for file called 'stop' in main directory.
if(file.exists(paste(basedir,directory,'/stop',sep=''))){stop('STOPPING!!!')}

runs=as.numeric(unlist(strsplit(unlist(strsplit(filelist[totruns],split='.*tile'))[2],split='-'))[1])

print(paste('Run',runs,'. Remaining',length(filelist)-totruns+1))
completeness=1-length(TileCat[MSsel & TileCat[,'CATA_INDEX'] %in% TileSub & TileCat[,'PRIORITY_CLASS']>=denpri,1])/length(TileCat[MSsel,1])

print(paste('Remaining top priority objects:',length(TileCat[MSsel & TileCat[,'PRIORITY_CLASS']>=denpri & TileCat[,'CATA_INDEX'] %in% TileSub,1])))

print(paste('Survey Total Completeness',completeness))
	
tempTile=TileCat[TileCat[,'CATA_INDEX'] %in% TileSub & TileCat[,'PRIORITY_CLASS']>=denpri,c('RA','DEC','CATA_INDEX','R_PETRO')]	

templist=readLines(paste(basedir,directory,filelist[totruns],sep=''))
tarIDs=grep('\\*.*G.*G.*',templist)
guideIDs=grep('\\*.*guide',templist)
skyIDs=grep('\\*.*sky',templist)
specIDs=grep('\\*.*stspec',templist)
ParkIDs=grep('\\*.*Parked',templist)
startFibs=grep('\\*Fibre',templist)
dumpIDs={}

for(i2 in 1:length(tarIDs)){	
dumpIDs=c(dumpIDs,as.numeric(unlist(strsplit(unlist(strsplit(templist[tarIDs[i2]]," +"))[3],'G'))[2]))}

plate=as.numeric(sub('\\.lis','',sub('.*P','',filelist[totruns])))

FibVec=rep(0,400)
FibVec[c(Fibres[[plate+1]]$brokenMain,Fibres[[plate+1]]$brokenGuide)]=99
FibVec[tarIDs-startFibs]=1
FibVec[guideIDs-startFibs]=2
FibVec[skyIDs-startFibs]=3
FibVec[specIDs-startFibs]=4

cat(paste('Fibre info for plate ',plate,sep=''))
cat(paste('\nMain working\t\t',length(Fibres[[plate+1]]$workingMain),sep=''))
cat(paste('\nMain Broken\t\t\t',length(Fibres[[plate+1]]$brokenMain),sep=''))
cat(paste('\nUsed for survey\t\t',length(which(FibVec==1)),sep=''))
cat(paste('\nUsed for sky\t\t',length(which(FibVec==3)),sep=''))
cat(paste('\nUsed for guide\t\t',length(which(FibVec==2)),sep=''))
cat(paste('\nUsed for spectra\t',length(which(FibVec==4)),sep=''))
cat(paste('\nUnused working\t\t',length(which(FibVec==0)),'\n',sep=''))

tiletext=(unlist(strsplit(templist[grep('CENTRE',templist)]," +")))
if(length(grep('\\+',tiletext[5]))==1){decsign=1}
if(length(grep('\\-',tiletext[5]))==1){decsign=-1}

tilecens=cbind(hms2deg(as.numeric(tiletext[2]),as.numeric(tiletext[3]),as.numeric(tiletext[4])),dms2deg(abs(as.numeric(tiletext[5])),as.numeric(tiletext[6]),as.numeric(tiletext[7]),decsign))

print(paste('Final used tile centre:',tilecens[1,1],'(RA/deg)',tilecens[1,2],'(Dec/deg)'))

temp=list(dumpID=dumpIDs,tileCens=tilecens,fibstats=FibVec)

#Here we find which objects have been assigned
tileloc=temp$tileCens
AssignOrder[AssignOrder[,1] %in% temp$dumpID,2]=runs
TileSub=AssignOrder[AssignOrder[,2]==0,1]
fibstats=rbind(fibstats,temp$fibstats)

#Calculates the 0.1 magnitude bin completeness
magcompleteness=1-hist(TileCat[TileCat[,'R_PETRO']>15 & TileCat[,'R_PETRO']<24 & TileCat[,'PRIORITY_CLASS']>=denpri & TileCat[,'POSITION']%in%position & TileCat[,'CATA_INDEX'] %in% TileSub,'R_PETRO'],breaks=seq(15, 24,by=0.1),plot=FALSE)$counts/hist(TileCat[MSsel & TileCat[,'R_PETRO']>15 & TileCat[,'R_PETRO']<24,'R_PETRO'],breaks=seq(15, 24,by=0.1),plot=FALSE)$counts
#Calculates the new total completeness that is printed out to the tilelim object that tracks the progress of the tiling
completeness=1-length(TileCat[TileCat[,'PRIORITY_CLASS']>=denpri & TileCat[,'POSITION']%in%position & TileCat[,'CATA_INDEX'] %in% TileSub,1])/length(TileCat[MSsel,1])
#make MagLims in the format needed for MakCircDen
MagLims=rbind(MagLims,magcompleteness)

png(paste(basedir,directory,'/RelCircDen',formatC(runs,flag=0,width=3),'.png',sep=''),width=600,height=600)
tempden=MakeCircDen(data=list(assign=AssignOrder),TileCat=TileCat,hirpet=lolim,res=0.05,assignlim=runs,bw=bw,denpri=denpri,position=position,basedir=basedir)
dev.off()
tempden$z[is.na(tempden$z)]=0
check80=length(which(as.numeric(tempden$z)<=0.2))/length(as.numeric(tempden$z))
check80g5=length(which(as.numeric(tempden $z[tempden $allz>=5])<=0.2))/length(as.numeric(tempden $z[tempden $allz>=5]))

tilelim=rbind(tilelim,data.frame(No.=runs, Comp=completeness, RA=as.numeric(tileloc)[1], Dec=as.numeric(tileloc)[2], Left=length(TileCat[TileCat[,'PRIORITY_CLASS']>=denpri & TileCat[,'POSITION']%in%position & TileCat[,'CATA_INDEX'] %in% TileSub,1]), AngComp=check80,AngComp5=check80g5,Plate=plate,Den=byden,Date=date(), Int=interact, Man=manual))

stopstate=list(assign=AssignOrder,maglim=MagLims,tilelim=tilelim,current=installed.packages()['Tiler','Version'],loc=loc,args=arguments,catname=catname,fibstats=fibstats)
try(save(stopstate,file=paste(basedir,directory,'stopstate.r',sep='')))

}

stopstate=list(assign=AssignOrder,maglim=MagLims,tilelim=tilelim,current=installed.packages()['Tiler','Version'],loc=loc,args=arguments,catname=catname,fibstats=fibstats)
try(save(stopstate,file=paste(basedir,directory,'stopstate.r',sep='')))

if(report){try(report(directory=directory,TileCat=TileCat,basedir=basedir,latex=TRUE,latexdir=latexdir,dvipsdir=dvipsdir,pdfopen=pdfopen))}

return=stopstate

}
