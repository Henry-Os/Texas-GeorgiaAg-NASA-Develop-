# Load needed libraries
library(tidyverse)
library(dplyr)
library(readr)
library(lubridate)
library(stringr)

# Establish integer vector of years of interest
years <- 2015:2024

# Establish empty data frames with the appropriate column types to
# hold data as each year gets processed
GA_benchmarks <- data.frame(Year = integer(), NASS_District= character(),
                            Avg_Emergence = numeric(), Avg_First_Square = numeric(),
                            Ang_First_Flower = numeric(), Avg_Open_Boll = numeric(),
                            Avg_Harvest = numeric())
TX_benchmarks <- data.frame(Year = integer(), NASS_District= character(),
                            Avg_Emergence = numeric(), Avg_First_Square = numeric(),
                            Ang_First_Flower = numeric(), Avg_Open_Boll = numeric(),
                            Avg_Harvest = numeric())
GA_monthly <- data.frame(Year = integer(), Month = integer(), NASS_District= character(),
                         Dist_Avg_GDD = numeric())
TX_monthly <- data.frame(Year = integer(), Month = integer(), NASS_District= character(),
                         Dist_Avg_GDD = numeric())

# Make a one-to-one matching data frame of county names to NASS District for each state
GA_county_to_district <- tibble::tibble(
    County = c("Baker", "Calhoun", "Clay", "Decatur", "Dougherty", "Early", "Grady",
               "Lee", "Miller", "Mitchell", "Quitman", "Randolph", "Seminole", "Stewart",
               "Sumter", "Terrell", "Thomas", "Webster", "Atkinson", "Ben Hill", "Berrien",
               "Brooks", "Clinch", "Coffee", "Colquitt", "Cook", "Crisp", "Dooly", "Echols",
               "Irwin", "Jeff Davis", "Lanier", "Lowndes", "Telfair", "Tift", "Turner", 
               "Wilcox", "Worth", "Appling", "Bacon", "Brantley", "Bryan", "Camden", 
               "Charlton", "Chatham", "Evans", "Glynn", "Liberty", "Long", "McIntosh",
               "Pierce", "Tattnall", "Ware", "Wayne"),  
    NASS_District = c(rep("GA_70", 18),
                      rep("GA_80", 20),
                      rep("GA_90", 16)))

TX_county_to_district <- tibble::tibble(
    County = c("Andrews", "Bailey", "Cochran", "Crosby", "Dawson", "Gaines", "Glasscock",
               "Hockley", "Howard", "Lamb", "Lubbock", "Lynn", "Martin", "Midland",
               "Terry", "Yoakum", "Borden", "Childress", "Collingsworth", "Cottle", "Dickens",
               "Donley", "Foard", "Garza", "Hall", "Hardeman", "Kent", "King", "Motley",
               "Wheeler", "Wichita", "Wilbarger", "Baylor", "Coleman", "Fisher", "Haskell",
               "Jones", "Knox", "Mitchell", "Nolan", "Runnels", "Scurry", "Stonewall", "Taylor",
               "Brewster", "Crane", "Culberson", "Ector", "El Paso", "Hudspeth", "Jeff Davis",
               "Loving", "Pecos", "Presidio", "Reeves", "Terrell", "Ward", "Winkler",
               "Bandera", "Blanco", "Burnet", "Coke", "Concho", "Crockett", "Edwards",
               "Gillespie", "Irion", "Kendall", "Kerr", "Kimble", "Kinney", "Lampasas",
               "Llano", "McCulloch", "Mason", "Menard", "Reagan", "Real", "San Saba",
               "Schleicher", "Sterling", "Sutton", "Tom Green", "Upton", "Uvalde", "Val Verde"),  
    NASS_District = c(rep("TX_12", 16),
                      rep("TX_21", 16),
                      rep("TX_22", 12),
                      rep("TX_60", 14),
                      rep("TX_70", 28)))

# This for loop goes through each year's data in Georgia and finds the average date (expressed as 
# an integer representing the day of the calendar year) in each district at which certain
# growth benchmarks are met by averaging the relevant county dates at which those benchmarks are met

