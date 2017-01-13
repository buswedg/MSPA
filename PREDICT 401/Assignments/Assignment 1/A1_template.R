#Predict 401
##Data Analysis Assignment 1

#----------------------------------------------------------------------------
# Part 1 Assessing Normality
#----------------------------------------------------------------------------

#This part of the assignment introduces methods which can be used to characterize
#an empirical distribution of data. Both summary statistics and visual methods 
#will be demonstrated using simulated data from a standard normal density 
#function. The reason for this is that statistical methods based on the normal 
#distribution are used frequently. The valid application of these methods depends 
#on the degree to which a normal distribution models the data. The work in this 
#section gives a baseline for evaluating data in the future.

#Use the R code from Appendix A of this assignment. The code is documented with 
#numerous comments. The output gives a baseline for comparing the results which 
#will be obtained in Part 2 and Part 3 of this Assignment. Execute the code 
#several times to see the degree of variation in the results obtained from 
#sampling a normal distribution.

#----------------------------------------------------------------------------
# Predict 401 Data Analysis Project 1
# Appendix A
#----------------------------------------------------------------------------

# Set the seed for the random number generator so that results can be compared.
set.seed(123)

# Generate standard normal random variables using the function rnorm().
normal_x <- rnorm(10000, mean=0, sd=1)

# Check summary statistics. Skewness is particularly important. Data which
# are skewed present estimation and inference problems. For a random sample
# from a normal distribution, the values for skewness should be close to zero
# and the kurtosis values produced by R should close to 3.
summary(normal_x)
skewness(normal_x)
kurtosis(normal_x)

# Plot a histogram with density function overlay.
hist(normal_x, prob=T, ylim=c(0.0,0.5))
lines(density(normal_x),lwd=2, col="darkred")

# Demonstrate QQ Plot by comparing two standard normal variables. A QQ plot
# is a scatterplot of two sets of data. The values of the quantiles for the
# two sets are plotted against each other. If the distributions are the same,
# the resulting plot is a straight line.

# normal_x is one set of data. Generate a second vector normal_w.
normal_w <- rnorm(10000, mean=0, sd=1)

# Sort and match the ordered sets of data to form the plot.
normal_x <- sort(normal_x)
normal_w <- sort(normal_w)
plot(normal_x, normal_w, main = "Scatterplot of two normal random variables")

# This can be done for any set of data with supplied functions.
# The unknown distribution is plotted against the standard normal distribution.
# The closer to a straight line, the better the normal approximation.
# qqnorm() and qqline() provide the capability to make this comparison.
qqnorm(normal_x)
qqline(normal_x)
# The normal QQ plot illustrates desirable agreement. Due to sampling
# variability there will always be some departures. Note the next section.

# Another way to compare an empirical distribution to the standard normal is shown
# by using the plot.ecdf() function. Since this assignment uses smaller sample
# sizes, a sample of size 50 will be used and compared to normal_x. Execute this
# portion of the code several times to see the degree of variabilty that occurs.
# The degree of sampling variability this simulation reveals is important to
# remember. This is why we need statistical tests to determine when a departure
# is extreme enough to be declared statistically significant.
normal_w <- rnorm(50, mean=0, sd=1)
plot.ecdf(normal_x,xlab = "Standard Normal Variable x", main = "Comparison to Standard Normal")
plot.ecdf(normal_w, col = "blue", pch =2, add=TRUE)
abline(v = 0.0, lty = 2, col = "red")
legend ("topleft", legend = c("normal", "sample"), col = c('black', "blue"), pch = c(19, 2))

#----------------------------------------------------------------------------
# Part 2 "Coca Cola Develops the African Market"
#----------------------------------------------------------------------------

#Refer to Black Business Statistics page 96 problem 1. The data in "Coke.csv" will
#be used to characterize the production process so that a performance assessment 
#can be made. Use the R code from Appendix B of this assignment and execute. 
#Complete the assigned readings and consider the following questions as you review
#the results of this analysis.

#----------------------------------------------------------------------------
# Predict 401 Data Analysis Project 1
# Appendix B
#----------------------------------------------------------------------------

# Case Study "Coca Cola Develops the African Market"
# EDA using data shown in problem 1 page 96 of Business Statistics.

rm(list=ls())

for(package in c('moments')) {
  if(!require(package, character.only=TRUE)) {
    install.packages(package)
    library(package, character.only=TRUE)
  }
}

