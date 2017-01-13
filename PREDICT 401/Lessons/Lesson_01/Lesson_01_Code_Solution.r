# Solution for Lesson_1_Exercises_Using_R

# read the comma-delimited text file creating a data frame object in R

# R will treat most of the variables as numeric (or integer)

# note that the NBR and CORNER variables are character strings 
# default behavior of the read.csv() function will make these factor variables,
# with internal codes being NO = 1 and YES = 2 (not 0 and 1)

# create the data frame
houses <- read.csv("data/home_prices.csv")

# examine the structure of the data frame
str(houses)

# look at the first few records of the data frame
head(houses)

# look at the last few records of the data frame
tail(houses)

# look at descriptive statistics 
summary(houses)

# the questions for this assignment concern the variable PRICE
# so we will create a vector called PRICE and work with it
PRICE <- houses$PRICE

# for the variable PRICE, select a simple random sample of size 12

# prior to random sampling, seed the random number generator 
# so that results will be reproducible
set.seed(9999)

# use the sample() function to select a random sample of size 12
SRS <- sample(PRICE, 12)

# print the values of SRS and compute its mean
print(SRS)
mean(SRS)

# select a systematic sample of twelve observations. Start with the seventh
# observation and pick every 10th observation thereafter (i.e. 7, 17, 27,..)
SS <- PRICE[seq(from = 7, to = 117, by = 10)]

# check on the systematic sample
PRICE[7] == SS[1]
PRICE[17] == SS[2]
PRICE[27] == SS[3]
PRICE[117] == SS[12]

# print the values of SS and compute its mean
print(SS)
mean(SS)

# try the commands summary(SRS) and summary(SS)
summary(SRS)
summary(SS)

# box-and-whisker plot to compare SRS and SS
boxplot(SRS, SS, names = c("SRS", "SS"))