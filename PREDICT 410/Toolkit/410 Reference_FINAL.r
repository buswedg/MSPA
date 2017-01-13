#Predict 410
##Toolkit

##########################################################################
# Part 0 Statistical Inference in Linear Regression
# http://www.jerrydallal.com/lhsp/aov1out.htm
# http://www.ats.ucla.edu/stat/sas/output/sas_glm_output.htm
# http://www.webpages.uidaho.edu/~chrisw/stat401/unbal1.pdf
# https://books.google.com.au/books?id=chSCeNpmeXUC&pg=PA33&lpg=PA33&dq=sas+%22corrected+total%22+intercept&source=bl&ots=Y7boxQ6kS3&sig=DjfP_H9QZb73zDIhwpuHKqElIMA&hl=en&sa=X&ved=0ahUKEwi8pMb_9YrNAhWDrJQKHQzxA_oQ6AEITDAI#v=onepage&q=sas%20%22corrected%20total%22%20intercept&f=false
##########################################################################

# ------------------------------------------------------------------------ 
# Model 1
# ------------------------------------------------------------------------ 

#  Table: Analysis of Variance
#  
#  | Source 		     | DF | Sum of Squares | Mean Square | F Value | Pr > F   |
#  |:---------------:|:--:|:--------------:|:-----------:|:-------:|:--------:|
#  | Model  		     | 4  | 2126.00904 	   | 531.50226 	 | 		     | < 0.0001 |
#  | Error  		     | 67 | 630.35953 	   | 9.40835 	   | 		     | 		      |
#  | Corrected Total | 71 | 2756.36857 	   | 			       | 		     | 		      |
#
#  | Source 		    |   	     |
#  |:--------------:|:--------:|
#  | Root MSE 		  | 3.06730  |
#  | Dependent Mean | 37.26901 |
#  | Coeff Var 		  | 8.23017  |
#  | R-Square 		  | 		     |
#  | Adj R-Square 	| 		     |
#  
#  Table: Parameter Estimates
#
#  | Variable  | DF | Parameter Estimate | Standard Error | t-value | Pr > |t| |
#  |:---------:|:--:|:------------------:|:--------------:|:-------:|:--------:|
#  | Intercept | 1  | 11.33027 			     | 1.99409 		    | 5.68 	  | < 0.0001 |
#  | X1 	     | 1  | 2.18604 			     | 0.41043 		    | 		    | < 0.0001 |
#  | X2 	     | 1  | 8.27430 			     | 2.33906 		    | 3.54 	  | 0.0007   |
#  | X3 	     | 1  | 0.49182 			     | 0.26473 		    | 1.86 	  | 0.0676   |
#  | X4 	     | 1  | -0.49356 			     | 2.29431 		    | -0.22 	| 0.8303   |
#
#  | Number in Model | C(p)  | R-Square | AIC 	   | BIC 	    | Variables in Model |
#  |:---------------:|:-----:|:--------:|:--------:|:--------:|:------------------:|
#  | 4 				       | 5.000 | 0.7713 	| 166.2129 | 168.9481 | X1 X2 X3 X4 	     |


# (1) How many observations are in the sample data? 

# There are 72 observations in the sample data. 

# The reported 'Corrected Total' degrees of freedom is 71, which is equal 
# to N - 1, where N is the number of observations.

# Note, this can be "Corrected Total" or "Uncorrected Total" depending on 
# whether an intercept is included or not. (NOINT)

# The "Corrected Total" adjusts the sums of squares to incorporate 
# information on the intercept. Specifically, the Corrected Total is the 
# sum of the squared difference between the response variable and the 
# mean of the response variable, whereas the "Uncorrected Total" is the 
# sum of the squared values of just the response variable, i.e. the raw
# sum of the raw sum of squares.

# ESS is likely to be larger for models without an intercept, however TSS 
# will be lower, therefore both R-square, F-stat are likely to be higher.

# Both the Total and Error degrees of freedom will be greater by one for
# a model without an intercept, since one fewer parameters have been
# estimated.


# (2) Write out the null and alternate hypotheses for the t-test for 
# Beta_1. 

# H_0 : beta_1 = 0 versus H_1 : beta_1 =/= 0


# (3) Compute the t-statistic for Beta1.

# t_0 = beta^_1 / se(beta^_1)

# where,
# beta^_1 is the estimated coefficient
# se(beta^_1) is the standard error of that estimate

# t_0 = 2.18604 / 0.41043
b_1 <- 2.18604
seb_1 <- 0.41043
t_0 <- b_1 / seb_1
print(t_0)
rm(b_1, seb_1, t_0)


# (4) Compute the R-Squared value for Model 1.

# R^2 = SSR / SST = 1 - SSE / SST

# where,
# SSR is the sum of the squares for regression
# SSE is the sum of the squares for residuals
# SST is the total sum of squares

# R^2 = 1 - 630.35953 / 2756.36857
ssr <- 2126.00904
sse <- 630.35953
sst <- 2756.36857
r2 <- 1 - sse / sst
print(r2)
rm(ssr, sse, sst, r2)


# (5) Compute the Adjusted R-Square value for Model 1. 

# R_adj^2 = 1 - (SSE/(n-k-1)) / (SST/(n-1))
# R_adj^2 = 1 - (SSE/(n-p)) / (SST/(n-1)) 

# where,
# n is the number of observations
# p is the total number of paramters in the model
# k is the number of parameters in the model excluding any intercept
# SSE is the sum of the squares for residuals
# SST is the total sum of squares

# R_adj^2 = 1 - (630.35953/(72-5)) / (2756.36857/(72-1)) 
sse <- 630.35953
sst <- 2756.36857
n <- 72 # corrected total DF + 1
p <- 5 # incl. intercept
k <- 4 # excl. intercept
adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
print(adjr2)
rm(sse, sst, n, p, k, adjr2)

#or

# R_adj^2 = 1 - (1-R^2) * ((n-1) / (n-k-1))
r2 <- 0.771308
n <- 72 # corrected total DF + 1
p <- 5 # incl. intercept
k <- 4 # excl. intercept
adjr2 <- 1 - (1-r2) * ((n-1) / (n-k-1))
print(adjr2)
rm(r2, n, p, k, adjr2)


# (6) Write out the null and alternative hypotheses for the Overall 
# F-test. 

# H_0 : beta_1 = beta_2 = ... = beta_m = 0, versus 
# H_1 : At least one of beta_1, beta_2, ..., beta_m is non-zero

# where,
# m is the number of paramters in the model

# The F-statistic has a F-distribution with (k,n-p) degrees-of-freedom for
# a regression model with k predictor variables and p total parameters.


# (7) Compute the F-statistic for the Overall F-test.

