#Predict 410
##Assignment 4 Statistical Inference in Linear Regression

# Model 1: Let's consider the following SAS output for a regression model which we will refer to as Model 1.

#  Table: Analysis of Variance
#  
#  | Source | DF | Sum of Squares | Mean Square | F Value | Pr > F |
#  |:------:|:--:|:--------------:|:-----------:|:-------:|:------:|
#  | Model | 4 | 2126.00904 | 531.50226 | | < 0.0001 |
#  | Error | 67 | 630.35953 | 9.40835 | | |
#  | Corrected Total | 71 | 2756.36857 | | |
#
#  | Source |   |
#  |:------:|:-:|
#  | Root MSE | 3.06730 |
#  | Dependent Mean | 37.26901 |
#  | Coeff Var | 8.23017 |
#  | R-Square | |
#  | Adj R-Square | |
#  
#  Table: Parameter Estimates
#
#  | Variable | DF | Parameter Estimate | Standard Error | t-value | Pr > |t| |
#  |:--------:|:--:|:------------------:|:--------------:|:-------:|:--------:|
#  | Intercept | 1 | 11.33027 | 1.99409 | 5.68 | < 0.0001 |
#  | X1 | 1 | 2.18604 | 0.41043 | | < 0.0001 |
#  | X2 | 1 | 8.27430 | 2.33906 | 3.54 | 0.0007 |
#  | X3 | 1 | 0.49182 | 0.26473 | 1.86 | 0.0676 |
#  | X4 | 1 | -0.49356 | 2.29431 | -0.22 | 0.8303 |
#
#  | Number in Model | C(p) | R-Square | AIC | BIC | Variables in Model |
#  |:---------------:|:----:|:--------:|:---:|:---:|:------------------:|
#  | 4 | 5.000 | 0.7713 | 166.2129 | 168.9481 | X1 X2 X3 X4 |

## How many observations are in the sample data?

#There are 72 observations in the sample data.

#The reported 'Corrected Total' degrees of freedom is 71, which is equal to N - 1, where N is the number of observations.


## Write out the null and alternate hypotheses for the t-test for Beta_1.

#H_0 : beta_1 = 0 versus H_1 : beta_1 =/= 0


## Compute the t-statistic for Beta1.

#t_0 = beta^_1 / se(beta^_1)

#where df = n - dim(Model)

#t_0 = 2.18604 / 0.41043

2.18604 / 0.41043


## Compute the R-Squared value for Model 1.

#R^2 = SSR / SST = 1 - SSE / SST

#R^2 = 1 - 630.35953 / 2756.36857

1 - 630.35953 / 2756.36857


## Compute the Adjusted R-Square value for Model 1.

#R_adj^2 = 1 - (SSE/(n-k-1)) / (SST/(n-1)) = 1 - (SSE/(n-p)) / (SST/(n-1))

#R_adj^2 = 1 - (630.35953/(72-5)) / (2756.36857/(72-1))

1 - (630.35953 / (72-5)) / (2756.36857 / (72-1))


## Write out the null and alternative hypotheses for the Overall F-test.

#H_0 : beta_1 = ... = beta_k = 0 versus H_1 : beta_i =/= 0


## Compute the F-statistic for the Overall F-test.

#F_0 = (SSR/k) / (SSE/(n-p))

#F_0 = (2126.00904/4) / (630.35953/(72-5))

(2126.00904/4) / (630.35953/(72-5))


# Model 2: Now let's consider the following SAS output for an alternate regression model which we will refer to as Model 2.

