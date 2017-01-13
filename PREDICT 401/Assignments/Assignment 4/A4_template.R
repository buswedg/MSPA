#Predict 401
##Data Analysis Assignment 4

for(package in c('moments', 'ggplot2')) {
  if(!require(package, character.only=TRUE)) {
    install.packages(package)
    library(package, character.only=TRUE)
  }
}

rm(package)

#----------------------------------------------------------------------------
# Part 1 Exploratory Data Analysis (EDA)
#----------------------------------------------------------------------------

#This part of the assignment will use the data in "Hospital.csv". Refer to Black 
#Business Statistics Chapter 10 page 410 problem 3. Use the code in Appendix A for 
#Part 1. Complete the following.

#1 Use the results from summary() to determine if extreme outliers are present. Use 
#these results to fill in the following table. Refer to Section 3.4 of Black page 85 
#(Figure 3.13).

hospital <- read.csv(file.path("data/hospital.csv"),sep=",")
summary(hospital)

my_stats <- function(x) {
  cat("\n      min:", min(x, na.rm = TRUE))
  cat("\n      max:", max(x, na.rm = TRUE))
  cat("\n     mean:", mean(x, na.rm = TRUE))
  cat("\n   median:", median(x, na.rm = TRUE))
  cat("\n    range:", range(x))  
  cat("\n       sd:", sd(x, na.rm = TRUE))
  cat("\n variance:", var(x, na.rm = TRUE))
  cat("\n       Q1:", quantile(x, probs = c(0.25), na.rm = TRUE))
  cat("\n       Q3:", quantile(x, probs = c(0.75), na.rm = TRUE))
  cat("\n      IQR:", IQR(x, na.rm = TRUE))
  cat("\n Q3+3*IQR:", quantile(x, probs = c(0.75), na.rm = TRUE) + 3*IQR(x, na.rm = TRUE))
  cat("\n      P10:", quantile(x, probs = c(0.10), na.rm = TRUE))
}

my_stats(hospital$Admissions)
my_stats(hospital$Beds)
my_stats(hospital$Tot..Exp.)

#Variable, IQR, Q3+3*IQR, Max
#Admissions, 8151, 34219, 37375
#Beds, 185.5, 826.5, 1297
#Tot..Exp., 69354.75, 297962.8, 367706


#2 Evaluate the various displays. Evaluate the histograms for skewness.

boxplot(hospital$Admissions)
boxplot(hospital$Beds)
boxplot(hospital$Tot..Exp.)

#negative skew: left: mean is less than the mode/median.
#postive skew: right skew: mean is greater than the mode/median.
par(mfrow=c(1,3))
hist(hospital$Admissions)
hist(hospital$Beds)
hist(hospital$Tot..Exp.)
par(mfrow=c(1,1))

par(mfrow=c(1,3))
qqnorm(hospital$Admissions, datax=TRUE)
qqline(hospital$Admissions, datax=TRUE, distribution=qnorm, probs=c(0.25,0.75), qtype=7)

qqnorm(hospital$Beds, datax=TRUE)
qqline(hospital$Beds, datax=TRUE, distribution=qnorm, probs=c(0.25,0.75), qtype=7)

qqnorm(hospital$Tot..Exp., datax=TRUE)
qqline(hospital$Tot..Exp., datax=TRUE, distribution=qnorm, probs=c(0.25,0.75), qtype=7)
par(mfrow=c(1,1))


#3 Review the boxplots of admissions, beds and expenditures and compare Psychiatric 
#hospitals versus General hospitals. Compare the boxplots to the corresponding 
#scatter plots.

hospital_1 <- subset(hospital, subset = (Service == 1))
hospital_2 <- subset(hospital, subset = (Service == 2))

boxplot(hospital_1$Admissions)
boxplot(hospital_1$Beds)
boxplot(hospital_1$Tot..Exp.)

boxplot(hospital_2$Admissions)
boxplot(hospital_2$Beds)
boxplot(hospital_2$Tot..Exp.)


