# ============================================================
#  One-time Scraper for Big 12 Basketball Recruiting Data
#  Saves to recruits_data.csv for use in the app
# ============================================================

library(rvest)
library(httr2)
library(dplyr)
library(stringr)

# ── Campus coordinates (lat, lon) ─────────────────────────
campus_coords <- list(
    "Arizona"        = c(32.2319, -110.9501),
    "Arizona State"  = c(33.4242, -111.9281),
    "Baylor"         = c(31.5489, -97.1131),
    "BYU"            = c(40.2518, -111.6493),
    "Cincinnati"     = c(39.1329, -84.5150),
    "Colorado"       = c(40.0076, -105.2659),
    "Houston"        = c(29.7174, -95.3412),
    "Iowa State"     = c(42.0267, -93.6465),
    "Kansas"         = c(38.9543, -95.2558),
    "Kansas State"   = c(39.1836, -96.5717),
    "Oklahoma State" = c(36.1269, -97.0682),
    "TCU"            = c(32.7096, -97.3640),
    "Texas Tech"     = c(33.5843, -101.8783),
    "UCF"            = c(28.6024, -81.2001),
    "Utah"           = c(40.7649, -111.8421),
    "West Virginia"  = c(39.6350, -79.9542)
)

# ── City → (lat,lon) lookup table ────────────────────────
city_db <- list(
    # Texas
    "Houston, TX" = c(29.760, -95.370), "Dallas, TX" = c(32.776, -96.797),
    "San Antonio, TX" = c(29.425, -98.494), "Austin, TX" = c(30.266, -97.750),
    "Fort Worth, TX" = c(32.725, -97.321), "El Paso, TX" = c(31.761, -106.487),
    "Lubbock, TX" = c(33.577, -101.856), "Amarillo, TX" = c(35.222, -101.831),
    "Waco, TX" = c(31.549, -97.146), "Tyler, TX" = c(32.351, -95.302),
    "Beaumont, TX" = c(30.086, -94.102), "Corpus Christi, TX" = c(27.800, -97.397),
    "Midland, TX" = c(31.997, -102.078), "Odessa, TX" = c(31.845, -102.368),
    "Plano, TX" = c(33.020, -96.699), "Arlington, TX" = c(32.736, -97.108),
    "Laredo, TX" = c(27.506, -99.507), "Pasadena, TX" = c(29.691, -95.209),
    "Mesquite, TX" = c(32.764, -96.599), "McAllen, TX" = c(26.204, -98.230),
    "Killeen, TX" = c(31.117, -97.728), "Pearland, TX" = c(29.563, -95.286),
    "Frisco, TX" = c(33.150, -96.823), "Richardson, TX" = c(32.948, -96.729),
    "Garland, TX" = c(32.913, -96.638), "Irving, TX" = c(32.814, -96.949),
    "Stephenville, TX" = c(32.220, -98.202),
    # Southeast
    "Atlanta, GA" = c(33.749, -84.388), "Charlotte, NC" = c(35.227, -80.843),
    "Raleigh, NC" = c(35.779, -78.638), "Durham, NC" = c(35.994, -78.899),
    "Greensboro, NC" = c(36.073, -79.792), "Winston-Salem, NC" = c(36.100, -80.244),
    "Memphis, TN" = c(35.149, -90.052), "Nashville, TN" = c(36.166, -86.784),
    "Knoxville, TN" = c(35.961, -83.921), "Chattanooga, TN" = c(35.045, -85.309),
    "Jacksonville, FL" = c(30.332, -81.656), "Orlando, FL" = c(28.538, -81.379),
    "Miami, FL" = c(25.761, -80.192), "Tampa, FL" = c(27.948, -82.458),
    "Tallahassee, FL" = c(30.438, -84.281), "Gainesville, FL" = c(29.651, -82.325),
    "Fort Lauderdale, FL" = c(26.122, -80.143), "West Palm Beach, FL" = c(26.715, -80.064),
    "Hialeah, FL" = c(25.858, -80.278), "St. Petersburg, FL" = c(27.773, -82.640),
    "Miami Gardens, FL" = c(25.942, -80.246), "Palm Bay, FL" = c(28.035, -80.589),
    "Birmingham, AL" = c(33.521, -86.803), "Huntsville, AL" = c(34.730, -86.586),
    "Mobile, AL" = c(30.696, -88.043), "Montgomery, AL" = c(32.361, -86.279),
    "Jackson, MS" = c(32.299, -90.184), "Gulfport, MS" = c(30.367, -89.095),
    "New Orleans, LA" = c(29.951, -90.071), "Baton Rouge, LA" = c(30.443, -91.187),
    "Shreveport, LA" = c(32.526, -93.749), "Lafayette, LA" = c(30.224, -92.020),
    "Savannah, GA" = c(32.080, -81.099), "Macon, GA" = c(32.841, -83.633),
    "Columbia, SC" = c(34.000, -81.035), "Greenville, SC" = c(34.852, -82.399),
    "Charleston, SC" = c(32.776, -79.931),
    # Midwest
    "Chicago, IL" = c(41.878, -87.630), "Rockford, IL" = c(42.271, -89.094),
    "Peoria, IL" = c(40.694, -89.589), "Joliet, IL" = c(41.526, -88.082),
    "Champaign, IL" = c(40.117, -88.244), "Springfield, IL" = c(39.801, -89.644),
    "Indianapolis, IN" = c(39.768, -86.158), "Fort Wayne, IN" = c(41.130, -85.129),
    "Evansville, IN" = c(37.975, -87.556), "Kokomo, IN" = c(40.487, -86.134),
    "Columbus, OH" = c(39.961, -82.999), "Cleveland, OH" = c(41.499, -81.695),
    "Cincinnati, OH" = c(39.103, -84.512), "Toledo, OH" = c(41.663, -83.555),
    "Akron, OH" = c(41.081, -81.519), "Canton, OH" = c(40.798, -81.379),
    "Dayton, OH" = c(39.759, -84.192),
    "Detroit, MI" = c(42.332, -83.046), "Grand Rapids, MI" = c(42.966, -85.656),
    "Flint, MI" = c(43.013, -83.688), "Lansing, MI" = c(42.733, -84.556),
    "Warren, MI" = c(42.492, -83.027), "Ann Arbor, MI" = c(42.281, -83.748),
    "Milwaukee, WI" = c(43.039, -87.907), "Madison, WI" = c(43.073, -89.401),
    "Green Bay, WI" = c(44.519, -88.020), "Oshkosh, WI" = c(44.025, -88.543),
    "Minneapolis, MN" = c(44.978, -93.265), "St. Paul, MN" = c(44.955, -93.102),
    "Rochester, MN" = c(44.023, -92.470), "Duluth, MN" = c(46.786, -92.101),
    "Kansas City, MO" = c(39.099, -94.578), "St. Louis, MO" = c(38.627, -90.199),
    "Springfield, MO" = c(37.215, -93.298), "Branson, MO" = c(36.644, -93.218),
    "Omaha, NE" = c(41.257, -96.004), "Lincoln, NE" = c(40.813, -96.703),
    "Sioux Falls, SD" = c(43.549, -96.700), "Fargo, ND" = c(46.877, -96.789),
    "Des Moines, IA" = c(41.600, -93.609), "Cedar Rapids, IA" = c(42.008, -91.645),
    "Wichita, KS" = c(37.692, -97.337), "Overland Park, KS" = c(38.982, -94.671),
    "Oklahoma City, OK" = c(35.467, -97.517), "Tulsa, OK" = c(36.154, -95.993),
    "Norman, OK" = c(35.221, -97.440), "Broken Arrow, OK" = c(36.061, -95.791),
    "Little Rock, AR" = c(34.746, -92.290), "Fayetteville, AR" = c(36.062, -94.158),
    # Northeast
    "New York, NY" = c(40.713, -74.006), "Brooklyn, NY" = c(40.650, -73.950),
    "Bronx, NY" = c(40.845, -73.865), "Queens, NY" = c(40.728, -73.795),
    "Yonkers, NY" = c(40.931, -73.899), "Syracuse, NY" = c(43.048, -76.147),
    "Buffalo, NY" = c(42.887, -78.879), "Rochester, NY" = c(43.158, -77.616),
    "Albany, NY" = c(42.651, -73.755), "Farmingdale, NY" = c(40.732, -73.443),
    "Glen Head, NY" = c(40.845, -73.628),
    "Philadelphia, PA" = c(39.952, -75.165), "Pittsburgh, PA" = c(40.440, -79.996),
    "Allentown, PA" = c(40.602, -75.470), "Lancaster, PA" = c(40.038, -76.306),
    "Harrisburg, PA" = c(40.274, -76.884),
    "Newark, NJ" = c(40.735, -74.172), "Jersey City, NJ" = c(40.729, -74.077),
    "Boston, MA" = c(42.360, -71.058), "Worcester, MA" = c(42.263, -71.802),
    "Springfield, MA" = c(42.101, -72.590), "Lynn, MA" = c(42.467, -70.944),
    "Hartford, CT" = c(41.764, -72.685), "Bridgeport, CT" = c(41.179, -73.190),
    "Waterbury, CT" = c(41.558, -73.052),
    "Providence, RI" = c(41.824, -71.413),
    "Washington, DC" = c(38.907, -77.037), "Baltimore, MD" = c(39.290, -76.612),
    "Richmond, VA" = c(37.541, -77.436), "Virginia Beach, VA" = c(36.853, -75.978),
    "Norfolk, VA" = c(36.851, -76.291), "Chesapeake, VA" = c(36.769, -76.287),
    "Hampton, VA" = c(37.031, -76.345),
    # Mountain/West
    "Denver, CO" = c(39.739, -104.984), "Colorado Springs, CO" = c(38.834, -104.822),
    "Aurora, CO" = c(39.729, -104.832), "Lakewood, CO" = c(39.705, -105.082),
    "Pueblo, CO" = c(38.255, -104.609),
    "Phoenix, AZ" = c(33.448, -112.074), "Tucson, AZ" = c(32.221, -110.969),
    "Mesa, AZ" = c(33.415, -111.831), "Chandler, AZ" = c(33.307, -111.841),
    "Tempe, AZ" = c(33.425, -111.940), "Scottsdale, AZ" = c(33.494, -111.926),
    "Las Vegas, NV" = c(36.175, -115.137), "Henderson, NV" = c(36.040, -114.982),
    "North Las Vegas, NV" = c(36.199, -115.117), "Reno, NV" = c(39.529, -119.814),
    "Salt Lake City, UT" = c(40.760, -111.891), "Provo, UT" = c(40.233, -111.658),
    "Ogden, UT" = c(41.223, -111.974), "St. George, UT" = c(37.104, -113.584),
    "Albuquerque, NM" = c(35.085, -106.651), "Santa Fe, NM" = c(35.687, -105.938),
    "Boise, ID" = c(43.615, -116.202), "Meridian, ID" = c(43.612, -116.392),
    "Spokane, WA" = c(47.659, -117.426), "Seattle, WA" = c(47.607, -122.332),
    "Tacoma, WA" = c(47.253, -122.445), "Bellevue, WA" = c(47.611, -122.192),
    "Portland, OR" = c(45.523, -122.676), "Eugene, OR" = c(44.051, -123.087),
    # California
    "Los Angeles, CA" = c(34.052, -118.244), "San Diego, CA" = c(32.715, -117.157),
    "San Jose, CA" = c(37.339, -121.894), "San Francisco, CA" = c(37.775, -122.419),
    "Fresno, CA" = c(36.737, -119.787), "Sacramento, CA" = c(38.582, -121.494),
    "Long Beach, CA" = c(33.770, -118.194), "Oakland, CA" = c(37.804, -122.271),
    "Bakersfield, CA" = c(35.373, -119.019), "Anaheim, CA" = c(33.836, -117.915),
    "Santa Ana, CA" = c(33.746, -117.868), "Riverside, CA" = c(33.954, -117.395),
    "Stockton, CA" = c(37.958, -121.291), "Modesto, CA" = c(37.640, -120.997),
    "Oxnard, CA" = c(34.197, -119.177), "Moreno Valley, CA" = c(33.937, -117.230),
    "Pomona, CA" = c(34.055, -117.752), "Torrance, CA" = c(33.836, -118.341),
    "Pasadena, CA" = c(34.148, -118.144), "Compton, CA" = c(33.896, -118.220),
    "Santa Maria, CA" = c(34.952, -120.436), "Napa, CA" = c(38.297, -122.286),
    "Castaic, CA" = c(34.489, -118.628), "Inglewood, CA" = c(33.962, -118.353),
    # Other US
    "Anchorage, AK" = c(61.218, -149.900), "Honolulu, HI" = c(21.307, -157.858),
    "Louisville, KY" = c(38.252, -85.758), "Lexington, KY" = c(38.040, -84.459),
    "Fayetteville, NC" = c(35.053, -78.879), "Asheville, NC" = c(35.579, -82.554),
    "Gary, IN" = c(41.593, -87.347), "South Bend, IN" = c(41.676, -86.252),
    "Athens, GA" = c(33.960, -83.378), "Augusta, GA" = c(33.471, -81.975),
    "Murfreesboro, TN" = c(35.846, -86.390), "Clarksville, TN" = c(36.530, -87.359),
    "Lake City, MN" = c(44.449, -92.268),
    # International / cities without state
    "Kinshasa" = c(-4.322, 15.322), "Kinshasa, Congo" = c(-4.322, 15.322),
    "Yaoundé" = c(3.867, 11.517), "Cameroon" = c(3.848, 11.502),
    "Rome, Rome" = c(41.902, 12.496), "Rome, Italy" = c(41.902, 12.496),
    "Montreal, QC" = c(45.501, -73.568), "Edmonton, AB" = c(53.546, -113.490),
    "Vancouver, BC" = c(49.246, -123.117), "Toronto, ON" = c(43.653, -79.383),
    "Germany" = c(51.166, 10.452), "Berlin, Germany" = c(52.520, 13.405),
    "France" = c(46.227, 2.213), "Paris, France" = c(48.857, 2.352),
    "Nigeria" = c(9.082, 8.675), "Lagos, Nigeria" = c(6.455, 3.384),
    "Senegal" = c(14.497, -14.452), "Australia" = c(-25.274, 133.775),
    "Spain" = c(40.463, -3.749), "Serbia" = c(44.017, 21.006),
    "Croatia" = c(45.100, 15.202), "Bahamas" = c(25.025, -77.980),
    "Jamaica" = c(18.110, -77.297),
    "Helsinki" = c(60.170, 24.938), "Helsinki, Finland" = c(60.170, 24.938),
    "Helsinski" = c(60.170, 24.938),
    "Hickory, NC" = c(35.729, -81.338)
)

