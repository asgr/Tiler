makeTile <-
function(TileCat=TileV5, tilecens, filebase='test', RAran=cbind(sqrt(3)/2,sqrt(3)/2), Decran=cbind(0.5,0.5), useIDs='all', magpri=FALSE, maglim=0.1, TileSub=TileSub,  minpri=2, denpri=8, plate=0, basedir='~/usr/local/bin/Tiler/', directory='eastMaGreedy', configdir="/Applications/configure-7.9.Darwin/",manual=FALSE,date='auto',medshift=TRUE){
  data(PriConvMat,package='Tiler')
  
if(useIDs[1]=='all'){tempTilecat=TileCat[,c('RA','DEC','CATA_INDEX','PRIORITY_CLASS','R_PETRO')]}else{
	tempTilecat=TileCat[TileCat[,'CATA_INDEX'] %in% useIDs,c('RA','DEC','CATA_INDEX','PRIORITY_CLASS','R_PETRO')]
	}
if(length(RAran[,1])==1){RAran=cbind(rep(RAran[,1],length(tilecens[,1])),rep(RAran[,2],length(tilecens[,1])))}
if(length(Decran[,1])==1){Decran=cbind(rep(Decran[,1],length(tilecens[,1])),rep(Decran[,2],length(tilecens[,1])))}
#print(length(which(tempTilecat[,4]==9)))

i=1

if(useIDs[1]=='all'){subset=tempTilecat[tempTilecat[,1]>tilecens[i,1]-RAran[i,1] & tempTilecat[,1]<tilecens[i,1]+RAran[i,2] & tempTilecat[,2]>tilecens[i,2]-Decran[i,1] & tempTilecat[,2]<tilecens[i,2]+Decran[i,2] & tempTilecat[,4]>=denpri,]}else{
	subset=tempTilecat
	}
pritemp=vector('integer',length=length(subset[,4]))
for(count in 1:10){
pritemp[subset[,4]==PriConvMat[count,1]]=PriConvMat[count,2]
}
IPorig=subset[,4]
subset[,4]=pritemp
#print(summary(subset))
#New code works out the collider matrix after each set of allocations
tempSplits=PriSplits(TileSub=TileSub, TileCat=TileCat, useIDs=useIDs, denpri=denpri)
colliders=tempSplits$bump[,1]
useIDs=useIDs[!useIDs %in% tempSplits$collide]
filename=paste(filebase,'-',round(tilecens[i,1],2),'-',round(tilecens[i,2],2),sep='')
print(paste('Filename for next configuring: ',filename,'.fld',sep=''))
subset[subset[,3] %in% colliders,4]=subset[subset[,3] %in% colliders,4]+1

#Here I load the field up with lower priority objects, careful to only add the highest available each time.
confIDs={}
trypri=max(subset[,4])
while(length(confIDs)<600 & trypri>=PriConvMat[PriConvMat[,1]==minpri,2]){
	confIDs=c(confIDs,resample(which(subset[,4]==trypri),min(c(600-length(confIDs),length(which(subset[,4]==trypri))))))
	if(trypri<=PriConvMat[PriConvMat[,1]==minpri,2] | length(subset[subset[,4]<trypri,4])==0){break}
	trypri=max(subset[subset[,4]<trypri,4],na.rm=TRUE)
	}
subset=subset[confIDs,]
IPorig=IPorig[confIDs]

print(paste('Total Objects sent to configure: ',length(subset[,1]),sep=''))
#The following bit adds a further level of priority to each observation within magpri of the brightest galaxy in the field. Magpri isn't used in the current implemenation, so ignore
if(magpri==FALSE){}else{subset[subset[,5]>magpri & subset[,5]<magpri+maglim,4]=subset[subset[,5]>magpri & subset[,5]<magpri+maglim,4]+1;print(summary(subset[,5]));print(summary(subset[,4]))}

tarIDs={}
#I'll be honest, I'm not entirely sure why this is in a while statement. I think it's to stop stupid stuff happening when down to only one target- i.e. it not being targeted. In practice this never came up when observing GAMA I, but it's not impossible
while(length(tarIDs)==0){
#This runs runCONFIG, which actually invokes the configure software
runCONFIG(long=subset[,1],lat=subset[,2],id=subset[,3],prior=subset[,4],mags=subset[,5],IPorig=IPorig,file=filename,label=filename,tilecens=tilecens[i,],basedir=basedir,directory=directory, configdir=configdir, manual=manual, plate=plate, date=date)
#This reads out the .lis file, which contains all the required allocation information
templist=readLines(paste(basedir,directory,filename,'P',plate,'.lis',sep=''))
#This strips out the targeted GAMA object lines in the .lis file
tarIDs=grep('\\*.*G.*G.*',templist)
}
#Here I grab all of the other useful info about the configuration
guideIDs=grep('\\*.*guide',templist)
skyIDs=grep('\\*.*sky',templist)
specIDs=grep('\\*.*stspec',templist)
ParkIDs=grep('\\*.*Parked',templist)
startFibs=grep('\\*Fibre',templist)
dumpIDs={}

for(i2 in 1:length(tarIDs)){	
#A bit rough to read, but this uses the strsplit to find which object IDs were targeted. The unlist is necessary because strsplit by default produces lists because you can pass it a vector of strings to split and each might have multiple products. I could have done this in one line rather than looping, but that would have made it even harder to read!
dumpIDs=c(dumpIDs,as.numeric(unlist(strsplit(unlist(strsplit(templist[tarIDs[i2]]," +"))[3],'G'))[2]))}

FibVec=rep(0,400)
FibVec[c(Fibres[[plate+1]]$brokenMain,Fibres[[plate+1]]$brokenGuide)]=99
FibVec[tarIDs-startFibs]=1
FibVec[guideIDs-startFibs]=2
FibVec[skyIDs-startFibs]=3
FibVec[specIDs-startFibs]=4
#prints useful stuff to the screen. I've used cat instead of print here. Either is fine, but cat doesn't print out [1] on the LHS, so people generally prefer it.
cat(paste('Fibre info for plate ',plate,sep=''))
cat(paste('\nMain working\t\t',length(Fibres[[plate+1]]$workingMain),sep=''))
cat(paste('\nMain Broken\t\t\t',length(Fibres[[plate+1]]$brokenMain),sep=''))
cat(paste('\nUsed for survey\t\t',length(which(FibVec==1)),sep=''))
cat(paste('\nUsed for sky\t\t',length(which(FibVec==3)),sep=''))
cat(paste('\nUsed for guide\t\t',length(which(FibVec==2)),sep=''))
cat(paste('\nUsed for spectra\t',length(which(FibVec==4)),sep=''))
cat(paste('\nUnused working\t\t',length(which(FibVec==0)),'\n',sep=''))

#Here we redo the configure if it wasn't good enough first time
if(length(which(FibVec==0))>5 & length(subset[,1]>550) & manual==FALSE & medshift==TRUE){
	tilecens=cbind(round(median(subset[,1]),2),round(median(subset[,2]),2))
	print(paste('BAD FIELD. Shifting tile centre to',tilecens[i,1],'RA/deg',tilecens[i,2],'Dec/deg and reconfiguring.'))
	runCONFIG(long=subset[,1],lat=subset[,2],id=subset[,3],prior=subset[,4],mags=subset[,5],IPorig=IPorig,file=filename,tilecens=tilecens[i,],basedir=basedir,directory=directory, configdir=configdir, manual=manual, plate=plate, date=date)
templist=readLines(paste(basedir,directory,filename,'P',plate,'.lis',sep=''))
tarIDs=grep('\\*.*G.*G.*',templist)
guideIDs=grep('\\*.*guide',templist)
skyIDs=grep('\\*.*sky',templist)
specIDs=grep('\\*.*stspec',templist)
ParkIDs=grep('\\*.*Parked',templist)
startFibs=grep('\\*Fibre',templist)
dumpIDs={}

#This is all the same again, but for a second attempt if the first wasn't good enough. I only do this twice, so it didn't seem worthwhile looping it

for(i2 in 1:length(tarIDs)){	
dumpIDs=c(dumpIDs,as.numeric(unlist(strsplit(unlist(strsplit(templist[tarIDs[i2]]," +"))[3],'G'))[2]))}

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
	}

#if(length(Fibres[[plate+1]]$workingMain)-length(dumpIDs)+length(skyIDs)<25 & manual==FALSE){dumpIDs=dumpIDs[-sample(which(dumpIDs %in% subset[subset[,4]>=min(subset[subset[,3] %in% dumpIDs,4]),3]),25-(length(Fibres[[plate+1]]$workingMain)-length(dumpIDs))+length(skyIDs))]}

tiletext=(unlist(strsplit(templist[grep('CENTRE',templist)]," +")))
if(length(grep('\\+',tiletext[5]))==1){decsign=1}
if(length(grep('\\-',tiletext[5]))==1){decsign=-1}

tilecens=cbind(hms2deg(as.numeric(tiletext[2]),as.numeric(tiletext[3]),as.numeric(tiletext[4])),dms2deg(abs(as.numeric(tiletext[5])),as.numeric(tiletext[6]),as.numeric(tiletext[7]),decsign))

print(paste('Final used tile centre:',tilecens[1,1],'(RA/deg)',tilecens[1,2],'(Dec/deg)'))

tempTilecat=tempTilecat[(tempTilecat[,3] %in% dumpIDs)==FALSE,]
#Finally, after a successful configuration, we return all the information required in the higher level Tiler program
return=list(keepID=tempTilecat[,3],dumpID=dumpIDs,tileCens=tilecens,fibstats=FibVec,intile=subset[,3])
}