for(year in years) {
    source.path <- paste0("data/GA_PRISM/DD60-GA-", year, ".csv")
    # Skip header lines
    DD_60 <- read_csv(source.path, skip = 10)
    # Rename columns for clarity
    DD_60 <- DD_60 %>% 
        filter(!is.na(Name)) %>%
        rename(County = "Name", tmin = "tmin (degrees F)",
           tmax = "tmax (degrees F)", tmean = "tmean (degrees F)",
           DD60pos = "DD60 (positive)", CumDD60 = "Cumulative DD60") %>%
        select(-"Elevation (ft)") %>%
        # Extract the name of each county (drop "County")
        mutate(County = str_extract(County, ".*(?= C)")) %>%
        # Date manipulation, including expression of each calendar date as a day of the year (1 through 365)
        mutate(Date = mdy(Date)) %>%
        mutate(DayOfYear = yday(Date))

    # Group GDD data by county and find the date of the year at which the benchmarks are met;
    # if the GDD do not aggregate to that benchmark, put in NA as a flag.
    # Benchmarks obtained from https://www.cropscience.bayer.us/articles/dad/cotton-growth-and-development
    County_benchmarks <- DD_60 %>%
        group_by(County) %>%
        summarize(EmergenceDOY = ifelse(any(CumDD60 > 50), DayOfYear[which(CumDD60 > 50)[1]], NA), 
              SquareDOY = ifelse(any(CumDD60 > 500), DayOfYear[which(CumDD60 > 500)[1]], NA), 
              FlowerDOY = ifelse(any(CumDD60 > 800), DayOfYear[which(CumDD60 > 800)[1]], NA), 
              OpenBollDOY = ifelse(any(CumDD60 > 1800), DayOfYear[which(CumDD60 > 1800)[1]], NA),
              HarvestDOY = ifelse(any(CumDD60 > 2400), DayOfYear[which(CumDD60 > 2400)[1]], NA), .groups = "drop") %>%
        ungroup()

    # Join NASS Districts to counties 
    County_benchmarks <- County_benchmarks %>%
        left_join(GA_county_to_district, by = "County") %>%
        relocate(NASS_District, .after = "County")
    
    # Group by NASS District and average the day of the year calculations from above across each district
    District_benchmarks <- County_benchmarks %>%
        group_by(NASS_District) %>%
        summarize(Avg_Emergence = mean(EmergenceDOY),
              Avg_First_Square = mean(SquareDOY),
              Avg_First_Flower = mean(FlowerDOY),
              Avg_Open_Boll = mean(OpenBollDOY),
              Avg_Harvest = mean(HarvestDOY))
    
    # Fill in the Year column with the current year being processed and prepare for binding to master df
    District_benchmarks$Year <- rep(year, 3)
    District_benchmarks <- District_benchmarks %>%
        relocate(Year, .before = everything())
    District_benchmarks <- District_benchmarks %>% 
        mutate_if(is.numeric, round, digits = 1)
    
    # Bind to the relevant data from previous years
    GA_benchmarks <- rbind(GA_benchmarks, District_benchmarks)
}

# Write to .csv
# write.csv(GA_benchmarks, "GA_benchmarks.csv", row.names = FALSE)

# This loop does the same thing for Texas; the one exception that needed to be addressed differently is that
# Collingsworth County exceeded the column size and caused problems so it is formatted to match 
# the other counties for the county name extraction step
for(year in years) {
    source.path <- paste0("data/TX_PRISM/DD60-TX-", year, ".csv")
    DD_60 <- read_csv(source.path, skip = 10)
    DD_60 <- DD_60 %>%
        mutate(Name = str_replace_all(Name, "Collingswort", "Collingsworth C"))
    DD_60 <- DD_60 %>% 
        filter(!is.na(Name)) %>%
        rename(County = "Name", tmin = "tmin (degrees F)",
               tmax = "tmax (degrees F)", tmean = "tmean (degrees F)",
               DD60pos = "DD60 (positive)", CumDD60 = "Cumulative DD60") %>%
        select(-"Elevation (ft)") %>%
        mutate(County = str_extract(County, ".*(?= C)")) %>%
        mutate(Date = mdy(Date)) %>%
        mutate(DayOfYear = yday(Date))
    County_benchmarks <- DD_60 %>%
        group_by(County) %>%
        summarize(EmergenceDOY = ifelse(any(CumDD60 > 50), DayOfYear[which(CumDD60 > 50)[1]], NA),
                  SquareDOY = ifelse(any(CumDD60 > 500), DayOfYear[which(CumDD60 > 500)[1]], NA),
                  FlowerDOY = ifelse(any(CumDD60 > 800), DayOfYear[which(CumDD60 > 800)[1]], NA),
                  OpenBollDOY = ifelse(any(CumDD60 > 1800), DayOfYear[which(CumDD60 > 1800)[1]], NA),
                  HarvestDOY = ifelse(any(CumDD60 > 2400), DayOfYear[which(CumDD60 > 2400)[1]], NA), .groups = "drop") %>%
        ungroup()
    
    County_benchmarks <- County_benchmarks %>%
        left_join(TX_county_to_district, by = "County") %>%
        relocate(NASS_District, .after = "County")
    
    District_benchmarks <- County_benchmarks %>%
        group_by(NASS_District) %>%
        summarize(Avg_Emergence = mean(EmergenceDOY),
                  Avg_First_Square = mean(SquareDOY),
                  Avg_First_Flower = mean(FlowerDOY),
                  Avg_Open_Boll = mean(OpenBollDOY),
                  Avg_Harvest = mean(HarvestDOY))
    
    District_benchmarks$Year <- rep(year, nrow(District_benchmarks))
    District_benchmarks <- District_benchmarks %>%
        relocate(Year, .before = everything())
    District_benchmarks <- District_benchmarks %>%
        mutate_if(is.numeric, round, digits = 1)
    
    TX_benchmarks <- rbind(TX_benchmarks, District_benchmarks)
}