# F_0 = (SSR/k) / (SSE/(n-p))

# where,
# n is the number of observations
# p is the total number of paramters in the model
# k is the number of parameters in the model excluding any intercept
# SSR is the sum of the squares for regressionsiduals
# SST is the total sum of squares

# F_0 = (2126.00904/4) / (630.35953/(72-5))
sse <- 630.35953
ssr <- 2126.00904
n <- 72 # corrected total DF + 1
p <- 5 # incl. intercept
k <- 4 # excl. intercept
f_0 <- (ssr/k) / (sse/(n-p))
print(f_0)
rm(sse, ssr, n, p, k, f_0)


# ------------------------------------------------------------------------ 
# Model 2
# ------------------------------------------------------------------------ 

#  Table: Analysis of Variance
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


# (8) Now let's consider Model 1 and Model 2 as a pair of models. Does Model 1 
# nest Model 2 or does Model 2 nest Model 1? Explain. 

# Y = beta_0 + beta_1(X_1) + beta_2(X_2) + beta_3(X_3) + beta_4(X_4) : Model 1
# Y = beta_0 + beta_1(X_1) + beta_2(X_2) + beta_3(X_3) + beta_4(X_4) + beta_5(X_5) + beta_6(X_6) : Model 2

# Predictor variables in Model 1 are a subset of the predictor variables 
# in Model 2. Therefore Model 1 nests Model 2, or Model 1 is nested by 
# Model 2. 


# (9) Write out the null and alternate hypotheses for a nested F-test using 
# Model 1 and Model 2 

# The null hypothesis is that all additional terms in the full model are
# equal to zero, with the alternate hypothesis that at least one of the
# additional terms in the full model are non-zero.

# H_0 : beta_k+1 = beta_k+2 = ... = beta_k+p = 0, versus 
# H_1 : At least one of beta_k+1, beta_k+2, beta_k+p is non-zero

# where,
# k is the number of paramters in the reduced model
# p is the number of additional parameters in the full model


# (10) Compute the F-statistic for a nested F-test using Model 1 and Model 2

# F_0 = ((SSE(RM)-SSE(FM)) / (dim(FM)-dim(RM))) / (SSE(FM)/(n-dim(FM)))
# F_0 = ((630.35953-572.60911) / (7-5)) / (572.60911/(72-7))

# where,
# n is the number of observations
# dim(FM) is the number of parameters in the full model
# dim(RM) is the number of parameters in the reduced model
# SSE(FM) is the sum of squares for residuals for the full model
# SSE(RM) is the sum of squares for residuals for the reduced model

# If F >= F(alpha, v1, v2), reject H_0
n <- 72 # corrected total DF + 1
dimFM <- 7 # incl. intercept
dimRM <- 5 # incl. intercept
sseFM <- 572.60911
sseRM <- 630.35953
f_0 <- ((sseRM-sseFM) / (dimFM-dimRM)) / (sseFM/(n-dimFM))
print(f_0)
rm(n, dimFM, dimRM, sseFM, sseRM, f_0)


# (11) Compute the AIC values for both Model 1 and Model 2

# AIC = n * ln(SSE/(n)) + 2*p

# Model 1
#72 * log(630.35953/72) + (2*5)
n <- 72 # corrected total DF + 1
p <- 5 # incl. intercept
sse <- 630.35953
aic <- n * log(sse/(n)) + 2*p
print(aic)
rm(n, p, sse, aic)

# Model 2
#72 * log(572.60911/72) + (2*7)
n <- 72 # corrected total DF + 1
p <- 7 # incl. intercept
sse <- 572.60911
aic <- n * log(sse/(n)) + 2*p
print(aic)
rm(n, p, sse, aic)


# (12) Compute the BIC values for both Model 1 and Model 2

# BIC = n * ln(SSE/(n)) + p*ln(n)

# Model 1
#72 * log(630.35953/72) + (2*(5+2)*((72*9.40835)/(630.35953))) - (2*((72*9.40835)/(630.35953))**2)
n <- 72 # corrected total DF + 1
p <- 5 # incl. intercept
sse <- 630.35953
bic <- n * log(sse/(n)) + p*log(n)
print(bic)
rm(n, p, sse, bic)


# Model 2
#72 * log(572.60911/72) + (2*(7+2)*((72*8.80937)/(572.60911))) - (2*((72*8.80937)/(572.60911))**2)
n <- 72 # corrected total DF + 1
p <- 7 # incl. intercept
sse <- 572.60911
bic <- n * log(sse/(n)) + p*log(n)
print(bic)
rm(n, p, sse, bic)


# (13) Compute the Mallow's C_p values for both Model 1 and Model 2

# C_p = (SSE / MSE) -n + 2*p

# Model 1
#(630.35953/9.40835) + (2*5) - 72
n <- 72 # corrected total DF + 1
p <- 5 # incl. intercept
sse <- 630.35953
mse <- 9.40835
c_p <- (sse / mse) -n + 2*p
print(c_p)
rm(n, p, sse, mse, c_p)

# Model 2
#(572.60911/8.80937) + (2*7) - 72
n <- 72 # corrected total DF + 1
p <- 7 # incl. intercept
sse <- 572.60911
mse <- 8.80937
c_p <- (sse / mse) -n + 2*p
print(c_p)
rm(n, p, sse, mse, c_p)


# (14) Verify the t-statistics for the remaining coefficients in Model 1

# t_0 = beta^_1 / se(beta^_1)

# where,
# beta^_1 is the estimated coefficient
# se(beta^_1) is the standard error of that estimate

# Intercept
11.33027/1.99409

# X1
2.18604/0.41043

# X2
8.27430/2.33906

# X3
0.49182/0.26473

# X4
-0.49356/2.29431


# (15) Verify the Mean Square values for Model 1 and Model 2.

# R^2 = SSR / k

# where,
# SSR is the sum of the squares for regression
# k is the number of parameters in the model excluding any intercept

# Model 1
#2126.00904/4
ssr <- 2126.00904
k <- 4 # excl. intercept
mse <- ssr / k
print(mse)
rm(mse)


# Model 2
#2183.75946/6
ssr <- 2183.75946
k <- 6 # excl. intercept
mse <- ssr / k
print(mse)
rm(mse)


# (16) Verify the Root MSE values for Model 1 and Model 2.

# Model 1
sqrt(9.40835)

# Model 2
sqrt(8.80937)


##########################################################################
# Part 3 Notes
##########################################################################