#4 Note how table() is used in conjunction with chisq.test(). This portion of the 
#program will demonstrate the effect of Yates' Continuity Correction on the chi 
#square test of independence. Part of this involves using the user supplied chi() 
#function. Fill in the following table.

service <- factor(hospital$Service, labels = c("General", "Psychiatric"))
region <- factor(hospital$Geog..Region, labels = c("S","N","M","SW","R", "C", "NW")) 

admissions <- hospital$Admissions
beds <- hospital$Beds
hospital$Tot..Exp. <- hospital$Tot..Exp./1000   # Expenditures in thousands of dollars
exp <- hospital$Tot..Exp.

beds_median <- factor(beds > median(beds), labels = c("below","above"))
admissions_median <- factor(admissions > median(admissions), labels = c("below","above"))
exp_median <- factor(exp > median(exp), labels = c("below","above"))

service_beds <- table(service ,beds_median)
addmargins(service_beds)
service_exp <- table(service, exp_median)
addmargins(service_exp)
service_admissions <- table(service, admissions_median)
addmargins(service_admissions)

chisq.test(service_exp) # 0.001042
chisq.test(service_beds) # 0.8956
chisq.test(service_admissions) # 2.242e-09

# Refer to pages 58-60 of Chihara and Hesterberg Mathematical Statistics
# Chapter 3.5 is available through Course Reserves.  Yates'continuity correction
# may overcorrect.  An example where it is not used is shown for beds.

# This is the numerical calculation of Pearson's Chi square without Yates' Correction.

(84-168*101/200)^2/(168*101/200)+(84-99*168/200)^2/(99*168/200)+
  (17-101*32/200)^2/(101*32/200)+(15-99*32/200)^2/(99*32/200)

# The user supplied function chi() does the same thing starting with a table.

chi <- function(x){
  # To be used with 2x2 contingency tables that have margins added.
  # Expected values are calculated.
  e11 <- x[3,1]*x[1,3]/x[3,3]
  e12 <- x[3,2]*x[1,3]/x[3,3]
  e21 <- x[3,1]*x[2,3]/x[3,3]
  e22 <- x[3,2]*x[2,3]/x[3,3]
  # Value of chi square statistic is calculated.
  result <- (x[1,1]-e11)^2/e11+(x[1,2]-e12)^2/e12+(x[2,1]-e21)^2/e21+(x[2,2]-e22)^2/e22
  result
}

# Example of using the function chi() and obtaining a p-value.
service_beds <- addmargins(service_beds)
q <- chi(service_beds)
q # [1] 0.1050105
pchisq(q, 1, lower.tail = FALSE) # [1] 0.7458977

service_admissions <- addmargins(service_admissions)
q <- chi(service_admissions)
q # [1] 38.09524
pchisq(q, 1, lower.tail = FALSE) # [1] 6.737436e-10

service_exp <- addmargins(service_exp)
q <- chi(service_exp)
q # [1] 12.05357
pchisq(q, 1, lower.tail = FALSE) # [1] 0.0005169325

# Record the chi square results from the chisq.test().  Also use the function chi()
# on service_beds, service_exp and service_admissions.  Record the results.


#5 Evaluate the table showing the geographic distribution of hospitals.

# Create a contingency table of service by regions.  It is apparent the distribution
# of Psychiatric hospitals differs from General hospitals across geographic regions.
# Because of the number of zeros in the table,a Chi square test is not advised.

addmargins(table(hospital$service,hospital$region))


#----------------------------------------------------------------------------
# Part 2 Two-Sample t tests and Bootstrapping
#----------------------------------------------------------------------------

#6 Using the code supplied in Appendix B of this assignment, subset the data into 
#two data.frames, one for general medical hospitals and the other for psychiatric 
#hospitals. Do an initial EDA using the code supplied taking note of the 
#distributions shapes and locations.

hospital <- data.frame(hospital, region, service, exp)

gen <- hospital[service == "General", ]
psy <- hospital[service == "Psychiatric", ]

psy.A <- psy$Admissions  # These are the samples for comparison. 
gen.A <- gen$Admissions

