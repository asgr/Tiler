MakeWaste <-
function (data = "find", directory = "test", save = FALSE, type = "png", 
    basedir = "~/Work/R/GAMA/Tiling") 
{
  options(stringsAsFactors = FALSE)
  data(PriConvMat,package='Tiler')
  PriConvMat[,'Colour']=as.character(PriConvMat[,'Colour'])
  PriConvMat[,'Pty']=as.character(PriConvMat[,'Pty'])
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
    fibtot = {}
    fibmax = {}
    fibmaxpos = {}
    for (i in 1:length(data$fibstats[, 1])) {
        fibtot = c(fibtot, length(which(data$fibstats[i, ] == 1)))
        fibmax = c(fibmax, fibtot[i] + length(which(data$fibstats[i,] == 0)) + length(which(data$fibstats[i, ] == 99)))
        fibmaxpos = c(fibmaxpos, fibtot[i] + length(which(data$fibstats[i,] == 0)))
    }
    par(mar = c(3.1, 3.1, 2.1, 2.1))
    magplot(cbind(data$tilelim[, 1], fibtot), type = "l", xlab = "Tile No.", 
        ylab = "Fibres", xlim = c(min(data$tilelim[, 1]), max(c(min(data$tilelim[,1]) + 20, max(data$tilelim[, 1])))), ylim = c(0, 400), col = "black", main = paste("Fibre Priorities for ",min(data$assign[, 2]),"-", max(data$assign[, 2]), " Tiles", sep = ""), grid=TRUE, lwd=2)
    for (i in 1:length(which(PriConvMat[, "WastePlot"] == TRUE))) {
      select=data$assign[,3] == PriConvMat[PriConvMat[, "WastePlot"] == TRUE,1][i] & data$assign[, 2] > 0
      if(length(which(select))>0){
        lines(as.matrix(as.data.frame(table(data$assign[select, 2]))), lty = PriConvMat[PriConvMat[, "WastePlot"] == TRUE, "Lty"][i], col = PriConvMat[PriConvMat[, "WastePlot"] == TRUE, "Colour"][i], lwd=2)
      }
    }
    lines(cbind(data$tilelim[, 1], fibmax), col = "grey", lty = 2, lwd=2)
    lines(cbind(data$tilelim[, 1], fibmaxpos), col = "red", lty = 3, lwd=2)
    legend("bottomright", lty = c(2, 3, 1, PriConvMat[PriConvMat[,"WastePlot"], "Lty"]), legend = c("All Fibs", "Non-Broken", "Total Assigned", paste('Priority',PriConvMat[PriConvMat[, "WastePlot"],'Orig'])), col = c("grey", "red", "black", PriConvMat[PriConvMat[, "WastePlot"], "Colour"]), lwd=2, bg='white')
    if (save) {
        dev.off()
    }
}
