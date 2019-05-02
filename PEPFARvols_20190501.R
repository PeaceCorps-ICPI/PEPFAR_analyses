# Purpose: Merge Volunteers funded by PEPFAR with VIDA Geoterms data
# Date: 05/01/2019

getwd()

library(readxl)

# import datasets
dfunding <- readxl::read_xlsx("Combined_20190501.xlsx")
dvida <- readxl::read_xlsx("Combined_20190501.xlsx", 2)
dpepfar <- readxl::read_xlsx("Combined_20190501.xlsx", 3)

# combine funded Volunteers with VRT Geoterms data, (full outer join - includes PEPFAR & non-PEPFAR Funded PCVs)
combineddf <- merge(dfunding, dvida, by=c("Post", "VolID"), all = TRUE)

# revise column name of PEPFAR areas dataset from Operatingunit to Post, to enable merging across all three
names(dpepfar)[1] <- "Post"

# combine earlier joined dataset with the PEPFAR priority areas dataset on country name - since PSNUs, SNUs and VRT Geoterms do not necessarily align, full outer join
combineddf2 <- merge(combineddf, dpepfar, by="Post", all = TRUE)

# export to csv
write.csv(combineddf2,"CombinedPEPFARvols_20190501.csv", row.names = FALSE)
