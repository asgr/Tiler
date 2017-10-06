MakeFibGrid <-
function (data = "find", directory = "test", save = FALSE, type = "png", 
    basedir = "~/Work/R/GAMA/Tiling") 
{
    if (is.character(data)) {
        if (data == "find") {
            load(paste(basedir, "/", directory, "/stopstate.r", 
                sep = ""))
            data = stopstate
        }
    }
    if (save) {
        if (type == "png") {
            png(paste(basedir, "/", directory, "/FibGrid", 1, 
                "-", max(data$assign[, 2]), ".png", sep = ""), 
                width = 800, height = 480)
        }
        if (type == "eps") {
            setEPS()
            postscript(paste(basedir, "/", directory, "/FibGrid", 
                1, "-", max(data$assign[, 2]), ".eps", sep = ""), 
                width = 800/72, height = 480/72)
        }
        if (type == "pdf") {
            pdf(paste(basedir, "/", directory, "/FibGrid", 1, 
                "-", max(data$assign[, 2]), ".pdf", sep = ""), 
                width = 800/72, height = 480/72, onefile = TRUE)
        }
    }
    par(mar = c(3.1, 3.1, 2.1, 2.1))
    magimage(x = data$tilelim[, 1], y = 1:400, z = data$fibstats, 
        breaks = c(0, 0.5, 1.5, 2.5, 3.5, 4.5, 100), col = c("white", 
            "lightgreen", "yellow", "blue", "orange", "red"), 
        xlab = "Tile No.", ylab = "Pivot No.", xlim = c(min(data$tilelim[, 
            1]), max(c(min(data$tilelim[, 1]) + 20, max(data$tilelim[, 
            1])))), main = paste("Pivot usage for 1-", max(data$assign[, 
            2]), " Tiles", sep = ""), magmap=FALSE, grid=TRUE)
    legend("topright", legend = c("Target", "Guide", "Sky", "Spec", 
        "Broken", "Unused"), col = c("lightgreen", "yellow", 
        "blue", "orange", "red", "white"), pch = 1, bg='white')
    if (save) {
        dev.off()
    }
}