rm(package)

coke <- read.csv("data/coke.csv", sep = ",")

str(coke) # Check structure of the dataset.

# Generate summary statistics and visual displays
summary(coke$Fill)
sd(coke$Fill)
stem(coke$Fill)
boxplot(coke$Fill)
100*sd(coke$Fill)/mean(coke$Fill) # Compute percent CV.

# Compare summary statistics with 20 percent trimmed mean.
mean(coke$Fill, trim=.2)

# Evaluate the distribution of the data.
hist(coke$Fill, prob=T, ylim=c(0.0,1.5))
lines(density(coke$Fill),lwd=2, col="darkred")

# Determine skewness and kurtosis of data.
skewness(coke$Fill)
kurtosis(coke$Fill)

# Evaluate QQ plot of filled coke cans.
qqnorm(coke$Fill)
qqline(coke$Fill)

# Comparison of Fill volume versus standard normal using empirical distribution functions.
# To do this, we standardize the data to a mean of zero and standard deviation of one.
mu <- mean(coke$Fill)
std <- sd(coke$Fill)
Fill <- (coke$Fill - mu)/std

normal <- rnorm(1000, mean = 0, sd = 1)

plot.ecdf(normal, xlab = "Standard Normal Variable x", main = "Comparison to Standard Normal")
plot.ecdf(Fill, col = "blue", pch =2, add=TRUE)
abline(v = 0.0, lty = 2, col = "red")
legend ("topleft", legend = c("normal", "sample"), col = c('black', "blue"), pch = c(19, 2))

# Prepare a relative frequency table.
# First define cell boundaries. Second, define cell midpoints.
cells <- seq(from = 339, to = 341.2, by = 0.2)
center <- seq(from = 339.1, to = 341.1, by = 0.2)

Fill_Volume <- coke$Fill
# Cut() places each fill volume into its associated cell.
Fill_Volume <- cut(Fill_Volume, cells, include.lowest=TRUE, right = FALSE)
# table() followed by prop.table() calculates proportions in each cell.
Fill_Volume <- prop.table(table(Fill_Volume))
# Include the cell center in the data frame.
Fill_Volume <- data.frame(Fill_Volume, center)
# Print out the data frame and compare to the stem-and-leaf plot.
Fill_Volume

# Superimpose on histogram using established breaks from cells.
# First establish the count in each cell.
count <- Fill_Volume$Freq*length(coke$Fill)
Fill_Volume <- data.frame(Fill_Volume, count)

# Plot the frequency (count) for each cell with overlay.
hist(coke$Fill, breaks=cells, main = "Frequency in Each Cell", right = FALSE)
lines(Fill_Volume$center, Fill_Volume$count, type = "b", col = "red")

# Calculate the mean and standard deviation from the grouped data and compare.
mean <- sum(Fill_Volume$Freq*Fill_Volume$center)
mean
delta2 <- (Fill_Volume$center - mean)**2
std <- sqrt(sum(delta2*Fill_Volume$Freq))
std

# Add an index variable to the data frame so that a scatter plot can be made.
index <- seq(1,50)
sample <- data.frame(coke, index)
plot (sample$index, sample$Fill, ylim = c(335, 345), main = "Fill versus Index")
abline(h = mean(sample$Fill))

coke$Fill <- sort(coke$Fill)
coke$Fill[48] # 95th percentile value

# Determine if the data can be approximated using a normal distribution.

#standardize to a mean of zero, and standard deviation of one.
mu <- mean(coke$Fill)
std <- sd(coke$Fill)
Fill <- (coke$Fill - mu) / std

#create normal distribution
normal <- rnorm(10000, mean = 0, sd = 1)

hist(coke$Fill, prob=T, ylim=c(0.0,1.5))
hist(Fill, prob=T)
hist(normal, prob=T)

boxplot(coke$Fill)
boxplot(Fill)
boxplot(normal)

plot.ecdf(coke$Fill) # comparison of original to std.normal
abline(v = mean(coke$Fill), lty = 2, col = "red")
plot.ecdf(Fill) # comparison of standardized to std.normal
abline(v = 0, lty = 2, col = "red")
plot.ecdf(normal) # comparison of normal to std.normal
abline(v = 0, lty = 2, col = "red")

#1) Is one of the four: summary(), hist(), stem() and boxplot() more effective and
#preferable for identifying outliers?

