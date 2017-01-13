# R program to aggregate XYZ customer mail and order transaction data

# revised 2012/07/10

# to run this program, set the current working directory 
# to the directory that contains the program and R binary files
# then at the console prompt, type this: 
#
#       source("miller_XYZ_data_integration.r")

# the program begins by loading the R binary files for the three data frames
# this is like loading SAS datasets from libraries

cat("\n","READ BINARY FILES:",date(),"\n") # processing marker report to console

load("XYZ_customer_data.RData")
customer.data.frame <- PREDICT450.customer.data.frame

# sales and transactions prior to 2009 could be useful in models 
# for evaluating 2009 marketing activities
# both LTD and YTD variables include 2009 sales
# so PRE2009 variables may be more appropriate for many predictive models
customer.data.frame$PRE2009_SALES <- customer.data.frame$LTD_SALES - customer.data.frame$YTD_SALES
customer.data.frame$PRE2009_TRANSACTIONS <- customer.data.frame$LTD_TRANSACTIONS - customer.data.frame$YTD_TRANSACTIONS

# sort by account number
customer.data.frame <- customer.data.frame[sort.list(customer.data.frame$ACCTNO),]

load("XYZ_item_data.RData")
item.data.frame <- PREDICT450.item.data.frame
item.data.frame$TRANDATE <- as.character(item.data.frame$TRANDATE)
# recode Small Appliances as Appliances... that is, merge the appliances categories
item.data.frame$DEPTDESCR <- ifelse((item.data.frame$DEPTDESCR == "Small Appliances"),"Appliances",item.data.frame$DEPTDESCR)

load("XYZ_mail_data.RData")
mail.data.frame <- PREDICT450.mail.data.frame

# //////////////////////////////////////////////////////
# set up user-defined function used in aggregation
# for SUM_MAIL-to-ANY_MAIL transformations on mail data
binary.is.any <- function(x)
{ # begin definition of user function binary.is.any
  # this is like a sum but if the sum is greater than 1 we return 1
  return.value <- sum(x)
  if(return.value > 1) return.value <- 1
  as.integer(return.value)
} # begin definition of user function binary.is.any  


# //////////////////////////////////////////////////////
# set up user-defined function used in processing
# transaction dates for order transaction items 
# compute difference in days between two POSIX dates
compute.difference.in.days <- function(first.date,second.date)
{ # begin definition of function compute.difference.in.days
  # first.date and second.date must be POSIX dates
if((class(first.date)[1] == "POSIXlt") && (class(second.date)[1] == "POSIXlt"))
as.integer(round(as.numeric(second.date - first.date),digits=0))
else as.integer(-9999)
} # end definition of function compute.difference.in.days


# /////////////////////////////////////////////////////////
# user function used for intermediate reporting to screen
multiple.of.one.thousand <- function(x)
{ # return true if x is a multiple of 1000
returnvalue <- FALSE
if(trunc(x/1000)==(x/1000)) returnvalue <- TRUE
returnvalue
} # end of function multiple.of.one.thousand

# /////////////////////////////////////////////
# show the contents of the customer data frame
cat("\n","CUSTOMER DATA ---------------------------------------","\n")
print(str(customer.data.frame,list.len=999))
# show the first twenty observations
# print(customer.data.frame[1:20,])
# head(customer.data.frame)


cat("\n","ORDER TRANSACTION DATA ---------------------------------------","\n")
print(str(item.data.frame,list.len=999))
# show the first twenty observations
# print(item.data.frame[1:20,])

# //////////////////////////////////////////////////////////
# show the contents of the initial mail campaign data frame
cat("\n","MAIL CAMPAIGN DATA ---------------------------------------","\n")
print(str(mail.data.frame,list.len=999))
# show the first twenty observations
# print(mail.data.frame[1:20,])

# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# WORK ON CAMPAIGN/MAIL DATA 
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
cat("\n","WORK ON CAMPAIGN/MAIL DATA:",date(),"\n") # processing marker report to console

# level the mail data frame so that there is only one record for each customer

