# Solution for Lesson_6_Exercises_Using_R

# We use packages and functions in R whenever possible. 
# We build upon the foundation that R provides.
# The R environment includes more than five thousand packages,
# many written by the leading experts in statistics and data science.

# for the normal distribution we have the following functions
# dnorm(x, mean = 0, sd = 1, log = FALSE)  # density function
# pnorm(q, mean = 0, sd = 1, lower.tail = TRUE, log.p = FALSE)  # distribution function
# qnorm(p, mean = 0, sd = 1, lower.tail = TRUE, log.p = FALSE)  # quantiles
# rnorm(n, mean = 0, sd = 1)  # generate n normal random deviates

# 1) Assume the purchases of shoppers in a store have been studied 
# for a period of time # and it is determined the daily purchases 
# by individual shoppers are normally distributed with a mean of $81.14 
# and a standard deviation of $50.71. 
# Find the following probabilities using R.

# 1) a)	What is the probability that a randomly chosen shopper spend less than $75.00?
sprintf("%.4f", pnorm(75, mean = 81.14, sd = 20.71, lower.tail = TRUE))  

# 1) b) What proportion of shoppers spend more than $100.00? 
sprintf("%.4f", pnorm(100, mean = 81.14, sd = 20.71, lower.tail = FALSE))  

# 1) c) What proportion of shoppers spend between $50.00 and $80.00?
prob_greater_than_50 <- pnorm(50, mean = 81.14, sd = 20.71, lower.tail = FALSE)
prob_greater_than_80 <-pnorm(80, mean = 81.14, sd = 20.71, lower.tail = FALSE)
sprintf("%.4f", prob_greater_than_50 - prob_greater_than_80)  


# 2) Assume that the shopper's purchases are normally distributed 
# with a mean of $97.11 and a standard deviation of $39.46. 
# Find the following scores using R. 

# 2) a) What weight is the 90th Percentile of the shopper's purchases? 
# That is, find the score P90 that separates the bottom 90% of shopper's 
# purchases from the top 10%. 
sprintf("%.4f", qnorm(0.90, mean = 97.11, sd = 39.46, lower.tail = TRUE))  


# 2) b) What is the median shopper's purchase? 
# That is, find the score P50 that separates the bottom 50% of shopper's 
# purchases from the top 50%. What is important about this number?
sprintf("%.4f", qnorm(0.50, mean = 97.11, sd = 39.46, lower.tail = TRUE)) 

# What is important about this number?
# The normal distribution is symmetric, so its mean and median are identical.

# 3) Generate a sample of size 50 from a normal distribution with a mean 
# of 100 and a standard deviation of 4. What is the mean and standard error of the 
# mean for this sample? Generate a second sample of size 50 from the same normal 
# population. What is the mean and standard error of the mean for this second sample? 
# What can you say about the means and standard deviations of random samples 
# of the same size taken from the same population?  Now repeat this process 
# generating a sample of size 5000. Calculate the mean and standard error of 
# the mean for this third sample and compare to the previous samples. 
# What do you observe?

set.seed(1234)  # seed the random number generator for reproducibility
my_first_sample <- rnorm(n = 50, mean = 100, sd = 4)
std_error1 <- sd(my_first_sample)/sqrt(50)
cat("\nmy_first_sample mean: ", mean(my_first_sample), " std_error:", std_error1)

my_second_sample <- rnorm(n = 50, mean = 100, sd = 4)
std_error2 <- sd(my_second_sample)/sqrt(50)
cat("\nmy_second_sample mean: ", mean(my_second_sample)," std_error:", std_error2)

# What can you say about the means and standard deviations of random samples 
# They are close in value.

my_third_sample <- rnorm(n = 5000, mean = 100, sd = 4)
std_error3 <- sd(my_third_sample)/sqrt(5000)
cat("\nmy_third_sample mean: ", mean(my_third_sample), " std_error:", std_error3)

# Compare to the previous samples. What do you observe?
# Similar mean, smaller standard deviation. 
# Note that this relates to the standard error of the mean.


# 4) Assume a biased coin when flipped will generate heads one third of the time. 
# Estimate the probability of getting at least 250 heads out of 600 flips 
# using the normal distribution approximation. Then calculate the 
# exact probability using the binomial distribution. Compare the two probabilities.

# 250 heads out of 600 tosses implies a binomial with n = 600 and x = 250
# the biased coin has probability of heads p = 1/3

# normal approximation to the binomial uses  z = (x - n*p)/sqrt(n * p * (1-p))
n <- 600
p <- 1/3
x <- 250  # least 250 heads implies the upper tail of the standard normal distribution
z <- (x - n*p)/sqrt(n * p * (1-p))
sprintf("%.6f", pnorm(z, mean = 0, sd = 1, lower.tail = FALSE))

# R provides binomial probabilties directly
# dbinom(x, size, prob, log = FALSE)  # density function
# pbinom(q, size, prob, lower.tail = TRUE, log.p = FALSE)  # distribution function
# qbinom(p, size, prob, lower.tail = TRUE, log.p = FALSE)  # quantile function
# rbinom(n, size, prob)  # here n is the number of random variates to generate
sprintf("%.6f", pbinom(q = x, size = n, prob = p, lower.tail = FALSE))

# The normal approximation to the binomial is very close to the binomial.


# 5) Use the uniform distribution over 0 to 1. Generate three separate simple
# random samples of size n = 25, n = 100, n = 400. Plot histograms for each and
# comment on what you observe.
par(mfrow=c(1,3), oma=c(0,0,2,0))
hist(runif(25, min = 0, max = 1), main = "")
hist(runif(100, min = 0, max = 1), main = "")
hist(runif(400, min = 0, max = 1), main = "")
mtext("Histograms of uniform distribution (n = 25, 100 and 400)", side = 3,
	outer = T, line = -1)
par(mfrow=c(1,1))

# 6) Salaries.csv gives the CEO age and salary for 60 small business firms. 
# Use salaries.csv to answer the following questions: 

# 6) a) Is the distribution of ages a normal distribution? Explain your answer. 
# Let's begin by using exploratory data analysis, looking at the distribution.
# Make sure the comma-delimited text file <salaries.csv> is in your working directory.
salaries <- read.csv(file.path("c:/Rdata/","salaries.csv"))
print(str(salaries))  # examine the structure of the data frame
with(salaries, hist(AGE))
with(salaries, plot(density(AGE)))

# R provides qq plotting capabilities... see qqnorm documentation
# A straight line look to the plot suggests that the distribution
# is similar in form to a normal distribution.
qqnorm(salaries$AGE,main="AGE QQ",xlab="Normal Quantiles",ylab="Age Quantiles",datax=TRUE)
qqline(salaries$AGE,datax=TRUE,distribution=qnorm,probs=c(0.25,0.75),qtype=7)

# Each of these graphs implies that AGE may be thought of as normally distributed.
