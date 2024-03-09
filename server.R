library(tableHTML)
library(readr)
library(ggplot2)
library(rjson)
library(DT)
library(shinyWidgets)
options(scipen=999)
# gg_df <- read_csv("data/parcel_value_sdcounty.csv")
# use_text <- fromJSON(file = "data/use_code_sd.txt")
use_df <- do.call("rbind", lapply(use_text$fields[34][[1]][[5]][[4]], as.data.frame))
zones_list <- c("Unzoned", "Single-Family", 'Mixed-Use', 'Multi-Family', 
                'Commercial', 'Industrial', 'Agricultural', 'Special/Misc.', 'Multi-Zone')
output_colnames <- c('Zone Type', 'Total Area in SQFT', 'Land Value/SQFT', 'Impr Value/SQFT', 'Total Value/SQFT')
output_colnames2 <- c('Usage', 'Total Area in SQFT', 'Land Value/SQFT', 'Impr Value/SQFT', 'Total Value/SQFT')
city_prop_tax_revenue <- data.frame(city=c('CARLSBAD', 'CHULA VISTA', 'CORONADO', 'DEL MAR', 'EL CAJON', 'ENCINITAS', 'ESCONDIDO', 'IMPERIAL BEACH', 'LA MESA', 'LEMON GROVE', 'NATIONAL CITY', 'OCEANSIDE', 'POWAY', 'SAN MARCOS', 'SAN DIEGO', 'SANTEE', 'SOLANA BEACH', 'VISTA'), 
                                    actual_prop_tax=c(84200000, 40877000, 39357663, 7532110, 13491146, 57756627, 35068340, 8450100, 16937640, 6826468, 13924393, 85070732, 26256293, 29253790, 706200000, 24588330, 9235000, 33589780))