# this data frame will have at most one record for each account 
# but the values of the MAIL variables are sums
aggregate.sum.mail.data.frame <- aggregate(mail.data.frame[-1],mail.data.frame[1],sum)
colnames(aggregate.sum.mail.data.frame) <- c("ACCTNO","SUM_MAIL_1","SUM_MAIL_2","SUM_MAIL_3","SUM_MAIL_4","SUM_MAIL_5","SUM_MAIL_6","SUM_MAIL_7","SUM_MAIL_8","SUM_MAIL_9","SUM_MAIL_10","SUM_MAIL_11","SUM_MAIL_12","SUM_MAIL_13","SUM_MAIL_14","SUM_MAIL_15","SUM_MAIL_16")

# this data frame will have at most one record for each account 
# but the values of the MAIL variables are binary indicators showning 
# that the customer has received (1) at least one mailer or (0) no mailer
# aggregate function asks for all columns to be aggregated on, which is
# all columns except for the first column (ACCTNO), and this aggregation
# is done using that first column (ACCTNO) as a basis for the aggregation
aggregate.any.mail.data.frame <- aggregate(mail.data.frame[-1],mail.data.frame[1],binary.is.any)
colnames(aggregate.any.mail.data.frame) <- c("ACCTNO","ANY_MAIL_1","ANY_MAIL_2","ANY_MAIL_3","ANY_MAIL_4","ANY_MAIL_5","ANY_MAIL_6","ANY_MAIL_7","ANY_MAIL_8","ANY_MAIL_9","ANY_MAIL_10","ANY_MAIL_11","ANY_MAIL_12","ANY_MAIL_13","ANY_MAIL_14","ANY_MAIL_15","ANY_MAIL_16")

# combine the aggregate mail data frames by columns
aggregate.mail.data.frame <- cbind(aggregate.sum.mail.data.frame,aggregate.any.mail.data.frame[,c(2:17)])

# sort by account number
aggregate.mail.data.frame <- aggregate.mail.data.frame[sort.list(aggregate.mail.data.frame$ACCTNO),]


# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# n the customer and aggregate mail data frames
# merging on ACCTNO 
# x=TRUE specifies that if a customer is in the customer data frame
#        but not the aggregate mail data frame then NAs will be 
#        put in the SUM_MAIL and ANY_MAIL fields
customer.and.mail.data.frame <- merge(customer.data.frame,aggregate.mail.data.frame,by=c("ACCTNO"),all.x=TRUE)

# sort by account number
customer.and.mail.data.frame <- customer.and.mail.data.frame[sort.list(customer.and.mail.data.frame$ACCTNO),]


# for all SUM_MAIL and ANY_MAIL fields replace NAs with zeroes
customer.and.mail.data.frame$SUM_MAIL_1 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_1)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_1)
customer.and.mail.data.frame$ANY_MAIL_1 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_1)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_1)

customer.and.mail.data.frame$SUM_MAIL_2 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_2)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_2)
customer.and.mail.data.frame$ANY_MAIL_2 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_2)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_2)

customer.and.mail.data.frame$SUM_MAIL_3 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_3)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_3)
customer.and.mail.data.frame$ANY_MAIL_3 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_3)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_3)

customer.and.mail.data.frame$SUM_MAIL_4 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_4)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_4)
customer.and.mail.data.frame$ANY_MAIL_4 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_4)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_4)

customer.and.mail.data.frame$SUM_MAIL_5 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_5)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_5)
customer.and.mail.data.frame$ANY_MAIL_5 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_5)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_5)

customer.and.mail.data.frame$SUM_MAIL_6 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_6)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_6)
customer.and.mail.data.frame$ANY_MAIL_6 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_6)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_6)

customer.and.mail.data.frame$SUM_MAIL_7 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_7)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_7)
customer.and.mail.data.frame$ANY_MAIL_7 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_7)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_7)

customer.and.mail.data.frame$SUM_MAIL_8 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_8)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_8)
customer.and.mail.data.frame$ANY_MAIL_8 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_8)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_8)

customer.and.mail.data.frame$SUM_MAIL_9 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_9)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_9)
customer.and.mail.data.frame$ANY_MAIL_9 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_9)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_9)

customer.and.mail.data.frame$SUM_MAIL_10 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_10)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_10)
customer.and.mail.data.frame$ANY_MAIL_10 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_10)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_10)

