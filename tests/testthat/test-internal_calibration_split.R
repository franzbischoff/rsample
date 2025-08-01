test_that("informative error messages", {
  expect_snapshot(error = TRUE, {
    internal_calibration_split(NULL)
  })

  # we don't know how manual rsets are constructed,
  # thus we can't provide an internal_calibration_split method
  df <- data.frame(x = c(1, 2, 3, 4, 5, 6))
  indices <- list(
    list(analysis = c(1L, 2L), assessment = 3L),
    list(analysis = c(4L, 5L), assessment = 6L)
  )
  splits <- lapply(indices, make_splits, data = df)
  m_rset <- manual_rset(splits, c("Split 1", "Split 2"))

  expect_snapshot(error = TRUE, {
    internal_calibration_split(m_rset)
  })
})

# mc ---------------------------------------------------------------------

test_that("mc_split", {
  set.seed(11)
  r_set <- mc_cv(warpbreaks)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c("mc_split_cal", "internal_calibration_split", "mc_split", "rsplit"),
    exact = TRUE
  )
})

test_that("mc_split can create mock split", {
  dat <- data.frame(x = 1:2, y = 1:2)

  set.seed(11)
  r_set <- mc_cv(dat, prop = 1 / 2, times = 1)
  split_args <- .get_split_args(r_set)
  # analysis set only contains 1 row, thus can't split further
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c("mc_split_cal", "internal_calibration_split", "mc_split", "rsplit"),
    exact = TRUE
  )
})

test_that("group_mc_split", {
  skip_if_not_installed("modeldata")

  data(ames, package = "modeldata", envir = rlang::current_env())

  set.seed(11)
  r_set <- group_mc_cv(ames, "MS_SubClass")
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "group_mc_split_cal",
      "internal_calibration_split",
      "group_mc_split",
      "mc_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("group_mc_split can create mock split", {
  dat <- data.frame(x = 1:2, y = 1:2, group = c("A", "B"))

  set.seed(11)
  r_set <- group_mc_cv(dat, group = "group", prop = 1 / 2, times = 1)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "group_mc_split_cal",
      "internal_calibration_split",
      "group_mc_split",
      "mc_split",
      "rsplit"
    ),
    exact = TRUE
  )
})


# vfold ------------------------------------------------------------------

test_that("vfold_split", {
  set.seed(11)
  r_set <- vfold_cv(warpbreaks, v = 5)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "vfold_split_cal",
      "internal_calibration_split",
      "vfold_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("vfold_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3)

  set.seed(11)
  r_set <- vfold_cv(dat, v = 2)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "vfold_split_cal",
      "internal_calibration_split",
      "vfold_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("group_vfold_split", {
  skip_if_not_installed("modeldata")

  data(ames, package = "modeldata", envir = rlang::current_env())

  set.seed(11)
  r_set <- group_vfold_cv(ames, "MS_SubClass")
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "group_vfold_split_cal",
      "internal_calibration_split",
      "group_vfold_split",
      "vfold_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("group_vfold_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3, group = c("A", "B", "B"))

  set.seed(11)
  r_set <- group_vfold_cv(dat, group = "group", v = 2)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "group_vfold_split_cal",
      "internal_calibration_split",
      "group_vfold_split",
      "vfold_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

# bootstrap --------------------------------------------------------------

test_that("boot_split", {
  set.seed(11)
  r_set <- bootstraps(warpbreaks, times = 2)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_lte(
    nrow(split_cal$data),
    analysis(r_split) |> nrow()
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[complement(split_cal), ],
    ignore_attr = "row.names"
  )
  expect_s3_class(
    split_cal,
    c("boot_split_cal", "internal_calibration_split", "boot_split", "rsplit"),
    exact = TRUE
  )
})

test_that("boot_split can create mock split", {
  dat <- data.frame(x = 1, y = 1)

  set.seed(11)
  r_set <- bootstraps(dat, times = 1) |> suppressWarnings()
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c("boot_split_cal", "internal_calibration_split", "boot_split", "rsplit"),
    exact = TRUE
  )
})

