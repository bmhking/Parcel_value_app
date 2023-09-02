library(tableHTML)
library(readr)
library(ggplot2)
library(rjson)
library(DT)
library(shinyWidgets)
options(scipen=999)
use_text <- fromJSON(file = "data/use_code_sd.txt")
use_df <- do.call("rbind", lapply(use_text$fields[34][[1]][[5]][[4]], as.data.frame))
zones_list <- c("Unzoned", "Single-Family", 'Mixed-Use', 'Multi-Family', 
                'Commercial', 'Industrial', 'Agricultural', 'Special/Misc.')
output_colnames <- c('Zone Type', 'Total Area in SQFT', 'Land Value per SQFT', 'Impr Value per SQFT', 'Total Value per SQFT')
output_colnames2 <- c('Usage', 'Total Area in SQFT', 'Land Value per SQFT', 'Impr Value per SQFT', 'Total Value per SQFT')
city_prop_tax_revenue <- data.frame(city=c('CARLSBAD', 'CHULA VISTA', 'CORONADO', 'DEL MAR', 'EL CAJON', 'ENCINITAS', 'ESCONDIDO', 'IMPERIAL BEACH', 'LA MESA', 'LEMON GROVE', 'NATIONAL CITY', 'OCEANSIDE', 'POWAY', 'SAN MARCOS', 'SAN DIEGO', 'SANTEE', 'SOLANA BEACH', 'VISTA'), 
                                    actual_prop_tax=c(84200000, 40877000, 39357663, 7532110, 13491146, 57756627, 35068340, 8450100, 16937640, 6826468, 13924393, 85070732, 26256293, 29253790, 706200000, 24588330, 9235000, 33589780))
