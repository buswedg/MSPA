# Solution for Lesson_12_Exercises_Using_R

# Exercises: Problems 1 through 4 use the data listed in the data file newsapers.csv. 
# The data are from the Gale Directory of Publications, 1994. A sample of 34 newspapers 
# is listed along with their Daily and Sunday circulations (in thousands).
# We begin by reading in the data and looking at the structure of these data.
newspapers <- read.csv(file.path("c:/Rdata","newspapers.csv"))
print(str(newspapers))
print(summary(newspapers))

# 1) Plot Sunday circulation versus daily circulation. Does the scatter plot 
# suggest a linear relationship between the two variables? Calculate the Pearson 
# product moment correlation coefficient between Sunday and daily circulation.
with(newspapers, plot(Daily, Sunday))
with(newspapers, scatter.smooth(Daily, Sunday))  # smooth line looks straight
with(newspapers, print(cor(Daily, Sunday)))  # strong positive correlation

# --------------
# 2) Fit a regression line with Sunday circulation as the dependent variable.  Use the 
# examples shown on pages 212-213 of Lander for this problem.
# Comment on the quality of the fit. What percent of the total variation in 
# Sunday circulation is accounted for by the regression line?
my_model <- lm(Sunday ~ Daily, data = newspapers)
my_model
summary(my_model)

plot(newspapers$Daily, newspapers$Sunday, main = "Sunday vs. Daily Circulation")
abline(my_model)

# In addition to plotting our fitted line, we should observe the behavior of the residuals.
par(mfrow=c(2,2))
plot(my_model)
par(mfrow=c(1,1))

# A linear model fits these data very well.
# R-squared:  0.9181 = proportion of Sunday circulation variance accounted for.

# --------------
# 3) Obtain 95% confidence intervals for the coefficients in the regression model.
confint(my_model, level = 0.95)  

# --------------
# 4) Determine a 95% prediction interval to predict Sunday circulation 
# for all available values of Daily circulation.

# Use predict(model, interval = "prediction", level = 0.95). 
predict(my_model, interval = "prediction", level = 0.95)  
# This gives the prediction intervals for all observations. 

# Then, define a new data frame using Daily = 500 and Sunday = NA. Predict an interval
# for Sunday circulation

# To get the prediction interval for a new observation with daily circulation 
# of 500 thousand, say, we could set up a new data frame with that value.

Daily <- 500
Sunday <- NA
new_data_frame <- data.frame(Daily, Sunday)
predict(my_model, newdata=new_data_frame, interval="prediction", level=0.95)

# --------------
#Exercises: Use the tableware.cvs data file derived from data for a line 
# of tableware manufactured by Nambe Mills.	After casting, the pieces 
# go through a series of shaping, grinding, buffing, and polishing steps. 
# Fifty-nine instances of production are listed. Variables include these
# TYPE: bowl, cass, dish, tray, plate 
# BOWL: Bowl (1) or not (0) 
# CASS: Casserole (1) or not (0) 
# DISH: Dish (1) or not (0)
# TRAY: Tray (1) or not (0) 
# DIAM: Diameter of item, or equivalent (inches) 
# TIME: Grinding and polishing time (minutes) 
# PRICE: Retail price ($) 
# RATE: Retail price divided by Time ($ per minute)
# We begin by reading in the data and looking at the structure of these data.
tableware <- read.csv(file.path("c:/Rdata","tableware.csv"))
print(str(tableware))
print(summary(tableware))

# --------------
# 5) Regress PRICE as a dependent variable against TIME. Comment on the 
# quality of the fit. Is a simple linear regression model adequate 
# or is something more needed? 
# Let's start with a couple plots.
with(tableware, plot(TIME, PRICE))
with(tableware, scatter.smooth(TIME, PRICE))  # smooth line looks straight
with(tableware, print(cor(TIME, PRICE)))  # strong positive correlation

my_model <- lm(PRICE ~ TIME, data = tableware)
my_model
summary(my_model)

plot(tableware$TIME, tableware$PRICE, main = "Tableware Price, as a function of Time")
abline(my_model)

# A linear model fits these data very well.
# R-squared:  0.8508 = proportion of PRICE variance accounted for by the model.
# We may be able to do better by adding explanatory variables, 
# but this is a good start.

# --------------
# 6) ANOVA can be accomplished using a regression model. Regress PRICE 
# against the variables BOWL, CASS, DISH and TRAY as they are presented 
# in the data file. What do the coefficients represent in this regression model?
# How is the effect of plate accounted for?
model_with_binary_indicators <- {PRICE ~ BOWL + CASS + DISH + TRAY}
model_with_binary_indicators_fit <- lm(model_with_binary_indicators, data = tableware)
print(model_with_binary_indicators_fit)
print(summary(model_with_binary_indicators_fit))
# The estimated coefficients represent incremental costs associated with the
# types of tableware. The type plate is represented by all zeroes for the 
# indicator variables included in the model with binary indicators.

index <- tableware$TYPE == "plate"
mean(tableware[index,8])


# But there is a better way to fit a model of this form using R 
# because the tableware data frame has the factor variable type.
# This factor variable can be used to create contrasts.
# If we like binary indicator contrasts, we can ask for treatment contrasts.
options(contrasts = c("contr.treatment", "contr.poly"))
my_factor_model <- {PRICE ~ TYPE}
my_factor_model_fit <- lm(my_factor_model, data = tableware)
print(my_factor_model_fit)
print(summary(my_factor_model_fit))
print(anova(my_factor_model_fit))  # type is statistically significant
# Note that the R-squared value from this model is identical to 
# that obtained with the binary indicators.

# --------------
# 7) Plot PRICE versus DIAM and calculate the Pearson product moment correlation
# coefficient. Include DIAM in the regression model in (6). Compare results between
# the two models. DIAM is referred to as a covariate. Does its inclusion improve upon
# the fit of the first model without DIAM?

plot(tableware$DIAM, tableware$PRICE, pch = 21, bg = c("darkred","blue4","plum",
	"violetred2","slategray4")[unclass(tableware$TYPE)])
legend("bottomright", legend = c("bowl","cass","dish","plate","tray"),
	col = c("darkred","blue4","plum","bisque4","slategray4"), pch = 20, bty = "n")
with(tableware, print(cor(DIAM, PRICE))) 

# First fit PRICE as a function of TYPE.
Price_Type <- {PRICE ~ TYPE}
Price_Type_fit <- lm(Price_Type, data = tableware)
summary(Price_Type_fit)
anova(Price_Type_fit)

# Then, expand the model to include DIAM
bigger_model <- {PRICE ~ DIAM + TYPE}
bigger_model_fit <- lm(bigger_model, data = tableware)
summary(bigger_model_fit)
anova(bigger_model_fit)  # both variables are significant


# Additional graphics can be examined for the fitted model itself.
# These are diagnostic graphics.
par(mfrow=c(2,2))
plot(bigger_model_fit)
par(mfrow=c(1,1))

# Note how everything we do in R involves objects and functions. 
# Fitted models are objects. And by giving these fitted models names we
# make it easy to use all kinds of functions with these models.
# By naming a fitted linear model "my_biggest_model_fit," for example,
# we can easily obtain a summary table with regression coefficients, 
# an analysis of variance for effects, and diagnostic graphics.
# We can also obtain confidence intervals, predictions, and 
# prediction intervals. R is an object-oriented programming
# environment that helps us to do data science. 



