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
options(scipen=999)
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
use_text <- fromJSON(file = "data/use_code_sd.txt")

## fairbanks ranch APN
# 269,303,305,302082, 302140, 302120,30216, 30222, 30223, 30224, 30225
## Scripps ranch APN
# 3190,3191,3192,3193,31940,31941,31942,31943,31944,3200,3201,32020,32021,32022,32023,32024,32028,32029,3203,3204,3205,3206,3207,3208,3209,363,364,32500,32501,32502,32503,32504,32505,32506,32511,32518,32519,3252,3253,3254,3255,3256,3257,3258,3259
## Logan Heights APN
# 5352,535400,535402,535403,535404,535405,535407,535408,535409,535410,535411,535413,535414,535415,535416,535417,535418,535419,53542,53543,53544,53545,53546,53547,53548,53549,53550,53551,53552,53553,53554,53557,53558,53559,53564,53565,53566,53567,53568,53569,53571,53572,53573,53574,53575,53576,53577,53578,53579,5358,5359,5450,5451,54520,54521,54522,54523,54524,54525,54527,54528,54529,54530,54531,54532,54533,54535,54536,54537,54538,54539,54540,54542,54543,54544,54545,54546,54547,54549,54550,54551,54552,54553,54554,54555,54556,54558,54559,54560,54561,54562,54563,54565,54566,54567,54568,54569,5458,5459,53800,53801,53802,53807,53808,53809,5381,5383,53840,53841,53842,53843,53845,53846,53849,53860,53862,53863,53864,53865,55000,55001,55002,55003,55004,55005,55006,55008,5501200,5501201,5501202,5501204,5501205,5501206,5501207,5501208,5501209,550121,550122,550123,550124,550125,550126,550127,550128,550129,55013,55014,55015,55016,55017
## Southcrest APN
# 55018,55019,55020,55021,55022,5503,55040,55041,55042,55043,55044,55045,55046,55047,55060,55063,55064,55065,55071,55075,55078,55079,55103,55104,55105009,55105013,55105014,55105015,55105016,55105018,55107006,55107007,55107008,55107009,5510701,5510800,5510801,55108032,55108033,55108037,55108039,55109,55113,55114,55115,55116,55117,55118,55119,5512,5513,55163,55164,5517,5518,5519
## Rancho Bernardo APN
# 272,273,274,313021,31330,31331,31332,31333,31334,31335,31336,31337,31339,31341,31342,31343,31344,31345,31347,31348,31349,31350,67800,67801,67804,67808,67809,6781,67820,67821,67822,67824,67825,67826,67827,67828,678300,67840,6787,6788,6789
## Santaluz APN
# 26921,26922,26923,26925,26926,26927,26928,26929,30311,30312,30317,30318,312290
## Mission Hills APN
# 442,443,44400,44401,44403,44404,44405,44407,44408,44409,44426,44427,44428,44438,44439,44440,44441,44442,444603,45101,45102,45111,451120,451121,45121,4517
## Hillcrest APN
# 44441,44442,44445,44446,44447,44448,44449,44450,44451,44452,44453,44456,444612,444613,44462,44463,44465,44466,44467,44468,44469,4447,44560,44561,44562,44563,44564,44565,451072,45109,45110,451193,45120,451272,45128,45129,4513700,45137010,45137011,45137013,45139,45140,45151013,45151027,45151028,45151029,4515103,4520,4521,452200,452202,452203,452204,452205,452206,452207,452208,452209,452210,452211,452212,452213,452215,452216,452217,452218,452219,45222,45223,45224,45225,45226,45227,45228,45229,45230,45231,45232,45233,45234,45235,452363,45237,45238,45239,45240,45243,45245,452481,452483,452484,452488,4525370,45253710,45253711,45253712,4525380,45253810,45253811,45253812,4525540,45255411,45255412,45255413,45255452,45255453,4525550
## University Heights APN
# 43808,43810,43815,43816,44412002,44412003,44413,44416,44417,44418,44419,44421,44422,44423,44424,44425,44434,44435,44436,44437,44459,44501,44503,44504,44505,44506,445071,445072,44510,44511,44512,44513,44514,44515,44518,44519,44520,44521,44522,44523,44526,44527,44528,44529,44531,44532,44533,445341,44537,44538,44539,44540,445411,44544,44546,44547,44548,44549,44550,44551,44552,44555,44556,44557
## Bankers Hill APN
# 45249,45253,45255,45257,4526,4527,53305,53306,53307,53308,53309,53310,53313,53315,53316,53317,53318,53319,53320,53325,53327,53328,53329,53330,53362
## Middletown APN
# 444604,444605,444606,444611,444614,45103,45104,45105,45106,451071,45108,451122,451123,45113,45114,45115,45116,45117,45118,451191,451192,45122,45123,45124,45125,45126,451271,45132,45133,45134,45135,45136,45137014,45137015,45137016,45137017,45138,45145,45146,45147,45148,45149,45150,4515100,45151017,45151018,45151019,45151021,45151025,45151026,45153,45154,45155,45156,45157,45158,4515903,4515904,45159077,45159103,45159104,45159105,45159106,45159107,45159108,45159109,4515911,45159134,4516,53301,53304,533051,533055
## Kensington APN
# 44001,44002,44003,44004,44005,44015,44016,44017,44018,44019,44020,44021,44033,44034,44035,44036,44037,44038,44048,44049,44050,44051,44054,44055,44065,44066,44067,45471,45472,45473,46135,4650,46523,46524,46525,46526,46527,46528,46529,4653,46540,46541,46542,46565,47101,47102,47105,47106
## Cherokee Point APN
# 44723,44724,44725,44726,44728,4473,4474,44756,44757,44758,44759,4476,4477
## Teralta APN
# 45474,45475,45476,47121,47122,47123,47124,47125,4712647130,471311,471312,471313,47135,47136,47137,47138,47139,47140,47144,47145,47146,47147,47148,47149
## Colina del Sol APN
# 47127,47128,47129,47132,47133,47134,47141,47143,47150,47151,47152,4715301,47153023,47153024,47153029,4715303,47203,47204,47216,47217,472181,472182,47227,47238,47239
## Azalea Park APN
# 45462,45463,45468,45469,47619,47627,47628,47635,47636,47637,47642,47643,47644,47645,47646,47648,47652,47655,47656,54006,54008,54009,54101,54165
## Barrio Logan APN
# 535616,535624,53803,53804,53805,53806,53821,53823,53824,53825,53826,53827,53844,53847,53848,5385,5386100,5386101,53861020,53861022,53861023,53861024,53861025,53866,53867,53868,53869,5387,5388,55023,55024,55025,55026,55028,55029,55048,55049,5505,55061,55062,55066,55067,55072,7600174,7600181,76002116,76002206,7600231,7600240,76021409,7602171
## Shelltown APN
# 55068,55069,55070,550712,55073,55074,55076,551302,551312,551342,55135,55143,55144,55145,55146,5515
## Ocean Beach APN
# 4480,4481,4482,4483,4484,44850,44851,44852,44853,44854,44855,44856,44857,4488
## Downtown APN
# 53302,53303,53311,53312,53321,53322,53323,53324,53331,53332,53333,53334,53335,53336,53337,53338,53339,5334,5335,53361,53363,5340,53418,53419,53420,53421,53422,53432,53433,53434,53435,53436,5350,53510,53511,53512,53513,53514,53515,53516,53517,53518,53519001,53519002,53519007,53519008,53519009,53519010,53519013,53519014,53519015,53519040,53519041,53534,53535,53536,53537,53538,53539,535401,535406,535412,53555,53556,53560,53561,53562,53563001,53563002,53563003,53563004,53563025,5357
## Bay Park APN
# 425,430,43602,43603019,43603024,43604009,43605,43606,43607,43608,43609,43610,43611,43612,43613,43614,43615
## Sunset Cliffs APN
# 448452,53001,53002,53003,53004,53005,53006,53038,53039,5304,53050,53051,53052,5310,53110,53140,53141,53142,53143,53144,53145,53146,53147,53201,53202,53203
## La Playa APN
# 53120,531353,531354,531355,531363,531593,531602,531612,53163,53164,53165,53166,53167,53168,53169,53170,53218,53219,532232,532233,53224,53225,53226,53227,53228,53229,53230,53231,53232,53233,53234,53235,53236,5324,76000201,76000302,76000304,76000103,76000106
## Loma Portal APN
# 44122,44123,44124,449611,449670,44968,44969,44970,44971,45001,45002,45003,450041,450042,450043,450044,45005,45006,45007,45008,45009,4501,4502,4503,45040,45041,45042,45043,45045,45076,45077,45078,530313,530314
## Point Loma Heights APM
# 4410,44113,44116,44125,44126,44137,44138,44166,44858,44859,4486,4487,449,53007,53008,53009,5301,53022,53023,53028,530302,530303,530304,530305,530311,530312,530315,530316,530351,530352,530363,530364,76010238,76010239,76010267
## Balboa Park West
# 45255,45262,45266,45271,53310,53319,53320,53329,53330
## Balboa Park East
# 45347,45352,45353,45358,45363,45369,53901,53907,53908,53914,53921,53927,53934,53940
## Alvarado Estates
# 46129,46140,46141,46142,46143,46144,46157001,46157002,46158009,46158011,46158013,46158014,46159,46160
## Convoy
# 356
## Kearny Mesa
# 356,369,42133,42135,42137,42138,42139
## Gaslamp
# 53357,53361,535053,535061,535082,535083,535084,535085,535092,535093,535094,535095,53534,53555
## East Village
# 53405,53406,53407,53418,53419,53420,53421,53422,53432,53433,53434,53435,53436,53510,53511,53512,53513,53514,53515,53516,53517,53518,53519001,53519002,53519007,53519008,53519009,53519010,53519013,53519014,53519015,53535,53536,53537,53538,53539,535401,535406,535412,53555,53556,53561,53562,53563001,53563002,53563003,53563004,53563025