customer.and.mail.data.frame$SUM_MAIL_11 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_11)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_11)
customer.and.mail.data.frame$ANY_MAIL_11 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_11)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_11)

customer.and.mail.data.frame$SUM_MAIL_12 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_12)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_12)
customer.and.mail.data.frame$ANY_MAIL_12 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_12)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_12)

customer.and.mail.data.frame$SUM_MAIL_13 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_13)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_13)
customer.and.mail.data.frame$ANY_MAIL_13 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_13)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_13)

customer.and.mail.data.frame$SUM_MAIL_14 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_14)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_14)
customer.and.mail.data.frame$ANY_MAIL_14 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_14)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_14)

customer.and.mail.data.frame$SUM_MAIL_15 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_15)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_15)
customer.and.mail.data.frame$ANY_MAIL_15 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_15)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_15)

customer.and.mail.data.frame$SUM_MAIL_16 <- ifelse((is.na(customer.and.mail.data.frame$SUM_MAIL_16)),as.integer(0),customer.and.mail.data.frame$SUM_MAIL_16)
customer.and.mail.data.frame$ANY_MAIL_16 <- ifelse((is.na(customer.and.mail.data.frame$ANY_MAIL_16)),as.integer(0),customer.and.mail.data.frame$ANY_MAIL_16)

# now we do the cumulative mailings up to and including the mailing date
customer.and.mail.data.frame$TOTAL_MAIL_1 <- customer.and.mail.data.frame$SUM_MAIL_1
customer.and.mail.data.frame$TOTAL_MAIL_2 <- customer.and.mail.data.frame$TOTAL_MAIL_1 + customer.and.mail.data.frame$SUM_MAIL_2
customer.and.mail.data.frame$TOTAL_MAIL_3 <- customer.and.mail.data.frame$TOTAL_MAIL_2 + customer.and.mail.data.frame$SUM_MAIL_3
customer.and.mail.data.frame$TOTAL_MAIL_4 <- customer.and.mail.data.frame$TOTAL_MAIL_3 + customer.and.mail.data.frame$SUM_MAIL_4
customer.and.mail.data.frame$TOTAL_MAIL_5 <- customer.and.mail.data.frame$TOTAL_MAIL_4 + customer.and.mail.data.frame$SUM_MAIL_5
customer.and.mail.data.frame$TOTAL_MAIL_6 <- customer.and.mail.data.frame$TOTAL_MAIL_5 + customer.and.mail.data.frame$SUM_MAIL_6
customer.and.mail.data.frame$TOTAL_MAIL_7 <- customer.and.mail.data.frame$TOTAL_MAIL_6 + customer.and.mail.data.frame$SUM_MAIL_7
customer.and.mail.data.frame$TOTAL_MAIL_8 <- customer.and.mail.data.frame$TOTAL_MAIL_7 + customer.and.mail.data.frame$SUM_MAIL_8
customer.and.mail.data.frame$TOTAL_MAIL_9 <- customer.and.mail.data.frame$TOTAL_MAIL_8 + customer.and.mail.data.frame$SUM_MAIL_9
customer.and.mail.data.frame$TOTAL_MAIL_10 <- customer.and.mail.data.frame$TOTAL_MAIL_9 + customer.and.mail.data.frame$SUM_MAIL_10
customer.and.mail.data.frame$TOTAL_MAIL_11 <- customer.and.mail.data.frame$TOTAL_MAIL_10 + customer.and.mail.data.frame$SUM_MAIL_11
customer.and.mail.data.frame$TOTAL_MAIL_12 <- customer.and.mail.data.frame$TOTAL_MAIL_11 + customer.and.mail.data.frame$SUM_MAIL_12
customer.and.mail.data.frame$TOTAL_MAIL_13 <- customer.and.mail.data.frame$TOTAL_MAIL_12 + customer.and.mail.data.frame$SUM_MAIL_13
customer.and.mail.data.frame$TOTAL_MAIL_14 <- customer.and.mail.data.frame$TOTAL_MAIL_13 + customer.and.mail.data.frame$SUM_MAIL_14
customer.and.mail.data.frame$TOTAL_MAIL_15 <- customer.and.mail.data.frame$TOTAL_MAIL_14 + customer.and.mail.data.frame$SUM_MAIL_15
customer.and.mail.data.frame$TOTAL_MAIL_16 <- customer.and.mail.data.frame$TOTAL_MAIL_15 + customer.and.mail.data.frame$SUM_MAIL_16


# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# WORK ON AGGREGATING ITEM/SALES TRANSACTION DATA CUSTOMER-BY-CUSTOMER  
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
cat("\n","WORK ON ITEM/SALES DATA:",date(),"\n") # processing marker report to console

all.customer.data.frame <- customer.and.mail.data.frame

# aggregation for order transactions will be done customer by customer 
# and mail campaign noting the XYZ Company mail campaign dates
# mail campaigns are organized by date of mail drop....  

# set up POSIXlt/POSIXt dates from alphanumeric character dates
# these are for the mail campaign delivery dates for XYZ Company
# plus three days of mail time... four days in November... five in December
# the resulting DELIVERY_DATE values fell mostly on Fridays and Saturdays in 2009
# from the data dictionary documentation for XYZ Company
DELIVERY_DATE_1 <- strptime("09JAN2009",format="%d%b%Y")  # for mail date "06JAN2009"
DELIVERY_DATE_2 <- strptime("30JAN2009",format="%d%b%Y")  # for mail date "27JAN2009"
DELIVERY_DATE_3 <- strptime("27FEB2009",format="%d%b%Y")  # for mail date "24FEB2009"
DELIVERY_DATE_4 <- strptime("27MAR2009",format="%d%b%Y")  # for mail date "24MAR2009"
DELIVERY_DATE_5 <- strptime("17APR2009",format="%d%b%Y")  # for mail date "14APR2009"
DELIVERY_DATE_6 <- strptime("15MAY2009",format="%d%b%Y")  # for mail date "12MAY2009"
DELIVERY_DATE_7 <- strptime("12JUN2009",format="%d%b%Y")  # for mail date "09JUN2009"
DELIVERY_DATE_8 <- strptime("10JUL2009",format="%d%b%Y")  # for mail date "07JUL2009"
DELIVERY_DATE_9 <- strptime("07AUG2009",format="%d%b%Y")  # for mail date "04AUG2009"
DELIVERY_DATE_10 <- strptime("04SEP2009",format="%d%b%Y")  # for mail date "01SEP2009"
DELIVERY_DATE_11 <- strptime("25SEP2009",format="%d%b%Y")  # for mail date "22SEP2009"
DELIVERY_DATE_12 <- strptime("17OCT2009",format="%d%b%Y")  # for mail date "13OCT2009"
DELIVERY_DATE_13 <- strptime("07NOV2009",format="%d%b%Y")  # for mail date "03NOV2009"
DELIVERY_DATE_14 <- strptime("28NOV2009",format="%d%b%Y")  # for mail date "24NOV2009"
DELIVERY_DATE_15 <- strptime("08DEC2009",format="%d%b%Y")  # for mail date "03DEC2009"
DELIVERY_DATE_16 <- strptime("15DEC2009",format="%d%b%Y")  # for mail date "10DEC2009"
DELIVERY_DATE_17 <- strptime("01JAN2010",format="%d%b%Y") 

delivery.date.list <- c(DELIVERY_DATE_1,
DELIVERY_DATE_2,
DELIVERY_DATE_3,
DELIVERY_DATE_4,
DELIVERY_DATE_5,
DELIVERY_DATE_6,
DELIVERY_DATE_7,
DELIVERY_DATE_8,
DELIVERY_DATE_9,
DELIVERY_DATE_10,
DELIVERY_DATE_11,
DELIVERY_DATE_12,
DELIVERY_DATE_13,
DELIVERY_DATE_14,
DELIVERY_DATE_15,
DELIVERY_DATE_16,
DELIVERY_DATE_17)

# create new transaction date variable that is POSIXlt/POSIXt for use in time comparisons
item.data.frame$TRANSACTION_DATE <- strptime(item.data.frame$TRANDATE,format="%d%b%Y")