# ------------------------------------------------------------------------ 
# Basic
#
# Text - Introduction to Linear Regression Analysis
# - Ch2: Simple Linear Regression
# - Ch3: Multiple Linear Regression
#
# Text - Multivariable Modeling
# - Ch3: Simple Linear and Locally Weighted Regression
# - Ch4: Multiple Linear Regression
# - pg73: Exploratory Data Analysis 
#
# Text - SAS Statistics by Example
# - pg120: Running a simple linear regression
# - ch9: Multiple Regression
#
# Text - The Little SAS Book
# - s9.10: Using PROC REG for Simple Regression Analysis
#
# Assigned readings - Exploratory data analysis and simple linear regression
# Chapters 1-2, pp. 1-66 Montgomery - Introduction to Linear Regression Analysis
# Chapters 2-3, pp.11-49 Fox - Applied Regression Analysis and Generalized Linear Models
#
# Assigned readings - Multiple Linear Regression
# Chapter 3, pp. 67-128 Montgomery - Introduction to Linear Regression Analysis
#
# ------------------------------------------------------------------------ 

# What is regression?

# Statistical technique for modelling relationship between two variables.

# Regression analysis helps one understand how the typical value of the 
# dependent variable changes when any one of the independent variables is 
# varied, while the other independent variables are held fixed.


# Simple vs. Multiple:

# Simple linear regression: y = beta_0 + beta_1(x) + epsilon
# Has only one regressor (or predictor variable)

# Multiple linear regression: y = beta_0 + beta_1x + beta_k(z) epsilon
# Has more than one regressor (or predictor variable)


# EDA:

# For simple linear regression, any univariate/bivariate plot: Scatter 
# plots, histogram, boxplot etc. 

# For multiple linear regression, many univariate plots

# For mix of continuous and categorical types: univariate analysis via a 
# tabulation (bin) of frequencies, with a calculation of the amount of
# observations which fall within each range.


# ------------------------------------------------------------------------ 
# Statistical Inference versus Predictive Modeling
#
# Text - Introduction to Linear Regression Analysis
# - s2.3: Hypothesis testing on the slope and intercept
# - s3.3: Hypothesis testing in multiple linear regression
# - s12.6: Statistical inference in non-linear regression
#
# Assigned readings - Model validation
# Montgomery - Introduction to Linear Regression Analysis
# - Chapter 4, pp. 129-170
# - Chapter 6, pp. 211-222
# - Chapter 11, pp. 372-388
#
# Course reserves - Best Practice of Modeling Process in a Business Environment
# ------------------------------------------------------------------------ 

# Difference:

# Can build statistical models for inference purposes or predictive 
# purposes.

# Predictive modeling is primary focused on model performance that is 
# out-of-sample, and statistical inference is focused on model performance 
# that is in-sample.

# Statistical inference is focused on knowing what the response (y^) is 
# for a value of x within the original set of observations.

# Prediction is focused on knowing what the predicted response (y^) is 
# for a value of x not included within the original set of observations.

# Primary objective of any inferential procedure is to test a null 
# hypothesis. That is, using H0 for the null hypothesis and H1 for the
# alternate hypothesis, and a test statistic with a known sampling 
# distribution. 

# Primary objective of predictive modeling however is to accurately 
# produce an estimated value for the primary quantity of interest or 
# assigning an observation to the correct class.

# Focus:

# If we are constructing the model for inference purposes, we'll want a
# characterization of Y given X that is minimally biased.

# If we are constructing the model for prediction purposes, we'll be 
# willing to accept more bias if it reduces the overall variance of the 
# prediction.

# Validation:

# For statistical inference, model validation is generally referred to as 
# the assessment of goodness-of-fit and is done in-sample.

# For predictive modeling, model validation is generally referred to as 
# assessment of predictive accuracy and is done out-of-sample.

# Evaluation of goodness-of-fit is typically assessed using graphical 
# procedures (scatterplots) for the model residuals.

# Evaluation of predictive models is typically performed through a form of 
# cross-validation where the sample is split into a training sample and a 
# test sample. In this validation, the model is estimated on the training 
# sample and then evaluated out-of-sample on the testing sample, with a 
# comparison of metrics such as Mean Square Error (MSE) and Mean Absolute 
# Error (MAE).


# ------------------------------------------------------------------------ 
# Exploratory Data Analysis
#
# Text - SAS Statistics by Example
# - pg58-60: Producing scatter plots using GPLOT
# - pg61-62,33: Producing scatter plots using SGPLOT
# - pg63-68,33,114: Producing scatter plots using SGSCATTER
# - pg112: Producing scatter plots with CORR procedure
# ------------------------------------------------------------------------ 

# Comparing continuous types: scatter plot with LOESS smooth curve

# Comparing continuous to discrete types: univariate analysis via a 
# tabulation (bin) of frequencies, with a calculation of the amount of
# observations which fall within each range. This can be done with box
# plots for each binned type to show potential outliers.

# Some categorical variables can be treated as numeric is they are ordered 
# and there are a lot of categories.


# ------------------------------------------------------------------------ 
# Goodness-of-Fit
#
# Text - Introduction to Linear Regression Analysis
# - s13.2.4 Testing Goodness-of-Fit
# ------------------------------------------------------------------------ 

# Regression model validation is the process of deciding whether the 
# numerical results quantifying hypothesized relationships between 
# variables, obtained from regression analysis, are acceptable as 
# descriptions of the data. 

# To validate the model, the user assesses the goodness-of-fit (GOF).

# Notes on GOF:

# - GOF is assessed within sample 
# - The objective is to confirm the model assumptions 
# - In OLS regression the GOF is typically assessed using graphical 
# procedures (scatterplots) for the model residuals 

# R-squared/ adjusted R-squared can also be used to assess GOF.

# R-Squared does not provided definitive evidence of lack of fit. Models 
# can fit the model assumptions but not be very predictive in-sample.

# R-squared is only a good measure of goodness of fit if our regression 
# assumptions have been validated.

# Note the bias-variance trade-off:
# - Including many covariates leads to low bias and high variance.
# - Including few covariates leads to high bias and low variance.
# - the model with the smallest MSE, is the model which makes the optimal 
# bias-variance trade-off.

# ------------------------------------------------------------------------ 
# OLS Assumptions
# ------------------------------------------------------------------------ 

# Importance of validation for statitical inference:

# Model validation is determined by the prescribed use of the model. 

# Since... the model is to be used for statistical inference, and as such
# model validation is generally referred to as the assessment of 
# goodness-of-fit.

# When we fit a statistical model, the analyst has underlying assumptions 
# about the probabilistic structure for that model. If the estimated model 
# does not conform to these probabilistic assumptions, then any statistical 
# inference based on that model will be incorrect.

# In OLS regression, we make a number of assumptions, two of which are... 

# OLS assumptions:

# - Errors are normally distributed: This assumption is required for 
# hypothesis testing and interval estimation.

# - Error term has constant variance: 

