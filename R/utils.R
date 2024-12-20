
# warn_and_return checks if a file exists already and returns the raster
# from the exsting file with a warning that no calculation is being performed
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

  TRUE

}
