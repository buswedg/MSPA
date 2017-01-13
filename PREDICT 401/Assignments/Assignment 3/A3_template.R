#Predict 401
##Data Analysis Assignment 3

#------------------------------------------------------------------------------
# Part 1: Presentation of the Chi Square Distribution 
# Appendix A
#------------------------------------------------------------------------------

require(moments)

# Plot the chi square density function. mu equals the expectation which is the
# degrees of freedom for the chi square density.  For the chi square distribution
# if the mean is mu then the variance is 2mu.  We will be using mu = 1.0.

mu <- 1  # This is where different mean values may be substituted.

#-----------------------------------------------------------------------------
limit <- round(0.9*mu + 11)   # This generates a plotting limit.

X <- seq(1,2*limit)/2   # This generates values for computing the density.
plot(X, dchisq(X, df = mu, ncp = 0), type = "b",  xlim = c(0, limit),
     col = "darkred", lwd = 2, main = "Chi Square Density")

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Part 2: Bootstrap Approach.  
# Appendix A

# Two different bootstraping methods will be used.  In some cases the traditional
# t statistic works as well as the bootstrap t method.  When this is not the case, 
# the bootstrap t method is preferred since it will compensate for asymmetry.

# Draw a random sample of size n. It is designated as srs and will be used later. 

n <- 500  #  This is the sample size which will be changed repeatedly for this part.

set.seed(124)  # Retain this random seed. Use the same seed for each iteration.
mu <- 1  # This is the mean value for the chi square distribution.

# First a simple random sample is taken from the population.
srs <- rchisq(n, mu, ncp = 0)
# srs is the initial sample which is resampled for the bootstrap.

# Calculate the sample mean and standard deviation for use later.
mu.boot <- mean(srs)
std.boot <- sd(srs)

# Produce the histogram of the simple random sample srs.
cells <- seq(from = 0, to = max(srs)+0.5, by = 0.5)
hist(srs, breaks = cells, main = "Histogram of Initial Simple Random Sample", col = "blue")
# This is the distribution used in bootstrapping.

#-------------------------------------------------------------------------
# What follows is resampling with replacement from the simple random sample srs.
# This resampling with replacement is the basis of bootstrapping.

N <- 10^4      # Number of iterations.
# Define vectors for storage purposes.
my.boot <-numeric(N)
t.my.boot <- numeric(N)

for (i in 1:N)
{
  x <- sample(srs, n, replace = TRUE)                    # Sample size is n.
  my.boot[i] <- mean(x)                                  # Calculate mean value for srs.
  t.my.boot[i] <- (mean(x)-mu.boot)/(sd(x)/sqrt(n))      # Calculate t statistic for srs.
}

#-------------------------------------------------------------------------
# Construct a histogram of the resampled mean values and superimpose normal density function.
m <- mean(my.boot)
s <- sd(my.boot)
x0 <- min(my.boot)
x1 <- max(my.boot)+1
x <- seq(x0,x1,length=1000)
y <- dnorm(x, mean=m, sd = s, log=FALSE)
ylim <- max(y)+0.05

# Sampling distribution of mean values with quantiles at 2.5% and 97.5% shown as vertical lines.

hist(my.boot, main = "Resampling distribution of mean values", probability = TRUE, col = "red")
abline(v= m, col = "green", lty = 2, lwd = 2)
abline(v = quantile(my.boot, probs = c(0.025, 0.975)), col = "green", lty = 2, lwd = 2)
lines(x,y, col="green", lwd = 2)

# It is apparent that the resampled mean values have a histogram which is skewed right.
#----------------------------------------------------------------------
# Construct a histogram of the resampled t-statistic values and superimpose the t density function.
x0 <- min(t.my.boot)
x1 <- max(t.my.boot)
x <- seq(x0,x1,length=1000)
y <- dt(x, df = n-1)
ymax <- max(y)

