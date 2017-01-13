for(package in c("dummies", "bayesm", "reshape", 
                 "knitr",
                 "ggplot2")) {
  if(!require(package, character.only=TRUE)) {
    install.packages(package)
    library(package, character.only=TRUE)
  }
}

rm(package)

###########################################################################
# Preliminaries
###########################################################################

#-------------------------------------------------------------------------
# References
#-------------------------------------------------------------------------

#http://joelcadwell.blogspot.com.au/2013/03/lets-do-some-hierarchical-bayes-choice.html

#-------------------------------------------------------------------------
# Data prep
#-------------------------------------------------------------------------

# Load functions
load("data/efCode.RData")

# Load the dataset
load("data/stc-cbc-respondents-v6.RData")
df_resp.raw <- resp.data.v5mod
df_task <- read.csv("data/stc-dc-task-cbc-v6.csv")
df_scenarios <- read.csv("data/stc-extra-scenarios-v6.csv")
rm(resp.data.v5mod)

# Data structure/stats
#summary(df_resp.raw)
#str(df_resp.raw)
#dim(df_resp.raw)

# Generate effects coded version of task.mat
df_task.att <- as.matrix(df_task[, 3:7])
df_X <- efcode.attmat.f(df_task.att)
colnames(df_X) <- c("screen_1", "screen_2", 
                    "RAM_1", "RAM_2", 
                    "processor_1", "processor_2", 
                    "price_1", "price_2", 
                    "brand_1", "brand_2", "brand_3")

# Get vector of prices centered on mean
pricevec <- df_task$price - mean(df_task$price)

# Get the columns from X.mat that represent brand
df_X.brand <- df_X[, 9:11]
colnames(df_X.brand) <- colnames(df_X[,9:11])

# Multiply each column in X.brands by pricevec
df_X.brandbyprice <- df_X.brand * pricevec
colnames(df_X.brandbyprice) = c("brand_1_by_Price", 
                                "brand_2_by_Price", 
                                "brand_3_by_Price")
rm(pricevec)

# Combine X.mat and X.BrandsByPrice to get the X matrix for choice modelling
df_X <- cbind(df_X, df_X.brandbyprice)

# Check matrix
det(t(df_X)%*%df_X)

# Get the survey responses
df_y.resp <- df_resp.raw[, 3:38]
#names(df_y.resp)
df_y.resp <- na.omit(df_y.resp)
df_y.resp <- as.matrix(df_y.resp)

# Create list of data for each respondent
ls_lgtdata <- NULL

for (i in 1:360)  { # 360 should be the number of respondents w/o NA"s
  ls_lgtdata[[i]] <- list(y = df_y.resp[i,], X = df_X)
}

#length(ls_lgtdata)
#ls_lgtdata[[3]]


###########################################################################
# Model Evaluation
###########################################################################

#-------------------------------------------------------------------------
# Model 1
#-------------------------------------------------------------------------

# Specify iterations
#mcmctest <- list(R=5000, keep=5) # run 5,000 iterations and keep every 5th
R <- 30000 #5000
keep <- 10 #5
mcmctest <- list(R=R, keep=keep)
ndraws <- R/keep
rm(R, keep)

# Create data input list
Data1 <- list(p=3, lgtdata=ls_lgtdata) # p is the number of choice models, fed to rhierMnlDP
# note that X is subdivided by p in order to match y, i.e. 108 / 3 = 36

# Test run
testrun1 <- rhierMnlDP(Data=Data1, Mcmc=mcmctest) # Z (covariates) not specified
#names(testrun1)

# Get betadraw
betadraw1 <- testrun1$betadraw
#dim(betadraw1) # 360 rows (case/respondent), 14 columns (beta estimate), n draws (where n is based on R / keep)
dimnames(betadraw1) <- list(NULL, colnames(df_X), NULL)

# Plot beta draw chain
plot(betadraw1[3, 2,]) # 3rd case/respondent, 2nd beta estimate, n draws
abline(h=0)

# Plot distribution of beta draws
plot(density(betadraw1[3, 2, (ndraws-200):ndraws], width=2)) # 3rd case/respondent, 2nd beta estimate, last 200 draws
summary(betadraw1[3, 2, (ndraws-200):ndraws]) # Beta coefficient tends to be very different from zero? A little different?

# Calculate the overall means of the coefficients
meanBetas <- apply(betadraw1[, , (ndraws-200):ndraws], 2, mean) # Returns 1x14 matrix of coefficient means for all respondents (based on last 200 draws)

