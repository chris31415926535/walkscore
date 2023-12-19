
<!-- README.md is generated from README.Rmd. Please edit that file -->

# A Tidy Interface to the ‘Walk Score’ API

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

## A Note about *NA* API Responses

**If you receive many NA responses, try waiting a few minutes and
repeating your query.** When you query the Walkscore API for specific
lat/lon value, it *seems* that it returns cached values if they exist,
or otherwise calculates new values. However, in at least some cases, the
API seems to return an invalid/nonexistent result to your query *while
it is calculating your requested value on the server*.

So if you are querying regions that are new to Walkscore you will
receive NA results the first time, but if you query again later
Walkscore may have calculated those results and added them to its cache.

Unfortunately this is a server-side issue and this package can’t fix it:
we can only parse the responses the server gives us, and the
`polite_pause` parameter is for adding delays between API calls whatever
their result may be.

**Another reminder that I am not affiliated with Walkscore!**

## Related Projects

See also the package `walkscoreAPI` [available on
CRAN](https://cran.r-project.org/package=walkscoreAPI). Compared to
`walkscoreAPI`, the current package `walkscore` has advantages for some
use cases:

1.  `walkscore` uses data frames for inputs and outputs and adheres to
    “tidy” design princniples; `walkscoreAPI` works on single values and
    provides output as a list.
2.  `walkscore` handles batching automatically for data frame inputs;
    `walkscoreAPI` does not.
3.  `walkscore` automatically handles API failures if you hit your rate
    limit by returning the results so far, and will pick up where it
    left off if you re-feed the output into it again once your rate
    limit resets; `walkscoreAPI` has no such functionality.

However, `walkscoreAPI` may be simpler if you only need to find a few
values, or if you have a professional/enterprise API key with higher
usage limits and you want to run a large volume of API calls in
parallel.

`walkscoreAPI` also has a number of helper functions, whereas
`walkscore` is focused entirely on accessing the Walk Score API.