# Sampling distribution of t values with quantiles at 2.5% and 97.5% shown.
hist(t.my.boot, col = "green", main = "Resampling Distribution of t-statistic", 
     probability = TRUE, ylim = c(0,ymax))
abline(v = 0.0, col = "darkred", lty = 2, lwd = 2)
abline(v = quantile(t.my.boot, probs = c(0.025, 0.975)), col = "darkred", lty = 2, lwd = 2)
lines(x,y, col="darkred", lwd = 2)

# It is apparent that the resampled t statistic values have a left-skewed histogram.
#----------------------------------------------------------------------

# This exercise demonstrates the confidence intervals for the three methods converge
# as the sample size increases. With a sample size of 200 the results are becoming
# much closer.  This exercise also reveals that the bootstrap t interval adjusts for
# the skewness in the sampling distribution which in many cases results in
# better coverage of the true population mean than what the symmetric traditional
# t statistic confidence interval provides.

#----------------------------------------------------------------------
# Traditional confidence interval for the mean using srs and t-statistic.
t.test(srs, conf.level=0.95, alternative = c("two.sided"))
# We will compare to this confidence interval.
#----------------------------------------------------------------------
# Percentile bootstrapping confidence interval.
round(quantile(my.boot, prob = c(0.025,0.975)), digits = 3)
#----------------------------------------------------------------------
# Determine a two-sided confidence interval using bootstrap t distribution.
Q1 <- quantile(t.my.boot, prob = c(0.025), names = FALSE)
Q2 <- quantile(t.my.boot, prob = c(0.975), names = FALSE)
round(mu.boot - Q2*(std.boot/sqrt(n)), digits = 3)
round(mu.boot - Q1*(std.boot/sqrt(n)), digits = 3)
#-----------------------------------------------------------------------
#----------------------------------------------------------------------- 
#-----------------------------------------------------------------------
# Part 3 Analyzing Data
# Appendix B
#-----------------------------------------------------------------------
# Analyzing the Databases Problem 2 page 294

hospital <- read.csv(file.path("data/Hospital.csv"),sep=",")
str(hospital)
require(moments)

# EDA on census reveals an asymmetric distribution.
census <- hospital$Census
summary(census)
hist(census, col = "blue")
boxplot(census, col = "blue")
skewness(census)

# The distribution of census is similar to what was shown in the exercises above.
# For what follows we will consider census a sample from a larger population.
# Resampling will be used to generate sampling distributions.

# Set the stage for resampling.
mu <- mean(census)
n <- length(census)                     # The sample size is the number of observations in census.
N <- 10^4
census.mean<-numeric(N)
census.t <- numeric(N)
set.seed(124)

for (i in 1:N)
{
  x <- sample(census,n,replace = TRUE)
  census.mean[i] <- mean(x)
  census.t[i] <- (mean(x)-mu)/(sd(x)/sqrt(n))}

#----------------------------------------------------------------------
# Construct histogram and superimpose normal density function.
m <- mean(census.mean)
s <- sd(census.mean)
x0 <- min(census.mean)
x1 <- max(census.mean)+1
x <- seq(x0,x1,length=1000)
y <- dnorm(x, mean=m, sd = s, log=FALSE)
ylim <- max(y)+0.05

hist(census.mean, main="Bootstrap distribution of mean values", probability = TRUE, col = "red")
abline(v = quantile(census.mean, probs = c(0.025, 0.975)), col = "green", lty = 2, lwd = 2)
abline(v= m, col = "green", lty = 2, lwd = 2)   # observed mean
lines(x,y, col="green", lwd = 2)

#----------------------------------------------------------------------
# Construct a histogram of the resampled t-statistic values and superimpose the t density function.

x0 <- min(census.t)
x1 <- max(census.t)
x <- seq(x0,x1,length=1000)
y <- dt(x, df = n-1)
ymax <- max(y)

