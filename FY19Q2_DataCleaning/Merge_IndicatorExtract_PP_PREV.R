
#To merge PC PEPFAR indicators
#DataSource: VRT indicator extract
#Date 04/16/2019 KS

#set working directory and load libraries
setwd("C:/Users/Ksato/Peace Corps")

#install.packages("tidyverse")
#install.packages("readxl")

library(tidyverse)
library(readxl)

#read in datasets

df1<- readxl::read_xlsx("VRT_Extract_ksato_16_Apr_2019_21_26_20.xlsx")
df2 <- readxl::read_xlsx("VRT_Extract_ksato_16_Apr_2019_21_26_20.xlsx", 2)
df3 <- readxl::read_xlsx("VRT_Extract_ksato_16_Apr_2019_21_26_20.xlsx",3)

#merge longdf1 and longdf2
mergedf <- bind_rows (df1,df2,df3)

#Check column names
colnames(mergedf)

#keep only necessary columns
longdf1 <- subset(mergedf, select = c("PostName", "PostID", "FirstName", "LastName", "VolID", "VolunteerReportID", "Current Volunteer Project", "Sector", "APCD/PM", "VolunteerGeoTerm1",
                                    "VolunteerGeoTerm2", "VolunteerGeoTerm3", "ReportingPeriodID", "Reporting Period FY", "Reporting Period Name", "Reporting Period Start Date",
                                    "Reporting Period End Date", "IndicatorID", "IndicatorCode", "IndicatorTitle", "IndicatorDescription", "SUM_Additional_Total", "Males Under 1-Total-Additional",
                                    "Males 1-4-Total-Additional", "Males 5-9-Total-Additional","Males 10-14-Total-Additional", "Males 15-19-Total-Additional", "Males 20-24-Total-Additional",  
                                    "Males 25-29-Total-Additional", "Males 30-34-Total-Additional", "Males 35-39-Total-Additional",    
                                    "Males 40-44-Total-Additional", "Males 45-49-Total-Additional", "Males 50+-Total-Additional",             
                                    "Unknown Male-Total-Additional", "Females Under 1-Total-Additional", "Females 1-4-Total-Additional",           
                                    "Females 5-9-Total-Additional", "Females 10-14-Total-Additional", "Females 15-19-Total-Additional",        
                                    "Females 20-24-Total-Additional", "Females 25-29-Total-Additional", "Females 30-34-Total-Additional",         
                                    "Females 35-39-Total-Additional", "Females 40-44-Total-Additional", "Females 45-49-Total-Additional",         
                                    "Females 50+-Total-Additional", "Unknown Female-Total-Additional", "Males 0-9-Total-Additional",             
                                    "Males 40-49-Total-Additional", "Females 0-9-Total-Additional", "Females 40-49-Total-Additional",        
                                    "Males 25-49-Total-Additional", "Females 25-49-Total-Additional"))

#Check column names
colnames(longdf1)

#Check for N/A values
is.na(longdf1)

#Replace N/A values with blanks
longdf1 [is.na(longdf1)]=""
is.na(longdf1)

#Export dataset to csv 
write.csv(longdf1,"PEPFAR_indicatorextract_merge_20190416.csv", row.names = FALSE)
