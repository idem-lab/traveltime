## Submission

This is a new submission.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for CRAN

* Some examples and tests download friction surfaces from the Malaria Atlas
  Project server via the 'malariaAtlas' package. Examples that need the
  internet are wrapped in `\donttest{}`, and the corresponding tests are
  skipped on CRAN. If the server is unavailable, `get_friction_surface()`
  fails gracefully, returning `NULL` with an informative warning.
* The vignette is precomputed, because it downloads data, so it does not
  require an internet connection to build.
