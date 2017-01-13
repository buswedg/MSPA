#Predict 401
##Data Analysis Assignment 2

#----------------------------------------------------------------------------
# Part 1 Table Construction and Probability Calculations
#----------------------------------------------------------------------------

#This part of the assignment will use the data in "Hospital.csv". Refer to Black 
#Business Statistics page 15 for the data dictionary, and Chapter 4 page 140 
#problem 2. Use the code in Appendix A of this assignment. Review the problem and 
#execute the code. Comment statements document the program. The table that's 
#generated will be used in Part 2.

#----------------------------------------------------------------------------
# Predict 401 Data Analysis Project 1
# Appendix A
#----------------------------------------------------------------------------

hospital <- read.csv(file.path("data/Hospital.csv"),sep=",")
str(hospital)

# Page 15 of Black has a hospital data dictionary.
# Chapter 4 page 140 problem 2.

# To generate table with margins, it is necessary to convert the variables to factors.
# In this case, it is equivalent to generating nominal variables for table construction.
control <- factor(hospital$Control)
region <- factor(hospital$Geog..Region)
control_region <- table(control, region)

# Check the structure and print out the table.
str(control_region)
control_region

# Add marginal totals and rename for simplicity.  Print the table.
# The table frequencies can be indexed by row and column.
m_c_r <- addmargins(control_region)
m_c_r

# Use of labeling with factors.
control <- factor(hospital$Control, labels = c("G_NFed","NG_NP","Profit","F_GOV"))
region <- factor(hospital$Geog..Region, labels = c("So","NE","MW",'SW',"RM","CA","NW"))
control_region <- table(control, region)
addmargins(control_region)

# The following calculations are for problem 2.

# Probability hospital is in Midwest if for-profit?
m_c_r[3,3]/m_c_r[3,8]

# Probability hospital is government federal if in the South?
m_c_r[1,1]/m_c_r[5,1]

# Probability Rocky Mountain or NP Government?
(m_c_r[5,3]+m_c_r[2,8]-m_c_r[2,3])/m_c_r[5,8]

# Probability for-profit in California?
m_c_r[3,6]/m_c_r[5,8]

# Extra problem:  Probability Control=2 but not Region 2 or 3?
x <- m_c_r[2,8]-m_c_r[2,2]-m_c_r[2,3]/m_c_r[2,8]

# Chapter 5 page 180 problem 2----------------------------

# Breakdown of hospitals by service: general hospital=1, psychiatric=2.
# Create a factor out of Service and form a table.
service <- factor(hospital$Service, labels = c("medical", "psychiatric"))
service <- table(service)
addmargins(service)

# Chapter 6  page 220 problem 3---------------------------

# Chapter 7  page 254 problem 3---------------------------

# Exact binomial probability

# Normal approximation with continuity correction.

# Second problem


#----------------------------------------------------------------------------
# Part 2 Probability Calculations
#----------------------------------------------------------------------------

#Refer to Black Business Statistics Chapter 4 page 140 problem 2, Chapter 5 page 
#180 problem 2 and Chapter 6 page 220 problem 3. Answer the questions in these 
#problems. The table constructed in Part 1 will be needed. Use library functions 
#dbinom(), dhyper() and pexp(). Lander, R for Everyone pages 185-186 lists various 
#library functions. If you have questions, for example with pexp(), type ?pexp() 
#into the console for information. The results of these calculations will be 
#needed for the quiz.

#----------------------------------------------------------------------------
# Predict 401 Data Analysis Project 1
# Appendix B
#----------------------------------------------------------------------------

hospital <- read.csv(file.path("data/Hospital.csv"),sep=",")
str(hospital)

# To generate table with margins, it is necessary to convert the variables to factors.
# In this case, it is equivalent to generating nominal variables for table construction.
control <- factor(hospital$Control)
region <- factor(hospital$Geog..Region)
control_region <- table(control, region)

# Check the structure and print out the table.
str(control_region)
control_region

# Add marginal totals and rename for simplicity.  Print the table.
# The table frequencies can be indexed by row and column.
m_c_r <- addmargins(control_region)
m_c_r

