MakeCircDen <-
function(data='find',directory='test',TileCat=TileV4f,lorpet=14,hirpet=22,bw=sqrt(2)/10,res=0.05,assignlim=0,plot=TRUE, save=FALSE,type='png',denpri=8,basedir='~/Work/R/GAMA/Tiling',position='g02'){
#WARNING, bw here means the diameter of the circle used for convolusion, this is to stay consistent with the definition in other packages
if(any(colnames(TileCat)=='CATAID')){colnames(TileCat)[colnames(TileCat)=='CATAID']='CATA_INDEX'}
options(stringsAsFactors=FALSE)
options(scipen=999)
if(is.character(data)){if(data=='find'){
	load(paste(basedir,'/',directory,'/stopstate.r',sep=''))
	data=stopstate
	}}
RAreg={}
DECreg={}

info=read.table(paste(basedir,'/SurveyInfo.txt',sep=''),header=T)

RAadd=info[info[,'Region']== position,'RAmin']
Decadd=info[info[,'Region']== position,'DECmin']
raran=info[info[,'Region']== position,'RArange']
decran=info[info[,'Region']== position,'DECrange']
loc=info[info[,'Region']== position,'Loc']
skirt=info[info[,'Region']== position,'Skirt']
year=info[info[,'Region']== position,'Year']
semester=info[info[,'Region']== position,'Sem']
run=info[info[,'Region']== position,'Run']
denpri=info[info[,'Region']== position,'Denpri']
minpri=info[info[,'Region']== position,'LoPclass']
survey=info[info[,'Region']== position,'MainSclass']
byden=info[info[,'Region']== position,'ByDen']
magbin=5
lolim=22



if(save & plot){
	if(type=='png'){png(paste(basedir,'/',directory,'/DenMap',assignlim,'.png',sep=''),width=800,height=480)}
	if(type=='eps'){
	setEPS()
	postscript(paste(basedir,'/',directory,'/DenMap',assignlim,'.eps',sep=''),width=800/72,height=480/72)}
	if(type=='pdf'){pdf(paste(basedir,'/',directory,'/DenMap',assignlim,'.pdf',sep=''),width=800/72,height=480/72,onefile=TRUE)}
	}

tempAll=TileCat[TileCat[,'MAG']>lorpet & TileCat[,'MAG']<hirpet & TileCat[,'SURVEY_CLASS']>=survey & TileCat[,'POSITION']%in%position,c('RA','DEC')]

tempObs=TileCat[TileCat[,'MAG']>lorpet & TileCat[,'MAG']<hirpet & TileCat[,'POSITION']%in%position & ((TileCat[,'CATA_INDEX'] %in% data$assign[data$assign[,2]>0 & data$assign[,2]<=assignlim,1] & TileCat[,'PRIORITY_CLASS']>=denpri) | (TileCat[,'SURVEY_CLASS']>=survey & TileCat[,'PRIORITY_CLASS']<denpri)),c('RA','DEC')]

RAreg=c(RAadd,RAadd+raran)
DECreg=c(Decadd,Decadd+decran)

if(dim(tempObs)[1]>0){
hatAll=CircHat(tempAll[,1],tempAll[,2],gridres=c(res,res),h=bw/2,lims=c(RAreg[1],RAreg[2],DECreg[1],DECreg[2]))
hatObs=CircHat(tempObs[,1],tempObs[,2],gridres=c(res,res),h=bw/2,lims=c(RAreg[1],RAreg[2],DECreg[1],DECreg[2]))
}else{
hatAll=CircHat(tempAll[,1],tempAll[,2],gridres=c(res,res),h=bw/2,lims=c(RAreg[1],RAreg[2],DECreg[1],DECreg[2]))
hatObs=hatAll
hatObs$z=hatObs$z-hatObs$z
}



if(plot){
par(mar=c(5.1,4.1,4.1,2.1))
image(x=hatAll$x,y=hatAll$y,z=1-hatObs$z/hatAll$z,zlim=c(0,1),col=c(grey(0:19/19),rainbow(80,start=0,end=2/3)),xlab='RA/deg',ylab='Dec/deg',main=paste(loc,'Obs/Tar Contrast for\nR Petro',lorpet,'to',hirpet,'After',assignlim,'Tiles'),asp=1/cos((pi/180)*(DECreg[2]+DECreg[1])/2))
}

if(plot & save){dev.off()}

z=1-hatObs$z/hatAll$z
z[is.na(z)]=0
return=list(x=hatAll$x,y=hatAll$y,z=z,obz=hatObs$z,allz=hatAll$z)

}