#  Table: Analysis of Variance
#  
#  | Source | DF | Sum of Squares | Mean Square | F Value | Pr > F |
#  |:------:|:--:|:--------------:|:-----------:|:-------:|:------:|
#  | Model | 6 | 2183.75946 | 363.95991 | 41.32 | < 0.0001 |
#  | Error | 65 | 572.60911 | 8.80937 | | |
#  | Corrected Total | 71 | 2756.63857 | | |
#  
#  | Source |   |
#  |:------:|:-:|
#  | Root MSE | 2.96806 |
#  | Dependent Mean | 37.26901 |
#  | Coeff Var | 7.96388 |
#  | R-Square | 0.7923 |
#  |Adj R-Square | 0.7731 |
#  
#  Table: Parameter Estimates
#
#  | Variable | DF | Parameter Estimate | Standard Error | t-value | Pr > |t| |
#  |:--------:|:--:|:------------------:|:--------------:|:-------:|:--------:|
#  | Intercept | 1 | 14.39017 | 2.89157 | 4.98 | < 0.0001 |
#  | X1 | 1 | 1.97132 | 0.43653 | 4.52 | < 0.0001 |
#  | X2 | 1 | 9.13895 | 2.30071 | 3.97 | 0.0002 |
#  | X3 | 1 | 0.56485 | 0.26266 | 2.15 | 0.0352 |
#  | X4 | 1 | 0.33371 | 2.42131 | 0.14 | 0.8908 |
#  | X5 | 1 | 1.90698 | 0.76459 | 2.49 | 0.0152 |
#  | X6 | 1 | -1.04330 | 0.64759 | -1.61 | 0.1120 |
#  
#  | Number in Model | C(p) | R-Square | AIC | BIC | Variables in Model |
#  |:---------------:|:----:|:--------:|:---:|:---:|:------------------:|
#  | 6 | 7.000 | 0.7923 | 163.2947 | 166.7792 | X1 X2 X3 X4 X5 X6 |

## Now let's consider Model 1 and Model 2 as a pair of models. Does Model 1 nest Model 2 or does Model 2 nest Model 1? Explain.

#Y = beta_0 + beta_1(X_1) + beta_2(X_2) + beta_3(X_3) + beta_4(X_4) : Model 1

#Y = beta_0 + beta_1(X_1) + beta_2(X_2) + beta_3(X_3) + beta_4(X_4) + beta_5(X_5) + beta_6(X_6) : Model 2

#Predictor variables in Model 1 are a subset of the predictor variables in Model 2. 

#Therefore Model 1 nests Model 2, or Model 1 is nested by Model 2.


## Write out the null and alternate hypotheses for a nested F-test using Model 1 and Model 2

#H_0 : beta_1 = beta_2 = ... = beta_6 = 0 versus H_1 : beta_i =/= 0


## Compute the F-statistic for a nested F-test using Model 1 and Model 2

#F_0 = ((SSE(RM)-SSE(FM)) / (dim(FM)-dim(RM))) / (SSE(FM)/(n-dim(FM)))

#F_0 = ((630.35953-572.60911) / (7-5)) / (572.60911/(72-7))

((630.35953-572.60911) / (7-5)) / (572.60911/(72-7))


## Here are some additional questions to help you understand other parts of the SAS output.


## Compute the AIC values for both Model 1 and Model 2

#Model 1

72 * log(630.35953/72) + (2*5)

#Model 2

72 * log(572.60911/72) + (2*7)

## Compute the BIC values for both Model 1 and Model 2

#Model 1

72 * log(630.35953/72) + (2*(5+2)*((72*9.40835)/(630.35953))) - (2*((72*9.40835)/(630.35953))**2)

#Model 2

72 * log(572.60911/72) + (2*(7+2)*((72*8.80937)/(572.60911))) - (2*((72*8.80937)/(572.60911))**2)


## Compute the Mallow's C_p values for both Model 1 and Model 2

#Model 1

(630.35953/9.40835) + (2*5) - 72

#Model 2

(572.60911/8.80937) + (2*7) - 72

## Verify the t-statistics for the remaining coefficients in Model 1

#Intercept

11.33027/1.99409

#X1

2.18604/0.41043

#X2

8.27430/2.33906

#X3

0.49182/0.26473

#X4

-0.49356/2.29431

## Verify the Mean Square values for Model 1 and Model 2.

#Model 1

2126.00904/4

#Model 2

2183.75946/6

## Verify the Root MSE values for Model 1 and Model 2.

#Model 1

sqrt(9.40835)

#Model 2

sqrt(8.80937)