# ── Haversine distance (miles) ────────────────────────────
haversine <- function(lat1, lon1, lat2, lon2) {
    R <- 3958.8
    phi1 <- lat1 * pi / 180
    phi2 <- lat2 * pi / 180
    dphi <- (lat2 - lat1) * pi / 180
    dlam <- (lon2 - lon1) * pi / 180
    a <- sin(dphi / 2)^2 + cos(phi1) * cos(phi2) * sin(dlam / 2)^2
    2 * R * asin(pmin(1, sqrt(a)))
}

# ── Geocode a hometown string ─────────────────────────────
clean_hometown <- function(x) {
    if (is.na(x) || nchar(trimws(x)) == 0) {
        return(NA_character_)
    }

    cleaned <- x %>%
        str_replace_all("<!--|-->", "") %>%
        str_replace_all("<[^>]+>", "") %>%
        str_replace_all("&nbsp;", " ") %>%
        str_replace_all("\\s+", " ") %>%
        str_trim()

    cleaned <- str_replace_all(cleaned, "^,+|,+$", "")

    if (nchar(cleaned) == 0) {
        return(NA_character_)
    }
    cleaned
}

geocode_city <- function(hometown) {
    hometown <- clean_hometown(hometown)
    if (is.na(hometown) || nchar(trimws(hometown)) == 0) {
        return(NULL)
    }
    key <- trimws(hometown)
    if (!is.null(city_db[[key]])) {
        return(city_db[[key]])
    }
    key2 <- str_replace_all(key, "[()]", "") %>% trimws()
    if (!is.null(city_db[[key2]])) {
        return(city_db[[key2]])
    }
    parts <- str_split(key2, ",")[[1]]
    if (length(parts) >= 2) {
        k3 <- paste0(trimws(parts[1]), ", ", trimws(parts[2]))
        if (!is.null(city_db[[k3]])) {
            return(city_db[[k3]])
        }
    }
    NULL
}

