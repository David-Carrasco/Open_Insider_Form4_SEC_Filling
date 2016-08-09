library(rvest)
library(httr)
library(dplyr)
library(tidyr)
library(stringr)
library(quantmod)

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

#Preparing colnames
colnames(data_insider) <- c('Details_Filing', 'Filing_Date', 'Trade_Date', 'Ticker', 'Company',
                            'Insider_Name', 'Insider_Title', 'Trade_Type', 'Share_Price', 'Shares_Traded',
                            'Shares_Owned', 'Own_Change_pct', 'Money_Traded', '1day_return', '1week_return', 
                            '1month_return', '6month_return')

#Deleting NAs rows
colSums(is.na(data_insider))
data_insider <- data_insider[!is.na(data_insider$Ticker),]

#Renaming '' by 'Regular' filing in the Details_Filing column
data_insider$Details_Filing[data_insider$Details_Filing == ''] <- 'Regular'

# Filing Data and Trade date. From character to Date. Hour:Minute:Second part won't be keep in mind
data_insider$Filing_Date <- as.Date(data_insider$Filing_Date, format = '%Y-%m-%d')
data_insider$Trade_Date <- as.Date(data_insider$Trade_Date, format = '%Y-%m-%d')

# New column - Calculate difference in days between Filling Date and Trade date
data_insider$Dif_Filing_Trade <- as.integer(abs(data_insider$Trade_Date - data_insider$Filing_Date))

# Character -> Factor (Ticker, Company, Insider ...)
# Deleting also the Company name since the Ticker is enough to identify the company
data_insider$Ticker <- as.factor(data_insider$Ticker)
data_insider$Insider_Name <- as.factor(data_insider$Insider_Name)
data_insider$Company <- NULL

#Deleting Trader_Type because all operations are purchases, in this case!
data_insider$Trade_Type <- NULL

# Character -> Numeric
data_insider$Share_Price <- as.numeric(str_replace_all(data_insider$Share_Price, pattern = '\\$|\\,', replacement = ''))
data_insider$Shares_Traded <- as.numeric(str_replace_all(data_insider$Shares_Traded, pattern = '\\+|\\,', replacement = ''))
data_insider$Shares_Owned <- as.numeric(str_replace_all(data_insider$Shares_Owned, pattern = '\\,', replacement = ''))
data_insider$Money_Traded <- as.numeric(str_replace_all(data_insider$Money_Traded, pattern = '\\,|\\+|\\$', replacement = ''))

# Shares owned - special case 'New' - Create new logical column pointing out if it's a new position
# Avoiding the % share that insider holds after the trade
data_insider$New_Owner <- ifelse(data_insider$Own_Change_pct == 'New', TRUE, FALSE)
data_insider$Own_Change_pct[data_insider$Own_Change_pct == 'New'] <- '0'
data_insider$Own_Change_pct <- as.numeric(str_replace_all(data_insider$Own_Change_pct, pattern = '\\+|\\%|\\>', replacement = ''))

#TEMPORAL
data_insider$Own_Change_pct <- NULL

# Tidyr - Separate rows by Insider Title (1 row by each element)
data_insider <- data_insider %>%
  mutate(Insider_Title = strsplit(Insider_Title, ",")) %>%
  unnest(Insider_Title) %>%
  str_trim(Insider_Title)

#TODO
#Check ';' and other symbols in the Insider_Title column - Clean the data in the column too

#Moving to factor
data_insider$Insider_Title <- as.factor(data_insider$Insider_Title)








#Ordering columns
data_insider <- dplyr::select(data_insider, ___)

###########
## MODEL ##
###########

#TODO
# Add market capitalization of each company
# Calculate max return in different timeframes (1d, 1w, 1m, 6m, 1y)
# Group by the same date and the same company??




