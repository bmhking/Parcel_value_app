library(tableHTML)
library(readr)
zones_list <- c("Unzoned", "Single-Family", 'Mixed-Use', 'Multi-Family', 
                'Commercial', 'Industrial', 'Agricultural', 'Special/Misc.')
output_colnames <- c('Zone Type', 'Total Area in SQFT', 'Land Value per SQFT', 'Impr Value per SQFT', 'Total Value per SQFT')
city_prop_tax_revenue <- data.frame(city=c('CARLSBAD', 'CHULA VISTA', 'CORONADO', 'DEL MAR', 'EL CAJON', 'ENCINITAS', 'ESCONDIDO', 'IMPERIAL BEACH', 'LA MESA', 'LEMON GROVE', 'NATIONAL CITY', 'OCEANSIDE', 'POWAY', 'SAN MARCOS', 'SAN DIEGO', 'SANTEE', 'SOLANA BEACH', 'VISTA'), 
                                    actual_prop_tax=c(84200000, 40877000, 39357663, 7532110, 13491146, 57756627, 35068340, 8450100, 16937640, 6826468, 13924393, 85070732, 26256293, 29253790, 706200000, 24588330, 9235000, 33589780))
print_2_digits <- function(x){
  return(format(round(x, digits=2), nsmall = 2) )
}
Sys.setenv(MAPBOX_API_TOKEN = "pk.eyJ1IjoiYm1oa2luZyIsImEiOiJjbGw5bXowNXMxNHhhM2xxaGF3OWFhdTNlIn0.EH2wndceM6KvF0Pp8_oBNQ")
gg_df <- read_csv("data/parcel_value_sdcounty.csv")
property_value_layer <- list(
  get_position=~lon+lat,
  get_elevation=~total_value_per_sqft,
  elevation_scale=3,
  pickable=TRUE,
  get_fill_color=~color,
  coverage = 0.02)
server <- function(input, output, session) {
  output$deck <- renderDeckgl({
      deckgl(longitude=-116.75, 
             latitude=33,
             zoom=8.25,
             pitch=45.0,
             width = '100%', 
             height = "100%",
             bearing=0) %>%
        add_mapbox_basemap("mapbox://styles/mapbox/light-v11") %>%
        add_column_layer(data=gg_df, properties=property_value_layer)
  })
  
  tabledata <- reactive({
    plotdata_df <- gg_df
    if(input$city != 'COUNTY'){
      plotdata_df <- plotdata_df %>% filter(SITUS_COMMUNITY==input$city)
    }
    plotdata_df$city_total_area <- sum(plotdata_df$shape_area)
    plotdata_df_agg <- plotdata_df %>% group_by(zoning_type_text) %>% 
      summarize(Zone_Area = sum(as.numeric(shape_area)),
                Zone_Land_Value = sum(as.numeric(land_value))/sum(as.numeric(shape_area)),
                Zone_Impr_Value = sum(as.numeric(impr_value))/sum(as.numeric(shape_area)),
                Zone_Total_Value = sum(as.numeric(total_value))/sum(as.numeric(shape_area)))
    plotdata_df_agg
  })
  
  plotdata <- reactive({
    plotdata_df <- gg_df
    if(input$city != 'COUNTY'){
      plotdata_df <- plotdata_df %>% filter(SITUS_COMMUNITY==input$city)
    }
    plotdata_df$city_total_area <- sum(plotdata_df$shape_area)
    plotdata_df_agg <- plotdata_df %>% group_by(zoning_type_text) %>% 
      summarize(Zone_Area = sum(as.numeric(shape_area)),
                Zone_Land_Value = sum(as.numeric(land_value))/sum(as.numeric(shape_area)),
                Zone_Impr_Value = sum(as.numeric(impr_value))/sum(as.numeric(shape_area)),
                Zone_Total_Value = sum(as.numeric(total_value))/sum(as.numeric(shape_area)))
    plotdata_df <- plotdata_df %>% inner_join(plotdata_df_agg, by=join_by(zoning_type_text))
    if(input$zone != 'All Zones'){
      plotdata_df <- plotdata_df %>% filter(zoning_type_text==input$zone)
    }
    plotdata_df
  })
  
  layerdata <- reactive({
    if(input$datatype == 'Total Value per SQFT'){
      value_layer <- list(
        get_position=~lon+lat,
        get_elevation=~total_value_per_sqft,
        elevation_scale=3,
        pickable=TRUE,
        get_fill_color=~color,
        coverage = 0.02)
    }else if(input$datatype == 'Impr Value per SQFT'){
      value_layer <- list(
        get_position=~lon+lat,
        get_elevation=~impr_value_per_sqft,
        elevation_scale=3,
        pickable=TRUE,
        get_fill_color=~color,
        coverage = 0.02)
    }else if(input$datatype == 'Land Value per SQFT'){
      value_layer <- list(
        get_position=~lon+lat,
        get_elevation=~land_value_per_sqft,
        elevation_scale=3,
        pickable=TRUE,
        get_fill_color=~color,
        coverage = 0.02)
    }
    value_layer
  })
  
  observeEvent(input$city, {
    plot_df <- plotdata()
    table_df <- tabledata()
    layer_properties <- layerdata()
    deckgl_proxy('deck') %>%
      add_column_layer(data=plot_df, properties=layer_properties)%>%
      update_deckgl()
    output$taxefficiency <- renderText({
      if(input$city %in% city_prop_tax_revenue$city){
        total_prop_tax_base <- sum(table_df$Zone_Total_Value * table_df$Zone_Area)
        paste('On average, this city collects', sprintf("%1.2f%%", 10000*city_prop_tax_revenue$actual_prop_tax[city_prop_tax_revenue$city == input$city]/total_prop_tax_base), 'of potential property tax base based on 1% rate')
      }else{
        'No data available'
      }
    })
    output$summarytable <- render_tableHTML({
        display_df <- table_df
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
  })
  observeEvent(input$zone, {
    plot_df <- plotdata()
    layer_properties <- layerdata()
    deckgl_proxy('deck') %>%
        add_column_layer(data=plot_df, properties=layer_properties)%>%
        update_deckgl()
  })
  observeEvent(input$datatype, {
    plot_df <- plotdata()
    layer_properties <- layerdata()
    deckgl_proxy('deck') %>%
      add_column_layer(data=plot_df, properties=layer_properties)%>%
      update_deckgl()
  })
}