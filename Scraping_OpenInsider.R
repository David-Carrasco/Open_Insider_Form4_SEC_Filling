library(rvest)
library(httr)

############################
##### DOWNLOADING DATA #####
############################

#Query parameters (quantities in $)
#min_share_price <- 10
#min_value_traded <- 100000 
max_number_trades <- 999999

#Model url
main_url <- paste0('http://openinsider.com/screener?s=&o=&pl=&ph=&ll=&lh=&fd=0&fdr=&td=0&tdr=&fdlyl=&fdlyh=&daysago=&xp=1&vl=&vh=&ocl=&och=&sic1=-1&sicl=100&sich=9999&grp=0&nfl= &nfh=&nil=&nih=&nol=&noh=&v2l=&v2h=&oc2l=&oc2h=&sortcol=0&cnt=', max_number_trades)

#Creating CSV file with the whole database of Open Insider - Downloading only PURCHSASES
data_insider <- read_html(GET(main_url)) %>%
  html_node('.tinytable') %>%
  html_table(header = TRUE, trim = TRUE, dec = ',')

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