print_2_digits <- function(x){
  return(format(round(x, digits=2), nsmall = 2) )
}
Sys.setenv(MAPBOX_API_TOKEN = "pk.eyJ1IjoiYm1oa2luZyIsImEiOiJjbGw5bXowNXMxNHhhM2xxaGF3OWFhdTNlIn0.EH2wndceM6KvF0Pp8_oBNQ")
# gg_df <- read_csv("data/parcel_value_sdcounty.csv")
tooltip_html <- "Zoning Type: {{zoning_type_text}}<br>Usage: {{use_type}}<br>Land Value: {{land_print}}<br>Impr Value: {{impr_print}}<br>Total Value: {{total_print}}"
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
    plotdata_df$city_total_area <- sum(plotdata_df$shape_area)
    plotdata_df$use_type <- use_df$name[match(plotdata_df$use_type, use_df$code)]
    plotdata_df_agg <- plotdata_df %>% group_by(zoning_type_text) %>% 
      summarize(Zone_Area = sum(as.numeric(shape_area)),
                Zone_Land_Value = sum(as.numeric(land_value))/sum(as.numeric(shape_area)),
                Zone_Impr_Value = sum(as.numeric(impr_value))/sum(as.numeric(shape_area)),
                Zone_Total_Value = sum(as.numeric(total_value))/sum(as.numeric(shape_area)))
    plotdata_df <- plotdata_df %>% inner_join(plotdata_df_agg, by=join_by(zoning_type_text))
    plotdata_df <- plotdata_df %>% filter(zoning_type_text %in% input$zone)
    plotdata_df$land_print <- print_2_digits(plotdata_df$land_value_per_sqft)
    plotdata_df$impr_print <- print_2_digits(plotdata_df$impr_value_per_sqft)
    plotdata_df$total_print <- print_2_digits(plotdata_df$total_value_per_sqft)
    plotdata_df_expanded <- plotdata_df %>% group_by(use_type) %>% 
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
    if(input$colortype == 'Zoning Type'){
      if(input$datatype == 'Total Value per SQFT'){
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
      }else if(input$datatype == 'Impr Value per SQFT'){
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
      }else if(input$datatype == 'Land Value per SQFT'){
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
    }else{
      if(input$datatype == 'Total Value per SQFT'){
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
      }else if(input$datatype == 'Land Value per SQFT'){
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
      }else if(input$datatype == 'Impr Value per SQFT'){
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
  
  
  observeEvent(input$filter, {
    refilter()
    layer_properties <- layerdata()
    deckgl_proxy('deck') %>%
      add_column_layer(data=values$plot_df, properties=layer_properties)%>%
      update_deckgl()
    output$taxefficiency <- renderText({
      chosen_city <- isolate(input$city)
      if(all(chosen_city %in% city_prop_tax_revenue$city)){
        total_prop_tax_base <- sum(values$agg_df$Zone_Total_Value * values$agg_df$Zone_Area)
        if(length(chosen_city) == 1){
          paste('On average,', chosen_city[1], 'collects', sprintf("%1.2f%%", 10000*sum(city_prop_tax_revenue$actual_prop_tax[city_prop_tax_revenue$city %in% chosen_city])/total_prop_tax_base), 'of potential property tax base based on 1% rate')
        }else{
          paste('On average, the selected cities collect', sprintf("%1.2f%%", 10000*sum(city_prop_tax_revenue$actual_prop_tax[city_prop_tax_revenue$city %in% chosen_city])/total_prop_tax_base), 'of potential property tax base based on 1% rate')
        }
      }else{
        'No data available'
      }
    })
    output$summarytable <- render_tableHTML({
      display_df <- values$agg_df[, 1:5]
      display_df <- display_df[order(match(display_df$zoning_type_text, zones_list)), c('zoning_type_text', 'Zone_Area', 'Zone_Land_Value', 'Zone_Impr_Value', 'Zone_Total_Value')]
      colnames(display_df) <- output_colnames
      display_df %>% 
        mutate_if(is.numeric, print_2_digits) %>%
        tableHTML(widths = c(100, rep(150, 4)),
                  rownames = FALSE) %>% 
        add_css_column(css = list('text-align', 'right'), 
                       columns = output_colnames[2:length(output_colnames)]) %>%
        add_css_conditional_column(conditional = '==', 
                                   value = 'Single-Family', 
                                   css = list('background-color', 'yellow'), 
                                   columns = 'Zone Type') %>% 
        add_css_conditional_column(conditional = '==', 
                                   value = 'Mixed-Use', 
                                   css = list('background-color', 'coral'), 
                                   columns = 'Zone Type') %>% 
        add_css_conditional_column(conditional = '==', 
                                   value = 'Multi-Family', 
                                   css = list('background-color', 'orange'), 
                                   columns = 'Zone Type') %>% 
        add_css_conditional_column(conditional = '==', 
                                   value = 'Commercial', 
                                   css = list('background-color', 'red'), 
                                   columns = 'Zone Type') %>% 
        add_css_conditional_column(conditional = '==', 
                                   value = 'Industrial', 
                                   css = list(c('background-color', 'color'), c('purple', 'white')), 
                                   columns = 'Zone Type') %>% 
        add_css_conditional_column(conditional = '==', 
                                   value = 'Agricultural', 
                                   css = list(c('background-color', 'color'), c('green', 'white')), 
                                   columns = 'Zone Type') %>% 
        add_css_conditional_column(conditional = '==', 
                                   value = 'Special/Misc.', 
                                   css = list(c('background-color', 'color'), c('blue', 'white')), 
                                   columns = 'Zone Type')
    })
    output$expandedtable <- renderDT({
      display_df <- values$expanded_df[, 1:5]
      display_df <- display_df[order(match(display_df$use_type, zones_list)), c('use_type', 'Zone_Area', 'Zone_Land_Value', 'Zone_Impr_Value', 'Zone_Total_Value')]
      display_df$use_type <- as.factor(display_df$use_type)
      colnames(display_df) <- output_colnames2
      datatable(display_df %>% mutate_if(is.numeric, print_2_digits), filter = 'top', rownames = FALSE)
    })
    output$valueplot <- renderPlot({
      display_df <- data.frame(zone=rep(values$agg_df$zoning_type_text, each=2), 
                               value=c(values$agg_df$Zone_Land_Value, values$agg_df$Zone_Impr_Value),
                               type=rep(c('Zone_Land_Value', 'Zone_Impr_Value'), times=length(table(values$agg_df$zoning_type_text))))
      display_df$value <- display_df$value[c(rep(1:nrow(values$agg_df), each=2) + rep(c(0,nrow(values$agg_df)), times=nrow(values$agg_df)))]
      ggplot(display_df, aes(fill=type, x=zone, y=value)) +
        geom_bar(position="stack", stat="identity") +
        scale_fill_manual(labels = c("Impr Value per SQFT", "Land Value per SQFT"), values = c("blue", "red")) + 
        labs(fill=NULL) +
        theme_classic() +
        theme(axis.title.x=element_blank(), 
              axis.title.y=element_blank(), 
              aspect.ratio = 1/2,
              legend.position = 'top') +
        coord_flip()  +
        scale_y_continuous(expand = c(0, NA))
    })
  })
  
  observeEvent(input$datatype, {
    layer_properties <- layerdata()
    deckgl_proxy('deck') %>%
      add_column_layer(data=values$plot_df, properties=layer_properties)%>%
      update_deckgl()
  })  
  
  observeEvent(input$colortype, {
    layer_properties <- layerdata()
    deckgl_proxy('deck') %>%
      add_column_layer(data=values$plot_df, properties=layer_properties)%>%
      update_deckgl()
  })
}