aggregate(Admissions~service,data=hospital,summary)

par(mfrow = c(2,2))
hist(psy.A, col = "red", xlab = "Admissions")
hist(gen.A, col = "green", xlab = "Admissions")
boxplot(psy.A, col = "red", ylab = "Admissions")
boxplot(gen.A, col = "green", ylab = "Admissions")
par(mfrow = c(1,1))


#7 Execute the resampling code supplied and examine the resampling distributions 
#presented for the mean difference and the t statistic. Take note of how close the 
#vertical lines are in the plot of the sampling distribution for the t statistic. 
#These mark where the quantiles are located.

np <- length(psy.A)
ng <- length(gen.A)
mu <- mean(gen.A)-mean(psy.A)
std.s <- sqrt((var(psy.A)/np)+(var(gen.A)/ng))  # Sample standard deviation of difference.

N <- 10^4
diff.mean <- numeric(N)
diff.t <- numeric(N)
set.seed(123)   # Keep this set.seed the same to assure comparable results.

for (i in 1:N)
{
  psy.sample <- sample(psy.A, np, replace=TRUE)
  gen.sample <- sample(gen.A, ng, replace=TRUE)
  x <- mean(gen.sample)-mean(psy.sample)                    # Calculate the mean difference.
  diff.mean[i] <- x                                        
  std <- sqrt((var(psy.sample)/np) + (var(gen.sample)/ng))
  diff.t[i] <- ((x-mu)/std)                                 # Calculate the t statistic.
}

# Evaluate the bootstrapping sampling distributions.

x <- seq(-4*std.s+mu, mu+4*std.s, 0.1)
hist(diff.mean, main = "Resampling distribution of the mean differences", col = "red", prob = T)    
abline(v=mean(diff.mean), col="blue", lty = 2, lwd=2)
curve(dnorm(x,mean = mu, sd = std.s ),add=TRUE, col= "green", lwd = 2, type = "l")
legend("topright", legend = c("skewness = 0.06", "kurtosis = 3.03"))
abline(v= quantile(diff.mean, probs = 0.05), col = "blue", lwd = 2, lty = 2)
abline(v= quantile(diff.mean, probs = 0.95), col = "blue", lwd = 2, lty = 2)
skewness(diff.mean) # [1] 0.06415897
kurtosis(diff.mean) # [1] 3.031802

hist(diff.t, main = "Resampling Distribution of t-statistic df = n=ng+np-2", breaks = "Sturges",
     ylim = c(0, 0.45), prob = TRUE, col = "green", xlab = "t-statistic values")
curve(dt(x, df=ng+np-2),add=TRUE, col= "darkred", lwd = 2)
legend("topright", legend = c("skewness = -0.20", "kurtosis = 3.12"))
abline(v= quantile(diff.t, probs = 0.05), col = "blue", lwd = 2, lty = 2)
abline(v= quantile(diff.t, probs = 0.95), col = "blue", lwd = 2, lty = 2)
abline(v= qt(c(0.05,0.95),ng+np-2,lower.tail=T),col="darkred",lwd=2,lty=2)
skewness(diff.t) # [1] -0.201206
kurtosis(diff.t) # [1] 3.120071


#8 Continue with the program and calculate: 1) the traditional two-sample t 
#confidence interval, 2) the percentile bootstrap confidence interval, and 3) 
#the bootstrap t confidence interval. Do this as shown at the 90% confidence 
#interval. Compare results.

gen <- hospital[service == "General", ]
psy <- hospital[service == "Psychiatric", ]

psy.B <- psy$Beds
gen.B <- gen$Beds

aggregate(Beds~service,data=hospital,summary)

np <- length(psy.B)
ng <- length(gen.B)
mu <- mean(gen.B)-mean(psy.B)
std.s <- sqrt((var(psy.B)/np)+(var(gen.B)/ng))  # Sample standard deviation of difference.

N <- 10^4
diff.mean <- numeric(N)
diff.t <- numeric(N)

set.seed(123)  # Keep this set.seed the same to assure comparable results.

