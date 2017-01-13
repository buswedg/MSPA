# Solution for Lesson_3_Exercises_Using_R

# mileage.csv is derived from a 1991 U.S EPA study of passenger car mileage. 
# This file includes on sixty cars: HP (engine horsepower), 
# MPG (average miles per gallon) WT (vehicle weight in 100 lb units) 
# and CLASS (vehicle weight class C1,...,C6).
# read the comma-delimited text file creating a data frame object in R
# and examine its structure
mileage <- read.csv("data/mileage.csv")
str(mileage)

# 1) For each weight class determine the mean and standard deviation of MPG. What can you conclude from these calculations?
# begin by defining a simple function to print mean and standard deviation
my_mean_sd <- function(x) c(mean(x), sd(x))  # user-defined function
aggregate (MPG~CLASS, mileage, my_mean_sd)  # low variability within classes

# 2) For each weight class determine the mean and standard deviation of HP. 
# What can you conclude from these calculations?
aggregate (HP~CLASS, mileage, my_mean_sd)  # higher means... higher standard deviations

# ----------------------------------------
# User defined functions to calculate and print selected statistics (adding variance)

range <- function(x) {max(x, na.rm = TRUE) - min(x, na.rm = TRUE)}  # distance between min and max

my_stats <- function(x) {
  cat("\n    mean:", mean(x, na.rm = TRUE))
  cat("\n   median:", median(x, na.rm = TRUE))
  cat("\n    range:", range(x))  
  cat("\n       sd:", sd(x, na.rm = TRUE))
  cat("\n variance:", var(x, na.rm = TRUE))
  cat("\n       Q1:", quantile(x, probs = c(0.25), na.rm = TRUE))
  cat("\n       Q3:", quantile(x, probs = c(0.75), na.rm = TRUE))
  cat("\n      P10:", quantile(x, probs = c(0.10), na.rm = TRUE))
}

#-----------------------------------------

# shoppers.csv contains the dollar amounts spent in a store 
# by individual shoppers during one day.
# read in shoppers and examine its structure
shoppers <- read.csv("data/shoppers.csv")
str(shoppers)

# Find the mean, median, range, standard deviation, variance, Q1, Q3 and P10.
my_stats(shoppers$Spending)
hist(shoppers$Spending)   # distribution is skewed right

#-----------------------------------------
# pontus.csv lists the ages of USA Presidents at the time of their inauguration. 
# Also listed are the heights of the Presidents and their opponents.
# read in potus and examine its structure
pontus <- read.csv("data/pontus.csv")
str(pontus)

# 1) Find the mean, median, range, standard deviation, Q1, Q3 and P10 of the ages.

my_stats(pontus$Age)
# check calculations by looking at the distribution of ages
Presidents_Ages <- pontus$Age
hist(Presidents_Ages)  # to check

# 2) Find the mean, median, range, standard deviation, Q1, Q3 and P10 
# of the heights of the Presidents and also their opponents.

my_stats(pontus$Ht)
with(pontus, table(Ht))  # to check

my_stats(pontus$HtOpp)  
with(pontus, table(HtOpp))  # to check

# 3) Calculate the difference between each President's height and that of his opponent.
# Plot a histogram and construct a boxplot of these differences.
Ht_Difference <- pontus[,5]-pontus[,6]
summary(Ht_Difference)
hist(Ht_Difference)   # Immaterial average height difference between pairs.
boxplot(pontus$Ht, pontus$HtOpp)

# ----------------------------------------
# geyser.csv contains the intervals (in minutes) between eruptions 
# of Old Faithful Geyser in Yellowstone National Park. 
# The data were taken on two consecutive weeks: WEEK1 and WEEK2. 
# Compare the two sets of data using summary statistics and histograms. 
# What do you conclude?
# read in geyser and examine its structure

geyser <- read.csv("data/geyser.csv")
str(geyser)

# produce summary statistics and histograms
summary(geyser)

Week1 <- geyser[,1]
Week2 <- geyser[,2]

par(mfrow=c(1,2))
hist(Week1)
hist(Week2)
par(mfrow=c(1,1))

par(mfrow=c(1,2))
boxplot(Week1)
boxplot(Week2)
par(mfrow=c(1,1))

# no apparent average difference between weeks, but multi-modal distribution.
