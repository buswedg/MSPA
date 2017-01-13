# Solution for Lesson_5_Exercises_Using_R

# We use packages and functions in R whenever possible. 
# We build upon the foundation that R provides.
# The R environment includes more than five thousand packages,
# many written by the leading experts in statistics and data science.

# R provides binomial probabilties directly
# dbinom(x, size, prob, log = FALSE)  # density function
# pbinom(q, size, prob, lower.tail = TRUE, log.p = FALSE)  # distribution function
# qbinom(p, size, prob, lower.tail = TRUE, log.p = FALSE)  # quantile function
# rbinom(n, size, prob)  # here n is the number of random variates to generate
# size is number of trials, often labeled as the binomial parameter n
# prob is the binomial parameter p, probability of success
# x is a binomial random variable in [0, n]
# we can compute binomial (n, p) probabilities to four significant digits by 
# probability <- dbinom(x, size = n, prob = p)

# 1) Use R to answer the following questions.
# 1) a) Suppose a gambler goes to the race track to bet on four races. 
# There are six horses in each race. He picks one at random out of each race 
# and bets on each of the four selections. Assuming a binomial distribution, 
# answer the following questions. 
# We will assume that the races are independent events, n = 4
# We will assume that each horse has an equal probability of winning p = 1/6
# Let x be the binomial random variable, the number of wins.

# 1) a) i) The gambler wins all four races (a very lucky gambler)
prob_win_four <- dbinom(x = 4, size = 4, prob = 1/6)
sprintf("%.4f", prob_win_four)  # result printed with four places behind decimal

# 1) a) ii)	The gambler loses all four races. 
# This is the same as the probability that he/she wins no races: x = 0.
prob_loses_four <- dbinom(x = 0, size = 4, prob = 1/6)
sprintf("%.4f", prob_loses_four)  

# iii) The gambler wins exactly one race. 
prob_wins_exactly_one <- dbinom(x = 1, size = 4, prob = 1/6)
sprintf("%.4f", prob_wins_exactly_one)  

# iv) The gambler wins at least one race.
# There are a couple of ways to get at this. One would be to take the union
# of the events that he/she wins 1, 2, 3, or 4 races, use dbinom(), and 
# then use the addition rule to get the probability of the union.
# Another way, which we show here, is to take one minus the probability
# that he wins no races, a quantity we had computed in 1) a) ii).
prob_wins_at_least_one <- 1 - dbinom(x = 0, size = 4, prob = 1/6)
sprintf("%.4f", prob_wins_at_least_one)

# Please forgive the notation in 1) b), as n is a parameter of the binomial
# distribution. To avoid confusion, let m be the number of cups.
# So we will rewrite the question as follows:
# 1) b)	A woman claims she can tell by taste if cream is added before 
# a tea bag is placed in a tea cup containing hot water. 
# An experiment is designed. A series of cups of tea will be prepared 
# with m of them having the cream added prior to the tea bag and 
# m of them with the cream added after the tea bag. This gives a total 
# of 2m cups of tea. The sequence of tea cups is presented in random order. 
# If the woman cannot discriminate it will be expected on average 
# she would guess at random and be correct on half the tea cups. 
# Answer the following questions assuming the number of successes 
# follows a binomial distribution with probability equal to 0.5 and 2m trials.
# That is we are working with a binomial distribution (n = 2m, p = 0.5). 
# The p = 0.5 comes from the fact that half of the cups have cream added first
# and the other half do not.

# 1) b) i) If m = 10, what is the probability the woman is correct more than 
# 15 out of 20 times? 
# Here it is best to use the distribution function and look at the upper tail.
# pbinom(q, size, prob, lower.tail = TRUE) 
# The argument lower.tail = TRUE gives probabilities of x being q or less.
# The argument lower.tail = FALSE gives probabilities of x being greater than q.
prob_15_of_20 <- pbinom(q = 15, size = 20, prob = 0.5, lower.tail = FALSE)
sprintf("%.4f", prob_15_of_20)

# 1) b) ii) To reduce the amount of labor, how small can 2m be 
# while keeping the probability of 2m consecutive successes at or below 0.05?
# Here we can use a while-loop to find the desired value of n = 2m.
# We continue to have half of the cups with cream first (binomial p = 0.5),
# but now we are looking for a distribution function value in the upper tail
# at or below 0.05. This is the value we get from the pbinom() function.
target_p_value <- 0.05  # we will stop looking when we meet this target or go under
# later in the course we will call this a critical value in hypothesis testing
current_p_value <- 1.00  # initialze for search
n <- 0  # initialize number of cups... we will increase by 2 in each iteration
while (current_p_value > target_p_value) {
    n <- n + 2  # increase by one for this iteration
    # we are talking about consecutive hits greater than or equal to n - 1
    current_p_value <- pbinom(q = n-1, size = n, prob = 0.5, lower.tail = FALSE)
    # print out intermediate results for each iteration
    cat("\n Number of Consecutive Cups Correctly Identified:", n, "p_value: ",sprintf("%.4f", current_p_value))
    }
# when we break out of the while-loop it means that the p_value target has been met
# at this point we know the value of n... the number of consecutive successes
cat("\n\nLady Tasting Tea Solution: ", n, "Consecutive Cups Correctly Labeled",
    "\n p-value: ",sprintf("%.4f", current_p_value),"<= 0.05 critical value")
    
# 1) c) An emergency room has 4.6 serious accidents to handle on average 
# each night. Using the Poisson distribution, calculate the distribution of 
# accidents per night. (In other words, what is the probability of 0, 1, 2, ...
# accidents per night?)    
# Again we turn to built-in functions in R.
# dpois(x, lambda, log = FALSE)  # density function
# ppois(q, lambda, lower.tail = TRUE, log.p = FALSE)  # distribution function
# qpois(p, lambda, lower.tail = TRUE, log.p = FALSE)  # quantiles
# rpois(n, lambda)  # random variate generation
# To answer the question, we set lambda to 4.6 and look at the density function.
# Let's do it in a for-loop and print out intermediate results
for (x in 0:20) 
    cat("\n x:", x, "prob:", sprintf("%.4f", dpois(x, lambda = 4.6)))
    
# let's plot this probability function
x <- 0:20
prob_x <- dpois(x, lambda = 4.6)
plot(x, prob_x, las = 1, type = "h")
title("Poisson Probabilities (lambda = 4.6)")
 
# 1) d) A production process occasionally produces at random 
# a defective product at a rate of 0.001. If these products 
# are packaged 100 at a time in a box and sold, answer the 
# following questions and compare your answers. What do you conclude? 
# 1) d) i)	Using the binomial distribution, calculate the probability 
# a box has zero defectives. 
# here we let n = 100 and p = 0.001, and compute the probability x = 0
sprintf("%.4f", dbinom(x = 0, size = 100, prob = 0.001))  

# 1) d) ii)	Using the Poisson distribution, calculate the probability 
# a box has zero defectives.
# let lambda = n * p = 100 * 0.001 = .1 
sprintf("%.4f", dpois(0, lambda = 0.1))

# What do we conclude? The underlying process must be the same. 
# Bernoulli, perhaps? This also shows with a small error rate and appropriate 
# sample size the two distributions produce similar results.  
# let's check the two distributions over a limited range.

x <- 0:4
prob_x <- dpois(x, lambda = .1)
plot(x, prob_x, las = 1, type = "h")
title("Poisson Probabilities (lambda = 0.1)")

c <- c(0,1,2,3,4)
prob <- dbinom(x = c, size = 100, prob = 0.001)
plot(c, prob, las = 1, type = "h")
title("Binomial Probabilities (n = 100, p = 0.001)")
