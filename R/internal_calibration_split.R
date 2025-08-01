#' Internal calibration split of the analysis set for fitting a post-processor
#'
#' @param x An `rsplit` object.
#' @param split_args A list of arguments to be used for the internal calibration
#' split.
#' @param ... Not currently used.
#' @return An `rsplit` object.
#' @details
#' `rsplit` objects live most commonly inside of an `rset` object. The
#' `split_args` argument can be the output of [.get_split_args()] on that
#' corresponding `rset` object, even if some of the arguments used to create the
#' `rset` object are not needed for the internal calibration split.
#' * For `mc_split` and `group_mc_split` objects, `internal_calibration_split()`
#' will ignore `split_args$times`.
#' * For `vfold_split` and `group_vfold_split` objects, it will ignore
#' `split_args$times` and `split_args$repeats`. `split_args$v` will be used to
#' set `split_args$prop` to `1 - 1/v` if `prop` is not already set and otherwise
#' ignored. The method for `group_vfold_split` will always use
#' `split_args$balance = NULL`.
#' * For `boot_split` and `group_boot_split` objects, it will ignore
#' `split_args$times`.
#' * For `val_split`, `group_val_split`, and `time_val_split` objects, it will
#' interpret a length-2 `split_args$prop` as a ratio between the training and
#' validation sets and split into inner analysis and calibration set in
#' the same ratio. If `split_args$prop` is a single value, it will be used as
#' the proportion of the inner analysis set.
#' * For `clustering_split` objects, it will ignore `split_args$repeats`.
#'
#' @keywords internal
#' @export
internal_calibration_split <- function(x, ...) {
  UseMethod("internal_calibration_split")
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.default <- function(x, ...) {
  cls <- class(x)
  cli::cli_abort(
    "No method for objects of class{?es}: {cls}."
  )
}

# mc ---------------------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.mc_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  split_args$times <- 1

  split_cal <- internal_calibration_split_core(
    analysis_set,
    split_function = mc_splits,
    split_args = split_args,
    classes = c("mc_split_cal", "internal_calibration_split", class(x))
  )

  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.group_mc_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  split_args$times <- 1

  split_cal <- internal_calibration_split_core(
    analysis_set,
    split_function = group_mc_splits,
    split_args = split_args,
    classes = c("group_mc_split_cal", "internal_calibration_split", class(x))
  )

  split_cal
}


# vfold ------------------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.vfold_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  # TODO should this be done outside of rsample,
  # in workflows or tune?
  if (is.null(split_args$prop)) {
    split_args$prop <- 1 - 1 / split_args$v
  }
  # use mc_splits for a random split
  split_args$times <- 1
  split_args$v <- NULL
  split_args$repeats <- NULL

  split_cal <- internal_calibration_split_core(
    analysis_set,
    split_function = mc_splits,
    split_args = split_args,
    classes = c("vfold_split_cal", "internal_calibration_split", class(x))
  )

  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.group_vfold_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  # TODO should this be done outside of rsample,
  # in workflows or tune?
  if (is.null(split_args$prop)) {
    split_args$prop <- 1 - 1 / split_args$v
  }

  # use group_mc_splits for a random split
  split_args$times <- 1
  split_args$v <- NULL
  split_args$repeats <- NULL
  split_args$balance <- NULL

  split_cal <- internal_calibration_split_core(
    analysis_set,
    split_function = group_mc_splits,
    split_args = split_args,
    classes = c(
      "group_vfold_split_cal",
      "internal_calibration_split",
      class(x)
    )
  )

  split_cal
}


