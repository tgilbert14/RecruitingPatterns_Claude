# Recruiting Patterns

Big 12 basketball recruiting distance analysis app built in Shiny.

## What This App Does

- Loads Big 12 basketball recruiting records from local CSV artifacts
- Computes and visualizes hometown-to-campus distance patterns
- Uses a hero box plot as the primary comparison view
- Provides supplemental histogram and QA/QC table views

## Run Locally

1. Open the project in RStudio (or VS Code with R support).
2. Ensure required packages are installed (shiny, ggplot2, dplyr, scales, stringr, rvest, httr, jsonlite).
3. Launch the app:

```r
shiny::runApp("app.R")
```

## Data Workflow

- Main app data file: `recruits_data.csv`
- Logo mapping file: `team_logo_urls.csv`
- Local logo assets: `www/logos/`

If data needs refresh, run the scraper script and regenerate CSV artifacts.

## UI Documentation

- In-app help is available in the `How To Read This` supplemental tab.
- Additional UI/interpretation notes are in `UI_GUIDE.md`.