summary(coke$Fill)
hist(coke$Fill, prob=T, ylim=c(0.0,1.5))
stem(coke$Fill) #https://stat.ethz.ch/R-manual/R-devel/library/graphics/html/stem.html
boxplot(coke$Fill)

#2) What is the advantage of using a stem-and-leaf display relative to a 
#histogram?

#https://en.wikipedia.org/wiki/Stem-and-leaf_display
#Unlike histograms, stem-and-leaf displays retain the original data to at least 
#two significant digits, and put the data in order, thereby easing the move to 
#order-based inference and non-parametric statistics.

#3) Why calculate the percent coefficient of variation and 20% trimmed mean? What
#is their usefulness for characterizing these data?

100*sd(coke$Fill)/mean(coke$Fill) # Compute percent CV.
mean(coke$Fill, trim=.2)

#https://en.wikipedia.org/wiki/Coefficient_of_variation
#The coefficient of variation (CV), also known as relative standard deviation 
#(RSD), is a standardized measure of dispersion of a probability distribution or
#frequency distribution.
#The coefficient of variation is useful because the standard deviation of data 
#must always be understood in the context of the mean of the data.
#When the mean value is close to zero, the coefficient of variation will approach
#infinity and is therefore sensitive to small changes in the mean.

#https://en.wikipedia.org/wiki/Truncated_mean
#A truncated mean or trimmed mean is a statistical measure of central tendency, 
#much like the mean and median. It involves the calculation of the mean after 
#discarding given parts of a probability distribution or sample at the high and 
#low end, and typically discarding an equal amount of both.
#The truncated mean is a useful estimator because it is less sensitive to outliers
#than the mean but will still give a reasonable estimate of central tendency or 
#mean.
#unless the underlying distribution is symmetric, the truncated mean of a sample 
#is unlikely to produce an unbiased estimator for either the mean or the median.

#4) How does the distribution of the Coke.csv data compare to a normal 
#distribution based on skewness, kurtosis, the QQ plot and the empirical 
#distribution display?

skewness(coke$Fill)
kurtosis(coke$Fill)
qqnorm(coke$Fill) #https://stat.ethz.ch/R-manual/R-devel/library/stats/html/qqnorm.html
qqline(coke$Fill) # By default qqline draws a line through the first and third quartiles
abline(h = mean(coke$Fill))

#https://en.wikipedia.org/wiki/Normal_distribution
#skewness=0, kurtosis=0
#kurtosis values produced by R should close to 3

#If the skewness is greater than 1.0 (or less than -1.0), the skewness is 
#substantial and the distribution is far from symmetrical.

#https://en.wikipedia.org/wiki/Q%E2%80%93Q_plot
#a graphical method for comparing two probability distributions by plotting their 
#quantiles against each other.
#If the two distributions being compared are similar, the points in the Q-Q plot 
#will approximately lie on the line y = x.
#If the distributions are linearly related, the points in the Q-Q plot will 
#approximately lie on a line, but not necessarily on the line y = x.

#5) Assuming the data are collected in serial order, what conclusions might be 
#reached from the index plot of Fill? How is the bottling process working?

index <- seq(1,50)
sample <- data.frame(coke, index)
plot (sample$index, sample$Fill, ylim = c(335, 345), main = "Fill versus Index")
abline(h = mean(sample$Fill))

#----------------------------------------------------------------------------
# Part 3 "Soap Companies Do Battle"
#----------------------------------------------------------------------------

#Refer to Black Business Statistics page 48 problem 2. The data in 
#"soap_sales.csv" will be used. Using the code for Part 2 as an example, adapt the 
#code to the sales data. Complete the following steps and be prepared to answer 
#questions on a quiz.

rm(list=ls())

for(package in c('moments', 'Rlab')) {
  if(!require(package, character.only=TRUE)) {
    install.packages(package)
    library(package, character.only=TRUE)
  }
}

rm(package)

soap <- read.csv("data/soap_sales.csv", sep = ",")

#1) Execute summary(), stem(), histogram() and boxplot(). Observe the results.

summary(soap$sales)
hist(soap$sales, prob=T, ylim=c(0.0,1.5))
stem(soap$sales) #https://stat.ethz.ch/R-manual/R-devel/library/graphics/html/stem.html
boxplot(soap$sales)

#2) Calculate and compare the 20% trimmed mean to the mean from summary().

