Instructions for Tiling software

Author:  Aaron Robotham

Create a directory specific for your current tiling survey (i.e. I usually make a folder for each GAMA run). This folder should contain the files that will vary for each survey. The catalogues should be ascii and not have a leading # on the first line, i.e. look like this (all columns must be included and the names must be exactly as shown):

objects:

CATA_INDEX  RA DEC R_PETRO SURVEY_CLASS PRIORITY_CLASS POSITION
9091700001      355.3979797000000076      -29.2363433999999991      14.4033909       6       8 APMCC0917
9091700002      355.3943481000000020      -29.2308425999999990      17.5741386       6       9 APMCC0917
9091700003      355.4186707000000069      -29.2293529999999997      18.9740582       6       9 APMCC0917
9091700004      355.4155579000000102      -29.2223377000000006      17.5855961       6       8 APMCC0917

CATA_INDEX	Object ID
RA		Right ascension
DEC		Declination
R_PETRO		r-band petro mag
SURVEY_CLASS	This specifies whether the object is main survey (above or equal to MainSclass)
PRIORITY_CLASS 	Indicates the importance of each target between 1 (low) and 9 (high)
POSITION	The survey region code for the object

guides:

ROWID RA DEC PSFMAG_R
999091700096     355.4356384000000162     -29.4283104000000009     14.2486877
999091700111     355.5883789000000093     -29.1087893999999991     14.0694313
999091700138     355.3394470000000069     -29.4658717999999986     14.0480652
999091700249     355.1301879999999755     -29.4512806000000005     14.4285583

ROWID		Object ID
RA		Right ascension
DEC		Declination
PSFMAG_R	r-band PSF mag (can be filled with place-holder values)

skies:

RA DEC
355.7595942504526079     -29.2249855203739273
355.1304749543483013     -29.0560654028099279
355.3812874230538341     -29.2724326202835385
355.6078842508777598     -29.4760053266580115

RA		Right ascension
DEC		Declination

spec:

ROWID RA DEC  PSFMAG_R PRIORITY_FLAG
999091700001     355.3940734999999904     -29.2190398999999985     16.3626366      7
999091700016     355.4709472999999775     -29.2705249999999992     17.1006565      7
999091700022     355.4739989999999921     -29.2830486000000008     15.6917324      7
999091700082     355.5869141000000013     -29.1524104999999984     16.0948925      7

ROWID		Object ID
RA		Right ascension
DEC		Declination
PSFMAG_R	r-band PSF mag (can be filled with place-holder values)
PRIORITY_FLAG 	Indicates the importance of each target between 1 (low) and 9 (high)

You also need a file containing information on your survey regions called 'SurveyInfo.txt', this should contain the following columns:

Region	RAmin	RArange DECmin	DECrange	Skirt	Year	Sem	    Run	    Loc	    Denpri	MainSclass	LoPclass	ByDen
G02	    30.2	8.6	    -6.3	2.5		    0.4	    7	    B	    10	    GAMA02	8	    3	        1		    TRUE 
G09	    129	    12	    -2	    5		    0	    7	    A	    20	    GAMA09	8	    3	        1		    FALSE
G12	    174	    12	    -3	    5		    0	    7	    A	    1	    GAMA12	8	    3	        1		    FALSE
G15	    211.5	12	    -2	    5		    0.4	    7	    A	    40	    GAMA15	8	    3	        1		    TRUE
G23	    339	    12	    -35	    5		    0.4	    7	    A	    30	    GAMA23	8	    3	        1		    TRUE

Region		The survey region code
RAmin		Minimum RA of the region
RArange		RA range of the region (high-low)
DECmin		Minimum declination of the region
DECrange	Declination range of the region (high-low)
Skirt		How close tiles can get to the edge: 0.4 is good in general, but should be 0 when survey has almost finished
Year		Survey year
Sem		Survey Semester
Run		The observing run number for the current semester.
Loc		Name to use for survey region code
Denpri		Minimum value for PRIORITY_CLASS that will be used to find the best tile position
MainSclass	Minimum SURVEY_CLASS that defines the main survey- used to calculate the completeness properly
LoPclass	Minimum PRIORITY_CLASS that will be sent to tiling
ByDen		If TRUE density priority (lowest completeness first) is used to place tiles, if FALSE greedy priority (most targets left) is used to place tiles

#Tiler package v1.1 updated G23 area

Once the catalogues and SurveyInfo.txt files are in place you can start tiling. You might need to actually get R on your machine- google 'R project' and you'll find it easily enough. Once you have installed R and got the latest version of the Tiling software, you now need to get all the packages installed.

