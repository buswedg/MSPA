# Solution for Lesson_11_Exercises_Using_R

# 1) Use the tableware.cvs data to test the hypothesis that the mean RATE
# for the five levels of TYPE are equal. Test the hypothesis using 
# a 0.05 significance level. Produce means and confidence intervals 
# for each level of TYPE.
tableware <- read.csv(file.path("c:/Rdata/","tableware.csv"))
print(str(tableware))


RATE_anova <- aov(RATE~ TYPE - 1, data = tableware)
RATE_lm <- lm(RATE~ TYPE - 1, data = tableware)

summary(RATE_anova)
summary(RATE_lm)

# ddply(), package:  plyr, can hasten generation of our per TYPE confidence
# intervals and let us output a handy table
library(plyr)
RATEbyType <- ddply(tableware, "TYPE", summarize,
                    RATE.mean=mean(RATE), RATE.sd=sd(RATE),
                    Length=NROW(RATE),
                    tfrac=qt(p=.975, df=Length-1),
                    Lower=RATE.mean - tfrac*RATE.sd/sqrt(Length),
                    Upper=RATE.mean + tfrac*RATE.sd/sqrt(Length)
                    )
RATEbyType

# We can now use Lower and Upper CI values in a plot
library(ggplot2)
ggplot(RATEbyType, aes(x=RATE.mean, y=TYPE))+geom_point()+
  geom_errorbarh(aes(xmin=Lower, xmax=Upper), height=.3)+
  ggtitle("Average Rate by Day")

# This shows the results without a -1.  The means are not different from each other.
RATE_anova <- aov(RATE~ TYPE, data = tableware)
RATE_lm <- lm(RATE~ TYPE, data = tableware)

summary(RATE_anova)
summary(RATE_lm)
# -------------------
# 2) Use the tableware.cvs data to test the hypothesis that the mean 
# PRICE for the five levels of TYPE are equal. Test the hypothesis 
# using a 0.05 significance level. Print out 95% confidence intervals 
# for each level of TYPE.

# What follows is an alternative way to code the problem.
my_price_model <- {PRICE ~ TYPE}
my_price_model_fit <- lm(my_price_model, data = tableware)
print(summary(my_price_model_fit))
print(anova(my_price_model_fit))
# Confidence intervals for the coefficients in the regression model.
print(confint(my_price_model_fit, level = 0.95))  

# --------------------
# Data Set: hot_dogs.csv
# Reference: Original source: Consumer Reports, June 1986, pp. 366-367.
# Description: Results of a laboratory analysis of calories and sodium 
# content of major hot dog brands. Researchers for Consumer Reports 
# analyzed three types of hot dog: beef, poultry, and meat 
# (mostly pork and beef, but up to 15% poultry meat). 

# 1) Use the hot_dogs.csv data. Perform a one-way AOV by Type on Calories and
# also Sodium. Use Tukey's Honestly Significant Difference test if the F-test is
# significant. Plot boxplots.

# Read in the data, create data frame, examine its structure.
hotdogs <- read.csv(file.path("c:/Rdata/","hot_dogs.csv"))
print(str(hotdogs))

# Create boxplots using Calories and Sodium, by Type.
with(hotdogs, boxplot(Calories ~ Type, main = "Calories"))
with(hotdogs, boxplot(Sodium ~ Type, main = "Sodium"))

# Perform one-way AOV, Calories
calories.anova <- aov(Calories ~ Type, data = hotdogs)
summary(calories.anova)

# Perform one-way AOV, Sodium
sodium.anova <- aov(Sodium ~ Type, data = hotdogs)
summary(sodium.anova)


# Perform Tukey's Honest Significant Difference Test
TukeyHSD(calories.anova, conf.level = 0.95)
TukeyHSD(sodium.anova, conf.level = 0.95)





