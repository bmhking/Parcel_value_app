library(shiny)
library(deckgl)
library(dplyr)
library(readr)
library(DT)
library(shinyWidgets)
gg_df <- read_csv("data/parcel_value_sdcounty.csv")
gg_df$land_value_per_sqft <- gg_df$land_value/gg_df$shape_area
gg_df$impr_value_per_sqft <- gg_df$impr_value/gg_df$shape_area
gg_df$total_value_per_sqft <- gg_df$total_value/gg_df$shape_area
gg_df$zonecolor <- '#000000'
gg_df$zonecolor[gg_df$zoning_type_group == 0] <- '#FFFFFF'
gg_df$zonecolor[gg_df$zoning_type_group == 10] <- '#FFFF00'
gg_df$zonecolor[gg_df$zoning_type_group == 20] <- '#FF7F50'
gg_df$zonecolor[gg_df$zoning_type_group == 30] <- '#FF7F50'
gg_df$zonecolor[gg_df$zoning_type_group == 40] <- '#FFA500'
gg_df$zonecolor[gg_df$zoning_type_group == 50] <- '#FF0000'
gg_df$zonecolor[gg_df$zoning_type_group == 60] <- '#FF0000'
gg_df$zonecolor[gg_df$zoning_type_group == 70] <- '#800080'
gg_df$zonecolor[gg_df$zoning_type_group == 80] <- '#00FF00'
gg_df$zonecolor[gg_df$zoning_type_group == 90] <- '#0000FF'
gg_df$totalvaluecolor <- '#000000'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 25 & gg_df$total_value_per_sqft >= 0] <- '#0B5345'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 50 & gg_df$total_value_per_sqft >= 25] <- '#0E6655'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 75 & gg_df$total_value_per_sqft >= 50] <- '#1E8449'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 100 & gg_df$total_value_per_sqft >= 75] <- '#229954'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 150 & gg_df$total_value_per_sqft >= 100] <- '#27AE60'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 200 & gg_df$total_value_per_sqft >= 150] <- '#9ACD32'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 250 & gg_df$total_value_per_sqft >= 200] <- '#E1E000'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 350 & gg_df$total_value_per_sqft >= 250] <- '#FEBA4F'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 500 & gg_df$total_value_per_sqft >= 350] <- '#FF7F50'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 750 & gg_df$total_value_per_sqft >= 500] <- '#FF4500'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 1000 & gg_df$total_value_per_sqft >= 750] <- '#D21404'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 2000 & gg_df$total_value_per_sqft >= 1000] <- '#C54BBC'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft >= 2000] <- '#603FEF'
gg_df$landvaluecolor <- '#000000'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 10 & gg_df$land_value_per_sqft >= 0] <- '#0B5345'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 20 & gg_df$land_value_per_sqft >= 10] <- '#0E6655'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 35 & gg_df$land_value_per_sqft >= 20] <- '#1E8449'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 50 & gg_df$land_value_per_sqft >= 35] <- '#229954'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 75 & gg_df$land_value_per_sqft >= 50] <- '#27AE60'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 100 & gg_df$land_value_per_sqft >= 75] <- '#9ACD32'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 125 & gg_df$land_value_per_sqft >= 100] <- '#E1E000'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 150 & gg_df$land_value_per_sqft >= 125] <- '#FEBA4F'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 200 & gg_df$land_value_per_sqft >= 150] <- '#FF7F50'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 300 & gg_df$land_value_per_sqft >= 200] <- '#FF4500'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 400 & gg_df$land_value_per_sqft >= 300] <- '#D21404'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 500 & gg_df$land_value_per_sqft >= 400] <- '#C54BBC'
gg_df$landvaluecolor[gg_df$land_value_per_sqft >= 500] <- '#603FEF'
gg_df$imprvaluecolor <- '#000000'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 10 & gg_df$impr_value_per_sqft >= 0] <- '#008000'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 20 & gg_df$impr_value_per_sqft >= 10] <- '#0E6655'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 35 & gg_df$impr_value_per_sqft >= 20] <- '#1E8449'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 50 & gg_df$impr_value_per_sqft >= 35] <- '#229954'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 75 & gg_df$impr_value_per_sqft >= 50] <- '#27AE60'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 100 & gg_df$impr_value_per_sqft >= 75] <- '#9ACD32'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 150 & gg_df$impr_value_per_sqft >= 100] <- '#E1E000'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 200 & gg_df$impr_value_per_sqft >= 150] <- '#FEBA4F'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 300 & gg_df$impr_value_per_sqft >= 200] <- '#FF7F50'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 500 & gg_df$impr_value_per_sqft >= 300] <- '#FF4500'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 900 & gg_df$impr_value_per_sqft >= 500] <- '#D21404'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 1500 & gg_df$impr_value_per_sqft >= 900] <- '#C54BBC'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft >= 1500] <- '#603FEF'
gg_df[which(gg_df$use_type_text == "NATURAL RESOURCES – MINING, EXTRACTIVE, PROCESSING CEMENT/SILICA PRODUCTS, ROCK & GRAVEL"), "use_type_text"] <-"NATURAL RESOURCES – MINING, ETC."
ui <- fluidPage(
  fluidRow(column(7, h2("San Diego Parcel Value Height Map"), 
                  "Evaluating every lot's value by standardizing the area.", 
                  tags$a(href="https://github.com/bmhking/Parcel_value_app", 
                         "Repo link."), 
                  tags$a(href="https://github.com/bmhking/Parcel_value_app", 
                         "How to use this app."),
                  
                  deckglOutput("deck", height='675px')),
           column(5, fluidRow(
                        fluidRow(br(), column(5, pickerInput("city", NULL, 
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
                                              options = list(`actions-box` = TRUE, title = "Select parcel usages"), multiple = T),
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
                                       textAreaInput("APNs", NULL, placeholder = 'Separate prefixes with a comma e.g. 001,0022', height = '140px')
                                       )
                              ),
                        tableOutput('summarytable'),
                        fluidRow(column(3, br(),
                                           tableOutput('legend')),
                                 column(9, br(),
                                           tableOutput('parcelareatable'),
                                           br(),
                                           htmlOutput('scrolldowntip')))
                                 # column(8, fluidRow(plotOutput('valueplot', height='315px'))))
                        )
                  )
           ),
  br(),
  fluidRow(column(12, DTOutput('expandedtable')))

)