---
Title: "Wind Speed Processing"
Project: "Texas & Georgia Agriculture"
Date: "March 4, 2025"
CodeContact: "Nick Grener, grener@gmail.com"

Inputs: "Climate_Regions_Max_Daily_Wind.csv, TX_Districts_Max_Daily_Wind.csv 
Daily maximum wind speed m/s datasets 

Acquired February 23, 2025 from https://app.climateengine.org/climateEngine via:
Make Graph - Native Time Series - One Variable Calculation

Climate_Regions_Max_Daily_Wind.csv was obtained from selecting five US climate divisions corresponding to NASS districts of interest in this study:
GA - Southeast (GA 70)
GA - South Central (GA 80)
GA - Southwest (GA 90)
TX - Trans Pecos (TX 60)
TX - Edwards Plateau (TX 70)
The other NASS districts of interest did not align with US climate divisions, 
so data was obtained at the county level, 4 counties at a time, and later aggregated to the NASS district level

Variable:
Climate & Hydrology - GridMET - 4km - Daily - Wind Speed - Maximum in m / s
Temporal resolution/ coverage: daily / 2015-03-01 to 2024-11-30
Computational spatial resolution: 4000 m (1/24 degree) 

Citation:
Huntington, J., Hegewisch, K., Daudert, B., Morton, C., Abatzoglou, J., McEvoy, D., and T., Erickson. (2017). 
Climate Engine: Cloud Computing of Climate and Remote Sensing Data for Advanced Natural Resource Monitoring and Process Understanding. 
Bulletin of the American Meteorological Society, http://journals.ametsoc.org/doi/abs/10.1175/BAMS-D-15-00324.1"

Outputs: "Max_Wind_By_Day_And_NASS.csv, Max_Wind_By_Half_Month_And_NASS.csv, Max_Wind_By_Month_And_NASS.csv"

Description: "Creates three .csv files representing the maximum wind speed in each NASS District
at the daily, half-monthly, and monthly level"
---

# Load needed packages (use install.packages() first if not already installed)
library(tidyverse)
library(lubridate) 
library(ggplot2)

# Read in main file and convert date to three separate columns
main_max_wind_df <- read_csv("data/Climate_Regions_Max_Daily_Wind.csv") %>%
    mutate(Date = mdy(Date)) %>%
    mutate(Year = year(Date), Month = month(Date), Day = day(Date))
TX_max_wind_df <- read_csv("data/TX_Districts_Max_Daily_Wind.csv") %>%
    mutate(Date = mdy(Date)) %>%
    mutate(Year = year(Date), Month = month(Date), Day = day(Date))

# Join the max wind speed column for each YX district to the main table
main_max_wind_df <- main_max_wind_df %>%
    left_join(select(TX_max_wind_df, Date, TX_12, TX_21, TX_22), by = "Date") 

# Drop all dates that are not of interest and reorganize order of columns
main_max_wind_df <- main_max_wind_df %>%
    filter(!month(Date) %in% c(1, 2, 12)) %>%
    select(Date, Year, Month, Day, everything())

# Confirm that there are no missing values
sum(is.na.data.frame(main_max_wind_df))

# Write data frame to .csv file for further processing in case the analysis that follows changes
write_csv(main_max_wind_df, "outputs/Max_Wind_By_Day_And_NASS.csv")

# Extract maximum value in each month for each district
monthly_max_wind_df <- main_max_wind_df %>%
    group_by(Year, Month) %>% 
    summarise(across(starts_with(c("GA_", "TX_")), \(x) max(x, na.rm = TRUE))) %>%  # Get max per region
    ungroup()

# Pivot longer so that regions are now the rows and drop extraneous columns
monthly_max_wind_df_long <- monthly_max_wind_df %>%
    pivot_longer(cols = starts_with(c("GA_", "TX_")), 
                 names_to = "NASS_District", 
                 values_to = "Max_Wind_Speed") 

# Repeat this process but for half-monthly analysis:
# Extract maximum value in each half-month for each district
half_month_max_wind_df <- main_max_wind_df %>%
    mutate(Half_Month = ifelse(Day <= 15, 1, 2)) %>%  # Create Half-Month column
    group_by(Year, Month, Half_Month) %>%  # Group by Year, Month, Half-Month
    summarise(across(starts_with(c("GA_", "TX_")), \(x) max(x, na.rm = TRUE))) %>%  # Get max per region
    ungroup()

# Make new column for half-months and order appropriately
month_names <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
half_month_max_wind_df <- half_month_max_wind_df %>%
    mutate(Month_Name = month_names[Month],  # Convert Month number to name
        End_Day = ifelse(Month %in% c(4, 6, 9, 11), 30, 31),  # Handle 30-day months
        Interval = factor(
            paste0(Month_Name, " ", ifelse(Half_Month == 1, "1 - 15", paste0("16 - ", End_Day))),
            levels = c("Mar 1 - 15", "Mar 16 - 31", "Apr 1 - 15", "Apr 16 - 30",
                "May 1 - 15", "May 16 - 31", "Jun 1 - 15", "Jun 16 - 30",
                "Jul 1 - 15", "Jul 16 - 31", "Aug 1 - 15", "Aug 16 - 31",
                "Sep 1 - 15", "Sep 16 - 30", "Oct 1 - 15", "Oct 16 - 31",
                "Nov 1 - 15", "Nov 16 - 30"), ordered = TRUE)) 

# Pivot longer so that regions are now the rows and drop extraneous columns
half_month_max_wind_df_long <- half_month_max_wind_df %>%
    pivot_longer(cols = starts_with(c("GA_", "TX_")), 
                 names_to = "NASS_District", 
                 values_to = "Max_Wind_Speed") %>%
    select(-Month, -Half_Month, -Month_Name, -End_Day)

# Write to .csv files
write_csv(monthly_max_wind_df_long, "outputs/Max_Wind_By_Month_And_NASS.csv")
write_csv(half_month_max_wind_df_long, "outputs/Max_Wind_By_Half_Month_And_NASS.csv")
 
