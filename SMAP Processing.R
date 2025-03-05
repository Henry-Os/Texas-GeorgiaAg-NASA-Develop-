---
Title: "SMAP Processing"
Project: "Texas & Georgia Agriculture"
Date: "March 4, 2025"
CodeContact: "Nick Grener, grener@gmail.com"

Inputs: "Cotton masks for each NASS District and daily SMAP datasets for states of interest

Daily soil moisture datasets (aggregate from three-hourly SMAP L4)

## File format:  yyyymmdd.nc
## Temporal resolution/ coverage: daily / 2015-03-31 to 2024-12-31
## Spatial resolution/ coverage: 0.1 degree/ Texas and Georgia 
## Variable names:
rootzonesm: Root Zone Soil Moisture ; unit: m^3/m^-3
surfacesm: Surface Soil Moisture; unit: m^3/m^-3

Citation:
Reichle, R., De Lannoy, G., Koster, R. D., Crow, W. T., Kimball, J. S., Liu, Q., & Bechtold, M. (2022). 
SMAP L4 Global 3-hourly 9 km EASE-Grid Surface and Root Zone Soil Moisture Analysis Update, Version 7, Boulder, Colorado USA.[Dataset]. 
NASA National Snow and Ice Data Center Distributed Active Archive Center. https://doi.org/10.5067/LWJ6TF5SZRG3"

Outputs: "Masked_SMAP_plot.png, Masked_SMAP_Statistics.xlsx"

Description: "Calculates the average monthly surface soil moisture and root zone soil moisture
for each NASS District based on all 9 km pixels within the district that contain a cotton field"
---

# Load needed libraries 
library(readr)
library(sf)
library(stringr)
library(ggplot2)
library(dplyr)
library(openxlsx)
library(exactextractr)

# Establish empty data frame & start counter for filling it
SM_Values_Daily <- data.frame(District=character(), Year=integer(), Month = integer(),
                        Day = integer(), MeanSSM = double(), MeanRZSM = double(),
                        stringsAsFactors=FALSE)
row_i <- 1

# Establish months and districts of interest
# months <- c("03")
months <- c("03", "04", "05", "06", "07", "08", "09", "10", "11")
# NASS_Districts <- c("TX_21")
NASS_Districts <- c("GA_70", "GA_80", "GA_90", "TX_12", "TX_21", 
                    "TX_22", "TX_60", "TX_70")

# Make function to mask rasters
clipMask <- function(path, extent){
    ## path is a full file path to a raster object
    ## extent is a spatial object (in SpatVect format) which will be used to clip and mask the raster
    ## returns a raster object that is clipped and masked to the extent object 
    r1 <- terra::rast(path) %>%
        terra::crop(y = extent) %>%
        terra::mask(mask = extent)
    return(r1)
}

# Establish empty data frame & start counter
SM_Values_Daily_Masked <- data.frame(District=character(), Year=integer(), Month = integer(),
                                     Day = integer(), MeanSSM = double(), MeanRZSM = double(),
                                     stringsAsFactors=FALSE)
row_j <- 1

# Main loop
for (district_name in NASS_Districts) {
    # With mask:
    shapefile_path <- paste0("data/CottonMasks/", district_name, "_CottonMask.shp")
    AOI <- read_sf(dsn = shapefile_path, quiet =TRUE)
    AOI_fixed <- st_make_valid(AOI)
    # Point to correct folder for reading SMAP values
    if (str_sub(district_name, 1, 2) == "GA") {
        SMAP_folder <- "data/GA_SMAP/GA/"
    } else {
        SMAP_folder <- "data/TX_SMAP/TX/"
    }
    SMAP_files <- list.files(SMAP_folder, pattern = ".nc", full.names = FALSE)
    # Run through every date's data and average the SMAP measurements for the AOI
    for (datefile in SMAP_files) {
        if (str_sub(datefile, 5, 6) %in% months) {
            points_in_area <- clipMask(path = paste0(SMAP_folder, datefile), extent = AOI_fixed)
            SM_Values_Daily_Masked[row_j, "District"] <- district_name
            SM_Values_Daily_Masked[row_j, "Year"] <- as.integer(str_sub(datefile, 1, 4))
            SM_Values_Daily_Masked[row_j, "Month"] <- as.integer(str_sub(datefile, 5, 6))
            SM_Values_Daily_Masked[row_j, "Day"] <- as.integer(str_sub(datefile, 7, 8))
            SM_Values_Daily_Masked[row_j, "MeanSSM"] <- mean(values(points_in_area[["surfacesm"]]), na.rm = TRUE)
            SM_Values_Daily_Masked[row_j, "MeanRZSM"] <- mean(values(points_in_area[["surfacesm"]]), na.rm = TRUE)
            row_j <- row_j + 1
        }
    }
}

# Change year to factor variable
SM_Values_Daily_Masked$Year <- as.factor(SM_Values_Daily_Masked$Year)

# Calculate monthly average for each district/year/month combo
SM_Values_Monthly_Masked <- SM_Values_Daily_Masked %>% 
    group_by(District, Year, Month) %>% 
    summarize(MonthlyMeanSSM = mean(MeanSSM, na.rm = TRUE), 
              MonthlyMeanRZSM = mean(MeanRZSM, na.rm = TRUE)) %>%
    ungroup()

# Make plot
SM_Values_Monthly_Masked_Plot <- ggplot(data = SM_Values_Monthly_Masked, 
                                 aes(x = Month, y = MonthlyMeanRZSM, group = Year, color = Year)) +
    geom_line(linewidth = 0.8) +
    ggtitle("Average Soil Moisture by District and Year") +
    xlab("Month") +
    ylab("Mean Root Zone Soil Moisture") +
    scale_color_manual(labels = c("2015", "2016", "2017", "2018", "2019", 
                                  "2020", "2021", "2022", "2023", "2024"), 
                       values = c("#a6cee3", "#b2df8a", "#fb9a99", "#fdbf6f", "#cab2d6", 
                                  "#1f78b4", "#33a02c", "#e31a1c", "#ff7f00", "#6a3d9a")) + 
    facet_wrap(~ District, nrow = 2)

# Save plot and monthly averages
ggsave("outputs/Masked_SMAP_plot.png", plot = SM_Values_Monthly_Masked_Plot, width = 10, height = 8, dpi = 300)
write.xlsx(SM_Values_Monthly_Masked, "outputs/Masked_SMAP_Statistics.xlsx")


## This is an example plot and calculation of the masking used above;
# yields avg of .1911 for Apr 24, 2016 in GA 80 in about 15 seconds
# Just eliminates 9 km pixels with no cotton farms in them and averages the rest.
AOI <- read_sf(dsn = "data/CottonMasks/GA_80_CottonMask.shp", quiet =TRUE)
AOI_fixed <- st_make_valid(AOI)
SMAP_folder <- "data/GA_SMAP/GA/"
SMAP_file <- "20160424.nc"
points_in_area <- clipMask(path = paste0(SMAP_folder, SMAP_file), extent = AOI_fixed)

(mean(values(points_in_area[["surfacesm"]]), na.rm = TRUE))
qtm(points_in_area)






