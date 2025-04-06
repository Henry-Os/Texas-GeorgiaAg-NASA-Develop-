# Texas & Georgia Agriculture
**Project:** Texas & Georgia Agriculture    

**Node:** Maryland - Goddard 

**Term:** Spring 2025

**Team:** Lorryn Andrade (Project Lead), Nick Grener, Kelechi Igwe, Henry Osei  

**Code Contact:** Nick Grener, grener@gmail.com      

## Introduction  
The purpose of this collection of scripts is to build and then analyze a table holding data representing vegetative indices, weather variables, and cotton quality data. The scripts automate the process of extraction various environmental variables and Cotton quality data for use in our modeling process. In terms of temporal resolution, the hypothesized drivers/predictor variables - enhanced vegetation index, root zone soil moisture, growing degree days, precipitation, maximum wind speed - are recorded at the monthly level, while the response variables describing cotton quality are recorded at the annual crop year level. Spatially, all variables are aggregated to the level of National Agricultural Statistical Service (NASS) Districts.

## Applications and Scope   
The scope of this analysis is the years 2015 through 2024 and eight NASS districts that represent areas of significant cotton production in the US- three in Georgia (GA-70, GA-80, and GA-90) and five in Texas (TX-12, TX-21, TX-22, TX-60, TX-70). The code can be amended in the appropriate places if the user wishes to apply a comparable analysis to other regions/years, but note that not every data source used here is guaranteed to contain the needed data for all years. For example, the Soil Moisture Active Passive radiometer launched and went online in 2015, so SMAP data is not available prior to 2015. 

## Capabilities 
Each script perform unique tasks including automating the extraction of environmental variable data using application programming interfaces (APIs), data cleaning, exploratory data analysis and visualization, and finally, development and deployment of multiple regression models. 


## Interfaces 
All scripts were written in either R Studio (for the R code) and Jupyter notebooks (for the Python code) environments. 

### Languages
R and Python

### Required Packages
- R
    - `tidyverse`
    - `sf`
    - `openxlsx`
    - `exactextractr`
    - `lubridate`
    - `terra`
    - `tmap`
- Python
    - `xarray`
    - `rioxarray`
    - `earthaccess`
    - `dask`
    - `folium`
    - `numpy`
    - `os`
    - `pandas`
    - `re`
    - `requests`
    - `chardet`
    - `json`
    - `io`
    - `pickle`
    - `h5py`
    - `geopandas`
    - `rasterio`

## Parameters
The code needs to be run in the following groupings, but within each group the order of the scripts does not matter:

#### A. Extraction Scripts
1. get_CottonQualityData_from_NASS.ipynb 
2. get_GridMET_data.ipynb

#### B. Pre-processing Scripts
1. TXGA_CottonMask.ipynb
2. convert_IMERG_HDF5_to_csv.ipynb

#### C. Processing Scripts
1. Wind Speed Processing.r  
2. SMAP Processing.r
3. GDD Processing.r
4. Cotton Quality Processing.r
5. TXGA_EVI.ipynb

#### D. Analysis Scripts
1. visualize_ModelResults  


## Assumptions, Limitations, & Errors 
Data from counties within districs were averaged, without considering any kind of weighting. For example, 10 km pixels of precipitation data from IMERG within a county were average without considering what percentage area of the 10 km pixels were contained within the county boundaries.    

## Support
For support on working with HDF5Y precipitation files from IMERG, visit: https://gpm.nasa.gov/data/tutorials 

## Acknowledgments
-Manh-Hung Le (Hydrological Sciences Laboratory, NASA Goddard Space Flight Center) 
- Owen Kelly (Precipitation Processing System, NASA Goddard Space Flight Center)
