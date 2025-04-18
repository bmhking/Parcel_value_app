# The value of standardizing value by area
**The screenshots are taken from older versions of the dashboard.**
The dashboard shows value/sqft of every taxable parcel in San Diego County. Why value/sqft instead of just value? Because land is the most important resource for the government and we measure yield with a standardized area. To illustrate the immense differences in value/sqft, I will compare the most expensive mansion in La Jolla and a Section 8 housing unit that used to be "where you bought weed".

Foxhill Estates is the most expensive property in La Jolla, spanning over 30 acres and just sold at $35 million. That means it is assessed at $25/sqft. In contrast, Meadowbrook Apartments in Bay Terrace is a Section 8 housing unit that houses more than 200 households. It used to be a very sketchy place, albeit in the past 10 years it has been improving. It is assessed at $65/sqft - 280% that of Foxhill Estate's. Therefore for the public to evaluate the efficacy of land, just looking at market or assessed value is not enough. The value must be standardized by area for it to be meaningful.

I am using this methodology to write a paper on how high residential water usage and low property tax efficiency are connected in San Diego.

# How to use the app
When you open the link, the website looks like this:
![](https://raw.githubusercontent.com/bmhking/Parcel_value_app/main/tutorial/tutorial_1.PNG)
There are three columns of filters. After setting all the filters, you can click the `Apply Filter` button and wait for the map to load. For example, the following image shows the results for selecting parcels from every community, zoning type, and parcel usage:
![](https://raw.githubusercontent.com/bmhking/Parcel_value_app/main/tutorial/tutorial_2.PNG)
The left side is the map, while the right side includes summary statistics for every zoning type.
![](https://raw.githubusercontent.com/bmhking/Parcel_value_app/main/tutorial/tutorial_3.PNG)
Scrolling down gives the summary statistics for every usage type.

In the first column, you can select different communities/zoning types/usages to map. The communities are taken from SANDAG, and selecting all of them gives you the full county. Note that the zoning types and usages are two separate classfications: just because a parcel is zoned for a specific type does not mean that the usage of the parcel is limited to that zoning type (e.g. a single family home zoning type parcel might still be a duplex or small corner store).

The second column decides what value is plotted and the coloring scheme. There are three values to select: land, improvement, and total value per sqft. Land value + improvement value = total value. There are two coloring schemes: by value and by zoning type. The zoning type color scheme is taken from [New York's zoning guide](https://www.nyc.gov/assets/planning/download/pdf/applicants/applicant-portal/area_map_standard.pdf). The value color scheme was created by me to cater specifically to the three value types in San Diego County. While for all three value types, the color goes from dark green to red to blue, for each of the three value types, the thresholds are different.

The third column is the APN box which allows you to write in prefixes for the 10-digit APN numbers associated with every parcel. The app will only show parcels that begin with those prefixes (you can enter any amount of prefixes, and there is no prefix digit requirement). Separate every prefix with a comma. Use [SANDAG's Parcel Lookup Tool](https://sdgis.sandag.org/) to find APNs of specific parcels. Here is an example for Alvarado Estates:
![](https://raw.githubusercontent.com/bmhking/Parcel_value_app/main/example_alvaradoestates.png)
Another example for Convoy district. All parcels in Convoy have an APN that start with 356:
![](https://raw.githubusercontent.com/bmhking/Parcel_value_app/main/tutorial/tutorial_convoy.PNG)
Hovering over a column will show you information about that parcel:
![](https://raw.githubusercontent.com/bmhking/Parcel_value_app/main/tutorial/tutorial_convoy_column.PNG)

# How to load the app in local
This app requires `Shiny` to run in local. 
I recommend using RStudio to run most R tasks, since RStudio integrates so well with many of the core functionalities of the language.  
Once you download RStudio, download the required libraries in `ui.R` and `server.R` (including `shiny`) (or use the `renv.lock` file to download the environment - requires `renv` package). Then, replace the default `data/parcel_value_sdcounty.csv` with the extracted one in the root menu, and click the `Run App` button in the RStudio interface. 

# Further examples of what you can do with the app:
1. Rancho Santa Fe analysis

Rancho Santa Fe is the most affluent neighborhood in San Diego county. Are their houses as wealthy as we think they are?
![](https://raw.githubusercontent.com/bmhking/Parcel_value_app/main/tutorial/tutorial_ranchosantafe.PNG)
Rancho Santa Fe is assessed at $25.54/sqft. San Diego city is assessed at $84.62/sqft - more than 3 times that of Rancho Santa Fe. Rancho Santa Fe is receiving subsidies that is paid for by citizens in the city. If Rancho Santa Fe was developed to San Diego city's average value/sqft, we would see an increase of property value equal to:

$$(\$84.62-\$25.54)\times556,300,609.60=\$32,866,240,015.20$$

That's 47 full Shohei Ohtani contracts, or 5 full lineups of him.

2. Comparing the two sides of Balboa Park

To the west side of Balboa Park is 6th Ave which is full of "luxury" apartments (aka anything built in the past 10 years) whom white homeowners keep telling me makes housing unaffordable (I'm sure they live in very affordable homes) and will block the sun (because it is common knowledge that the sun rests on second floor). To the east of Balboa Park are a bunch of single family homes in North and South Park where a lot of these homeowners live:
![](https://raw.githubusercontent.com/bmhking/Parcel_value_app/main/tutorial/tutorial_balboaparkcomparison.PNG)
The west side apartments full of million dollar, unaffordable condos are assessed at 6 times more than the east side 1.5 million dollar, affordable houses. The difference in property value is around $1.76 billion - or $17.6 million dollars of property tax income every year. It's obvious which side is more affordable for the local government

# History of edits:
- Change button UI to be more user-friendly (8/17)
- Add tooltip functionality to show you the address and zoning type of the parcel (8/17)
- Add stacked bar chart showing the table summary of value per sqft (8/20)
- Add apply button so map doesn't update everytime you change an input (8/20)
- Fixed tooltip bug where the tooltip shows the average value of whole area for that zoning type instead of that specific building (8/24)
- Improved stacked bar chart UI (8/24)
- Expand the analysis to further differentiate the zoning types to building types (detached single family house, duplexes, townhouses, highrises etc.) (8/24)
- Implemented multiple choice selection (8/24)
- Added Color Scheme by value instead of zone (9/2)
- Updated color legend so now it shows the legend based on whether the user selected zone type or value per sqft to color (9/2)
- Add mode of map which shows ROI (total value per sqft - infrastructure cost per sqft) under certain assumptions
- Added filter for parcels based on APN that integrates with the other dropdown menus (2/2)
- Replaced stacked barchart with a further summary of the zoning types. Also added more statistics to the usage type table (2/2)
- Updated with 2024 SANDAG assessments (2/13)
- Updated UI to make it more friendly (2/18)
- Added commas to the area values (2/18)
- Add ability to filter by lot size (3/9)
- Add ability to filter by lat/lon with a 0.01 degree radius - around 1 mile (3/12)
- Add ability to download data of selected parcels in map (03/30)
- Replaced Parcel with Lot in tables for clarity (03/30)
- Disabled buttons when the data is loading (03/30)
- Add ability to exclude a certain list of APN prefixes in the APN prefix tab in addition to current functionality that filters based on these APN prefixes (04/09)
- Add sqrt mode to shrink downtown for easier comparison and 100x mode to better plot agriculture communities where land is cheap (04/15)
- Edited map settings so now user can freely choose height multiplier (04/16)
- Auto-centers map at the mean lat and lon of mapped parcels (04/16)
- Add 2D mode (04/17)
- Added error message if user does not select city/community, zoning, and usage (04/17)
- Changed column to 6 sides instead of 20. Now the map runs more smoothly (04/17)
- Reorganize usage options
- Add ability to read in a file of APNs - currently not working on it since you already can copy/paste a list of APNs. I might work on this later
- Add ability to show average value of surrounding parcels of a parcel (likely in a certain radius) - currently can do it with lat/long

# Need help with:
- Optimizing the dashboard so it costs less to run on GCP
- Add loading tooltips when rendering the map to improve UI (basic Shiny capabilities cannot cover deck.gl maps)
- Plot the parcels on their actual parcel map since the parcel shapefile is too large for my computer to run
- Find a way to implement "reverse mode" - highlighting parcels with a low value per sqft
- Explore other color schemes
- Find other data sources where zoning, land use, and land unit data are more accurate
