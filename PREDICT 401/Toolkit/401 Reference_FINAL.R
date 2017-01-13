#Predict 401
##Toolkit

for(package in c('moments', 'plyr', 'gtools', 'MASS', 'ggplot2')) {
  if(!require(package, character.only=TRUE)) {
    install.packages(package)
    library(package, character.only=TRUE)
  }
}

rm(package)


########################################################################### 
# Part 1 Basic Operations
########################################################################### 

# create data frame
houses <- read.csv(file.path('data/home_prices.csv'))
shoppers <- read.csv(file.path('data/shoppers.csv'))
mileage <- read.csv(file.path('data/mileage.csv'))
pontus <- read.csv(file.path('data/pontus.csv'))
salaries <- read.csv(file.path('data/salaries.csv'))
hotdogs <- read.csv(file.path('data/hot_dogs.csv'))
nsalary <- read.csv(file.path('data/nsalary.csv'))
tires <- read.csv(file.path('data/tires.csv'))
tableware <- read.csv(file.path('data/tableware.csv'))
newspapers <- read.csv(file.path('data/newspapers.csv'))
schools <- read.csv(file.path('data/schools.csv'))


# structure of a data frame
str(houses)
nrow(houses)
ncol(houses)
head(houses)
tail(houses)


# descriptive statistics 
summary(houses)

my_stats <- function(x) {
  cat('\n       min:', min(x, na.rm=TRUE))
  cat('\n       max:', max(x, na.rm=TRUE))
  cat('\n      mean:', mean(x, na.rm=TRUE))
  cat('\n trim mean:', mean(x, trim=0.10, na.rm=TRUE))
  cat('\n    median:', median(x, na.rm=TRUE))
  cat('\n     range:', range(x))  
  cat('\n        sd:', sd(x, na.rm=TRUE))
  cat('\n  variance:', var(x, na.rm=TRUE))
  cat('\n coeff var:', (sd(x, na.rm=TRUE)/mean(x, na.rm=TRUE))*100)
  cat('\n        Q1:', quantile(x, probs=c(0.25), na.rm=TRUE))
  cat('\n        Q3:', quantile(x, probs=c(0.75), na.rm=TRUE))
  cat('\n       IQR:', IQR(x, na.rm=TRUE)) #Black: pg 78-80
  cat('\n  Q3+3*IQR:', quantile(x, probs=c(0.75), na.rm=TRUE) + 3*IQR(x, na.rm=TRUE))
  cat('\n       P10:', quantile(x, probs=c(0.10), na.rm=TRUE))
  cat('\n  skewness:', skewness(x, na.rm=TRUE))
  cat('\n  kurtosis:', kurtosis(x, na.rm=TRUE))
}
my_stats(shoppers$Spending)
rm(my_stats)


# combinations
# order doesn't matter, nCr=n!/[(n-r)!r!]
# Suppose 4 essays are randomly chosen to appear on the class bulletin board. How many
# different groups of 4 are possible?
comb <- combinations(30, 4) # no. combs for selecting 4 from 30
nrow(comb)
rm(comb)


# permutations
# order matters, nPr=n!/[(n-r)!]
# Suppose 4 essays are randomly chosen for awards of $10, $7, $5, and $3. How many
# different groups of 4 are possible?
perm <- permutations(30, 4) # no. perms for combining 4 and 30
nrow(perm)
rm(perm)

#or

perm_without_replacement <- function(n, r){
  return(factorial(n)/factorial(n - r))
}
perm_without_replacement(30, 4)
rm(perm_without_replacement)

#or

comb <- combinations(30, 4) # no. combs for selecting 4 from 30
comb <- nrow(comb)

perm <- permutations(4, 4) # no. perms for combining 4 and 4
perm <- nrow(perm)

print(comb*perm)
rm(comb, perm)


########################################################################## 
# Part 2 Bayes Theorem
# https://districtdatalabs.silvrback.com/conditional-probability-with-r
########################################################################## 

# P( A | B ) = P( AB ) / P( B )
# P( B | A ) = P( AB ) / P( A )

# P( A | B ) = (P( B | A ) * P( A )) / P( B )
# P( B ) = (P( B | A ) * P( A )) + (P( B | ~A ) * P( ~A ))

p_cancer=0.005 # P(A) P(cancer)  
print(p_cancer) #0.005

p_neg_nocancer=0.99 # P(~B|~A) P(negative|no cancer): Outcome 1: (True Negative) Probability that the test provides a negative result given the patient does not have cancer.  
print(p_neg_nocancer) #0.99  

p_pos_nocancer=0.01 # P(B|~A) P(positive|no cancer): Outcome 2 (Type I error): Probability that the test provides a positive result given the patient does not have cancer.  
print(p_pos_nocancer) #0.01  

p_neg_cancer=0.05 # P(~B|A) P(negative|cancer): Outcome 3 (Type II error): Probability that the test provides a negative result given the patient has cancer.  
print(p_neg_cancer) #0.05  

p_pos_cancer=0.95 # P(B|A) P(positive|cancer): Outcome 4: (True Positive) Probability that the test provides a positive result given the patient has cancer.  
print(p_pos_cancer) #0.95  

# Based on the above we can derive:  
p_nocancer = 1 - p_cancer # P(~A) P(no cancer)  
print(p_nocancer) #0.995  

# P( B ) = (P( B | A ) * P( A )) + (P( B | ~A ) * P( ~A ))
p_pos = (p_cancer * p_pos_cancer) + (p_nocancer * p_pos_nocancer) # P(B) P(positive)  
print(p_pos) #0.0147  

# P( A | B ) = (P( B | A ) * P( A )) / P( B )
p_cancer_pos = (p_pos_cancer * p_cancer) / p_pos # P(A|B) P(cancer|positive)  
print(p_cancer_pos) #0.3231293 

rm(p_cancer, p_neg_nocancer, p_pos_nocancer, p_neg_cancer,
   p_pos_cancer, p_nocancer, p_pos, p_cancer_pos)


########################################################################## 
# Part 3 Sampling and Probability
########################################################################## 

# ------------------------------------------------------------------------
# Basic Sampling / Probability
# ------------------------------------------------------------------------

# probabilities in a probability distribution must be 1
# each individual probability must be between 0 and 1, inclusive
# the total area of the bars in a probability histogram is 1

# select a random sample, of 12 from vector
set.seed(9999)
PRICE <- houses$PRICE
sample(PRICE, 12)
rm(PRICE)


# select a systematic sample, starting with the seventh obs and pick 
# every 10th obs thereafter (i.e. 7, 17, 27,..)
PRICE <- houses$PRICE
PRICE[seq(from=7, to=117, by=10)]
rm(PRICE)


# probability of observation meeting criteria
N_cases <- sum((shoppers$Spending >= 40) == TRUE) # no. shoppers who spent $40 or more
prob_40_or_more <- N_cases / nrow(shoppers)
print(prob_40_or_more)
rm(N_cases, prob_40_or_more)


# probability of paired observation (without replacement) meeting criteria 
# if two shoppers are picked at random (at same time), what is the 
# probability the pair will include one shopper who spent $40 or more 
# dollars and another shopper who spent less than $10? 
n <- nrow(shoppers)
total_possible_pairs <- n*(n-1)/2 # find total number of possible pairs
n1 <- sum(shoppers$Spending < 10) # no. shoppers who spent less than $10
n2 <- sum(shoppers$Spending >= 40) # no. shoppers who spent $40 or more
probability_event <- n1*n2 / total_possible_pairs
print(probability_event)
rm(n, n1, n2, total_possible_pairs, probability_event)


# probability of two drawn observations (without replacement) meeting 
# criteria 
# if two shoppers are picked at random (sequentially), what is the 
# probability the pair will include two shoppers who spent no less than 
# $10 and no more than $40? 
n <- nrow(shoppers)
total_possible_draws <- n*(n-1) # find total number of possible draws
m <- sum(((shoppers$Spending >= 10) & (shoppers$Spending <= 40)))
probability_event <- m*(m-1) / total_possible_draws
print(probability_event)
rm(n, m, total_possible_draws, probability_event)


# probability of four drawn observations (without replacement) meeting 
# criteria 
# if four shoppers are picked at random (sequentially), what is the 
# probability the four will include: one shopper will have spent less than 
# $10, one shopper will have spent $40 or more dollars and two shoppers 
# will have spent no less than $10 and no more than $40? 
n <- nrow(shoppers)
total_possible_draws <- n*(n-1)*(n-2)*(n-3)/(4*3*2*1)
n1 <- sum(shoppers$Spending < 10) # no. shoppers who spent less than $10
n2 <- sum(shoppers$Spending >= 40) # no. shoppers who spent $40 or more
m <- sum(((shoppers$Spending >= 10) & (shoppers$Spending <= 40)))
m <- n1*n2*m*(m-1)/2
probability_event <- m / total_possible_draws
print(probability_event)
rm(n, m, total_possible_draws, probability_event)


# probability of a single drawn observation (without replacement) meeting 
# criteria based on a predefined (subset) criteria 
# if we know a randomly picked shopper has spent more than $30, what is 
# the probability that shopper has spent more than $40? 
shoppers_more_than_30 <- subset(shoppers, subset=Spending > 30)
n <- sum((shoppers_more_than_30$Spending > 40) == TRUE)
probability_event <- n / nrow(shoppers_more_than_30)
print(probability_event)
rm(n, shoppers_more_than_30, probability_event)


# probability of having drawn a duplicate from a set of observations 
# draw from 100 samples with replacement, size 22 from 365 integers (i.e. 
# 1,2,...,365) 
# count the number of samples in which one or more of the numbers sampled 
# is duplicated 
set.seed(1235)  # set random number seed for reproducibility
count_duplicates <- 0  # initialize count
for (i in 1:100) {
  this_sample <- sample(1:365, size=22, replace=TRUE)
  if(length(this_sample) != length(unique(this_sample))) 
    count_duplicates <- count_duplicates + 1
}    
prob_any_duplicates <- count_duplicates/100
print(prob_any_duplicates)
rm(i, this_sample, count_duplicates, prob_any_duplicates)