for (i in 1:N)
{
  psy.sample <- sample(psy.B, np, replace=TRUE)
  gen.sample <- sample(gen.B, ng, replace=TRUE)
  x <- mean(gen.sample)-mean(psy.sample)                    # Calculation of the mean difference.
  diff.mean[i] <- x
  std <- sqrt((var(psy.sample)/np) + (var(gen.sample)/ng))
  diff.t[i] <- ((x-mu)/std)                                 # Calculation of the t statistic.
}

# Traditional two-sample confidence interval using t-statistic.
t.test(gen.B, psy.B, var.equal = F, conf.level = 0.90)$conf.int

# Determine two-sided confidence interval using mean bootstrap distribution.
round(quantile(diff.mean, probs = c(0.05, 0.95)), digits = 2)

# Bootstrap confidence interval based on the t-statistic.
round((mu - quantile(diff.t, probs = 0.95, names = F) * std.s), digits = 2)
round((mu - quantile(diff.t, probs = 0.05, names = F) * std.s), digits = 2)


#9 Note the tail area comparison between the theoretical t distribution and the 
#bootstrap t resampling distribution. Ideally the two values would both equal 0.05. 
#If both values are within 0.025 and 0.075, the theoretical distribution may be an 
#acceptable match to the resampling results. There is no hard and fast rule for 
#making this judgment.

sum(diff.t > 1.658)/N # [1] 0.1161
sum(diff.t < -1.658)/N # [1] 0.0201


#10 Repeat the preceding steps for expenditures and beds. For beds, you will need 
#to adapt the code supplied to that variable. After completing these steps, enter 
#the results in the table below. Round off to a single decimal place. (The last 
#column is the conclusion reached (at 90% confidence) from testing the null 
#hypothesis of no difference between the population means versus the alternative 
#hypothesis that there is a difference.)

#Beds, 
#-100.4526, 58.5478
#-100.02, 49.20
#-133.96, 42.04


#----------------------------------------------------------------------------
# Part 3 One-way Analysis of Variance and Linear Regression
#----------------------------------------------------------------------------

#11 In the overview table that is constructed, take note of which region has the highest average
#expenditure per capita on education, and how average expenditures compare to average income.

schools <- read.csv(file.path("data/schools.csv"),sep=",")
schools$year <- factor(schools$year, labels = c("1","2","3"))
str(schools)
summary(schools)

my <- aggregate(schools$Y~schools$region, data = schools, mean)
mx <- aggregate(schools$X~schools$region, data = schools, mean)
mx <- mx[,2]
overview <- cbind(my,mx)
colnames(overview) <- c("region","expenditures", "income")
overview


#12 Compare the Pearson Correlation Coefficient with the R-squared result from the simple linear
#regression. The square of the correlation coefficient equals the R-squared value of 0.4.

# Evaluate correlation between Y and X.  This is the Pearson Product Moment Correlation
# Coefficient sometimes referred to as the linear correlation coefficient.
cor.test(schools[,1],schools[,2])[4] # 0.6324381

# This suggests a regression analysis may be used.
result <- lm(Y~X,data=schools)
summary(result)

# Note that the correlation coefficient from cor.test when squared equals
# the multiple R-squared value of 0.4 when rounded.  However, this is only
# a preliminary model.  Other factors should be considered.
0.6324381^2


#13 Review the next series of boxplots prior to completing the AOV. Ask yourself how the AOV
#results might turn out. The AOV is sufficiently robust to handle the differences in variability.

par(mfrow = c(2,2))
boxplot(Y~year, data = schools, col = "red", main = "Expenditures by Year")
boxplot(Y~region, data = schools, col = "red", main = "Expenditures by Region")
boxplot(X~year, data = schools, col = "blue", main = "Income by Year")
boxplot(X~region, data = schools, col = "blue", main = "Income by Region")
par(mfrow = c(1,1))


#14 Perform the two AOVs relating Y to year and to region. The F value is the test statistic in an
#AOV. With a one-way analysis of variance, only when this statistic produces a small p-value
#can the results be deemed statistically significant and TukeyHSD() used.

