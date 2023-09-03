This app requires `Shiny` to run.  
Note that the default Shiny host server can only allow 1GB of RAM, while this app requires at least 2GB. Therefore, the default version of this app can only show the results of the cities of Carlsbad and Chula Vista and the unicorpoated community of Rancho Santa Fe.  
For the whole county's data, unzip `parcel_value_sdcounty.7z`, which will reveal the csv that has data for all parcels in the county and replace the existing file in `/data` with the unzipped file.

# How to load the app in local
I recommend using RStudio to run most R tasks, since RStudio integrates so well with many of the core functionalities of the language.  
Once you download RStudio, download the required libraries in `ui.R` and `server.R` (including `shiny`) that are listed in the `library(foo)` commands. Then, replace the default `data/parcel_value_sdcounty.csv` with the extracted one in the root menu, and click the `Run App` button in the RStudio interface. The app should work fine.

# Future plans:
- Change button UI to be more user-friendly (8/17)
- Add tooltip functionality to show you the address and zoning type of the parcel (8/17)
- Add stacked bar chart showing the table summary of value per sqft (8/20)
- Add apply button so map doesn't update everytime you change an input (8/20)
- Fixed tooltip bug where the tooltip shows the average value of whole area for that zoning type instead of that specific building (8/24)
- Improved stacked bar chart UI (8/24)
- Expand the analysis to further differentiate the zoning types to building types (detached single family house, duplexes, townhouses, highrises etc.) (8/24)
- Implemented multiple choice selection (8/24)
- Added Color Scheme by value instead of zone (9/2)
- Add mode of map which shows ROI (total value per sqft - infrastructure cost per sqft) under certain assumptions

# Need help with:
- Optimize the web app - it would be very helpful since it is taking a lot of RAM
- Plot the parcels on their actual parcel map since I don't have that map - now it is plotted as a column with fixed radius
- Since the base data is too big to load into Github, setup a sql database to read the data from
- Find a way to dynamically change color scheme
- Implement vmt analysis