test_that("group_boot_split", {
  skip_if_not_installed("modeldata")

  data(ames, package = "modeldata", envir = rlang::current_env())

  set.seed(11)
  r_set <- group_bootstraps(ames, group = "MS_SubClass", times = 2)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_lte(
    nrow(split_cal$data),
    analysis(r_split) |> nrow()
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[complement(split_cal), ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "group_boot_split_cal",
      "internal_calibration_split",
      "group_boot_split",
      "boot_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("group_boot_split can create mock split", {
  dat <- data.frame(x = 1:2, y = 1:2, group = c("A", "B"))

  set.seed(11)
  r_set <- group_bootstraps(dat, group = "group", times = 1)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "group_boot_split_cal",
      "internal_calibration_split",
      "group_boot_split",
      "boot_split",
      "rsplit"
    ),
    exact = TRUE
  )
})


# validation set ---------------------------------------------------------

test_that("initial_validation_split", {
  set.seed(11)
  initial_vsplit <- initial_validation_split(
    warpbreaks,
    prop = c(0.6, 0.2)
  )
  r_set <- validation_set(initial_vsplit)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c("val_split_cal", "internal_calibration_split", "val_split", "rsplit"),
    exact = TRUE
  )
})

test_that("val_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3)

  set.seed(11)
  initial_vsplit <- initial_validation_split(dat, prop = c(0.4, 0.33))
  r_set <- validation_set(initial_vsplit)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c("val_split_cal", "internal_calibration_split", "val_split", "rsplit"),
    exact = TRUE
  )
})

test_that("group_initial_validation_split", {
  skip_if_not_installed("modeldata")

  data(ames, package = "modeldata", envir = rlang::current_env())

  set.seed(11)
  initial_vsplit <- group_initial_validation_split(
    ames,
    group = "MS_SubClass",
    prop = c(0.7, 0.2)
  )
  r_set <- validation_set(initial_vsplit)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "group_val_split_cal",
      "internal_calibration_split",
      "group_val_split",
      "val_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("group_val_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3, group = c("A", "B", "C"))

  set.seed(11)
  initial_vsplit <- group_initial_validation_split(
    dat,
    group = "group",
    prop = c(0.4, 0.33)
  )
  r_set <- validation_set(initial_vsplit)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "group_val_split_cal",
      "internal_calibration_split",
      "group_val_split",
      "val_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("initial_validation_time_split", {
  set.seed(11)
  initial_vsplit <- initial_validation_time_split(
    warpbreaks,
    prop = c(0.6, 0.2)
  )
  r_set <- validation_set(initial_vsplit)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "time_val_split_cal",
      "internal_calibration_split",
      "time_val_split",
      "val_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("time_val_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3)

  set.seed(11)
  initial_vsplit <- initial_validation_time_split(dat, prop = c(0.4, 0.33))
  r_set <- validation_set(initial_vsplit)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "time_val_split_cal",
      "internal_calibration_split",
      "time_val_split",
      "val_split",
      "rsplit"
    ),
    exact = TRUE
  )
})


# clustering -------------------------------------------------------------

test_that("clustering_split", {
  set.seed(11)
  r_set <- clustering_cv(warpbreaks, vars = breaks, v = 5)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[-split_cal$in_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "clustering_split_cal",
      "internal_calibration_split",
      "clustering_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("clustering_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3)

  set.seed(11)
  r_set <- clustering_cv(dat, vars = x, v = 2)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "clustering_split_cal",
      "internal_calibration_split",
      "clustering_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

# apparent ---------------------------------------------------------------

test_that("apparent_split", {
  set.seed(11)
  r_set <- apparent(warpbreaks)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split)

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )
  expect_identical(
    calibration(split_cal),
    analysis(r_split)
  )

  expect_s3_class(
    split_cal,
    c(
      "apparent_split_cal",
      "internal_calibration_split",
      "apparent_split",
      "rsplit"
    ),
    exact = TRUE
  )
})