# Perform initial one-way analyses of variance.
aov.year <- aov(Y~year, schools)
summary(aov.year)
# No significant difference is found: Pr(>F) = 0.799

aov.region <- aov(Y~region, schools)
summary(aov.region)
# Significant difference is found: Pr(>F) = 5.09e-12
# Significant difference is found.  Perform TukeyHSD.  Compare to the boxplots.
TukeyHSD(aov.region)


#15 Examine the results from TukeyHSD() and determine which comparisons resulted in significant
#differences. Then adapt the code and duplicate the analyses only this time use X instead of Y.
#Summarize the results of the TukeyHSD() procedure in the table below as shown.

# Repeat the one-way analysis of variance using Income as the dependent variable.
aov.year <- aov(X~year, schools)
summary(aov.year)
# No significant difference is found: Pr(>F) = 0.614

aov.region <- aov(X~region, schools)
summary(aov.region)
# Significant difference is found: Pr(>F) = 2.21e-10
# Significant difference is found.  Perform TukeyHSD.  Compare to the boxplots.
TukeyHSD(aov.region)


#16 Compare to the boxplots produced at (13).


#17 Execute the two-way AOVs and take note of which factor(s) turn out to be statistically
#significant. This could include the interaction term. Would you expect this result?

# Combine factors and perform a two-way analysis of variance.
result <- aov(Y~region+year+region*year,schools)
summary(result)

result <- aov(X~region+year+region*year,schools)
summary(result)


#18 Execute the multiple linear regression and note which if any terms in the model turn out to be
#statistically significant. (This is an example of what is referred to as a parallel lines regression.)

result <- lm(Y~X+region,schools)
summary(result)


#19 Compare the regression results with the associated ggplot. Note how the term in the regression
#model for region D reflects the positioning of those data points relative the other data points.

ggplot(schools, aes(x = X, y = Y))+geom_point(aes(color = region), size = 3)+
  ggtitle("Plot of Expenditures versus Income Colored by Region")


#20 Evaluate how well the residuals conform to a normal distribution. The fit is reasonable.

r <- residuals(result)

par(mfrow = c(1,2))
hist(r, col = "red", main = "Histogram of Residuals", xlab = "Residual")
boxplot(r, col = "red", main = "Boxplot Residuals", ylab = "Residual")
par(mfrow = c(1,1))

qqnorm(r, col = "red", pch = 16, main = "QQ Plot of Residuals")
qqline(r, col = "green", lty = 2, lwd = 2)
skewness(r) # [1] -0.002500969
kurtosis(r) # [1] 3.251458


#----------------------------------------------------------------------------
# Data Analysis Assignment 4 Quiz
#----------------------------------------------------------------------------

#Question 1
#Refer to your assigned reading and analysis resulting from Part 1 of the assignment.
#Chi-square tests were conducted on three contingency tables using Service crossed with each of 
#Admissions, Beds and Expenditures. Which test result was not statistically significant?

#Service with Admissions
#xService with Beds
#Service with Total Expenditures
#All of the above
#None of the above


#Question 2
#Based on the EDA conducted in Part 1 of the assignment and the descriptive statistics that were 
#calculated, which of the following statements is in error?

#The average number of admissions for General hospitals is greater than the average number of 
#admissions for Psychiatric hospitals.
#The average total expenditures for General hospitals is greater than the average total 
#expenditures for Psychiatric hospitals.
#xThe distribution of Psychiatric hospitals is uniform across regions of the country.
#Psychiatric hospitals and General hospitals have distributions of total expenditures which exhibit 
#extreme outliers.
#None of the Above

mean(hospital_1$Admissions)
mean(hospital_2$Admissions)

mean(hospital_1$Tot..Exp.)
mean(hospital_2$Tot..Exp.)

addmargins(table(hospital$service,hospital$region))

boxplot(hospital_1$Tot..Exp.)
boxplot(hospital_2$Tot..Exp.)