# define time periods by delivery dates. Time period K goes from the beginning of Kth period 
# and up to and including the date of delivery of the (K+1)th period. For example,
# TRAN_TIME_PERIOD = 0 for Jan 1 through January 8 (day before delivery of first mailer)
# TRAN_TIME_PERIOD = 1 for Jan 9 through January 29 (day before delivery of second mailer)
# and so on until TRAN_TIME_PERIOD = 16 extends from the date of delivery of last mailer until the end of the year

item.data.frame$TRAN_TIME_PERIOD <- integer(nrow(item.data.frame)) # initialize to zeroes
for(index.for.delivery.date in 1:17)
  item.data.frame$TRAN_TIME_PERIOD <- ifelse((item.data.frame$TRANSACTION_DATE >= delivery.date.list[index.for.delivery.date]),index.for.delivery.date,item.data.frame$TRAN_TIME_PERIOD)

# for each item record define QTY variables by campaign time-period
item.data.frame$QTY0 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 0),item.data.frame$QTY,0) # items ordered before delivery of first mailer
item.data.frame$QTY1 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 1),item.data.frame$QTY,0) # items ordered after first mailer before second mailer
item.data.frame$QTY2 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 2),item.data.frame$QTY,0) # 
item.data.frame$QTY3 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 3),item.data.frame$QTY,0) # 
item.data.frame$QTY4 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 4),item.data.frame$QTY,0) # 
item.data.frame$QTY5 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 5),item.data.frame$QTY,0) # 
item.data.frame$QTY6 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 6),item.data.frame$QTY,0) # 
item.data.frame$QTY7 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 7),item.data.frame$QTY,0) # 
item.data.frame$QTY8 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 8),item.data.frame$QTY,0) # 
item.data.frame$QTY9 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 9),item.data.frame$QTY,0) # 
item.data.frame$QTY10 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 10),item.data.frame$QTY,0) # 
item.data.frame$QTY11 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 11),item.data.frame$QTY,0) # 
item.data.frame$QTY12 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 12),item.data.frame$QTY,0) # 
item.data.frame$QTY13 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 13),item.data.frame$QTY,0) # 
item.data.frame$QTY14 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 14),item.data.frame$QTY,0) # 
item.data.frame$QTY15 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 15),item.data.frame$QTY,0) # 
item.data.frame$QTY16 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 16),item.data.frame$QTY,0) # 

# for each item record define TOTAMT variables by campaign time-period
item.data.frame$TOTAMT0 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 0),item.data.frame$TOTAMT,0) # sales dollars before delivery of first mailer
item.data.frame$TOTAMT1 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 1),item.data.frame$TOTAMT,0) # sales dollars after first mailer before second
item.data.frame$TOTAMT2 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 2),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT3 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 3),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT4 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 4),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT5 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 5),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT6 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 6),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT7 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 7),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT8 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 8),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT9 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 9),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT10 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 10),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT11 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 11),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT12 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 12),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT13 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 13),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT14 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 14),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT15 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 15),item.data.frame$TOTAMT,0) # 
item.data.frame$TOTAMT16 <- ifelse((item.data.frame$TRAN_TIME_PERIOD == 16),item.data.frame$TOTAMT,0) # 

# aggregate QTY and TOTAMT variables by customer... summing up numbers of items ordered and total sales dollars by time period
aggregate.sum.item.data.frame <- aggregate(item.data.frame[c(2,6,11:44)],item.data.frame[1],sum)
colnames(aggregate.sum.item.data.frame) <- c("ACCTNO",names(item.data.frame)[c(2,6,11:44)])

