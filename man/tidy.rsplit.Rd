% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tidy.R
\name{tidy.rsplit}
\alias{tidy.rsplit}
\alias{tidy.rset}
\alias{tidy.vfold_cv}
\alias{tidy.nested_cv}
\title{Tidy Resampling Object}
\usage{
\method{tidy}{rsplit}(x, unique_ind = TRUE, ...)

\method{tidy}{rset}(x, unique_ind = TRUE, ...)

\method{tidy}{vfold_cv}(x, ...)

\method{tidy}{nested_cv}(x, unique_ind = TRUE, ...)
}
\arguments{
\item{x}{A \code{rset} or \code{rsplit} object}

\item{unique_ind}{Should unique row identifiers be returned? For example,
if \code{FALSE} then bootstrapping results will include multiple rows in the
sample for the same row in the original data.}

\item{...}{These dots are for future extensions and must be empty.}
}
\value{
A tibble with columns \code{Row} and \code{Data}. The latter has possible
values "Analysis" or "Assessment". For \code{rset} inputs, identification
columns are also returned but their names and values depend on the type of
resampling. For \code{\link[=vfold_cv]{vfold_cv()}}, contains a column "Fold" and, if repeats are
used, another called "Repeats". \code{\link[=bootstraps]{bootstraps()}} and \code{\link[=mc_cv]{mc_cv()}} use the column
"Resample".
}
\description{
The \code{tidy()} function from the \pkg{broom} package can be used on \code{rset} and
\code{rsplit} objects to generate tibbles with which rows are in the analysis and
assessment sets.
}
\details{
Note that for nested resampling, the rows of the inner resample,
named \code{inner_Row}, are \emph{relative} row indices and do not correspond to the
rows in the original data set.
}
\examples{
\dontshow{if (rlang::is_installed("ggplot2")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
library(ggplot2)
theme_set(theme_bw())

set.seed(4121)
cv <- tidy(vfold_cv(mtcars, v = 5))
ggplot(cv, aes(x = Fold, y = Row, fill = Data)) +
  geom_tile() +
  scale_fill_brewer()

set.seed(4121)
rcv <- tidy(vfold_cv(mtcars, v = 5, repeats = 2))
ggplot(rcv, aes(x = Fold, y = Row, fill = Data)) +
  geom_tile() +
  facet_wrap(~Repeat) +
  scale_fill_brewer()

set.seed(4121)
mccv <- tidy(mc_cv(mtcars, times = 5))
ggplot(mccv, aes(x = Resample, y = Row, fill = Data)) +
  geom_tile() +
  scale_fill_brewer()

set.seed(4121)
bt <- tidy(bootstraps(mtcars, time = 5))
ggplot(bt, aes(x = Resample, y = Row, fill = Data)) +
  geom_tile() +
  scale_fill_brewer()

dat <- data.frame(day = 1:30)
# Resample by week instead of day
ts_cv <- rolling_origin(dat,
  initial = 7, assess = 7,
  skip = 6, cumulative = FALSE
)
ts_cv <- tidy(ts_cv)
ggplot(ts_cv, aes(x = Resample, y = factor(Row), fill = Data)) +
  geom_tile() +
  scale_fill_brewer()
\dontshow{\}) # examplesIf}
}