#or

set.seed(1235) 
mean(replicate(100,any(duplicated(sample(1:365, 22, replace=TRUE)))))


# probabiliy of matched draws (with replacement)
# four different witnesses pick a man from a line-up of five men
# find the probability that all four witnesses pick the same person
possible_selections = 5 * 5 * 5 * 5 # 625
same_person_outcomes = 5 # a,a,a,a b,b,b,b c,c,c,c etc.
same_person_outcomes / possible_selections
rm(possible_selections, same_person_outcomes)

#or

(1/5)^3


# probabiliy of draws which meet criteria (with replacement)
# an IRS auditor randomly selects three tax returns from 49 returns of 
# which seven contain errors
# what is the probability that she selects none of those containing 
# errors?
# number of combinations of 49 objects, selected three at a time
orig_combs <- 49 * 48 * 47/(3*2)
# remove the seven returns with errors
# number of combinations of 42 objects, selected three at a time
sub_combs <- 42 * 41 * 40/(3*2)
sub_combs / orig_combs
rm(orig_combs, sub_combs)

#or

dhyper(x=0, m=7, n=42, k=3)


# ------------------------------------------------------------------------
# Custom Distribution Problems
# ------------------------------------------------------------------------

# create custom distribution and calculate std deviation
e <- c(0, 1, 2, 3) # bins
p <- c(0.46, 0.41, 0.09, 0.04) # probabilities
mu <- sum(e*p)
var <- sum(((e-mu)**2)*(p))
sd <- sqrt(var)
print(sd)
rm(e, p, mu, var, sd)

#or

min <- -10
max <- 10
mu <- (min + max) / 2
sd <- (max-min)/4 # range rule
print(sd)
rm(min, max, mu, sd)


# ------------------------------------------------------------------------
# Uniform Distribution Problems
# ------------------------------------------------------------------------

# generate uniform distributions
par(mfrow=c(1,3), oma=c(0,0,2,0))
hist(runif(25, min=0, max=1), main='')
hist(runif(100, min=0, max=1), main='')
hist(runif(400, min=0, max=1), main='')
par(mfrow=c(1,1))

# create custom unfiorm distribution and calculate prob fall in range
pdf <- (1 / (12 - 6)) # uniform dist over range of 6 to 12
loss <- (10 - 8.5) # desired prob range
print(pdf * loss) # likelihood of falling in prob range
rm(pdf, loss)


# ------------------------------------------------------------------------
# Normal Distribution Problems
# ------------------------------------------------------------------------

# dnorm(x, mean=0, sd=1, log=FALSE)  # density function
# pnorm(q, mean=0, sd=1, lower.tail=TRUE, log.p=FALSE)  # distribution function
# qnorm(p, mean=0, sd=1, lower.tail=TRUE, log.p=FALSE)  # quantiles
# rnorm(n, mean=0, sd=1)  # generate n normal random deviates

# 68-95-99.7 rule
# 68.27% of data fall within 1 standard deviations of the mean.
sd1 <- 0.6827
print(1-sd1)
# 95.45% of data fall within 2 standard deviations of the mean.
sd2 <- 0.9545
print(1-sd2)
# 99.73% of data fall within 3 standard deviations of the mean.
sd3 <- 0.9973
print(1-sd3)
rm(sd1, sd2, sd3)

# Chebyshev's rule
# under Chebyshev's inequality a minimum of just 75% of values must lie 
# within two standard deviations of the mean
mean <- 67.1
sd <- 3.5
mean + 2*sd
rm(mean, sd)

# generate a normal distribution and find mean and std error
set.seed(1234)  # seed the random number generator for reproducibility
sample <- rnorm(n=50, mean=100, sd=4)
std_error <- sd(sample)/sqrt(50)
cat('\nsample mean: ', mean(sample), ' std_error:', std_error)
rm(sample, std_error)

# what proportion of the distribution is less/greater than xxx? 
pnorm(75, mean=81.14, sd=20.71, lower.tail=TRUE) # proportion less than 75
pnorm(100, mean=81.14, sd=20.71, lower.tail=FALSE) # proportion greater than 100

# what proportion of the distribution is between 50 and 80? 
prob_50 <- pnorm(50, mean=81.14, sd=20.71, lower.tail=FALSE)
prob_80 <-pnorm(80, mean=81.14, sd=20.71, lower.tail=FALSE)
print(prob_50 - prob_80)
rm(prob_50, prob_80)

# for the distribution, what weight is the xxth percentile? 
qnorm(0.25, mean=81.14, sd=20.71, lower.tail=TRUE)
qnorm(0.75, mean=81.14, sd=20.71, lower.tail=TRUE)

#or

sample <- rnorm(n=500, mean=81.14, sd=20.71)
quantile(sample, c(0.1, 0.25, 0.5, 0.75, 0.9)) 

# generate a normal distribution and find prob of shaded area
# scores on a test are normally distributed with a mean of 68.2 and a 
# standard deviation of 10.4
# estimate the probability that among 75 randomly selected students, at 
# least 20 of them score greater than 78
# score is greater than means so lower.tail is FALSE
p <- pnorm(q=78, mean=68.2, sd=10.4, lower.tail=F)
p <- round(p, 4)
n <- 75
q <- 1-p
np <- n*p
nq <- n*(q)
# Both np and nq >5 so can use continuity correction.
var <- n*p*q
sd <- sqrt(var)
# Conintuity correction brings 20 to 20.5
stu <- 20.5
z <- (stu-np)/sd
pnorm(-abs(z)) # 0.5 - 0.4893
rm(p, n, q, np, nq, var, sd, stu, z)


# ------------------------------------------------------------------------
# Binomial Distribution Problems
# ------------------------------------------------------------------------

# The binomial distribution is a discrete probability distribution. It 
# describes the outcome of n independent trials in an experiment. Each 
# trial is assumed to have only two outcomes, either success or failure.

# dbinom(x, size, prob, log=FALSE)  # density function
# pbinom(q, size, prob, lower.tail=TRUE, log.p=FALSE)  # distribution function
# qbinom(p, size, prob, lower.tail=TRUE, log.p=FALSE)  # quantile function
# rbinom(n, size, prob)  # where n is the number of random variates to generate

# suppose that 60% of marbles in a bag are black and 40% are white 
# find the prob of drawing a black marble from 20 draws
trials <- c(0:20)
probabilities <- dbinom(trials, size=20, prob=0.6)
successes <- trials[5:20]
binomial_probabilities <- probabilities[5:20]
successes <- factor(successes)
barplot(binomial_probabilities, names.arg=successes, xlab='successes',
        ylab='binomial probabilities')

dbinom(x=1, size=20, prob=0.4) # prob of drawing one white
dbinom(x=10, size=20, prob=0.4) # prob of drawing ten white

# suppose a gambler goes to the race track to bet on four races, there are 
# six horses in each race, what is the probability of winning xxx races?
dbinom(x=0, size=4, prob=1/6) # prob gambler loses all four
dbinom(x=1, size=4, prob=1/6) # prob gambler wins one
1 - dbinom(x=0, size=4, prob=1/6) # prob gambler wins at least one

# a series of cups of tea are prepared with m having cream added prior to 
# the tea bag and m of them with the cream added after the tea bag i.e. 
# follows a binomial distribution with prob equal to 0.5 and 2m trials
# what is the probability that a woman is able to guess at least/at most
# xxx amount of cups with cream?
pbinom(q=0, size=1, prob=0.5) # prob woman correct 1 out of 1 times
pbinom(q=3, size=4, prob=0.5) # prob woman correct at least 2 out of 4 times
pbinom(q=1, size=10, prob=0.5, lower.tail=FALSE) # prob woman correct more than 1 out of 10 times
pbinom(q=5, size=10, prob=0.5, lower.tail=FALSE) # prob woman correct more than 5 out of 10 times

# how small can 2m be while keeping the probability of 2m consecutive 
# successes at or below 0.05?
target_p_value <- 0.05
current_p_value <- 1.00
n <- 0  # initialize number of cups
while (current_p_value > target_p_value) {
  n <- n + 1  # increase by one in each iteration
  # we are talking about consecutive hits greater than or equal to n - 1
  current_p_value <- pbinom(q=n-1, size=n, prob=0.5, lower.tail=FALSE) # prob woman correct every time
  # print out intermediate results for each iteration
  cat('\n Consecutive Cups Correctly Identified:', n, 'p_value: ', current_p_value)
}


# ------------------------------------------------------------------------
# Poisson Distribution Problems
# ------------------------------------------------------------------------

# The Poisson distribution is the probability distribution of independent 
# event occurrences in an interval.

# dpois(x, lambda, log=FALSE)  # density function
# ppois(q, lambda, lower.tail=TRUE, log.p=FALSE)  # distribution function
# qpois(p, lambda, lower.tail=TRUE, log.p=FALSE)  # quantiles
# rpois(n, lambda)  # random variate generation

# emergency room has 4.6 serious accidents to handle on average each night 
# find the prob of an accident occuring over any given night 
for (x in 0:20) 
  cat('\n x:', x, 'prob:', dpois(x, lambda=4.6))

x <- 0:20
prob_x <- dpois(x, lambda=4.6)
plot(x, prob_x, las=1, type='h')
rm(x)

dpois(x=1, lambda=4.6) # prob of one accident
dpois(x=4, lambda=4.6) # prob of four accidents

# there are twenty lobsters ordered in a restaurant on average each day,
# what is the probability that xxx lobsers are ordered for a given day?
dpois(5, lambda=20) # prob 5 lobsters ordered
dpois(10, lambda=20) # prob 10 lobsters ordered

# there are twelve cars crossing a bridge per minute on average, what is 
# the probability of at least/at most xxx cars crossing the bridge for a 
# given minute?
ppois(5, lambda=12) # prob 5 or less cars
ppois(10, lambda=12) # prob 10 or less cars
ppois(4, lambda=12, lower=FALSE) # prob 5 or more cars
ppois(9, lambda=12, lower=FALSE) # prob 10 or more cars