# ── Compute distances ─────────────────────────────────────
add_distances <- function(df) {
    campus <- campus_coords
    df %>%
        rowwise() %>%
        mutate(
            coords = list(geocode_city(hometown)),
            ht_lat = if (!is.null(coords)) coords[1] else NA_real_,
            ht_lon = if (!is.null(coords)) coords[2] else NA_real_,
            camp_lat = campus[[team]][1],
            camp_lon = campus[[team]][2],
            distance_miles = if (!is.na(ht_lat)) {
                haversine(ht_lat, ht_lon, camp_lat, camp_lon)
            } else {
                NA_real_
            }
        ) %>%
        ungroup() %>%
        filter(!is.na(distance_miles)) %>%
        select(team, year, hometown, distance_miles)
}

# ── Scrape one page from on3.com ──────────────────────────
scrape_on3_page <- function(team, year, slug, verbose = TRUE) {
    url <- sprintf(
        "https://www.on3.com/college/%s/basketball/%d/commits/",
        slug, year
    )
    if (verbose) cat(sprintf("  %-20s %d ... ", team, year))

    tryCatch(
        {
            resp <- request(url) |>
                req_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36") |>
                req_headers(
                    "Accept-Language" = "en-US,en;q=0.9",
                    "Accept" = "text/html,application/xhtml+xml"
                ) |>
                req_timeout(25) |>
                req_perform()

            if (resp_status(resp) != 200) {
                cat("HTTP", resp_status(resp), "\n")
                return(NULL)
            }
            html_text <- resp_body_string(resp)

            # Try multiple extraction strategies
            hometowns <- character(0)

            # Strategy 1: regex for Hometown patterns
            m1 <- str_match_all(
                html_text,
                "Hometown[^(]*\\(([^)]{2,50})\\)"
            )[[1]]
            if (nrow(m1) > 0) hometowns <- c(hometowns, m1[, 2])

            # Strategy 2: JSON data embedded in page
            if (length(hometowns) == 0) {
                m2 <- str_match_all(
                    html_text,
                    '"hometown"[^:]*:\\s*"([^"]{2,50})"'
                )[[1]]
                if (nrow(m2) > 0) hometowns <- c(hometowns, m2[, 2])
            }

            # Strategy 3: rvest parsing
            if (length(hometowns) == 0) {
                page <- read_html(html_text)
                dts <- page %>%
                    html_nodes("dt") %>%
                    html_text(trim = TRUE)
                dds <- page %>%
                    html_nodes("dd") %>%
                    html_text(trim = TRUE)
                ht_idx <- which(str_detect(dts, "(?i)hometown"))
                if (length(ht_idx) > 0 && max(ht_idx) <= length(dds)) {
                    hometowns <- dds[ht_idx]
                }
            }

            hometowns <- vapply(hometowns, clean_hometown, character(1))
            hometowns <- hometowns[!is.na(hometowns) & nchar(trimws(hometowns)) > 1]
            hometowns <- unique(trimws(hometowns))

            if (length(hometowns) == 0) {
                cat("0 recruits\n")
                return(NULL)
            }

            cat(length(hometowns), "recruits\n")
            data.frame(
                team = team, year = year, hometown = hometowns,
                stringsAsFactors = FALSE
            )
        },
        error = function(e) {
            cat("ERROR:", e$message, "\n")
            NULL
        }
    )
}

