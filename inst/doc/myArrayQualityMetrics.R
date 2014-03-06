### R code from vignette source 'arrayQualityMetrics.Rnw'

###################################################
### code chunk number 1: arrayQualityMetrics.Rnw:117-119
###################################################
options(error = recover, warn = 2)
options(bitmapType = "cairo")


###################################################
### code chunk number 2: DataLoading
###################################################
library("ALLMLL")
data("MLL.A")


###################################################
### code chunk number 3: AffyBatchQM
###################################################
library("myArrayQualityMetrics")
arrayQualityMetrics(expressionset = MLL.A[, 1:5],
                    outdir = "Report_for_MLL_A",
                    force = TRUE,
                    do.logtransform = TRUE)


###################################################
### code chunk number 4: Normalisation
###################################################
nMLL = rma(MLL.A)


###################################################
### code chunk number 5: ExpressionSet
###################################################
arrayQualityMetrics(expressionset = nMLL,
                    outdir = "Report_for_nMLL",
                    force = TRUE)


###################################################
### code chunk number 6: NChannelSet
###################################################
library("vsn")
library("CCl4")
data("CCl4")
nCCl4 = justvsn(CCl4, subsample = 15000)
arrayQualityMetrics(expressionset = nCCl4,
                    outdir = "Report_for_nCCl4",
                    force = TRUE)


###################################################
### code chunk number 7: intgroup1
###################################################
pData(nMLL)$condition = rep(letters[1:4], times = 5)
pData(nMLL)$batch = rep(paste(1:4), each = 5)


###################################################
### code chunk number 8: intgroup2
###################################################
arrayQualityMetrics(expressionset = nMLL,
                    outdir = "Report_for_nMLL_with_factors",
                    force = TRUE,
                    intgroup = c("condition", "batch"))


###################################################
### code chunk number 9: XYcoordinates
###################################################
featureData(nCCl4)$X = featureData(nCCl4)$Row
featureData(nCCl4)$Y = featureData(nCCl4)$Column


###################################################
### code chunk number 10: hasTarget
###################################################
featureData(nCCl4)$hasTarget = (regexpr("^NM", featureData(nCCl4)$Name) > 0)
table(featureData(nCCl4)$hasTarget)


###################################################
### code chunk number 11: pData
###################################################
pd = pData(CCl4)
rownames(pd) = NULL
pd


###################################################
### code chunk number 12: RIN
###################################################
RIN = with(pd, ifelse( Cy3=="CCl4", RIN.Cy3, RIN.Cy5))
fRIN = factor(RIN)
levels(fRIN) = c("poor", "medium", "good")
pData(nCCl4)$"RNA-integrity" = fRIN


###################################################
### code chunk number 13: NChannelSet
###################################################
arrayQualityMetrics(expressionset = nCCl4,
                    outdir = "Report_for_nCCl4_with_RIN",
                    force = TRUE,
                    intgroup = "RNA-integrity")


###################################################
### code chunk number 14: pkgs
###################################################
toLatex(sessionInfo())


