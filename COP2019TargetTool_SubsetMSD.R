#Date updated: 01/17/2019
#Purpose: To subset MSD PSNU x IM dataset (clean datasets) for OGHH Target Tool
#Software: R

#Increase memory in R
memory.limit(size = 90000)

#Check and set working directory. Note: update working directory as relevant for your files.
getwd()
setwd("C:/R/PCFY18")

#Installation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
.libPaths(c("C:/Users/knoykhovich/R", .libPaths()))

#Install packages (if not already installed). Note: more information on ICPI utilites can be found here https://github.com/ICPI/ICPIutilities 
install.packages("tidyverse")
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")

#Load libraries
library(tidyverse)
library(ICPIutilities)


####read CLEAN MSD dataset file with the ICPI Utilities function
c1 <- read_msd("MER_Structured_Dataset_PSNU_IM_FY17-18_20181221_v2_1.txt")

#check column names in the MSD dataset
colnames(c1)

#check format/spelling of Funding Agency
unique(c1$fundingagency)

#Filter dataset for where Funding Agency = Peace Corps
c2 <- filter(c1, fundingagency == "PC")

#drop unnecessary columns 
c3 <- c2 %>% 
  select(operatingunit, snu1, psnu, snuprioritization, primepartner:implementingmechanismname, indicator:standardizeddisaggregate,
         ageasentered:sex, otherdisaggregate:coarsedisaggregate, fy2017_targets:fy2019_targets)

#filter out zeroes and NAs
c4 <- c3 %>% 
  filter_at(vars(starts_with("FY")), any_vars(!is.na(.) & .!=0))

#calculate APR values for OVC correctly (use Q4 results for all OVC SERV & OVC HIV STAT values for APR)
c5 <- mutate(c4, calcfy2018apr = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex", fy2018q4,
                                           if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "TransferExit", fy2018q4, 
                                                   if_else(indicator == "OVC_HIVSTAT" | indicator == "OVC_HIVSTAT_POS" | indicator == "OVC_HIVSTAT_NEG"|indicator == "OVC_SERV_UNDER_18"| indicator == "OVC_SERV_OVER_18", fy2018q4, 
                                                           if_else(indicator == "OVC_SERV", fy2018q4, fy2018apr)))))

#remove exit without graduation from program status
unique(c5$otherdisaggregate)
c6 <- filter(c5, standardizeddisaggregate != "ProgramStatus" | otherdisaggregate != "Exited without Graduation")

#remove "Transferred" from program status
c7 <- filter(c6, standardizeddisaggregate != "ProgramStatus" | otherdisaggregate != "Transferred")

#export dataset to csv for reading into Tableau 
write.csv(c7, "TargetToolMSDcleanPSNUxIM_20181221.csv", row.names = FALSE)

