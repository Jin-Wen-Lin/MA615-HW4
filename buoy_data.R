# Load the data
library(dplyr)   # For data manipulation
library(data.table)
library(tidyverse)

file_root<-"https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
tail<- ".txt.gz&dir=data/historical/stdmet/"

years_1 <- rev(2001:2023)
years_2 <- rev(1985:1999)


file_root<-"https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
year<-"2000"
tail<- ".txt.gz&dir=data/historical/stdmet/"
path<-paste0(file_root,year,tail)
header=scan(path,what= 'character',nlines=1)
buoy<-fread(path,header=FALSE,skip=1, fill = 17)
colnames(buoy)<-header


read_data <- function(year){
  path<-paste0(file_root,year,tail)
  header=scan(path,what= 'character',nlines=1)
  # Notice that there is only one line for the header in the years from 1985 to 2006
  if (year <= 2006){
    buoy<-fread(path,header=FALSE,skip=1)
  }
  else{
    buoy<-fread(path,header=FALSE,skip=2)
  }
  colnames(buoy)<-header
  return(buoy)
  
}

buoys_1 <- lapply(years_1, read_data)
buoys_2 <- lapply(years_2, read_data)

# Overall data
buoy_data <- bind_rows(buoys_1, buoy, buoys_2)

# Combine years into one column and named Year
buoy_data <- buoy_data  %>% mutate(Year1 = paste0(19, YY))
buoy_data <- buoy_data %>% mutate(Year = coalesce(as.numeric(`#YY`), 
                                                  as.numeric(YYYY), as.numeric(Year1)))
buoy_data <- buoy_data %>% select(-`#YY`)
buoy_data <- buoy_data %>% select(- YYYY)
buoy_data <- buoy_data %>% select(- Year1)
buoy_data <- buoy_data %>% select(- YY)
buoy_data <- buoy_data %>% select(Year, everything())

write.csv(buoy_data, "buoy_data.csv", row.names = FALSE)