# ── Main scraping loop ───────────────────────────────────
cat("===============================================\n")
cat("BIG 12 BASKETBALL RECRUITING SCRAPER\n")
cat("Source: on3.com\n")
cat("Target: recruits_data.csv\n")
cat("===============================================\n\n")

team_slugs <- c(
    "Arizona"        = "arizona-wildcats",
    "Arizona State"  = "arizona-state-sun-devils",
    "Baylor"         = "baylor-bears",
    "BYU"            = "byu-cougars",
    "Cincinnati"     = "cincinnati-bearcats",
    "Colorado"       = "colorado-buffaloes",
    "Houston"        = "houston-cougars",
    "Iowa State"     = "iowa-state-cyclones",
    "Kansas"         = "kansas-jayhawks",
    "Kansas State"   = "kansas-state-wildcats",
    "Oklahoma State" = "oklahoma-state-cowboys",
    "TCU"            = "tcu-horned-frogs",
    "Texas Tech"     = "texas-tech-red-raiders",
    "UCF"            = "ucf-knights",
    "Utah"           = "utah-utes",
    "West Virginia"  = "west-virginia-mountaineers"
)

years <- 2021:2025
rows <- list()
total <- length(years) * length(team_slugs)
n <- 0

cat("Scraping", length(team_slugs), "teams across", length(years), "years...\n")
cat("Total requests:", total, "\n\n")

