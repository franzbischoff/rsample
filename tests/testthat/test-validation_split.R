test_that("`validation_split()` is deprecated", {
  dat1 <- data.frame(a = 1:20, b = letters[1:20], c = rep(1:4, 5))

  expect_snapshot({
    set.seed(11)
    rs1 <- validation_split(dat1)
    sizes1 <- dim_rset(rs1)

    expect_true(all(sizes1$analysis == 15))
    expect_true(all(sizes1$assessment == 5))
  })
})

test_that("default param", {
  withr::local_options(lifecycle_verbosity = "quiet")

  set.seed(11)
  rs1 <- validation_split(dat1)
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis == 15))
  expect_true(all(sizes1$assessment == 5))
  same_data <-
    purrr::map_lgl(rs1$splits, function(x) {
      all.equal(x$data, dat1)
    })
  expect_true(all(same_data))

  good_holdout <- purrr::map_lgl(
    rs1$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("`validation_time_split()` is deprecated", {
  dat1 <- data.frame(a = 1:20, b = letters[1:20], c = rep(1:4, 5))

  expect_snapshot({
    set.seed(11)
    rs1 <- validation_time_split(dat1)
    sizes1 <- dim_rset(rs1)

    expect_true(all(sizes1$analysis == 15))
    expect_true(all(sizes1$assessment == 5))
  })
})

test_that("default time param", {
  withr::local_options(lifecycle_verbosity = "quiet")

  set.seed(11)
  rs1 <- validation_time_split(dat1)
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis == 15))
  expect_true(all(sizes1$assessment == 5))
  same_data <-
    purrr::map_lgl(rs1$splits, function(x) {
      all.equal(x$data, dat1)
    })
  expect_true(all(same_data))

  good_holdout <- purrr::map_lgl(
    rs1$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
  tr1 <- training(rs1$splits[[1]])
  expect_equal(nrow(tr1), floor(nrow(dat1) * 3 / 4))
  expect_equal(tr1, dplyr::slice(dat1, 1:floor(nrow(dat1) * 3 / 4)))
})

test_that("default time param with lag", {
  withr::local_options(lifecycle_verbosity = "quiet")

  skip_if_not_installed("modeldata")
  data(drinks, package = "modeldata")

  rs1 <- validation_time_split(dat1, lag = 5)
  expect_s3_class(rs1, "validation_split")
  tr1 <- training(rs1$splits[[1]])
  expect_equal(nrow(tr1), floor(nrow(dat1) * 3 / 4))
  expect_equal(tr1, dplyr::slice(dat1, 1:floor(nrow(dat1) * 3 / 4)))

  expect_snapshot(validation_time_split(drinks))
  expect_snapshot(validation_time_split(drinks, lag = 12.5), error = TRUE)
  expect_snapshot(validation_time_split(drinks, lag = 500), error = TRUE)
})

test_that("assessment set of time split includes the lag (#376)", {
  withr::local_options(lifecycle_verbosity = "quiet")

  toy_data <- data.frame(id = 1:100)
  val_rset <- validation_time_split(toy_data, prop = 0.75, lag = 2)
  dat_assess <- assessment(val_rset$splits[[1]])
  expect_equal(dat_assess$id, 74:100)
})

test_that("`group_validation_split()` is deprecated", {
  dat1 <- data.frame(a = 1:20, b = letters[1:20], c = rep(1:4, 5))

  expect_snapshot({
    set.seed(11)
    rs1 <- group_validation_split(dat1, c)
    sizes1 <- dim_rset(rs1)

    expect_true(all(sizes1$analysis == 15))
    expect_true(all(sizes1$assessment == 5))
  })
})

