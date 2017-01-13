# Predict 401 Data Analysis Project #2
# Problems drawn from Analyzing the Databases in Black chpts 4,5,6,7

#----------------------------------------------------------------------------
# Part 1
# Appendix A
#----------------------------------------------------------------------------

hospital <- read.csv(file.path("c:/RBlack/","Hospital.csv"),sep=",")
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

#--------------------------------------------------------------------------
# Part 4
# Appendix B
#--------------------------------------------------------------------------
# Evaluation of sample size selection rules. 
# Exact probability calculation.

p <- 0.05  #  This is where different probabilities may be substituted.
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
legend("topright", legend=c("green is np >= 5","black is np >= 9(1-p)", "purple is np(1-p) >= 15"))