use_df <- do.call("rbind", lapply(use_text$fields[34][[1]][[5]][[4]], as.data.frame))
zones_list <- c("Unzoned", "Single-Family", 'Mixed-Use', 'Multi-Family', 
                'Commercial', 'Industrial', 'Agricultural', 'Special/Misc.', 'Multi-Zone')
output_colnames <- c('Zone Type', 'Total Area in SQFT', 'Land Value/SQFT', 'Impr Value/SQFT', 'Total Value/SQFT')
output_colnames2 <- c('Usage', 'No. of Parcels', 'Total Area in SQFT', 'Mean Parcel Area', 'Land Value/SQFT', 'Impr Value/SQFT', 'Total Value/SQFT')
output_colnames3 <- c('Zone Type', 'No. of Parcels', 'Mean Parcel Area', 'Median Parcel Area')
city_prop_tax_revenue <- data.frame(city=c('CARLSBAD', 'CHULA VISTA', 'CORONADO', 'DEL MAR', 'EL CAJON', 'ENCINITAS', 'ESCONDIDO', 'IMPERIAL BEACH', 'LA MESA', 'LEMON GROVE', 'NATIONAL CITY', 'OCEANSIDE', 'POWAY', 'SAN MARCOS', 'SAN DIEGO', 'SANTEE', 'SOLANA BEACH', 'VISTA'), 
                                    actual_prop_tax=c(84200000, 40877000, 39357663, 7532110, 13491146, 57756627, 35068340, 8450100, 16937640, 6826468, 13924393, 85070732, 26256293, 29253790, 706200000, 24588330, 9235000, 33589780))