# bootstrap --------------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.boot_split <- function(x, split_args, ...) {
  check_dots_empty()

  # use unique rows to prevent the same information from entering
  # both the inner analysis and inner assessment set
  id_outer_analysis <- unique(x$in_id)
  analysis_set <- x$data[id_outer_analysis, , drop = FALSE]

  split_args$times <- 1
  split_cal <- rlang::try_fetch(
    {
      split_cal <- rlang::inject(
        bootstraps(analysis_set, !!!split_args)
      )
      split_cal <- split_cal$splits[[1]]
    },
    rsample_bootstrap_empty_assessment = function(cnd) {
      return("mock_needed")
    },
    error = function(cnd) {
      return("mock_needed")
    }
  )

  if (identical(split_cal, "mock_needed")) {
    cli::cli_warn(
      "Cannot create calibration split; creating an empty calibration set."
    )
    # with a 0-row calibration set, we can't end up with rows in both
    # calibration and analysis, thus use the full analysis set with duplicate
    # rows here
    analysis_set <- analysis(x)
    split_cal <- internal_calibration_split_mock(analysis_set)
  }

  class_cal <- "boot_split_cal"
  class(split_cal) <- c(class_cal, "internal_calibration_split", class(x))
  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.group_boot_split <- function(x, split_args, ...) {
  check_dots_empty()

  # use unique rows to prevent the same information from entering
  # both the inner analysis and inner assessment set
  id_outer_analysis <- unique(x$in_id)
  analysis_set <- x$data[id_outer_analysis, , drop = FALSE]

  split_args$times <- 1
  split_cal <- rlang::try_fetch(
    {
      split_cal <- rlang::inject(
        group_bootstraps(analysis_set, !!!split_args)
      )
      split_cal <- split_cal$splits[[1]]
    },
    rsample_bootstrap_empty_assessment = function(cnd) {
      return("mock_needed")
    },
    error = function(cnd) {
      return("mock_needed")
    }
  )

  if (identical(split_cal, "mock_needed")) {
    cli::cli_warn(
      "Cannot create calibration split; creating an empty calibration set."
    )
    # with a 0-row calibration set, we can't end up with rows in both
    # calibration and analysis, thus use the full analysis set with duplicate
    # rows here
    analysis_set <- analysis(x)
    split_cal <- internal_calibration_split_mock(analysis_set)
  }

  class_cal <- "group_boot_split_cal"
  class(split_cal) <- c(class_cal, "internal_calibration_split", class(x))
  split_cal
}


# validation set ---------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.val_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  if (length(split_args$prop) == 2) {
    # keep ratio between training and validation as ratio between
    # inner analysis and inner assessment
    split_args$prop <- split_args$prop[[1]] / sum(split_args$prop)
  } else {
    split_args$prop <- split_args$prop[[1]]
  }
  split_args$times <- 1

  split_cal <- internal_calibration_split_core(
    analysis_set,
    split_function = mc_splits,
    split_args = split_args,
    classes = c("val_split_cal", "internal_calibration_split", class(x))
  )

  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.group_val_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  if (length(split_args$prop) == 2) {
    # keep ratio between training and validation as ratio between
    # inner analysis and inner assessment
    split_args$prop <- split_args$prop[[1]] / sum(split_args$prop)
  } else {
    split_args$prop <- split_args$prop[[1]]
  }
  split_args$times <- 1

  split_cal <- internal_calibration_split_core(
    analysis_set,
    split_function = group_mc_splits,
    split_args = split_args,
    classes = c("group_val_split_cal", "internal_calibration_split", class(x))
  )

  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.time_val_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  if (length(split_args$prop) == 2) {
    # keep ratio between training and validation as ratio between
    # inner analysis and inner assessment
    split_args$prop <- split_args$prop[[1]] / sum(split_args$prop)
  } else {
    split_args$prop <- split_args$prop[[1]]
  }

  split_cal <- internal_calibration_split_core(
    analysis_set,
    split_function = initial_time_split,
    split_args = split_args,
    classes = c("time_val_split_cal", "internal_calibration_split", class(x))
  )

  split_cal
}


# clustering -------------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.clustering_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  # TODO: reduce the number of clusters by 1 in tune?
  split_args$repeats <- 1

  split_cal <- internal_calibration_split_core(
    analysis_set,
    split_function = clustering_cv,
    split_args = split_args,
    classes = c(
      "clustering_split_cal",
      "internal_calibration_split",
      class(x)
    )
  )

  split_cal
}