salesMean <- round(mean(soap$sales), 2)
salesMeanTrimmed <- round(mean(soap$sales, trim = 0.2), 2)

#3) Calculate the skewness and kurtosis, plot qqnorm(), qqline() and plot.ecdf().
#Compare to the results of Parts 1 and 2.

skewness(soap$sales)
kurtosis(soap$sales)
qqnorm(soap$sales) #https://stat.ethz.ch/R-manual/R-devel/library/stats/html/qqnorm.html
qqline(soap$sales) # By default qqline draws a line through the first and third quartiles
abline(h = mean(soap$sales))
plot.ecdf(soap$sales)

#4) Construct a six-cell relative frequency table with lower cell boundary 
#starting at 10 and cell width of 5. Calculate the mean and standard deviation 
#from the grouped data.

cells <- seq(from = 10, to = 40, by = 5)
center <- seq(from = 12.5, to = 37.5, by = 5)

Fill_Volume <- soap$sales
# Cut() places each fill volume into its associated cell.
Fill_Volume <- cut(Fill_Volume, cells, include.lowest=TRUE, right = FALSE)
# table() followed by prop.table() calculates proportions in each cell.
Fill_Volume <- prop.table(table(Fill_Volume))
# Include the cell center in the data frame.
Fill_Volume <- data.frame(Fill_Volume, center)
# Print out the data frame and compare to the stem-and-leaf plot.
Fill_Volume

#5) Using the results from (4), plot a histogram of the relative frequencies with 
#overlay as shown in Part 2. Compare this plot with the stem-and-leaf plot.

# Superimpose on histogram using established breaks from cells.
# First establish the count in each cell.
count <- Fill_Volume$Freq*length(soap$sales)
Fill_Volume <- data.frame(Fill_Volume, count)

# Plot the frequency (count) for each cell with overlay.
hist(soap$sales, breaks=cells, main = "Frequency in Each Cell", right = FALSE)
lines(Fill_Volume$center, Fill_Volume$count, type = "b", col = "red")

# Calculate the mean and standard deviation from the grouped data and compare.
mean <- sum(Fill_Volume$Freq*Fill_Volume$center)
mean
delta2 <- (Fill_Volume$center - mean)**2
std <- sqrt(sum(delta2*Fill_Volume$Freq))
std

#6) Plot sales as a function on week similarly to the index plot shown in Part 2.
index <- seq(1,52)
sample <- data.frame(soap, index)
plot (sample$index, sample$sales, main = "Fill versus Index")
abline(h = mean(sample$sales))

#----------------------------------------------------------------------------
# Data Analysis Assignment 1 Quiz
#----------------------------------------------------------------------------

rm(list=ls())

for(package in c('moments', 'Rlab')) {
  if(!require(package, character.only=TRUE)) {
    install.packages(package)
    library(package, character.only=TRUE)
  }
}

rm(package)

soap <- read.csv("data/soap_sales.csv", sep = ",")

#Question 1
#Select from the following list the preferred method for identifying outliers 
#from a random sample of data. five-number summary, consisting of the median, 
#lower quartile, upper quartile, smallest value and largest value.
#histogram
#stem-and-leaf plot
#x box-and-whisker plot

summary(soap$sales)

stem(soap$sales)

hist(soap$sales,
     main = "Soap Sales",
     xlab = "Dollars",
     col = "beige")

boxplot(soap$sales,
        main = "Soap Sales",
        xlab = "Dollars",
        col = "beige",
        notch = T,
        horizontal = T)

bplot(soap$sales,
      main = "Soap Sales",
      xlab = "Dollars",
      col = "beige",
      horizontal = T,
      outlier = T)

#Question 2
#Skewness can be suggested by the position of the median relative to the mean.
#x True
#False

#Black, 6th ed, pg 78

#Question 3
#A stem-and-leaf plot contains numerical information about the data points.
#x True
#False

#Question 4
#A histogram differentiates class interval frequencies and shows trends.
#True
#x False

#Question 5
#With extremely skewed data the 20% trimmed mean will be close to the sample mean.
#True
#x False

salesMean <- round(mean(soap$sales), 2)
salesMeanTrimmed <- round(mean(soap$sales, trim = 0.2), 2)

#Question 6
#The hinges of a box-and-whisker plot determine the interquartile range.
#x True
#False

