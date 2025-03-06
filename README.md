# Project Short Title 
**Project:** Texas & Georgia Agriculture    

**Node:** Maryland - Goddard 

**Term:** Spring 2025

**Team:** Lorryn Andrade (Project Lead), Nick Grener, Kelechi Igwe, Henry Osei  

**Code Contact:** Nick Grener, grener@gmail.com      

## Introduction  
The purpose of this collection of scripts is to build and then analyze a table holding data representing vegetative indices, weather variables, and cotton quality data. In terms of temporal resolution, the hypothesized drivers/predictor variables - enhanced vegetation index, root zone soil moisture, growing degree days, precipitation, maximum wind speed - are recorded at the monthly level, while the response variables describing cotton quality are recorded at the annual crop year level. Spatially, all variables are aggregated to the level of National Agricultural Statistical Service (NASS) Districts.

## Applications and Scope   
The scope of this analysis is the years 2015 through 2024 and eight NASS districts that represent areas of significant cotton production in the US- three in Georgia (GA-70, GA-80, and GA-90) and five in Texas (TX-12, TX-21, TX-22, TX-60, TX-70). The code can be amended in the appropriate places if the used wishes to apply a comparable analysis to other regions/years, but note that not every data source used here is guaranteed to house the needed data for all years. For example, the Soil Moisture Active Passive radiometer launched and went online in 2015, so SMAP data is not available prior to that date. 

## Capabilities 
(What can this code do, how has it improved the way work is performed and decisions are made?)

## Interfaces 
This code was produced in R Studio (for the R code) and Jupyter notebooks (for the Python code). 

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
    - `os`
    - `pandas`
    - `re`
    - `requests`
    - `chardet`
    - `json`
    - `io`
    - `pickle`

## Parameters
The code needs to be run in the following groupings, but within each group the order of the scripts does not matter:

#### A. Extraction Scripts
1. get_CottonQualityData.ipynb *in progress
2. get_GRIDMET_data.ipynb *in progress

#### B. Pre-processing Scripts
1. (cotton masking script) *in progress
2. convert_IMERG_HDF5_to_csv.ipynb *in progress

#### C. Processing Scripts
1. Wind Speed Processing.r  
2. SMAP Processing.r
3. GDD Processing.r
4. Cotton Quality Processing.r
5. 

#### D. Analysis Scripts
1.   
2. 


## Assumptions, Limitations, & Errors 
(This is where limitations of the theory, model, science, etc should be briefly documented. If the tools only work for a specific scenario, say so.)   

## Support
(Tell people where they can go to for help. Provide links to relevant documentation, chat rooms, email addresses, tutorials, etc.) 

## Acknowledgments
-Manh-Hung Le (Hydrological Sciences Laboratory, NASA Goddard Space Flight Center)  
