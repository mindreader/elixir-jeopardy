# elixir-jeopardy
A jeopardy question scraper and server.

## Scraper

Questions are gently scraped from j-archive.com and then can be indexed by category and written out to disk.  There are about 60000 questions available, which is the last several years of jeopardy.  Questions involving pictures or audio have had them stripped out as they are usually not available to be scraped in the first place.

## API

When the server starts it reads the category index and keeps them in memory so that it can grab a random category quickly, but fetches questions from disk on demand because there are so many.  Categories are picked randomly but they are weighted so that categories with more questions tend to come up more often.

There are only two exposed at the moment

1. /categories/random - get a random category
2. /questions/bycategory/:category - get all questions in that category

## Frontend

The frontend is written in reactjs.  Fonts are free fonts that are reasonably similar to the actual jeopardy fonts.
