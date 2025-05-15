## R CMD check results

0 errors | 0 warnings | 0 notes

* A patch fix to address issues identified by CRAN team:
  * Throws an error if `preserve_metadata = "gdalraster_sozip"` in function `tar_terra_rast()` and if GDAL is less than 3.7. 
  * Tests also don't report progress bars, as mentioned by CRAN team.
