
# warn_and_return checks if `filename` already exists and, if it does and
# `overwrite` is FALSE, warns and returns the existing file as a SpatRaster so
# the caller can return it without recalculating. Otherwise returns NULL.
warn_and_return <- function(
  filename,
  overwrite
){

  filename_used <- !is.null(filename)

  file_exists <- ifelse(
    filename_used,
    file.exists(filename),
    FALSE
  )

  warn_user_not_overwrite <- filename_used && file_exists && !overwrite

  if (warn_user_not_overwrite) {

    cli::cli_warn(
      message = c(
        "x" = "{.path {filename}} already exists",
        "Using existing file, {.path {filename}}",
        "i" =  "To re-generate file, change {.arg overwrite} to {.code TRUE}"
      )
    )

    return(terra::rast(filename))

  }

  NULL

}
