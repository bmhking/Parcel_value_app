library(shiny)
library(deckgl)
library(dplyr)
library(readr)
library(DT)
library(stringr)
library(shinyWidgets)
library(shinyjs)
library(shinyalert)

gg_df <- read_csv("data/parcel_value_sdcounty.csv")
gg_df$total_value <- gg_df$land_value + gg_df$impr_value
gg_df$land_value_per_sqft <- gg_df$land_value/gg_df$shape_area
gg_df$impr_value_per_sqft <- gg_df$impr_value/gg_df$shape_area
gg_df$total_value_per_sqft <- gg_df$total_value/gg_df$shape_area
city_list <- names(table(gg_df$SITUS_COMM))
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
  fluidRow(column(6, h2("San Diego Parcel Value Height Map"), 
                  "Evaluating every lot's value through standardizing by area.", 
                  tags$a(href="https://bmhking.github.io/Parcel_value_app/", 
                         "How to use this app."), 
                  tags$div(style="display:inline-block",
                           title="The data is retrieved from SANDAG's Parcel dataset. While the assessment and size data are accurate, please note that land use and zoning fields are not regularly maintained by the Assessor's Office and should only be used as an approximation.",
                           HTML("<b>A note on the dataset &#9432;</b>")
                  ),
                  br(),
                  tags$a(href="https://github.com/bmhking/Parcel_value_app", 
                         "Github repo"), " | ",
                  tags$a(href="https://sdlanduse.substack.com/", 
                         "Substack"), " | ",
                  tags$a(href="https://patreon.com/sdparcelmap", 
                         "Help me cover server costs"),
                  deckglOutput("deck", height='675px')),
           column(6, tabsetPanel(id = "filters",
                                 tabPanel("Required Filters", br(),
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
                                                               choices = names(table(gg_df$use_type_text)), 
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
                                   tabPanel("APN Prefixes", br(),
                                            fluidRow(column(10, textAreaInput("APNs", NULL, placeholder = 'Separate prefixes with a comma e.g. 001,0022', 
                                                          height = '140px', width = '100%')),
                                                     column(2, radioButtons("includeorexclude", "", 
                                                                   c("Include" = "include", "Exclude" = "exclude"))))
                                            ),
                                   tabPanel("Latitude/Longitude", br(),
                                            fluidRow(column(6, numericInput("lat", HTML("Latitude (&#176;): SD center: 32.7157&#176;"), NA, min = -90, max = 90),
                                                            numericInput("lon", HTML("Longitude (&#176;): SD center: -117.1611&#176;"), NA, min = -180, max = 180)),
                                                     column(5, numericInput("rad", HTML("Range (&#176;): 0.01&#176; &asymp; 2 mile square"), NA, min = 0, max = 90),
                                                            br(), actionButton('resetlatlonrad', HTML("<b>Reset Tab</b>"), value=0, style = "width: 100%")))
                                            ),
                                   tabPanel("Lot Size Condition", br(),
                                            fluidRow(column(6, numericInput("lotsizemin", "Minimum Lot Size (SQFT):", NA, min = 0, max = max(gg_df$shape_area)),
                                                      numericInput("lotsizemax", "Maximum Lot Size (SQFT):", NA, min = 0, max = max(gg_df$shape_area))),
                                                     column(5, br(), HTML("<b>1 Acre = 43560 SQFT</b>"), br(), br(),
                                                            actionButton('resetlotsize', HTML("<b>Reset Lot Size Range</b>"), value=0, style = "height: 100%")))
                                            ),
                                   tabPanel("Additional Map Options", br(), 
                                            fluidRow(column(3, radioButtons("mapmode", "Column Height",
                                                            c("Default" = "default", "Square Root" = "sqrt", "2-D" = "twod"))),
                                                     column(4, numericInput("heightmultiplier", "Column Height Multiplier:", NA, min=0)),
                                                     column(4, checkboxInput("includetaxexempt", HTML("<b>Include Tax-Exempt Parcels</b>"), FALSE),
                                                            checkboxInput("includenovalue", HTML("<b>Include Parcels With 0 Value</b>"), FALSE))
                                                     )
                                            )
                                   ),
                  fluidRow(column(2, tags$div(style="display:inline-block",title="If San Diego city is selected it will take a while to load",
                             actionButton('filter', HTML("<b>Show Map</b>"), value=0))),
                           column(4, actionButton('selectall', HTML("<b>Select All Zones and Uses</b>"), value=0)),
                           column(3, conditionalPanel(condition = "output.deck",
                             downloadButton("downloadData", HTML("<b>Download Data</b>"))
                           )),
                           column(3, conditionalPanel(condition = "output.deck",
                             htmlOutput('scrolldowntip')
                           ))
                           ),
                  br(),
                  tableOutput('summarytable'),
                  fluidRow(column(3, tableOutput('legend')),
                           column(9, br(), tableOutput('parcelareatable'))
                           )
                  )
           ),
  br(),
  fluidRow(column(12, DTOutput('expandedtable')))

)