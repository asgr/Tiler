Tiler <-
function(tileplus=5, position='A3880', directory='default', plate=0, runfolder=FALSE, restrict='all', interact=FALSE, manual=FALSE,justfld=FALSE,dofailcomp=FALSE, start='default',norep=FALSE, bw=sqrt(2)/10, TileCat=TCsamiclusY1, runoffset=1, date='get', report=FALSE, pdfopen=FALSE, movie=FALSE, updatefib=FALSE, basedir='~/SAMI/cluster_tiling/samiY1SBRUN1/', configdir='/Applications/Work/configure-7.10.Darwin', convertdir='/sw/bin', latexdir='/Applications/TeX', dvipsdir='/sw/bin'){
if(any(colnames(TileCat)=='CATAID')){colnames(TileCat)[colnames(TileCat)=='CATAID']='CATA_INDEX'}
options(scipen=999)

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

if(directory=='default'){directory=paste(position,collapse='')}

if(file.exists(paste(basedir,'/',directory,'/Observed/stopstate.r',sep=''))){continue=TRUE}else{continue=FALSE}
dir.create(paste(basedir,'/',directory,'/Observed',sep=''),showWarnings=FALSE,recursive=TRUE)
	
#Checks the survey has been started when continue=TRUE.
if(continue==TRUE & file.exists(paste(basedir,'/',directory,'/Observed/stopstate.r',sep=''))==FALSE){print('stopstate.r does not exist in specified directory, set continue=FALSE to start a fresh field configuration.');break}

#Checks whether the plate/date flag is a legal vector length, which is either 1 (in which case all plate codes are set to the same value for that run) or equal to tileplus
if(tileplus>0 & ((length(plate)>1 & length(plate)<tileplus) | length(plate)>tileplus)){stop(paste('Length of plate vector is',length(plate),'should be either 1 or',tileplus))}
if(length(plate)==1){plate=rep(plate,tileplus)}
if(tileplus>0 & ((length(date)>1 & length(date)<tileplus) | length(date)>tileplus)){stop(paste('Length of date vector is',length(date),'should be either 1 or',tileplus))}
if(length(date)==1){date=rep(date,tileplus)}
if(tileplus>0 & ((length(restrict)>1 & length(restrict)<tileplus) | length(restrict)>tileplus)){stop(paste('Length of restrict vector is',length(restrict),'should be either 1 or',tileplus))}
if(length(restrict)==1){restrict=rep(restrict,tileplus)}

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

if(runfolder!=FALSE & runfolder!=TRUE){
	runfolder=paste(runfolder,'/',sep='')
}

#Here I install (if required) and load the relevant packages- needs adjusting depending on your machine
#if(!'fields' %in% installed.packages()[,'Package']){print('Installing required fields package');install.packages('fields')}
#if(!'plotrix' %in% installed.packages()[,'Package']){print('Installing required plotrix package');install.packages('plotrix')}
#library('fields',lib=c('/home/aatlxa/gama/R/x86_64-redhat-linux-gnu-library/2.9/',.libPaths()))
#library('plotrix',lib=c('/home/aatlxa/gama/R/x86_64-redhat-linux-gnu-library/2.9/',.libPaths()))

#Special function to cope with a sample size of only one value (i.e. it will only return that value)
#resample <- function(x, size, ...)
#if(length(x) <= 1) { if(!missing(size) && size == 0) x[FALSE] else x
#} else sample(x, size, ...)
#Sets the now decided values for various parameters, leave these alone unless you're trying to do something really clever!
comp=1
FFT=FALSE
shift=FALSE

#If you're starting a fresh run then continue will be FALSE, otherwise it picks up from where it finished tiling
if(continue==FALSE & tileplus>0){
	TileSub=TileCat[TileCat[,'POSITION']%in%position & TileCat[,'PRIORITY_CLASS']>=minpri,'CATA_INDEX']
	AssignOrder=cbind(TileCat[TileCat[,'PRIORITY_CLASS']>=minpri & TileCat[,'POSITION']%in%position,'CATA_INDEX'])
	AssignOrder=cbind(AssignOrder,rep(0,length(AssignOrder[,1])),TileCat[TileCat[,'CATA_INDEX'] %in% AssignOrder[,1],'PRIORITY_CLASS'])
	MagLims={}
	tilelim={}
	arguments={}
	fibstats={}
	startrun=runoffset
}else{
	#stopstate.r is all of the available tiling information for a run, so when continuing this must be loaded
	load(paste(basedir,directory,'Observed/stopstate.r',sep=''))
	#print out a summary for a sanity check
	print(summary(stopstate$assign))
	#Various vectors and tables are stripped out of the stopstate image and assigned to the correct object for the session
	AssignOrder=stopstate$assign
	MagLims=stopstate$maglim
	tilelim=stopstate$tilelim
	startrun=max(stopstate$assign[,2]+1)
	arguments=stopstate$args
	fibstats=stopstate$fibstats
	#This if statement isn't accessed in the normal DoTile script because start is always default- basically if you're tiling maually you can specify which tile you start from, 	this flexibility seemed unnecessary though
	if(start!='default'){startrun=start
		AssignOrder[AssignOrder[,2]>=start,2]=0
		if(length(tilelim)>0){
			exists=which(tilelim[,1] %in% 1:(start-1))
			MagLims=MagLims[exists,]
			tilelim=tilelim[exists,]
			fibstats=fibstats[exists,]
		}
	}
	TileSub=AssignOrder[AssignOrder[,2]==0,1]
}
norepvec=TileSub

#Runfolder is always TRUE in the DoTile script so this can be ignored- it is possible to give the runfolder a name etc manually 
if(runfolder!=FALSE){if(runfolder==TRUE){directory=paste(directory,'TargetFork',startrun,'-',startrun+tileplus-1,'P',plate[1],'/',sep='')}else{directory=paste(directory,'TargetFork',startrun,'-',startrun+tileplus-1,'P',plate[1],'-',runfolder,sep='')}}else{directory=paste(directory,'Observed/',sep='')}
catname='Undefined (check)'

#generates the vector of input arguments for future reference

#Set colnames for tilelim
#magbin used to be set to 2.4 and 2.8, but increased to 5, also lolim used to be 19.4 and 19.8. Changed so as to allow priority 8 objects (extra main survey k-band and z-band objects)
#Clearly this bit will need adjusting for any future GAMA regions- the minimum RA and DEC coordinates are required for offsetting

arguments=c(arguments,paste('Tiler(tileplus= ',tileplus,', position= ',position,', directory= ',directory,', plate= ',plate[1],', continue= ',continue,', interact= ',interact,', manual= ',manual,', start= ',start,', denpri= ',denpri,', minpri= ',minpri,', bw= ',bw,', TileCat= ',catname,', skirt= ',skirt,', date= ',date[1],', report= ',report,', pdfopen= ',pdfopen,', movie= ',movie,', updatefib= ',updatefib,', byden= ',byden,', basedir= ',basedir,', configdir= ',configdir,', convertdir= ',convertdir,', latexdir= ',latexdir,', dvipsdir= ',dvipsdir,')',sep=''))


#Generates an inner region to search within when choosing tile g12s. From Full simulations of tiling G09 seem to indicate that a 0.4 degree inner skirt as about optimum
testgrid=expand.grid(seq(RAadd+skirt,RAadd+raran-skirt,by=0.1),seq(Decadd+skirt,Decadd+decran-skirt,by=0.1))

#Used to have (TileCat[,'S']>0 & TileCat[,'Q']>2), but I don't think we should have the latter 'Q'>2 since this is time dependent in effect
if(byden | interact){
	tempTilePos=TileCat[TileCat[,'SURVEY_CLASS']>=survey & TileCat[,'POSITION']%in%position,c('RA','DEC')]
	tartestPos={}
	#find possible objects within a 1 deg radius (2dF) on the testgrid generated above- this limits the resolution at which possible field positions can be generated

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

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#First frames for tiling annimations generated here, but only when continue==FALSE, i.e. the first time a new tiling strategy is run
if((continue==FALSE)){
	png(paste(basedir,directory,'/RelCircDen000.png',sep=''),width=600,height=600)
	tempden=MakeCircDen(stopstate,TileCat=TileCat,hirpet=lolim,res=0.05,assignlim=0,bw=bw,denpri=denpri,position=position,basedir=basedir)
	dev.off()
	tempden$z[is.na(tempden$z)]=1
}
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#Various target selections as per Baldry 2010- I use SURVEY_CLASS to define my selection
MSsel=TileCat[,'SURVEY_CLASS']>=survey & TileCat[,'POSITION']%in%position

#The main loop starts here.
if(tileplus>0){
	for(runs in startrun:(startrun+tileplus-1)){
		#Checks for file called 'stop' in main directory.
		if(file.exists(paste(basedir,directory,'/stop',sep=''))){stop('Stop file found. STOPPING!')}
		print(paste('Run',runs,': stopping after',(startrun+tileplus-1)))
		#Generate main smaple completeness
		completeness=1-length(TileCat[MSsel & TileCat[,'CATA_INDEX'] %in% TileSub & TileCat[,'PRIORITY_CLASS']>=denpri,1])/length(TileCat[MSsel,1])
		#Print some useful stuff
		print(paste('Remaining top priority objects:',length(TileCat[MSsel & TileCat[,'PRIORITY_CLASS']>=denpri & TileCat[,'CATA_INDEX'] %in% TileSub,1])))
		print(paste('Survey Total Completeness',completeness))
		
		if(completeness==1){stop('Survey Complete. Go have some tea.')}
		
tempTile=TileCat[TileCat[,'CATA_INDEX'] %in% TileSub & TileCat[,'PRIORITY_CLASS']>=denpri,c('RA','DEC','CATA_INDEX','R_PETRO')]

		#find remaining objects within a 1 deg radius (2dF) on the testgrid generated above- this limits the resolution at which possible field positions can be generate

		sparsedists=try(fields.rdist.near(sph2car(as.matrix(testgrid),deg=T),sph2car(as.matrix(tempTile[,1:2]),deg=T),mean.neighbor=max(ceiling(c(100,length(tempTile[,1])/((raran*decran)/pi)))),delta=pi/180))
		if(class(sparsedists)=='try-error'){
		sparsedists=try(fields.rdist.near(sph2car(as.matrix(testgrid),deg=T),sph2car(as.matrix(tempTile[,1:2]),deg=T),mean.neighbor=2*max(ceiling(c(100,length(tempTile[,1])/((raran*decran)/pi)))),delta=pi/180))
		}
		if(class(sparsedists)=='try-error'){
		sparsedists=try(fields.rdist.near(sph2car(as.matrix(testgrid),deg=T),sph2car(as.matrix(tempTile[,1:2]),deg=T),mean.neighbor=4*max(ceiling(c(100,length(tempTile[,1])/((raran*decran)/pi)))),delta=pi/180))
		}
		
		tartest=rep(0,length(testgrid[,1]))
		sparsedists=table(sparsedists$ind[,1])
		tartest[as.numeric(names(sparsedists))]=as.numeric(sparsedists)

		if(byden){tartestden=tartest/tartestPos}else{tartestden=tartest}
		if(dofailcomp){tartestden=failtestPos/failtest}
		#Here I allow for the possibility that more than one location is at the relative density peak/ target peak. This is almost certainly not an issue with DenGreedy (unlikely) but might be a problem when using Greedy.
		
			if(restrict[runs+1-startrun]=='all'){maxlocs=which(tartestden==max(tartestden))}
			if(restrict[runs+1-startrun]=='lora'){
				maxlocs=which(tartestden==max(tartestden[testgrid[,1]<RAadd+raran/3]))
			}
			if(restrict[runs+1-startrun]=='cen'){
				maxlocs=which(tartestden==max(tartestden[testgrid[,1]>RAadd+raran/3 & testgrid[,1]<RAadd+raran*2/3]))
			}
			if(restrict[runs+1-startrun]=='hira'){
				maxlocs=which(tartestden==max(tartestden[testgrid[,1]>RAadd+raran*2/3]))
			}

			#Calc the positions with the same value as the max, then sample a single position from this randomly. Using the my own function resample to stop undesired sampling when maxlocs is of length 1 (in this case it will sample from 1:maxlocs)
			tileloc=testgrid[resample(maxlocs,1),]

		#Here I define the circular subset of IDs to be sent to makeTile for configuring
		print(paste('The location of the chosen tile: ',tileloc[1],' (RA/deg) ',tileloc[2],' (Dec/deg)'))
		alldistsind=fields.rdist.near(sph2car(as.matrix(tileloc),deg=T),sph2car(as.matrix(TileCat[,c('RA','DEC')]),deg=T),mean.neighbor=length(TileCat[,1]),delta=pi/180)$ind
		useIDs=TileCat[(1:length(TileCat[,1])) %in% alldistsind[,2] & TileCat[,'CATA_INDEX'] %in% TileSub & TileCat[,'CATA_INDEX'] %in% norepvec,'CATA_INDEX']
		#Currently magpri and RA/Decran don't do anything, they are set such that they neither influence the coord cuts or magnitude weighting. Might want to strip makeTile down to a more basic function eventually...
		stamp=paste(paste(position,collapse=''),'_Y',year,'_S',semester,'_R',run,sep='')

		if(justfld==FALSE){
			#This is a modification that stops the location of the tile g12 to become the median of the points within it when completeness is low. This stops main surevy targets being missed in the last steps of the survey
			if(completeness>0.99){medshift=F}else{medshift=T}
			#start running makeTile, which does all of the hard work of actually tiling- see makeTile for details. Briefly, it generates the .fld, configures it, and re-runs if the number of assigned fibres is low using a median shift (unless this has been stopped by the logic above)
			temp=makeTile(tilecens=tileloc,filebase=paste(stamp,'tile',formatC(runs,flag=0,width=3),sep=''), TileCat=TileCat, RAran=cbind(1,1), Decran=cbind(1,1), useIDs=useIDs, TileSub=TileSub, minpri=minpri, basedir=basedir, directory=directory, configdir=configdir, denpri=denpri, manual=manual, plate=plate[runs+1-startrun], date=date[runs+1-startrun],medshift=medshift)
			#Here we find which objects have been assigned
			tileloc=temp$tileCens
			AssignOrder[AssignOrder[,1] %in% temp$dumpID,2]=runs
			TileSub=AssignOrder[AssignOrder[,2]==0,1]
			if(norep){norepvec=norepvec[! norepvec %in% temp$intile];print(length(norepvec));write(temp$intile,file='~/usr/local/bin/Tiler/norepdump',append=TRUE)}
			fibstats=rbind(fibstats,temp$fibstats)
		}else{
			temp=makeFld(tileloc, paste(stamp,'tile',formatC(runs,flag=0,width=3),sep=''), TileCat=TileCat, RAran=cbind(1,1), Decran=cbind(1,1), useIDs=useIDs, TileSub=TileSub, minpri=minpri, basedir=basedir, directory=directory, configdir=configdir, denpri=denpri, manual=manual, plate=plate[runs+1-startrun], date=date[runs+1-startrun])
			#Here we find which objects have been assigned
			tileloc=temp$tileCens
			AssignOrder[AssignOrder[,1] %in% temp$dumpID,2]=runs
			TileSub=AssignOrder[AssignOrder[,2]==0,1]
			fibstats=rbind(fibstats,temp$fibstats)
		}

		#Calculates the 0.1 magnitude bin completeness
		magcompleteness=1-hist(TileCat[TileCat[,'R_PETRO']>15 & TileCat[,'R_PETRO']<24 & TileCat[,'PRIORITY_CLASS']>=denpri & TileCat[,'POSITION']%in%position & TileCat[,'CATA_INDEX'] %in% TileSub,'R_PETRO'],breaks=seq(15, 24,by=0.1),plot=FALSE)$counts/hist(TileCat[MSsel & TileCat[,'R_PETRO']>15 & TileCat[,'R_PETRO']<24,'R_PETRO'],breaks=seq(15, 24,by=0.1),plot=FALSE)$counts
		#Calculates the new total completeness that is printed out to the tilelim object that tracks the progress of the tiling
		completeness=1-length(TileCat[TileCat[,'PRIORITY_CLASS']>=denpri & TileCat[,'POSITION']%in%position & TileCat[,'CATA_INDEX'] %in% TileSub,1])/length(TileCat[MSsel,1])
		#make MagLims in the format needed for MakCircDen
		MagLims=rbind(MagLims,magcompleteness)

		png(paste(basedir,directory,'/RelCircDen',formatC(runs,flag=0,width=3),'.png',sep=''),width=600,height=600)

		#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		tempden=MakeCircDen(data=list(assign=AssignOrder),TileCat=TileCat,hirpet=lolim,res=0.05,assignlim=runs,bw=bw,denpri=denpri,position=position,basedir=basedir)
		dev.off()
		tempden$z[is.na(tempden$z)]=0
		check80=length(which(as.numeric(tempden$z)<=0.2))/length(as.numeric(tempden$z))
		check80g5=length(which(as.numeric(tempden $z[tempden $allz>=5])<=0.2))/length(as.numeric(tempden $z[tempden $allz>=5]))
		#Generate all of the tilelim information for the most recent tile placed and append it to the current tilelim
		tilelim=rbind(tilelim,data.frame(No.=runs, Comp=completeness, RA=as.numeric(tileloc)[1], Dec=as.numeric(tileloc)[2], Left=length(TileCat[TileCat[,'PRIORITY_CLASS']>=denpri & TileCat[,'POSITION']%in%position & TileCat[,'CATA_INDEX'] %in% TileSub,1]), AngComp=check80,AngComp5=check80g5,Plate=plate[runs+1-startrun],Den=byden,Date=date(), Int=interact, Man=manual))
		#Generate stopstate- the object containing all the information about the survey in R form
		stopstate=list(assign=AssignOrder,maglim=MagLims,tilelim=tilelim,current=installed.packages()['Tiler','Version'],loc=loc,args=arguments,catname=catname,fibstats=fibstats)
		#Save stopstate to disk for later recovery
		try(save(stopstate,file=paste(basedir,directory,'stopstate.r',sep='')))
		}
}

stopstate=list(assign=AssignOrder,maglim=MagLims,tilelim=tilelim,current=installed.packages()['Tiler','Version'],loc=loc,args=arguments,catname=catname,fibstats=fibstats)
try(save(stopstate,file=paste(basedir,directory,'stopstate.r',sep='')))

if(report){try(report(directory=directory,TileCat=TileCat,basedir=basedir,latex=TRUE,latexdir=latexdir,dvipsdir=dvipsdir,pdfopen=pdfopen))}

return=stopstate

}