is_noninteger_column <- function(x){
  if(is.numeric(x)){
    return(!all(x==as.integer(x)))
  }else{
    return(FALSE)
  }
}
print_2_digits <- function(x){
  return(format(round(x, digits=2), nsmall = 2))
}
Sys.setenv(MAPBOX_API_TOKEN = "pk.eyJ1IjoiYm1oa2luZyIsImEiOiJjbGw5bXowNXMxNHhhM2xxaGF3OWFhdTNlIn0.EH2wndceM6KvF0Pp8_oBNQ")
# gg_df <- read_csv("{data/parcel_value_sdcounty.csv")
tooltip_html <- "APN: {{APN_list}}<br>Zone Type: {{zoning_type_text}}<br>Usage: {{use_type_text}}<br>Area in SQFT: {{shape_print}}<br>Land Value/SQFT: {{land_print}}<br>Impr Value/SQFT: {{impr_print}}<br>Total Value/SQFT: {{total_print}}"
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
      plotdata_df <- plotdata_df %>% filter(APN_list %in% APN_selected)
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
        mutate_if(is_noninteger_column, print_2_digits) %>%
        tableHTML(widths = c(100, rep(150, 4)),
                  rownames = FALSE) %>% 
        add_css_column(css = list('text-align', 'right'), 
                       columns = output_colnames[2:length(output_colnames)])
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
                       columns = output_colnames3[2:length(output_colnames3)])
    })
    output$scrolldowntip <- renderText({
      '<h4>&#x2193 Scroll down to view usage-level summary</h4>'
    })
    # output$valueplot <- renderPlot({
    #   display_df <- data.frame(zone=rep(values$agg_df$zoning_type_text, times=2), 
    #                            Percentage=c(values$agg_df$Zone_Area, 
    #                                    values$agg_df$Zone_Total_Value_2),
    #                            type=rep(c('Area', 'Total Value'), each=length(table(values$agg_df$zoning_type_text))))
    #   display_df[display_df$type=='Area', 'Percentage'] <- display_df[display_df$type=='Area', 'Percentage']/display_df[(display_df$type=='Area') & (display_df$zone=='Total'), 'Percentage']
    #   display_df[display_df$type=='Total Value', 'Percentage'] <- display_df[display_df$type=='Total Value', 'Percentage']/display_df[(display_df$type=='Total Value') & (display_df$zone=='Total'), 'Percentage']
    #   display_df <- display_df[display_df$zone != 'Total', ]
    #   display_df$Percentage_label <- paste0(round(display_df$Percentage*100, 2), "%")
    #   display_df$zone<- factor(display_df$zone, levels=rev(sort(unique(display_df$zone))))
    #   ggplot(display_df, aes(fill=Percentage, y=zone, x=type), linetype=0) +
    #     geom_tile() + 
    #     geom_label(aes(label = Percentage_label)) + 
    #       theme_classic() +
    #       theme(axis.line=element_blank(),
    #             axis.title.x=element_blank(),
    #             axis.title.y=element_blank()) + 
    #       scale_fill_gradient(low='white', high='blue', limits=c(0,1), labels=percent)
    # })
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