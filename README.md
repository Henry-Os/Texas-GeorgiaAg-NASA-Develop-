# Project Short Title 
**Project:** Texas & Georgia Agriculture    

**Node:** Maryland - Goddard 

**Term:** Spring 2025

**Team:** Lorryn Andrade (Project Lead), Nick Grener, Kelechi Igwe, Henry Osei  

**Code Contact:** Name, [Email] (add email address that can be accessed longterm after DEVELOP)         

## Introduction  
What motivated the creation of the code and how does the code address the problem? (1 paragraph, 3-5 sentences)  

## Applications and Scope   
Where will the code be used, and to what extent?   

## Capabilities 
What can this code do, how has it improved the way work is performed and decisions are made? 

## Interfaces 

### Languages
What languages does it use, how do the users actually interface with the end product?  

### Required Packages

- R
    - `tidyverse`
    - `sf`
    - `openxlsx`
    - `exactextractr`
    - `lubridate`
- Python
    - `xarray`


## Parameters
Describe any steps needed for the script to run. It will help to specify which line in the code will need to be changed by the user based on their needs.  

1. step 1  
2. step 2 
3. include examples 

## Assumptions, Limitations, & Errors 
This is where limitations of the theory, model, science, etc should be briefly documented. If the tools only work for a specific scenario, say so.   

## Support
Tell people where they can go to for help. Provide links to relevant documentation, chat rooms, email addresses, tutorials, etc. 


## Data Sources

#### Cotton Masks

???? Henry made these need to get code from him

#### SMAP (all .nc files in GA_SMAP and TX_SMAP folders)

???? Given to us by Hung, how do we cite this or should we get the extraction code from him?

Daily soil moisture datasets (aggregate from three-hourly SMAP L4)

File format:  yyyymmdd.nc
Temporal resolution/ coverage: daily / 2015-03-31 to 2024-12-31
Spatial resolution/ coverage: 0.1 degree/ Texas and Georgia 
Variable names:
rootzonesm: Root Zone Soil Moisture ; unit: m^3/m^-3
surfacesm: Surface Soil Moisture; unit: m^3/m^-3

Citation:
Reichle, R., De Lannoy, G., Koster, R. D., Crow, W. T., Kimball, J. S., Liu, Q., & Bechtold, M. (2022). SMAP L4 Global 3-hourly 9 km EASE-Grid Surface and Root Zone Soil Moisture Analysis Update, Version 7, Boulder, Colorado USA.[Dataset]. NASA National Snow and Ice Data Center Distributed Active Archive Center. https://doi.org/10.5067/LWJ6TF5SZRG3

#### Daily maximum wind speed m/s datasets: Climate_Regions_Max_Daily_Wind.csv, TX_Districts_Max_Daily_Wind.csv

Acquired February 23, 2025 from https://app.climateengine.org/climateEngine via:

Make Graph - Native Time Series - One Variable Calculation

Climate_Regions_Max_Daily_Wind.csv was obtained from selecting five US climate divisions corresponding to NASS districts of interest in this study:
GA - Southeast (GA 70)
GA - South Central (GA 80)
GA - Southwest (GA 90)
TX - Trans Pecos (TX 60)
TX - Edwards Plateau (TX 70)
The other NASS districts of interest did not align with US climate divisions, so the data in TX_Districts_Max_Daily_Wind_Speed.csv was obtained by polygon shapefiles for TX 12, TX 21, and TX 22

Variable:
Climate & Hydrology - GridMET - 4km - Daily - Wind Speed - Maximum in m / s

Temporal resolution/ coverage: daily / 2015-03-01 to 2024-11-30
Computational spatial resolution: 4000 m (1/24 degree) 

Citation:
Huntington, J., Hegewisch, K., Daudert, B., Morton, C., Abatzoglou, J., McEvoy, D., and T., Erickson. (2017). Climate Engine: Cloud Computing of Climate and Remote Sensing Data for Advanced Natural Resource Monitoring and Process Understanding. Bulletin of the American Meteorological Society, http://journals.ametsoc.org/doi/abs/10.1175/BAMS-D-15-00324.1

## Acknowledgments
Include acknowledgments of who helped develop the code.
- Name (Institution)  
