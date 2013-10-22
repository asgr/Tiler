Instructions for Tiling software

Author:  Aaron Robotham

The catalogues should be ascii and not have a leading # on the first line, i.e. look like this:

objects:

CATA_INDEX  RA DEC R_PETRO SURVEY_CLASS PRIORITY_CLASS POSITION
9091700001      355.3979797000000076      -29.2363433999999991      14.4033909       8       8 APMCC0917
9091700002      355.3943481000000020      -29.2308425999999990      17.5741386       9       9 APMCC0917
9091700003      355.4186707000000069      -29.2293529999999997      18.9740582       9       9 APMCC0917
9091700004      355.4155579000000102      -29.2223377000000006      17.5855961       8       8 APMCC0917

guides:

ROWID RA DEC PSFMAG_R
999091700096     355.4356384000000162     -29.4283104000000009     14.2486877
999091700111     355.5883789000000093     -29.1087893999999991     14.0694313
999091700138     355.3394470000000069     -29.4658717999999986     14.0480652
999091700249     355.1301879999999755     -29.4512806000000005     14.4285583

skies:

RA DEC
355.7595942504526079     -29.2249855203739273
355.1304749543483013     -29.0560654028099279
355.3812874230538341     -29.2724326202835385
355.6078842508777598     -29.4760053266580115

spec:

ROWID RA DEC  PSFMAG_R PRIORITY_FLAG
999091700001     355.3940734999999904     -29.2190398999999985     16.3626366      7
999091700016     355.4709472999999775     -29.2705249999999992     17.1006565      7
999091700022     355.4739989999999921     -29.2830486000000008     15.6917324      7
999091700082     355.5869141000000013     -29.1524104999999984     16.0948925      7

Once catalogues are in place you can start tiling. You might need to actually get R on your machine- google 'R project' and you'll find it easily enough. Once you have installed R and got the latest version of the Tiling software, you now need to get all the packages installed.

cd to where the Tiler_?.?tar.gz is, and install the tiling software on the terminal with:

> R CMD install Tiler_?.?.tar.gz, where the ?.? should be replaced with the version number (e.g. 1.1)

start R with:

> R

You are now inside R. You also need to install: sphereplot, rgl, celestial, plotrix, fields. For each one you run:

> install.packages('sphereplot',type='source')
> install.packages('rgl',type='source')
> install.packages('celestial',type='source')
> install.packages('plotrix',type='source')
> install.packages('fields',type='source')
> install.packages('xtable',type='source')

To update the catalogues within R type (something like, it obviously depends on the actual names!):

TCsamiclusY1=read.table('AAOmega_cluster_targets_Sep10.txt',header=T)   #Can give this a different LHS name if it is passed to the function
DATAguide=read.table('AAOmega_guides_Sep10.txt',header=T)			#Must be called DATAguide
DATAstspec=read.table('AAOmega_fstars_Sep10.txt',header=T)		#Must be called DATAstspec
DATAsky=read.table('AAOmega_skies_Sep10.txt',header=T)				#Must be called DATAsky

You can save this with

> save.image('samiTiler-1.?.img')

The above read in commands are in the RUNMEtile.rscript and RUNMErebuild.rscript scripts inside the Tiler_?.?.tar.gz tarball.

To run the tiling code for e.g. an individual cluster (rather than the RUNMEtile.rscript script) use:

> Tiler(tileplus=5, position='A3880', plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=T, basedir='.', configdir='/instsoft/2dF/misc_software/configure-7.10+.Linux')

tileplus	Tiles to make
position	Cluster name (can be a combination of clusters, see below)
plate		Vector the same length as tileplus value. This will assign the given plate number to each tile
runfolder	Puts the new file in its own TargetFork subdirectory
TileCat		Name of the tiling catalogue to use (within R)
runoffset	Amount to offset the tiling number by- useful if you remake the catalogue and want to jump ahead to the current tile number
updatefib	Should the fibres be updated internally (usually best to keep this set to TRUE)
basedir		Base directory to use for the folder structure, default is '.', i.e. where you are currently
confider	Path to the 'configure' code. Example here is setup for the AATLXA machine (which has R and configure installed).

To run multiple positions at once (useful if target clusters overlap etc) use:

> Tiler(tileplus=5, position=c('a4038','APMCC0917'), plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=T, basedir='.', configdir='/instsoft/2dF/misc_software/configure-7.10+.Linux')

During the run, if you want to feedback observed objects, just remake the objects ascii table and load it back in. You can give it a different name, but then the 'TileCat' argument will need updating in the Tiler code.

So to make a whole run this is probably what you want to run:

> Tiler(tileplus=5, position='A119', plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=T, basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> Tiler(tileplus=5, position='A168', plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=F, basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> Tiler(tileplus=5, position='A2399', plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=F, basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> Tiler(tileplus=5, position='A3880', plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=F, basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> Tiler(tileplus=5, position=c('a4038','APMCC0917'), plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=F, basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> Tiler(tileplus=5, position='A85', plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=T, basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> Tiler(tileplus=5, position='EDCC0442', plate=c(0,1,0,1,0), runfolder=TRUE, TileCat=TCsamiclusY1, runoffset=1, updatefib=T, basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')

I've made a file called RUNMEtile.rscript which you can run as an executable, it is inside the Tiler_?.?.tar.gz tarball.

To update the survey you copy the observed .lis files into the 'Observed' directory for the appropriate cluster, then you can run:

> rebuildState(TileCat=TCsamiclusY1,position='A119',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='A168',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='A2399',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='A3880',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position=c('a4038','APMCC0917'),basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='A85',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='EDCC0442',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')

These commands are in RUNMErebuild.rscript which you can run as an executable, it is inside the Tiler_?.?.tar.gz tarball.

Once all of the cluster regions have been rebuilt you can re-run RUNMEtile.rscript (or the individual commands above). This works because the updated state of the survey is stored in a file called 'stopstate.r' that you'll find in the 'Observed' folder.

That should be enough to get you going, email me at aaron.robotham@uwa.edu.au if you're stuck.
