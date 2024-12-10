## code to prepare `DATASET` dataset goes here

library(terra)

# Land Transport Authority. (2019). LTA MRT Station Exit (GEOJSON) (2024)
# [Dataset]. data.gov.sg. Retrieved December 10, 2024 from
# https://data.gov.sg/datasets/d_b39d3a0871985372d7e1637193335da5/view

mrt_vect <- vect("data-raw/LTAMRTStationExitGEOJSON.geojson")


stations <-geom(mrt_vect)[,c("x", "y")]

usethis::use_data(stations, overwrite = TRUE)
