# Regenerate the precomputed "Validating the costDist migration" article.
#
# Run this by hand whenever vignettes/articles/costdist-validation.Rmd.orig
# changes. It executes the comparison ONCE -- which needs terra + gdistance +
# raster, and the in-development traveltime loaded from source (no install) --
# and writes a static article that pkgdown and GitHub can display with no
# packages installed and no code executed at build time:
#
#   vignettes/articles/costdist-validation.Rmd   (built: code shown, not run)
#   vignettes/articles/figures/*.png             (tracked figures)
#
# Usage:  Rscript data-raw/render-costdist-article.R

pkgload::load_all(".", quiet = TRUE)   # traveltime from source; no install needed

# knit() (unlike rmarkdown::render) does not change the working directory, so
# switch into the article directory ourselves. This keeps fig.path ("figures/")
# and the image links in the built .Rmd relative to the article.
owd <- setwd("vignettes/articles")
on.exit(setwd(owd), add = TRUE)

knitr::knit(
  input  = "costdist-validation.Rmd.orig",
  output = "costdist-validation.Rmd"
)

message("Rebuilt costdist-validation.Rmd and figures/.")
