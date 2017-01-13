# Solution for Lesson_2_Exercises_Using_R

# read the comma-delimited text file creating a data frame object in R
# as we did in Lesson 1, we create the data frame and examine it structure
houses <- read.csv("data/home_prices.csv")
str(houses)

# 1) a) Construct a histogram for PRICE. Describe the distribution shape.
hist(houses$PRICE)  # looks positively skewed, mean > mean
# or use with() function
with(houses, hist(PRICE))

# 1) b) Construct a histogram for TAX. Describe the distribution shape.
hist(houses$TAX)  # also looks positively skewed, mean > mean
# or use with() function
with(houses, hist(TAX))

# 1) c) Construct a scatterplot displaying TAX versus PRICE. Is there a relationship?
# here we put PRICE on the horizontal axis, TAX on vertical axis
with(houses, plot(PRICE, TAX))  # looks like a strong positive relationship

# 1) d) Construct a stem-and-leaf plot for TAX using stem()
# To aid in the interpretation, divide TAX by 100 and round to 1 digit.
# stem() will group the digits to the left of the decimal point, and
# list the numbers to the right of the decimal point to form the leaf.
# Then try it directly on TAX.  The result is the same.
X <- round(houses$TAX/100, digits=1)
stem(X)

# 1) e) Use the par() and mfrow() or mfcol() functions to construct a window
# with two rows and one column showing the histograms for PRICE and TAX.
par(mfrow=c(1,2))
with(houses, hist(PRICE))
with(houses, hist(TAX))
par(mfrow=c(1,1))
 

# 2) a) Construct a histogram for PRICE starting the first class at 1300 ($hundreds) 
# with a class width of 600 ($hundreds).
max(houses$PRICE) # this will let us know how many breaks we need  
with(houses, hist(PRICE, breaks = c(1300, 1900, 2500, 3100, 3700, 4300, 4900,
	5500)))

# 2) b) Construct a histogram for TAX starting the first classat $500with a class
#	width of $500.
max(houses$TAX)
with(houses, hist(TAX, breaks = c(500, 1000, 1500, 2000, 2500, 3000, 3500,
	4000, 4500)))