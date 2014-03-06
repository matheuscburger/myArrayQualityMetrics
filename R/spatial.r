##--------------------------------------------------------------------------------
## Spatial distributions. This function calls 'spatialplot' for possibly multiple
## elements of the list x, including "M", "R", "G"
##--------------------------------------------------------------------------------
aqm.spatial = function(x, scale="rank", channels = c("M", "R", "G"),
                       maxNumArrays=8, nrColumns=4, ...)
{
  if(!( (length(scale)==1) && is.character(scale) && (scale %in% c("direct", "rank")) ))
    stop("'scale' must be 'direct' or 'rank'\n")

  channels = intersect(channels, names(x))

  if(is.numeric(x$sx) && is.numeric(x$sy))
    {
      lapply(channels, spatialplot, x=x, scale=scale, maxNumArrays=maxNumArrays, nrColumns=nrColumns)
    } else {
      NULL
    }
}


##--------------------------------------------------------------------------------
## Spatial distribution plot for one channel
##--------------------------------------------------------------------------------
spatialplot = function(whichChannel, x, scale, maxNumArrays, nrColumns)
{

  colorRamp = colorRampPalette(rgb(seq(0,1,l=256),seq(0,1,l=256),seq(1,0,l=256)))
  maxx = max(x$sx, na.rm=TRUE)
  maxy = max(x$sy, na.rm=TRUE)

  ## Outlier detection: compute a measure for large scale spatial structures
  stat = numeric(x$numArrays)
  attr(stat, "name") = "<i>F<sub>a</sub></i>"

  for(a in seq_len(x$numArrays))
    {
      mat = matrix(NA_real_, nrow=maxy, ncol=maxx)
      mat[ cbind(x$sy, x$sx) ] = x[[whichChannel]][, a]
      pg  = fft(mat)       ## periodogram
      npg = Re(pg*Conj(pg))
      npg[1,1] = 0         ## drop the constant component
      stat[a] = sqrt(sum(npg[1:4, 1:4]) / sum(npg))   # low frequency power
    }
  fo = boxplotOutliers(stat)
  outliers = new("outlierDetection",
      statistic = stat,
      threshold = fo$threshold,
      which     = fo$which,
      description = c(attr(stat, "name"), "data-driven"))

  selected = processMaxNumArrays(x$numArrays, maxNumArrays, nrColumns, stat)

  dat = x[[whichChannel]][, selected$j, drop=FALSE]
  stopifnot(length(x$sx)==nrow(dat),
            length(x$sy)==nrow(dat))  ## this should always be true, given the definition of prepdata

  if(scale=="rank")
    dat = apply(dat, 2, rank)

  df = data.frame(
    "Array"  = as.factor(col(dat)),
    "ch"     = as.vector(dat),
    "row"    = x$sy,
    "column" = x$sx)

  panelNames = sprintf("array %d (F=%4.2f)", selected$j, stat[selected$j])

  spat = levelplot(ch ~ column*row | Array,
    data = df,
    axis = function (...) list(tick="no"),
    xlab = whichChannel,
    ylab = "",
    panel = "panel.levelplot.raster",
    col.regions = colorRamp,
    as.table = TRUE,
    layout = selected$lay,
    asp = "iso",
    strip = function(..., bg, factor.levels) strip.default(..., bg ="#cce6ff", factor.levels = panelNames),
    colorkey = (scale!="rank"))

  legend = paste("The figure <!-- FIG --> shows false color representations of the arrays' spatial distributions of",
    " feature intensities (", whichChannel, "). Normally, when the features are distributed randomly on the arrays, one expects to see a uniform",
    " distribution; control features with particularly high or low intensities may stand out. The color scale is",
    " proportional to ",
    switch(scale,
           rank = "the ranks of ",
           direct = ""),
    "the probe intensities",
    switch(scale,
           rank = paste(". Note that the rank scale has the potential to amplify patterns that are small in amplitude",
             "but systematic within an array. It is possible to switch off the rank scaling by modifying the argument",
             "<tt>scale</tt> in the call of the <tt>aqm.spatial</tt> function."),
           direct = ", and it is shown in the panel on the right."),
   "<br>Outlier detection was performed by computing <i>F<sub>a</sub></i> , the sum of the absolutes value of low frequency ",
   "Fourier coefficients, as a measure of large scale spatial structures.", selected$legOrder,
   " The value of <i>F<sub>a</sub></i> is shown in the panel headings. ", sep="")

  ## we allow 3^2 square inch per array
  fac = 3 / sqrt(maxx*maxy)

  new("aqmReportModule",
      plot     = spat,
      section  = "Individual array quality",
      title    = paste("Spatial distribution of", whichChannel),
      id       = paste("sp", tolower(whichChannel), sep = ""),
      legend   = legend,
      outliers = outliers,
      colors   = x$arrayColors,
      size     = with(selected, c(w = maxx * fac * lay[1], h = (maxy * fac + 0.25) * lay[2])))
}


