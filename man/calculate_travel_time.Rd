% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_travel_time.R
\name{calculate_travel_time}
\alias{calculate_travel_time}
\title{Calculate travel time}
\usage{
calculate_travel_time(
  friction_surface,
  points,
  filename = NULL,
  overwrite = FALSE
)
}
\arguments{
\item{friction_surface}{A \code{SpatRaster} friction surface layer with in
resistance units. See Details.}

\item{points}{A two-column \code{matrix}, \code{data.frame}, (including \code{tibble} types)
with longitude (x) in the first column and latitude (y) in the second, or a
\code{SpatVector}, in the same coordinate reference system as
\code{friction_surface}.}

\item{filename}{\code{character}. Output file name with extension suitable for
\code{terra::writeRaster}}

\item{overwrite}{\code{logical}. If \code{TRUE} \code{filename} is overwritten.}
}
\value{
\code{SpatRaster}
}
\description{
Calculate the travel time from a set of points over a friction
surface.
}
\details{
Implements methods from Weiss et al. 2018, 2020 to calculate travel
time from given locations over a friction surface.

Over large areas this function can require significant RAM and will be
slow.

Pre-prepared walking or motorised friction surfaces can be obtained
with\code{?get_friction_surface}. User can also provide their own friction
surface. This surface but must be in resistance units (1/conductance), e.g.
minutes/meter. See Van Etten 2017.

Citations:

D. J. Weiss, A. Nelson, C. A. Vargas-Ruiz, K. Gligoric, S., Bavadekar, E.
Gabrilovich, A. Bertozzi-Villa, J. Rozier, H. S. Gibson, T., Shekel, C.
Kamath, A. Lieber, K. Schulman, Y. Shao, V. Qarkaxhija, A. K. Nandi, S. H.
Keddie, S. Rumisha, P. Amratia, R. Arambepola, E. G. Chestnutt, J. J.
Millar, T. L. Symons, E. Cameron, K. E. Battle, S. Bhatt, and P. W.
Gething. Global maps of travel time to healthcare facilities. (2020) Nature
Medicine. \url{https://doi.org/10.1038/s41591-020-1059-1}

D. J. Weiss, A. Nelson, H.S. Gibson, W. Temperley, S. Peedell, A. Lieber,
M. Hancher, E. Poyart, S. Belchior, N. Fullman, B. Mappin, U. Dalrymple, J.
Rozier, T.C.D. Lucas, R.E. Howes, L.S. Tusting, S.Y. Kang, E. Cameron, D.
Bisanzio, K.E. Battle, S. Bhatt, and P.W. Gething. A global map of travel
time to cities to assess inequalities in accessibility in 2015. (2018).
Nature. \url{https://doi:10.1038/nature25181}

van Etten, J. (2017). R package gdistance: Distances and routes on
geographical grids. Journal of Statistical Software
\url{https://doi.org/10.18637/jss.v076.i13}
}
\examples{

ext <- matrix(
  data = c("111", "0", "112", 1),
  nrow = 2,
  ncol = 2,
  dimnames = list(
    c("x", "y"),
    c("min", "max")
   )
 )

 friction_surface <- get_friction_surface(
   surface = "motor2020",
   extent = ext
 )

 from_here <- data.frame(
   x = c(111.2, 111.9),
   y = c(0.2, 0.35)
 )

 calculate_travel_time(
  friction_surface = friction_surface,
  points = from_here
 )

}