# Plot the overall means of the coefficients
plot(meanBetas, main="Mean Betas for Model 1")
abline(h=0, lty=2)

# Summary table of the overall means of the coefficients
#round(meanBetas,3)
df_meanBetas <- data.frame(meanBetas)
colnames(df_meanBetas) <- c("Beta mean")

df_meanBetas <- round(df_meanBetas, 3)
df_meanBetas$Attribute <- c("7 inch Screen", "10 inch Screen",
                            "16Gb RAM", "32Gb RAM",
                            "2GHz Processor", "2.5Ghz Processor",
                            "$299", "$399",
                            "Somesong Brand", "Pear Brand", "Gaggle Brand",
                            "Somesong Brand by Price", "Pear Brand by Price", "Gaggle Brand by Price")
df_meanBetas <- df_meanBetas[, c("Attribute",
                                 "Beta mean")]
kable(df_meanBetas)

# Summary table of coefficient percentiles for a particular repondent
round(apply(betadraw1[4, , 801:1000], 1, 
            quantile,probs=c(0.05,0.50,0.95)),3) # Coefficient percentiles for the 4'th respondent, by X matrix column

# Calculate the coefficient means for each respondent
df_meanBetas <- apply(betadraw1, c(1,2), mean) # Returns 360x14 matrix, of coefficient means for each respondent (based on n draws)
#print(round(df_meanBetas, 3))

# Plot the a comparison of coefficient means between two attributes for each respondent
plot(df_meanBetas[, c(1:2)], main="")
abline(h=0, lty=2)

# Calculate measures of fit
df_xbeta <- df_X%*%t(df_meanBetas) # Returns 108x360 matrix, of subjects betas
df_xbeta2 <- matrix(df_xbeta, ncol=3, byrow=TRUE) # Returns 12960x3 matrix
df_expxbeta2 <- exp(df_xbeta2)
rsumvec <- rowSums(df_expxbeta2) # Divide each row by its sum to get predicted choice probabilities
df_pchoicemat <- df_expxbeta2/rsumvec # Use this to calculate likelihood, RLH, MAE, MSE etc.
rm(df_xbeta, df_xbeta2, df_expxbeta2, rsumvec)

round(apply(df_pchoicemat, 2, quantile, 
            probs=c(0.10,0.25,0.5,0.75,0.90)), 4)
rm(df_pchoicemat)

# Compute chains of mean betas
df_betaMeanChains <- apply(betadraw1, c(2:3), mean) # Returns 14xn matrix, of coefficient means for each draw (based on R / keep draws)
#print(round(df_betaMeanChains, 3))

# Plot comparison of chains of mean betas between two attributes for each draw
plot(df_betaMeanChains[, c(1:2)], main="")
abline(h=0, lty=2)

# Estimate the distribution of the differences between the 1'st respondents 7th and 8th coefficients over the last 200 draws
summary(betadraw1[1, 7,(ndraws-200):ndraws]-betadraw1[1, 8, (ndraws-200):ndraws])
plot(density(betadraw1[1, 7,(ndraws-200):ndraws]-betadraw1[1, 8, (ndraws-200):ndraws], width=2.5))
abline(v=mean(betadraw1[1, 7,(ndraws-200):ndraws]-betadraw1[1, 8, (ndraws-200):ndraws]), lty=2)

# Generate plot of beta means over draws
df_betaMeanChains.t <- t(df_betaMeanChains)
dimnames(df_betaMeanChains.t) <- list(NULL, paste("mbeta", c(1:14), sep=""))

df_meltedbetas <- melt(df_betaMeanChains.t, 
                       varnames=c("draw", "beta"), 
                       value.name="mean.beta")

png(filename='images/model1_betadraw.png', 
    width=600, height=250, res=100)

ggplot(df_meltedbetas, aes(draw, value)) + 
  geom_line(aes(group=beta, colour=beta)) +
  labs(x='Draw', y='Beta value') +
  scale_x_continuous(breaks = round(seq(0, 3000, by=500), 1)) +
  theme(legend.position='none')

dev.off()

rm(df_meltedbetas)

# Generate plot of log likelihood measures over draws
df_loglike1 <- data.frame(draw=1:length(testrun1$loglike), 
                          loglike=testrun1$loglike)

png(filename='images/model1_loglike.png', 
    width=600, height=250, res=100)

