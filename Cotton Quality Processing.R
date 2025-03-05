---
Title: "Cotton Quality Processing"
Project: "Texas & Georgia Agriculture"
Date: "March 4, 2025"
CodeContact: "Nick Grener, grener@gmail.com"

Inputs: "Must run Python script to get Cotton quality data from the web first, which
will establish the needed folders of USDA data that give the quality of every bale
processed in the districts and years of interest."
Outputs: "TX_quality_summary_data.csv, GA_quality_summary_data.csv"

Description: 
"Averages out the seven cotton quality measures at the seasonal and NASS district level."
---

# Load needed libraries"
library(tidyverse)
library(readr)
library(dplyr)

# Establish vector of years of interest and empty df to hold summary data
years_of_interest <- 2015:2024
TX_quality_summary_data <- data.frame(Year = integer(), NASS_District = character(), n_bales = integer(), Avg_Mike = numeric(), 
                                      Avg_Strength = numeric(), Avg_HVI_RD = numeric(),Avg_HVI_b = numeric(), 
                                      Avg_Trash_Percent = numeric(), Avg_Length = numeric(), Avg_Uniformity = numeric())
GA_quality_summary_data <- data.frame(Year = integer(), NASS_District = character(), n_bales = integer(), Avg_Mike = numeric(), 
                                      Avg_Strength = numeric(), Avg_HVI_RD = numeric(),Avg_HVI_b = numeric(), 
                                      Avg_Trash_Percent = numeric(), Avg_Length = numeric(), Avg_Uniformity = numeric())


# This approach calculates summary statistics on each week's worth of data for Texas, keeping track of how 
# many bales are represented in that week in each district. Then at the end a weighted average is 
# used to calculate summary statistics on the full data for the year. 
# This is much faster than gathering all of the bales for the year in one place first, 
# then calculating summary statistics on the full data set.
for (year in years_of_interest) {
    # Find folder for this year and create list of weekly file names
    Qual_folder <- paste0("TexasQuality/", year, " Crop/")  
    Qual_files <- list.files(Qual_folder, pattern = ".csv", full.names = FALSE)
    # Set up a blank data frame to hold all of the data for this year
    Annual_summary_data <- data.frame(Year = integer(), NASS_District = character(), n = integer(), Avg_Mike = numeric(), 
                                          Avg_Strength = numeric(), Avg_HVI_RD = numeric(),Avg_HVI_b = numeric(), 
                                          Avg_Trash_Percent = numeric(), Avg_Length = numeric(), Avg_Uniformity = numeric())
    # Run through every week's file, pull out just the variables of interest first
    for (week in Qual_files) {
        Weekly_data_raw <- read_csv(paste0(Qual_folder, week))
        Weekly_data <- Weekly_data_raw %>%
            select("MIKE", "Strength", "HVI Color RD", "HVI Color +b", "Trash % Surface",
                   "Length 100ths", "Length Uniformity", "State-NASS District Number") %>%  
            rename(NASS_District = "State-NASS District Number", Mike = "MIKE", Strength = "Strength", 
                   HVI_RD = "HVI Color RD", HVI_b = "HVI Color +b", Trash_Percent = "Trash % Surface",
                   Length = "Length 100ths", Uniformity = "Length Uniformity")
        # Group the weekly data by NASS District and summarize (including total count of bales as "n")
        Weekly_summary_data <- Weekly_data %>%
            group_by(NASS_District) %>%
            summarize(n = n(), Avg_Mike = mean(as.numeric(Mike)), Avg_Strength = mean(as.numeric(Strength)), 
                      Avg_HVI_RD = mean(as.numeric(HVI_RD)), Avg_HVI_b = mean(as.numeric(HVI_b)), 
                      Avg_Trash_Percent = mean(as.numeric(Trash_Percent)), Avg_Length = mean(as.numeric(Length)), 
                      Avg_Uniformity = mean(as.numeric(Uniformity))) %>%
            ungroup()
        # Add in the current year as a column and move it to the front
        Weekly_summary_data$Year <- year
        Weekly_summary_data <- Weekly_summary_data %>% relocate(Year, .before = everything())
        # Append the weekly summary data for all districts to the weeks already calculated
        Annual_summary_data <- rbind(Annual_summary_data, Weekly_summary_data) 
    }
    # Now go back and, for each district, get the annual summary statistics via a weighted average
    Temp_summary_data <- Annual_summary_data %>%
        group_by(NASS_District) %>%
        summarize(n_bales = sum(n), Avg_Mike = sum(n * Avg_Mike) / sum(n), 
                  Avg_Strength = sum(n * Avg_Strength) / sum(n), 
                  Avg_HVI_RD = sum(n * Avg_HVI_RD) / sum(n),
                  Avg_HVI_b = sum(n * Avg_HVI_b) / sum(n), 
                  Avg_Trash_Percent = sum(n * Avg_Trash_Percent) / sum(n),
                  Avg_Length = sum(n * Avg_Length) / sum(n), 
                  Avg_Uniformity = sum(n * Avg_Uniformity) / sum(n)) %>%
        ungroup()
    # Fill in the year variable and move it to the front
    Temp_summary_data$Year <- rep(year, nrow(Temp_summary_data))
    Temp_summary_data <- Temp_summary_data %>% relocate(Year, .before = everything())
    # Append the summary statistics to those for the years calculated earlier
    TX_quality_summary_data <- rbind(TX_quality_summary_data, Temp_summary_data)
}

