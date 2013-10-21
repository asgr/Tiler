runCONFIG <-
function(long,lat,id,prior,mags,IPorig,file='test',label='2dF test field',alocate=TRUE,guides=TRUE,sky=TRUE,stanspec=TRUE,tilecens=FALSE,date='auto',basedir='~/Work/R/GAMA/Tiling/',directory='test/', configdir="/Applications/Work/configure-7.9.Darwin/", manual=FALSE, plate=0){
tempsph=cbind(long=long,lat=lat)
N=length(long)

dms=deg2dms(tempsph[,'lat'])
hms=deg2hms(tempsph[,'long'])

if(tilecens[1]==FALSE){
cenRA=median(long)
cenDec=median(lat)
dmsCen=deg2dms(cenDec)
hmsCen=deg2hms(cenRA)
}else{
tilecens=as.numeric(tilecens)
cenRA=tilecens[1]
cenDec=tilecens[2]
dmsCen=deg2dms(cenDec)
hmsCen=deg2hms(cenRA)
}

if(date=='auto'){
year=2009
month=floor(10+as.numeric(hmsCen[,1])/2) %% 12
day=7}else{
if(date=='get'){
temp=unlist(strsplit(as.character(Sys.Date()),split="-"))
year=temp[1]
month=temp[2]
day=temp[3]}else{
temp=unlist(strsplit(as.character(date),split="-"))
year=temp[1]
month=temp[2]
day=temp[3]
}}

idtemp=id
nametargets=id
for(i in 1:length(id)){
	id[i]=paste('G',formatC(idtemp[i],width=6,format='f',flag=0,digits=0),sep='')
nametargets[i]=paste(id[i],'_IP',IPorig[i],'_Y2_',formatC(long[i],width=7,digits=2,flag=0,format='f'),'_',formatC(lat[i],width=5,digits=2,flag=0,format='f'),sep='')
	}
rm(idtemp)

output=cbind(id,hms,dms,rep('P',N),prior,formatC(mags,width=5,digits=2,flag=0,format='f'),rep(0,N),nametargets)

if(guides){
guideid=which((DATAguide[,'RA']-cenRA)^2+(DATAguide[,'DEC']-cenDec)^2<1)
guideidtemp=guideid
for(i in 1:length(guideid)){guideid[i]=paste('F',formatC(guideidtemp[i],width=8,flag=0),sep='')}
rm(guideidtemp)

guides=cbind(DATAguide[(DATAguide[,'RA']-cenRA)^2+(DATAguide[,'DEC']-cenDec)^2<1,c('RA','DEC','PSFMAG_R')])
if(length(guides[,1])>50){samp=sample(1:length(guides[,1]),50);guides=guides[samp,];guideid=guideid[samp]}

output=rbind(output,cbind(guideid,deg2hms(guides[,1]),deg2dms(guides[,2]),rep('F',length(guides[,1])),rep(9,length(guides[,1])),formatC(guides[,3], width=5, digits=2, flag=0, format='f'),rep(0,length(guides[,1])),rep('guide',length(guides[,1]))))}

skylogic=sky
if(sky){
skyid=which((DATAsky[,'RA']-cenRA)^2+(DATAsky[,'DEC']-cenDec)^2<1)
skyidtemp=skyid
for(i in 1:length(skyid)){skyid[i]=paste('X',formatC(skyidtemp[i],width=8,flag=0),sep='')}
rm(skyidtemp)

sky=cbind(DATAsky[(DATAsky[,'RA']-cenRA)^2+(DATAsky[,'DEC']-cenDec)^2<1,c('RA','DEC')])
if(length(sky[,1])>100){samp=sample(1:length(sky[,1]),100);sky=sky[samp,];skyid=skyid[samp]}

output=rbind(output,cbind(skyid,deg2hms(sky[,1]),deg2dms(sky[,2]),rep('S',length(sky[,1])),rep(9,length(sky[,1])),formatC(rep(20,length(sky[,1])),width=5,digits=2,flag=0,format='f'),rep(0,length(sky[,1])),rep('sky',length(sky[,1]))))
}

if(stanspec){
stspecid=which((DATAstspec[,'RA']-cenRA)^2+(DATAstspec[,'DEC']-cenDec)^2<0.9)
stspecidtemp=stspecid
for(i in 1:length(stspecid)){stspecid[i]=paste('S',formatC(stspecidtemp[i],width=8,flag=0),sep='')}
rm(stspecidtemp)

stspec=cbind(DATAstspec[(DATAstspec[,'RA']-cenRA)^2+(DATAstspec[,'DEC']-cenDec)^2<0.9,c('RA','DEC','PSFMAG_R','PRIORITY_FLAG')])
if(length(stspec[,1])>3){
	tempsel=which(stspec[,'PRIORITY_FLAG']==7)
	if(length(tempsel)<3){tempsel=c(tempsel,which(stspec[,'PRIORITY_FLAG']<7))}
	samp=resample(tempsel,3)
	stspec= stspec[samp,1:3]
	stspecid=stspecid[samp]
	}

output=rbind(output,cbind(stspecid,deg2hms(stspec[,1]),deg2dms(stspec[,2]),rep('P',length(stspec[,1])),rep(9,length(stspec[,1])),formatC(stspec[,3] ,width=5, digits=2,flag=0,format='f'),rep(0,length(stspec[,1])),rep('stspec',length(stspec[,1]))))}

write(paste("*\nLABEL ",label,'P',plate,"\nUTDATE ",year,month,day,"\nCENTRE ",hmsCen[,1],hmsCen[,2],hmsCen[,3],dmsCen[,1],dmsCen[,2],dmsCen[,3],"\nEQUINOX J2000.0\n* End of header info\n*\n"), file=paste(basedir,directory,file,'P',plate,'.fld',sep=''))
write.table(output,file=paste(basedir,directory,file,'P',plate,'.fld',sep=''),append=TRUE,sep=' ',row.names=FALSE,col.names=FALSE,quote=FALSE)
if(alocate){
	if(manual==FALSE & skylogic){
    print(paste(configdir,'configure -a -f ',basedir,directory,file,'P',plate,'.fld -s -sky 25 -p ',plate,' -I \'2dF-AAOmega\'',sep=''))
    system(paste(configdir,'configure -a -f ',basedir,directory,file,'P',plate,'.fld -s -sky 25 -p ',plate,' -I \'2dF-AAOmega\'',sep=''))}
	if(manual==FALSE & skylogic==FALSE){system(paste(configdir,'configure -a -f ',basedir,directory,file,'P',plate,'.fld -s -sky 0 -p ',plate,' -I \'2dF-AAOmega\'',sep=''))}
	if(manual==TRUE){
    system(paste(configdir,'configure -f ',basedir,directory,file,'P',plate,'.fld -p ',plate,' -I \'2dF-AAOmega\' &',sep=''))
		print(paste('When ',file,'P',plate,'.sds and ',file,'P',plate,'.lis files have been saved inside the main directory for the run (should be the default one) type 99. If quitting, type 666.',sep=''))
		checklis=FALSE
		checksds=FALSE
		while((checklis & checksds) == FALSE){
			done=scan()
			if(length(done)>0){
			if(done[1]==666){stop()}
			if(done[1]==99){
				checklis=file.exists(paste(basedir,directory,file,'P',plate,'.lis',sep=''))
				checksds=file.exists(paste(basedir,directory,file,'P',plate,'.sds',sep=''))
				
				if(checklis==FALSE){print(paste(file,'P',plate,'.lis file has not been saved correctly, try again',sep=''))}
				if(checksds==FALSE){print(paste(file,'P',plate,'.sds file has not been saved correctly, try again',sep=''))}
				if(checklis==FALSE | checksds==FALSE){print('When file(s) saved, type 99. If quitting type 666')}
				}else{print('Incorrect entry, type 99. If quitting type 666')}
				}else{print('Incorrect entry, type 99. If quitting type 666')}
			}
		}
	}
}