# slide ------------------------------------------------------------------

test_that("sliding_window_split", {
  df <- data.frame(x = 1:10)
  r_set <- sliding_window(df, lookback = 4, assess_start = 3, assess_stop = 5)

  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$in_id,
    1:3
  )
  expect_identical(
    split_cal$out_id,
    4:5
  )

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, , drop = FALSE],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, , drop = FALSE],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "sliding_window_split_cal",
      "internal_calibration_split",
      "sliding_window_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("sliding_window_split needs at least 2 observations", {
  df <- data.frame(x = 1:10)
  r_set <- sliding_window(df, lookback = 0)

  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "sliding_window_split_cal",
      "internal_calibration_split",
      "sliding_window_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("sliding_window_split with incomplete sets", {
  df <- data.frame(x = 1:10)
  r_set <- sliding_window(
    df,
    lookback = 4,
    assess_start = 3,
    assess_stop = 5,
    complete = FALSE
  )

  split_args <- .get_split_args(r_set)

  # not enough observations for a full calibration set and (inner) analysis set
  r_split <- get_rsplit(r_set, 2)
  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  r_split <- get_rsplit(r_set, 3)
  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$in_id,
    1L
  )
  expect_identical(
    split_cal$out_id,
    2:3
  )

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, , drop = FALSE],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, , drop = FALSE],
    ignore_attr = "row.names"
  )
})

test_that("sliding_index_split", {
  df <- data.frame(x = 1:10)
  r_set <- sliding_index(df, x, lookback = 4, assess_start = 3, assess_stop = 5)

  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$in_id,
    1:3
  )
  expect_identical(
    split_cal$out_id,
    4:5
  )

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, , drop = FALSE],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, , drop = FALSE],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "sliding_index_split_cal",
      "internal_calibration_split",
      "sliding_index_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("sliding_index_split can lookback over irregular index", {
  df <- data.frame(x = c(1, 3, 4, 5, 6:10))
  r_set <- sliding_index(df, x, lookback = 4, assess_start = 3, assess_stop = 5)

  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$in_id,
    1:2
  )
  expect_identical(
    split_cal$out_id,
    3:4
  )
})

test_that("sliding_index_split can make calibration set relative to irregular index", {
  df <- data.frame(x = c(1:7, 9:20))
  r_set <- sliding_index(
    df,
    x,
    lookback = 9,
    assess_start = 3,
    assess_stop = 10
  )

  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$in_id,
    1:5
  )
  expect_identical(
    split_cal$out_id,
    7:9
  )
})

test_that("sliding_index_split needs at least 2 observations", {
  df <- data.frame(x = 1:10)
  r_set <- sliding_index(df, x, lookback = 0)

  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "sliding_index_split_cal",
      "internal_calibration_split",
      "sliding_index_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("sliding_index_split with incomplete sets", {
  df <- data.frame(x = 1:10)
  r_set <- sliding_index(
    df,
    x,
    lookback = 4,
    assess_start = 3,
    assess_stop = 5,
    complete = FALSE
  )

  split_args <- .get_split_args(r_set)

  # not enough observations for a full calibration set and (inner) analysis set
  r_split <- get_rsplit(r_set, 2)
  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  r_split <- get_rsplit(r_set, 3)
  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$in_id,
    1L
  )
  expect_identical(
    split_cal$out_id,
    2:3
  )

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, , drop = FALSE],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, , drop = FALSE],
    ignore_attr = "row.names"
  )
})

