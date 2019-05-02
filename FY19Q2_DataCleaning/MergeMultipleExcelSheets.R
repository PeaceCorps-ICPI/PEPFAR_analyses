#Purpose: Merge VRT Indicator Extracts for Namibia Reporting Dashboard 
#Date: 5/1/2019
#Data source: Indicator Extract after VBA macro code is run to delete unnecessary sheets
#VBC Macro Code saved here: https://github.com/PeaceCorps-ICPI/PEPFAR_analyses/edit/master/FY19Q2_DataCleaning/VRT_IndicatorExtract_PP_PREV_Cleanup.md

#install packages (purr)
#install.packages('openxlsx')
#install.packages(readxl)
#library(openxlsx)
library(readxl)
library(purrr)
library(tidyverse)

#merge all sheets in indicator extract, adding columns in a wide format
file <- 'VRT_Extract_ksato_30_Apr_2019_08_00_22.xlsx'
sheets <- excel_sheets(file)
df <- map_df(sheets, ~ read_excel(file, sheet = .x))

#check column names
colnames(df)

#drop any unnecessary columns
subdf <- df[c(-(1:2), -(22:23), -(27:28),  -(33:46), -(209:234), -(290:387))]
colnames(subdf)

#reshape dataset from wide to long
longdf <- gather(subdf, key= "disaggregate", "value", 34:251, na.rm=TRUE)

write.xlsx(subdf, file = "VRTmergedNamibia_HE_CED_ED.xlsx", colNames = TRUE)