#Question 3
#Refer to the analysis conducted in Part 2 of the assignment dealing with Expenditures.

#The histograms showing bed distributions are skewed left for both General and Psychiatric hospitals.
#negative skew: left: mean is less than the mode/median.
#postive skew: right skew: mean is greater than the mode/median.

#True
#xFalse

hist(hospital_1$Beds)
hist(hospital_2$Beds)


#Question 4
#Refer to the analysis conducted in the assignment dealing with chi-square tests.

#The p-values from the chi-square tests of independence involving service with each of admissions, 
#beds and total expenditures changed when Yates' Continuity Correction was not used.

#xTrue
#False


#Question 5
#Refer to the analysis conducted in the assignment dealing with confidence intervals generated using
#the traditional t test, the percentile bootstrap method and the bootstrap t method. 

#The null hypothesis that the average difference in admissions between General and Psychiatric 
#hospitals is zero can be rejected at the 90% confidence level.

#xTrue
#False

psy.A <- psy$Admissions
gen.A <- gen$Admissions

t.test(gen.A, psy.A, var.equal = F, conf.level = 0.90)


#Question 6
#Refer to the analysis conducted in the assignment dealing with confidence intervals generated 
#using the traditional t test, the percentile bootstrap method and the bootstrap t method. 

#The null hypothesis that the average difference in total expenditures between General and 
#Psychiatric hospitals is zero can be rejected at the 90% confidence level.

#xTrue
#False

psy.E <- psy$Tot..Exp.
gen.E <- gen$Tot..Exp.

t.test(gen.E, psy.E, var.equal = F, conf.level = 0.90)


#Question 7
#Refer to the analysis conducted in the assignment dealing with confidence intervals generated 
#using the traditional t test, the percentile bootstrap method and the bootstrap t method. 

#The null hypothesis that the average difference in beds between General and Psychiatric hospitals 
#is zero can be rejected at the 90% confidence level.

#True
#xFalse

psy.B <- psy$Beds
gen.B <- gen$Beds

t.test(gen.B, psy.B, var.equal = F, conf.level = 0.90)


#Question 8
#The following question deals with the analysis of variance portion of the assignment using the 
#data in schools.csv.

#The one-way analysis of variance with expenditures per capita as a dependent variable and region 
#as an independent variable did not produce a statistically significant F test result at the 1% 
#significance level.

#True
#xFalse

aov.region <- aov(X~region, schools)
summary(aov.region)
# Significant difference is found: Pr(>F) = 2.21e-10


#Question 9
#The following question deals with the analysis of variance portion of the assignment using the 
#data in schools.csv.

#Following a one-way analysis of variance which produced a statistically significant F test at the 
#1% level, the TukeyHSD procedure found average income per capita for region C to be significantly 
#different from each of the other three regions.

#xTrue
#False

# Significant difference is found.  Perform TukeyHSD.  Compare to the boxplots.
TukeyHSD(aov.region)


#Question 10
#The following question deals with the analysis of variance portion of the assignment using the 
#data in schools.csv.

#At the 1% significance level, region was found to be a statistically significant factor in both 
#two-way analyses of variance in which income per capita and expenditures per capita were used as 
#dependent variables. 

#xTrue
#False

# Combine factors and perform a two-way analysis of variance.
result <- aov(Y~region+year+region*year,schools)
summary(result)

result <- aov(X~region+year+region*year,schools)
summary(result)


#Question 11
#The following question deals with the analysis of variance portion of the assignment using the 
#data in schools.csv.

#The multiple linear regression of expenditures per capita as a dependent variable, versus the 
#independent variables income per capita and region, did not show income per capita and region D as 
#statistically significant factors at the 1% significance level.

#True
#xFalse

result <- lm(Y~X+region,schools)
summary(result)


#Question 12
#The following question deals with the analysis of variance portion of the assignment using the 
#data in schools.csv.

#The multiple linear regression of expenditures per capita as a dependent variable, versus the 
#independent variables income per capita and region, produced a multiple R-squared value greater 
#than 0.5.

#xTrue
#False