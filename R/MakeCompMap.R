MakeCompMap <-
function (data = "find", directory = "test", save = FALSE, type = "png", 
    basedir = "~/Work/R/GAMA/Tiling") 
{
    hirpet = 24
    compline = 1
    if (is.character(data)) {
        if (data == "find") {
            load(paste(basedir, "/", directory, "/stopstate.r", 
                sep = ""))
            data = stopstate
        }
    }
    comp95 = {
    }
    comp99 = {
    }
    comp100 = {
    }
    for (i in 1:max(which(data$maglim < 0.95, arr.ind = TRUE)[, 
        1])) {
        comp95[i] = (min(data$tilelim[, 1]) - 1) + 14.9 + min(which(data$maglim[i, 
            ] < 0.95)) * 0.1
    }
    for (i in 1:max(which(data$maglim < 0.99, arr.ind = TRUE)[, 
        1])) {
        comp99[i] = (min(data$tilelim[, 1]) - 1) + 14.9 + min(which(data$maglim[i, 
            ] < 0.99)) * 0.1
    }
    for (i in 1:max(which(data$maglim < 1, arr.ind = TRUE)[, 
        1])) {
        comp100[i] = (min(data$tilelim[, 1]) - 1) + 14.9 + min(which(data$maglim[i, 
            ] < 1)) * 0.1
    }
    loc80 = (max(which(data$maglim < 0.8, arr.ind = TRUE)[, 1]) + 
        min(data$tilelim[, 1]))
    loc90 = (max(which(data$maglim < 0.9, arr.ind = TRUE)[, 1]) + 
        min(data$tilelim[, 1]))
    loc95 = (max(which(data$maglim < 0.95, arr.ind = TRUE)[, 
        1]) + min(data$tilelim[, 1]))
    loc99 = (max(which(data$maglim < 0.99, arr.ind = TRUE)[, 
        1]) + min(data$tilelim[, 1]))
    loc100 = (max(which(data$maglim < 1, arr.ind = TRUE)[, 1]) + 
        min(data$tilelim[, 1]))
    all80 = length(which(stopstate$tilelim[, 2] < 0.8)) + min(data$tilelim[, 
        1])
    all90 = length(which(stopstate$tilelim[, 2] < 0.9)) + min(data$tilelim[, 
        1])
    all95 = length(which(stopstate$tilelim[, 2] < 0.95)) + min(data$tilelim[, 
        1])
    all99 = length(which(stopstate$tilelim[, 2] < 0.99)) + min(data$tilelim[, 
        1])
    all100 = length(which(stopstate$tilelim[, 2] < 1)) + min(data$tilelim[, 
        1])
    if (save) {
        if (type == "png") {
            png(paste(basedir, "/", directory, "/Comp", min(data$assign[, 
                2]), "-", max(data$assign[, 2]), ".png", sep = ""), 
                width = 800, height = 480)
        }
        if (type == "eps") {
            setEPS()
            postscript(paste(basedir, "/", directory, "/Comp", 
                min(data$assign[, 2]), "-", max(data$assign[, 
                  2]), ".eps", sep = ""), width = 800/72, height = 480/72)
        }
        if (type == "pdf") {
            pdf(paste(basedir, "/", directory, "/Comp", min(data$assign[, 
                2]), "-", max(data$assign[, 2]), ".pdf", sep = ""), 
                width = 800/72, height = 480/72, onefile = TRUE)
        }
    }
    layout(mat = matrix(c(2, 1), nrow = 2, ncol = 1), heights = c(0.25, 
        0.7))
    par(mar = c(3.1, 3.1, 0, 2.1))
    magimage(z = data$maglim, breaks = c(0, 0.8, 0.9, 0.95, 0.99, 
        1 - 1e-08, 1), col = grey(0:5/5), y = c(seq(15, 24, by = 0.1)), 
        x = sort(data$tilelim[, 1]), xlab = "Tile No.", ylab = "Magnitude", 
        xlim = c(min(data$tilelim[, 1]), max(c(min(data$tilelim[, 
            1]) + 20, max(data$tilelim[, 1])))), magmap=FALSE, grid=TRUE)
    abline(v = c(loc80, loc90), lty = 3)
    if (compline >= 0.95) {
        lines(stepfun(x = 2:max(which(data$maglim < 0.95, arr.ind = TRUE)[, 
            1] + 1), y = c(comp95, hirpet)))
        abline(v = loc95, lty = 3)
    }
    if (compline >= 0.99) {
        lines(stepfun(x = 2:max(which(data$maglim < 0.99, arr.ind = TRUE)[, 
            1] + 1), y = c(comp99, hirpet)))
        abline(v = loc99, lty = 3)
    }
    if (compline >= 1) {
        lines(stepfun(x = 2:max(which(data$maglim < 1, arr.ind = TRUE)[, 
            1] + 1), y = c(comp100, hirpet)))
        abline(v = loc100, lty = 3)
    }
    legend("bottomright", pch = 22, pt.bg = grey(0:5/5), legend = c("<80%", 
        "<90%", "<95%", "<99%", "<100%", "100%"), bg='white')
    abline(v = c(all80, all90, all95, all99), lty = 2, col = "red")
    par(mar = c(0, 3.1, 2.1, 2.1))
    magplot(0,0, xlim= c(min(data$tilelim[, 1]), max(c(min(data$tilelim[, 
            1]) + 20, max(data$tilelim[, 1])))), ylim=c(0,1), type='n', labels=FALSE, grid=TRUE)
    lines(data$tilelim)
    title(main = paste("Completeness Map for", min(data$assign[, 
        2]), "-", max(data$assign[, 2]), " Tiles", sep = ""))
    magaxis(side = 4)
    box()
    lines(c(all80, all80), c(0, data$tilelim[all80, 2]), lty = 2, 
        col = "red")
    lines(c(0, all80), c(data$tilelim[all80, 2], data$tilelim[all80, 
        2]), lty = 2, col = "red")
    lines(c(all90, all90), c(0, data$tilelim[all90, 2]), lty = 2, 
        col = "red")
    lines(c(0, all90), c(data$tilelim[all90, 2], data$tilelim[all90, 
        2]), lty = 2, col = "red")
    lines(c(all95, all95), c(0, data$tilelim[all95, 2]), lty = 2, 
        col = "red")
    lines(c(0, all95), c(data$tilelim[all95, 2], data$tilelim[all95, 
        2]), lty = 2, col = "red")
    lines(c(all99, all99), c(0, data$tilelim[all99, 2]), lty = 2, 
        col = "red")
    lines(c(0, all99), c(data$tilelim[all99, 2], data$tilelim[all99, 
        2]), lty = 2, col = "red")
    text(x = c(all80, all90, all95, all99), y = rep(0.2, 4), 
        labels = c(all80, all90, all95, all99))
    layout(1)
    par(mar = c(3.1, 3.1, 2.1, 2.1))
    if (save) {
        dev.off()
    }
    return = cbind(c("all80", "all90", "all95", "all99", "all100", 
        "loc80", "loc90", "loc95", "loc99", "loc100"), c(all80, 
        all90, all95, all99, all100, loc80, loc90, loc95, loc99, 
        loc100))
}