##########################################################################  
# Part 4 Hypothesis Testing
##########################################################################  

# ------------------------------------------------------------------------
# Notes
# ------------------------------------------------------------------------

# alpha, beta and power of hypothesis testing
# power is the probability of rejecting the hypothesis tested when the 
# ALTERNATIVE hypothesis is true

# power of a hypothesis test is effected by:
# - sample size: greater sample size=greater power
# - signifiance level: higher significance=greater power
# - true value of the parameter being tested: greater the difference
# between the true parameter and alternative=greater power

# alpha increase=beta decrease, power increase
# alpha decrease=beta increase, power decrease

# probability of a type I error depends on the significant level
# probability of a type II error depends on the true value of the 
# population mean (unknown)

# Power = 1 - Beta
# Alpha = 1 - specificity
# Beta + Alpha = 1 ?

# 					         | Z		          | Y
#                    | reject H0      | fail to reject H0 |
# |------------------|----------------|-------------------|
# | A                | Type I         | Correct           |
# | H0 valid/true    | False Positive | True Positive     |
# |                  | prob=alpha     | prob=1-alpha      |
# |                  | xxxx           | xxxx              |
# |------------------|----------------|-------------------|
# | B                | Correct        | Type II           | 
# | H0 invalid/false | True Negative  | False Negative    |
# |                  | prob=1-beta    | prob=beta         |
# |                  | xxxx           | xxxx              |

# Outliers have an influence on both the mean and variance used to 
# calculate the t statistic. Outliers have a larger effect on the 
# variance, increasing type II errors due to the standard error 
# increasing more than the mean.

# generally,
# h0: x = x0
# h1: x < x0 for a lower one-tailed test
#     x > x0 for an upper one-tailed test
#     x <> x0 for a two tailed text
# where x0 is a hypothesized value of the true value x.

# Z-scores represent the distance of a value from the mean measured in 
# standard deviations
# 0.90 confidence: mu +- 1.65 standard deviations
# 0.95 confidence: mu +- 1.96 standard deviations
# 0.99 confidence: mu +- 2.58 standard deviations


# ------------------------------------------------------------------------
# Basic test statistics
# ------------------------------------------------------------------------

# derive z-score
x0 <- 115.8 # hypothesized/population value/mean
x <- 138 # sample value/mean
sd <- 13.5 # sample standard deviation
n <- 100 # sample size
z <- (x-x0) / sd
print(z)
rm(x0, x, sd, n, z)

# or

# z <- qnorm(area)
z <- qnorm(0.05) # z for 0.05 of left tail
z <- qnorm(1 - 0.05 / 2) # z for 0.95 confidence
z <- qnorm(1 - 0.01 / 2) # z for 0.99 confidence
rm(z)


# derive t-score
x0 <- 115.8 # hypothesized/population value/mean
x <- 138 # sample value/mean
sd <- 13.5 # sample standard deviation
n <- 100 # sample size
se <- sd/sqrt(n) # sample std error
t <- (x-x0) / se
print(t)

# or

# t <- pt(area, df=n-1)
t <- pt(0.05, 50-1) # t for 0.05 of left tail
t <- pt(1 - 0.05 / 2, 50-1) # t for 0.95 confidence
t <- pt(1 - 0.01 / 2, 50-1) # t for 0.99 confidence
rm(x0, x, sd, n, se, t)


# derive shaded area (significance/p) for normal distribution
x0 <- 115.8 # hypothesized value
mu <- 138 # sample mean
sd <- 13.5 # sample standard deviation
area <- pnorm(x0, mu, sd) # single tailed
print(area)

# or

# area <- pnorm(-abs(z)) # single tailed
# area <- 2*pnorm(-abs(z)) # two tailed
area <- pnorm(-abs(-1.644444))
rm(x0, mu, sd, area)


# derive shaded area (significance/p) for a t distribution
# area <- pt(-abs(t), df=n-1) # single tailed
# area <- 2*pt(-abs(t), df=n-1) # two tailed


# ------------------------------------------------------------------------
# Confidence Intervals
# ------------------------------------------------------------------------

# derive 0.90 confidence interval of population proportion, based on sample
# mean and number of observations
mu <- 49 # hypothesized/population value/mean
n <- 85 # sample size

p <- mu/n
q <- 1-p
sd = sqrt((q*p)/n)
moe <- qnorm(0.95) * sd # margin of error for 0.90 confidence (0.05 of right)

conf.int <- c(p - moe, p + moe)
print(conf.int)
rm(mu, n, p, q, sd, moe, conf.int)


# derive 0.90 confidence interval of population mean, based on sample mean
# and standard deviation
mu <- 138 # hypothesized/population value/mean
sd <- 13.5 # sample standard deviation

moe <- qnorm(0.95) * sd # margin of error for 0.90 confidence (0.05 of right)

conf.int <- c(mu - moe, mu + moe)
print(conf.int)
rm(mu, sd, moe, conf.int)


# derive 0.95 confidence interval of population mean, based on sample mean, 
# standard deviation and number of observations
mu <- 8.1 # hypothesized/population value/mean
sd <- 4.8 # sample standard deviation
n <- 10 # sample size

se <- sd/sqrt(n)
moe <- qt(0.975, df = n-1) * se # margin of error for 0.95 confidence (0.025 of right)

conf.int <- c(mu - moe, mu + moe)
print(conf.int)
rm(mu, sd, n, se, moe, conf.int)


# derive 0.95 confidence interval of population mean, based on sample size
# and 0.99 confidence interval
n <- 144 # sample size
conf.lower <- 65.7 # 0.99 lower confidence interval bound
conf.upper <- 67.3 # 0.99 upper confidence interval bound

mu <- mean(c(conf.lower, conf.upper)) # sample mean
z <- qnorm(1 - 0.01 / 2) # z for 0.99 confidence
sd <- sqrt(n) * (conf.upper - mu) / z
se <- sd/sqrt(n)
moe <- qt(0.975, df = n-1) * se # margin of error for 0.95 confidence (0.025 of right)

conf.int <- c(mu - moe, mu + moe)
print(conf.int)
rm(n, conf.lower, conf.upper, mu, sd, se, z, moe, conf.int)


# derive 0.90 confidence interval of population standard deviation, based 
# on sample mean, sample standard deviation and sample size
n <- 14 # sample size
mu <- 161.5 # hypothesized/population value/mean
sd <- 13.7 # sample standard deviation

se <- sd/sqrt(n)
X2.left <- qchisq(0.05, df = n-1) # chi for 0.05 left tail
X2.right <- qchisq(0.95, df = n-1) # chi for 0.05 right tail
conf.lower <- sqrt(((n - 1) * sd**2)/X2.right)
conf.upper <- sqrt(((n - 1) * sd**2)/X2.left)

conf.int <- c(conf.lower, conf.upper)
print(conf.int)
rm(n, mu, sd, se, X2.right, X2.left, conf.lower, conf.upper, conf.int)


# derive 0.90 confidence interval of population proportion, based on sample
# number of observations
x <- 30 # 
n <- 56 # sample size

prop <- x/n
z <- qnorm(1 - 0.05 / 2) # z for 0.95 confidence
moe <- z * sqrt((prop * ((1 - prop)/n)))

conf.int <- c(prop - moe, prop + moe)
print(conf.int)
rm(x, n, z, prop, moe, conf.int)


# derive 0.90 confidence interval for the difference between population 
# proportions
n1 <- 50
x1 <- 15
p1 <- x1/n1

n2 <- 60
x2 <- 23
p2 <- x2/n2

alpha <- 0.10
z <- qnorm(1-alpha/2)

se <- sqrt((p1*(1-p1)/n1)+(p2*(1-p2)/n2))
moe <- z*se
conf.lower <- (p1-p2) - moe
conf.upper <- (p1-p2) + moe
print(c(conf.lower, conf.upper))
rm(n1, x1, p1, n2, x2, p2, alpha, z, se, moe, conf.lower, conf.upper)



# ------------------------------------------------------------------------
# Minimum Sample Size
# ------------------------------------------------------------------------

# derive the minimum sample size required to estimate the population
# mean, based on margin of error, confidence level and standard deviation
sd <- 500
moe <- 135
z <- qnorm(1 - 0.05 / 2) # z for 0.95 confidence

#z <- (pbar-p0)/sqrt(p0*(1-p0)/n)
#n <- (z / (pbar-p0))**2 * p0*(1-p0) # z <- qnorm(1 - 0.05 / 2)
#n <- (z / moe)**2 * p0*(1-p0)
#n <- (z**2 * sd**2) / moe**2
n <- (z**2 * sd**2) / moe**2
print(n)
rm(sd, moe, z, n)


# derive the minimum sample size required to estimate the population
# proportion, based on margin of error and confidence level
p0 <- 0.5
moe <- 0.005
z <- qnorm(1 - 0.04 / 2) # z for 0.96 confidence

#z <- (pbar-p0)/sqrt(p0*(1-p0)/n)
#n <- (z / (pbar-p0))**2 * p0*(1-p0) # z <- qnorm(1 - 0.05 / 2)
#n <- (z / moe)**2 * p0*(1-p0)
#n <- (z**2 * sd**2) / moe**2
n <- (z / moe)**2 * p0*(1-p0)
print(n)
rm(p0, moe, z, n)


# ------------------------------------------------------------------------
# Test of Population Mean with Unknown Variance
# http://www.r-tutor.com/elementary-statistics/hypothesis-testing
# ------------------------------------------------------------------------

# Test statistic t in terms of the sample mean, sample size and sample 
# standard deviation:
# t=(xbar-mu0)/(s/sqrt(n))

# Example 1 (Lower tail test):

# The null hypothesis of the lower tail test of the population mean can be
# expressed as mu >= mu_0, where mu_0 is a hypothesized value of the true 
# population mean mu. 

