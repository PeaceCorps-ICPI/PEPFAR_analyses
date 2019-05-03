#Date updated: 05/03/2019
#Purpose: To subset OU X IM Genie Extract for OGHH dashboard
#Software: R

memory.limit(size = 900000)
getwd()

#Load Packages
#B.Installation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
.libPaths(c("C:/Users/knoykhovich/R", .libPaths()))
library(tidyverse)
library(ICPIutilities)


# Import First Dataset: Genie X OU x IM -----------------------------------

#read genie file with ICPI Utilities functions
df1 <- read_msd("Genie_Daily_OUxIM_20190503.txt")
colnames(df1)

#drop unnecessary columns 
df2 <- df1 %>% 
  select(operatingunit, countryname, primepartner:implementingmechanismname, indicator:standardizeddisaggregate,
         categoryoptioncomboname:statushiv, otherdisaggregate:coarsedisaggregate, fiscal_year:targets, qtr2, qtr4, cumulative)

#Replace N/A values with blanks
df2 [is.na(df2)]=""
is.na(df2)

#check disaggregates
unique(df2$standardizeddisaggregate)

#remove exit without graduation from program status
df3 <- filter(df2, standardizeddisaggregate != "ProgramStatus" | categoryoptioncomboname != "Exited without Graduation")

#remove Age/Sex/Service
df4 <- filter(df3, standardizeddisaggregate != "Age/Sex/Service")
colnames(df4)

# #remove prior year's data, keep only Fy19 Q2
# df5 <- filter(df4, fiscal_year != "2018")



df5 <- df4

#reshape from wide to long, putting all results and targets in one column, removes rows with missing values
longdf <- gather(df5, key = "period", "value", targets:cumulative, na.rm=TRUE)


#add a new column "new period" to merge fiscal year and period name
longdf$newperiod <- paste("FY", longdf$fiscal_year, longdf$period, sep = "")

#drop old fiscal year and period column
longdf2 <- longdf %>% 
  select(-fiscal_year, -period, -trendsfine, -trendssemifine, -trendscoarse, -statushiv)

#reorder column names to match previous dataset   
colnames(longdf2)
longdf3 <- longdf2[c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,17)]

#rename column "new period" to "period
colnames(longdf3)
names(longdf3)[17] <- "period"

#export dataset to csv for reading into Tableau, update date in filename
write.csv(longdf3, "GenieOUxIMclean_201900503.csv", row.names = FALSE)

# PRIOR CODE
# adjust fy2017 apr OVC SERV total N to fall under Total Numerator, instead of Program Status
# df6 <- df5 %>% 
#   mutate(standardizeddisaggregate = case_when(
#     indicator %in% c('OVC_SERV') ~ ' TotalNumerator',
#     TRUE~standardizeddisaggregate
#   ))


# Insert FY15-FY18 dataset ------------------------------------------------

#import previously merged FYs (FY15-FY18) dataset
pdat1 <- read_csv("MergedFile20190211.csv")

# remove columns for matching with new dataset strutcure (longdf3)
colnames(pdat1)
colnames(longdf3)

pdat2 <-  pdat1 %>% 
  select(-agefine, -agesemifine)

#check structure of longdf3 and MSDv3
str(longdf3)
str(pdat2)

#merge previous dataset with FY15-FY16 data with updated dataset
mergedf <- rbind(longdf3, pdat2)
str(mergedf)

#subset data without NULL values
finaldf <- select(filter(mergedf, value != "NULL"), c(operatingunit:value))
str(finaldf)
unique(finaldf$period)

#export dataset to csv for reading into Tableau 
write.csv(finaldf, "MergedPEPFARDataset_OUxIM_20190503.csv", row.names = FALSE)