# Write to .csv
# write.csv(TX_benchmarks, "TX_benchmarks.csv", row.names = FALSE)

# This loop takes a different approach; for each year in Georgia, we sum up the GDD accumulated in each county 
# during each calendar month.  Then that sum is averaged across all counties in the district
# to get a measure of the average GDD experienced across that district in the month.
# Finally, these values are accumulated during each year to get an average cumulative
# GDD value in each district up to the end of any given month.

for(year in years) {
    source.path <- paste0("data/GA_PRISM/DD60-GA-", year, ".csv")
    # Skip header lines
    DD_60 <- read_csv(source.path, skip = 10)
    # Rename columns for clarity
    DD_60 <- DD_60 %>% 
        filter(!is.na(Name)) %>%
        rename(County = "Name", tmin = "tmin (degrees F)",
               tmax = "tmax (degrees F)", tmean = "tmean (degrees F)",
               DD60pos = "DD60 (positive)", CumDD60 = "Cumulative DD60") %>%
        select(-"Elevation (ft)") %>%
        # Extract the name of each county (drop "County")
        mutate(County = str_extract(County, ".*(?= C)")) %>%
        # Date manipulation, including expression of each calendar date as a day of the year (1 through 365)
        mutate(Date = mdy(Date)) %>%
        mutate(DayOfYear = yday(Date))
    
    # Group by county and month and sum up the GDD for the month
    Monthly_totals <- DD_60 %>%
        mutate(Month = month(Date)) %>% 
        group_by(County, Month) %>%
        summarize(Total_DD60pos = sum(DD60pos, na.rm = TRUE), .groups = "drop") %>%
        ungroup()
    
    # Join NASS Districts to counties
    Monthly_totals <- Monthly_totals %>%
        left_join(GA_county_to_district, by = "County") %>%
        relocate(NASS_District, .after = "County")
    
    # Now group by NASS district & month and find the average of the GDD sums in 
    # all counties for that month 
    District_averages <- Monthly_totals %>%
        group_by(NASS_District, Month) %>%
        summarize(Dist_Avg_GDD = mean(Total_DD60pos))
    
    # Fill in the Year column with the current year being processed and prepare for binding to master df
    District_averages$Year <- rep(year, 27)
    District_averages <- District_averages %>%
        relocate(c(Year, Month), .before = everything())
    District_averages <- District_averages %>% 
        mutate_if(is.numeric, round, digits = 1)
    
    # Bind to the relevant data from previous years
    GA_monthly <- rbind(GA_monthly, District_averages)
}

# Add a column that sums up the cumulative GDD in the district up to the end
# of each month. The district average values are used for this cumulatuve sum.
GA_monthly <- GA_monthly %>%
    group_by(Year, NASS_District) %>%
    mutate(Cum_Avg_GDD = cumsum(Dist_Avg_GDD)) %>%
    ungroup()

# Write to .csv
# write.csv(GA_monthly, "GA_monthly.csv", row.names = FALSE)

# Repeat for Texas across all years:
for(year in years) {
    source.path <- paste0("data/TX_PRISM/DD60-TX-", year, ".csv")
    DD_60 <- read_csv(source.path, skip = 10)
    DD_60 <- DD_60 %>%
        mutate(Name = str_replace_all(Name, "Collingswort", "Collingsworth C"))
    DD_60 <- DD_60 %>% 
        filter(!is.na(Name)) %>%
        rename(County = "Name", tmin = "tmin (degrees F)",
               tmax = "tmax (degrees F)", tmean = "tmean (degrees F)",
               DD60pos = "DD60 (positive)", CumDD60 = "Cumulative DD60") %>%
        select(-"Elevation (ft)") %>%
        mutate(County = str_extract(County, ".*(?= C)")) %>%
        mutate(Date = mdy(Date)) %>%
        mutate(DayOfYear = yday(Date))
    
    Monthly_totals <- DD_60 %>%
        mutate(Month = month(Date)) %>% 
        group_by(County, Month) %>%
        summarize(Total_DD60pos = sum(DD60pos, na.rm = TRUE), .groups = "drop") %>%
        ungroup()
    
    Monthly_totals <- Monthly_totals %>%
        left_join(TX_county_to_district, by = "County") %>%
        relocate(NASS_District, .after = "County")
    
    District_averages <- Monthly_totals %>%
        group_by(NASS_District, Month) %>%
        summarize(Dist_Avg_GDD = mean(Total_DD60pos))
    
    District_averages$Year <- rep(year, 45)
    District_averages <- District_averages %>%
        relocate(c(Year, Month), .before = everything())
    District_averages <- District_averages %>% 
        mutate_if(is.numeric, round, digits = 1)
    
    TX_monthly <- rbind(TX_monthly, District_averages)
}

TX_monthly <- TX_monthly %>%
    group_by(Year, NASS_District) %>%
    mutate(Cum_Avg_GDD = cumsum(Dist_Avg_GDD)) %>%
    ungroup()

# Write to .csv
# write.csv(TX_monthly, "TX_monthly.csv", row.names = FALSE)