hist(census.t, main="Bootstrap distribution of t statistic", probability = TRUE, col = "green")
abline(v=0.0, col = "red", lty = 2, lwd = 2)
abline(v = quantile(census.t, probs = c(0.025, 0.975)), col = "red", lty = 2, lwd = 2)
lines(x,y, col="darkred", lwd = 2)
#-----------------------------------------------------------------------------------------------

# Construct two-sided confidence interval using t-statistic.  The following
# calculation gives a traditional t-statistic confidence interval using 
# 90% and 99% for comparison.
t.test(census, conf.level = 0.9, alternative = c("two.sided"))
t.test(census, conf.level = 0.99, alternative = c("two.sided"))

# Determine two-sided bootstrap percentile confidence intervals.
round(quantile(census.mean, probs=c(0.05,0.95)), digits = 2)
round(quantile(census.mean, probs=c(0.005,0.995)), digits = 2)

# Determine two-sided bootstrap t confidence intervals.
Q2 <- quantile(census.t, prob=c(0.95), names = FALSE)
Q1 <- quantile(census.t, prob=c(0.05), names = FALSE)
round(mu -Q2*sd(census)/sqrt(n), digits = 2)
round(mu -Q1*sd(census)/sqrt(n), digits = 2)

Q2 <- quantile(census.t, prob=c(0.995), names = FALSE)
Q1 <- quantile(census.t, prob=c(0.005), names = FALSE)
round(mu -Q2*sd(census)/sqrt(n), digits = 2)
round(mu -Q1*sd(census)/sqrt(n), digits = 2)


# The resulting 90% confidence intervals are similar as a consequence of the sample size.
# Such results do not always result, particularly when outliers are common.
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
# Part 4 Hypothesis Testing 
# Appendix C
#--------------------------------------------------------------------------
# Problem 2 Page 351
# For what follows we will consider the data a sample from a larger population.
# It will be necessary to develop the necessary confidence intervals based on the above examples.
# The intervals required are one-sided, so adjustments will be needed.
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
# Does the average hospital have more than 700 births per year?

hospital <- read.csv(file.path("data/Hospital.csv"),sep=",")
str(hospital)
require(moments)

summary(hospital$Births)
hist(hospital$Births, col = "blue")
boxplot(hospital$Births, col = "blue")

# Distribution of births is asymmetric and right skewed.

# Form the sampling distribution for the mean.

births <- hospital$Births
n <- length(births)
N <- 10^4
mu <- mean(births)
births.t <- numeric(N)
births.mean <- numeric(N)
set.seed(124)

for (i in 1:N)
{
  x <- sample(births,n,replace = TRUE)
  births.mean[i] <- mean(x)
  births.t[i] <- (mean(x)-mu)/(sd(x)/sqrt(n))
}

#---------------------------------------------------------------------------------
# Construct histogram and superimpose normal density function.
m <- mean(births.mean)
s <- sd(births.mean)
x0 <- min(births.mean)
x1 <- max(births.mean)+1
x <- seq(x0,x1,length=1000)
y <- dnorm(x, mean=m, sd = s, log=FALSE)
ylim <- max(y)+0.05

hist(births.mean, main="Bootstrap distribution of mean values", probability = TRUE, col = "red")
abline(v= m, col = "green", lty = 2, lwd = 2)   # observed mean
abline(v=700,col="green",lty=2, lwd = 2)          # null hypothesis value for mean
abline(v= quantile(births.mean, probs=0.01), 
       col="green", lty =2, lwd = 2)  # quantile for 99% confidence interval
lines(x,y, col="green", lwd = 2)

#---------------------------------------------------------------------------------
# Construct a histogram of the resampled t-statistic values and superimpose the t density function.
x0 <- min(births.t)
x1 <- max(births.t)
x <- seq(x0,x1,length=1000)
y <- dt(x, df = n-1)
ymax <- max(y)

