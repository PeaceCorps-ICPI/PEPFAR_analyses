#Date updated: 01/10/2019
#Purpose: To subset OU X IM Genie Extract for OGHH dashboard
#Software: R

memory.limit(size = 900000)
getwd()


#Load Packages
#B.Installation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
.libPaths(c("C:/Users/knoykhovich/R", .libPaths()))
library(tidyverse)
library(ICPIutilities)

#read genie file with ICPI Utilities functions
df1 <- read_msd("GenieOUxIM_PC_20190110.txt")
colnames(df1)

#drop unnecessary columns 
df2 <- df1 %>% 
  select(operatingunit, countryname, primepartner:implementingmechanismname, indicator:standardizeddisaggregate,
         categoryoptioncomboname:agesemifine, sex, otherdisaggregate:coarsedisaggregate, fy2017_targets, fy2017q2, fy2017q4:fy2017apr, fy2018_targets, fy2018q2, fy2018q4:fy2019_targets)

#filter out zeroes and NAs
df3 <- df2 %>% 
  filter_at(vars(starts_with("FY")), any_vars(!is.na(.) & .!=0))

#remove exit without graduation from program status
df4 <- filter(df3, standardizeddisaggregate != "ProgramStatus" | categoryoptioncomboname != "Exited without Graduation")

# Create new column called "calcfy2018apr" to pull Q4 values from Age/Sex disaggs and TransferExit disaggs into new calcfy2018aapr column, all other values take from fy2018apr and put into new "calcfy2018apr" column. 
df5 <- mutate(df4, calcfy2018aprclean = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex", fy2018q4,
                                   if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "TransferExit", fy2018q4, 
                                   if_else(indicator == "OVC_HIVSTAT" | indicator == "OVC_HIVSTAT_POS" | indicator == "OVC_HIVSTAT_NEG", fy2018q4, 
                                   if_else(indicator == "OVC_SERV", fy2018q4, fy2018apr)))))

#adjust fy2017 apr OVC SERV total N to fall under Total Numerator, instead of Program Status
df6 <- df5 %>% 
  mutate(standardizeddisaggregate = case_when(
    indicator %in% c('OVC_SERV') ~ ' TotalNumerator',
    TRUE~standardizeddisaggregate
  ))





#reshape from wide to long, putting all results and targets in one colum, removes rows with missing values
longdf <- gather(df5, key = "period", "value", fy2017_targets:calcfy2018aprclean, na.rm=TRUE)

#adjust fy2017apr OVC SERV Total N to fall under Total Numerator, not Program Status
#dfalternate <- longdf %>% 
#  mutate(standardizeddisaggregate = case_when(
#    indicator == "OVC_SERV" & period == "fy2017apr" ~ 'Total Numerator',
#    TRUE~standardizeddisaggregate))

#export dataset to csv for reading into Tableau 
write.csv(longdf, "GenieOUxIMclean_20190110.csv", row.names = FALSE)



#run checks of number of columns
ncol(df5)
ncol(longdf)
names(df5)
names(longdf)

#import prior dataset with Fy15-16 data
MSDv1 <- read_msd("MSDmergedFY15toFy18.txt")
ncol(MSDv1)
names(MSDv1)
unique(MSDv1$period)

#drop fy2017 targets, Fy2017q2, Fy2017q4, fy2017apr, fy2018 targets, fy2018q2, fy2019 targets from previous file
MSDv2 <- filter(MSDv1, period == "FY2015Q2" | period =="FY2015Q4" | period =="FY2015APR" | period =="FY2016_TARGETS" | period
                =="FY2016Q2" | period =="FY2016Q4" | period =="FY2016APR" )
unique(MSDv2$period)


#merge previous dataset with FY15-FY16 data with current dataset
mergedf <- rbind(longdf, MSDv2)

#subset data without NULL values
finaldf <- select(filter(mergedf, value != "NULL"), c(operatingunit:value))
str(finaldf)
unique(finaldf$period)

#export dataset to csv for reading into Tableau 
write.csv(finaldf, "MergedFile20190211.csv", row.names = FALSE)


#import funding data
Funds <- read_csv("FundingData.csv")
colnames(Funds)

#reshape from wide to long, putting all dollars in one column, and post name in another
longfund <- gather(Funds, key = "post", "amount", Botswana:Zambia)
write.csv(longfund, "FundingDataFY17to19.csv", row.names = FALSE)

