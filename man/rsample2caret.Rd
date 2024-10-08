% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/caret.R
\name{rsample2caret}
\alias{rsample2caret}
\alias{caret2rsample}
\title{Convert Resampling Objects to Other Formats}
\usage{
rsample2caret(object, data = c("analysis", "assessment"))

caret2rsample(ctrl, data = NULL)
}
\arguments{
\item{object}{An \code{rset} object. Currently,
\code{\link[=nested_cv]{nested_cv()}} is not supported.}

\item{data}{The data that was originally used to produce the
\code{ctrl} object.}

\item{ctrl}{An object produced by \code{caret::trainControl()} that has
had the \code{index} and \code{indexOut} elements populated by
integers. One method of getting this is to extract the
\code{control} objects from an object produced by \code{train}.}
}
\value{
\code{rsample2caret()} returns a list that mimics the
\code{index} and \code{indexOut} elements of a
\code{trainControl} object. \code{caret2rsample()} returns an
\code{rset} object of the appropriate class.
}
\description{
These functions can convert resampling objects between
\pkg{rsample} and \pkg{caret}.
}