# The null hypothesis of the two-tailed test is to be rejected if 
# t <= -t_alpha, where t_alpha is the 100(1 - alpha) percentile of the 
# Student t distribution with n - 1 degress of freedom.

# manufacturer claims that the mean lifetime of a light bulb is more than 
# 10,000 hours
# in a sample of 30 light bulbs, it was found that they only last 9,900 
# hours on average with a standard deviation of 125 hours
# can we reject the claim by the manufacturer?
# null hypothesis is that mu >= 10000
# alternative hypothesis is that mu < 10000
xbar <- 9900 # sample mean
mu0 <- 10000 # hypothesized value
s <- 125 # sample standard deviation
n <- 30 # sample size
t <- (xbar-mu0)/(s/sqrt(n))
t # test statistic

alpha <- 0.05 
t.alpha <- qt(1-alpha, df=n-1) 
cv <- -t.alpha
cv # critical value

# test statistic -4.38178 is less than the critical value -1.699127 and 
# hence, at 0.05 significance level, we reject the null hypothesis 
# that the mean lifetime of a light bulb is more than 10,000 hours

#or

#p.value <- pnorm(z) 	# known variance
p.value <- pt(-abs(t), df=n-1) 	# we use -abs(t) because pt()
print(p.value) # p-value 7.035026e-05 < 0.05, reject null hypothesis
rm(xbar, mu0, s, t, alpha, t.alpha, cv, p.value)


# Example 2 (Upper tail test):

# The null hypothesis of the upper tail test of the population mean can be
# expressed as mu <= mu_0, where mu_0 is a hypothesized value of the true 
# population mean mu. 

# The null hypothesis of the two-tailed test is to be rejected if 
# t >= t_alpha, where t_alpha is the 100(1 - alpha) percentile of the 
# Student t distribution with n - 1 degress of freedom.

# cookie bag states that there is at most 2 grams of saturated fat in a 
# single cookie
# in a sample of 35 cookies, it was found that the mean amount of 
# saturated fat per cookie was 2.1 grams and the sample standard deviation
# was 0.3 grams
# can we reject the claim on food label?
# null hypothesis is that mu <= 2
# alternative hypothesis is that mu > 2
xbar <- 2.1 # sample mean
mu0 <- 2 # hypothesized value
s <- 0.3 # sample standard deviation
n <- 35 # sample size
t <- (xbar-mu0)/(s/sqrt(n))
t # test statistic

alpha <- 0.05 
t.alpha <- qt(1-alpha, df=n-1) 
cv <- t.alpha
cv # critical value

# test statistic 1.972027 is greater than the critical value of 1.690924
# hence, at 0.05 significance level, we reject the null hypothesis 
# that there is at most 2 grams of saturated fat in a single cookie

#or

#pval <- pnorm(z, lower.tail=FALSE)  	# known variance
p.value <- pt(-abs(t), df=n-1) 	# we use -abs(t) because pt()
print(p.value) # p-value 0.02839295 < 0.05, reject null hypothesis
rm(xbar, mu0, s, t, alpha, t.alpha, cv, p.value)


# Example 3 (Two tail test):

# The null hypothesis of the two-tailed test of the population mean can be
# expressed as mu=mu_0, where mu_0 is a hypothesized value of the true 
# population mean mu. 

# The null hypothesis of the two-tailed test is to be rejected if 
# t <= -t_alpha/2 or t >= t_alpha/2, where t_alpha/2 is the 100(1 - alpha)
# percentile of the Student t distribution with n - 1 degress of freedom.

# a random sample of size 100 is drawn from a normal distribution for 
# which the mean and variance are unknown 
# assume the sample mean is 50 and the std deviation of the sample is 2 
# test the hypothesis that the true mean is 56 
# null hypothesis is that mu = 56
# alternative hypothesis is that mu <> 56
xbar <- 50 # sample mean
mu0 <- 56 # hypothesized value
s <- 2 # sample standard deviation
n <- 100 # sample size
t <- (xbar-mu0)/(s/sqrt(n))
t # test statistic

alpha <- 0.05 
t.half.alpha <- qt(1-alpha/2, df=n-1) 
cv <- c(-t.half.alpha, t.half.alpha)
cv # critical value

# test statistic -30 lies outside of the critical values -1.9600 and 
# 1.9600 hence, at 0.05 significance level, we reject the null hypothesis 
# that the sample mean is equal to 56

#or

#p.value <- 2 * pnorm(z) 	# known variance
p.value <- 2 * pt(-abs(t), df=n-1) 	# we use -abs(t) because pt()
print(p.value) # p-value 1.70085e-51 < 0.05, reject null hypothesis
rm(xbar, mu0, s, t, alpha, t.half.alpha, cv, p.value)

# ------------------------------------------------------------------------
# Test of Population Proportion
# http://www.r-tutor.com/elementary-statistics/hypothesis-testing
# ------------------------------------------------------------------------

# Test statistic z in terms of the sample proportion and the sample size:
# z=(pbar-p0)/sqrt(p0*(1-p0)/n) 

# Example 1 (Lower tail test):

# The null hypothesis of the lower tailed test about population proportion 
# can be expressed as p >= p_0, where p_0 is a hypothesized value of the 
# true population proportion p. 

# The null hypothesis of the two-tailed test is to be rejected if 
# z <= -z_alpha, where z_alpha is the 100(1 - alpha) percentile of the 
# standard normal distribution.

# 60% of citizens voted in last election
# 85 out of 148 people in a telephone survey said that they voted in 
# current election
# can we reject the null hypothesis that the proportion of voters in the 
# population is above 60% this year?
# null hypothesis is that p >= 60%
# alternative hypothesis is that p < 60%
pbar <- 85/148 # sample proportion
p0 <- 0.6 # hypothesized value
n <- 148 # sample size
z <- (pbar-p0)/sqrt(p0*(1-p0)/n)
z # test statistic
p <- pnorm(z) # lower-tail, p-value P(z* > -z) probability that you would get a sample proportion of pbar or greater
p # p-value

alpha <- 0.05
z.alpha <- qnorm(1-alpha)
cv <- -z.alpha
cv # critical value

# test statistic -0.6376 is not less than the critical value of -1.6449
# hence, at 0.05 significance level, we do not reject the null hypothesis 
# that the proportion of voters in the population is above 60% this year

#or

prop.test(85, 148, p=0.6, alt='less', correct=FALSE, conf.level=0.95) # p-value 0.2619 > 0.05, do not reject null hypothesis
rm(pbar, p0, n, z, alpha, z.alpha, cv)


# Example 2 (Upper tail test):

# The null hypothesis of the upper tailed test about population proportion 
# can be expressed as p <= p_0, where p_0 is a hypothesized value of the 
# true population proportion p.

# The null hypothesis of the two-tailed test is to be rejected if 
# z >= z_alpha, where z_alpha is the 100(1 - alpha) percentile of the 
# standard normal distribution.

# can we reject the null hypothesis that the proportion of ceos aged 45 
# years or older is less than 50%?
# null hypothesis is that p <= 50%
# alternative hypothesis is that p > 50%
age <- salaries$AGE >= 45
pbar <- sum(age)/length(age) # sample proportion
p0 <- 0.5 # hypothesized value
n <- length(age) # sample size
z <- (pbar-p0)/sqrt(p0*(1-p0)/n) # z <- (stu-np)/sd
z # test statistic
p <- pnorm(z, lower.tail=FALSE) # upper-tail, p-value P(z* < z) probability that you would get a sample proportion of pbar or less
p # p-value

alpha <- 0.05
z.alpha <- qnorm(1-alpha)
cv <- z.alpha
cv # critical value

# test statistic 4.905779 is greater than the critical value of 1.6449
# hence, at 0.05 significance level, we reject the null hypothesis that 
# the proportion of ceos aged 45 years or older is less than 50%

#or

prop.test(sum(age), length(age), p=0.5, alt='greater', correct=FALSE, conf.level=0.95) # p-value 4.653e-07 < 0.05, reject null hypothesis
rm(pbar, p0, n, z, alpha, z.alpha, cv)


# Example 3 (Two tail test):

# The null hypothesis of the two-tailed test about population proportion 
# can be expressed as p=p_0, where p_0 is a hypothesized value of the 
# true population proportion p.

# The null hypothesis of the two-tailed test is to be rejected if 
# z <= -z_alpha/2 or z >= z_alpha/2, where z_alpha/2 is the 100(1 - alpha) 
# percentile of the standard normal distribution. 

# a coin is flipped 100 times at the 0.95 confidence level, test the null 
# hypothesis the coin is unbiased versus the alternative that it is biased 
# if 43 heads are obtained
# null hypothesis is that p=50%
# alternative hypothesis is that p <> 50%
pbar <- 43/100 # sample proportion
p0 <- 0.5 # hypothesized value
n <- 100 # sample size
z <- (pbar-p0)/sqrt(p0*(1-p0)/n)
z # test statistic
p <- 2 * pnorm(z, lower.tail=FALSE) # two-tailed
p <- pnorm(z, lower.tail=FALSE) # upper-tail, p-value P(z* < z) probability that you would get a sample proportion of pbar or less
p <- pnorm(z) # lower-tail, p-value P(z* > -z) probability that you would get a sample proportion of pbar or greater
p # p-value

alpha <- 0.05
z.half.alpha <- qnorm(1-alpha/2)
cv <- c(-z.half.alpha, z.half.alpha)
cv # critical value

# test statistic -1.4 lies between the critical values -1.9600 and 1.9600
# hence, at 0.05 significance level, we do not reject the null hypothesis 
# that the coin toss is fair

#or

prop.test(43, 100, p=0.5, alt='two.sided', correct=FALSE, conf.level=0.95) # p-value 0.1615 > 0.05, do not reject null hypothesis

rm(pbar, p0, n, z, p, alpha, z.half.alpha, cv)


# ------------------------------------------------------------------------
# Comparison of Population Mean Between Two Independent Samples
# http://www.r-tutor.com/elementary-statistics/inference-about-two-populations
# ------------------------------------------------------------------------

