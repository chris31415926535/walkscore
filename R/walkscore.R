
# HTTP Response	Status Code	Description
# 200	1	Walk Score successfully returned.
# 200	2	Score is being calculated and is not currently available.
# 404	30	Invalid latitude/longitude.
# 500 series	31	Walk Score API internal error.
# 200	40	Your WSAPIKEY is invalid.
# 200	41	Your daily API quota has been exceeded.
# 403	42	Your IP address has been blocked.

#' Get Walk Scores from the Walk Score API
#'
#' This package provides a tidy interface to the Walk Score API, a proprietary
#' API that measures a location's "walkability" using a number between 0 and 100.
#'
#' The Walk Score API has a free tier which allows 5,000 API calls per day, and
#' paid tiers with higher limits.
#'
#' This function makes it easy to spread your API calls out over a few days. When
#' you call the function for the first time, if necessary it creates a new column
#' of walks cores and assigns each row `NA`. Then, each row's walk score is populated
#' as the function gets a good API response. The function breaks automatically
#' upon detecting a rate limit, returning all results collected so far. When your
#' rate limit resets and you call the function again, it picks up from the first
#' `NA` walk score it finds and continues on. So make sure to save your results
#' after each batch, but you don't need to keep track of fine-grained batch issues
#' or worry about losing a whole batch if a response errors out--the function
#' handles that for you.
#'
#' You'll need a valid Walk Score API key to use this package.
#'
#' **Please Note** neither this package nor its author are affiliated with Walk
#' Score in any way, nor are any warranties made about this package or any data
#' available through the Walk Score API. "Walk Score" is copyrighted and a
#' registered trademark of its owner, *again, with whom we are not affiliated*.
#'
#' API documentation is available here: [https://www.walkscore.com/professional/api.php](https://www.walkscore.com/professional/api.php)
#'
#' @param df A `tibble` with columns named `lat` and `lon` containing latitude and longitude respectively.
#' @param apikey Character. A valid Walk Score API key.
#' @param polite_pause Numeric. The number of seconds to pause between API calls. Default is 0.2.
#' @param verbose Boolean. Should we print lots of info to the console?
#'
#' @return The input `tibble` with new columns containing Walk Score API responses.
#' @examples \dontrun{
#' df <- data.frame(lat = 45.378791, lon = -75.662508)
#' df <- walkscore::walkscore(df, apikey = "your api key")
#' }
#' @export
walkscore <- function(df, apikey, polite_pause = 0.2, verbose = FALSE){

  # if we don't have any walkscores yet, add a column of NA values.
  # we'll use NA values to figure out which rows we need to process
  if (!"walkscore" %in% colnames(df)) df$walkscore <- NA

  # loop through each row
  for (i in 1:nrow(df)) {

    if (verbose) message("Row ", i)

    # if this row has a valid walkscore skip it
    if (!is.na(df[i,]$walkscore)) {
      if (verbose) message("  Skipping! We already have a walkscore for this row.")
      next
    }

    if (verbose) message("  Trying to get walk score...")

    api_result <- try({

      url <- sprintf("https://api.walkscore.com/score?format=json&lat=%s&lon=%s&transit=1&bike=1&wsapikey=%s&address=%s", df[i,]$lat, df[i,]$lon, apikey, "")
      api_response <- httr::GET(url)

      # get http status: did api call work at all?
      http_status <- api_response$status_code

      if (http_status == 200){

        if (verbose) message("  Success! HTTP 200 response..")

        api_response_content <- httr::content(api_response)

        # set up a default API response object, in case we error on the first try
        result <- api_response

        # if we got a good walkscore, format the results
        if (api_response_content$status == 1){

          if (verbose) message("  Success again! A valid walk score...")

          result <- api_response_content |>
            unlist() |>
            dplyr::as_tibble(rownames = "name") |>
            tidyr::pivot_wider(names_from = "name", values_from = "value") |>
            dplyr::select(-dplyr::any_of(c("more_info_icon", "more_info_link", "help_link", "logo_url")))

        } # end if api_response_content$status == 1


        if (api_response_content$status != 1){

          if (verbose) message("  Failure! Didn't get a valid walk score...")

          class(result) <- c(class(result), "error")

          # handle other conditions where we get good HTTP response but another kind of error
          if (api_response_content$status == "40")  class(result) <- c(class(result), "keyinvalid", "break")
          if (api_response_content$status == "41")  class(result) <- c(class(result), "ratelimit", "break")
          if (api_response_content$status == "42")  class(result) <- c(class(result), "ipblocked", "break")

        } # end if api_response_content$status != 1

      } # end if http_status == 200

      if (http_status != 200) {

        if (verbose) message("  Failure! An invalid HTTP response..")

        # we got some other kind of http error
        result <- api_response
        class(result) <- c(class(result), "error", "httperror", "break")

      } # end if http_status != 200

      result
    })

    # if we didn't get an error, add the data
    if (!"error" %in% class(api_result)){

      # add all the new info to the row in question
      # using base R so that it will create columns if they're not there yet
      # not worried about types here because it will coerce.
      # we set applicable columns to numeric at the end, before returning final results
      for (colname in colnames(result)) df[i,colname] <- result[,colname]

    }

    # if we did get an error, deal with that here
    if ("error" %in% class(api_result)){

      warning(sprintf("Bad API response processing row %s.", i))

      # if we got an error so bad we need to break, then break
      # e.g. rate limit, invalid API key, ip blocked
      if ("break" %in% class(api_result)) {

        # default details gives all of the API key info.
        warning_details <- {
          step1 <- unlist(api_result)
          step2 <- paste0(names(step1),": ", step1)
          step3 <- paste0(step2, collapse="\n")
          paste0("**********************\nAPI Reponse Details:\n", step3)
        }

        # add helpful info if we got a helpful status code
        if ("ratelimit" %in% class(api_result)) warning_details <- sprintf("Rate limit reached. No more API calls possible until rate limit resets.\n%s", warning_details)
        if ("keyinvalid" %in% class(api_result)) warning_details <- sprintf("Invalid API key. Have you signed up for a Walkscore API key?\n%s", warning_details)
        if ("ipblocked" %in% class(api_result)) warning_details <- sprintf("IP address blocked.\n%s", warning_details)

        warning(warning_details)

        break
      }

    }

    # do a polite pause
    Sys.sleep(polite_pause)

  } # end for (i in 1:nrow(df))


  # set any applicable columns to numeric
  df$walkscore <- as.numeric(df$walkscore)
  if ("bike.score" %in% colnames(df)) df$bike.score <- as.numeric(df$bike.score)
  if ("snapped_lon" %in% colnames(df)) df$snapped_lon <- as.numeric(df$snapped_lon)
  if ("snapped_lat" %in% colnames(df)) df$snapped_lat <- as.numeric(df$snapped_lat)

  return(df)
}



