# Big 12 Basketball Recruiting Patterns App

A Shiny R app that visualizes recruiting distance patterns for Big 12 basketball teams.

## Quick Start

### 1. First Time Setup

**Install required packages:**
```r
install.packages(c("shiny","ggplot2","dplyr","scales","stringr","rvest","httr2","jsonlite"))
```

### 2. Scrape Real Data (One Time)

Run the scraper to fetch real recruiting data from on3.com and save it to `recruits_data.csv`:

```r
source('scrape_recruits.R')
```

This will:
- Scrape all 16 Big 12 teams across 2021-2025
- Extract player-level records (player name, hometown, high school, status) from each team's commits page
- Calculate distances from hometown to campus
- Save clean data to `recruits_data.csv`
- Save QA outputs:
  - `recruits_player_qa.csv`
  - `recruits_unmatched_hometowns.csv`
  - `recruits_duplicate_players.csv`

The scraper is respectful to on3.com (1-second delays between requests) and will take ~5-10 minutes to complete.

### 3. Run the App

```r
shiny::runApp('app.R')
```

The app loads instantly from the CSV file.

## Data Workflow

```
scrape_recruits.R
       ↓
recruits_data.csv ← (static data file)
       ↓
   app.R (reads CSV, displays interactively)
```

## File Descriptions

- **app.R** — Main Shiny application (UI + server)
- **scrape_recruits.R** — One-time scraper script that fetches real data
- **recruits_data.csv** — Static data file (created by scraper)
- **recruits_player_qa.csv** — Full player-level table for QA/QC
- **recruits_unmatched_hometowns.csv** — Rows where hometown did not geocode
- **recruits_duplicate_players.csv** — Duplicate player checks by team/year

## Features

- **Year slider:** Filter by recruiting class (2021-2025)
- **Team selection:** Show all or specific teams
- **Display modes:** 
  - Overlay all teams
  - Facet by individual team
- **Distance options:**
  - Highlight local zone (≤300 miles)
  - Exclude international recruits (>4000 miles)
  - Density curve overlay
- **Stats strip:** Live calculations of recruits, medians, and percentages
- **QA/QC table:** Player-level rows under the plot (player, hometown, high school, status, distance)

## Refreshing Data

When you want to update with the latest recruiting data:

```r
source('scrape_recruits.R')
```

Then click "Reload Data" in the app sidebar or refresh your browser.

## Troubleshooting

**"recruits_data.csv not found"**
- Run `source('scrape_recruits.R')` first

**No recruits loading**
- Check internet connection
- on3.com may be blocking requests
- Try again after 10 minutes

**Scraper is slow**
- This is normal (1-2 minutes per team × 16 teams × 5 years)
- Only needs to run once

## Data Notes

- Hometowns are matched to a geographic database of US and international cities
- Distances are calculated using the Haversine formula (great-circle distance in miles)
- Recruits without recognized hometowns are excluded
- Includes some international recruits (Cameroon, Nigeria, Serbia, etc.)