# Use of labeling with factors.
control <- factor(hospital$Control, labels = c("G_NFed","NG_NP","Profit","F_GOV"))
region <- factor(hospital$Geog..Region, labels = c("So","NE","MW",'SW',"RM","CA","NW"))
control_region <- table(control, region)
addmargins(control_region)

# Evaluation of sample size selection rules. 
# Exact probability calculation.

#p <- 0.05  #  This is where different probabilities may be substituted.
#p <- 0.2
#p <- 0.3
#p <- 0.4
p <- 0.5
#p <- 0.025
#p <- 4/9
sample_size <- numeric(0)
tail_prob <- numeric(0)

for (i in 1:80)   # Changes to 80 can lengthen or shorten the x-axis.
{N <- i*5         # Steps of 5 are being used.
Np <- N*p
sample_size[i] <- N
x <- Np+ 1.644854*sqrt((N*p*(1-p)))
tail_prob[i] <- pbinom(x, size = N, prob = p, lower.tail = FALSE, log.p = FALSE)}


N_size1 <- 5/p
N_size2 <- 9.0*(1-p)/p
N_size3 <- 15/(p*(1-p))
N_size1
N_size2
N_size3

plot(sample_size, tail_prob, type = "b", col = "blue", ylim = c(0, 0.125),
     main = "Exact")
abline(h = 0.05)
abline(h = c(0.025, 0.075), col = "red")
abline(v = N_size1, col = "green")
abline(v = N_size2, col = "black")
abline(v = N_size3, col = "purple")
#legend("bottom", legend=c("green is np >= 5","black is np >= 9(1-p)", "purple is np(1-p) >= 15"))

# Black: Page 140 Problem 2:
# Use the hospital database. Construct a cross-tabulation table for region and
# for type of control. You should have a 7x4 table. Using this table, answer
# the following questions. (Refer to Chapter 1 for category members.) 

# What is the probability that a randomly selected hospital is in the Midwest
# if the hospital is known to be for-profit?
m_c_r[3,3]/m_c_r[3,8]
#0.2444444

# If the hospital is known to be in the South, what is the probability that it
# is a government, non-federal hospital?
m_c_r[1,1]/m_c_r[5,1]
#0.3035714

# What is the probability that a hospital is in the Rocky Mountain region or a
# not-for-profit, non-government hospital?
(m_c_r[5,5]+m_c_r[2,8]-m_c_r[2,5])/m_c_r[5,8]
#0.485

# What is the probability that a hospital is a for-profit hospital located in
# California?
m_c_r[3,6]/m_c_r[5,8]
#0.045

# Black: Chapter 5 page 180 problem 2:
# Use the hospital database. 

# Create a factor out of Service and form a table
service <- factor(hospital$Service, labels = c("medical", "psychiatric"))
service <- table(service)
service <- addmargins(service)
service

# What is the breakdown between hospitals that are general medical hospitals
# and those that are psychiatric hospitals in this database of 2000 hospitals?
# (Hint: In Service, 1 = general medical and 2 = psychiatric.)
service[1:1] # medical
service[2:2] # psychiatric

# Using these figures and the hypergeometric distribution, determine the 
# probability of randomly selecting 16 hospitals from the database and getting
# exactly 9 that are psychiatric hospitals.
dhyper(x = 9, m = 32, n = 168, k = 16, log = F)

# Now, determine the number of hospitals in this database that are for-profit
# (Hint: In Control, 3 = for-profit.)
length(which(hospital$Control == 3))

# From this number, calculate p, the proportion of hospitals that are
# for-profit.
length(which(hospital$Control == 3)) / length(hospital$Control)

# Using this value of p and the binomial distribution, determine the probability
# of randomly selecting 30 hospitals and getting exactly 10 that are for-profit.
dbinom(x = 10, size = 30, prob = 0.225, log = F)

# Black: Chapter 6 page 220 problem 3:
# Use the hospital database.

# It can be determined that some hospitals admit around 50 patients per day.
# Suppose we select a hospital that admits 50 patients per day. Assuming that
# admittance only occurs within a 12-hour time period each day, and that
# admittance is Poisson distributed, what is the value of lambda per hour for
# this hospital?

lambda <- 50/12

# What is the interarrival time for admittance based on this figure?

