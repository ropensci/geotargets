#' Create a GDAL Virtual Dataset (VRT) with terra
#'
#' Provides a target format for [terra::SpatRaster-class],
#' [terra::SpatRasterDataset-class], and [terra::SpatRasterCollection-class]
#' objects representing a [GDAL Virtual Dataset
#' (VRT)](https://gdal.org/en/stable/drivers/raster/vrt.html).
#'
#' @param ... Additional arguments passed to [terra::vrt()]
#'
#' @details `tar_terra_vrt()` accepts SpatRaster, SpatRasterDataset, or
#'   SpatRasterCollection objects as input, and returns a SpatRaster referencing
#'   a GDAL Virtual Dataset file (.vrt). The .vrt file format uses XML and
#'   describes the layers and tiles that comprise a virtual raster data source.
#'   To use a list of SpatRaster of varying extent, such as output from
#'   `tar_terra_tiles()`, or a character vector of paths, wrap the tile result
#'   in a call to `terra::sprc()` to create a SpatRasterCollection.
#'
#' @inheritParams targets::tar_target
#' @importFrom rlang %||% arg_match0
#' @seealso [tar_terra_tiles()]
#' @export
#' @return target class "tar_stem" for use in a target pipeline
#' @examples
#' if (Sys.getenv("TAR_LONG_EXAMPLES") == "true") {
#'  targets::tar_dir({ # tar_dir() runs code from a temporary directory.
#'    targets::tar_script({
#'      list(
#'        geotargets::tar_terra_vrt(
#'          terra_rast_example,
#'          terra::rast(system.file("ex/elev.tif", package = "terra"))
#'        )
#'      )
#'    })
#'    targets::tar_make()
#'    x <- targets::tar_read(terra_rast_example)
#'  })
#'
#' targets::tar_dir({
#'     targets::tar_script({
#'         library(targets)
#'         library(geotargets)
#'         list(
#'             tar_terra_rast(r, terra::rast(
#'                 system.file("ex", "elev.tif", package = "terra")
#'             )),
#'             tar_terra_rast(r2, r * 2),
#'             tar_terra_tiles(rt, c(r, r2), function(x)
#'                 tile_grid(x, ncol = 2, nrow = 2)),
#'             tar_terra_vrt(r3, terra::sprc(rt))
#'         )
#'     })
#' })
#'
#'}
tar_terra_vrt <- function(
  name,
  command,
  pattern = NULL,
  ...,
  tidy_eval = targets::tar_option_get("tidy_eval"),
  packages = targets::tar_option_get("packages"),
  library = targets::tar_option_get("library"),
  repository = targets::tar_option_get("repository"),
  error = targets::tar_option_get("error"),
  memory = targets::tar_option_get("memory"),
  garbage_collection = targets::tar_option_get("garbage_collection"),
  deployment = targets::tar_option_get("deployment"),
  priority = targets::tar_option_get("priority"),
  resources = targets::tar_option_get("resources"),
  storage = targets::tar_option_get("storage"),
  retrieval = targets::tar_option_get("retrieval"),
  cue = targets::tar_option_get("cue"),
  description = targets::tar_option_get("description")
) {
  check_pkg_installed("terra")

  name <- targets::tar_deparse_language(substitute(name))

  envir <- targets::tar_option_get("envir")

  command <- targets::tar_tidy_eval(
    expr = as.expression(substitute(command)),
    envir = envir,
    tidy_eval = tidy_eval
  )

  pattern <- targets::tar_tidy_eval(
    expr = as.expression(substitute(pattern)),
    envir = envir,
    tidy_eval = tidy_eval
  )

  .format_terra_vrt_read <- function(path) {
    terra::rast(path)
  }

  .format_terra_vrt_write <- function(object, path) {
    # SpatRaster or SpatRasterCollection => character vector of source file path
    if (
      inherits(
        object,
        c("SpatRaster", "SpatRasterDataset", "SpatRasterCollection")
      )
    ) {
      object <- terra::sources(object)
    } else {
      stop(
        "Input object should be an object of class SpatRaster, SpatRasterDataset, or SpatRasterCollection"
      )
    }

    # default: the VRT contains project-specific paths to target store
    #  terra returns absolute paths: remove store parent directory from VRT paths
    #  user specified configs with absolute path to target store are preserved
    object <- gsub(
      paste0(".*(", targets::tar_path_store(), ".*)$"),
      "\\1",
      object
    )

    # add additional arguments from tar_terra_vrt(...)
    VRT_ARGS <- c(list(x = object, filename = path), args)

    # create a SpatRaster with a VRT file referencing the source paths
    do.call(terra::vrt, VRT_ARGS)
  }

  targets::tar_target_raw(
    name = name,
    command = command,
    pattern = pattern,
    packages = packages,
    library = library,
    format = targets::tar_format(
      read = .format_terra_vrt_read,
      write = .format_terra_vrt_write,
      marshal = function(object) terra::wrap(object),
      unmarshal = function(object) terra::unwrap(object),
      substitute = list(args = list(...))
    ),
    repository = repository,
    iteration = "list",
    error = error,
    memory = memory,
    garbage_collection = garbage_collection,
    deployment = deployment,
    priority = priority,
    resources = resources,
    storage = storage,
    retrieval = retrieval,
    cue = cue
  )
}
