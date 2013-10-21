report <-
function (directory = "test", TileCat = TileV4f, basedir = "~/Work/R/GAMA/Tiling", 
    latex = FALSE, latexdir = "/usr/texbin", pdfopen = FALSE, 
    dvipsdir = "/sw/bin", position = "g09") 
{
    library(xtable, lib = c("/home/aatlxa/gama/R/x86_64-redhat-linux-gnu-library/2.9/", 
        .libPaths()))
    reset = FALSE
    if (exists("stopstate")) {
        temp = stopstate
        reset = TRUE
    }
    load(paste(basedir, "/", directory, "/stopstate.r", sep = ""), 
        envir = .GlobalEnv)
    assign("TileCat", TileCat, envir = .GlobalEnv)
    assign("angcompnum", length(which(stopstate$tilelim[, "AngComp"] < 
        0.99)) + min(stopstate$tilelim[, "No."]), envir = .GlobalEnv)
    assign("basedir", basedir, envir = .GlobalEnv)
    assign("position", position, envir = .GlobalEnv)
    writeLines(SweaveFile, paste(basedir, "/", directory, "/report.Rnw", 
        sep = ""))
    Sweave(paste(basedir, "/", directory, "/report.Rnw", sep = ""), 
        stylepath = TRUE)
    if (reset) {
        assign("stopstate", temp, envir = .GlobalEnv)
    }
    else {
        rm(stopstate, envir = .GlobalEnv)
    }
    rm(TileCat, envir = .GlobalEnv)
    rm(angcompnum, envir = .GlobalEnv)
    file.rename("report.tex", paste(basedir, "/", directory, 
        "/report.tex", sep = ""))
    file.rename("report-001.eps", paste(basedir, "/", directory, 
        "/report-001.eps", sep = ""))
    file.rename("report-001.pdf", paste(basedir, "/", directory, 
        "/report-001.pdf", sep = ""))
    file.rename("report-002.eps", paste(basedir, "/", directory, 
        "/report-002.eps", sep = ""))
    file.rename("report-002.pdf", paste(basedir, "/", directory, 
        "/report-002.pdf", sep = ""))
    file.rename("report-003.eps", paste(basedir, "/", directory, 
        "/report-003.eps", sep = ""))
    file.rename("report-003.pdf", paste(basedir, "/", directory, 
        "/report-003.pdf", sep = ""))
    file.rename("report-004.eps", paste(basedir, "/", directory, 
        "/report-004.eps", sep = ""))
    file.rename("report-004.pdf", paste(basedir, "/", directory, 
        "/report-004.pdf", sep = ""))
    file.rename("report-005.eps", paste(basedir, "/", directory, 
        "/report-005.eps", sep = ""))
    file.rename("report-005.pdf", paste(basedir, "/", directory, 
        "/report-005.pdf", sep = ""))
    temp = c(paste("cd ", basedir, "/", directory, sep = ""), 
        "/usr/texbin/latex report.tex", "/usr/texbin/latex report.tex")
    if (latex) {
        system(paste("cd ", basedir, "/", directory, "\n", latexdir, 
            "/pdflatex report.tex\n", latexdir, "/pdflatex report.tex\n", 
            sep = ""))
        file.remove(paste(basedir, "/Rplots.pdf", sep = ""))
        file.remove(paste(basedir, "/", directory, "/report.Rnw", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report.log", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report.aux", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report.tex", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-001.eps", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-001.pdf", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-002.eps", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-002.pdf", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-003.eps", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-003.pdf", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-004.eps", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-004.pdf", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-005.eps", 
            sep = ""))
        file.remove(paste(basedir, "/", directory, "/report-005.pdf", 
            sep = ""))
        if (pdfopen) {
            system(paste("open -a preview ", basedir, "/", directory, 
                "/report.pdf", sep = ""))
        }
    }
}