# Example 1 (Upper tail test):

# test claim that mean is greater than another
# null hypothesis is that p1 <= p2
# alternative hypothesis is that p1 > p2
n1 <- 85
x1 <- 38
n2 <- 90
x2 <- 23

z.prop=function(x1,x2,n1,n2){
  numerator=(x1/n1) - (x2/n2)
  p.common=(x1+x2) / (n1+n2)
  denominator=sqrt(p.common * (1-p.common) * (1/n1 + 1/n2))
  z.prop.ris=numerator / denominator
  return(z.prop.ris)
}

z <- z.prop(x1,x2,n1,n2)
print(z) # test statistic

alpha <- 0.05
z.alpha <- qnorm(1-alpha)
cv <- z.alpha
cv # critical value

rm(x1, x2, n1, n2, z, alpha, z.alpha, cv)


# Example 2 (Upper tail test):

# test claim that mean is greater than another
# null hypothesis is that p1 <= p2
# alternative hypothesis is that p1 > p2
n1 <- 16
x1 <- 73
s1 <- 10.9
n2 <- 12
x2 <- 68.4
s2 <- 8.2

t.stat=function(x1, x2, n1, n2, s1, s2){
  numerator=((n1-1)*s1^2)+((n2-1)*s2^2)
  denominator=(n1 + n2 - 2)
  s=sqrt(numerator / denominator)
  
  numerator=(x1-x2)
  denominator=s*sqrt((1/n1)+(1/n2))
  t=numerator / denominator
  return(t)
}

t <- t.stat(x1, x2, n1, n2, s1, s2)
print(t)

alpha <- 0.05 
df <- (n1 - 1) + (n2 - 1)
t.alpha <- qt(1-alpha, df=df) 
cv <- t.alpha
cv # critical value

rm(x1, x2, n1, n2, s1, s2, df, t, alpha, t.alpha, cv)


# Example 3 (Two tail test):

# compare mean selling prices between homes located in the northeast 
# sector of the city versus the remaining homes at the 0.95 confidence 
# level, is there a significant difference between the two?
NE_PRICE <- subset(houses, subset=(NBR == 'YES'))$PRICE
OTHER_PRICE <- subset(houses, subset=(NBR == 'NO'))$PRICE
t.test(NE_PRICE, OTHER_PRICE, alternative='two.sided', conf.int=0.95) # p-value 0.1134 > 0.05, do not reject null hypothesis


# Example 4 (Two tail test):

# compare mean salaries between rural and non-rural areas at the 0.95 
# confidence level, is there a significant difference between the two?
RURAL_SALARY <- subset(nsalary, subset=(RURAL == 'YES'))$NSAL
NON_RURAL_SALARY <- subset(nsalary, subset=(RURAL == 'NO'))$NSAL
t.test(RURAL_SALARY, NON_RURAL_SALARY, alternative='two.sided', conf.int=0.95) # p-value 8.504e-06 <  0.05, reject null hypothesis


# ------------------------------------------------------------------------
# Comparison of Population Proportions
# http://www.r-tutor.com/elementary-statistics/inference-about-two-populations
# ------------------------------------------------------------------------

# Example 1:

# find the 0.95 confidence interval estimate of the difference between the 
# female proportion of Aboriginal students and the female proportion of 
# Non-Aboriginal students, each within their own ethnic group
x <- table(quine$Eth, quine$Sex)
print(x)

prop.test(table(quine$Eth, quine$Sex), correct=FALSE) 

# The 0.95 confidence interval estimate of the difference between the 
# female proportion of Aboriginal students and the female proportion of 
# Non-Aboriginal students is between -15.6% and 16.7%.


# Example 2:

# when 100 volunteers in each group had been treated and evaluated, the 
# results revealed an 85% success rate for the new drug and a 65% success 
# rate for the control group at the 0.95 confidence level, is there a 
# significant difference between the two?
x <- matrix(c(85,65,15,35), nrow=2, ncol=2, byrow=FALSE, 
            dimnames=list(c('new_drug', 'control'), c('success', 'fail')))
print(x)

prop.test(x, correct=FALSE, conf.level=0.95) # p-value 0.0009589 < 0.05, reject null hypothesis


# Example 3:

# for 267 bats, one player hit 85 home runs, for 248 bats, the other 
# player hit 89 home runs assume the number of home runs follows a 
# binomial distribution at the 0.95 confidence level, is there a 
# significant difference between the two?
x <- matrix(c(85,89,(267-85),(248-89)), nrow=2, ncol=2, byrow=FALSE, 
            dimnames=list(c('Player A', 'Player B'), c('HR', 'Other')))
print(x)

prop.test(x, correct=FALSE, conf.level=0.95) # p-value 0.001091 < 0.05, reject null hypothesis


# Example 4:

# find the 0.90 confidence interval for the difference between population
# proportions, p1 - p2. x1=15, n1=50, x2=23, n2=60.
prop.test(x=c(15,23), n=c(50,60), correct=FALSE, conf.level=0.90) # p-value 0.36 > 0.10, do not reject null hypothesis


# ------------------------------------------------------------------------
# Test of Variance
# http://www.itl.nist.gov/div898/handbook/eda/section3/eda359.htm
# ------------------------------------------------------------------------

# Test statistic f in terms of the sample variance:
# f=s_1^2 / s_2^2, where s_1 and s_2 are the sample variances

# Example 1 (Upper tail test):

# The null hypothesis of the upper tailed test about population variance 
# can be expressed as s <= s_0, where s_0 is a hypothesized value of the 
# true population variance s. 

# The null hypothesis of the upper tail test is to be rejected if 
# f >= f_alpha, where f_alpha is the critical value of the F distribution.

# test claim that variance is greater than another
# null hypothesis is that s1 <= s2
# alternative hypothesis is that s1 > s1
s1 <- 23^2 # variance of sample 1 (std^2)
n1 <- 16
s2 <- 19.2^2 # variance of sample 2 (std^2)
n2 <- 17

f <- s1 / s2
f # test statistic

alpha <- 0.05
f.alpha <- qf(alpha, n1-1, n2-1, lower.tail=FALSE)
cv <- f.alpha
cv # critical value

# test statistic 1.435004 is less than the critical value of 2.352223
# hence, at .05 significance level, we fail to reject the null hypothesis 
# that s1 is less than s2

rm(s1, s2, n1, n2, f, alpha, f.alpha, cv)


# ------------------------------------------------------------------------
# Test of occurence
# http://www.itl.nist.gov/div898/handbook/eda/section3/eda358.htm
# ------------------------------------------------------------------------

# The null hypothesis of the test of occurence is that the propotion of
# occurences are all equal.

# Example 1:
# test the claim that the characteristics occur with the same frequency
# characteristic  A   B   C   D   E   F
# frequency       28  30  45  48  38  39

freq <- c(28, 30, 45, 48, 38, 39)

x <- mean(freq)
freq_err <- freq - x
chi <- sum(freq_err^2 / x)
chi # test statistic

alpha <- 0.05
df <- length(freq) - 1
c.alpha <- qchisq(1-alpha, df=df)
cv <- c.alpha
cv # critical value

# test statistic 8.263158 is less than the critical value of 11.0705
# hence, at .05 significance level, we fail to reject the null hypothesis

rm(freq, freq_err, x, chi, alpha, df, c.alpha, cv)

# Example 2:
# use a chi-square test to find a 0.95 confidence interval for the variance 
# in the amount of calories
var.conf.int=function(x, conf.level=0.95) {
  df <- length(x) - 1
  chilower <- qchisq((1 - conf.level)/2, df, lower.tail=TRUE)
  chiupper <- qchisq((1 - conf.level)/2, df, lower.tail=FALSE)
  v <- var(x)
  c(df * v/chiupper, df * v/chilower)
}
var.conf.int(beef$Calories)

# Example 3:
# use a chi-square test to see if the variance in sodium for each hot dog 
# type is different from 6000 with 0.95 confidence. 
var.conf.int=function(x, conf.level=0.95) {
  df <- length(x) - 1
  chilower <- qchisq((1 - conf.level)/2, df, lower.tail=TRUE)
  chiupper <- qchisq((1 - conf.level)/2, df, lower.tail=FALSE)
  v <- var(x)
  c(df * v/chiupper, df * v/chilower)
}
(6000 < var.conf.int(beef$Sodium)[1]) || (6000 > var.conf.int(beef$Sodium)[2]) # true, reject the null hypothesis


########################################################################## 
# Part 5 ANOVA / Regression
########################################################################## 

# ------------------------------------------------------------------------
# Notes
# ------------------------------------------------------------------------

# The linear regression equation is appropriate for prediction only when 
# there is a significant linear correlation between two variables. The 
# strength of the linear relationship (as measured by the linear 
# correlation coefficient) indicates the usefulness of the regression 
# equation for making predictions.

# The standard error of estimate, se, is a measure of the distances 
# between the observed sample y values, and the predicted values yhat. 
# Smaller values of se indicate that the actual values of y will be closer 
# to the regression line, whereas larger values of se indicate a greater 
# dispersion of the y values about the regression line. When the standard 
# error estimate is 0, the y values lie on the regression line.

# ------------------------------------------------------------------------
# Various questions on ANOVA / Regression
# ------------------------------------------------------------------------

# find the linear correlation coefficient between two vectors
x <- c(1.2, 2.7, 4.4, 6.6, 9.5)
y <- c(1.6, 4.7, 9.9, 24.5, 39.0)
cor(x^2, y)
rm(x, y)


# fit linear regression model and generate anova table
x <- c(6, 8, 20, 28, 36)
y <- c(2, 4, 13, 20, 30)
# my_model <- lm(Sunday ~ Daily, data=newspapers)
my_model <- lm(y ~ x)
summary(my_model)
anova(my_model)
rm(x, y, my_model)


# fit linear regression model with factor variable type
my_factor_model <- {PRICE ~ TYPE}
my_factor_model_fit <- lm(my_factor_model, data=tableware)
summary(my_factor_model_fit)
anova(my_factor_model_fit)