for (yr in years) {
    cat("YEAR", yr, ":\n")
    for (team in names(team_slugs)) {
        n <- n + 1
        pg <- scrape_on3_page(team, yr, team_slugs[[team]])
        if (!is.null(pg) && nrow(pg) > 0) {
            rows[[length(rows) + 1]] <- pg
        }
        Sys.sleep(1) # Be respectful: 1 second between requests
    }
    cat("\n")
}

# ── Combine and compute distances ──────────────────────────
if (length(rows) == 0) {
    stop("No data scraped. Check network/site access.")
}

cat("Processing data...\n")
raw_data <- bind_rows(rows)
cat("  Raw recruits:", nrow(raw_data), "\n")

final_data <- add_distances(raw_data)
cat("  With valid distances:", nrow(final_data), "\n")

# ── Save to CSV ────────────────────────────────────────────
output_file <- "recruits_data.csv"
write.csv(final_data, output_file, row.names = FALSE)
cat("\n✓ Saved to", output_file, "\n")
cat("  File size:", format(file.size(output_file), units = "auto"), "\n")

# ── Summary stats ──────────────────────────────────────────
cat("\n=== SUMMARY STATS ===\n")
cat("Total recruits:", nrow(final_data), "\n")
cat("Year range:", min(final_data$year), "–", max(final_data$year), "\n")
cat("Teams represented:", n_distinct(final_data$team), "\n")
cat("Median distance:", round(median(final_data$distance_miles)), "miles\n")
cat("Mean distance:", round(mean(final_data$distance_miles)), "miles\n")
cat("\nDistance by team:\n")
print(final_data %>%
    group_by(team) %>%
    summarise(n = n(), med_dist = round(median(distance_miles))) %>%
    arrange(desc(n)))