# apparent ---------------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.apparent_split <- function(x, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  split_cal <- apparent(analysis_set)
  split_cal <- split_cal$splits[[1]]

  class_cal <- "apparent_split_cal"
  class(split_cal) <- c(class_cal, "internal_calibration_split", class(x))
  split_cal
}


# slide ------------------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.sliding_window_split <- function(
  x,
  split_args,
  ...
) {
  check_dots_empty()

  analysis_set <- analysis(x)

  if (nrow(analysis_set) < 2) {
    cli::cli_warn(
      "This set cannot be split into an analysis and a calibration set as there 
      is only one row; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(
      analysis_set,
      class = c(
        "sliding_window_split_cal",
        "internal_calibration_split",
        "sliding_window_split"
      )
    )
    return(split_cal)
  }

  split_args_inner <- translate_window_definition(
    split_args$lookback,
    split_args$assess_start,
    split_args$assess_stop
  )

  lookback <- split_args_inner$lookback
  assess_start <- split_args_inner$assess_start
  assess_stop <- split_args_inner$assess_stop

  seq <- vctrs::vec_seq_along(analysis_set)

  id_in <- slider::slide(
    .x = seq,
    .f = identity,
    .before = lookback,
    .after = 0L,
    .step = 1L,
    .complete = split_args$complete
  )

  id_out <- slider::slide(
    .x = seq,
    .f = identity,
    .before = -assess_start,
    .after = assess_stop,
    .step = 1L,
    .complete = TRUE
  )

  indices <- compute_complete_indices(id_in, id_out)

  if (length(indices) < 1) {
    cli::cli_warn(
      "Cannot create calibration split; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(analysis_set)
  } else {
    indices <- indices[[length(indices)]]
    split_cal <- make_splits(
      indices,
      data = analysis_set,
      class = "sliding_window_split"
    )
  }

  # no need to use skip and step args since they don't apply to _within_ an rsplit

  class_cal <- "sliding_window_split_cal"
  class(split_cal) <- c(class_cal, "internal_calibration_split", class(x))
  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.sliding_index_split <- function(x, split_args, ...) {
  check_dots_empty()

  analysis_set <- analysis(x)

  if (nrow(analysis_set) < 2) {
    cli::cli_warn(
      "This set cannot be split into an analysis and a calibration set as there 
      is only one row; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(
      analysis_set,
      class = c(
        "sliding_index_split_cal",
        "internal_calibration_split",
        "sliding_index_split"
      )
    )
    return(split_cal)
  }

  split_args_inner <- translate_window_definition(
    split_args$lookback,
    split_args$assess_start,
    split_args$assess_stop
  )

  lookback <- split_args_inner$lookback
  assess_start <- split_args_inner$assess_start
  assess_stop <- split_args_inner$assess_stop

  loc <- tidyselect::eval_select(split_args$index, analysis_set)
  index <- analysis_set[[loc]]

  seq <- vctrs::vec_seq_along(analysis_set)

  id_in <- slider::slide_index(
    .x = seq,
    .i = index,
    .f = identity,
    .before = lookback,
    .after = 0L,
    .complete = split_args$complete
  )

  id_out <- slider::slide_index(
    .x = seq,
    .i = index,
    .f = identity,
    .before = -assess_start,
    .after = assess_stop,
    .complete = TRUE
  )

  indices <- compute_complete_indices(id_in, id_out)

  if (length(indices) < 1) {
    cli::cli_warn(
      "Cannot create calibration split; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(analysis_set)
  } else {
    indices <- indices[[length(indices)]]
    split_cal <- make_splits(
      indices,
      data = analysis_set,
      class = "sliding_index_split"
    )
  }

  # no need to use skip and step args since they don't apply to _within_ an rsplit

  class_cal <- "sliding_index_split_cal"
  class(split_cal) <- c(class_cal, "internal_calibration_split", class(x))
  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.sliding_period_split <- function(
  x,
  split_args,
  ...
) {
  check_dots_empty()

  analysis_set <- analysis(x)

  if (nrow(analysis_set) < 2) {
    cli::cli_warn(
      "This set cannot be split into an analysis and a calibration set as there 
      is only one row; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(
      analysis_set,
      class = c(
        "sliding_period_split_cal",
        "internal_calibration_split",
        "sliding_period_split"
      )
    )
    return(split_cal)
  }
  if (split_args$lookback < 1) {
    cli::cli_warn(
      "Cannot create calibration split; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(
      analysis_set,
      class = c(
        "sliding_period_split_cal",
        "internal_calibration_split",
        "sliding_period_split"
      )
    )
    return(split_cal)
  }

  split_args_inner <- translate_window_definition(
    split_args$lookback,
    split_args$assess_start,
    split_args$assess_stop
  )

  lookback <- split_args_inner$lookback
  assess_start <- split_args_inner$assess_start
  assess_stop <- split_args_inner$assess_stop

  loc <- tidyselect::eval_select(split_args$index, analysis_set)
  index <- analysis_set[[loc]]

  seq <- vctrs::vec_seq_along(analysis_set)

  id_in <- slider::slide_period(
    .x = seq,
    .i = index,
    .period = split_args$period,
    .f = identity,
    .every = split_args$every,
    .origin = split_args$origin,
    .before = lookback,
    .after = 0L,
    .complete = split_args$complete
  )

  id_out <- slider::slide_period(
    .x = seq,
    .i = index,
    .period = split_args$period,
    .f = identity,
    .every = split_args$every,
    .origin = split_args$origin,
    .before = -assess_start,
    .after = assess_stop,
    .complete = TRUE
  )

  indices <- compute_complete_indices(id_in, id_out)

  if (length(indices) < 1) {
    cli::cli_warn(
      "Cannot create calibration split; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(analysis_set)
  } else {
    indices <- indices[[length(indices)]]
    split_cal <- make_splits(
      indices,
      data = analysis_set,
      class = "sliding_period_split"
    )
  }

  # no need to use skip and step args since they don't apply to _within_ an rsplit

  class_cal <- "sliding_period_split_cal"
  class(split_cal) <- c(class_cal, "internal_calibration_split", class(x))
  split_cal
}

translate_window_definition <- function(lookback, assess_start, assess_stop) {
  length_window <- lookback + 1 + assess_stop
  length_analysis <- lookback + 1

  prop_analysis <- length_analysis / length_window
  prop_assess <- (assess_stop - assess_start + 1) /
    length_window

  length_inner_analysis <- ceiling(prop_analysis * length_analysis)
  length_calibration <- ceiling(prop_assess * length_analysis)
  if (length_inner_analysis + length_calibration > length_analysis) {
    if (length_calibration > 1) {
      length_calibration <- length_calibration - 1
    } else {
      length_inner_analysis <- length_inner_analysis - 1
    }
  }

  lookback <- length_inner_analysis - 1
  assess_stop <- length_analysis - length_inner_analysis
  assess_start <- assess_stop - length_calibration + 1

  lookback <- check_lookback(lookback)
  assess_start <- check_assess(assess_start, "assess_start")
  assess_stop <- check_assess(assess_stop, "assess_stop")
  if (assess_start > assess_stop) {
    cli_abort(
      "{.arg assess_start} must be less than or equal to {.arg assess_stop}."
    )
  }

  list(
    lookback = lookback,
    assess_start = assess_start,
    assess_stop = assess_stop
  )
}


# initial split ----------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.initial_time_split <- function(x, split_args, ...) {
  check_dots_empty()

  training_set <- training(x)

  split_cal <- internal_calibration_split_core(
    training_set,
    split_function = initial_time_split,
    split_args = split_args,
    classes = c(
      "initial_time_split_cal",
      "internal_calibration_split",
      class(x)
    )
  )

  split_cal
}


# initial validation split -----------------------------------------------

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.initial_validation_split <- function(
  x,
  split_args,
  ...
) {
  check_dots_empty()

  training_set <- training(x)

  split_args$prop <- split_args$prop[1] / sum(split_args$prop)
  split_args$times <- 1

  split_cal <- internal_calibration_split_core(
    training_set,
    split_function = mc_splits,
    split_args = split_args,
    classes = c(
      "initial_validation_split_cal",
      "internal_calibration_split",
      "mc_split",
      "rsplit"
    )
  )

  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.group_initial_validation_split <- function(
  x,
  split_args,
  ...
) {
  check_dots_empty()

  training_set <- training(x)

  split_args$prop <- split_args$prop[1] / sum(split_args$prop)
  split_args$times <- 1

  split_cal <- internal_calibration_split_core(
    training_set,
    split_function = group_mc_splits,
    split_args = split_args,
    classes = c(
      "group_initial_validation_split_cal",
      "internal_calibration_split",
      "group_mc_split",
      "mc_split",
      "rsplit"
    )
  )

  split_cal
}

#' @rdname internal_calibration_split
#' @export
internal_calibration_split.initial_validation_time_split <- function(
  x,
  split_args,
  ...
) {
  check_dots_empty()

  training_set <- training(x)

  if (nrow(training_set) < 2) {
    cli::cli_warn(
      "This set cannot be split into a training and a calibration set as there 
      is only one row; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(training_set)
    class_cal <- "initial_validation_time_split_cal"
    class(split_cal) <- c(
      class_cal,
      "internal_calibration_split",
      class(split_cal)
    )
    return(split_cal)
  }

  prop_analysis <- split_args$prop[1] / sum(split_args$prop)
  n_analysis <- floor(nrow(training_set) * prop_analysis)

  analysis_id <- seq(1, n_analysis, by = 1)
  cal_id <- seq(n_analysis + 1, nrow(training_set), by = 1)

  split_cal <- make_splits(
    list(analysis = as.integer(analysis_id), assessment = as.integer(cal_id)),
    data = training_set
  )

  class_cal <- "initial_validation_time_split_cal"
  class(split_cal) <- c(
    class_cal,
    "internal_calibration_split",
    class(split_cal)
  )
  split_cal
}


# helpers ----------------------------------------------------------------

internal_calibration_split_core <- function(
  analysis_set,
  split_function,
  split_args,
  classes
) {
  split_cal <- try(
    {
      split_cal <- rlang::inject(
        split_function(analysis_set, !!!split_args)
      )
      if (!inherits(split_cal, "rsplit")) {
        split_cal <- split_cal$splits[[1]]
      }
      split_cal
    },
    silent = TRUE
  )

  if (inherits(split_cal, "try-error")) {
    cli::cli_warn(
      "Cannot create calibration split; creating an empty calibration set."
    )
    split_cal <- internal_calibration_split_mock(analysis_set)
  }

  class(split_cal) <- classes

  split_cal
}

internal_calibration_split_mock <- function(analysis_set, class = NULL) {
  calibration_set <- analysis_set[0, , drop = FALSE]
  mock_split <- make_splits(analysis_set, calibration_set, class = class)
  mock_split
}

#   ----------------------------------------------------------------------

#' @rdname internal_calibration_split
#' @export
calibration <- function(x, ...) {
  UseMethod("calibration")
}

#' @rdname internal_calibration_split
#' @export
calibration.default <- function(x, ...) {
  cls <- class(x)
  cli::cli_abort(
    "No method for objects of class{?es}: {cls}"
  )
}

#' @rdname internal_calibration_split
#' @export
calibration.internal_calibration_split <- function(x, ...) {
  as.data.frame(x, data = "assessment", ...)
}

#' @rdname internal_calibration_split
#' @export
assessment.internal_calibration_split <- function(x, ...) {
  cli_abort(
    "Internal calibration splits are designed to only return analysis and calibration sets."
  )
}

#' @rdname internal_calibration_split
#' @export
print.internal_calibration_split <- function(x, ...) {
  out_char <-
    if (is_missing_out_id(x)) {
      paste(length(complement(x)))
    } else {
      paste(length(x$out_id))
    }

  cat("<Analysis/Calibration/Total>\n")
  cat("<", length(x$in_id), "/", out_char, "/", nrow(x$data), ">\n", sep = "")
}