# compare the mean price for five data type levels using ANOVA
# at the 0.95 confidence level, are these prices equal?
RATE_anova <- aov(RATE~ TYPE - 1, data=tableware)
RATE_lm <- lm(RATE~ TYPE - 1, data=tableware)
summary(RATE_anova)
summary(RATE_lm)

RATEbyType <- ddply(tableware, 'TYPE', summarize,
                    RATE.mean=mean(RATE), RATE.sd=sd(RATE),
                    Length=NROW(RATE),
                    tfrac=qt(p=.975, df=Length-1),
                    Lower=RATE.mean - tfrac*RATE.sd/sqrt(Length),
                    Upper=RATE.mean + tfrac*RATE.sd/sqrt(Length)
)
RATEbyType

ggplot(RATEbyType, aes(x=RATE.mean, y=TYPE))+geom_point()+
  geom_errorbarh(aes(xmin=Lower, xmax=Upper), height=.3)+
  ggtitle('Average Rate by Day')

RATE_anova <- aov(RATE~ TYPE, data=tableware)
RATE_lm <- lm(RATE~ TYPE, data=tableware)
summary(RATE_anova)
summary(RATE_lm)


# compare the mean price for five data type levels using regression
# at the 0.95 confidence level, are these prices equal?
my_price_model <- {PRICE ~ TYPE}
my_price_model_fit <- lm(my_price_model, data=tableware)

print(confint(my_price_model_fit, level=0.95))  


# perform a one-way AOV by type on calories use Tukey's Honestly 
# Significant Difference test to see if the F-test is significant 
with(hotdogs, boxplot(Calories ~ Type, main='Calories'))

calories.anova <- aov(Calories ~ Type, data=hotdogs)
summary(calories.anova)

TukeyHSD(calories.anova, conf.level=0.95)


# calculate rediction interval of predictions from regression model at the 
# 0.95 prediction interval, what is the Sunday circulation? 
my_model <- lm(Sunday ~ Daily, data=newspapers)
predict(my_model, interval='prediction', level=0.95)


# calculate prediction interval of a particular observation from a 
# regression model at the 0.95 prediction interval, what is the Sunday 
# circulation with daily circulation of 500 thousand? 
my_model <- lm(Sunday ~ Daily, data=newspapers)

Daily <- 500
Sunday <- NA
new_data_frame <- data.frame(Daily, Sunday)
predict(my_model, newdata=new_data_frame, interval='prediction', level=0.95)


# calculate the Pearson product moment correlation
with(tableware, print(cor(DIAM, PRICE))) 

#or

cor.test(schools[,1],schools[,2])


# return Pearsons critical correlation coefficient
critical.r <- function(n, alpha=.05) {
  df <- n - 2
  critical.t <- qt(alpha/2, df, lower.tail=F)
  critical.r <- sqrt((critical.t^2) / ((critical.t^2) + df))
  return(paste(critical.t, critical.r))
}

critical.r(28) # if observed r is less than crit.r, it is not significantly different from random


# confirm regression output/ANOVA statistics

#  Example Table: Analysis of Variance
#  
#  | Source 		     | DF | Sum of Squares | Mean Square | F Value | Pr > F   |
#  |:---------------:|:--:|:--------------:|:-----------:|:-------:|:--------:|
#  | Model 			     | 6  | 2183.75946 	   | 363.95991 	 | 41.32   | < 0.0001 |
#  | Error 			     | 65 | 572.60911 	   | 8.80937 	   | 		     | 		      |
#  | Corrected Total | 71 | 2756.63857 	   | 			       | 		     |		      |
#  
#  | Source 		    |   	     |
#  |:--------------:|:--------:|
#  | Root MSE 		  | 2.96806  |
#  | Dependent Mean | 37.26901 |
#  | Coeff Var 		  | 7.96388  |
#  | R-Square 		  | 0.7923   |
#  | Adj R-Square 	| 0.7731   |
#  
#  Table: Parameter Estimates
#
#  | Variable  | DF | Parameter Estimate | Standard Error | t-value | Pr > |t| |
#  |:---------:|:--:|:------------------:|:--------------:|:-------:|:--------:|
#  | Intercept | 1 	| 14.39017 			     | 2.89157		    | 4.98 	  | < 0.0001 |
#  | X1 	     | 1 	| 1.97132 			     | 0.43653 		    | 4.52 	  | < 0.0001 |
#  | X2 	     | 1 	| 9.13895 			     | 2.30071 		    | 3.97 	  | 0.0002   |
#  | X3 	     | 1 	| 0.56485 			     | 0.26266 		    | 2.15 	  | 0.0352   |
#  | X4 	     | 1 	| 0.33371 			     | 2.42131 		    | 0.14 	  | 0.8908   |
#  | X5 	     | 1 	| 1.90698 			     | 0.76459 		    | 2.49 	  | 0.0152   |
#  | X6 	     | 1 	| -1.04330 			     | 0.64759 		    | -1.61 	| 0.1120   |
#  
#  | Number in Model | C(p)  | R-Square | AIC 	   | BIC 	    | Variables in Model |
#  |:---------------:|:-----:|:--------:|:--------:|:--------:|:------------------:|
#  | 6 				       | 7.000 | 0.7923 	| 163.2947 | 166.7792 | X1 X2 X3 X4 X5 X6  |

# t-statistic: t_0 = beta^_1 / se(beta^_1)
# R-squared: R^2 = SSR / SST = 1 - SSE / SST
# Adjusted R-squared: R_adj^2 = 1 - (SSE/(n-k-1)) / (SST/(n-1)
# F-test: F_0 = (SSR/k) / (SSE/(n-p))

fit <- lm(mpg~hp, data=mtcars)
#Estimate Std. Error t value Pr(>|t|)    
#(Intercept) 30.09886    1.63392  18.421  < 2e-16 ***
#hp          -0.06823    0.01012  -6.742  1.79e-07 ***

#Residual standard error: 3.863 on 30 degrees of freedom
#Multiple R-squared:  0.6024,	Adjusted R-squared:  0.5892 
#F-statistic: 45.46 on 1 and 30 DF,  p-value: 1.788e-07

anova(fit)
#Response: mpg
#           Df  Sum Sq  Mean Sq   F value   Pr(>F)    
#hp         1   678.37  678.37    45.46     1.788e-07 ***
#Residuals  30  447.67  14.92   

# SST: Total Sum of Squares
# SSR: Regression Sum of Squares
# SSE: Error Sum of Squares

# - The Total Sum of Squares (SST/TSS) is the total variation in the 
# sample. 
sst <- sum((mtcars$mpg - mean(mtcars$mpg))^2)
sst

# - The Error Sum of Squares (SSE/ESS)/ Residual Sum of Squares (RSS)/ 
# Sum of Squared Residuals (SSR) is the variation in the sample that 
# cannot be explained. 
sse <- sum(fit$residuals^2)
sse

# - The Regression Sum of Squares (SSR/RegSS) is the variation in the 
# sample that has been explained by the regression model:
ssr <- sst - sse
ssr

# - Residual standard error (RSE) is the square root of (RSS / degrees 
# of freedom):
rse <- sqrt(sse / fit$df.residual)
rse

# - Mean Squared Error (MSE) is the mean of the square of the residuals.
mse <- mean(fit$residuals^2)
mse

# - Root Mean Squared Error (RMSE) is the square root of MSE.
rmse <- sqrt(mse)
rmse

# - R^2
r2 <- ssr / sst
r2
#or
r2 <- 1 - sse / sst
r2

# - Adjusted R^2
# R_adj^2 = 1 - (SSE/(n-k-1)) / (SST/(n-1))
adj_r2 <- 1 - (sse / (nrow(mtcars)-1-1)) / (sst / (nrow(mtcars)-1))
adj_r2

# - F-test
# F_0 = (SSR/k) / (SSE/(n-p))
f_0 <- (ssr/1) / (sse/(nrow(mtcars)-2)) # F-test
f_0

rm(sst, sse, ssr, rse, mse, rmse, r2, adj_r2, f_0)


########################################################################## 
# Part 6 Visualization
########################################################################## 

# box-and-whisker plot
boxplot(SRS, SS)

#or

with(nsalary, boxplot(NSAL ~ RURAL))

# stem and leaf plot
#https://en.wikipedia.org/wiki/Stem-and-leaf_display
#Unlike histograms, stem-and-leaf displays retain the original data to at least 
#two significant digits, and put the data in order, thereby easing the move to 
#order-based inference and non-parametric statistics.
stem(houses$PRICE)

# histogram
hist(houses$PRICE)
#negative skew: left: mean is less than the mode/median.
#postive skew: right skew: mean is greater than the mode/median.

#or

with(houses, hist(houses$TAX, breaks=c(500, 1000, 1500, 2000, 2500, 
                                         3000, 3500, 4000, 4500)))


# qq plot
qqnorm(salaries$AGE, datax=TRUE)
qqline(salaries$AGE, datax=TRUE, distribution=qnorm, probs=c(0.25,0.75), qtype=7)


# scatterplot
plot(houses$PRICE, houses$TAX)

#or

with(tires, plot(WGT, GRO, las=1,
                 xlim=c(min(WGT, GRO), max(WGT, GRO)),
                 ylim=c(min(WGT, GRO), max(WGT, GRO))))
segments(10, 10, 45, 45)  # line of equality

#or

with(newspapers, scatter.smooth(Daily, Sunday))


# linear regression plot
my_model <- lm(Sunday ~ Daily, data=newspapers)
plot(newspapers$Daily, newspapers$Sunday)
abline(my_model)


# dual plots
par(mfrow=c(1,2))
hist(houses$TAX)
hist(houses$PRICE)
par(mfrow=c(1,1))


# -----------------------------------------------------------------------------

p <- (0.86*0.14)/((0.86*0.14)+(0.65*0.35))

# -----------------------------------------------------------------------------

