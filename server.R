library(tableHTML)
library(readr)
library(ggplot2)
library(rjson)
library(DT)
library(shinyWidgets)
library(scales)
library(dplyr)
library(purrr)
library(stringr)
library(stringi)
library(shinyjs)
useShinyjs()
options(scipen=999)
gg_df <- read_csv("data/parcel_value_sdcounty.csv")
gg_df$land_value_per_sqft <- gg_df$land_value/gg_df$shape_area
gg_df$impr_value_per_sqft <- gg_df$impr_value/gg_df$shape_area
gg_df$total_value_per_sqft <- gg_df$total_value/gg_df$shape_area
gg_df$sqrt_land_value_per_sqft <- sqrt(gg_df$land_value_per_sqft)
gg_df$sqrt_impr_value_per_sqft <- sqrt(gg_df$impr_value_per_sqft)
gg_df$sqrt_total_value_per_sqft <- sqrt(gg_df$total_value_per_sqft)
gg_df$impr_land_ratio <- gg_df$impr_value/gg_df$land_value
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
# old color scheme: '#0B5345', '#0E6655', '#1E8449', '#229954', '#27AE60', '#9ACD32', '#E1E000', '#FEBA4F', '#FF7F50', '#FF4500', '#D21404', '#C54BBC', '#603FEF'
gg_df$totalvaluecolor <- '#000000'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 25 & gg_df$total_value_per_sqft >= 0] <- '#0B5345'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 50 & gg_df$total_value_per_sqft >= 25] <- '#14714E'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 75 & gg_df$total_value_per_sqft >= 50] <- '#1E9057'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 100 & gg_df$total_value_per_sqft >= 75] <- '#27AE60'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 150 & gg_df$total_value_per_sqft >= 100] <- '#65BF40'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 200 & gg_df$total_value_per_sqft >= 150] <- '#A3CF20'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 250 & gg_df$total_value_per_sqft >= 200] <- '#E1E000'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 350 & gg_df$total_value_per_sqft >= 250] <- '#F0B028'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 500 & gg_df$total_value_per_sqft >= 350] <- '#FF7F50'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 750 & gg_df$total_value_per_sqft >= 500] <- '#FF4500'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 1000 & gg_df$total_value_per_sqft >= 750] <- '#D21404'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft < 2000 & gg_df$total_value_per_sqft >= 1000] <- '#C54BBC'
gg_df$totalvaluecolor[gg_df$total_value_per_sqft >= 2000] <- '#603FEF'
gg_df$landvaluecolor <- '#000000'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 10 & gg_df$land_value_per_sqft >= 0] <- '#0B5345'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 20 & gg_df$land_value_per_sqft >= 10] <- '#14714E'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 35 & gg_df$land_value_per_sqft >= 20] <- '#1E9057'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 50 & gg_df$land_value_per_sqft >= 35] <- '#27AE60'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 75 & gg_df$land_value_per_sqft >= 50] <- '#65BF40'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 100 & gg_df$land_value_per_sqft >= 75] <- '#A3CF20'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 125 & gg_df$land_value_per_sqft >= 100] <- '#E1E000'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 150 & gg_df$land_value_per_sqft >= 125] <- '#F0B028'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 200 & gg_df$land_value_per_sqft >= 150] <- '#FF7F50'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 300 & gg_df$land_value_per_sqft >= 200] <- '#FF4500'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 400 & gg_df$land_value_per_sqft >= 300] <- '#D21404'
gg_df$landvaluecolor[gg_df$land_value_per_sqft < 500 & gg_df$land_value_per_sqft >= 400] <- '#C54BBC'
gg_df$landvaluecolor[gg_df$land_value_per_sqft >= 500] <- '#603FEF'
gg_df$imprvaluecolor <- '#000000'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 10 & gg_df$impr_value_per_sqft >= 0] <- '#0B5345'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 20 & gg_df$impr_value_per_sqft >= 10] <- '#14714E'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 35 & gg_df$impr_value_per_sqft >= 20] <- '#1E9057'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 50 & gg_df$impr_value_per_sqft >= 35] <- '#27AE60'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 75 & gg_df$impr_value_per_sqft >= 50] <- '#65BF40'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 100 & gg_df$impr_value_per_sqft >= 75] <- '#A3CF20'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 150 & gg_df$impr_value_per_sqft >= 100] <- '#E1E000'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 200 & gg_df$impr_value_per_sqft >= 150] <- '#F0B028'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 300 & gg_df$impr_value_per_sqft >= 200] <- '#FF7F50'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 500 & gg_df$impr_value_per_sqft >= 300] <- '#FF4500'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 900 & gg_df$impr_value_per_sqft >= 500] <- '#D21404'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft < 1500 & gg_df$impr_value_per_sqft >= 900] <- '#C54BBC'
gg_df$imprvaluecolor[gg_df$impr_value_per_sqft >= 1500] <- '#603FEF'

