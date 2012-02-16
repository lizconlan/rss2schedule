# rss2schedule

Grabs data from UK Parliament calendar feed RSS, makes an attempt at interpretation of each item before stashing it in a MongoDB store. The HTML component is deliberately light (some might say "poor") as it's mostly there to reassure Heroku that it's a genuine Sinatra app - plus proof of life: if the date's changed, the cron task ran - very light diagnostics, very sloppy HTML (sorry).

Uses the rake cron task to call the parser (named to fit in with Heroku's naming convention with the intention that it should run once daily).

## Installation

(Assumes Ruby 1.9.2)

bundle install

## Disclaimer

As all the data we've seen in the feed so far has been marked up with the parlycal namespace, the straight RSS parser has been practically abandoned and should be treated as unfinished and unreliable. Remains mostly for interest.