# - The relationship between the response y and the regressors is linear, 
# at least approximately.

# - Error term has a zero mean 

# - Errors are independent and identically distributed (iid) 

# Methods to check:

# We usually cannot detect departures from these assumptions by examination 
# of the standard summary statistics (i.e. F-stat or R^2). Instead, methods 
# to check for departures from these assumptions are primarily based on study 
# of the model residuals.

# - Errors are normally distributed: Quantile-Quantile plot (QQ-Plot) of 
# the residuals to compare their distribution to a normal distribution.
# The normal QQ-Plot provides a line of reference for the distribution to be
# compared for normality. Under this plot, we expect the residuals to trace 
# approximately along the line y=x. Do note that there is a level of
# subjectivity associated with inerpreting this plot, as slight deviations
# from the line y=x may still be interpreted as following a normal
# distribution. In general however, if the general trend of the plotted
# distribution is more steep or shallow than the line y=x over the range,
# or if it exhibits an arced or 'S' shape, then that distribution may be
# considered non-normal.

# - Error term has constant variance: Scatterplot of the residuals against 
# each predictor variable. Or alternatively, a plot of RStudent residuals 
# which shows externally studentized residuals and includes threshold values 
# of +-2. Again, there is a level of subjectivity associated with interpreting 
# this plot, but generally, if there is any structure in this plot (e.g. a 
# fanning pattern), then non-constant variance of the residuals may be present.

# Additional considerations:

# Linear model is linear in the parameters, not the predictor variables. 

# Require that the response variable be continuous, or approximately 
# continuous. 

# The predictor variables can be either continuous or discrete. 

# Check for influential observations using a plot of RStudent residuals 
# against Leverage, as well as the plot of Cook's D distance against 
# observations:
# - For the plot of RStudent residuals against Leverage, those points 
# which lie outside the bounds are noted to be unusually high or low in 
# comparison to the remaining dataset, and therefore may be influential to 
# parameter estimates.
# - for the Cooks D distance plot, (Fox 1991) notes that attention should 
# be paid to points along the D plot which are substantially larger in 
# comparison to the remaining points, as these points are suggested to be 
# influential. 


# ------------------------------------------------------------------------ 
# ANOVA
#
# Text - Introduction to Linear Regression Analysis:
# - s2.3.3: Analysis of variance
# - s8.3: Regression approach to analysis of variance
# Text - SAS Statistics by Example
# - ch7: Running a one-way ANOVA
# - ch12: Performing a Kruskal-Wallis One-Way ANOVA
# - ch13: Computing Sample Size for an ANOVA Design
# Text - The Little SAS Book
# - s19.12 Using PROC ANOVA for One-way Analysis of Variance
# - s19.13 Reading the output of PROC ANOVA
# ------------------------------------------------------------------------ 

# Analysis of Variance or ANOVA Table is a fundamental output from a 
# fitted OLS regression model. 

# The output from the ANOVA table is ued for a number of purposes: 

# - Show the decomposition of the total variation. 
# - Compute the R-Squared and Adjusted R-Squared metrics. 
# - Perform the Overall F-test for a regression effect. 
# - Perform a F-test for nested models as commonly used in forward, 
# back-ward, and stepwise variable selection. 

# Decomposing the sample variation: 
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

# ------------------------------------------------------------------------
# Regression Metrics
#
# Text - Introduction to Linear Regression Analysis
# - s2.12.2: Correlation Coefficient
# - s10.1.3: AIC and BIC
# Text - Multivariable Modeling
# - pg94-95, 126-128: AIC
# - pg257-258: BIC)
# Text - SAS Statistics by Example
# - ch8: Correlation and regression
# - pg211: Folded f-test
# - pg187, 199-200: AIC
# - pg138, 142-145: Mallows Cp 
# ------------------------------------------------------------------------ 

# t-statistic: t_0 = beta^_1 / se(beta^_1)

# - t-statistic can be thought of as a measure of the precision with which 
# the regression coefficient is measured. 
# - t-statistic is the ratio of the parameter estimate (the beta 
# coefficient) to its standard error. 
# - The standard error is an estimate of the standard deviation of the 
# coefficient, the amount it varies across cases. 
# - If the standard error is 'small' compared to the size of the estimate, 
# then the t-statistic is large. 
# - Regression coefficients are estimated with respect to the other 
# predictor variables (and their coefficients) in the model, hence they 
# are sometimes called 'partial regression coefficients' since they 
# represent the partial effect of the predictor variable.

# R-squared: R^2 = SSR / SST = 1 - SSE / SST

# - R-squared of the regression is the fraction of the variation in your 
# dependent variable that is accounted for (or predicted by) your 
# independent variables. 
# - R-Square will always increase as regressors are added to the model.
# - R-Squared value for the no intercept model is computed with a similar 
# formula as in the case of the intercept model. The formula is the same 
# if you set Y-bar equal to zero, even if Y-bar is not equal to zero in 
# the data. This is where the difference occurs. The R-Squared value for 
# the no intercept model assumes a sample mean of zero, or ties the 
# 'center' to the origin and not the overall mean. 

# R-squared vs Rho

# R-squared or coeff. of determination:
# - shows the amount of variation in response variable which is explained 
# by predictor variable 
# - lies between 0 and 1 

# correlation coefficient (R):
# - shows degree of relationship between two variables
# - lies between -1 and 1

# Adjusted R-squared: R_adj^2 = 1 - (SSE/(n-k-1)) / (SST/(n-1)

# - Accounts for the model complexity of the regression model allowing for 
# models of different sizes to be compared. 
# - Will not be monotonic in the number of model parameters. 
# - Will increase until you reach an optimal model, then it will flatten 
# out and likely decrease. 

# F-test: F_0 = (SSR/k) / (SSE/(n-p))

# - Used to test the overall significance of the regression.
# - Joint hypothesis test that at least one of the predictor variables has 
# a non-zero coefficient.
# - Typically, if the F-statistic is not significant, we do not continue 
# with the analysis, since the regression is not useful for prediction or
# inference.
# - If the F-statistic exceeds the critical value, then we have some 
# indication that at least one of the b_i is nonzero. However, the test 
# gives us no clue as to which of the b_i are nonzero.
# - It does not indicate that the model is "correct", or even "adequate".

# Akaike information criterion (AIC): AIC = n*ln(SSE/n)+2p

# - Provides a means for model selection.
# - Measure of the relative quality of statistical models for a given set 
# of data.
# - Deals with the trade-off between the goodness of fit of the model and 
# the complexity of the model.
# - AIC rewards goodness of fit with a penalty that is an increasing 
# function of the number of estimated parameters.
# - Preferred model is the one with the minimum AIC value.
# - The AIC penalizes the number of parameters less strongly than does the 
# BIC.
# - AIC does not provide a test of a model in the sense of testing a null 
# hypothesis; i.e. AIC can tell nothing about the quality of the model in 
# an absolute sense. If all the candidate models fit poorly, AIC will not 
# give any warning of that.

