PriSplits <-
function (TileSub, TileCat = TileV4g, useIDs, proximity = 40, 
    denpri = 9) 
{
    bumppri = {
    }
    collide = {
    }
    carttemp = sph2car(TileCat[TileCat[, "CATA_INDEX"] %in% TileSub & 
        TileCat[, "PRIORITY_CLASS"] >= denpri, c("RA", "DEC")],deg=T)
    if (length(carttemp) > 0) {
        temp = fields.rdist.near(carttemp, carttemp, delta = (pi/180) * 
            proximity/3600, mean.neighbor = max(ceiling(1 + (length(TileSub)/48) * 
            pi * (proximity/3600)^2), 20))
        temp$ind = matrix(temp$ind, ncol = 2)
        temptileIDs = matrix(c(TileCat[TileCat[, "CATA_INDEX"] %in% 
            TileSub & TileCat[, "PRIORITY_CLASS"] >= denpri, 
            "CATA_INDEX"][temp$ind[, 1]], TileCat[TileCat[, "CATA_INDEX"] %in% 
            TileSub & TileCat[, "PRIORITY_CLASS"] >= denpri, 
            "CATA_INDEX"][temp$ind[, 2]]), ncol = 2)
        temptab = table(temptileIDs[, 1]) - 1
        temptab = temptab[temptab > 0]
        message("Remaining 10 worst colliders")
        print(sort(temptab, decreasing = TRUE)[1:10])
        temptileIDs = matrix(temptileIDs[temptileIDs[, 1] %in% 
            useIDs, ], ncol = 2)
        temptab = table(temptileIDs[, 1]) - 1
        temptab = temptab[temptab > 0]
        while (length(temptab) > 0) {
            topIDs = which(temptab == max(temptab))
            tempbump = as.numeric(names(temptab[resample(topIDs, 
                1)]))
            bumppri = rbind(bumppri, c(tempbump, max(temptab)))
            avoid = temptileIDs[temptileIDs[, 1] == tempbump, 
                2]
            collide = c(collide, temptileIDs[temptileIDs[, 1] == 
                tempbump & temptileIDs[, 2] != tempbump, 2])
            temptileIDs = matrix(temptileIDs[!temptileIDs[, 1] %in% 
                avoid, ], ncol = 2)
            temptab = table(temptileIDs[, 1]) - 1
            temptab = temptab[temptab > 0]
        }
    }
    return = list(bump = bumppri, collide = collide)
}