ggplot(df_loglike1) + 
  geom_line(aes(y=loglike, x=draw)) +
  labs(x='Draw', y='Log Likelihood')

dev.off()

# Find number of draws which fall outside of percentile range
getp.f <- function(x, y=0){
  pfcn <- ecdf(x)
  return(pfcn(y))
}

for (i in 12:14){
  betamat <- betadraw1[,i,(ndraws-200):ndraws]
  zp <- apply(betamat,1,getp.f)
  
  betaDiffZero <- rep(0,nrow(betamat))
  betaDiffZero[zp <= 0.05 | zp >= 0.95] = 1
  respDiffBetas <- betamat[betaDiffZero == 1,]
  
  obsDiff <- as.numeric(dim(respDiffBetas))[1] 
  obsTot <- as.numeric(dim(respDiffBetas))[2]
  print(paste(obsDiff, obsTot, obsDiff/obsTot))
}

rm(betamat, zp, betaDiffZero, respDiffBetas, obsDiff, obsTot)


#-------------------------------------------------------------------------
# Model 2
#-------------------------------------------------------------------------

# Specify iterations
#mcmctest <- list(R=5000, keep=5) # run 5,000 iterations and keep every 5th
R <- 30000 #5000
keep <- 10 #5
mcmctest <- list(R=R, keep=keep)
ndraws <- R/keep
rm(R, keep)

# Create z-matrix of covariates
z.owner = df_resp.raw$STCowner = ifelse(df_resp.raw$STCowner == 1, 1, 0)
z.owner[is.na(z.owner)] <- 0
z.gender = df_resp.raw$Gen = ifelse(df_resp.raw$Gen == 1, 1, 0)

df_z.ownerc <- scale(z.owner, scale=FALSE)
df_z.genderc <- scale(z.gender, scale=FALSE)
df_z <- cbind(df_z.ownerc, df_z.genderc)
rm(df_z.ownerc, df_z.genderc)

# Create data input list
Data2 <- list(p=3, lgtdata=ls_lgtdata, Z=df_z) # p is the number of choice models, fed to rhierMnlDP
# note that X is subdivided by p in order to match y, i.e. 108 / 3 = 36

# Test run
testrun2 <- rhierMnlDP(Data=Data2, Mcmc=mcmctest)
#names(testrun2)

# Get betadraw
betadraw2 <- testrun2$betadraw
#dim(betadraw2) # 360 rows (case/respondent), 14 columns (beta estimate), n draws (where n is based on R / keep)
dimnames(betadraw2) <- list(NULL, colnames(df_X), NULL)

# Get deltadraw
deltadraw2 <- testrun2$Deltadraw
#dim(deltadraw2) # 360 rows (case/respondent), 28 columns (delta estimate), n draws (where n is based on R / keep)
df_deltadraw2.ownerc <- deltadraw2[, 1:14]
df_deltadraw2.genderc <- deltadraw2[, 15:28]
dimnames(df_deltadraw2.ownerc) <- list(NULL, colnames(df_X))
dimnames(df_deltadraw2.genderc) <- list(NULL, colnames(df_X))

# Plot beta draw chain
plot(betadraw2[3, 2,]) # 3rd case/respondent, 2nd beta estimate, n draws
abline(h=0)

# Plot distribution of beta draws
plot(density(betadraw2[3, 2, (ndraws-200):ndraws], width=2)) # 3rd case/respondent, 2nd beta estimate, last 200 draws
summary(betadraw2[3, 2, (ndraws-200):ndraws]) # Beta coefficient tends to be very different from zero? A little different?

# Calculate the overall means of the coefficients
meanBetas <- apply(betadraw2[, , (ndraws-200):ndraws], 2, mean) # Returns 1x14 matrix of coefficient means for all respondents (based on last 200 draws)

# Calculate the overall means of the deltas
meanDeltas.ownerc <- apply(df_deltadraw2.ownerc[(ndraws-200):ndraws, ], 2, mean) # Returns 1x14 matrix of coefficient deltas for all respondents (based on last 200 draws)
meanDeltas.genderc <- apply(df_deltadraw2.genderc[(ndraws-200):ndraws, ], 2, mean) # Returns 1x14 matrix of coefficient deltas for all respondents (based on last 200 draws)

# Plot the overall means of the coefficients
plot(meanBetas, main="Mean Betas for Model 2")
abline(h=0, lty=2)