# Example:
# y = b0 + b1*X1 + b2*X2 + b3*X3
# Regression model was fitted on a sample of 250 observations and yielded 
# a likelihood value of 0.18.

q2n <- 250
q2k <- 3
q2p <- q2k + 1
q2lhd <- 0.18

#AIC = n * ln(SSE/n) + 2p
aic <- ((-2)*(log(0.18)))+(2*(q2p))
aic

# Bayesian information criterion (BIC):  BIC = n*ln(SSE/n)+p*ln(n)
# - Same as AIC, however, the BIC penalizes the number of parameters more 
# strongly than does the AIC.

# Example:
# y = b0 + b1*X1 + b2*X2 + b3*X3
# Regression model was fitted on a sample of 250 observations and yielded 
# a likelihood value of 0.18.

q3n <- 250
q3k <- 3
q3p <- q2k + 1
q3lhd <- 0.18

#BIC = n * ln(SSE/n) + p*ln(n)
bic <- ((-2)*(log(0.18)))+(q3p*(log(q3n)))
bic

# Mallows Cp:
# - Provides a means for model selection.
# - Measure of 'total error of prediction' using p parameters.
# - A small value of Cp means that the model is relatively precise.
# - Able to balance the number of predictor variables included within a 
# model.
# - When using Mallow's Cp, you should select the model with the smallest 
# Cp value that is 'close' to the diagonal line Cp = p.
# - A Mallows' Cp value which is close to the number of included 
# predictors plus the constant suggests that the model is relatively 
# unbiased.
# - the Cp approximation is only valid for large sample size.


# ------------------------------------------------------------------------ 
# Data Transformation
#
# Text - Introduction to Linear Regression Analysis
# - Ch5: Transformations and weighting to correct model inadequacies
# ------------------------------------------------------------------------ 

# Non-linear re-expression of the variables may be necessary when any of 
# the following apply:

# - The residuals have a skewed distribution. The purpose of a 
# transformation is to obtain residuals that are approximately 
# symmetrically distributed. 
# - The spread of the residuals changes systematically with the values of 
# the dependent variable. The purpose of the transformation is to remove 
# that systematic change in spread, achieving approximate 
# homoscedasticity. 
# - A desire to linearize a relationship. 
# - When the context of the data expects, e.g. chemistry concentrations a
# are expressed commonly as logarithms. 
# - A desire to simplify the model, e.g. when a log-transform can simplify 
# the number and complexity of interaction terms. 


# ------------------------------------------------------------------------ 
# Dummy variables
#
# Text - Introduction to Linear Regression Analysis
# - pg153-154: Creating dummy variables for regression
# ------------------------------------------------------------------------ 

# Dummy variables allow us to represent nominal-level independent 
# variables in statistical techniques like regression analysis.  

# Any categorical variable with k levels can be included in a regression 
# model with at most (k-1) dummy variables when an intercept is included 
# in the model. Note that this is true only if the three levels are 
# mutually exclusive (so not overlap) and exhaustive (no other levels 
# exist for the variable). 

# That is, one of the categories must serve as the 'reference' category, 
# which is the category to which you compare the other categories.

# Only Dummy Variables:

# For a variable that has three levels denoted by 1, 2, and 3, one 
# possible specification would be:

# Y = b0 + b1(L2) + b2(L3) + e

# where:

# L2 takes the value of 1 if level 2 of the categorical is true, 0 if not 
# L3 takes the value of 1 if level 3 of the categorical is true, 0 if not
# The first level of the categorical (L1) can be taken as our base.

# We can intepret the dummy variables as:

# Y_L1 = b0 + e, where L2 = 0 and L3 = 0
# Y_L2 = b0 + b1(L2) + e, where L2 = 1 and L3 = 0
# Y_L3 = b0 + b2(L3) + e, where L2 = 0 and L3 = 1

# Here, the value of each respective coefficient shows the change in the 
# value of the dependent variable compared with the base case.

# For example, if we estimated:

# Y = 1.0 + 0.5(L2) - 0.5(L3) + e

# We would say that the estimated intercept suggests that Y is equal to 
# 1.0 for our base case:

# Y = 1.0 + e

# That is, when L2 and L3 are both false, Y is equal to 1.0.

# However, when the second level categorical variable (L2) is true, it 
# acts as a positive shift on the estimated intercept coefficient,
# resulting in a greater predicted value for Y:

# Y = 1.5 + e

# That is, when L2 is true, Y is equal to 1.5.

# Likewise, when the third categorical variable (L3) is true, it acts as
# a negative shift on the estimated intercept coefficient, resulting in a
# lower predicted value for Y:

# Y = 0.5 + e

# That is, when L3 is true, Y is equal to 0.5.

# Continuous + Dummy Variables:

# If our model already included a continuous predictor variable, we could
# include the dummy variable in the same manner as above (non-interaction 
# term), and/or as an interaction term with the continuous predictor variable.

# Non-interaction Term:

# If the model had an additional continuous variable (X1), we would 
# estimate:

# Y = b0 + b1(X1) + b2(L2) + b3(L3) + e

# Similar to the above, we can intepret the dummy variables as:

# Y_L1 = b0 + b1(X1) + e, where L2 = 0 and L3 = 0
# Y_L2 = b0 + b1(X1) + b2(L2) + e, where L2 = 1 and L3 = 0
# Y_L3 = b0 + b1(X1) + b3(L3) + e, where L2 = 0 and L3 = 1

# Interaction Terms:

# If the model included dummy variables as interaction terms, we would 
# estimate:

# Y = b0 + b1(X1) + b2(X1*L2) + b3(X1*L3) + e

# In this case, We can intepret the dummy variables as:

# Y_L1 = b0 + b1(X1) + e, where L2 = 0 and L3 = 0
# Y_L2 = b0 + (b1+b2)(X1) + e, where L2 = 1 and L3 = 0
# Y_L3 = b0 + (b1+b3)(X3) + e, where L2 = 0 and L3 = 1

# For example, if we estimated:

# Y = 1.0 + 1.0(X1) + 0.5(X1*L2) - 0.5(X1*L3) + e

# We now say that the estimated intercept suggests that Y is equal to 1.0 
# for our base case, when X1 is also equal to zero. That is, when X1 is 
# equal to zero, and L2 and L3 are both false, Y is equal to 1.0.

# Now, the coefficient for X1 represents the effect of X1 on the base case
# only. That is, a one unit increase in X1 results in a +1.0 change in Y
# when L2 and L3 are false:

