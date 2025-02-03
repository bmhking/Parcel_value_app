library(shiny)
library(deckgl)
library(dplyr)
library(readr)
library(DT)
library(shinyWidgets)
# gg_df <- read_csv("data/parcel_value_sdcounty.csv")
gg_df[which(gg_df$use_type_text == "NATURAL RESOURCES – MINING, EXTRACTIVE, PROCESSING CEMENT/SILICA PRODUCTS, ROCK & GRAVEL"), "use_type_text"] <-"NATURAL RESOURCES – MINING, ETC."
ui <- fluidPage(
  fluidRow(column(7, titlePanel("SD Parcel ROI"), deckglOutput("deck", height='700px')),
           column(5, fluidRow(
                        fluidRow(br(), column(5, pickerInput("city", NULL, 
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
                                                                   'Special/Misc.',
                                                                   'Multi-Zone'), 
                                             options = list(`actions-box` = TRUE), multiple = T),
                                           pickerInput("use", NULL, 
                                              choices = names(table(gg_df$use_type_text)),
                                              options = list(`actions-box` = TRUE), multiple = T),
                                           actionButton('filter', 'Apply Filter', value=0)),
                                column(3, fluidRow(selectInput("datatype", h4("Type of Metric"),
                                                        choices = c("Total Value/SQFT" = "Total Value/SQFT", 
                                                                    "Land Value/SQFT" = "Land Value/SQFT", 
                                                                    "Impr Value/SQFT" = "Impr Value/SQFT"),
                                                        selected = "Total Value/SQFT")),
                                       fluidRow(selectInput("colortype", h4("Coloring Scheme"),
                                                             choices = c("Value/SQFT" = "Value/SQFT",
                                                                         "Zone Type" = "Zone Type"),
                                                             selected = "Value/SQFT"))
                                       ),
                                column(4, h4("APN prefixes"),
                                       textAreaInput("APNs", h5('Separate prefixes with a comma e.g. 001,0022'))
                                       )
                              ),
                        tableOutput('summarytable'),
                        fluidRow(column(3, br(),
                                           tableOutput('legend')),
                                 column(9, br(),
                                           tableOutput('parcelareatable')))
                                 # column(8, fluidRow(plotOutput('valueplot', height='315px'))))
                        )
                  )
           ),
  br(),
  fluidRow(column(12, DTOutput('expandedtable')))

)