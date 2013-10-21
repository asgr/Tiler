MakeWaste <-
function (data = "find", directory = "test", save = FALSE, type = "png", 
    basedir = "~/Work/R/GAMA/Tiling") 
{
  data(PriConvMat,package='Tiler')
  
    if (is.character(data)) {
        if (data == "find") {
            load(paste(basedir, "/", directory, "/stopstate.r", 
                sep = ""))
            data = stopstate
        }
    }

    if (save) {
        if (type == "png") {
            png(paste(basedir, "/", directory, "/Waste", 1, "-", 
                max(data$assign[, 2]), ".png", sep = ""), width = 800, 
                height = 480)
        }
        if (type == "eps") {
            setEPS()
            postscript(paste(basedir, "/", directory, "/Waste", 
                1, "-", max(data$assign[, 2]), ".eps", sep = ""), 
                width = 800/72, height = 480/72)
        }
        if (type == "pdf") {
            pdf(paste(basedir, "/", directory, "/Waste", 1, "-", 
                max(data$assign[, 2]), ".pdf", sep = ""), width = 800/72, 
                height = 480/72, onefile = TRUE)
        }
    }
    fibtot = {
    }
    fibmax = {
    }
    fibmaxpos = {
    }
    for (i in 1:length(data$fibstats[, 1])) {
        fibtot = c(fibtot, length(which(data$fibstats[i, ] == 
            1)))
        fibmax = c(fibmax, fibtot[i] + length(which(data$fibstats[i, 
            ] == 0)) + length(which(data$fibstats[i, ] == 99)))
        fibmaxpos = c(fibmaxpos, fibtot[i] + length(which(data$fibstats[i, 
            ] == 0)))
    }
    par(mar = c(5.1, 4.1, 4.1, 2.1))
    plot(cbind(data$tilelim[, 1], fibtot), type = "l", xlab = "Tile No.", 
        ylab = "Fibres", xlim = c(min(data$tilelim[, 1]), max(c(min(data$tilelim[, 
            1]) + 20, max(data$tilelim[, 1])))), ylim = c(0, 
            400), col = "purple", main = paste("Fibre Priorities for",min(data$assign[, 2]),"-", max(data$assign[, 2]), " Tiles", sep = ""))
    legendtext = c("Fibs", "Non-Broken", "Total Fibres")
    for (i in 1:length(which(PriConvMat[, "WastePlot"] == TRUE))) {
        lines(as.matrix(as.data.frame(table(data$assign[data$assign[, 
            3] == PriConvMat[PriConvMat[, "WastePlot"] == TRUE, 
            1][i] & data$assign[, 2] > 0, 2]))), lty = PriConvMat[PriConvMat[, 
            "WastePlot"] == TRUE, "Lty"][i], col = PriConvMat[PriConvMat[, 
            "WastePlot"] == TRUE, "Colour"][i])
        legendtext = c(legendtext, paste("Priority", PriConvMat[PriConvMat[, 
            "WastePlot"] == TRUE, 1][i]))
    }
    lines(cbind(data$tilelim[, 1], fibmax), col = "grey", lty = 2)
    lines(cbind(data$tilelim[, 1], fibmaxpos), col = "red", lty = 3)
    legend("bottomright", lty = c(2, 3, 1, PriConvMat[PriConvMat[, 
        "WastePlot"] == TRUE, "Lty"]), legend = legendtext, col = c("grey", 
        "red", "purple", PriConvMat[PriConvMat[, "WastePlot"] == 
            TRUE, "Colour"]))
    if (save) {
        dev.off()
    }
}