arrival <- 1/lambda
arrival

# Suppose a person was just admitted to the hospital. What is the probability
# that it would be more than 30 minutes before the next person was admitted?

pexp(q = 3/6, rate = lambda, lower.tail = F, log.p = F)

# What is the probability that there would be less than 10 minutes before the
# next person was admitted?

pexp(q = 1/6, rate = lambda, lower.tail = T, log.p = F)


#----------------------------------------------------------------------------
# Part 3 Comparison of Probability Calculations
#----------------------------------------------------------------------------

#Refer to Black Business Statistics Chapter 7 page 254 problem 3. This problem 
#will require the table constructed in Part 1. Assume the binomial distribution 
#can be used without a finite population correction. Complete the following 
#calculations:

#1) Determine the probability (using data from Part 1), and calculate the exact 
#result using pbinom(). (Note that pbinom() does not include 225 in the upper tail
#unless it is started at 224.) Use the function pnorm() with continuity correction
#to approximate this probability.

#2) For the last calculation, subtract 1 to start the pbinom() calculation at the 
#right point for the lower tail. (i.e. start at 39 and request the lower tail). 
#Determine the exact binomial probability and also use the normal approximation 
#with continuity correction to estimate the probability.

# Black: Chapter 7 problem 3 page 254:
# Use the hospital database.

# Determine the proportion of hospitals that are under the control of
# nongovernment not-for-profit organizations (Control = 2). Assume that this
# proportion represents the entire population for all hospitals.

p <- m_c_r[2,8]/m_c_r[5,8]

# If you randomly selected 500 hospitals from across the United States, what is
# the probability that 45% or more are under the control of nongovernment 
# not-for-profit organizations? 

# Notice we subtract 1 from q!!
# Exact binomial probability:
pbinom(q = ((0.45*500)-1), size = 500, prob = p, lower.tail = F)
# Or:
1 - pbinom(q = ((0.45*500)-1), size = 500, prob = p, lower.tail = T)

# This is a data check (apparently)
x <- c(seq(1, 224, by = 1))
1 - sum(dbinom(x = x, size = 500, prob = p, log = F))

# Continuity correction:
z <- (0.45 - p)/(sqrt(p*(1-p)/500))
pnorm(z, mean = 0, sd = 1, lower.tail = F, log.p = F)

# If you randomly selected 100 hospitals, what is the probability that less
# than 40% are under the control of nongovernment not-for-profit organizations?

# We also subtract 1 from Q here, because while lower.tail = T, we pair it with
# less than, which is equivalent to lower.tail = F, and then pairing it with
# greater than. See example below.

# Exact binomial probability:
pbinom(q = ((0.40*100)-1), size = 100, prob = p, lower.tail = T)
# And now we do the inverse, "unadjusted", which gives the same result:
pbinom(q = 0.60*100, size = 100, prob = 1-p, lower.tail = F)

# Continuity correction:
z <- ((0.395)-p)/(sqrt(p*(1-p)/100))
pnorm(z, mean = 0, sd = 1, lower.tail = T, log.p = F)

#----------------------------------------------------------------------------
# Part 4 Study of Distributional Convergence
#----------------------------------------------------------------------------



#----------------------------------------------------------------------------
# Data Analysis Assignment 2 Quiz
#----------------------------------------------------------------------------

#Question 1

#Refer to your analysis of Hospital.csv Chapter 4 page 140 problem 2.

#The probability is 0.24 that a randomly selected hospital, known to be 
#for-profit, is in the Midwest.
#xTrue
#False


#Question 2

#Refer to your analysis of Hospital.csv Chapter 4 page 140 problem 2.

#If a randomly chosen hospital is known to be in the South, the probability it 
#is a government, nonfederal hospital is 0.198.
#True
#xFalse


#Question 3

#Refer to your analysis of Hospital.csv Chapter 4 page 140 problem 2.

#The probability is 0.53 that a randomly chosen hospital is in the Rocky 
#Mountain region or is a not-for-profit, nongovernment hospital.
#True
#xFalse


#Question 4

#Refer to your analysis of Hospital.csv Chapter 4 page 140 problem 2.