cd to where the Tiler_?.?tar.gz is, and install the tiling software on the terminal with:

> R CMD install Tiler_?.?.tar.gz, where the ?.? should be replaced with the version number (e.g. it is currently 1.2)

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

The above read in commands are in the RUNMEtile.rscript and RUNMErebuild.rscript scripts inside the Tiler_?.?.tar.gz tarball. These scripts can be copied to the directory containing your catalogues and edited as appropriate for your data.

As an example, to run the tiling code for an individual POSITION (rather than the RUNMEtile.rscript script) you can use something that looks similar to:

> Tiler(tileplus=5, position='A3880', plate=c(0,1,0,1,0), runfolder=TRUE, restrict='all', TileCat=TCsamiclusY1, runoffset=1, updatefib=T, basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')

tileplus	Tiles to make
position	Position name (can be a combination of positions, see below)
plate		Vector the same length as tileplus value. This will assign the given plate number to each tile
runfolder	Puts the new file in its own TargetFork subdirectory
restrict	Determines whether the field should be placed anywhere in the region ('all'), in the bottom 1/3 of the RA range ('lora'), mid RA 1/3 ('mid') or high RA 1/3 ('hira'), you can either specify one argument for all or a vector of length tile plus for different restrictions plate by plate
TileCat		Name of the tiling catalogue to use (within R)
runoffset	Amount to offset the tiling number by- useful if you remake the catalogue and want to jump ahead to the current tile number
updatefib	Should the fibres be updated internally (usually best to keep this set to TRUE)
basedir		Base directory to use for the folder structure, default is '.', i.e. where you are currently
confidir	Path to the 'configure' code. Example here is setup for the AATLXA machine (which has R and configure installed).

To run multiple positions at once (useful if target positions - e.g. clusters - overlap etc) use:

> Tiler(tileplus=6, position='G02', plate=c(0,1,0,1,0,1), runfolder=TRUE, TileCat=TC, runoffset=1,restrict=c('lora',,'all','all','all','all','hira') updatefib=! exists('Fibres'), basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')

During the run, if you want to feedback observed objects, just remake the objects ascii table and load it back in. You can give it a different name, but then the 'TileCat' argument will need updating in the Tiler code.

You can make a batch for a whole observing run by executing a script like this:

Tiler(tileplus=6, position='G02', plate=c(0,1,0,1,0,1), runfolder=TRUE, TileCat=TC, runoffset=1,restrict=c('lora','all','all','all','all','hira'), updatefib=! exists('Fibres'), basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
Tiler(tileplus=6, position='G09', plate=c(0,1,0,1,0,1), runfolder=TRUE, TileCat=TC, runoffset=1,restrict=c('lora','all','all','all','all','hira'), updatefib=! exists('Fibres'), basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
Tiler(tileplus=6, position='G12', plate=c(0,1,0,1,0,1), runfolder=TRUE, TileCat=TC, runoffset=1,restrict=c('lora','all','all','all','all','hira'), updatefib=! exists('Fibres'), basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
Tiler(tileplus=6, position='G15', plate=c(0,1,0,1,0,1), runfolder=TRUE, TileCat=TC, runoffset=1,restrict=c('lora','all','all','all','all','hira'), updatefib=! exists('Fibres'), basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
Tiler(tileplus=6, position='G23', plate=c(0,1,0,1,0,1), runfolder=TRUE, TileCat=TC, runoffset=1,restrict=c('lora','all','all','all','all','hira'), updatefib=! exists('Fibres'), basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')

There's a file called RUNMEtile.rscript which you can run as an executable, it is inside the Tiler_?.?.tar.gz tarball. This is an example of how you might want to script up the tiling process.

To update the survey you copy the observed .lis files into the 'Observed' directory for the appropriate POSITION folder, then you can run:

> rebuildState(TileCat=TCsamiclusY1,position='A119',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='A168',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='A2399',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='A3880',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position=c('a4038','APMCC0917'),basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='A85',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')
> rebuildState(TileCat=TCsamiclusY1,position='EDCC0442',basedir='.', configdir='/Applications/Work/configure-8.0.Darwin')

These commands are in RUNMErebuild.rscript which you can run as an executable, it is inside the Tiler_?.?.tar.gz tarball.

Once all of the POSITION regions have been rebuilt you can re-run RUNMEtile.rscript (or the individual commands above). This works because the updated state of the survey is stored in a file called 'stopstate.r' that you'll find in the 'Observed' folder.

That should be enough to get you going, email me at aaron.robotham@uwa.edu.au if you're stuck.
