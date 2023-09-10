library(shiny)
library(deckgl)
library(dplyr)
library(readr)
library(DT)
library(shinyWidgets)
gg_df <- read_csv("data/parcel_value_sdcounty.csv")

ui <- fluidPage(
  titlePanel("SD Parcel ROI"),
  fluidRow(column(6,deckglOutput("deck", height='700px')),
           column(6, fluidRow(
                        fluidRow(column(5, pickerInput("city", NULL, 
                                             choices=names(table(gg_df$SITUS_COMMUNITY)), 
                                             options = list(`actions-box` = TRUE), multiple = T),
                                           pickerInput("zone", NULL, 
                                                       choices = c('Unzoned',
                                                                   'Single-Family',
                                                                   'Mixed-Use',
                                                                   'Multi-Family',
                                                                   'Commercial',
                                                                   'Industrial',
                                                                   'Agricultural',
                                                                   'Special/Misc.'), 
                                             options = list(`actions-box` = TRUE), multiple = T),
                                           actionButton('filter', 'Apply Filter', value=0)),
                                column(3, radioButtons("datatype", h4("Type of Metric"),
                                                        choices = c("Total Value per SQFT" = "Total Value per SQFT", 
                                                                    "Land Value per SQFT" = "Land Value per SQFT", 
                                                                    "Impr Value per SQFT" = "Impr Value per SQFT"),
                                                        selected = "Total Value per SQFT")
                                       ),
                                column(4, radioButtons("colortype", h4("Coloring Scheme"),
                                                       choices = c("Zone Type" = "Zone Type", 
                                                                   "Value per SQFT" = "Value per SQFT"),
                                                       selected = "Zone Type")
                                       )
                              ),
                        br(),
                        tableOutput('summarytable'),
                        fluidRow(column(3, br(),
                                           tableOutput('legend')),
                                 column(8, plotOutput('valueplot')))
                        )
                  )
           ),
  br(),
  fluidRow(column(12, DTOutput('expandedtable')))

)