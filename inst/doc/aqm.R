### R code from vignette source 'aqm.Rnw'

###################################################
### code chunk number 1: aqm.Rnw:27-31
###################################################
options(error=recover)
options(bitmapType = "cairo")
.HaveDummy = !interactive()
  if(.HaveDummy) pdf("dummy.pdf")


###################################################
### code chunk number 2: loading
###################################################
library("arrayQualityMetrics")
library("ALLMLL")
data("MLL.A")


###################################################
### code chunk number 3: DataPreparation
###################################################
preparedData = prepdata(expressionset = MLL.A, 
                    intgroup = c(), 
                    do.logtransform = TRUE)


###################################################
### code chunk number 4: aqm.Rnw:91-92 (eval = FALSE)
###################################################
## ?aqm.boxplot


###################################################
### code chunk number 5: metrics
###################################################
bo = aqm.boxplot(preparedData)
de = aqm.density(preparedData)
qm = list("Boxplot" = bo, "Density" = de)


###################################################
### code chunk number 6: booutliers
###################################################
bo@outliers


###################################################
### code chunk number 7: shortReport
###################################################
outdir = tempdir()
aqm.writereport(modules = qm, reporttitle = "My example", outdir = outdir, 
                arrayTable = pData(MLL.A))
outdir


###################################################
### code chunk number 8: aqm.Rnw:166-167
###################################################
if(.HaveDummy) dev.off()


###################################################
### code chunk number 9: pkgs
###################################################
toLatex(sessionInfo())