# Plot the overall means of the deltas
plot(meanDeltas.ownerc, main="STCOwner impact Mean DeltaDraws")
abline(h=0, lty=2)
plot(meanDeltas.genderc, main="Gender impact Mean DeltaDraws")
abline(h=0, lty=2)

# Summary table of the overall means of the coefficients
#round(meanBetas,3)
df_meanBetas <- data.frame(meanBetas)
colnames(df_meanBetas) <- c("Beta mean")
kable(round(df_meanBetas, 3))

df_meanDeltas.ownerc <- data.frame(meanDeltas.ownerc)
df_meanDeltas.genderc <- data.frame(meanDeltas.genderc)
colnames(df_meanDeltas.ownerc) <- c("STCOwner delta mean")
colnames(df_meanDeltas.genderc) <- c("Gender delta mean")

df_meanSummary <- merge(df_meanBetas, df_meanDeltas.ownerc, 
                        by="row.names", all=TRUE, sort=FALSE)
rownames(df_meanSummary) <- df_meanSummary$Row.names
df_meanSummary$Row.names <- NULL
df_meanSummary <- merge(df_meanSummary, df_meanDeltas.genderc, 
                        by="row.names", sort=FALSE)
rownames(df_meanSummary) <- df_meanSummary$Row.names
df_meanSummary$Row.names <- NULL

df_meanSummary <- round(df_meanSummary, 3)
df_meanSummary$Attribute <- c("7 inch Screen", "10 inch Screen",
                              "16Gb RAM", "32Gb RAM",
                              "2GHz Processor", "2.5Ghz Processor",
                              "$299", "$399",
                              "Somesong Brand", "Pear Brand", "Gaggle Brand",
                              "Somesong Brand by Price", "Pear Brand by Price", "Gaggle Brand by Price")
df_meanSummary <- df_meanSummary[, c("Attribute",
                                     "Beta mean", 
                                     "STCOwner delta mean", 
                                     "Gender delta mean")]
kable(df_meanSummary)

# Summary table of coefficient percentiles for a particular repondent
round(apply(betadraw2[4, , 801:1000], 1, 
            quantile,probs=c(0.05,0.50,0.95)),3) # Coefficient percentiles for the 4'th respondent, by X matrix column

# Calculate the coefficient means for each respondent
df_meanBetas <- apply(betadraw2, c(1,2), mean) # Returns 360x14 matrix, of coefficient means for each respondent (based on n draws)
#print(round(df_meanBetas, 3))

# Plot the a comparison of coefficient means between two attributes for each respondent
plot(df_meanBetas[, c(1:2)], main="")
abline(h=0, lty=2)

# Calculate measures of fit
df_xbeta <- df_X%*%t(df_meanBetas) # Returns 108x360 matrix, of subjects betas
df_xbeta2 <- matrix(df_xbeta, ncol=3, byrow=TRUE) # Returns 12960x3 matrix
df_expxbeta2 <- exp(df_xbeta2)
rsumvec <- rowSums(df_expxbeta2) # Divide each row by its sum to get predicted choice probabilities
df_pchoicemat <- df_expxbeta2/rsumvec # Use this to calculate likelihood, RLH, MAE, MSE etc.
rm(df_xbeta, df_xbeta2, df_expxbeta2, rsumvec)

round(apply(df_pchoicemat, 2, quantile, 
            probs=c(0.10,0.25,0.5,0.75,0.90)), 4)
rm(df_pchoicemat)

# Compute chains of mean betas
df_betaMeanChains <- apply(betadraw2, c(2:3), mean) # Returns 14xn matrix, of coefficient means for each draw (based on R / keep draws)
#print(round(df_betaMeanChains, 3))

# Plot comparison of chains of mean betas between two attributes for each draw
plot(df_betaMeanChains[, c(1:2)], main="")
abline(h=0, lty=2)

# Estimate the distribution of the differences between the 1'st respondents 7th and 8th coefficients over the last 200 draws
summary(betadraw2[1, 7,(ndraws-200):ndraws]-betadraw2[1, 8, (ndraws-200):ndraws])
plot(density(betadraw2[1, 7,(ndraws-200):ndraws]-betadraw2[1, 8, (ndraws-200):ndraws], width=2.5))
abline(v=mean(betadraw2[1, 7,(ndraws-200):ndraws]-betadraw2[1, 8, (ndraws-200):ndraws]), lty=2)

# Generate plot of beta means over draws
df_betaMeanChains.t <- t(df_betaMeanChains)
dimnames(df_betaMeanChains.t) <- list(NULL, paste("mbeta", c(1:14), sep=""))