# Sampling distribution of t values with quantiles at 2.5% and 97.5% shown.
hist(births.t, col = "green", main = "Resampling Distribution of t-statistic", 
     probability = TRUE, ylim = c(0,ymax))
abline(v = 0.0, col = "darkred", lty = 2, lwd = 2)
abline(v = quantile(births.t, probs = 0.99, names = FALSE), 
       col = "darkred", lty = 2, lwd = 2)          # quantile for the 99% confidence interval 
lines(x,y, col="darkred", lwd = 2)

#--------------------------------------------------------------------------
# Construct confidence intervals and perform the necessary hypothesis tests.
#--------------------------------------------------------------------------
# Conduct a one-sided t-test at 95% confidence and 99% confidence.
t.test(births, mu = 700, conf.level = 0.95, alternative = c("greater"))
t.test(births, mu = 700, conf.level = 0.99, alternative = c("greater"))

# Determine 95% and 99% one-sided confidence intervals using percentile bootstrap method.
round(quantile(births.mean, probs=0.95, digits=2))
round(quantile(births.mean, probs=0.99, digits=2))

# Determine 95% and 99% one-sided confidence intervals using bootstrap t-test.
q <- quantile(births.t, prob=0.95, names=FALSE)
round(mu -q*sd(births)/sqrt(n), digits=2)

q <- quantile(births.t, prob=0.99, names=FALSE)
round(mu -q*sd(births)/sqrt(n), digits=2)

#--------------------------------------------------------------------------
# Personnel question-------------------------------------------------------
# On average, do hospitals employ fewer than 900 people?

personnel <- hospital$Personnel

hist(personnel, col = "blue")
boxplot(personnel, col = "blue")
mu <- mean(personnel)

# Distribution of personnel is asymmetric and right skewed.

n <- length(personnel)
N <- 10^4
personnel.t<-numeric(N)
personnel.mean <- numeric(N)
set.seed(124)

for (i in 1:N)
{
  x <- sample(personnel,n,replace = TRUE)
  personnel.mean[i] <- mean(x)
  personnel.t[i] <- (mean(x)-mu)/(sd(x)/sqrt(n))
}

#-------------------------------------------------------------------------------
# Construct histogram and superimpose normal density function.
m <- mean(personnel.mean)
s <- sd(personnel.mean)
x0 <- min(personnel.mean)
x1 <- max(personnel.mean)+1
x <- seq(x0,x1,length=1000)
y <- dnorm(x, mean=m, sd = s, log=FALSE)
ylim <- max(y)+0.05

hist(personnel.mean, main="Bootstrap distribution of mean values", 
     probability = TRUE, col = "red", ylim = c(0.0, 0.007))
abline(v= m, col = "green", lty = 2, lwd = 2)   # observed mean
abline(v=900,col="green",lty=2, lwd = 2)        # null hypothesis value for mean
abline(v=quantile(personnel.mean, probs=0.9), 
       col="green", lty=2, lwd= 2)     # quantile for the confidence interval
lines(x,y, col="green", lwd = 2)

#---------------------------------------------------------------------------------
# Construct a histogram of the resampled t-statistic values and superimpose the t density function.
x0 <- min(personnel.t)
x1 <- max(personnel.t)
x <- seq(x0,x1,length=1000)
y <- dt(x, df = n-1)
ymax <- max(y)

# Sampling distribution of t values with quantiles at 2.5% and 97.5% shown.
hist(personnel.t, col = "green", main = "Resampling Distribution of t-statistic", 
     probability = TRUE, ylim = c(0,ymax))
abline(v = 0.0, col = "darkred", lty = 2, lwd = 2)
abline(v = quantile(personnel.t, probs = 0.1, names = FALSE), 
       col = "darkred", lty = 2, lwd = 2)            # quantile for the confidence interval
lines(x,y, col="darkred", lwd = 2)

#---------------------------------------------------------------------------
# Construct confidence intervals and perform the necessary hypothesis tests.
#---------------------------------------------------------------------------
# Perform one-sided t-test.
t.test(personnel, mu = 900, conf.level = 0.90, alternative = c("less"))

