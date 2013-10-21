MakeTilePlot <-
function (data = "find", directory = "test", TileCat = TileV4f, 
    sub = "all", save = FALSE, type = "png", left = TRUE, skirt = 0.4, 
    basedir = "~/Work/R/GAMA/Tiling", position = "g09") 
{
    library(plotrix)
    if (is.character(data)) {
        if (data == "find") {
            load(paste(basedir, "/", directory, "/stopstate.r", 
                sep = ""))
            data = stopstate
        }
    }
    RAreg = {
    }
    DECreg = {
    }
    info = read.table(paste(basedir, "/SurveyInfo.txt", sep = ""), 
        header = T)
    RAadd = info[info[, "Region"] == position, "RAmin"]
    Decadd = info[info[, "Region"] == position, "DECmin"]
    raran = info[info[, "Region"] == position, "RArange"]
    decran = info[info[, "Region"] == position, "DECrange"]
    loc = info[info[, "Region"] == position, "Loc"]
    skirt = info[info[, "Region"] == position, "Skirt"]
    year = info[info[, "Region"] == position, "Year"]
    semester = info[info[, "Region"] == position, "Sem"]
    run = info[info[, "Region"] == position, "Run"]
    denpri = info[info[, "Region"] == position, "Denpri"]
    minpri = info[info[, "Region"] == position, "LoPclass"]
    survey = info[info[, "Region"] == position, "MainSclass"]
    magbin = 5
    RAreg = c(RAadd, RAadd + raran)
    DECreg = c(Decadd, Decadd + decran)
    if (sub[1] == "all") {
        sub = data$tilelim[, 1]
    }
    if (save) {
        if (type == "png") {
            png(paste(basedir, "/", directory, "/Tiles", min(sub), 
                "-", max(sub), ".png", sep = ""), width = 800, 
                height = 480)
        }
        if (type == "eps") {
            setEPS()
            postscript(paste(basedir, "/", directory, "/Tiles", 
                min(sub), "-", max(sub), ".eps", sep = ""), width = 800/72, 
                height = 480/72)
        }
        if (type == "pdf") {
            pdf(paste(basedir, "/", directory, "/Tiles", min(sub), 
                "-", max(sub), ".pdf", sep = ""), width = 800/72, 
                height = 480/72, onefile = TRUE)
        }
    }
    layout(matrix(c(1, 2), ncol = 2), widths = c(0.8, 0.2), heights = 1)
    par(mar = c(5.1, 4.1, 4.1, 0))
    plot(data$tilelim[sub, c(3, 4)], xlab = "RA/deg", ylab = "Dec/deg", 
        asp = 1, xlim = RAreg + c(-0.5, 0.5), ylim = DECreg + 
            c(-0.5, 0.5), main = paste("Tiling Map for ", loc, 
            " ", min(sub), "-", max(sub), " Tiles", sep = ""))
    for (i in 1:length(sub)) {
        draw.circle(as.numeric(data$tilelim[data$tilelim[, 1] == 
            sub[i], 3]), as.numeric(data$tilelim[data$tilelim[, 
            1] == sub[i], 4]), radius = 1, col = hsv(alpha = 0.1))
    }
    text(data$tilelim[sub, 3], data$tilelim[sub, 4] + 0.2, labels = data$tilelim[sub, 
        1])
    rect(RAreg[1], DECreg[1], RAreg[2], DECreg[2])
    rect(RAreg[1] + skirt, DECreg[1] + skirt, RAreg[2] - skirt, 
        DECreg[2] - skirt, lty = 3)
    if (left) {
        points(TileCat[TileCat[, "CATA_INDEX"] %in% data$assign[data$assign[, 
            3] %in% PriConvMat[PriConvMat[, "TilePlot"], "Orig"] & 
            (data$assign[, 2] %in% sub == FALSE | data$assign[, 
                2] == 0), 1], c("RA", "DEC")], pch = PriConvMat[PriConvMat[, 
            "TilePlot"], "Pty"], col = PriConvMat[PriConvMat[, 
            "TilePlot"], "Colour"])
    }
    else {
        points(TileCat[TileCat[, "CATA_INDEX"] %in% data$assign[data$assign[, 
            3] %in% PriConvMat[PriConvMat[, "TilePlot"], "Orig"] & 
            data$assign[, 2] %in% sub, 1], c("RA", "DEC")], pch = PriConvMat[PriConvMat[, 
            "TilePlot"], "Pty"], col = PriConvMat[PriConvMat[, 
            "TilePlot"], "Colour"])
    }
    plot.new()
    par(mar = c(5.1, 0, 4.1, 0))
    legendtext = {
    }
    for (i in 1:length(which(PriConvMat[, "TilePlot"] == TRUE))) {
        legendtext = c(legendtext, paste("Priority", PriConvMat[PriConvMat[, 
            "TilePlot"] == TRUE, 1][i]))
    }
    legend(x = -0.5, y = 0.9, pch = 1, legend = legendtext, col = PriConvMat[PriConvMat[, 
        "TilePlot"] == TRUE, "Colour"], bty = "n", title = "Tiling Cat\nPiorities")
    layout(1)
    par(mar = c(5.1, 4.1, 4.1, 2.1))
    if (save) {
        dev.off()
    }
}
