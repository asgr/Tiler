makeFld <-
function (TileCat = TileV4c, tilecens, filebase = "test", RAran = cbind(sqrt(3)/2, 
    sqrt(3)/2), Decran = cbind(0.5, 0.5), useIDs = "all", magpri = FALSE, 
    maglim = 0.1, TileSub = TileSub, minpri = 2, denpri = 8, 
    plate = 0, basedir = "~/Work/R/GAMA/Tiling/", directory = "eastMaGreedy", 
    configdir = "/Applications/Work/configure-7.9.Darwin/", manual = FALSE, 
    date = "auto", medshift = TRUE) 
{
    data(PriConvMat,package='Tiler')
    if (useIDs[1] == "all") {
        tempTilecat = TileCat[, c("RA", "DEC", "CATA_INDEX", 
            "PRIORITY_CLASS", "R_PETRO")]
    }
    else {
        tempTilecat = TileCat[TileCat[, "CATA_INDEX"] %in% useIDs, 
            c("RA", "DEC", "CATA_INDEX", "PRIORITY_CLASS", "R_PETRO")]
    }
    if (length(RAran[, 1]) == 1) {
        RAran = cbind(rep(RAran[, 1], length(tilecens[, 1])), 
            rep(RAran[, 2], length(tilecens[, 1])))
    }
    if (length(Decran[, 1]) == 1) {
        Decran = cbind(rep(Decran[, 1], length(tilecens[, 1])), 
            rep(Decran[, 2], length(tilecens[, 1])))
    }
    i = 1
    if (useIDs[1] == "all") {
        subset = tempTilecat[tempTilecat[, 1] > tilecens[i, 1] - 
            RAran[i, 1] & tempTilecat[, 1] < tilecens[i, 1] + 
            RAran[i, 2] & tempTilecat[, 2] > tilecens[i, 2] - 
            Decran[i, 1] & tempTilecat[, 2] < tilecens[i, 2] + 
            Decran[i, 2] & tempTilecat[, 4] >= denpri, ]
    }
    else {
        subset = tempTilecat
    }
    pritemp = vector("integer", length = length(subset[, 4]))
    for (count in 1:10) {
        pritemp[subset[, 4] == PriConvMat[count, 1]] = PriConvMat[count, 
            2]
    }
    IPorig = subset[, 4]
    subset[, 4] = pritemp
    tempSplits = PriSplits(TileSub = TileSub, TileCat = TileCat, 
        useIDs = useIDs, denpri = denpri)
    colliders = tempSplits$bump[, 1]
    useIDs = useIDs[!useIDs %in% tempSplits$collide]
    filename = paste(filebase, "-", round(tilecens[i, 1], 2), 
        "-", round(tilecens[i, 2], 2), sep = "")
    print(paste("Filename for next configuring: ", filename, 
        ".fld", sep = ""))
    subset[subset[, 3] %in% colliders, 4] = subset[subset[, 3] %in% 
        colliders, 4] + 1
    confIDs = {
    }
    trypri = max(subset[, 4])
    while (length(confIDs) < 600 & trypri >= PriConvMat[PriConvMat[, 
        1] == minpri, 2]) {
        confIDs = c(confIDs, resample(which(subset[, 4] == trypri), 
            min(c(600 - length(confIDs), length(which(subset[, 
                4] == trypri))))))
        if (trypri <= PriConvMat[PriConvMat[, 1] == minpri, 2] | 
            length(subset[subset[, 4] < trypri, 4]) == 0) {
            break
        }
        trypri = max(subset[subset[, 4] < trypri, 4], na.rm = TRUE)
    }
    subset = subset[confIDs, ]
    IPorig = IPorig[confIDs]
    print(paste("Total Objects sent to configure: ", length(subset[, 
        1]), sep = ""))
    if (magpri == FALSE) {
    }
    else {
        subset[subset[, 5] > magpri & subset[, 5] < magpri + 
            maglim, 4] = subset[subset[, 5] > magpri & subset[, 
            5] < magpri + maglim, 4] + 1
        print(summary(subset[, 5]))
        print(summary(subset[, 4]))
    }
    runCONFIG(long = subset[, 1], lat = subset[, 2], id = subset[, 
        3], prior = subset[, 4], mags = subset[, 5], IPorig = IPorig, 
        file = filename, label = filename, tilecens = tilecens[i, 
            ], basedir = basedir, directory = directory, configdir = configdir, 
        manual = manual, plate = plate, date = date, alocate = FALSE)
    return = list(keepID = useIDs[!useIDs %in% subset[, 3]], 
        dumpID = subset[, 3], tileCens = tilecens, fibstats = {
        })
}