# Determine one-sided confidence interval using percentile bootstrap distribution.
round(quantile(personnel.mean, probs=0.90, digits=2))

# Determine one-sided confidence interval using bootstrap t distribution.
q <- quantile(personnel.t, prob=0.90, names=FALSE)
round(mu -q*sd(personnel)/sqrt(n), digits=2)


#----------------------------------------------------------------------------
# Data Analysis Assignment 3 Quiz
#----------------------------------------------------------------------------

#Question 1

#Refer to your assigned readings, sync sessions and data analysis assignment.  Determine if the 
#following statement is True or False. 

#With a mean equal to 1.0, the chi square distribution is not asymmetric
#True
#xFalse


#Question 2

#Refer to your assigned readings, sync sessions and data analysis assignment.  Determine if the 
#following statement is True or False.

#The degrees of freedom for a chi square distribution equal the variance. 
#True
#xFalse


#Question 3

#Refer to your assigned readings, sync sessions and data analysis assignment.  Determine if the 
#following statement is True or False.

#For a standard normal distribution, the skewness is 0.0 and the kurtosis is 2.0.
#If Z has the standard normal distribution then,
#skew(Z)=0
#kurt(Z)=3
#True
#xFalse


#Question 4

#Refer to your assigned readings, sync sessions and data analysis assignment.  Determine if the 
#following statement is True or False.

#A box-and-whisker plot is one method for identifying a mixed normal distribution with heavy tails. 
#xTrue
#False


#Question 5

#Refer to your assigned readings, sync sessions and data analysis assignment.  Determine if the 
#following statement is True or False.

#A Q-Q plot is one method for identifying an asymmetric distribution with outliers.
#xTrue
#False


#Question 6

#Refer to your assigned readings, sync sessions and data analysis assignment.  Determine if the 
#following statement is True or False. 

#The interquartile range (IQR) is insensitive to the more extreme values under study.
#xTrue
#False


#Question 7

#Refer to the data analysis results in Part 2 of the assignment where different sample sizes 
#(n= 20, 40, 200 and 500) are used. Determine if the following statement is True or False.  

#For each of the four sample sizes, the width of the 95% bootstrap t confidence interval is 
#always smaller than the corresponding traditional t 95% confidence interval.
#True
#xFalse


#Question 8

#Refer to the data analysis results in Part 2 of the assignment where different sample sizes 
#(n= 20, 40, 200 and 500) are used. Determine if the following statement is True or False. 

#The width of the three confidence intervals is smaller with n = 500 than with n = 20.
#xTrue
#False


#Question 9

#Refer to the analysis of "Hospital.csv" Chapter 8 problem 2 page 294 dealing with Census.
#Determine if the following statement is True or False.

#The endpoints for the 90% bootstrap percentile confidence interval are shifted slightly to the 
#right (i.e. larger values) compared to the corresponding traditional 90% t-statistic confidence 
#interval endpoints. 
#xTrue
#False


#Question 10

#Refer to your analysis of "Hospital.csv" Chapter 9 problem 2 page 351. After testing the null 
#hypothesis that the average births per year equal 700 versus the alternative that the average 
#births per year exceed 700, at the 95% confidence level which of the following statements would 
#you choose to say?
#The results are inconclusive. Fail to reject the null hypothesis.
#xThere is a statistically significant result. Reject the null hypothesis as false on the basis of 
#this evidence.


#Question 11

#Refer to your analysis of "Hospital.csv" Chapter 9 problem 2 page 351. After testing the null 
#hypothesis that on average 900 personnel are employed versus the alternative that on average fewer
#than 900 personnel are employed, at the 90% confidence level which of the following statements 
#would you choose to say?  
#xThere is no statistically significant result. Do not reject the null hypothesis.
#There is a statistically significant result. Reject the null hypothesis.