use_text <- fromJSON(file = "data/use_code_sd.txt")
use_df <- do.call("rbind", lapply(use_text$fields[34][[1]][[5]][[4]], as.data.frame))
zones_list <- c("Unzoned", "Single-Family", 'Mixed-Use', 'Multi-Family', 
                'Commercial', 'Industrial', 'Agricultural', 'Special/Misc.', 'Multi-Zone')
output_colnames <- c('Zone Type', 'Total Area in SQFT', 'Land Value/SQFT', 'Impr Value/SQFT', 'Total Value/SQFT')
output_colnames2 <- c('Usage', '# of Parcels', 'Total Area in SQFT', 'Mean Lot Area', 'Land Value/SQFT', 'Impr Value/SQFT', 'Total Value/SQFT')
output_colnames3 <- c('Zone Type', '# of Parcels', 'Mean Lot Area', 'Median Lot Area')
is_noninteger_column <- function(x){
  if(is.numeric(x)){
    return(!all(x==as.integer(x)))
  }else{
    return(FALSE)
  }
}
print_2_digits <- function(x){
  return(format(round(x, digits=2), nsmall = 2, big.mark = ","))
}
Sys.setenv(MAPBOX_API_TOKEN = "pk.eyJ1IjoiYm1oa2luZyIsImEiOiJjbGw5bXowNXMxNHhhM2xxaGF3OWFhdTNlIn0.EH2wndceM6KvF0Pp8_oBNQ")
# gg_df <- read_csv("{data/parcel_value_sdcounty.csv")
tooltip_html <- "APN: {{APN_list}}<br>Zone Type: {{zoning_type_text}}<br>Usage: {{use_type_text}}<br>Lot Size in SQFT: {{shape_print}}<br>Land Value/SQFT: {{land_print}}<br>Impr Value/SQFT: {{impr_print}}<br>Total Value/SQFT: {{total_print}}"
server <- function(input, output, session) {
  # output$deck <- renderDeckgl({
  #     deckgl(longitude=-116.75,
  #            latitude=33,
  #            zoom=8.25,
  #            pitch=45.0,
  #            width = '100%',
  #            height = "100%",
  #            bearing=0) %>%
  #       add_mapbox_basemap("mapbox://styles/mapbox/light-v11")
  # })
  values <- reactiveValues()
  values2 <- reactiveValues()
  refilter <- eventReactive(input$filter, {
    disable("filter")
    disable("downloadData")
    plotdata_df <- gg_df
    plotdata_df <- plotdata_df %>% filter(SITUS_COMM %in% input$city)
    plotdata_df <- plotdata_df %>% filter(zoning_type_text %in% input$zone)
    plotdata_df <- plotdata_df %>% filter(use_type_text %in% input$use)
    # find parcels that start with the typed in APN prefixes
    if(input$APNs != ''){
      APN_list <- unlist(strsplit(stri_replace_all_charclass(input$APNs, "\\p{WHITE_SPACE}", ""), ','))
      prefix_lengths <- names(table(nchar(APN_list)))
      APN_selected <- c()
      for(prefix_length in prefix_lengths){
        prefixs <- APN_list[nchar(APN_list) == prefix_length]
        APN_selected <- c(APN_selected, gg_df$APN_list[substring(gg_df$APN_list, 1, prefix_length) %in% prefixs])
      }
      APN_selected <- APN_selected[!duplicated(APN_selected)]
      if(input$includeorexclude == "include"){
        plotdata_df <- plotdata_df %>% filter(APN_list %in% APN_selected)
      }else{
        plotdata_df <- plotdata_df %>% filter(!(APN_list %in% APN_selected))
      }
    }
    if(is.na(input$lotsizemax) & !is.na(input$lotsizemin)){
      plotdata_df <- plotdata_df %>% filter(shape_area >= input$lotsizemin)
    }else if(!is.na(input$lotsizemax) & is.na(input$lotsizemin)){
      plotdata_df <- plotdata_df %>% filter(shape_area <= input$lotsizemax)
    }else if(!is.na(input$lotsizemax) & !is.na(input$lotsizemin)){
      plotdata_df <- plotdata_df %>% filter(shape_area >= input$lotsizemin & shape_area <= input$lotsizemax)
    }
    if(!is.na(input$lat) & !is.na(input$lon)){
      if(is.na(input$rad)){
        filter_radius <- 0.00001
      }else{
        filter_radius <- input$rad
      }
      plotdata_df <- plotdata_df %>% filter(lat >= input$lat - filter_radius & lat <= input$lat + filter_radius & lon >= input$lon - filter_radius & lon <= input$lon + filter_radius)
    }
    plotdata_df$city_total_area <- sum(plotdata_df$shape_area)
    plotdata_df_agg <- plotdata_df %>% group_by(zoning_type_text) %>% 
      summarize(Zone_Area = sum(as.numeric(shape_area)),
                Zone_Land_Value = sum(as.numeric(land_value))/sum(as.numeric(shape_area)),
                Zone_Impr_Value = sum(as.numeric(impr_value))/sum(as.numeric(shape_area)),
                Zone_Total_Value = sum(as.numeric(total_value))/sum(as.numeric(shape_area)),
                Zone_Total_Value_2 = sum(as.numeric(total_value)),
                Zone_Parcel_Num = n(),
                Zone_Avg_Area = mean(as.numeric(shape_area)),
                Zone_Median_Area = median(as.numeric(shape_area)))
    plotdata_df_parcelarea <- plotdata_df_agg[, c(1, 7, 8, 9)]
    plotdata_df_parcelarea[nrow(plotdata_df_parcelarea) + 1, ] <- list(zoning_type_text = "Total",
       Zone_Parcel_Num = sum(plotdata_df_agg$Zone_Parcel_Num),
       Zone_Avg_Area = sum(plotdata_df_agg$Zone_Area) / sum(plotdata_df_agg$Zone_Parcel_Num),
       Zone_Median_Area = median(as.numeric(plotdata_df$shape_area)))
    plotdata_df_agg <- plotdata_df_agg[, 1:6]
    plotdata_df_agg[nrow(plotdata_df_agg) + 1, ] <- list(zoning_type_text = "Total",
       Zone_Area = sum(plotdata_df_agg$Zone_Area),
       Zone_Land_Value = sum(plotdata_df_agg$Zone_Area*plotdata_df_agg$Zone_Land_Value) / sum(plotdata_df_agg$Zone_Area),
       Zone_Impr_Value = sum(plotdata_df_agg$Zone_Area*plotdata_df_agg$Zone_Impr_Value) / sum(plotdata_df_agg$Zone_Area),
       Zone_Total_Value = sum(plotdata_df_agg$Zone_Area*plotdata_df_agg$Zone_Total_Value) / sum(plotdata_df_agg$Zone_Area),
       Zone_Total_Value_2 = sum(plotdata_df_agg$Zone_Total_Value_2))
    plotdata_df <- plotdata_df %>% inner_join(plotdata_df_agg, by=join_by(zoning_type_text))
    plotdata_df <- plotdata_df %>% filter(zoning_type_text %in% input$zone) %>%
      filter(use_type_text %in% input$use)
    plotdata_df$land_print <- print_2_digits(plotdata_df$land_value_per_sqft)
    plotdata_df$impr_print <- print_2_digits(plotdata_df$impr_value_per_sqft)
    plotdata_df$total_print <- print_2_digits(plotdata_df$total_value_per_sqft)
    plotdata_df$shape_print <- print_2_digits(plotdata_df$shape_area)
    plotdata_df_expanded <- plotdata_df %>% group_by(use_type_text) %>% 
      summarize(Zone_Parcel_Num = n(),
                Zone_Area = sum(as.numeric(shape_area)),
                Zone_Avg_Area = mean(as.numeric(shape_area)),
                Zone_Land_Value = sum(as.numeric(land_value))/sum(as.numeric(shape_area)),
                Zone_Impr_Value = sum(as.numeric(impr_value))/sum(as.numeric(shape_area)),
                Zone_Total_Value = sum(as.numeric(total_value))/sum(as.numeric(shape_area)))
    values$agg_df <- plotdata_df_agg
    values$plot_df <- plotdata_df
    values$expanded_df <- plotdata_df_expanded
    values$parcelarea_df <- plotdata_df_parcelarea
    return(list(agg_df = plotdata_df_agg, plot_df = plotdata_df, expanded_df = plotdata_df_expanded))
  })
  
  layerdata <- reactive({
    value_layer <- list(
      get_position=~lon+lat,
      pickable=TRUE,
      coverage = 0.02,
      tooltip = use_tooltip(
        html = tooltip_html,
        style = "background: steelBlue; border-radius: 5px;"
      ))
    if(input$mapmode == 'times100'){
      value_layer[['elevation_scale']]=300
    }else if(input$mapmode == 'sqrt'){
      value_layer[['elevation_scale']]=30
    }else{
      value_layer[['elevation_scale']]=3
    }
    if(input$colortype == 'Zone Type'){
      value_layer[['get_fill_color']]=~zonecolor
      if(input$datatype == 'Total Value/SQFT'){
        if(input$mapmode == 'sqrt'){
          value_layer[['get_elevation']]=~sqrt_total_value_per_sqft
        }else{
          value_layer[['get_elevation']]=~total_value_per_sqft
        }
      }else if(input$datatype == 'Impr Value/SQFT'){
        if(input$mapmode == 'sqrt'){
          value_layer[['get_elevation']]=~sqrt_impr_value_per_sqft
        }else{
          value_layer[['get_elevation']]=~impr_value_per_sqft
        }
      }else if(input$datatype == 'Land Value/SQFT'){
        if(input$mapmode == 'sqrt'){
          value_layer[['get_elevation']]=~sqrt_land_value_per_sqft
        }else{
          value_layer[['get_elevation']]=~land_value_per_sqft
        }
      }
    }else if(input$colortype == 'Value/SQFT'){
      if(input$datatype == 'Total Value/SQFT'){
        if(input$mapmode == 'sqrt'){
          value_layer[['get_elevation']]=~sqrt_total_value_per_sqft
        }else{
          value_layer[['get_elevation']]=~total_value_per_sqft
        }
        value_layer[['get_fill_color']]=~totalvaluecolor
      }else if(input$datatype == 'Impr Value/SQFT'){
        if(input$mapmode == 'sqrt'){
          value_layer[['get_elevation']]=~sqrt_impr_value_per_sqft
        }else{
          value_layer[['get_elevation']]=~impr_value_per_sqft
        }
        value_layer[['get_fill_color']]=~imprvaluecolor
      }else if(input$datatype == 'Land Value/SQFT'){
        if(input$mapmode == 'sqrt'){
          value_layer[['get_elevation']]=~sqrt_land_value_per_sqft
        }else{
          value_layer[['get_elevation']]=~land_value_per_sqft
        }
        value_layer[['get_fill_color']]=~landvaluecolor
      }
    }
    value_layer
  })
  
  legenddata <- reactive({
    if(input$colortype == 'Zone Type'){
      legend_for_plot <- data.frame(matrix(ncol = 2, nrow = 8))
      legend_for_plot[, 1] <- ''
      colnames(legend_for_plot) <- c('Color', 'Legend')
      legend_for_plot$Legend <- c(' Single-Family', ' Mixed-Use', ' Multi-Family', ' Commercial', ' Industrial', ' Agricultural', ' Special/Misc.', 'Multi-Zone')
    }else if(input$colortype == 'Value/SQFT'){
      legend_for_plot <- data.frame(matrix(ncol = 2, nrow = 13))
      legend_for_plot[, 1] <- ''
      colnames(legend_for_plot) <- c('Color', 'Legend')
      if(input$datatype == 'Total Value/SQFT'){
        legend_for_plot$Legend <- c(' 0 - 25', ' 25 - 50', ' 50 - 75', ' 75 - 100', ' 100 - 150', ' 150 - 200', ' 200 - 250', ' 250 - 350', ' 350 - 500', ' 500 - 750', ' 750 - 1000', ' 1000 - 2000', ' 2000 -')
      }else if(input$datatype == 'Land Value/SQFT'){
        legend_for_plot$Legend <- c(' 0 - 10', ' 10 - 20', ' 20 - 35', ' 35 - 50', ' 50 - 75', ' 75 - 100', ' 100 - 125', ' 125 - 150', ' 150 - 200', ' 200 - 300', ' 300 - 400', ' 400 - 500', ' 500 - ')
      }else if(input$datatype == 'Impr Value/SQFT'){
        legend_for_plot$Legend <- c(' 0 - 10', ' 10 - 20', ' 20 - 35', ' 35 - 50', ' 50 - 75', ' 75 - 100', ' 100 - 150', ' 150 - 200', ' 200 - 300', ' 300 - 500', ' 500 - 900', ' 900 - 1500', ' 1500 - ')
      }
    }
    legend_for_plot
  })
  
  observeEvent(input$resetlotsize, {
    updateNumericInput(session, "lotsizemin", value = NA)
    updateNumericInput(session, "lotsizemax", value = NA)
  })
  
  observeEvent(input$resetlatlonrad, {
    updateNumericInput(session, "lat", value = NA)
    updateNumericInput(session, "lon", value = NA)
    updateNumericInput(session, "rad", value = NA)
  })
  
  observeEvent(input$filter, {
    refilter()
    layer_properties <- layerdata()
    legend_table <- legenddata()
    map_centroid <- c(33, -116.75)
    map_zoom <- 8.25
    if(!is.na(input$lat) & !is.na(input$lon)){
      map_centroid <- c(input$lat, input$lon)
      map_zoom <- 12.5
    }
    output$deck <- renderDeckgl({
      deckgl(longitude=map_centroid[2],
             latitude=map_centroid[1],
             zoom=map_zoom,
             pitch=45.0,
             width = '100%',
             height = "100%",
             bearing=0) %>%
        add_mapbox_basemap("mapbox://styles/mapbox/light-v11") %>%
        add_column_layer(data=values$plot_df, properties=layer_properties)
    })
    # deckgl_proxy('deck') %>%
    #   add_column_layer(data=values$plot_df, properties=layer_properties )%>%
    #   update_deckgl()
    output$summarytable <- render_tableHTML({
      display_df <- values$agg_df[, 1:5]
      display_df <- display_df[order(match(display_df$zoning_type_text, c(zones_list, 'total'))), 
        c('zoning_type_text', 'Zone_Area', 'Zone_Land_Value', 'Zone_Impr_Value', 'Zone_Total_Value')]
      colnames(display_df) <- output_colnames
      display_df <- display_df %>% 
        mutate_if(is_noninteger_column, print_2_digits) %>%
        tableHTML(widths = c(100, rep(150, 4)), rownames = FALSE) %>% 
        add_css_column(css = list('text-align', 'right'), 
                       columns = output_colnames[2:length(output_colnames)]) %>%
        add_css_row(css = list('font-weight', 'bold'), rows = nrow(display_df) + 1)
    })
    output$expandedtable <- renderDT({
      display_df <- values$expanded_df[, 1:7]
      display_df <- display_df[order(match(display_df$use_type_text, zones_list)), c('use_type_text', 'Zone_Parcel_Num', 'Zone_Area', 'Zone_Avg_Area', 'Zone_Land_Value', 'Zone_Impr_Value', 'Zone_Total_Value')]
      display_df$use_type_text <- as.factor(display_df$use_type_text)
      colnames(display_df) <- output_colnames2
      datatable(display_df %>% mutate_if(is_noninteger_column, print_2_digits), 
                filter = 'top', rownames = FALSE, 
                options = list(columnDefs = list(list(width = '100px', targets = 1))))
    })
    output$parcelareatable <- render_tableHTML({
      display_df <- values$parcelarea_df[, 1:4]
      display_df <- display_df[order(match(display_df$zoning_type_text, c(zones_list, 'total'))), 
                               c('zoning_type_text', 'Zone_Parcel_Num', 'Zone_Avg_Area', 'Zone_Median_Area')]
      colnames(display_df) <- output_colnames3
      display_df %>% 
        mutate_if(is_noninteger_column, print_2_digits) %>%
        tableHTML(widths = c(100, 110, 150, 150),
                  rownames = FALSE) %>% 
        add_css_column(css = list('text-align', 'right'), 
                       columns = output_colnames3[2:length(output_colnames3)]) %>%
        add_css_row(css = list('font-weight', 'bold'), rows = nrow(display_df) + 1)
    })
    output$scrolldowntip <- renderText({
      '<b style = "border: solid; border-width: 1px; border-color: black; border-radius: 10px; white-space: pre;">  &#x2193Scroll down to view usage-level summary  </b>'
    })
    output$legend <- render_tableHTML({
      if(input$colortype == 'Zone Type'){
        legend_table %>%
          tableHTML(rownames = FALSE, border = 0, collapse = 'separate_shiny', spacing = '5px 1px') %>%
          add_css_rows_in_column(css = list('background-color',
                                            c('yellow', 'coral', 'orange', 'red', 'purple', 'green', 'blue', 'black')),
                                 column = 'Color') %>%
          add_css_header(css = list('opacity', 0), headers = 1)
      }else if(input$colortype == 'Value/SQFT'){
        legend_table %>%
          tableHTML(rownames = FALSE, border = 0, collapse = 'separate_shiny', spacing = '5px 1px') %>%
          add_css_rows_in_column(css = list('background-color',
                                            c('#0B5345', '#14714E', '#1E9057', '#27AE60', '#65BF40', '#A3CF20', '#E1E000', '#F0B028', '#FF7F50', '#FF4500', '#D21404', '#C54BBC', '#603FEF')),
                                 column = 'Color') %>%
          add_css_header(css = list('opacity', 0), headers = 1)
      }
    })
    enable("filter")
    enable("downloadData")
  })
  
  output$downloadData <- downloadHandler(
    filename = "dashboardata.csv",
    content = function(file) {
      write.csv(values$plot_df[, 1:14], file, row.names = FALSE)
    }
  )
}