x <- c(0, 1, 2, 3, 4)
p <- c(0.37, 0.13, 0.06, 0.15, 0.29)

mu <- sum(x*p)
var <- sum(((x-mu)**2)*(p))
sd <- sqrt(var)
round(sd, 2)

# -----------------------------------------------------------------------------

# 99.7% of data fall within 3 standard deviations of the mean.
sd3 <- 0.997
1-sd3

# -----------------------------------------------------------------------------

min <- -3
max <- 14
mu <- (min + max) / 2
sd <- (max-min)/sqrt(12)

# -----------------------------------------------------------------------------

n <- 85
x <- 49
alpha <- 0.02

p <- x/n
q <- 1-p

z <- qnorm(1-alpha/2)

oi <- sqrt((q*p)/n)

p - (z*oi)
p + (z*oi)

# -----------------------------------------------------------------------------

alpha <- 0.01
r <- 0.543
n <- 25

t <- (r)*(sqrt((n-2)/(1-(r**2)))); t
qt <- qt(1-alpha/2, n-2); qt
qt(1-0.05/2, 45)

# -----------------------------------------------------------------------------

x.n <- 16
x.mu <- 73
x.sd <- 10.9

y.n <- 12
y.mu <- 68.4
y.sd <- 8.2

# Determine standard error
SE <- sqrt((x.sd**2/x.n)+(y.sd**2/y.n))

# Determine degrees of freedom
df <- (x.n - 1)+(y.n - 1); df

# Determine critical value for t for 0.95 CI @ DF
cval <- qt((1-0.05/2), df)

t1 <- (x.mu - y.mu)
t2 <- sqrt(((x.sd**2)*(x.n-1)+(y.sd**2)*(y.n-1))/(df))
t3 <- sqrt((1/x.n)+(1/y.n))

t <- t1/(t2*t3); t


########################################################################## 
# Part 7 Notes
########################################################################## 

# ------------------------------------------------------------------------
# Basics
# ------------------------------------------------------------------------

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

#https://en.wikipedia.org/wiki/Normal_distribution
#skewness=0, kurtosis=0
#kurtosis values produced by R should close to 3
#If the skewness is greater than 1.0 (or less than -1.0), the skewness is 
#substantial and the distribution is far from symmetrical.
#negative skew: left: mean is less than the mode/median.
#postive skew: right skew: mean is greater than the mode/median.

#https://en.wikipedia.org/wiki/Q%E2%80%93Q_plot
#a graphical method for comparing two probability distributions by plotting their 
#quantiles against each other.
#If the two distributions being compared are similar, the points in the Q-Q plot 
#will approximately lie on the line y = x.
#If the distributions are linearly related, the points in the Q-Q plot will 
#approximately lie on a line, but not necessarily on the line y = x.
# By default qqline draws a line through the first and third quartiles

#https://en.wikipedia.org/wiki/Box_plot
#Black, 6th ed, pg 79: A box is drawn around the median with the lower and upper
#quartiles (Q1 and Q3) as the box endpoints. These box endpoints (Q1 and Q3) are 
#referred to as the hinges of the box. The value of the interquartile range (IQR)
#is computed by Q3 - Q1.
#Black, 6th ed, pg 79: Values in the data distribution that are outside the inner 
#fences but within the outer fences are referred to as mild outliers. Values that 
#are outside the outer fences are called extreme outliers.

# ------------------------------------------------------------------------
# Major Type of Analysis
# ------------------------------------------------------------------------

# 1 Exploratory Data Analysis (EDA)
# Application of EDA has two components: description and exploration. 
# Statistical summaries and visual displays are used to better understand 
# the data. 

# 2 Inferential Analysis
# Goal is to test theories or beliefs so as to say something about the 
# nature of a population or phenomenon. Analysis is based on random 
# samples that represent the population or phenomenon. 

# 3 Predictive Analysis
# Goal is to use the data on some objects to predict values for another 
# object. Various methods are employed to analyze current and historical 
# facts to make predictions about future events. 

# 4 Causal/Mechanistic Analysis
# Goal is to determine what happens to an outcome variable or object when 
# independent variables are changed. This can entail estimating the exact 
# degree of change that results from changing one or more independent 
# variables. The data results from a carefully designed and measured study 
# or experiment. Randomization may be necessary. 

# ------------------------------------------------------------------------
# T-tests Pro and Con 
# ------------------------------------------------------------------------

# Pro-

# - If assumptions are met, the t-test is fine. 
# - When assumptions aren't met, the t-test may still be robust when 
# comparing populations in some situations. 
# - With equal n and normal populations, homogeneous variance violations 
# won't increase the type I error much. 
# - With non-normal distributions and equal variances, the type I error 
# rate is maintained. 

# Con-

# - Small departures from the assumptions can result in: 
# - A reduction in the power (type II error is not maintained). 
# - Biased t-statistic and confidence intervals. 

# ------------------------------------------------------------------------
# Bootstraping
# ------------------------------------------------------------------------

# Basics -

# - The sampling distribution for a statistic is a theoretical distribution 
# whose shape is usually assumed. 
# - The entire population is never available in practice, but one of many 
# possible random samples can be taken. 
# - The sample is used as a representation of the population. 
# - By resampling from this random sample with replacement a large number 
# of times, it is possible to approximate the unknown theoretical sampling 
# distribution of a statistic. 
# - The resulting empirical sampling distribution provides information 
# about the variability of the statistic. 
# - Using this distribution, confidence intervals can be constructed.

# Advantages -

# - Achieve better accuracy and control of type I error rates as opposed to 
# just assuming there is no problem. 
# - Most of the problems associated with both accuracy and maintenance of 
# type I error rate are reduced using bootstrap methods compared to 
# Student's t-statistic. 
# - Wilcox suggests that there may be very few situations, if any, in 
# which the traditional approach offers any advantage over the bootstrap 
# approach 
# - However, the problem of outliers and the basic statistical properties 
# of means and variances remain.


########################################################################## 
# Backup
########################################################################## 

# find 0.95 confidence intervals for the mean amount of calories in each 
# type of hot dog i.e. Ha: true mean is not equal to 0
t.test(beef$Calories)$conf.int
t.test(meat$Calories)$conf.int
t.test(poultry$Calories)$conf.int


# construct 99% one-sided lower confidence intervals for the mean amount 
# of calories in each type of hot dog i.e. Ha: true mean is less than 0
t.test(beef$Calories, alt='less', conf.level=0.99)$conf.int
t.test(meat$Calories, alt='less', conf.level=0.99)$conf.int
t.test(poultry$Calories, alt='less', conf.level=0.99)$conf.int


# find the lower bound for the 0.95 confidence intervals for the mean 
# amount of calories in each type of hot dog
t.test(beef$Calories)$conf.int[1]
t.test(meat$Calories)$conf.int[1]
t.test(poultry$Calories)$conf.int[1]


# determine which type of hotdog has average calories less than 140 with 
# 0.95 confidence
as.numeric(t.test(beef$Calories)$conf.int)[1] < 140
as.numeric(t.test(meat$Calories)$conf.int)[1] < 140
as.numeric(t.test(poultry$Calories)$conf.int)[1] < 140


# determine which type of hotdog has average calories not equal to 140 
# with 0.95 confidence 
with(beef, t.test(Calories, alternative='two.sided', mu=140)) # p-value 0.003534, therefore reject null
with(meat, t.test(Calories, alternative='two.sided', mu=140))
with(poultry, t.test(Calories, alternative='two.sided', mu=140))


# the standard deviation for a normal distribution is equal to 100 units, 
# what sample size is required to estimate the unknown mean with a 0.95 
# confidence interval if the desired confidence interval has a width of 8 
# units? 
z_score <- qnorm(0.025, mean=0, sd=1, lower.tail=FALSE)
sample_size <- (z_score*100.0/4.0)**2
round(sample_size)


# consumers are presented with two beverages in random order and asked 
# which they prefer 
# the first beverage was preferred 85% of the time 
# how large a sample of consumers would be needed for the second beverage 
# to generate a 0.95 confidence interval with an overall width just less 
# than 2% (i.e. from 84% to 86%)? 
p <- 0.85
z_score <- qnorm(0.025, mean=0, sd=1, lower.tail=FALSE)
sample_size <- (z_score**2)*p*(1-p)/(0.01)**2
round(sample_size)

# Set seed for reproducibility:
set.seed(1234)

# Generate 10,000 random variables:
sample <- rnorm(10000, mean = 0, sd = 1)
# Print the variance:
sampleVar <- var(sample); sampleVar

# Increase scale of sample by 10:
sampleBig <- sample*10
# Now check variance:
sampleBigVar <- var(sampleBig); sampleBigVar

# Does increasing scale by 10, increase variance by a factor of 100?
ifelse(sampleBigVar==sampleVar*100, T, F)

# Does changing the constant (location) affect the variance?
ifelse(var(sample)==(var(sample+10)), T, F)


# -----------------------------------------------------------------------------
# `Q1`
# -----------------------------------------------------------------------------

# Suppose that a class of 30 students is assigned to write an essay.

# Suppose 4 essays are randomly chosen to appear on the class bulletin board.
# How many different groups of 4 are posssible?

Q1a <- combinations(30, 4)
nrow(Q1a)

# Suppose 4 essays are randomly chosen for awards of $10, $7, $5, and $3. How
# many different groups of 4 are possible?

# First up we have 4 possible groups ($dollars) and 4 possible essays. Order
# matters, so it's a permuatation:
Q1b1 <- permutations(4, 4)
nrow(Q1b1)

# Which gives us 24. Then we multiply 24 by the original number from Q1a:
Q1b2 <- nrow(Q1a) * nrow(Q1b1)
Q1b2

# -----------------------------------------------------------------------------
# `Q2`
# -----------------------------------------------------------------------------

# Use Bayes' theorem to find the indicated probability. Use the results 
# summarized in the table.