df_meltedbetas <- melt(df_betaMeanChains.t, 
                       varnames=c("draw", "beta"), 
                       value.name="mean.beta")

png(filename='images/model2_betadraw.png', 
    width=600, height=250, res=100)

ggplot(df_meltedbetas, aes(draw, value)) + 
  geom_line(aes(group=beta, colour=beta)) +
  labs(x='Draw', y='Beta value') +
  scale_x_continuous(breaks = round(seq(0, 3000, by=500), 1)) +
  theme(legend.position='none')

dev.off()

rm(df_meltedbetas)

# Generate plot of log likelihood measures over draws
df_loglike1 <- data.frame(draw=1:length(testrun2$loglike), 
                          loglike=testrun2$loglike)

png(filename='images/model2_loglike.png', 
    width=600, height=250, res=100)

ggplot(df_loglike1) + 
  geom_line(aes(y=loglike, x=draw)) +
  labs(x='Draw', y='Log Likelihood')

dev.off()

# Find number of draws which fall outside of percentile range
getp.f <- function(x, y=0){
  pfcn <- ecdf(x)
  return(pfcn(y))
}

for (i in 12:14){
  betamat <- betadraw2[,i,(ndraws-200):ndraws]
  zp <- apply(betamat,1,getp.f)
  
  betaDiffZero <- rep(0,nrow(betamat))
  betaDiffZero[zp <= 0.05 | zp >= 0.95] = 1
  respDiffBetas <- betamat[betaDiffZero == 1,]
  
  obsDiff <- as.numeric(dim(respDiffBetas))[1] 
  obsTot <- as.numeric(dim(respDiffBetas))[2]
  print(paste(obsDiff, obsTot, obsDiff/obsTot))
}

rm(betamat, zp, betaDiffZero, respDiffBetas, obsDiff, obsTot)


###########################################################################
# New Scenario Choice Modelling
###########################################################################

df_scenarios.att <- as.matrix(df_scenarios[,2:6])
df_X <- efcode.attmat.f(df_scenarios.att)
colnames(df_X) <- c("screen_1", "screen_2", 
                    "RAM_1", "RAM_2", 
                    "processor_1", "processor_2", "processor_3",
                    "price_1", "price_2", 
                    "brand_1", "brand_2", "brand_3")

# Get vector of prices centered on mean
pricevec <- df_scenarios$price - mean(df_scenarios$price)

# Get the columns from X.mat that represent brand
df_X.brand <- df_X[, 10:12]
colnames(df_X.brand) <- colnames(df_X[,10:12])

# Multiply each column in X.brands by pricevec
df_X.brandbyprice <- df_X.brand * pricevec
colnames(df_X.brandbyprice) = c("brand_1_by_Price", 
                                "brand_2_by_Price", 
                                "brand_3_by_Price")
rm(pricevec)

# Combine X.mat and X.BrandsByPrice to get the X matrix for choice modelling
df_X <- cbind(df_X, df_X.brandbyprice)

predict.hb.mnl <- function(betadraws, data) {
  data.model <- model.matrix(~screen_1 + screen_2 + 
                             RAM_1 + RAM_2 + 
                             processor_1 + processor_2 +
                             price_1 + price_2 + 
                             brand_1 + brand_2 + brand_3 + 
                             brand_1_by_Price + brand_2_by_Price + brand_3_by_Price, data = data)
  data.model <- data.model[,-1]
  nresp <- dim(betadraws)[1]
  ndraws <- dim(betadraws)[3]
  shares <- array(dim=c(nresp, nrow(data), ndraws))
  for (d in 1:ndraws) {
    for (i in 1:nresp) {
      utility <- data.model%*%betadraws[i,,d]
      shares[i,,d] = exp(utility)/sum(exp(utility))
    }
  }
  shares.agg <- apply(shares, 2:3, mean)
  cbind(share=apply(shares.agg, 1, mean), pct=t(apply(shares.agg, 1, quantile, probs=c(0.05, 0.95))), data)
}

df_share <- predict.hb.mnl(testrun1$betadraw, data.frame(df_X))
rownames(df_share) <- c("screen_1", "screen_2", 
                        "RAM_1", "RAM_2", 
                        "processor_1", "processor_2", "processor_3",
                        "price_1", "price_2", 
                        "brand_1", "brand_2", "brand_3")
kable(round(df_share, 3))