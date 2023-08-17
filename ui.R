library(shiny)
library(deckgl)
library(dplyr)
library(readr)
gg_df <- read_csv("data/parcel_value_sdcounty.csv")

ui <- fluidPage(
  titlePanel("SD Parcel ROI"),
  fluidRow(column(6,deckglOutput("deck", height='600px')),
           column(6, fluidRow(selectInput("city", NULL, 
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
                              selectInput("datatype", NULL, 
                                          choices = c('Total Value per SQFT',
                                                      'Land Value per SQFT',
                                                      'Impr Value per SQFT'), selected = 'Total Value per SQFT'),
                              textOutput('taxefficiency'),
                              tableOutput('summarytable')
                              )
                  )
           )
  
  # tags$head(tags$style(type = "text/css", "#summarytable th {display:none;}"))
)