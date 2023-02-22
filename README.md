
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Get Walk Scores from the Walk Score API

<!-- badges: start -->

[![R-CMD-check](https://github.com/chris31415926535/walkscore/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chris31415926535/walkscore/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This package provides a tidy interface to the Walk Score API, a
proprietary API that measures a location’s “walkability” using a number
between 0 and 100.

The Walk Score API has a free tier which allows 5,000 API calls per day,
and paid tiers with higher limits.

This function makes it easy to spread your API calls out over a few
days. When you call the function for the first time, if necessary it
creates a new column of walks cores and assigns each row `NA`. Then,
each row’s walk score is populated as the function gets a good API
response. The function breaks automatically upon detecting a rate limit,
returning all results collected so far. When your rate limit resets and
you call the function again, it picks up from the first `NA` walk score
it finds and continues on. So make sure to save your results after each
batch, but you don’t need to keep track of fine-grained batch issues or
worry about losing a whole batch if a response errors out–the function
handles that for you.

You’ll need a valid Walk Score API key to use this package.

**Please Note** neither this package nor its author are affiliated with
Walk Score in any way, nor are any warranties made about this package or
any data available through the Walk Score API. “Walk Score” is
copyrighted and a registered trademark of its owner, *again, with whom
we are not affiliated*.

API documentation is available here:
<https://www.walkscore.com/professional/api.php>

## Installation

You can install the development version of walkscore like so:

``` r
devtools::install_github("https://github.com/chris31415926535/walkscore")
```

## Example

``` r

library(dplyr)
library(walkscore)

your_apikey <- "put a real API key here"

test_data <- dplyr::tibble(lat = 45.420193, lon = -75.697796) |>
  walkscore::walkscore(apikey = your_apikey)
```