# Y = 1.0 + 1.0(X1) + e

# However, when the second level categorical variable (L2) is true, the
# coefficient (b2) is combined with the coefficient for X1 (b1): 

# Y = 1.0 + 1.5(X1) + e

# That is, a one unit increase in X1 when L2 is true, results in a +1.5 
# change in Y.

# Likewise, when the third level categorical variable (L3) is true, the
# coefficient (b3) is combined with the coefficient for X1 (b1):

# Y = 1.0 + 0.5(X1) + e

# That is, a one unit increase in X1 when L3 is true, results in a +0.5 
# change in Y.

# The decision of whether to include the dummy variable as an interaction
# term will depend on whether we expect the categorical variable to influence
# the relationship between X1 or Y, or whether its influence on Y should be
# independent of X1. If we believe it should influence the relationship
# between X1 and Y, we are testing for a change in slope and hence include
# the dummy variable as an interaction term. If we believe it's influence on
# Y should be independent of X1, we are testing for a change in level, and
# therefore do not include the dummy variable as an interaction term.


# ------------------------------------------------------------------------ 
# Forward, Backward and Stepwise Variable Selection
#
# Text - Introduction to Linear Regression Analysis
# - s10.2.2
# Text - Multivariable Modeling
# - pg92-94
# Text - SAS Statistics by Example
# - pg197-203: Backward elimination
# - pg145-152: Forward, Backward and Stepwise Selection Methods
# Text - The Little SAS Book
# - pg272
# ------------------------------------------------------------------------ 

# Forward selection involves starting with no variables in the model (other
# than the intercept) and testing the addition of each variable using a 
# chosen model comparison criterion. The variable (if any) that improves 
# the model the most is added over each iteration, until no further 
# improvement is possible.

# Backward elimination involves starting with all candidate variables and 
# testing the deletion of each variable using a chosen model comparison 
# criterion. The variable (if any) that improves the model the most (if 
# removed) is deleted over each iteration, until no further improvement 
# is possible. 

# Stepwise regression is a modification of forward selection in which at 
# each step all regressors entered into the model previously are 
# reassessed. A regressors added at an earlier step may now be redundant 
# because of the relationships between it and regressors is now 
# incorporated into the model. 

# For F statistic as the desired criterion: for each independent variable, 
# an F statistic is calculated that reflects the variables' contribution 
# to the model if it were included.

# For FS, variables are added one by one to the model until no remaining 
# variable produces a significant F statistic. The partial F statistic is 
# computed for each regressor as if it were to enter the model. The largest
# of these partial F statistics is compared with a preselected value, and 
# if the largest partial F is greater than the preselected value, that 
# regressor added to the model. This continues until the p-value for the 
# variable being entered is larger than a specified value.

# For BS, the reserve happens, where variables are removed one by one. The
# partial F statistic is computed for each regressor as if it were the 
# last variable to enter the model. The smallest of these partial F 
# statistics is compared with a preselected value, and if the smallest
# partial F is less than the preselected value, that regressor is removed
# from the model. This continues until the p-value for the variable being 
# removed is larger than a specified value.

# A minimum threshold can be specified, i.e. variables should only be 
# added if their coefficient estimation has a significance level (p-value) 
# less than 10%.

# For AIC/BIC as the desired criterion: for each independent variable, the 
# proceedure is terminated if its addition/removal causes no reduction of 
# AIC or BIC.

# For FS/SW + AIC: The AIC for the larger model will be smaller if it 
# reduces the log-likelihood by more than the penalty for the extra 
# parameter.

# Note, the order in which the regressors enter or leave the model does not 
# necessarily imply an order of importance to the regressors. It is not 
# unusual to find that a regressor inserted into the model early in the 
# procedure becomes negligible at a subsequent step.


# ------------------------------------------------------------------------ 
# Variable Importance
# ------------------------------------------------------------------------ 

# Statistical significance just means that the t-stat = Beta - 0 / 
# SE(Beta) is greater than the table t value. 

# So the estimated beta value is sufficiently different to zero in 
# relation to the variation (standard error) of the Beta value. 

# Being statically significant means that the estimated coefficient value 
# does not equal zero and can therefore be expected to explain some of the 
# variation in the response variable. 

# When we reject the null hypothesis that beta=0 we are saying that there 
# is some relationship between X and Y in the sense that the estimated 
# beta is estimated 'well enough' (or with enough precision) for us to 
# consider it to be different from zero. 

# Coefficient size alone does not determine the predictor's importance. 
# Coefficient size is affected by the scale of the predictor variable and 
# the scale of the response variable. 

# Given that the SE(Beta) will decrease as sample size increases we must 
# be wary of high t-values that make a regression model's coefficient 
# statistically significant and check model accuracy out-of-sample to 
# evaluate its predictive accuracy.

# A variable can be valuable from an explanatory perspective, but not 
# statistically significant. 


# ------------------------------------------------------------------------ 
# Nested models
# ------------------------------------------------------------------------ 

# Nested model is a logical subset of another model.

# When fewer parameters are estimated (i.e., more df), fit will always be 
# worse.

# If fit is almost as good, the nested model (with fewer parameters) is 
# preferred because it's more parsimonious.

# To test nested model:
# 1 Fit complete/full model and get SSE(FM)
# 2 Fit reduced model and get SSE(RM)
# 3 Set up hypothesis and choose alpha value
# 4 Compute F-statistic and compare to F(alpha, v1, v2)

# Example:
# Y = beta_0 + beta_1(X_1) + beta_2(X_2) + beta_3(X_3) + beta_4(X_4) : Model 1
# Y = beta_0 + beta_1(X_1) + beta_2(X_2) + beta_3(X_3) + beta_4(X_4) + beta_5(X_5) + beta_6(X_6) : Model 2

# Model (1) is the reduced model and model (2) is the complete/full model.

# How do we decide whether the more complex (full) model contributes 
# additional information about the association between y and the predictors?

# H_0 : beta_5 = beta_6 = 0 versus H_1 : beta_i =/= 0 where i = 5 or 6

# Test consists in comparing the SSE for the reduced model (SSE(RM)) and the
# SSE for the complete/full model (SSE(FM)).

# SSE(RM) will always be greater than SSE(FM), so test whether the drop in 
# SSE from fitting the complete model is large enough.

# F_0 = ((SSE(RM)-SSE(FM)) / (dim(FM)-dim(RM))) / (SSE(FM)/(n-dim(FM)))

# If F >= F(alpha, v1, v2), reject H_0