#Black, 6th ed, pg 79: A box is drawn around the median with the lower and upper
#quartiles (Q1 and Q3) as the box endpoints. These box endpoints (Q1 and Q3) are 
#referred to as the hinges of the box. The value of the interquartile range (IQR)
#is computed by Q3 - Q1.

#Question 7
#Refer to your analysis of the data in soap_sales.csv.

#Select from the following list the correct skewness and kurtosis results for the 
#distribution of data.
#The data are left skewed with skewness = 0.75 and kurtosis = 3.79.
#The data are right skewed with skewness = -0.75 and kurtosis = 2.79.
#The data are left skewed with skewness = -0.75 and kurtosis = 2.79.
#x The data are right skewed with skewness = 0.75 and kurtosis = 3.79.

#https://en.wikipedia.org/wiki/Skewness
#negative skew: left: mean is less than the mode/median.
#postive skew: right skew: mean is greater than the mode/median.

skewness(soap$sales)
kurtosis(soap$sales)
hist(soap$sales,
     main = "Soap Sales",
     xlab = "Dollars",
     col = "beige")

#Question 8
#Refer to your analysis of the data in soap_sales.csv.

#Select from the following list the correct mean and standard deviation calculated
#for the grouped data in the relative frequency table you constructed.
#mean = 20.92 and standard deviation = 5.25
#mean = 20.92 and standard deviation = 5.10
#x mean = 21.54 and standard deviation = 5.10
#mean = 21.35 and standard deviation = 4.75

cells <- seq(from = 10, to = 40, by = 5)
center <- seq(from = 12.5, to = 37.5, by = 5)

Fill_Volume <- soap$sales
# Cut() places each fill volume into its associated cell.
Fill_Volume <- cut(Fill_Volume, cells, include.lowest=TRUE, right = FALSE)
# table() followed by prop.table() calculates proportions in each cell.
Fill_Volume <- prop.table(table(Fill_Volume))
# Include the cell center in the data frame.
Fill_Volume <- data.frame(Fill_Volume, center)
# Print out the data frame and compare to the stem-and-leaf plot.
Fill_Volume

# Superimpose on histogram using established breaks from cells.
# First establish the count in each cell.
count <- Fill_Volume$Freq*length(soap$sales)
Fill_Volume <- data.frame(Fill_Volume, count)

# Plot the frequency (count) for each cell with overlay.
hist(soap$sales, breaks=cells, main = "Frequency in Each Cell", right = FALSE)
lines(Fill_Volume$center, Fill_Volume$count, type = "b", col = "red")

# Calculate the mean and standard deviation from the grouped data and compare.
mean <- sum(Fill_Volume$Freq*Fill_Volume$center)
mean
delta2 <- (Fill_Volume$center - mean)**2
std <- sqrt(sum(delta2*Fill_Volume$Freq))
std

# Compare
mean(soap$sales)
sd(soap$sales)

#Question 9
#Refer to your analysis of the data in soap_sales.csv. 

#The outlier shown in the box-and-whisker plot is an extreme outlier.
#True
#x False

#Black, 6th ed, pg 79: Values in the data distribution that are outside the inner 
#fences but within the outer fences are referred to as mild outliers. Values that 
#are outside the outer fences are called extreme outliers.

#Question 10
#Refer to your analysis of the data in soap_sales.csv.

#The 20% trimmed mean value is 20.71.
#x True
#False

salesMean <- round(mean(soap$sales), 2)
salesMeanTrimmed <- round(mean(soap$sales, trim = 0.2), 2)

#Question 11
#Refer to your analysis of the data in soap_sales.csv.

#The percent coefficient of variation is 22.47%.
#x True
#False

100*sd(soap$sales)/mean(soap$sales) # Compute percent CV.

#Question 12
#Refer to your analysis of the data in soap_sales.csv.

#The 95th percentile value is 26.2.
#True
#x False

round(quantile(soap$sales, 0.95), 1)

#Question 13
#Refer to your analysis of the data in soap_sales.csv.

#The outlier is a result of a developing trend in sales.
#x True
#False

#Question 14
#Based on the data analysis and readings pick between the two statements below.
#Outliers create problems for data analysis and should always be eliminated so 
#that a model can be fitted to the data. 
#x Outliers should be eliminated or corrected if a reason can be identified for 
#their occurrence. If not, measures should be taken to handle their presence 
#during analysis.