# Create a table:
Q2table <- matrix(c(8, 17, 18, 13, 7, 37), ncol = 2, byrow = T)
colnames(Q2table) <- c("Approve of mayor", "Do not approve of mayor")
rownames(Q2table) <- c("Republican", "Democrat", "Independent")
Q2table

# Verify work for sum() argument.
Q2 <- Q2table[2,1] / sum(Q2table[1:3])
round(Q2, 4)

# -----------------------------------------------------------------------------
# `Q3`
# -----------------------------------------------------------------------------

# A police department reports that the probabilities that 0, 1, 2, and 3
# burglaries will be reported in a given day are 0.46, 0.41, 0.09, and 0.04
# respectively. Find the standard deviation for the probability distribution.
# Round answer to the nearest hundredth.

e <- c(0, 1, 2, 3)
p <- c(0.46, 0.41, 0.09, 0.04)
mu <- sum(e*p)

var <- sum(((e-mu)**2)*(p))
sd <- sqrt(var)
Q3 <- sd
round(Q3, 2)

# -----------------------------------------------------------------------------
# `Q4`
# -----------------------------------------------------------------------------

# Assume that the weight loss for the first month of a diet program varies
# between 6 pounds and 12 pounds, and is spread evenly over the range of
# possibilities, so that there is a uniform distribution. Find the probability
# of the given range of pounds lost:

# Lost between 8.5 and 10 pounds.

# Uniform distribution = all are equally likely, so likelihood for each:
pdf <- (1 / (12 - 6))
# Range of the loss:
loss <- (10 - 8.5)
# Likelihood of falling in range of loss:
Q4 <- (pdf * loss); Q4

# -----------------------------------------------------------------------------
# `Q5`
# -----------------------------------------------------------------------------

# Find the indicated z score. The graph depicts the standard normal distribution
# with mean 0 and standard deviation 1. Shaded area is 0.0901.

# Use qnorm to find z score:
z <- qnorm(0.0901); z

# -----------------------------------------------------------------------------
# `Q6`
# -----------------------------------------------------------------------------

# True or false: In a hypothesis test, an increase in alpha will cause a
# decrease in the power of the test provided the sample size is kept fixed.

# Increasing alpha generally increases the power of the test.
# Increasing sample size increases power. Alternatively, if we hold the power
#       constant, and we decrease alpha, we need a larger sample size.
# Larger alpha gives a smaller confidence level.

# Examples:
Q5a <- pwr.t.test(d = (0-5)/10,
                  n = 35,
                  sig.level = 0.01,
                  type = "paired",
                  alternative = "two.sided")
Q5a

Q5b <- pwr.t.test(d = (0-5)/10,
                  n = 35,
                  sig.level = 0.05,
                  type = "paired",
                  alternative = "two.sided")
Q5b

# -----------------------------------------------------------------------------
# `Q7`
# -----------------------------------------------------------------------------

# True or false: In a hypothesis test regarding a population mean, the 
# probability of a Type II error, beta, depends on the true value of the
# population mean.

# Alpha is the probability of rejecting the hypothesis tested when that
#       hypothesis is true - the Type I error (false positive).
# Beta is the probability of accepting the hypothesis tested when the 
#       alternative hypothesis is true - the Type II error (false negative).
# Power is the probability of rejecting the hypothesis tested when the 
#       alternative hypothesis is true.

# -----------------------------------------------------------------------------
# `Q8`
# -----------------------------------------------------------------------------

# A cereal company claims that the mean weight of the cereal in its packets is
# 14 oz. Identify the Type I error for the test.

# A Type I error is a false positive. An example of this is positively tested
#       for cancer, when you really do not have cancer. By definition, a Type I 
#       error involves the rejection of a null hypothesis that is actually true.
# A Type II error is a false negative. By definition, a Type II error involves
#       failing to reject a null hypothesis that is actually false.
# In this example, the null hypothesis (H0) is:
#       The mean weight of the cereal in its packets is 14 oz. 

# The only choice that allows this is (C): Reject the claim that the mean weight
#       is 14 oz when it is actually greater than 14 oz.

# -----------------------------------------------------------------------------
# `Q9`
# -----------------------------------------------------------------------------

# Suppose that you perform a hypothesis test regarding a population mean, and
# the evidence does not warrant rejection of the null hypothesis. When
# formulating the conclusion to the test, why is the phrase "fail to reject the
# null hypothesis" more accurate than the phrase "accept the null hypothesis"?

# We use the phrase "fail to reject the null hypothesis" because there is still
# a chance the null hypothesis is false. That size of that chance depends on
# the value of alpha that we set during the test. Our failure to reject the null
# hypothesis is only true for the assumptions and parameters we specify during
# the test, and really means that based on those, we do not find sufficient
# evidence to reject the null hypothesis. That does not entail the null
# hypothesis is true, just that we do not have sufficient evidence to reject it.

# -----------------------------------------------------------------------------
# `Q10`
# -----------------------------------------------------------------------------

# Scores on a test are normally distributed with a mean of 68.2 and a standard
# deviation of 10.4. Estimate the probability that among 75 randomly selected
# students, at least 20 of them score greater than 78.

# Score greater than means lower.tail is FALSE
p <- pnorm(78, mean = 68.2, sd = 10.4, lower.tail = F); p
p <- round(p, 4)
n <- 75
q <- 1-p
np <- n*p
nq <- n*(q)
# Both np and nq >5 so can use continuity correction.
var <- n*p*q
sd <- sqrt(var)
# Conintuity correction brings 20 to 20.5
stu <- 20.5
z <- (stu-np)/sd; z
# Look up 1.98 in z-table
0.5 - 0.4893

# -----------------------------------------------------------------------------
# `Q11`
# -----------------------------------------------------------------------------

# According to a recent poll, 53% of Americans would vote for the incumbent
# president. If a random sample of 100 people results in 45% who would vote
# for the incumbent, test the claim that the actual percentage is 53%. Use a
# 0.10 significance level.

# H0: p = 0.53
# H1: p != 0.53
# Two sided test since it's !=

p <- 0.53
phat <- 45/100
z <- ((phat - p)/(sqrt(p*(1-p)/100))); z
# z score of -1.60 = p-value of 0.0548

# Find critical values:
alpha <- 0.10
zcrit <- qnorm(1-alpha/2)

ifelse(abs(z)>zcrit,"Reject null.","Fail to reject null.")

# -----------------------------------------------------------------------------
# `Q12`
# -----------------------------------------------------------------------------

# Find the value of the linear correlation coefficient:

x <- c(47.0, 46.6, 27.4, 33.2, 40.9)
y <- c(8, 10, 10, 5, 10)
cor(x, y)

# -----------------------------------------------------------------------------
# `Q13`
# -----------------------------------------------------------------------------

# What is the relationship between the linear correlation coefficient and the
# usefulness of the regression equation for making predections?

# The linear regression equation is appropriate for prediction only when there
# is a significant linear correlation between two variables. The strength of
# the linear relationship (as measured by the linear correlation coefficient)
# indicates the usefulness of the regression equation for making predictions.

# -----------------------------------------------------------------------------
# `Q14`
# -----------------------------------------------------------------------------

# Describe the standard error of estimate, se. How do smaller values of se
# relate to the dispersion of data points about the line determined by the
# linear regression equation? What does it mean when se is 0?

# The standard error of estimate, se, is a measure of the distances between the
# observed sample y values, and the predicted values yhat. Smaller values of se
# indicate that the actual values of y will be closer to the regression line,
# whereas larger values of se indicate a greater dispersion of the y values
# about the regression line. When the standard error estimate is 0, the y
# values lie on the regression line.

# -----------------------------------------------------------------------------
# `Q15`
# -----------------------------------------------------------------------------

# Use the given sample data to test the claim that p1 > p2. Use a significance
# level of 0.01.

# H0: p1 > p2

# Sample 1
n1 <- 85
x1 <- 38

# Sample 2
n2 <- 90
x2 <- 23

pHat1 <- x1/n1
pHat2 <- x2/n2
pHat <- (x1 + x2)/(n1 + n2)
round(pHat, 4)

# Critical value:
cv <- qnorm(1-alpha)

zScore <- (pHat1 - pHat2)/(sqrt((pHat*(1-pHat))*((1/n1)+(1/n2))))
# Now look up zScore in the table: 2.66 = 0.9961

# Since our zScore is greater than our critical value, we reject the null.

# To find the p-value:
# Since we are doing greater than, we subtract 1, as z-score is to the LEFT and
# we need to look to the right.
pval <- 1 - 0.9961; pval

# -----------------------------------------------------------------------------
# `Q16`
# -----------------------------------------------------------------------------

# Two types of flares are tested and their burning times (in minutes) are
# recorded. The summarys statistics are given below.

# H0: u1 = u2
# Ha: u1 != u2

# Brand X
x.n <- 35
x.mu <- 19.4
x.sd <- 1.4

# Brand Y
y.n <- 40
y.mu <- 15.1
y.sd <- 0.8

df <- (x.n - 1) + (y.n - 1)

alpha <- 0.05
cval <- qt((1-alpha/2), df)

# -----------------------------------------------------------------------------
# `Q17`
# -----------------------------------------------------------------------------

# Construct the indicated confidence interval for the difference between
# population proportions p1 - p2. Assume that the samples are independent and
# that they have been randomly selected.

# Construct a 90% confidence interval.
alpha <- 0.10
z <- qnorm(1-alpha/2)

n1 <- 50
x1 <- 15
p1 <- x1/n1

n2 <- 60
x2 <- 23
p2 <- x2/n2

se <- sqrt((p1*(1-p1)/n1)+(p2*(1-p2)/n2))
moe <- z*se
ciLower <- (p1-p2) - moe
ciUpper <- (p1-p2) + moe
print(c(ciLower, ciUpper))

# -----------------------------------------------------------------------------
# `Q18`
# -----------------------------------------------------------------------------

# Use the given data to find the equation of the regression line. Round the
# final values to three significant digits, if necessary.

x <- c(6, 8, 20, 28, 36)
y <- c(2, 4, 13, 20, 30)

lm(y~x)