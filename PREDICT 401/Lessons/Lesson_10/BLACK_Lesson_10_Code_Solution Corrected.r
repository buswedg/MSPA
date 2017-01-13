# Solution for Lesson_10_Exercises_Using_R

# 1) A double-blind clinical trial of a new drug for back pain was 
# designed using control and treatment groups. Volunteers were fully 
# informed and assigned at random to each group. Neither the volunteers 
# nor the doctor knew when the new drug or a placebo was being administered.
# When 100 volunteers in each group had been treated and evaluated, 
# the results revealed an 85% success rate for the new drug and a 65% 
# success rate for the control group. At the 95% confidence level, 
# is there a statistically significant difference between the two 
# reported rates? Use a one-sided test. Also, report a confidence 
# interval for the difference.
x <- matrix(c(85,65,15,35), nrow = 2, ncol = 2, byrow = FALSE, 
    dimnames = list(c("new_drug", "control"),c("success", "fail")))
print(x)    
prop.test(x, alternative = "greater", conf.level = 0.95)
# p-value = 0.0009589 < 0.05 (reject null hypothesis)

# --------------------
# 2) Two baseball players had their career records compared. 
# In 267 times at bat, one player hit 85 home runs. In 248 times at bat, 
# the other player hit 89 home runs. Assume the number of home runs 
# follows a binomial distribution, is there a statistically significant 
# difference with 95% confidence between the home run averages for 
# these two baseball players? 
# (First please note that these players had short careers in a league
# somewhere on a planet with a weak gravitational force.)
x <- matrix(c(85,89,(267-85),(248-89)), nrow = 2, ncol = 2, byrow = FALSE, 
    dimnames = list(c("Player A", "Player B"), c("HR", "Other")))
print(x)
prop.test(x, alternative = "two.sided", conf.level = 0.95)
# p-value = 0.3799 > 0.05 (do not reject null hypothesis, the difference 
# between the home run rates of these players is nonsignificant.)

# --------------------
# 3) Using the home_prices.csv data, compare mean selling prices 
# between homes located in the northeast sector of the city versus 
# the remaining homes. Also, compare the mean selling prices 
# between homes with a corner lot and those located elsewhere. 
# Use two-sample t-tests for the hypothesis tests at the 95%
# confidence level. Report confidence intervals for each.
# Start by reading in data and looking at descriptive statistics.
homes <- read.csv(file.path("c:/Rdata/","home_prices.csv"))  # read data, create data frame
print(str(homes))  # examine structure
# guessing that NBR = YES is for the northeast sector of the city
print(summary(homes))  # overall descriptive statistics
with(homes, by(PRICE, NBR, summary))  # price stats across sectors
with(homes, by(PRICE, CORNER, summary))  # price stats across corner or not

# Now we are ready to do the hypothesis tests.
NE_PRICE <- subset(homes, subset = (NBR == "YES"))$PRICE
OTHER_PRICE <- subset(homes, subset = (NBR == "NO"))$PRICE
t.test(NE_PRICE, OTHER_PRICE, alternative = "two.sided", conf.int = 0.95)
# p-value = 0.1134 > 0.05 (do not reject null hypothesis, prices of homes
# in the NE are not statistically different from prices of other homes).

CORNER_PRICE <- subset(homes, subset = (CORNER == "YES"))$PRICE
NON_CORNER_PRICE <- subset(homes, subset = (CORNER == "NO"))$PRICE
t.test(CORNER_PRICE, NON_CORNER_PRICE, alternative = "two.sided", conf.int = 0.95)
# p-value = 0.6685 > 0.05 (do not reject null hypothesis, prices of homes
# on corners are not statistically different from non-corner homes).


# --------------------
# 4) The nsalary.csv data are derived from data collected 
# by the Department of Social Services of the State of New Mexico. 
# The data have been adapted for this problem. Using these data 
# compare mean salary levels between RURAL and non-RURAL locations. 
# Use a two-sample t-test at the 95% confidence level. 
# Report your results.
# Start by reading in data and looking at descriptive statistics.
nsalary <- read.csv(file.path("c:/Rdata/","nsalary.csv"))  # read data, create data frame
print(str(nsalary))  # examine structure
print(summary(nsalary))  # overall descriptive statistics
with(nsalary, by(NSAL, RURAL, summary))  # price stats across sectors


# Create comparative boxplot
with(nsalary, boxplot(NSAL ~ RURAL, main = "Salary, RURAL",
	ylab = "Salary"))
# salaries obviously different for rural vs. non-rural

RURAL_SALARY <- subset(nsalary, subset = (RURAL == "YES"))$NSAL
NON_RURAL_SALARY <- subset(nsalary, subset = (RURAL == "NO"))$NSAL
t.test(RURAL_SALARY, NON_RURAL_SALARY, alternative = "two.sided", conf.int = 0.95)
# p-value = p-value = 8.504e-06 < 0.05 (reject null hypothesis, there are
# statistically significant differences between rural and non-rural salaries.)

# --------------------
# 5) tires.csv contains data published by R.D. Stichler, 
# G.G. Richey, and J. Mandel, "Measurement of Treadware 
# of Commercial Tires, Rubber Age, 73:2 (May 1953). 
# Treadwear measures of tires each tire was subject 
# to measurement by two methods, the first based on weight 
# loss and the second based on groove wear. Use a paired 
# t-test at the 95% confidence level to test for a 
# difference between the two methods. 
# Report your results using a confidence interval.
# Start by reading in data and looking at descriptive statistics.
tires <- read.csv(file.path("c:/Rdata/","tires.csv"))  # read data, create data frame
print(str(tires))  # examine structure
print(summary(tires))  # overall descriptive statistics

# Let's see how the measures compare on a scatter plot, using
# the same scale for both axes and a diagonal line of equality.
with(tires, plot(WGT, GRO, las = 1,
    xlim = c(min(WGT, GRO), max(WGT, GRO)),
    ylim = c(min(WGT, GRO), max(WGT, GRO))))
segments(10, 10, 45, 45, col = "darkred")  # line of equality
title("Comparing Measures of Tire Wear")
# Note that all but one of the WGT measures is larger than
# the corresponding GRO measure.

# Now for the paired t-test
with(tires, t.test(WGT, GRO, alternative = "two.sided", 
    paired = TRUE, conf.level = 0.95))
# p-value = 4.614e-05 < 0.05 (reject the null hypothesis that the means
# of the two measures are identical. There are statistically significant
# differences between these two measures of tire wear.)