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

clipMask <- function(path, extent){
    ## path is a full file path to a raster object
    ## extent is a spatial object (in SpatVect format) which will be used to clip and mask the raster
    ## returns a raster object that is clipped and masked to the extent object 
    r1 <- terra::rast(path) %>%
        terra::crop(y = extent) %>%
        terra::mask(mask = extent)
    return(r1)
}

system.time(
for (district_name in NASS_Districts) {
    # Without mask:
    shapefile_path <- paste0("data/", district_name, "_Boundary.shp")
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
            SM_Values_Daily[row_i, "District"] <- district_name
            SM_Values_Daily[row_i, "Year"] <- as.integer(str_sub(datefile, 1, 4))
            SM_Values_Daily[row_i, "Month"] <- as.integer(str_sub(datefile, 5, 6))
            SM_Values_Daily[row_i, "Day"] <- as.integer(str_sub(datefile, 7, 8))
            SM_Values_Daily[row_i, "MeanSSM"] <- mean(values(points_in_area[["surfacesm"]]), na.rm = TRUE)
            SM_Values_Daily[row_i, "MeanRZSM"] <- mean(values(points_in_area[["surfacesm"]]), na.rm = TRUE)
            row_i <- row_i + 1
        }
    }
}
)

# Change year to factor variable
SM_Values_Daily$Year <- as.factor(SM_Values_Daily$Year)

# Calculate monthly average for each district/year/month combo
SM_Values_Monthly <- SM_Values_Daily %>% 
    group_by(District, Year, Month) %>% 
    summarize(MonthlyMeanSSM = mean(MeanSSM, na.rm = TRUE), 
              MonthlyMeanRZSM = mean(MeanRZSM, na.rm = TRUE)) %>%
    ungroup()

# Make plot
SM_Values_Monthly_Plot <- ggplot(data = SM_Values_Monthly, 
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
ggsave("outputs/Unmasked_SMAP_plot.png", plot = SM_Values_Monthly_Plot, width = 10, height = 8, dpi = 300)
write.xlsx(SM_Values_Monthly, "outputs/Unmasked_SMAP_Statistics.xlsx")



SM_Values_Daily_Masked <- data.frame(District=character(), Year=integer(), Month = integer(),
                                     Day = integer(), MeanSSM = double(), MeanRZSM = double(),
                                     stringsAsFactors=FALSE)
row_j <- 1


system.time(
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
)


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
system.time({
    AOI <- read_sf(dsn = "data/CottonMasks/GA_80_CottonMask.shp", quiet =TRUE)
    AOI_fixed <- st_make_valid(AOI)
    SMAP_folder <- "data/GA_SMAP/GA/"
    SMAP_file <- "20160424.nc"
    points_in_area <- clipMask(path = paste0(SMAP_folder, SMAP_file), extent = AOI_fixed)
})
(mean(values(points_in_area[["surfacesm"]]), na.rm = TRUE))
qtm(points_in_area)
##

## Check what the value was for this district was when not masked
goal <- SM_Values_Daily %>% filter(District == "GA_80", Year == "2016", Month == 4, Day == 24)
(goal$MeanSSM)
## Comes out to .1919


## Another way to mask- yields avg of .2663 for Apr 24, 2016 in GA 80 in about 30 seconds
# Having a hard time visualizing what this approach is doing, though
system.time({
coarse_rast <- rast("data/GA_SMAP/GA/20160424.nc")
rast1 <- read_sf(dsn = "data/CottonMasks/GA_80_CottonMask.shp", quiet =TRUE)
mask_rast <- st_make_valid(rast1)
mask_rast <- rast(mask_rast)
# Ensure both rasters have the same CRS (coordinate reference system)
if (!identical(crs(coarse_rast), crs(mask_rast))) {
    mask_rast <- project(mask_rast, coarse_rast)
}
# Convert Mask_rast to polygons (fields) 
mask_vect <- as.polygons(mask_rast, dissolve=FALSE)  # Keeps separate fields
# Extract values from Coarse_rast based on field polygons
extracted_values <- terra::extract(coarse_rast, mask_vect, fun=mean, na.rm=TRUE)
# Merge the extracted values with the field polygons
mask_vect$avg_ssm <- extracted_values[,2] 
mask_vect$avg_rzsm <- extracted_values[,3] 
})
(mean(mask_vect$avg_ssm, na.rm = TRUE))
plot(mask_vect, "avg_ssm")