print_2_digits <- function(x){
  return(format(round(x, digits=2), nsmall = 2) )
}
Sys.setenv(MAPBOX_API_TOKEN = "pk.eyJ1IjoiYm1oa2luZyIsImEiOiJjbGw5bXowNXMxNHhhM2xxaGF3OWFhdTNlIn0.EH2wndceM6KvF0Pp8_oBNQ")
# gg_df <- read_csv("{data/parcel_value_sdcounty.csv")
tooltip_html <- "APN: {{APN_list}}<br>PARCELID: {{PARCELID}}<br>Zone Type: {{zoning_type_text}}<br>Usage: {{use_type_text}}<br>Area in SQFT: {{shape_print}}<br>Land Value/SQFT: {{land_print}}<br>Impr Value/SQFT: {{impr_print}}<br>Total Value/SQFT: {{total_print}}"
server <- function(input, output, session) {
  output$deck <- renderDeckgl({
      deckgl(longitude=-116.75, 
             latitude=33,
             zoom=8.25,
             pitch=45.0,
             width = '100%', 
             height = "100%",
             bearing=0) %>%
        add_mapbox_basemap("mapbox://styles/mapbox/light-v11")
  })
  values <- reactiveValues()
  values2 <- reactiveValues()
  refilter <- eventReactive(input$filter, {
    plotdata_df <- gg_df
    plotdata_df <- plotdata_df %>% filter(SITUS_COMMUNITY %in% input$city)
    plotdata_df <- plotdata_df %>% filter(use_type_text %in% input$use)
    plotdata_df$city_total_area <- sum(plotdata_df$shape_area)
    plotdata_df_agg <- plotdata_df %>% group_by(zoning_type_text) %>% 
      summarize(Zone_Area = sum(as.numeric(shape_area)),
                Zone_Land_Value = sum(as.numeric(land_value))/sum(as.numeric(shape_area)),
                Zone_Impr_Value = sum(as.numeric(impr_value))/sum(as.numeric(shape_area)),
                Zone_Total_Value = sum(as.numeric(total_value))/sum(as.numeric(shape_area)))
    plotdata_df_agg[nrow(plotdata_df_agg) + 1, ] <- list(zoning_type_text = "Total",
       Zone_Area = sum(plotdata_df_agg$Zone_Area),
       Zone_Land_Value = sum(plotdata_df_agg$Zone_Area*plotdata_df_agg$Zone_Land_Value) / sum(plotdata_df_agg$Zone_Area),
       Zone_Impr_Value = sum(plotdata_df_agg$Zone_Area*plotdata_df_agg$Zone_Impr_Value) / sum(plotdata_df_agg$Zone_Area),
       Zone_Total_Value = sum(plotdata_df_agg$Zone_Area*plotdata_df_agg$Zone_Total_Value) / sum(plotdata_df_agg$Zone_Area))
    plotdata_df <- plotdata_df %>% inner_join(plotdata_df_agg, by=join_by(zoning_type_text))
    plotdata_df <- plotdata_df %>% filter(zoning_type_text %in% input$zone) %>%
      filter(use_type_text %in% input$use)
    plotdata_df$land_print <- print_2_digits(plotdata_df$land_value_per_sqft)
    plotdata_df$impr_print <- print_2_digits(plotdata_df$impr_value_per_sqft)
    plotdata_df$total_print <- print_2_digits(plotdata_df$total_value_per_sqft)
    plotdata_df$shape_print <- print_2_digits(plotdata_df$shape_area)
    plotdata_df_expanded <- plotdata_df %>% group_by(use_type_text) %>% 
      summarize(Zone_Area = sum(as.numeric(shape_area)),
                Zone_Land_Value = sum(as.numeric(land_value))/sum(as.numeric(shape_area)),
                Zone_Impr_Value = sum(as.numeric(impr_value))/sum(as.numeric(shape_area)),
                Zone_Total_Value = sum(as.numeric(total_value))/sum(as.numeric(shape_area)))
    values$agg_df <- plotdata_df_agg
    values$plot_df <- plotdata_df
    values$expanded_df <- plotdata_df_expanded
    return(list(agg_df = plotdata_df_agg, plot_df = plotdata_df, expanded_df = plotdata_df_expanded))
  })
  
  layerdata <- reactive({
    value_layer <- list()
    if(input$colortype == 'Zone Type'){
      if(input$datatype == 'Total Value/SQFT'){
        value_layer <- list(
          get_position=~lon+lat,
          get_elevation=~total_value_per_sqft,
          elevation_scale=3,
          pickable=TRUE,
          get_fill_color=~zonecolor,
          coverage = 0.02,
          tooltip = use_tooltip(
            html = tooltip_html,
            style = "background: steelBlue; border-radius: 5px;"
          ))
      }else if(input$datatype == 'Impr Value/SQFT'){
        value_layer <- list(
          get_position=~lon+lat,
          get_elevation=~impr_value_per_sqft,
          elevation_scale=3,
          pickable=TRUE,
          get_fill_color=~zonecolor,
          coverage = 0.02,
          tooltip = use_tooltip(
            html = tooltip_html,
            style = "background: steelBlue; border-radius: 5px;"
          ))
      }else if(input$datatype == 'Land Value/SQFT'){
        value_layer <- list(
          get_position=~lon+lat,
          get_elevation=~land_value_per_sqft,
          elevation_scale=3,
          pickable=TRUE,
          get_fill_color=~zonecolor,
          coverage = 0.02,
          tooltip = use_tooltip(
            html = tooltip_html,
            style = "background: steelBlue; border-radius: 5px;"
          ))
      }
    }else if(input$colortype == 'Value/SQFT'){
      if(input$datatype == 'Total Value/SQFT'){
        value_layer <- list(
          get_position=~lon+lat,
          get_elevation=~total_value_per_sqft,
          elevation_scale=3,
          pickable=TRUE,
          get_fill_color=~totalvaluecolor,
          coverage = 0.02,
          tooltip = use_tooltip(
            html = tooltip_html,
            style = "background: steelBlue; border-radius: 5px;"
          ))
      }else if(input$datatype == 'Land Value/SQFT'){
        value_layer <- list(
          get_position=~lon+lat,
          get_elevation=~land_value_per_sqft,
          elevation_scale=3,
          pickable=TRUE,
          get_fill_color=~landvaluecolor,
          coverage = 0.02,
          tooltip = use_tooltip(
            html = tooltip_html,
            style = "background: steelBlue; border-radius: 5px;"
          ))
      }else if(input$datatype == 'Impr Value/SQFT'){
        value_layer <- list(
          get_position=~lon+lat,
          get_elevation=~impr_value_per_sqft,
          elevation_scale=3,
          pickable=TRUE,
          get_fill_color=~imprvaluecolor,
          coverage = 0.02,
          tooltip = use_tooltip(
            html = tooltip_html,
            style = "background: steelBlue; border-radius: 5px;"
          ))
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
  
  
  observeEvent(input$filter, {
    refilter()
    layer_properties <- layerdata()
    legend_table <- legenddata()
    deckgl_proxy('deck') %>%
      add_column_layer(data=values$plot_df, properties=layer_properties )%>%
      update_deckgl()
    output$summarytable <- render_tableHTML({
      display_df <- values$agg_df[, 1:5]
      display_df <- display_df[order(match(display_df$zoning_type_text, c(zones_list, 'total'))), 
        c('zoning_type_text', 'Zone_Area', 'Zone_Land_Value', 'Zone_Impr_Value', 'Zone_Total_Value')]
      colnames(display_df) <- output_colnames
      display_df %>% 
        mutate_if(is.numeric, print_2_digits) %>%
        tableHTML(widths = c(100, rep(150, 4)),
                  rownames = FALSE) %>% 
        add_css_column(css = list('text-align', 'right'), 
                       columns = output_colnames[2:length(output_colnames)])
    })
    output$expandedtable <- renderDT({
      display_df <- values$expanded_df[, 1:5]
      display_df <- display_df[order(match(display_df$use_type_text, zones_list)), c('use_type_text', 'Zone_Area', 'Zone_Land_Value', 'Zone_Impr_Value', 'Zone_Total_Value')]
      display_df$use_type_text <- as.factor(display_df$use_type_text)
      colnames(display_df) <- output_colnames2
      datatable(display_df %>% mutate_if(is.numeric, print_2_digits), filter = 'top', rownames = FALSE)
    })
    output$valueplot <- renderPlot({
      display_df <- data.frame(zone=rep(values$agg_df$zoning_type_text, each=2), 
                               value=c(values$agg_df$Zone_Land_Value, values$agg_df$Zone_Impr_Value),
                               type=rep(c('Zone_Land_Value', 'Zone_Impr_Value'), times=length(table(values$agg_df$zoning_type_text))))
      display_df$value <- display_df$value[c(rep(1:nrow(values$agg_df), each=2) + rep(c(0,nrow(values$agg_df)), times=nrow(values$agg_df)))]
      display_df$zone<- factor(display_df$zone, levels=rev(sort(unique(display_df$zone))))
      ggplot(display_df, aes(fill=type, x=zone, y=value)) +
        geom_bar(position="stack", stat="identity") +
        scale_fill_manual(labels = c("Impr Value/SQFT", "Land Value/SQFT"), values = c("blue", "red")) + 
        labs(fill=NULL) +
        theme_classic() +
        theme(axis.title.x=element_blank(), 
              axis.title.y=element_blank(), 
              legend.position = 'top') +
        coord_flip()  +
        scale_y_continuous(expand = c(0, NA))
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
                                            c('#0B5345', '#0E6655', '#1E8449', '#229954', '#27AE60', '#9ACD32', '#E1E000', '#FEBA4F', '#FF7F50', '#FF4500', '#D21404', '#C54BBC', '#603FEF')),
                                 column = 'Color') %>%
          add_css_header(css = list('opacity', 0), headers = 1)
      }
    })
  })
}