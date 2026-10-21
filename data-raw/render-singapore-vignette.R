# Regenerate the precomputed Singapore vignette.
#
# The vignette downloads data (the friction surface from the Malaria Atlas
# Project and the Singapore boundary from GADM), so it cannot be reliably
# rebuilt on CRAN. Instead it is executed ONCE here, with traveltime loaded
# from source, and the resulting static vignette is what is built:
#
#   vignettes/singapore.Rmd.orig   (source: edit this one)
#   vignettes/singapore.Rmd        (built: code shown, output precomputed)
#   vignettes/singapore-*.png      (figures)
#
# Run this by hand whenever vignettes/singapore.Rmd.orig or the package
# changes in a way that affects its output.
#
# Usage:  Rscript data-raw/render-singapore-vignette.R

pkgload::load_all(".", quiet = TRUE)

# knit() does not change the working directory, so switch into vignettes/ to
# keep fig.path and the image links in the built .Rmd relative to it.
owd <- setwd("vignettes")
on.exit(setwd(owd), add = TRUE)

knitr::knit(
  input  = "singapore.Rmd.orig",
  output = "singapore.Rmd"
)

message("Rebuilt vignettes/singapore.Rmd and figures.")
