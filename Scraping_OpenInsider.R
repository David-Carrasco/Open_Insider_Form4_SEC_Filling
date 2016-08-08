library(rvest)
library(httr)
library(dplyr)

############################
##### DOWNLOADING DATA #####
############################

#Query parameters (quantities in $)
#min_share_price <- 10
#min_value_traded <- 100000 
max_number_trades_per_page <- 5000

#Each query downloads 5000 filings as maximum - Creating a recursive downloads till there are no more filings
last_page <- 20

#Model url for 1 page - (Downloading only PURCHASES)
#main_url <- paste0('http://openinsider.com/screener?s=&o=&pl=&ph=&ll=&lh=&fd=0&fdr=&td=0&tdr=&fdlyl=&fdlyh=&daysago=&xp=1&vl=&vh=&ocl=&och=&sic1=-1&sicl=100&sich=9999&grp=0&nfl=&nfh=&nil=&nih=&nol=&noh=&v2l=&v2h=&oc2l=&oc2h=&sortcol=0&cnt=', max_number_trades_per_page)

#Creating CSV file with the whole database of Open Insider website, page by page 
data_insider_per_page <- lapply(1:last_page, function(current_page){
  
  url <- paste0('http://openinsider.com/screener?s=&o=&pl=&ph=&ll=&lh=&fd=0&fdr=&td=0&tdr=&fdlyl=&fdlyh=&daysago=&xp=1&vl=&vh=&ocl=&och=&sic1=-1&sicl=100&sich=9999&grp=0&nfl=&nfh=&nil=&nih=&nol=&noh=&v2l=&v2h=&oc2l=&oc2h=&sortcol=0&cnt=', max_number_trades_per_page,
                '&page=', current_page)
  
  tmp <- read_html(GET(url)) %>%
    html_node('.tinytable') %>%
    html_table(header = TRUE, trim = TRUE, dec = ',')
  
  return(tmp)
  
})

#Joining all the data in a dataframe
data_insider <- do.call(rbind, data_insider_per_page)

#Deleting repeated trades (More queries that are required)
data_insider <- data_insider[!duplicated(data_insider),]

############################
##### DATA PREPARATION #####
############################

#TODO
# X column -> Identify the values with the appropiate ones that are pointed out in the open insider website
# Character -> Date
# Character -> Factore (Ticker, Company, Insider ...)
# Character -> Numeric
# Calculate difference in days between Filling Date and Trade date
# Tidyr - Separate rows by Insider Title (1 row by each element)
# 




###########
## MODEL ##
###########

#TODO
# Add market capitalization of each company
# Calculate max return in different timeframes (1d, 1w, 1m, 6m, 1y)
# 