#The probability is 0.045 that a randomly chosen hospital is a for-profit 
#hospital located in California.
#xTrue
#False


#Question 5

#Refer to your analysis of Hospital.csv Chapter 5 problem 2 page 180 and to 
#Chapter 6 page 220 problem 3.

#The probability of randomly selecting 16 hospitals from the database and 
#getting exactly 9 that are psychiatric hospitals is 0.011. (Hint-use the 
#hypergeometric distribution.)
#True
#xFalse


#Question 6

#Refer to your analysis of Hospital.csv Chapter 5 problem 2 page 180 and to 
#Chapter 6 page 220 problem 3.

#Using the proportion of for-profit hospitals and the binomial distribution, 
#the probability of randomly selecting 30 hospitals and getting exactly 10 that 
#are for profit is 0.0610. (Hint--This assumes sampling with replacement.)
#xTrue
#False


#Question 7

#Refer to your analysis of Hospital.csv Chapter 5 problem 2 page 180 and to 
#Chapter 6 page 220 problem 3.

#If lambda per hour is 4.1667, the interarrival time for admittance is 0.24 hour.
#xTrue
#False


#Question 8

#Refer to your analysis of Hospital.csv Chapter 5 problem 2 page 180 and to 
#Chapter 6 page 220 problem 3.

#The probability more than 30 minutes would pass before the next admittance 
#is 0.125.
#xTrue
#False


#Question 9

#Refer to your analysis of Hospital.csv Chapter 5 problem 2 page 180 and to 
#Chapter 6 page 220 problem 3.

#The probability less than 10 minutes would pass before the next admittance 
#is 0.6006.
#True
#xFalse


#Question 10

#Refer to your analysis of Hospital.csv Chapter 7 problem 3 page 254. Assume 
#random sampling.

#The exact binomial probability of 45% or more of 500 hospitals being under the 
#control of non-government not-for-profit organizations is 0.171.

#(Hint--Use p = 0.43.)
#True
#xFalse


#Question 11

#Refer to your analysis of Hospital.csv Chapter 7 problem 3 page 254. Assume 
#random sampling.

#The exact binomial probability that less than 40% of 100 hospitals are under 
#the control of non-government not-for-profit organizations is 0.241. (Hint--Use 
#p = 0.43.).
#xTrue
#False


#Question 12

#The following question depends on results obtained by using the code in Appendix
#B. Only consider values of p in the assignment (0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 
#0.025) when answering.

#If p = 0.5, based on calculations using the binomial probability distribution, 
#the normal approximation to the binomial distribution may be used with a sample 
#size n >=10.

#green is np >= 5", "black is np >= 9(1-p)", "purple is np(1-p) >= 15"

#xTrue
#False


#Question 13

#The following question depends on results obtained by using the code in Appendix 
#B. Only consider values of p in the assignment (0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 
#0.025) when answering.

#If p = 0.5, the rule np>= 9(1-p) justifies using a smaller sample size than the 
#rule np(1-p)>=15.

#green is np >= 5", "black is np >= 9(1-p)", "purple is np(1-p) >= 15"

#xTrue
#False


#Question 14

#The following question depends on results obtained by using the code in Appendix
#B. Only consider values of p in the assignment (0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 
#0.025) when answering.

#If 0.2 <= p <= 0.4, then the rule np>=5 justifies using a smaller sample size 
#than the other two rules.

#green is np >= 5", "black is np >= 9(1-p)", "purple is np(1-p) >= 15"

#xTrue
#False


#Question 15

#The following question depends on results obtained by using the code in Appendix
#B. Only consider values of p in the assignment (0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 
#0.025) when answering.

#If p = 0.025, the rule np>= 9(1-p) is preferable to the other two rules.

#green is np >= 5", "black is np >= 9(1-p)", "purple is np(1-p) >= 15"

#xTrue
#False


#Question 16

#The following question depends on results obtained by using the code in Appendix
#B. Only consider values of p in the assignment (0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 
#0.025) when answering.

#If p = 4/9, the rules np >= 5 and np >= 9(1-p) give different minimum sample 
#sizes.

#green is np >= 5", "black is np >= 9(1-p)", "purple is np(1-p) >= 15"

#True
#xFalse