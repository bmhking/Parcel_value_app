library(shiny)
library(deckgl)
library(dplyr)
library(readr)
gg_df <- read_csv("data/parcel_value_sdcounty.csv")

ui <- fluidPage(
  titlePanel("SD Parcel ROI"),
  fluidRow(column(6,deckglOutput("deck", height='700px')),
           column(6, fluidRow(
                        fluidRow(column(5, selectInput("city", NULL, 
                                             choices = c('COUNTY', names(table(gg_df$SITUS_COMMUNITY))), selected = 'COUNTY'),
                                           selectInput("zone", NULL, 
                                             choices = c('All Zones',
                                                      'Unzoned',
                                                      'Single-Family',
                                                      'Mixed-Use',
                                                      'Multi-Family',
                                                      'Commercial',
                                                      'Industrial',
                                                      'Agricultural',
                                                      'Special/Misc.'), selected = 'All Zones'),
                                            actionButton('filter', 'Apply Filter')),
                                column(7, radioButtons("datatype", h4("Type of Metric"),
                                                        choices = c("Total Value per SQFT" = "Total Value per SQFT", 
                                                                    "Land Value per SQFT" = "Land Value per SQFT", 
                                                                    "Impr Value per SQFT" = "Impr Value per SQFT"),
                                                        selected = "Total Value per SQFT")
                                       )
                              ),
                        textOutput('taxefficiency'),
                        tableOutput('summarytable'),
                        plotOutput('valueplot', height='350px')
                        )
                  )
           )
  
  # tags$head(tags$style(type = "text/css", "#summarytable th {display:none;}"))
)