# ------------------------------------------------------------------------ 
# Multicollinearity
#
# Text - Introduction to Linear Regression Analysis
# - Ch9: Multicollinearity
# Text - Multivariable Modeling
# - pg90-91: Multicollinearity 
# 
# Assigned readings - Multicollinearity and Principal Components Analysis
# - Ch9, pp. 285-326 Montgomery - Introduction to Linear Regression Analysis
# - Ch9-10, pp. 169-210 - Everitt - Multivariable Modeling and Multivariate Analysis for the Behavioral Sciences
# - Ch6, pp. 264-316 - Morrison - Multivariate Statistical Methods - Optional
#
# ------------------------------------------------------------------------ 

# Multicollinearity, or near-linear dependence, is when two or more 
# predictor variables in multiple regression are highly correlated, 
# meaning that one can be linearly predicted from the others with a 
# non-trivial degree of accuracy. 

# Ways to detect multicollinearity: 

# - Large changes in the estimated regression coefficients when a 
# predictor variable is added or deleted. 
# - Insignificant regression coefficients for the affected variables in 
# the multiple regression, but a rejection of the joint hypothesis that 
# those coefficients are all zero (using an F-test). 
# - If a multivariable regression finds an insignificant coefficient of a 
# particular explanator, yet a simple linear regression of the explained 
# variable on this explanatory variable shows its coefficient to be 
# significantly different from zero, this situation indicates 
# multicollinearity in the multivariable regression. 
# - Detection-tolerance based on the variance inflation factor. 
# - Condition index for the X'X matrix

# The VIF is found by regressing all other predictor variables within the 
# original specification against the variable in question, and applying 
# the formula:

# VIF = 1 / (1-R^2)

# VIF <3: no or low multicollinearity
# VIF 3-5: some multicollinearity issues
# VIF 5-10: multicollinearity a problem
# VIF >10: multicollinearity a severe problem

# Methods to correct multicollinearity: 

# - Eliminating suspect predictor variables.
# - Variable transformations.
# - Principal Components analysis as a preconditioner for regression 
# analysis can reduce the independent variables. 


# ------------------------------------------------------------------------ 
# Principle Component Analysis
# Text - Multivariable Modeling
# s10.2: Principal Components Analysis (PCA)
# ------------------------------------------------------------------------ 

# What it is:

# PCA is a transformation of a set of correlated random variables to a set 
# of uncorrelated (or orthogonal) random variables 

# What it is used for:

# Reveals simple underlying structures in complex data sets using 
# analytical solutions from linear algebra. 

# Can also be used as a method to create a reduced rank approximation to 
# the covariance structure. i.e. perform dimensionality reduction. 

# PCA can be used as a means of creating a set of orthogonal predictor 
# variables from a set of raw predictor variables. Since the principal 
# components created from the original predictor variables are orthogonal, 
# we can use PCA as a remedy for multicollinearity in regression problems 
# or as a preconditioner to cluster analysis. 

# Notes:

# PCA is sensitive to the scale of the data. Most of the time the data 
# should be standardized. When the data re standardized our covariance 
# matrix and correlation matrix are the same matrix. 

# PCA does not require any statistical assumptions, e.g. the data are not 
# assumed to have a multivariate normal distribution. 

# How it is performed:

# 1 Standardize the data
# 2 Compute the eigenvalue-eigenvector pairs
# 3 Compute the principal components
# 4 Select number of components to retain

# Methods to select number of components to retain:

# - use the scree plot, which plots the number of components on the x-axis 
# against the proportion of the variance explained 
# - keep is the number of components where the scree plot forms an 
# elbow 
# - use a minimum eigenvalue rule such as the Kaiser Rule, which 
# recommends that the number of principal components to keep is equal to 
# the number of eigenvalues greater than one 
# - determine a threshold amount of variance to retain 

# The correct number of principal components to keep will depend on 
# the application. If you are using PCA as a preconditioner for regression 
# analysis or cluster analysis, then the effectiveness of these 
# applications under the alternate choices would determine which number is 
# the best to keep. In this sense the unsupervised learning problem has 
# been transformed into a supervised learning problem. 


# ------------------------------------------------------------------------ 
# Factor Analysis
#
# https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_factor_sect004.htm
# Text - Multivariable Modeling
# ch11: Factor Analysis
#
# Assigned readings
# Ch11, pp. 211-238 - Everitt - Multivariable Modeling and Multivariate Analysis for the Behavioral Sciences
#
# ------------------------------------------------------------------------ 

# What it is:

# Factor analysis is a statistical modeling technique used to model the 
# covariance structure in multivariate data. 

# What it is used for:

# Factor analysis estimates unobserved (or latent) relationships using 
# observed (or measured) variables. 

# Factor analysis can facilitate dimension reduction from observed 
# measurement variables to a smaller set of unobserved latent variables. 

# Can use factor analysis to improve the interpretability of our 
# multivariate data. 

# Notes:

# As a statistical modeling technique, factor analysis has statistical 
# assumptions. 

# Factor analysis is most useful on problems that are natural factor 
# analysis problems. In that matter Factor Analysis is very different 
# than Principal Components Analysis. You can apply PCA to any data that 
# is continuous or approximately continuous. 

# Base suited for if all variable names are known, i.e. we know and 
# understand all of the measurement variables. 

# All measurement variables have been purposely selected under the 
# guidance that they represent a measurement of a quality or trait that is 
# recognized as important but that cannot be directly measured. 

# Need to be able to obtain multiple measurements for each of the 
# unmeasurable qualities (the latent factors), e.g. physical attributes: 
# speed, strength, agility, educational attainment: math, reading, problem 
# solving. 

# MLE factor analysis has an associated hypothesis testing for determining 
# the number of factors. The other methods do not have a formal method for 
# determining the number of factors. 

# Exploratory versus Confirmatory Factor Analysis:

# EFA is performed when we have no preconceived notions about the factor 
# structure (i.e. the factor loadings) 

# CFA is performed when we want to statistically test a specific factor 
# structure. CFA will require the formal statistical assumptions of 
# maximum likelihood estimation so that formal statistical inference can 
# be applied. 

# Without rotation, factors are almost always orthogonal.

# How it is performed:

# 1 Perform a Principal Factor Analysis with a Varimax rotation 
# 2 Perform an iterative Principal Fator Analysis with a Varimax rotation. 
# 3 Performa Maximum Liklihood Factor Analysis with a Varimax rotation. 
# 4 Compare the solutions from these three factor analyses, are factor 
# loadings the same, is interpretability the same? 
# 5 Evaluate the factor loadings over a range of included factors (k) 
# 6 If you have enough data, then evaluate your prospective factor 
# loadings through bootstrapping or cross validation. 

# Communialities:

# The communality for a given variable can be interpreted as the proportion 
# of variation in that variable explained by the factors.
# It is found by regressing each variable against the included factors.
# Says that xx% of variation in that variable is explained by the factors.
# The total communality can be found and used to show the total variation 
# explained by the all factors.

# Choosing the amount of factors within the model: 

# - neigenvalues-greater-than-one-rule 
# - scree plot 
# - Horn's parallel analysis 

# Factor rotations are a method to improve interpretation of the factor 
# structure: 

# - Orthogonal rotations will yield orthogonal factors after the rotation. 
# The most common orthogonal rotation is the VARIMAX rotation. 
# - Oblique rotations will yield correlated factors after the rotation. 
# The most common oblique rotation is the PROMAX rotation. 


# ------------------------------------------------------------------------ 
# VARIMAX Rotation
#
# https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_factor_sect004.htm
# Text - Multivariable Modeling
# - pg225: Varimax and quartimax
# ------------------------------------------------------------------------ 

# Varimax rotation is the most common of the rotations that are available.

# Involves finding the rotation which maximizes the variances of the 
# loadings for each factor.

# In SAS, the VARIMAX rotation generates a 'orthogonal transormation 
# matrix'. The original 'factor pattern' matrix is postmultiplied by the 
# transformation matrix in order to get the 'rotated factor pattern'
# matrix.

# Objective is not hypothesis testing but data interpretation

# Success of the analysis can be judged by how well it helps you make your 
# interpretation

# Total amount of variation explained by the rotated factor model will be 
# the same, but the contributions will not be the same from the individual 
# factors.

# Final communalities for variables, as well as the total communality
# will also remain unchanged after rotation.

# A good rule of thumb is for a factor loading of at least 0.5 to indicate 
# a salient variable-factor relationship.


# ------------------------------------------------------------------------ 
# Principle Component Analysis vs. Factor Analysis
# ------------------------------------------------------------------------ 

# Differences: 

# Factor analysis is a statistical model while PCA is not. 
# - Factor analysis involves fitting a statistical model for the 
# correlation structure of a dataset. 
# - PCA is a statistical procedure which uses orthogonal transformation to 
# covert a dataset to a set of linearly uncorrelated variables. 
# - PCA does not require any statistical assumptions, such as the data 
# following a multivariate normal distribution. 

# In FA, the factors are linear combinations that maximize the shared 
# portion of the variance. 

# In PCA, the components are orthogonal linear combinations that maximize 
# the total variance. 

# In factor analysis, only the shared variances that are analyzed. 

# In PCA, all of the observed variance is analyzed. 

# FA is focused more on the interpretability of the data in comparison to 
# PCA. 
# - FA requires well defined and known variables. 
# - In PCA no assumption need be made about any underlying causal model. 

# FA is dependent on the optimization routine used and the initial 
# conditions of the optimization. 

# Similarities: 

# Both are able to be used as methods of dimensionality reduction. 

# If the predictor variables are uncorrelated neither FA nor PCA is of 
# any practical use. 

# Best use: 

# In situations where there are a small amount of predictor variables or 
# where the model under study is that of a real-world entity 
# (intelligence, social class, strength), FA may be the preferred 
# methodology. 

# In cases where there are many predictor variables FA is not ideal since 
# the primary goal of FA is to improve the interpretability of the 
# relationships between the assumed latent variables and the manifest 
# variables.


# ------------------------------------------------------------------------ 
# Cluster Analysis
#
# Text - Multivariable Modeling
# ch12: Cluster Analysis
#
# Assigned readings
# Ch12, pp. 239-260 - Everitt - Multivariable Modeling and Multivariate Analysis for the Behavioral Sciences
#
# ------------------------------------------------------------------------ 

# Cluster analysis falls into the category of statistical problems known 
# as 'unsupervised learning'. 

# Unsupervised learning tries to find hidden structure in unlabeled data. 

# As the data given to the learner are unlabeled, there is no error or 
# reward signal to evaluate potential solutions. 

# There are no completely satisfactory methods that can be used for 
# determining the number of population clusters for any type of cluster 
# analysis. 

# When the variables are in different units, you should standardize all 
# variables to minimize the effect of scale differences. i.e subtracting 
# the means and dividing by the standard deviation.

# Two main classes of cluster models:

# 1 Hierarchical methods
# 2 Non-hierarchical methods (often known as k-means clustering methods)

# Hierarchical methods:

# Optimum number of clusters can be selected from a dendrogram. Diagram 
# illustrates which clusters have been joined at each stage  and the 
# distance between clusters at the time of joining.

# The linkage method that you choose determines how the distance between 
# two clusters is defined:
# Single - Nearest Neighbour
# Centoid
# Ward

# Non-hierarchical methods:

# Note, in these methods the desired number of clusters is specified 
# in advance.
# 1 Choose initial cluster centres.
# 2 Assign each subject to its 'nearest' cluster defined in terms of the 
# distance to the centroid.
# 3 Find the centroids of the clusters that have been formed
# 4 Re-calculate the distance from each subject to each centroid, and
# move subjects between clusters as needed.

# Non-hierarchical Advantages:

# Allows subjects to move from one cluster to another.
# Tends to be used when large data sets are involved.

# Non-hierarchical Disadvantages:

# Difficult to know how many clusters you are likely to have and therefore 
# the analysis may have to be repeated.
# Sensitive to the choice of initial cluster centers.

# Distance measures:

# The most common distance measure is the Euclidean distance.
# - The Euclidean distance between two observations is calculated as the 
# square root of the sum of the squares of the distances between 
# corresponding variables in the two observations being considered.
# - Manhattan distance is calculated by adding up the absolute value of 
# the differences of the corresponding variables, and is less likely to 
# be influenced by a very large difference between just one of the 
# variables.

# There are diagnostic metrics to be considered from clustering: 

# 1 Cubic Clustering Criterion 
# 2 Pseudo F metrics 

# Cubic Clustering Criterion: 

# - Peaks on the plot with the CCC greater than 2 or 3 indicate good 
# clusterings. 
# - Peaks with the CCC between 0 and 2 indicate possible clusters but 
# should be interpreted cautiously. 
# - There may be several peaks if the data has a hierarchical structure. 
# - Very distinct non-hierarchical spherical clusters usually show a sharp 
# rise before the peak followed by a gradual decline. 
# - Very distinct non-hierarchical elliptical clusters often show a sharp 
# rise to the correct number of clusters followed by a further gradual 
# increase and eventually a gradual decline. 
# - If all values of the CCC are negative and decreasing for two or more 
# clusters, the distribution is probably unimodal or long-tailed. 
# - Very negative values of the CCC, say, -30, may be due to outliers. 
# Outliers generally should be removed before clustering. 

# Pseudo F:

# - Look for a relatively large value. 