test_that("sliding_period_split", {
  index <- vctrs::new_date(c(-18, -14, -2, 0, 1, 3:10, 31))
  df <- data.frame(index = index)

  r_set <- sliding_period(df, index, period = "month", lookback = 1)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(
    split_cal$in_id,
    1:3
  )
  expect_identical(
    split_cal$out_id,
    4:13
  )

  expect_identical(
    split_cal$data,
    analysis(r_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, , drop = FALSE],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, , drop = FALSE],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "sliding_period_split_cal",
      "internal_calibration_split",
      "sliding_period_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("sliding_period_split when looking back over multiple periods, only complete ones are used", {
  index <- vctrs::new_date(c(-32, -1, 0, 1, 31))
  df <- data.frame(index = index)

  r_set <- sliding_period(df, index, period = "month", lookback = 1)

  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  split_cal <- internal_calibration_split(r_split, split_args)

  expect_identical(split_cal$in_id, 1L)
  expect_identical(split_cal$out_id, 2L)
})

test_that("sliding_period_split needs at least 2 observations", {
  index <- vctrs::new_date(c(-60, 0, 32))
  df <- data.frame(index = index)

  r_set <- sliding_period(df, index, period = "month", lookback = 1)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "sliding_period_split_cal",
      "internal_calibration_split",
      "sliding_period_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("sliding_period_split needs observations in at least 2 periods", {
  index <- vctrs::new_date(c(-60, 0, 1, 2, 32))
  df <- data.frame(index = index)

  r_set <- sliding_period(df, index, period = "month", lookback = 1)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "sliding_period_split_cal",
      "internal_calibration_split",
      "sliding_period_split",
      "rsplit"
    ),
    exact = TRUE
  )

  index <- vctrs::new_date(c(0, 1, 2, 32))
  df <- data.frame(index = index)

  r_set <- sliding_period(df, index, period = "month", lookback = 0)
  split_args <- .get_split_args(r_set)
  r_split <- get_rsplit(r_set, 1)

  expect_snapshot({
    split_cal <- internal_calibration_split(r_split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    analysis(r_split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "sliding_period_split_cal",
      "internal_calibration_split",
      "sliding_period_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

# initial split ----------------------------------------------------------

test_that("initial_split", {
  set.seed(11)
  car_split <- initial_split(mtcars)
  split_cal <- internal_calibration_split(car_split, .get_split_args(car_split))

  expect_identical(
    split_cal$data,
    training(car_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "mc_split_cal",
      "internal_calibration_split",
      "initial_split",
      "mc_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("group_initial_split", {
  set.seed(11)
  car_split <- group_initial_split(mtcars, cyl)
  split_cal <- internal_calibration_split(car_split, .get_split_args(car_split))

  expect_identical(
    split_cal$data,
    training(car_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "group_mc_split_cal",
      "internal_calibration_split",
      "group_initial_split",
      "initial_split",
      "group_mc_split",
      "mc_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("initial_time_split", {
  set.seed(11)
  car_split <- initial_time_split(mtcars)
  split_cal <- internal_calibration_split(car_split, .get_split_args(car_split))

  expect_identical(
    split_cal$data,
    training(car_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "initial_time_split_cal",
      "internal_calibration_split",
      "initial_time_split",
      "initial_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("initial_time_split can create mock split", {
  dat <- data.frame(x = 1:2, y = 1:2)

  split <- initial_time_split(dat, prop = 0.5)
  split_args <- .get_split_args(split)

  expect_snapshot({
    split_cal <- internal_calibration_split(split, split_args)
  })

  expect_identical(
    analysis(split_cal),
    training(split)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "initial_time_split_cal",
      "internal_calibration_split",
      "initial_time_split",
      "initial_split",
      "rsplit"
    ),
    exact = TRUE
  )
})


# initial validation split -----------------------------------------------

test_that("initial_validation_split", {
  set.seed(11)
  car_split <- initial_validation_split(mtcars)
  split_cal <- internal_calibration_split(car_split, .get_split_args(car_split))

  expect_identical(
    split_cal$data,
    training(car_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "initial_validation_split_cal",
      "internal_calibration_split",
      "mc_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("initial_validation_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3)

  set.seed(11)
  initial_vsplit <- initial_validation_split(dat, prop = c(0.4, 0.33))
  split_args <- .get_split_args(initial_vsplit)

  expect_snapshot({
    split_cal <- internal_calibration_split(initial_vsplit, split_args)
  })

  expect_identical(
    analysis(split_cal),
    training(initial_vsplit)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "initial_validation_split_cal",
      "internal_calibration_split",
      "mc_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("group_initial_validation_split", {
  skip_if_not_installed("modeldata")
  data(ames, package = "modeldata", envir = rlang::current_env())

  set.seed(12)
  ames_split <- group_initial_validation_split(ames, group = Neighborhood)
  split_cal <- internal_calibration_split(
    ames_split,
    .get_split_args(ames_split)
  )

  expect_identical(
    split_cal$data,
    training(ames_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "group_initial_validation_split_cal",
      "internal_calibration_split",
      "group_mc_split",
      "mc_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("group_initial_validation_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3, group = c("A", "B", "C"))

  set.seed(11)
  initial_vsplit <- group_initial_validation_split(
    dat,
    group = "group",
    prop = c(0.4, 0.33)
  )
  split_args <- .get_split_args(initial_vsplit)

  expect_snapshot({
    split_cal <- internal_calibration_split(initial_vsplit, split_args)
  })

  expect_identical(
    analysis(split_cal),
    training(initial_vsplit)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "group_initial_validation_split_cal",
      "internal_calibration_split",
      "group_mc_split",
      "mc_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("initial_validation_time_split", {
  skip_if_not_installed("modeldata")
  data(drinks, package = "modeldata", envir = rlang::current_env())

  set.seed(12)
  drinks_split <- initial_validation_time_split(drinks)
  split_cal <- internal_calibration_split(
    drinks_split,
    .get_split_args(drinks_split)
  )

  expect_identical(
    split_cal$data,
    training(drinks_split)
  )

  expect_identical(
    analysis(split_cal),
    split_cal$data[split_cal$in_id, ],
    ignore_attr = "row.names"
  )
  expect_identical(
    calibration(split_cal),
    split_cal$data[split_cal$out_id, ],
    ignore_attr = "row.names"
  )

  expect_s3_class(
    split_cal,
    c(
      "initial_validation_time_split_cal",
      "internal_calibration_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

test_that("initial_validation_time_split can create mock split", {
  dat <- data.frame(x = 1:3, y = 1:3)

  set.seed(11)
  initial_vsplit <- initial_validation_time_split(dat, prop = c(0.4, 0.33))
  split_args <- .get_split_args(initial_vsplit)

  expect_snapshot({
    split_cal <- internal_calibration_split(initial_vsplit, split_args)
  })

  expect_identical(
    analysis(split_cal),
    training(initial_vsplit)
  )

  expect_identical(
    nrow(calibration(split_cal)),
    0L
  )

  expect_s3_class(
    split_cal,
    c(
      "initial_validation_time_split_cal",
      "internal_calibration_split",
      "rsplit"
    ),
    exact = TRUE
  )
})

# mock split -------------------------------------------------------------

test_that("can create a mock split", {
  mock_split <- internal_calibration_split_mock(
    mtcars,
    class = "internal_calibration_split"
  )
  mock_analysis <- analysis(mock_split)
  mock_calibration <- calibration(mock_split)

  expect_identical(mock_analysis, mtcars)
  expect_identical(nrow(mock_calibration), 0L)

  expect_s3_class(mock_split, "rsplit")

  mock_split <- internal_calibration_split_mock(mtcars, class = "mock_class")
  expect_s3_class(mock_split, "mock_class")
})

#   ----------------------------------------------------------------------

test_that("assessment() fails", {
  internal_calibration_split <- internal_calibration_split_mock(
    mtcars,
    class = "internal_calibration_split"
  )

  expect_snapshot(error = TRUE, {
    assessment(internal_calibration_split)
  })
})

test_that("print()", {
  internal_calibration_split <- internal_calibration_split_mock(
    mtcars,
    class = "internal_calibration_split"
  )

  expect_snapshot(
    print(internal_calibration_split)
  )
})