test_that("default group param", {
  withr::local_options(lifecycle_verbosity = "quiet")

  set.seed(11)
  rs1 <- group_validation_split(dat1, c)
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis == 15))
  expect_true(all(sizes1$assessment == 5))
  same_data <-
    purrr::map_lgl(rs1$splits, function(x) {
      all.equal(x$data, dat1)
    })
  expect_true(all(same_data))

  good_holdout <- purrr::map_lgl(
    rs1$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("grouping -- strata", {
  withr::local_options(lifecycle_verbosity = "quiet")

  set.seed(11)

  n_common_class <- 70
  n_rare_class <- 30

  group_table <- tibble(
    group = 1:100,
    outcome = sample(c(rep(0, n_common_class), rep(1, n_rare_class)))
  )
  observation_table <- tibble(
    group = sample(1:100, 5e4, replace = TRUE),
    observation = 1:5e4
  )
  sample_data <- dplyr::full_join(
    group_table,
    observation_table,
    by = "group",
    multiple = "all"
  )
  rs4 <- group_validation_split(sample_data, group, strata = outcome)
  sizes4 <- dim_rset(rs4)
  expect_snapshot(sizes4)

  rate <- purrr::map_dbl(
    rs4$splits,
    function(x) {
      dat <- as.data.frame(x)$outcome
      mean(dat == "1")
    }
  )
  expect_equal(mean(rate), 0.3, tolerance = 1e-2)

  good_holdout <- purrr::map_lgl(
    rs4$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("different percent", {
  withr::local_options(lifecycle_verbosity = "quiet")

  set.seed(11)
  rs2 <- validation_split(dat1, prop = .5)
  sizes2 <- dim_rset(rs2)

  expect_true(all(sizes2$analysis == 10))
  expect_true(all(sizes2$assessment == 10))
  same_data <-
    purrr::map_lgl(rs2$splits, function(x) {
      all.equal(x$data, dat1)
    })
  expect_true(all(same_data))

  good_holdout <- purrr::map_lgl(
    rs2$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))

  set.seed(11)
  rs2_group <- group_validation_split(dat1, c, prop = .5)
  sizes2_group <- dim_rset(rs2_group)

  expect_true(all(sizes2_group$analysis == 10))
  expect_true(all(sizes2_group$assessment == 10))
  same_data <-
    purrr::map_lgl(rs2_group$splits, function(x) {
      all.equal(x$data, dat1)
    })
  expect_true(all(same_data))

  good_holdout <- purrr::map_lgl(
    rs2_group$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("strata", {
  withr::local_options(lifecycle_verbosity = "quiet")

  set.seed(11)
  rs3 <- validation_split(warpbreaks, strata = "tension")
  sizes3 <- dim_rset(rs3)

  expect_true(all(sizes3$analysis == 39))
  expect_true(all(sizes3$assessment == 15))

  rate <- purrr::map_dbl(
    rs3$splits,
    function(x) {
      dat <- as.data.frame(x)$tension
      mean(dat == "M")
    }
  )
  expect_true(length(unique(rate)) == 1)

  good_holdout <- purrr::map_lgl(
    rs3$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("bad args", {
  withr::local_options(lifecycle_verbosity = "quiet")

  expect_snapshot(error = TRUE, {
    validation_split(mtcars, prop = 1)
  })
  expect_snapshot(error = TRUE, {
    validation_time_split(mtcars, prop = 1)
  })
  expect_snapshot(error = TRUE, {
    group_validation_split(mtcars, group = "cyl", prop = 1)
  })

  expect_snapshot(error = TRUE, {
    validation_split(warpbreaks, strata = warpbreaks$tension)
  })
  expect_snapshot(error = TRUE, {
    validation_split(warpbreaks, strata = c("tension", "wool"))
  })
})

test_that("printing", {
  withr::local_options(lifecycle_verbosity = "quiet")

  expect_snapshot(validation_split(warpbreaks))
  expect_snapshot(validation_split(warpbreaks)$splits[[1]])
})

test_that("rsplit labels", {
  withr::local_options(lifecycle_verbosity = "quiet")

  rs <- validation_split(mtcars)
  all_labs <- purrr::map(rs$splits, labels) |>
    list_rbind()
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})
