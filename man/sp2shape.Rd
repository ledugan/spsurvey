\name{sp2shape}
\alias{sp2shape}
\title{Convert an sp Package Object to an ESRI Shapefile}
\description{
  This function creates an ESRI shapefile from an sp package object.  The
  function can also accommodate an object created by the grts or irs functions
  in spsurvey.  The type of shapefile, i.e., point, polyline, or polygon, is
  determined by the class of the input object, which must be either
  "SpatialDesign", "SpatialPointsDataFrame", "SpatialLinesDataFrame", or
  "SpatialPolygonsDataFrame".
}
\usage{
sp2shape(sp.obj, shpfilename="tempfile", prjfilename=NULL)
}
\arguments{
  \item{sp.obj}{the sp package object or object created by either the grts or irs
    functions.}
  \item{shpfilename}{name (without any extension) of the output shapefile.  The
    default is "tempfile".}
  \item{prjfilename}{name (without any extension) of the projection file for the
    output shapefile.  The default is NULL.}
}
\value{
  An ESRI shapefile of type point, polyline, or polygon.
}
\references{
  ESRI Shapefile Technical Description: 
  \url{http://www.esri.com/library/whitepapers/pdfs/shapefile.pdf}
}
\author{
Tom Kincaid \email{Kincaid.Tom@epa.gov}
}
\examples{
  \dontrun{
  sp2shape(my.sp.object, "my.shapefile")
  }
}
\keyword{IO}
