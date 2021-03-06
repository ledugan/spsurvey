\name{SpatialDesign-class}
\docType{class}
\alias{SpatialDesign-class}
\alias{summary,SpatialDesign-method}
\alias{summary.SpatialDesign}
\alias{plot,SpatialDesign,missing-method}
\alias{plot.SpatialDesign}
\title{Class "SpatialDesign" }
\description{Class for spatial attributes that have spatial point locations and
  survey design information}
\usage{
  \S4method{summary}{SpatialDesign}(object, ..., auxvar = NULL, spframe = NULL,
    tess_ind = TRUE, sbc_ind = FALSE, nrows = 5, dxdy = TRUE)
  \method{summary}{SpatialDesign}(object, ..., auxvar = NULL, spframe = NULL,
    tess_ind = TRUE, sbc_ind = FALSE, nrows = 5, dxdy = TRUE)
  \S4method{plot}{SpatialDesign,missing}(x, y, ..., spframe = NULL,
    stratum = NULL, mdcaty = NULL, auxvar = NULL, pdffile = NULL, width = 8,
    height = 10)
  \method{plot}{SpatialDesign}(x, y, ..., spframe = NULL, stratum = NULL,
    mdcaty = NULL, auxvar = NULL, pdffile = NULL, width = 8, height = 10)
}
\arguments{
  \item{object, x}{\code{SpatialDesign} object}
  \item{y}{missing - this argument is not used}
  \item{...}{arguments passed through}
  \item{auxvar}{a vector containing the names of columns in the data slot of the
  	\code{SpatialDesign} object that identify auxiliary variables to be used to
  	summarize the survey design or create plots of the survey design.  The
  	default is NULL.}
  \item{spframe}{an sp package object of class \code{SpatialPointsDataFrame},
    \code{SpatialLinesDataFrame}, or \code{SpatialPolygonsDataFrame} that
    contains the survey design frame.  The default is NULL.}
  \item{tess_ind}{a logical variable indicating whether spatial balance metrics
   are calculated using proportions obtained from the intersection of Dirichlet
   tesselation polygons for the sample points with the frame object.  TRUE means
   calculate the metrics.  FALSE means do not calculate the metrics.  The
   default is TRUE}
  \item{sbc_ind}{a logical variable indicating whether spatial balance metrics
   are calculated using proportions obtained from a rectangular grid
   superimposed on the sample points and the frame.  TRUE means calculate the
   metrics. FALSE means do not calculate the metrics. The default is FALSE.}
  \item{nrows}{number of rows (and columns) for the grid of cells.  The default
   is 5.}
  \item{dxdy}{indicator for equal x-coordinate and y-coordinate grid cell
   increments, where TRUE means the increments are equal and FALSE means the
   increments are not equal.  The default is TRUE.}
  \item{stratum}{name of the column from the data slot of the spframe object
    that identifies stratum membership for each element in the frame.  If
    stratum equals NULL, the design is unstratified, and a column named
    "stratum" (with all its elements equal to the stratum name specified in
    design) is added to the data slot of the spframe object.  The default is
    NULL.}
  \item{mdcaty}{name of the column from the data slot of the spframe object that
    identifies the unequal probability category for each element in the frame.
    The default is NULL.}
  \item{pdffile}{a character variable containing the name of the pdf file to
    which output is written. If a value is not provided, output is written to
    the graphics window.  The default is NULL.}
  \item{width}{width of the graphic region in inches.  The default is 8.}
  \item{height}{height of the graphic region in inches.  The default is 10.}
}
\section{Slots}{
  \describe{
    \item{\code{design}:}{Object of class list containing specifications
      for the survey design.}
    \item{\code{data}:}{Object of class data.frame containing the attribute
      data.}
	  \item{\code{coords.nrs}:}{Numeric object that records the column positions
	    in \code{data} from which the coordinates were obtained.}
    \item{\code{coords}:}{Object of class matrix containing the coordinates
      matrix, where points are rows in the matrix.}
    \item{\code{bbox}:}{Object of class matrix containing the bounding box.}
    \item{\code{proj4string}:}{Object of class CRS containing the projection
      string.}
  }
}
\section{Extends}{
  Class \code{"SpatialPointsDataFrame"}, directly.
  Class \code{"SpatialPoints"}, by class \code{"SpatialPointsDataFrame"}.
  Class \code{"Spatial"}, by class \code{"SpatialPoints"}.
}
\seealso{
  \code{\link{SpatialDesign}} 
}
\keyword{classes}
