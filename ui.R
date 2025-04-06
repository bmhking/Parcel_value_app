library(shiny)
library(deckgl)
library(dplyr)
library(readr)
library(DT)
library(shinyWidgets)
library(shinyjs)

gg_df <- read_csv("data/parcel_value_sdcounty.csv")
gg_df$land_value_per_sqft <- gg_df$land_value/gg_df$shape_area
gg_df$impr_value_per_sqft <- gg_df$impr_value/gg_df$shape_area
gg_df$total_value_per_sqft <- gg_df$total_value/gg_df$shape_area
gg_df[which(gg_df$use_type_text == "NATURAL RESOURCES – MINING, EXTRACTIVE, PROCESSING CEMENT/SILICA PRODUCTS, ROCK & GRAVEL"), "use_type_text"] <-"NATURAL RESOURCES – MINING, ETC."

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
  fluidRow(column(7, h2("San Diego Parcel Value Height Map"), 
                  "Evaluating every lot's value through standardizing by area.", 
                  tags$a(href="https://github.com/bmhking/Parcel_value_app", 
                         "Repo link."), 
                  tags$a(href="https://bmhking.github.io/Parcel_value_app/", 
                         "How to use this app."),
                  deckglOutput("deck", height='675px')),
           column(5, tabsetPanel(id = "filters",
                                 tabPanel("Required Filters", br(),
                                            column(6, pickerInput("city", NULL, 
                                                               choices=names(table(gg_df$SITUS_COMM)), 
                                                               options = list(`actions-box` = TRUE, title = "Select city/communities"), multiple = T),
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
                                                               options = list(`actions-box` = TRUE, title = "Select parcel usages"), multiple = T)),
                                            
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
                                            textAreaInput("APNs", NULL, placeholder = 'Separate prefixes with a comma e.g. 001,0022', 
                                                          height = '140px', width = '100%')
                                            ),
                                   tabPanel("Latitude/Longitude", br(),
                                            fluidRow(column(6, numericInput("lat", "Latitude (SD center: 32.7157):", NA, min = -90, max = 90),
                                                            numericInput("lon", "Longitude (SD center: -117.1611):", NA, min = -180, max = 180)),
                                                     column(5, numericInput("rad", HTML("Radius (&#176;): 0.01&#176; radius &asymp; 1 mile."), NA, min = 0, max = 90),
                                                            br(), actionButton('resetlatlonrad', HTML("<b>Reset Tab</b>"), value=0, style = "width: 100%")))
                                   ),
                                   tabPanel("Lot Size Condition", br(),
                                            fluidRow(column(6, numericInput("lotsizemin", "Minimum Lot Size (SQFT):", NA, min = 0, max = max(gg_df$shape_area)),
                                                      numericInput("lotsizemax", "Maximum Lot Size (SQFT):", NA, min = 0, max = max(gg_df$shape_area))),
                                                     column(5, HTML("<b>1 Acre = 43560 SQFT</b>"),
                                                            actionButton('resetlotsize', HTML("<b>Reset Lot Size Range</b>"), value=0, style = "height: 110px")))
                                            )
                                   ),
                  fluidRow(column(2, tags$div(style="display:inline-block",title="If San Diego city is selected it will take a while to load",
                             actionButton('filter', HTML("<b>Show Map</b>"), value=0))),
                           column(3, conditionalPanel(condition = "output.deck",
                             downloadButton("downloadData", HTML("<b>Download Data</b>"))
                           )),
                           column(7, conditionalPanel(condition = "output.deck",
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