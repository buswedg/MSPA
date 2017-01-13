# Solution for Lesson_7_Exercises_Using_R

# Exercises

# 1) Assume a random sample of size 100 is drawn from a normal distribution with
# variance 1. The average value of the sample is 50. Find a 95% confidence
# interval for the mean.

n <- 100		# sample size
mean <- 50		# mean of sample
sd <- sqrt(1)	# standard deviation of population

margin.of.error <- qnorm(1-(0.05/2)) * sd/sqrt(n)

conf.int <- c(mean - margin.of.error, mean + margin.of.error)
conf.int

# ------------------------
#2) Assume the standard deviation for a normal distribution is equal to 100 units.  
# Also assume we want to estimate the unknown mean with a 95% confidence interval
# with total width of 8 units.  Calculate the sample size required.  
z_score <- qnorm(0.025, mean = 0, sd = 1, lower.tail = FALSE)
sample_size <- (z_score*100.0/4.0)**2
round(sample_size)

# ------------------------
# 3) A random sample of 1600 registered voters are contacted and 
# asked a variety of questions. For one question, 60% of the voters expressed 
# approval and 40% disapproval. Calculate a 95% confidence interval for the 
# proportion expressing approval.

# Here we will use a built-in R function for testing a proportion.
# prop.test(x, n, p = NULL,
#    alternative = c("two.sided", "less", "greater"),
#    conf.level = 0.95, correct = TRUE
# x	a vector of counts of successes, a one-dimensional table with two entries, 
#   or a two-dimensional table (or matrix) with 2 columns, giving the counts of 
#   successes and failures, respectively.
# n	a vector of counts of trials; ignored if x is a matrix or a table.
# p	a vector of probabilities of success. The length of p must be the same 
#   as the number of groups specified by x, and its elements must be greater 
#   than 0 and less than 1.
# alternative: a character string specifying the alternative hypothesis, 
#   must be one of "two.sided" (default), "greater" or "less". You can specify 
#   just the initial letter. Only used for testing the null that a single proportion
# equals a given value, or that two proportions are equal; ignored otherwise.
# conf.level: confidence level of the returned confidence interval. 
#   Must be a single number between 0 and 1. Only used when testing the 
#   null that a single proportion equals a given value, or that two proportions 
#   are equal; ignored otherwise.
# correct: a logical indicating whether Yates' continuity correction should be 
#   applied where possible.
prop.test(x = 1600 * 0.6, n = 1600, 
    alternative = "two.sided", conf.level = 0.95)

# If we were to store prop.test in an R object, we could examine its structure.
prop_test_object <- prop.test(x = 1600 * 0.6, n = 1600, 
    alternative = "two.sided", conf.level = 0.95)
print(str(prop_test_object))   

# Notice that this object is a list and the confidence interval lower
# and uppler limits themselves can be extracted from the object as
as.numeric(prop_test_object$conf.int)
# We will use this knowledge in (6) below.    
    
# 4) A taste test is conducted using a random sample of consumers.
# Consumers are presented with two beverages in random order and asked 
# which they prefer most. All the consumers expressed a preference. 
# One beverage was preferred 85% of the time. Using this number for 
# planning a second study, how large a sample of consumers would be 
# needed to generate a 95% confidence interval with an overall width 
# just less than 2% (i.e. from 84% to 86%)? Use the formulas given in
# Triola on page 333. Do the calculations two ways. One way assuming an 
# 85% preference rate and the second way assuming it is unknown.  
# Explain why the two sample sizes are different.

p <- 0.85
z_score <-  qnorm(0.025, mean = 0, sd = 1, lower.tail = FALSE)
sample_size <- (z_score**2)*p*(1-p)/(0.01)**2
round(sample_size)

sample_size <- (z_score**2)*(0.25)/(0.01)**2
round(sample_size)

#---------------------------------------------------------------------------
# Data Set: hot_dogs.csv
# Reference: Original source: Consumer Reports, June 1986, pp. 366-367.
# Description: Results of a laboratory analysis of calories and sodium 
# content of major hot dog brands. Researchers for Consumer Reports 
# analyzed three types of hot dog: beef, poultry, and meat 
# (mostly pork and beef, but up to 15% poultry meat). 
# Exercises: Use hot_dogs.csv to answer questions 1-4.

# Read in the data, create data frame, examine its structure.
hotdogs <- read.csv(file.path("c:/Rdata/","hot_dogs.csv"))
print(str(hotdogs))

# Look at the data... a little EDA.
plot(hotdogs)

# summary statistics
print(summary(hotdogs))

# Reading ahead in this lesson, we see that most of the questions
# concern subsets of the data by hotdog type. To respond to the
# questions, we will create three subset data frames.
beef <- subset(hotdogs, subset = (Type == "Beef"))
meat <- subset(hotdogs, subset = (Type == "Meat"))
poultry <- subset(hotdogs, subset = (Type == "Poultry"))

# Look at summary statistics for these data frames.
print(summary(beef))
print(summary(meat))
print(summary(poultry))

# ------------------------
# 5) Create boxplots and find 95% confidence intervals for the mean amount of 
# calories in each Type of hot dog: beef, meat and poultry.

with(hotdogs, boxplot(Calories ~ Type, main = "Calories, by hotdog type",
                      ylab = "Calories"))

# Here we know of an R function to compute the confidence interval.
with(beef, t.test(Calories)$conf.int)
with(meat, t.test(Calories)$conf.int)
with(poultry, t.test(Calories)$conf.int)

# Construct 99% one-sided lower confidence intervals for the mean amount of
# calories in each Type of hot dog:  beef, meat and poultry. 

# One-sided confidence intervals can also be created.
t.test(beef$Calories, alternative = "less", conf.level = 0.99)
t.test(meat$Calories, alternative = "less", conf.level = 0.99)
t.test(poultry$Calories, alternative = "less", conf.level = 0.99)

# ------------------------
# 6) Find a 95% confidence interval for the variance in the amount of 
# calories found for each Type of hotdog: beef, meat and poultry.
# Here we set up a user-defined function
# note that this is a chi-square test... so we use qchisq() function
# qchisq(p, df, ncp = 0, lower.tail = TRUE, log.p = FALSE)  # quantiles
var.conf.int = function(x, conf.level = 0.95) {
  df <- length(x) - 1
  chilower <- qchisq((1 - conf.level)/2, df, lower.tail = TRUE)
  chiupper <- qchisq((1 - conf.level)/2, df, lower.tail = FALSE)
  v <- var(x)
  c(df * v/chiupper, df * v/chilower)
}
with(beef, var.conf.int(Calories))
with(meat, var.conf.int(Calories))
with(poultry, var.conf.int(Calories))








