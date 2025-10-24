library(shiny)
library(deckgl)
library(dplyr)
library(readr)
library(DT)
library(stringr)
library(shinyWidgets)
library(shinyjs)
library(shinyalert)

# not needed for ui part
# gg_df_value <- read_csv("data/parcel_value_sdcounty_value.csv")
gg_df_landuse <- read_csv("data/parcel_value_sdcounty_landuse.csv")
gg_df_location <- read_csv("data/parcel_value_sdcounty_location.csv")
highlight_text_columns <- read_csv("data/highlight_text_columns.csv")
city_list <- names(table(gg_df_location$SITUS_COMM))
comm_list <- str_sub(city_list[str_sub(city_list, 1, 9) == 'SAN DIEGO'], 13, -1)
city_list <- c('SAN DIEGO', sort(city_list[str_sub(city_list, 1, 9) != 'SAN DIEGO']))

tabset_css <- "
/* for the active tab */
.nav-tabs>li.active>a, .nav-tabs>li.active>a:focus, .nav-tabs>li.active>a:hover {
  border: 1px solid blue;
  border-bottom-color: green;
}
/* for the line */
.nav-tabs {
  border-bottom-color: green;
}
"

ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(HTML(tabset_css))
  ),
  fluidRow(column(6, h3("San Diego Parcel Value Height Map"), 
                  "Showing the true value of developments.", 
                  tags$a(href="https://bmhking.github.io/Parcel_value_app/", 
                         "Help"), "|",
                  tags$a(href="https://github.com/bmhking/Parcel_value_app", 
                        "Github repo"), " | ",
                  tags$a(href="https://sdlanduse.substack.com/", 
                        "Substack"), " | ",
                  tags$a(href="https://patreon.com/sdparcelmap", 
                        "Donation link"), 
                  tags$div(style="display:inline-block",
                           title="The data is retrieved from SANDAG's Parcel dataset. While the assessment and size data are accurate, please note that land use and zoning fields are not regularly maintained by the Assessor's Office and should only be used as an approximation.",
                           HTML("<b>A note on the dataset &#9432;</b>")
                  ),
                  tabsetPanel(id = "filters", type='pill',
                               tabPanel("Required Filters",
                                        column(6, 
                                               pickerInput("city", NULL, 
                                                           choices = city_list, 
                                                           options = pickerOptions(actionsBox = TRUE, title = "Select city/communities", liveSearch = TRUE),
                                                           multiple = TRUE),
                                               conditionalPanel("input.city.indexOf('SAN DIEGO') >= 0",
                                                                pickerInput("comm", NULL, 
                                                                            choices = comm_list, 
                                                                            options = pickerOptions(actionsBox = TRUE, title = "Select San Diego City CPAs", liveSearch = TRUE),
                                                                            multiple = TRUE)),
                                               pickerInput("zone", NULL, 
                                                           choices = c('Unzoned',
                                                                       'Single-Family',
                                                                       'Mixed-Use',
                                                                       'Multi-Family',
                                                                       'Commercial',
                                                                       'Industrial',
                                                                       'Agricultural',
                                                                       'Special/Misc.',
                                                                       'Multi-Zone'), 
                                                           options = list(`actions-box` = TRUE, title = "Select zoning types"), multiple = T),
                                               pickerInput("use", NULL, 
                                                           choices = names(table(gg_df_landuse$use_type_text)), 
                                                           options = pickerOptions(actionsBox = TRUE, title = "Select parcel usages", liveSearch = TRUE),
                                                           multiple = T)
                                        ),
                                        
                                        column(6, selectInput("datatype", "Metric Plotted",
                                                              choices = c("Total Value/SQFT" = "Total Value/SQFT", 
                                                                          "Land Value/SQFT" = "Land Value/SQFT", 
                                                                          "Impr Value/SQFT" = "Impr Value/SQFT"),
                                                              selected = "Total Value/SQFT"),
                                               selectInput("colortype", "Coloring Scheme",
                                                           choices = c("Value/SQFT" = "Value/SQFT",
                                                                       "Zone Type" = "Zone Type"),
                                                           selected = "Value/SQFT"))
                               ),
                               tabPanel("APN Prefixes",
                                        fluidRow(column(10, textAreaInput("APNs", NULL, placeholder = 'Separate prefixes with a comma e.g. 001,0022', 
                                                                          height = '133px', width = '100%')),
                                                 column(2, radioButtons("includeorexclude", "", 
                                                                        c("Include" = "include", "Exclude" = "exclude"))))
                               ),
                               tabPanel('Additional Filters',
                                        tabsetPanel(id = 'additional_filters', type='pill',
                                                    tabPanel("By Latitude/Longitude",
                                                             fluidRow(column(3, numericInput("lat", HTML("Latitude (&#176;):"), NA, min = -90, max = 90)),
                                                                      column(3, numericInput("lon", HTML("Longitude (&#176;):"), NA, min = -180, max = 180)),
                                                                      column(4, numericInput("rad", HTML("Range (&#176;): 0.01&#176; &asymp; 2 mile square"), NA, min = 0, max = 90)), 
                                                                      column(2, br(), actionButton('clearlatlonrad', HTML("<b>Clear All</b>"), value=0, style = "width: 100%"))),
                                                             fluidRow(HTML("<b>&nbsp;&nbsp;&nbsp;&nbsp;For western longitudes, use \"-\". For example, San Diego's center is: (32.7157, -117.1611).</b>"))
                                                    ),
                                                    tabPanel("By Lot Size",
                                                             fluidRow(column(5, numericRangeInput('lotsizerange', 'Range (SQFT, 1 Acre = 43560 SQFT):', c(NA,NA), separator='-')),
                                                                      column(1, br(), actionButton('clearlotsize', HTML("<b>Clear All</b>"), value=0, style = "height: 100%"))
                                                             )
                                                    ),
                                                    tabPanel("By Value Condition",
                                                             fluidRow(column(6, numericRangeInput('landvaluerange', 'Land Value:', c(NA,NA), separator='-')),
                                                                      column(6, numericRangeInput('imprvaluerange', 'Impr Value:', c(NA,NA), separator='-'))
                                                             ),
                                                             fluidRow(column(6, numericRangeInput('totalvaluerange', 'Total Value:', c(NA,NA), separator='-')),
                                                                      column(6, radioButtons("parcelorsqft", "", c("By Parcel" = "byparcel", "By SQFT" = "bysqft"), inline=TRUE))
                                                             )
                                                    ),
                                                    tabPanel("By Address",
                                                             fluidRow(column(12, textInput('address', 'Address (do not enter city or ZIP code)'))),
                                                             fluidRow(HTML("<b>&nbsp;&nbsp;&nbsp;&nbsp;Enter a street name or an address based on property tax roll (case insensitive), e.g. C St or 202 C St.</b>"))
                                                    )
                                        )
                               ),
                               tabPanel("Additional Map Options",
                                        tabsetPanel(id = 'additional_map_options', type='pill',
                                                    tabPanel("Column Height",
                                                             fluidRow(column(3, radioButtons("mapmode", "Column Height",
                                                                                             c("Default" = "default", "Square Root" = "sqrt", "2-D" = "twod"))),
                                                                      column(4, numericInput("heightmultiplier", "Column Height Multiplier:", NA, min=0)))
                                                    ),
                                                    tabPanel("Non-Taxed Parcels",
                                                             fluidRow(column(12, checkboxInput("includetaxexempt", HTML("<b>Include Valued But Tax-Exempt Parcels</b>"), FALSE)),
                                                                      column(12, checkboxInput("includenovalue", HTML("<b>Include Parcels With 0 Value</b>"), FALSE))
                                                             )
                                                    ),
                                                    tabPanel("Highlighted Text",
                                                             fluidRow(column(8, pickerInput("parcelhighlighttext", 
                                                                                            "Select text to show on a highlighted parcel (by default, show all)", 
                                                                                            choices = highlight_text_columns$text_option, 
                                                                                            selected = highlight_text_columns$text_option,
                                                                                            options = list(`actions-box` = TRUE), multiple = T, width = '95%')),
                                                                      column(4, conditionalPanel("input.parcelhighlighttext.indexOf('Address') >= 0",
                                                                                                 numericInput("maxaddresslength", "Characters shown for Address", value = 100, min = 0)))
                                                             )
                                                    )
                                        )
                               )
                         ),
                  fluidRow(column(2, tags$div(style="display:inline-block",title="If San Diego city is selected it will take a while to load",
                                              actionButton('filter', HTML("<b>Show Map</b>"), value=0))),
                           column(4, actionButton('selectall', HTML("<b>Select All Zones and Uses</b>"), value=0))
                  ),
                  fluidRow(column(9, br(), div(tableOutput('summarytable')), 
                                  br(), div(tableOutput('parcelareatable')), style = "font-size:90%"),
                           column(3, tableOutput('legend'), 
                                  br(), conditionalPanel(condition = "output.deck",
                                     downloadButton("downloadData", HTML("<b>Download Data</b>"))), 
                                  br(), conditionalPanel(condition = "output.deck",
                                     htmlOutput('scrolldowntip'))
                                  )
                  )
                  ),
           column(6, br(), deckglOutput("deck", height='750px')
           )
  ),
  br(),
  fluidRow(column(12, DTOutput('expandedtable')))
)