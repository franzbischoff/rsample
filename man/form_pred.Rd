% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/form_pred.R
\name{form_pred}
\alias{form_pred}
\title{Extract Predictor Names from Formula or Terms}
\usage{
form_pred(object, ...)
}
\arguments{
\item{object}{A model formula or \code{\link[stats:terms]{stats::terms()}}
object.}

\item{...}{Arguments to pass to \code{\link[=all.vars]{all.vars()}}}
}
\value{
A character vector of names
}
\description{
While \code{\link[=all.vars]{all.vars()}} returns all variables used in a formula, this
function only returns the variables explicitly used on the
right-hand side (i.e., it will not resolve dots unless the
object is terms with a data set specified).
}
\examples{
form_pred(y ~ x + z)
form_pred(terms(y ~ x + z))

form_pred(y ~ x + log(z))
form_pred(log(y) ~ x + z)

form_pred(y1 + y2 ~ x + z)
form_pred(log(y1) + y2 ~ x + z)

# will fail:
# form_pred(y ~ .)

form_pred(terms(mpg ~ (.)^2, data = mtcars))
form_pred(terms(~ (.)^2, data = mtcars))
}