# Now do the same for Georgia:
for (year in years_of_interest) {
    # Find folder for this year and create list of weekly file names
    Qual_folder <- paste0("GeorgiaQuality/", year, " Crop/")  
    Qual_files <- list.files(Qual_folder, pattern = ".csv", full.names = FALSE)
    # Set up a blank data frame to hold all of the data for this year
    Annual_summary_data <- data.frame(Year = integer(), NASS_District = character(), n = integer(), Avg_Mike = numeric(), 
                                      Avg_Strength = numeric(), Avg_HVI_RD = numeric(),Avg_HVI_b = numeric(), 
                                      Avg_Trash_Percent = numeric(), Avg_Length = numeric(), Avg_Uniformity = numeric())
    # Run through every week's file, pull out just the variables of interest first
    for (week in Qual_files) {
        Weekly_data_raw <- read_csv(paste0(Qual_folder, week))
        Weekly_data <- Weekly_data_raw %>%
            select("MIKE", "Strength", "HVI Color RD", "HVI Color +b", "Trash % Surface",
                   "Length 100ths", "Length Uniformity", "State-NASS District Number") %>%  
            rename(NASS_District = "State-NASS District Number", Mike = "MIKE", Strength = "Strength", 
                   HVI_RD = "HVI Color RD", HVI_b = "HVI Color +b", Trash_Percent = "Trash % Surface",
                   Length = "Length 100ths", Uniformity = "Length Uniformity")
        # Group the weekly data by NASS District and summarize (including total count of bales as "n")
        Weekly_summary_data <- Weekly_data %>%
            group_by(NASS_District) %>%
            summarize(n = n(), Avg_Mike = mean(as.numeric(Mike)), Avg_Strength = mean(as.numeric(Strength)), 
                      Avg_HVI_RD = mean(as.numeric(HVI_RD)), Avg_HVI_b = mean(as.numeric(HVI_b)), 
                      Avg_Trash_Percent = mean(as.numeric(Trash_Percent)), Avg_Length = mean(as.numeric(Length)), 
                      Avg_Uniformity = mean(as.numeric(Uniformity))) %>%
            ungroup()
        # Add in the current year as a column and move it to the front
        Weekly_summary_data$Year <- year
        Weekly_summary_data <- Weekly_summary_data %>% relocate(Year, .before = everything())
        # Append the weekly summary data for all districts to the weeks already calculated
        Annual_summary_data <- rbind(Annual_summary_data, Weekly_summary_data) 
    }
    # Now go back and, for each district, get the annual summary statistics via a weighted average
    Temp_summary_data <- Annual_summary_data %>%
        group_by(NASS_District) %>%
        summarize(n_bales = sum(n), Avg_Mike = sum(n * Avg_Mike) / sum(n), 
                  Avg_Strength = sum(n * Avg_Strength) / sum(n), 
                  Avg_HVI_RD = sum(n * Avg_HVI_RD) / sum(n),
                  Avg_HVI_b = sum(n * Avg_HVI_b) / sum(n), 
                  Avg_Trash_Percent = sum(n * Avg_Trash_Percent) / sum(n),
                  Avg_Length = sum(n * Avg_Length) / sum(n), 
                  Avg_Uniformity = sum(n * Avg_Uniformity) / sum(n)) %>%
        ungroup()
    # Fill in the year variable and move it to the front
    Temp_summary_data$Year <- rep(year, nrow(Temp_summary_data))
    Temp_summary_data <- Temp_summary_data %>% relocate(Year, .before = everything())
    # Append the summary statistics to those for the years calculated earlier
    GA_quality_summary_data <- rbind(GA_quality_summary_data, Temp_summary_data)
}

# Round numeric values to two decimal places and write to a .csv file
TX_quality_summary_data <- TX_quality_summary_data %>%
    mutate(across(where(is.numeric), ~ round(.x, 2)))
write_csv(TX_quality_summary_data, "TX_quality_summary_data.csv")

GA_quality_summary_data <- GA_quality_summary_data %>%
    mutate(across(where(is.numeric), ~ round(.x, 2)))
write_csv(GA_quality_summary_data, "GA_quality_summary_data.csv")