# create binary response variables for each time period for each customer showing 0 if QTY is zero and 1 if QTY > 0
aggregate.sum.item.data.frame$RESPONSE0 <- ifelse((aggregate.sum.item.data.frame$QTY0 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE1 <- ifelse((aggregate.sum.item.data.frame$QTY1 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE2 <- ifelse((aggregate.sum.item.data.frame$QTY2 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE3 <- ifelse((aggregate.sum.item.data.frame$QTY3 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE4 <- ifelse((aggregate.sum.item.data.frame$QTY4 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE5 <- ifelse((aggregate.sum.item.data.frame$QTY5 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE6 <- ifelse((aggregate.sum.item.data.frame$QTY6 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE7 <- ifelse((aggregate.sum.item.data.frame$QTY7 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE8 <- ifelse((aggregate.sum.item.data.frame$QTY8 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE9 <- ifelse((aggregate.sum.item.data.frame$QTY9 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE10 <- ifelse((aggregate.sum.item.data.frame$QTY10 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE11 <- ifelse((aggregate.sum.item.data.frame$QTY11 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE12 <- ifelse((aggregate.sum.item.data.frame$QTY12 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE13 <- ifelse((aggregate.sum.item.data.frame$QTY13 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE14 <- ifelse((aggregate.sum.item.data.frame$QTY14 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE15 <- ifelse((aggregate.sum.item.data.frame$QTY15 > 0),1,0)
aggregate.sum.item.data.frame$RESPONSE16 <- ifelse((aggregate.sum.item.data.frame$QTY16 > 0),1,0)

# sort by account number
aggregate.sum.item.data.frame <- aggregate.sum.item.data.frame[sort.list(aggregate.sum.item.data.frame$ACCTNO),]


# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////
# merge the customer and aggregate item data frames
# merging on ACCTNO 
# x=TRUE specifies that if a customer is in the customer data frame
#        but not the aggregate item data frame then NAs will be 
#        put in the QTY TOTAMT and RESPONSE fields

cat("\n","MERGE DATA INTO COMPLETE CUSTOMER DATA FRAME:",date(),"\n") # processing marker report to console

complete.customer.data.frame <- merge(customer.and.mail.data.frame,aggregate.sum.item.data.frame,by=c("ACCTNO"),all.x=TRUE)

# NAs from the item data indicate that no items were ordered.... so we replace these with zeroes

complete.customer.data.frame$QTY <- ifelse((is.na(complete.customer.data.frame$QTY)),0,complete.customer.data.frame$QTY)
complete.customer.data.frame$TOTAMT <- ifelse((is.na(complete.customer.data.frame$TOTAMT)),0,complete.customer.data.frame$TOTAMT)

complete.customer.data.frame$QTY0 <- ifelse((is.na(complete.customer.data.frame$QTY0)),as.integer(0),complete.customer.data.frame$QTY0)
complete.customer.data.frame$QTY1 <- ifelse((is.na(complete.customer.data.frame$QTY1)),as.integer(0),complete.customer.data.frame$QTY1)
complete.customer.data.frame$QTY2 <- ifelse((is.na(complete.customer.data.frame$QTY2)),as.integer(0),complete.customer.data.frame$QTY2)
complete.customer.data.frame$QTY3 <- ifelse((is.na(complete.customer.data.frame$QTY3)),as.integer(0),complete.customer.data.frame$QTY3)
complete.customer.data.frame$QTY4 <- ifelse((is.na(complete.customer.data.frame$QTY4)),as.integer(0),complete.customer.data.frame$QTY4)
complete.customer.data.frame$QTY5 <- ifelse((is.na(complete.customer.data.frame$QTY5)),as.integer(0),complete.customer.data.frame$QTY5)
complete.customer.data.frame$QTY6 <- ifelse((is.na(complete.customer.data.frame$QTY6)),as.integer(0),complete.customer.data.frame$QTY6)
complete.customer.data.frame$QTY7 <- ifelse((is.na(complete.customer.data.frame$QTY7)),as.integer(0),complete.customer.data.frame$QTY7)
complete.customer.data.frame$QTY8 <- ifelse((is.na(complete.customer.data.frame$QTY8)),as.integer(0),complete.customer.data.frame$QTY8)
complete.customer.data.frame$QTY9 <- ifelse((is.na(complete.customer.data.frame$QTY9)),as.integer(0),complete.customer.data.frame$QTY9)
complete.customer.data.frame$QTY10 <- ifelse((is.na(complete.customer.data.frame$QTY10)),as.integer(0),complete.customer.data.frame$QTY10)
complete.customer.data.frame$QTY11 <- ifelse((is.na(complete.customer.data.frame$QTY11)),as.integer(0),complete.customer.data.frame$QTY11)
complete.customer.data.frame$QTY12 <- ifelse((is.na(complete.customer.data.frame$QTY12)),as.integer(0),complete.customer.data.frame$QTY12)
complete.customer.data.frame$QTY13 <- ifelse((is.na(complete.customer.data.frame$QTY13)),as.integer(0),complete.customer.data.frame$QTY13)
complete.customer.data.frame$QTY14 <- ifelse((is.na(complete.customer.data.frame$QTY14)),as.integer(0),complete.customer.data.frame$QTY14)
complete.customer.data.frame$QTY15 <- ifelse((is.na(complete.customer.data.frame$QTY15)),as.integer(0),complete.customer.data.frame$QTY15)
complete.customer.data.frame$QTY16 <- ifelse((is.na(complete.customer.data.frame$QTY16)),as.integer(0),complete.customer.data.frame$QTY16)

complete.customer.data.frame$TOTAMT0 <- ifelse((is.na(complete.customer.data.frame$TOTAMT0)),as.integer(0),complete.customer.data.frame$TOTAMT0)
complete.customer.data.frame$TOTAMT1 <- ifelse((is.na(complete.customer.data.frame$TOTAMT1)),as.integer(0),complete.customer.data.frame$TOTAMT1)
complete.customer.data.frame$TOTAMT2 <- ifelse((is.na(complete.customer.data.frame$TOTAMT2)),as.integer(0),complete.customer.data.frame$TOTAMT2)
complete.customer.data.frame$TOTAMT3 <- ifelse((is.na(complete.customer.data.frame$TOTAMT3)),as.integer(0),complete.customer.data.frame$TOTAMT3)
complete.customer.data.frame$TOTAMT4 <- ifelse((is.na(complete.customer.data.frame$TOTAMT4)),as.integer(0),complete.customer.data.frame$TOTAMT4)
complete.customer.data.frame$TOTAMT5 <- ifelse((is.na(complete.customer.data.frame$TOTAMT5)),as.integer(0),complete.customer.data.frame$TOTAMT5)
complete.customer.data.frame$TOTAMT6 <- ifelse((is.na(complete.customer.data.frame$TOTAMT6)),as.integer(0),complete.customer.data.frame$TOTAMT6)
complete.customer.data.frame$TOTAMT7 <- ifelse((is.na(complete.customer.data.frame$TOTAMT7)),as.integer(0),complete.customer.data.frame$TOTAMT7)
complete.customer.data.frame$TOTAMT8 <- ifelse((is.na(complete.customer.data.frame$TOTAMT8)),as.integer(0),complete.customer.data.frame$TOTAMT8)
complete.customer.data.frame$TOTAMT9 <- ifelse((is.na(complete.customer.data.frame$TOTAMT9)),as.integer(0),complete.customer.data.frame$TOTAMT9)
complete.customer.data.frame$TOTAMT10 <- ifelse((is.na(complete.customer.data.frame$TOTAMT10)),as.integer(0),complete.customer.data.frame$TOTAMT10)
complete.customer.data.frame$TOTAMT11 <- ifelse((is.na(complete.customer.data.frame$TOTAMT11)),as.integer(0),complete.customer.data.frame$TOTAMT11)
complete.customer.data.frame$TOTAMT12 <- ifelse((is.na(complete.customer.data.frame$TOTAMT12)),as.integer(0),complete.customer.data.frame$TOTAMT12)
complete.customer.data.frame$TOTAMT13 <- ifelse((is.na(complete.customer.data.frame$TOTAMT13)),as.integer(0),complete.customer.data.frame$TOTAMT13)
complete.customer.data.frame$TOTAMT14 <- ifelse((is.na(complete.customer.data.frame$TOTAMT14)),as.integer(0),complete.customer.data.frame$TOTAMT14)
complete.customer.data.frame$TOTAMT15 <- ifelse((is.na(complete.customer.data.frame$TOTAMT15)),as.integer(0),complete.customer.data.frame$TOTAMT15)
complete.customer.data.frame$TOTAMT16 <- ifelse((is.na(complete.customer.data.frame$TOTAMT16)),as.integer(0),complete.customer.data.frame$TOTAMT16)

complete.customer.data.frame$RESPONSE0 <- ifelse((is.na(complete.customer.data.frame$RESPONSE0)),as.integer(0),complete.customer.data.frame$RESPONSE0)
complete.customer.data.frame$RESPONSE1 <- ifelse((is.na(complete.customer.data.frame$RESPONSE1)),as.integer(0),complete.customer.data.frame$RESPONSE1)
complete.customer.data.frame$RESPONSE2 <- ifelse((is.na(complete.customer.data.frame$RESPONSE2)),as.integer(0),complete.customer.data.frame$RESPONSE2)
complete.customer.data.frame$RESPONSE3 <- ifelse((is.na(complete.customer.data.frame$RESPONSE3)),as.integer(0),complete.customer.data.frame$RESPONSE3)
complete.customer.data.frame$RESPONSE4 <- ifelse((is.na(complete.customer.data.frame$RESPONSE4)),as.integer(0),complete.customer.data.frame$RESPONSE4)
complete.customer.data.frame$RESPONSE5 <- ifelse((is.na(complete.customer.data.frame$RESPONSE5)),as.integer(0),complete.customer.data.frame$RESPONSE5)
complete.customer.data.frame$RESPONSE6 <- ifelse((is.na(complete.customer.data.frame$RESPONSE6)),as.integer(0),complete.customer.data.frame$RESPONSE6)
complete.customer.data.frame$RESPONSE7 <- ifelse((is.na(complete.customer.data.frame$RESPONSE7)),as.integer(0),complete.customer.data.frame$RESPONSE7)
complete.customer.data.frame$RESPONSE8 <- ifelse((is.na(complete.customer.data.frame$RESPONSE8)),as.integer(0),complete.customer.data.frame$RESPONSE8)
complete.customer.data.frame$RESPONSE9 <- ifelse((is.na(complete.customer.data.frame$RESPONSE9)),as.integer(0),complete.customer.data.frame$RESPONSE9)
complete.customer.data.frame$RESPONSE10 <- ifelse((is.na(complete.customer.data.frame$RESPONSE10)),as.integer(0),complete.customer.data.frame$RESPONSE10)
complete.customer.data.frame$RESPONSE11 <- ifelse((is.na(complete.customer.data.frame$RESPONSE11)),as.integer(0),complete.customer.data.frame$RESPONSE11)
complete.customer.data.frame$RESPONSE12 <- ifelse((is.na(complete.customer.data.frame$RESPONSE12)),as.integer(0),complete.customer.data.frame$RESPONSE12)
complete.customer.data.frame$RESPONSE13 <- ifelse((is.na(complete.customer.data.frame$RESPONSE13)),as.integer(0),complete.customer.data.frame$RESPONSE13)
complete.customer.data.frame$RESPONSE14 <- ifelse((is.na(complete.customer.data.frame$RESPONSE14)),as.integer(0),complete.customer.data.frame$RESPONSE14)
complete.customer.data.frame$RESPONSE15 <- ifelse((is.na(complete.customer.data.frame$RESPONSE15)),as.integer(0),complete.customer.data.frame$RESPONSE15)
complete.customer.data.frame$RESPONSE16 <- ifelse((is.na(complete.customer.data.frame$RESPONSE16)),as.integer(0),complete.customer.data.frame$RESPONSE16)

# sort by account number
complete.customer.data.frame <- complete.customer.data.frame[sort.list(complete.customer.data.frame$ACCTNO),]

# preliminary checks show that one customer had total item sales of $351000
# this case will be deleted from the data frame
complete.customer.data.frame <- complete.customer.data.frame[(complete.customer.data.frame$TOTAMT < 350000),]

# //////////////////////////////////////////////////////
# set up learning and test indicators for modeling work
# //////////////////////////////////////////////////////

LEARNING_TEST <- c(rep("LEARNING",length=20000),rep("TEST",length=nrow(complete.customer.data.frame) - 20000))
set.seed(9999) # this is needed to get reproducible results... was missing from earlier run
complete.customer.data.frame$LEARNING_TEST <- sample(LEARNING_TEST) # random permutation of the vector of character string values

# write results to a comma-delimited text file
# output the merged data as a comma-delimited text file
write.csv(complete.customer.data.frame,file="XYZ_complete_customer_data_frame.csv",row.names=FALSE)

save(complete.customer.data.frame,file="XYZ_complete_customer_data_frame.RData")


cat("\n","COMPLETE CUSTOMER DATA ---------------------------------------","\n")
print(str(complete.customer.data.frame,list.len=999))

cat("\n","----- RUN COMPLETE -----","\n")