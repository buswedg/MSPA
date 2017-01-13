# Predict 401 Data Analysis Project 1

#----------------------------------------------------------------------------
# Part 1 Assessing normality
# Appendix A
#----------------------------------------------------------------------------

require(moments)

# Set the seed for the random number generator so that results can be compared.
set.seed(123)

# Generate standard normal random variables using the function rnorm().
normal_x <- rnorm(10000, mean=0, sd=1)

# Check summary statistics.  Skewness is particularly important. Data which
# are skewed present estimation and inference problems.  For a random sample
# from a normal distribution, the values for skewness should be close to zero
# and the kurtosis values produced by R should close to 3.
summary(normal_x)
skewness(normal_x)
kurtosis(normal_x)

# Plot a histogram with density function overlay.
hist(normal_x, prob=T, ylim=c(0.0,0.5))
lines(density(normal_x),lwd=2, col="darkred")

# Demonstrate QQ Plot by comparing two standard normal variables.  A QQ plot
# is a scatterplot of two sets of data.  The values of the quantiles for the 
# two sets are plotted against each other.  If the distributions are the same,
# the resulting plot is a straight line.

# normal_x is one set of data.  Generate a second vector normal_w.
normal_w <- rnorm(10000, mean=0, sd=1)

# Sort and match the ordered sets of data to form the plot.
normal_x <- sort(normal_x)
normal_w <- sort(normal_w)
plot(normal_x, normal_w, main = "Scatterplot of two normal random variables")

# This can be done for any set of data with supplied functions.
# The unknown distribution is plotted against the standard normal distribution.
# The closer to a straight line, the better the normal approximation.
# qqnorm() and qqline() provide the capability to make this comparison.
qqnorm(normal_x)
qqline(normal_x)
# The normal QQ plot illustrates desirable agreement.  Due to sampling
# variability there will always be some departures. Note the next section.

# Another way to compare an empirical distribution to the standard normal is shown
# by using the plot.ecdf() function.  Since this assignment uses smaller sample
# sizes, a sample of size 50 will be used and compared to normal_x. Execute this
# portion of the code several times to see the degree of variabilty that occurs.
# The degree of sampling variability this simulation reveals is important to 
# remember.  This is why we need statistical tests to determine when a departure
# is extreme enough to be declared statistically significant.
normal_w <- rnorm(50, mean=0, sd=1)
plot.ecdf(normal_x,xlab = "Standard Normal Variable x", main = "Comparison to Standard Normal")
plot.ecdf(normal_w, col = "blue", pch =2, add=TRUE)
abline(v = 0.0, lty = 2, col = "red")
legend ("topleft", legend = c("normal", "sample"), col = c('black', "blue"), pch = c(19, 2))

#------------------------------------------------------------------------
# Predict 401 Data Analysis Project 1
# Part 2
# Appendix B
#------------------------------------------------------------------------
# Case Study "Coca Cola Develops the African Market"
# EDA using data shown in problem 1 page 96 of Business Statistics.

require(moments)
coke <- read.csv(file.path("c:/RBlack/","Coke.csv"), sep=" ")
str(coke)  # Check structure of the dataset.

# Generate summary statistics and visual displays
summary(coke$Fill)
sd(coke$Fill)
stem(coke$Fill)
boxplot(coke$Fill)
100*sd(coke$Fill)/mean(coke$Fill)  # Compute percent CV.

# Compare summary statistics with 20 percent trimmed mean.
mean(coke$Fill, trim=.2)

# Evaluate the distribution of the data.
hist(coke$Fill, prob=T, ylim=c(0.0,1.5))
lines(density(coke$Fill),lwd=2, col="darkred")

# Determine skewness and kurtosis of data.
skewness(coke$Fill)
kurtosis(coke$Fill)

# Evaluate QQ plot of filled coke cans.
qqnorm(coke$Fill)
qqline(coke$Fill)

# Comparison of Fill volume versus standard normal using empirical distribution functions.
# To do this, we standardize the data to a mean of zero and standard deviation of one.

mu <- mean(coke$Fill)
std <- sd(coke$Fill)
Fill <- (coke$Fill - mu)/std

normal <- rnorm(1000, mean = 0, sd = 1)

plot.ecdf(normal, xlab = "Standard Normal Variable x", main = "Comparison to Standard Normal")
plot.ecdf(Fill, col = "blue", pch =2, add=TRUE)
abline(v = 0.0, lty = 2, col = "red")
legend ("topleft", legend = c("normal", "sample"), col = c('black', "blue"), pch = c(19, 2))

# Prepare a relative frequency table.  
# First define cell boundaries. Second, define cell midpoints.
cells <- seq(from = 339, to = 341.2, by = 0.2)
center <- seq(from = 339.1, to = 341.1, by = 0.2)

Fill_Volume <- coke$Fill
# Cut() places each fill volume into its associated cell.
Fill_Volume <- cut(Fill_Volume, cells, include.lowest=TRUE, right = FALSE)
# table() followed by prop.table() calculates proportions in each cell.
Fill_Volume <- prop.table(table(Fill_Volume))
# Include the cell center in the data frame.
Fill_Volume <- data.frame(Fill_Volume, center)
# Print out the data frame and compare to the stem-and-leaf plot.
Fill_Volume

# Superimpose on histogram using established breaks from cells.
# First establish the count in each cell.
count <- Fill_Volume$Freq*length(coke$Fill)
Fill_Volume <- data.frame(Fill_Volume, count)

# Plot the frequency (count) for each cell with overlay.
hist(coke$Fill, breaks=cells, main = "Frequency in Each Cell", right = FALSE)
lines(Fill_Volume$center, Fill_Volume$count, type = "b", col = "red")

# Calculate the mean and standard deviation from the grouped data and compare.
mean <- sum(Fill_Volume$Freq*Fill_Volume$center)
mean
delta2 <- (Fill_Volume$center - mean)**2
std <- sqrt(sum(delta2*Fill_Volume$Freq))
std

# Add an index variable to the data frame so that a scatter plot can be made.
index <- seq(1,50)
sample <- data.frame(coke, index)
plot (sample$index, sample$Fill, ylim = c(335, 345), main = "Fill versus Index")
abline(h = mean(sample$Fill))

coke$Fill <- sort(coke$Fill)
coke$Fill[48]  # 95th percentile value

#  Evaluate the empirical distribution of coke data.
#  Answer the questions presented in problem #1.
#  Determine if the data can be approximated using a normal distribution.

#------------------------------------------------------------------------------
