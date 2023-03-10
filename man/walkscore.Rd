% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/walkscore.R
\name{walkscore}
\alias{walkscore}
\title{Get Walk Scores from the Walk Score API}
\usage{
walkscore(df, apikey, polite_pause = 0.2, verbose = FALSE)
}
\arguments{
\item{df}{A \code{tibble} with columns named \code{lat} and \code{lon} containing latitude and longitude respectively.}

\item{apikey}{Character. A valid Walk Score API key.}

\item{polite_pause}{Numeric. The number of seconds to pause between API calls. Default is 0.2.}

\item{verbose}{Boolean. Should we print lots of info to the console?}
}
\value{
The input \code{tibble} with new columns containing Walk Score API responses.
}
\description{
This package provides a tidy interface to the Walk Score API, a proprietary
API that measures a location's "walkability" using a number between 0 and 100.
}
\details{
The Walk Score API has a free tier which allows 5,000 API calls per day, and
paid tiers with higher limits.

This function makes it easy to spread your API calls out over a few days. When
you call the function for the first time, if necessary it creates a new column
of walks cores and assigns each row \code{NA}. Then, each row's walk score is populated
as the function gets a good API response. The function breaks automatically
upon detecting a rate limit, returning all results collected so far. When your
rate limit resets and you call the function again, it picks up from the first
\code{NA} walk score it finds and continues on. So make sure to save your results
after each batch, but you don't need to keep track of fine-grained batch issues
or worry about losing a whole batch if a response errors out--the function
handles that for you.

You'll need a valid Walk Score API key to use this package.

\strong{Please Note} neither this package nor its author are affiliated with Walk
Score in any way, nor are any warranties made about this package or any data
available through the Walk Score API. "Walk Score" is copyrighted and a
registered trademark of its owner, \emph{again, with whom we are not affiliated}.

API documentation is available here: \url{https://www.walkscore.com/professional/api.php}
}
\examples{
\dontrun{
df <- data.frame(lat = 45.378791, lon = -75.662508)
df <- walkscore::walkscore(df, apikey = "your api key")
}
}
