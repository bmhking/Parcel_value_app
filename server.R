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
library(shinyalert)

useShinyjs()
options(scipen=999)
gg_df_value <- read_csv("data/parcel_value_sdcounty_value.csv")
gg_df_landuse <- read_csv("data/parcel_value_sdcounty_landuse.csv")
gg_df_location <- read_csv("data/parcel_value_sdcounty_location.csv")
highlight_text_columns <- read_csv("data/highlight_text_columns.csv")
gg_df <- gg_df_value %>% inner_join(gg_df_landuse, by = join_by('APN_list', 'TAXSTAT')) %>%
  inner_join(gg_df_location, by = join_by('APN_list', 'TAXSTAT'))
all_uses <- names(table(gg_df$use_type_text))
gg_df$sqrt_land_value_per_sqft <- sqrt(gg_df$land_value_per_sqft)
gg_df$sqrt_impr_value_per_sqft <- sqrt(gg_df$impr_value_per_sqft)
gg_df$sqrt_total_value_per_sqft <- sqrt(gg_df$total_value_per_sqft)

# old code to read usage data from a file. Now usage data is read from the parcel dataset
# use_text <- rjson::fromJSON(file = "data/use_code_sd.txt")
# use_df <- do.call("rbind", lapply(use_text$fields$domain$codedValues[[34]], as.data.frame))
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
print_int <- function(x){
  return(format(x, nsmall = 0, big.mark = ","))
}
print_2_digits <- function(x){
  return(format(round(x, digits=2), nsmall = 2, big.mark = ","))
}
filter_by_numeric_range <- function(range_item, df_to_filter, col_to_filter){
  # col_to_filter must be a string, e.g. "Row_ID" instead of just Row_ID in dplyr format
  if(is.na(range_item[1])){
    return(df_to_filter %>% filter(!! sym(col_to_filter) <= range_item[2]))
  }else if(is.na(range_item[2])){
    return(df_to_filter %>% filter(!! sym(col_to_filter) >= range_item[1]))
  }else{
    return(df_to_filter %>% filter(!! sym(col_to_filter) >= range_item[1] & !! sym(col_to_filter) <= range_item[2]))
  }
}
filter_by_numeric_range_valuemetric <- function(range_item, df_to_filter, col_to_filter, parcel_switch){
  if(parcel_switch == 'byparcel'){
    return(filter_by_numeric_range(range_item, df_to_filter, col_to_filter))
  }else if(parcel_switch == 'bysqft'){
    return(filter_by_numeric_range(range_item, df_to_filter, paste0(col_to_filter, '_per_sqft')))
  }
}
Sys.setenv(MAPBOX_API_TOKEN = "pk.eyJ1IjoiYm1oa2luZyIsImEiOiJjbGw5bXowNXMxNHhhM2xxaGF3OWFhdTNlIn0.EH2wndceM6KvF0Pp8_oBNQ")
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
    comms <- input$city
    if(any(input$city == 'SAN DIEGO')){
      comms <- comms[comms != 'SAN DIEGO']
      comms <- c(comms, paste('SAN DIEGO - ', input$comm, sep = ''))
    }
    plotdata_df <- plotdata_df %>% filter(SITUS_COMM %in% comms)
    plotdata_df <- plotdata_df %>% filter(zoning_type_text %in% input$zone)
    plotdata_df <- plotdata_df %>% filter(use_type_text %in% input$use)
    if(!input$includenovalue){
      plotdata_df <- plotdata_df %>% filter(total_value != 0)
    }
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
    if(!is.null(input$lotsizerange)){
      plotdata_df <- filter_by_numeric_range(input$lotsizerange, plotdata_df, 'shape_area')
    }
    if(!is.na(input$lat) & !is.na(input$lon)){
      if(is.na(input$rad)){
        filter_radius <- 0.00001
      }else{
        filter_radius <- input$rad
      }
      plotdata_df <- plotdata_df %>% filter(lat >= input$lat - filter_radius & lat <= input$lat + filter_radius & lon >= input$lon - filter_radius & lon <= input$lon + filter_radius)
    }
    if(!is.null(input$landvaluerange)){
      plotdata_df <- filter_by_numeric_range_valuemetric(input$landvaluerange, plotdata_df, 'land_value', input$parcelorsqft)
    }
    if(!is.null(input$imprvaluerange)){
      plotdata_df <- filter_by_numeric_range_valuemetric(input$imprvaluerange, plotdata_df, 'impr_value', input$parcelorsqft)
    }
    if(!is.null(input$totalvaluerange)){
      plotdata_df <- filter_by_numeric_range_valuemetric(input$totalvaluerange, plotdata_df, 'total_value', input$parcelorsqft)
    }
    if(input$includetaxexempt){
      apnlistcount <- table(plotdata_df$APN_list)
      multipleapnlists <- names(apnlistcount)[apnlistcount > 1]
      for(apn in multipleapnlists){
        plotdata_df$land_value[which(plotdata_df$APN_list == apn)] <-
          sum(plotdata_df$land_value[which(plotdata_df$APN_list == apn)])
        plotdata_df$impr_value[which(plotdata_df$APN_list == apn)] <-
          sum(plotdata_df$impr_value[which(plotdata_df$APN_list == apn)])
        plotdata_df$total_value[which(plotdata_df$APN_list == apn)] <-
          sum(plotdata_df$total_value[which(plotdata_df$APN_list == apn)])
      }
      plotdata_df <- plotdata_df %>% filter(!(TAXSTAT == 0 & APN_list %in% multipleapnlists))
    }else(
      plotdata_df <- plotdata_df %>% filter(TAXSTAT == 1)
    )
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
    plotdata_df$land_print <- print_int(plotdata_df$land_value)
    plotdata_df$impr_print <- print_int(plotdata_df$impr_value)
    plotdata_df$total_print <- print_int(plotdata_df$total_value)
    plotdata_df$land_per_sqft_print <- print_2_digits(plotdata_df$land_value_per_sqft)
    plotdata_df$impr_per_sqft_print <- print_2_digits(plotdata_df$impr_value_per_sqft)
    plotdata_df$total_per_sqft_print <- print_2_digits(plotdata_df$total_value_per_sqft)
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
    tooltip_html_list <- c()
    for(i in 1:nrow(highlight_text_columns)){
      if(highlight_text_columns$text_option[i] %in% input$parcelhighlighttext){
        tooltip_html_list <- c(tooltip_html_list, 
                               paste0(highlight_text_columns$text_option[i], ': {{', highlight_text_columns$column_to_write[i], '}}'))
      }
    }
    tooltip_html <- paste(tooltip_html_list, collapse = '<br>')
    value_layer <- list(
      diskResolution = 6,
      get_position=~lon+lat,
      pickable=TRUE,
      radius=20,
      # coverage = 0.02,
      tooltip = use_tooltip(
        html = tooltip_html,
        style = "background: steelBlue; border-radius: 5px;"
      )
    )
    if(is.na(input$heightmultiplier)){
      value_layer[['elevation_scale']]=3
    }else{
      value_layer[['elevation_scale']]=3 * input$heightmultiplier
    }
    if(input$mapmode == 'twod'){
      value_layer[['get_fill_color']]="#FF0000"
      value_layer[['get_elevation']]=1
      value_layer[['radius']]=5
    }else{
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
      if(input$colortype == 'Zone Type'){
        value_layer[['get_fill_color']]=~zonecolor
      }else if(input$datatype == 'Total Value/SQFT'){
        value_layer[['get_fill_color']]=~totalvaluecolor
      }else if(input$datatype == 'Impr Value/SQFT'){
        value_layer[['get_fill_color']]=~imprvaluecolor
      }else if(input$datatype == 'Land Value/SQFT'){
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
  
  observeEvent(input$selectall, {
    updatePickerInput(session, "zone", selected = c('Unzoned',
                                                    'Single-Family',
                                                    'Mixed-Use',
                                                    'Multi-Family',
                                                    'Commercial',
                                                    'Industrial',
                                                    'Agricultural',
                                                    'Special/Misc.',
                                                    'Multi-Zone'))
    updatePickerInput(session, "use", selected = all_uses)
  })
  
  observeEvent(input$clearlotsize, {
    updateNumericRangeInput(session, "lotsizerange", value = c(NA,NA))
  })
  
  observeEvent(input$clearlatlonrad, {
    updateNumericInput(session, "lat", value = NA)
    updateNumericInput(session, "lon", value = NA)
    updateNumericInput(session, "rad", value = NA)
  })
  
  observeEvent(input$filter, {
    if(length(input$city) == 0 | is.null(input$zone) | is.null(input$use)){
      shinyalert("Insufficient Filters", "Please select cities/communities, zones, and usages", type = "error")
    }else if(is.null(input$comm) & identical(input$city, 'SAN DIEGO')){
      shinyalert("Insufficient Filters", "Please select the community within San Diego", type = "error")
    }else{
      if(is.null(input$comm) & 'SAN DIEGO' %in% input$city){
        shinyalert("Insufficient Filters", "No community was selected in San Diego City, so the map will not include San Diego City parcels", type = "warning")
      }
      refilter()
      layer_properties <- layerdata()
      legend_table <- legenddata()
      map_zoom <- 8.25
      if(!is.na(input$lat) & !is.na(input$lon)){
        map_centroid <- c(input$lat, input$lon)
        map_zoom <- 12.25
      }else{
        # San Diego centroid is around (33, -116.75)
        map_centroid <- c(mean(values$plot_df$lat), mean(values$plot_df$lon))
        if(sum(values$plot_df$shape_area)>1e9){
          map_zoom <- 8.25
        }else if(sum(values$plot_df$shape_area)>7.5e8){
          map_zoom <- 9.25
        }else if(sum(values$plot_df$shape_area)>5e8){
          map_zoom <- 10.25
        }else if(sum(values$plot_df$shape_area)>2.5e8){
          map_zoom <- 11.25
        }else{
          map_zoom <- 12.25
        }
      }
      output$deck <- renderDeckgl({
        deckgl(longitude=map_centroid[2],
               latitude=map_centroid[1],
               zoom=map_zoom,
               pitch=45.0,
               width='100%',
               height="100%",
               bearing=0) %>%
          add_mapbox_basemap("mapbox://styles/mapbox/light-v11") %>%
          add_column_layer(data=values$plot_df, properties=layer_properties)
      })
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
        '<b style = "border: solid; border-width: 1px; border-color: black; border-radius: 10px; white-space: pre;"> Scroll &#x2193 for usage table</b>'
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
    }
  })
  
  output$downloadData <- downloadHandler(
    filename = "dashboardata.csv",
    content = function(file) {
      write.csv(values$plot_df[, 1:14], file, row.names = FALSE)
    }
  )
}