for(package in c("scales",
                 "randomForest", "caret",
                 "ROCR",
                 "ggplot2", "gridExtra")) {
  if(!require(package, character.only=TRUE)) {
    install.packages(package)
    library(package, character.only=TRUE)
  }
}

rm(package)

###########################################################################
# Preliminaries - Raw Data
###########################################################################

#-------------------------------------------------------------------------
# References
#-------------------------------------------------------------------------

# https://topepo.github.io/caret/modelList.html


#-------------------------------------------------------------------------
# Data load
#-------------------------------------------------------------------------

# Load the dataset
df_charity.raw <- read.csv("data/charity.csv")

# Data structure/stats
#summary(df_charity.raw)
#str(df_charity.raw)
#dim(df_charity.raw)
#temp <- sapply(df_charity.raw, typeof)
#table(temp)
#double integer 
#1      23

# Convert blank to NA
df_charity.raw[df_charity.raw == ""] <- NA


#-------------------------------------------------------------------------
# Variable type conversions
#-------------------------------------------------------------------------

# Identify and convert character/numeric variables where appropriate
#str(df_charity.raw, list.len=nrow(df_charity.raw))
df_charity.clean <- df_charity.raw

cols <- colnames(df_charity.clean)
cols <- cols[cols != "ID"]

for (c in cols) {
  if (is.numeric(df_charity.clean[, c]) == TRUE) {
    if ((is.character(na.omit(df_charity.clean[, c])) == TRUE) | (length(unique(na.omit(df_charity.clean[, c]))) <= 2)) {
      df_charity.clean[, c] <- as.factor(df_charity.clean[, c])
    }
  }
}

rm(cols)

#str(df_charity.clean, list.len=nrow(df_charity.clean))


#-------------------------------------------------------------------------
# Data exploration
#-------------------------------------------------------------------------

df_charity.expl <- df_charity.clean

# Summary statistics
cols <- colnames(df_charity.expl[, sapply(df_charity.expl, is.numeric)])
cols <- cols[cols != "ID"]
df_temp <- df_charity.expl[, cols]
stats <- lapply(df_temp , function(x) rbind(mean=mean(x),
                                            median=median(x),
                                            s.d.=sd(x),
                                            min=min(x),
                                            max=max(x),
                                            miss=length(which(is.na(x))),
                                            n=length(x)))
df_temp <- t(data.frame(stats))
round(df_temp, digits=4)
#write.table(df_temp, "temp.csv", sep="\t") 
rm(cols, df_temp, stats)

# Correlations
cols <- colnames(df_charity.expl[, sapply(df_charity.expl, is.numeric)])
df_temp <- t(cor(df_charity.expl["damt"], df_charity.expl[cols], use="complete"))
colnames(df_temp) <- "Corr"
round(df_temp, digits=4)
#write.table(df_temp, "temp.csv", sep="\t") 
rm(cols, df_temp)


cols <- colnames(df_charity.expl[, sapply(df_charity.expl, is.numeric)])
cols <- cols[cols != "ID"]

for (i in cols) {
  
  df_temp <- df_charity.expl[i]
  colnames(df_temp) <- i
  
  plot1 <- ggplot(data=df_temp, aes(x=df_temp[, i])) +
    geom_histogram(color="darkblue", fill="lightblue") +
    ggtitle(paste("Histogram:", i)) +
    labs(x="", y="count")
  
  plot2 <- ggplot(data=df_temp, aes(x=factor(""), y=df_temp[, i])) +
    geom_boxplot(color="darkblue", fill="lightblue") +
    ggtitle(paste("Boxplot:", i)) +
    labs(x="", y="value")
  
  png(filename=paste0("images/expl_num_", i, ".png"), 
      width=1000, height=600, res=150)
  
  grid.arrange(plot1, plot2, ncol=2)
  
  dev.off()
  
}

rm(df_temp)


df_temp <- df_charity.expl[c("npro", "plow", "donr")]
df_temp <- na.omit(df_temp)
#colnames(df_temp) <- c("npro", "plow", "donr")

plot1 <- ggplot(data=df_temp, aes(x=df_temp[, "donr"], y=df_temp[, "npro"])) +
  geom_boxplot(color="darkblue", fill="lightblue") +
  ggtitle(paste("Boxplot: NPRO by DONR")) +
  labs(x="DONR", y="value")

plot2 <- ggplot(data=df_temp, aes(x=df_temp[, "donr"], y=df_temp[, "plow"])) +
  geom_boxplot(color="darkblue", fill="lightblue") +
  ggtitle(paste("Boxplot: PLOW by DONR")) +
  labs(x="DONR", y="value")

png(filename=paste0("images/expl_boxcomp_1.png"), 
    width=1200, height=800, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()

rm(df_temp)


###########################################################################
# Preliminaries - Campaign Response
###########################################################################

#-------------------------------------------------------------------------
# Prep for train/validation observations
#-------------------------------------------------------------------------

# Remove response/ID variables
resp_DONR.orig <- df_charity.clean[, "donr"]
resp_DAMT.orig <- df_charity.clean[, "damt"]
flag_PART.orig <- df_charity.clean[, "part"]
flag_ID.orig <- df_charity.clean[, "ID"]

df_charity.trnval <- df_charity.clean[(df_charity.clean[, "part"] == "train") | (df_charity.clean[, "part"] == "valid"), ]

resp_DONR.trnval <- df_charity.trnval[, "donr"]
resp_DAMT.trnval <- df_charity.trnval[, "damt"]
flag_PART.trnval <- df_charity.trnval[, "part"]
flag_ID.trnval <- df_charity.trnval[, "ID"]

df_charity.trnval[, "donr"] <- NULL
df_charity.trnval[, "damt"] <- NULL
df_charity.trnval[, "part"] <- NULL
df_charity.trnval[, "ID"] <- NULL


#-------------------------------------------------------------------------
# Data imputation
#-------------------------------------------------------------------------

df_charity.imp <- df_charity.trnval

# Check for NA's, zero's and blanks
sum(is.na(df_charity.imp)) # 0
sum(df_charity.imp == 0) # 24963
sum(df_charity.imp == "") # 0

for (c in 1:ncol(df_charity.imp)) {
  nas <- sum(is.na(df_charity.imp[, c]))
  zero <- sum(df_charity.imp[, c] == 0)
  blank <- sum(df_charity.imp[, c] == "")
  print(paste(colnames(df_charity.imp)[c], nas, zero, blank))
}

#str(df_charity.imp, list.len=nrow(df_charity.imp))
rm(nas, zero, blank)

# Impute numeric
cols <- colnames(df_charity.imp[, sapply(df_charity.imp, is.numeric)])

for (c in cols) {
  if (sum(is.na(df_charity.imp[, c])) > 0) {
    nm <- paste(c, "IMP", sep="_")
    df_charity.imp[, nm] <- df_charity.imp[, c]
    med <- median(df_charity.imp[, nm], na.rm=TRUE)
    df_charity.imp[, nm][is.na(df_charity.imp[, nm])] <- med
    df_charity.imp[, c] <- NULL
  }
}

rm(cols, nm, med)

# Impute factor
cols <- colnames(df_charity.imp[, sapply(df_charity.imp, is.factor)])

for (c in cols) {
  if (sum(is.na(df_charity.imp[, c])) > 0) {
    nm <- paste(c, "IMP", sep="_")
    df_charity.imp[, nm] <- as.numeric(df_charity.imp[, c]) - 1
    mod <- which.max(df_charity.imp[, nm]) - 1
    df_charity.imp[, nm][is.na(df_charity.imp[, nm])] <- mod
    df_charity.imp[, nm] <- as.factor(df_charity.imp[, nm])
    df_charity.imp[, c] <- NULL
  }
}

rm(cols, nm, mod)

# Check for NA's, zero's and blanks
sum(is.na(df_charity.imp)) # 0
sum(df_charity.imp == 0) # 24963
sum(df_charity.imp == "") # 0

for (c in 1:ncol(df_charity.imp)) {
  nas <- sum(is.na(df_charity.imp[, c]))
  zero <- sum(df_charity.imp[, c] == 0)
  blank <- sum(df_charity.imp[, c] == "")
  print(paste(colnames(df_charity.imp)[c], nas, zero, blank))
}

#str(df_charity.imp, list.len=nrow(df_charity.imp))
rm(nas, zero, blank)

#-------------------------------------------------------------------------
# Data trimming
#-------------------------------------------------------------------------

df_charity.trim <- df_charity.imp

# Create trimmed variables
cols <- colnames(df_charity.trim[, sapply(df_charity.trim, is.numeric)])

for (c in cols) {
  min <- min(df_charity.trim[, c])
  max <- min(df_charity.trim[, c])
  p01 <- quantile(df_charity.trim[, c], c(0.01)) 
  p99 <- quantile(df_charity.trim[, c], c(0.99))
  if (p01 > min | p99 < max) {
    nm <- paste(c, "T99", sep="_")
    df_charity.trim[, nm] <- df_charity.trim[, c]
    t99 <- quantile(df_charity.trim[, c], c(0.01, 0.99))
    df_charity.trim[, nm] <- squish(df_charity.trim[, nm], t99)
    #df_charity.trim[, c] <- NULL
  }
}

rm(cols, min, max, p01, p99, nm, t99)


#-------------------------------------------------------------------------
# Data transformations
#-------------------------------------------------------------------------

df_charity.trans <- df_charity.trim

# Create variable transformations
cols <- colnames(df_charity.trans[, sapply(df_charity.trans, is.numeric)])

for (c in cols) {
  nm <- paste(c, "LN", sep="_")
  df_charity.trans[, nm] <- df_charity.trans[, c]
  df_charity.trans[, nm] <- (sign(df_charity.trans[, nm]) * log(abs(df_charity.trans[, nm])+1))
  #df_charity.trans[, c] <- NULL
}

rm(cols, nm)


#-------------------------------------------------------------------------
# Create dummy variables
#-------------------------------------------------------------------------

df_charity.dum <- df_charity.imp

cols <- colnames(df_charity.dum[, sapply(df_charity.dum, is.factor)])

for (c in cols) {
  if (length(unique(df_charity.dum[, c])) <= 10) {
    for(level in unique(df_charity.dum[, c])[1:length(unique(df_charity.dum[, c]))-1]) {
      nm <- paste("DUM", c, level, sep="_")
      df_charity.dum[, nm] <- ifelse(df_charity.dum[, c] == level, 1, 0)
    }
  }
}

rm(cols, nm, level)

#length(df_charity.imp[, grepl("DUM_", names(df_charity.imp))]) #0
df_charity.dum <- df_charity.dum[, grepl("DUM_", names(df_charity.dum))]
df_charity.dum[, "ID"] <- flag_ID.trnval


#-------------------------------------------------------------------------
# Final prep for train/validation observations
#-------------------------------------------------------------------------

# Final transformed numeric data set
df_charity.trans <- df_charity.trans[, sapply(df_charity.trans, is.numeric)]
df_charity.trans[, "ID"] <- flag_ID.trnval

# Merge transformed data with dummies
df_charity.trnval <- merge(df_charity.trans, df_charity.dum, all=FALSE)

# Add back response/ID variables
df_charity.trnval[, "donr"] <- resp_DONR.trnval
df_charity.trnval[, "damt"] <- resp_DAMT.trnval
df_charity.trnval[, "part"] <- flag_PART.trnval

# Subset data frame for train set
df_charity.train <- df_charity.trnval[df_charity.trnval[, "part"] == "train", ]
nrow(df_charity.train) # 3984

# Remove response/ID variables
resp_DONR.train <- df_charity.train[, "donr"]
resp_DAMT.train <- df_charity.train[, "damt"]
flag_PART.train <- df_charity.train[, "part"]
flag_ID.train <- df_charity.train[, "ID"]

df_charity.train[, "donr"] <- NULL
df_charity.train[, "damt"] <- NULL
df_charity.train[, "part"] <- NULL
df_charity.train[, "ID"] <- NULL

# Subset data frame for validation set
df_charity.valid <- df_charity.trnval[df_charity.trnval[, "part"] == "valid", ]
nrow(df_charity.valid) # 2018

# Remove response/ID variables
resp_DONR.valid <- df_charity.valid[, "donr"]
resp_DAMT.valid <- df_charity.valid[, "damt"]
flag_PART.valid <- df_charity.valid[, "part"]
flag_ID.valid <- df_charity.valid[, "ID"]

df_charity.valid[, "donr"] <- NULL
df_charity.valid[, "damt"] <- NULL
df_charity.valid[, "part"] <- NULL
df_charity.valid[, "ID"] <- NULL


###########################################################################
# Estimate Model - Campaign Response
###########################################################################

#-------------------------------------------------------------------------
# Variable importance
#-------------------------------------------------------------------------

# Fit randomForest model
set.seed(1)
fit_rf <- randomForest(as.factor(resp_DONR.train) ~ ., data=df_charity.train, 
                       ntree=60, do.trace=TRUE)

# Varible importance
imp_rf <- varImp(fit_rf, scale=FALSE)
#plot(imp_rf, top=20)
imp_rf[, "Variable"] <- rownames(imp_rf)
imp_rf <- imp_rf[with(imp_rf, order(-Overall)), ]

df_temp <- imp_rf
df_temp <- transform(df_temp, 
                     Variable=reorder(Variable, -Overall))

png(filename="images/varimp_amt.png", 
    width=1000, height=600, res=150)

ggplot(df_temp[1:20, ], aes(Variable, Overall)) +
  geom_bar(stat="identity", fill="steelblue") +
  scale_fill_manual() +
  labs(x="",
       y="Importance") +
  #title="RESPONSE16 - Variable Importance") + 
  theme(text=element_text(size=10), axis.text.x=element_text(angle=270, hjust=0))

dev.off()

rm(df_temp)

# Subset dataset
#cols_DONR <- imp_rf[1:10, "Variable"]
cols_DONR <- imp_rf[1:nrow(imp_rf), "Variable"]
df_charity.trainsub <- df_charity.train[, cols_DONR]
df_charity.validsub <- df_charity.valid[, cols_DONR]


#-------------------------------------------------------------------------
# Model fitting
#-------------------------------------------------------------------------

df_charity.trainsub[, "resp_DONR.train"] <- resp_DONR.train # some versions of caret require pred be incl. in d.frame

objControl <- trainControl(method="cv", number=3, 
                           returnResamp="none", allowParallel=TRUE, verboseIter=TRUE)

# Naive Bayes: nb, Naive Bayes Classifier: nbDiscrete
set.seed(1)
fit_nb <- train(as.factor(resp_DONR.train) ~ .,
                data=df_charity.trainsub,
                method="nb", trControl=objControl)

# Random Forest: ranger, Parallel Random Forest: parRF
set.seed(1)
fit_rfc <- train(as.factor(resp_DONR.train) ~ .,
                 data=df_charity.trainsub,
                 method="parRF", trControl=objControl)

# glmnet: glmnet
set.seed(1)
fit_glmnet <- train(as.factor(resp_DONR.train) ~ .,
                    data=df_charity.trainsub,
                    method="glmnet", trControl=objControl)

# Logistic Regression: LogitBoost
set.seed(1)
fit_logboost <- train(as.factor(resp_DONR.train) ~ .,
                      data=df_charity.trainsub,
                      method="LogitBoost", trControl=objControl)

# Linear Discriminant Analysis: lda
set.seed(1)
fit_lda <- train(as.factor(resp_DONR.train) ~ .,
                 data=df_charity.trainsub,
                 method="lda", trControl=objControl)

# k-Nearest Neighbors: knn, k-Nearest Neighbors: kknn
set.seed(1)
fit_knn <- train(as.factor(resp_DONR.train) ~ .,
                 data=df_charity.trainsub,
                 method="kknn", trControl=objControl)


df_charity.trainsub[, "resp_DONR.train"] <- NULL

ls_fitnm <- list("nb", "rfc", "glm", "lboost", "lda", "knn")
ls_fit <- list(fit_nb, fit_rfc, fit_glmnet, fit_logboost, fit_lda, fit_knn)

for (i in 1:length(ls_fit)) {
  # ROC Curve - In-Sample
  pred_resp <- predict(object=ls_fit[[i]], newdata=df_charity.trainsub)
  pred_prob <- predict(object=ls_fit[[i]], newdata=df_charity.trainsub, type="prob")
  
  rocr_pred <- prediction(pred_prob[,2], resp_DONR.train)
  rocr_perf <- performance(rocr_pred, measure="tpr", x.measure="fpr")
  
  auc <- performance(rocr_pred, measure="auc")
  auc <- auc@y.values[[1]]
  print(paste0(ls_fitnm[[i]], ": in-sample: ", auc))
  
  rocr.data <- data.frame(fpr=unlist(rocr_perf@x.values),
                          tpr=unlist(rocr_perf@y.values))
  
  plot1 <- ggplot(rocr.data, aes(x=fpr, ymin=0, ymax=tpr)) + 
    geom_ribbon(alpha=0.2) + 
    geom_line(aes(y=tpr)) + 
    geom_abline(linetype="dashed") + 
    #ggtitle(expression(atop("xxx", atop("In-Sample ROC Curve")))) +
    ggtitle("In-Sample ROC Curve") +
    labs(x="False Positive Rate", y="True Positive Rate") + 
    annotate("text", x=0.75, y=0.25, label=paste("AUC:", round(auc,4)))
  
  rm(rocr.data, auc)
  
  png(filename=paste0("images/resp_", ls_fitnm[[i]], "_insample_roc.png"), 
      width=800, height=800, res=150)
  
  print(plot1)
  
  dev.off()
  
  # ROC Curve - Out-of-Sample
  pred_resp <- predict(object=ls_fit[[i]], newdata=df_charity.validsub)
  pred_prob <- predict(object=ls_fit[[i]], newdata=df_charity.validsub, type="prob")
  
  rocr_pred <- prediction(pred_prob[,2], resp_DONR.valid)
  rocr_perf <- performance(rocr_pred, measure="tpr", x.measure="fpr")
  
  auc <- performance(rocr_pred, measure="auc")
  auc <- auc@y.values[[1]]
  print(paste0(ls_fitnm[[i]], ": out-sample: ", auc))
  
  rocr.data <- data.frame(fpr=unlist(rocr_perf@x.values),
                          tpr=unlist(rocr_perf@y.values))
  
  plot2 <- ggplot(rocr.data, aes(x=fpr, ymin=0, ymax=tpr)) + 
    geom_ribbon(alpha=0.2) + 
    geom_line(aes(y=tpr)) + 
    geom_abline(linetype="dashed") + 
    #ggtitle(expression(atop("xxx", atop("Out-of-Sample ROC Curve")))) +
    ggtitle("Out-of-Sample ROC Curve") +
    labs(x="False Positive Rate", y="True Positive Rate") + 
    annotate("text", x=0.75, y=0.25, label=paste("AUC:", round(auc,4)))
  
  rm(rocr.data, auc)
  
  png(filename=paste0("images/resp_", ls_fitnm[[i]], "_outsample_roc.png"), 
      width=800, height=800, res=150)
  
  print(plot2)
  
  dev.off()
  
  png(filename=paste0("images/resp_", ls_fitnm[[i]], "_sample_roc.png"), 
      width=1000, height=600, res=150)
  
  grid.arrange(plot1, plot2, ncol=2)
  
  dev.off()
  
  # Confusion matrix
  confmat <- table(round(as.numeric(pred_resp, digits=0)),
                   resp_DONR.valid)
  row.names(confmat) = c(0,1)
  print(confusionMatrix(confmat, positive="1"))
  rm(confmat)
}

# Response rate comparison
# train set
temp <- as.numeric(resp_DONR.train) - 1
sum(temp) / length(temp) # 0.500753

# train set using using optimal model and maximum profit function
# average donation = $14.50 and mailing cost = $2
temp <- as.numeric(resp_DONR.train) - 1
pred_resp <- predict(object=fit_glmnet, newdata=df_charity.trainsub, type="prob")[, 2]
profitfunc <- cumsum(14.5 * temp[order(pred_resp, decreasing=TRUE)] - 2)
#plot(profitfunc)
which.max(profitfunc) / length(profitfunc) # 0.626004

# validation set
temp <- as.numeric(resp_DONR.valid) - 1
sum(temp) / length(temp) # 0.4950446

# validation set using using optimal model and maximum profit function
# average donation = $14.50 and mailing cost = $2
temp <- as.numeric(resp_DONR.valid) - 1
pred_resp <- predict(object=fit_glmnet, newdata=df_charity.validsub, type="prob")[, 2]
profitfunc <- cumsum(14.5 * temp[order(pred_resp, decreasing=TRUE)] - 2)
#plot(profitfunc)
which.max(profitfunc) / length(profitfunc) # 0.635778


###########################################################################
# Estimate Model - Donation Amount
###########################################################################

#-------------------------------------------------------------------------
# Subset for true responses
#-------------------------------------------------------------------------

# Can either use the full train set, or further subset based on true responses
# Subset data frame for train set
df_charity.train <- df_charity.trnval[df_charity.trnval[, "part"] == "train", ]
nrow(df_charity.train) # 3984

# Subset data frame for train set based on true resp
df_charity.train.true <- df_charity.trnval[((df_charity.trnval[, "part"] == "train") & 
                                              (df_charity.trnval[, "donr"] == 1)), ]
nrow(df_charity.train.true) # 1995

# Comment out if want to use full train set
df_charity.train <- df_charity.train.true

# Remove response/ID variables
resp_DONR.train <- df_charity.train[, "donr"]
resp_DAMT.train <- df_charity.train[, "damt"]
flag_PART.train <- df_charity.train[, "part"]
flag_ID.train <- df_charity.train[, "ID"]

df_charity.train[, "donr"] <- NULL
df_charity.train[, "damt"] <- NULL
df_charity.train[, "part"] <- NULL
df_charity.train[, "ID"] <- NULL

# Can either use the full validation set, or further subset based on true responses
# Subset data frame for validation set
df_charity.valid <- df_charity.trnval[df_charity.trnval[, "part"] == "valid", ]
#nrow(df_charity.valid) # 2018

# Subset data frame for validation set based on true resp
df_charity.valid.true <- df_charity.trnval[((df_charity.trnval[, "part"] == "valid") & 
                                              (df_charity.trnval[, "donr"] == 1)), ]
#nrow(df_charity.valid.true) # 999

# Comment out if want to use full validation set
df_charity.valid <- df_charity.valid.true

# Remove response variables
resp_DONR.valid <- df_charity.valid[, "donr"]
resp_DAMT.valid <- df_charity.valid[, "damt"]
flag_PART.valid <- df_charity.valid[, "part"]
flag_ID.valid <- df_charity.valid[, "ID"]

df_charity.valid[, "donr"] <- NULL
df_charity.valid[, "damt"] <- NULL
df_charity.valid[, "part"] <- NULL
df_charity.valid[, "ID"] <- NULL

#-------------------------------------------------------------------------
# Variable importance
#-------------------------------------------------------------------------

# Fit randomForest model
set.seed(1)
fit_rf <- randomForest(resp_DAMT.train ~ ., data=df_charity.train, 
                       ntree=20, importance=TRUE, do.trace=TRUE)

# Varible importance
imp_rf <- varImp(fit_rf, scale=FALSE)
#plot(imp_rf, top=20)
imp_rf[, "Variable"] <- rownames(imp_rf)
imp_rf <- imp_rf[with(imp_rf, order(-Overall)), ]

df_temp <- imp_rf
df_temp <- transform(df_temp, 
                     Variable=reorder(Variable, -Overall))

png(filename="images/varimp_resp.png", 
    width=1000, height=600, res=150)

ggplot(df_temp[1:20, ], aes(Variable, Overall)) +
  geom_bar(stat="identity", fill="steelblue") +
  scale_fill_manual() +
  labs(x="",
       y="Importance") +
  #title="RESPONSE16 - Variable Importance") + 
  theme(text=element_text(size=10), axis.text.x=element_text(angle=270, hjust=0))

dev.off()

rm(df_temp)

# Subset dataset
#cols_DAMT <- imp_rf[1:10, "Variable"]
cols_DAMT <- imp_rf[1:nrow(imp_rf), "Variable"]
df_charity.trainsub <- df_charity.train[, cols_DAMT]
df_charity.validsub <- df_charity.valid[, cols_DAMT]


#-------------------------------------------------------------------------
# Model fitting
#-------------------------------------------------------------------------

df_charity.trainsub[, "resp_DAMT.train"] <- resp_DAMT.train # some versions of caret require pred be incl. in d.frame

objControl <- trainControl(method="cv", number=3, 
                           returnResamp="none", allowParallel=TRUE, verboseIter=TRUE)

# Linear Regression: lm
set.seed(1)
fit_lms <- train(resp_DAMT.train ~ .,
                 data=df_charity.trainsub,
                 method="lmStepAIC", trControl=objControl)


# Random Forest: ranger, Parallel Random Forest: parRF
set.seed(1)
fit_rfr <- train(resp_DAMT.train ~ .,
                 data=df_charity.trainsub,
                 method="parRF", trControl=objControl)


# eXtreme Gradient Boosting: xgbLinear
set.seed(1)
fit_xgb <- train(resp_DAMT.train ~ .,
                 data=df_charity.trainsub,
                 method="xgbLinear", trControl=objControl)


# Partial Least Squares: kernelpls
set.seed(1)
fit_pls <- train(resp_DAMT.train ~ .,
                 data=df_charity.trainsub,
                 method="kernelpls", trControl=objControl)


# Ridge Regression with Variable Selection: foba
set.seed(1)
fit_rr <- train(resp_DAMT.train ~ .,
                data=df_charity.trainsub,
                method="foba", trControl=objControl)


# The lasso: lasso
set.seed(1)
fit_lasso <- train(resp_DAMT.train ~ .,
                   data=df_charity.trainsub,
                   method="lasso", trControl=objControl)

df_charity.trainsub[, "resp_DAMT.train"] <- NULL


ls_fitnm <- list("lm", "rfr", "xgb", "pls", "rr", "lasso")
ls_fit <- list(fit_lms, fit_rfr, fit_xgb, fit_pls, fit_rr, fit_lasso)

for (i in 1:length(ls_fit)) {
  summary(ls_fit[[i]])
  
  pred <- predict(ls_fit[[i]], df_charity.trainsub)
  pred[pred <= 0] <- 0
  
  # GOF
  k <- 54
  n <- length(resp_DAMT.train)
  resid <- resp_DAMT.train - pred
  sst <- sum((resp_DAMT.train - mean(resp_DAMT.train))^2)
  sse <- sum(resid^2)
  ssr <- sst - sse
  mae <- mean(abs(resid))
  mse <- mean((resid)^2)
  rmse <- sqrt(mse)
  r2 <- ssr / sst
  adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
  print(paste0(cat(ls_fitnm[[i]], ": in-sample: ", "\n",
                   "sst: ", round(sst, 2), "\n",
                   "sse: ", round(sse, 2), "\n",
                   "ssr: ", round(ssr, 2), "\n", 
                   "mae: ", round(mae, 2), "\n", 
                   "mse: ", round(mse, 2), "\n",
                   "rmse: ", round(rmse, 2), "\n",
                   "r2: ", round(r2, 4), "\n",
                   "adjr2 ", round(adjr2, 4), "\n\n", sep="")))
  rm(k, n, resid, sst, sse, ssr, mae, mse, r2, adjr2)
  
  # Plot of actual vs. predicted
  plot1 <- ggplot(aes(x=actual,y=pred), data=data.frame(actual=resp_DAMT.train, pred=pred)) + 
    geom_point() + 
    geom_abline(color='red') + 
    #ggtitle(expression(atop("MLR (Stepwise Sel.)", atop("In-Sample Predict vs. Actuals")))) +
    ggtitle("In-Sample Predict vs. Actuals") +
    labs(x="Actual", y="Prediction") 
  
  png(filename=paste0("images/amt_", ls_fitnm[[i]], "_insample_pred.png"), 
      width=800, height=800, res=150)
  
  print(plot1)
  
  dev.off()
  
  pred <- predict(ls_fit[[i]], df_charity.validsub)
  pred[pred <= 0] <- 0
  
  # GOF
  k <- 54
  n <- length(resp_DAMT.valid)
  resid <- resp_DAMT.valid - pred
  sst <- sum((resp_DAMT.valid - mean(resp_DAMT.valid))^2)
  sse <- sum(resid^2)
  ssr <- sst - sse
  mae <- mean(abs(resid))
  mse <- mean((resid)^2)
  rmse <- sqrt(mse)
  r2 <- ssr / sst
  adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
  print(paste0(cat(ls_fitnm[[i]], ": out-sample: ", "\n",
                   "sst: ", round(sst, 2), "\n",
                   "sse: ", round(sse, 2), "\n",
                   "ssr: ", round(ssr, 2), "\n", 
                   "mae: ", round(mae, 2), "\n", 
                   "mse: ", round(mse, 2), "\n",
                   "rmse: ", round(rmse, 2), "\n",
                   "r2: ", round(r2, 4), "\n",
                   "adjr2 ", round(adjr2, 4), "\n\n", sep="")))
  rm(k, n, resid, sst, sse, ssr, mae, mse, r2, adjr2)
  
  # Plot of actual vs. predicted
  plot2 <- ggplot(aes(x=actual,y=pred), data=data.frame(actual=resp_DAMT.valid, pred=pred)) + 
    geom_point() + 
    geom_abline(color='red') + 
    #ggtitle(expression(atop("MLR (Stepwise Sel.)", atop("Out-of-Sample Predict vs. Actuals")))) +
    ggtitle("Out-of-Sample Predict vs. Actuals") +
    labs(x="Actual", y="Prediction")
  
  png(filename=paste0("images/amt_", ls_fitnm[[i]], "_outsample_pred.png"), 
      width=800, height=800, res=150)
  
  print(plot2)
  
  dev.off()
  
  png(filename=paste0("images/amt_", ls_fitnm[[i]], "_sample_pred.png"), 
      width=1000, height=600, res=150)
  
  grid.arrange(plot1, plot2, ncol=2)
  
  dev.off()
}


###########################################################################
# Create Score
###########################################################################

#-------------------------------------------------------------------------
# Prep for test observations
#-------------------------------------------------------------------------

df_charity.test <- df_charity.clean[df_charity.clean[, "part"] == "test", ]

resp_DONR.test <- df_charity.test[, "donr"]
resp_DAMT.test <- df_charity.test[, "damt"]
flag_PART.test <- df_charity.test[, "part"]
flag_ID.test <- df_charity.test[, "ID"]

df_charity.test[, "donr"] <- NULL
df_charity.test[, "damt"] <- NULL
df_charity.test[, "part"] <- NULL
df_charity.test[, "ID"] <- NULL


#-------------------------------------------------------------------------
# Data imputation
#-------------------------------------------------------------------------

df_charity.imp <- df_charity.test

# Check for NA's, zero's and blanks
sum(is.na(df_charity.imp)) # 0
sum(df_charity.imp == 0) # 8214
sum(df_charity.imp == "") # 0

for (c in 1:ncol(df_charity.imp)) {
  nas <- sum(is.na(df_charity.imp[, c]))
  zero <- sum(df_charity.imp[, c] == 0)
  blank <- sum(df_charity.imp[, c] == "")
  print(paste(colnames(df_charity.imp)[c], nas, zero, blank))
}

#str(df_charity.imp, list.len=nrow(df_charity.imp))
rm(nas, zero, blank)

# Impute numeric
cols <- colnames(df_charity.imp[, sapply(df_charity.imp, is.numeric)])

for (c in cols) {
  if (sum(is.na(df_charity.imp[, c])) > 0) {
    nm <- paste(c, "IMP", sep="_")
    df_charity.imp[, nm] <- df_charity.imp[, c]
    med <- median(df_charity.imp[, nm], na.rm=TRUE)
    df_charity.imp[, nm][is.na(df_charity.imp[, nm])] <- med
    df_charity.imp[, c] <- NULL
  }
}

rm(cols, nm, med)

# Impute factor
cols <- colnames(df_charity.imp[, sapply(df_charity.imp, is.factor)])

for (c in cols) {
  if (sum(is.na(df_charity.imp[, c])) > 0) {
    nm <- paste(c, "IMP", sep="_")
    df_charity.imp[, nm] <- as.numeric(df_charity.imp[, c]) - 1
    mod <- which.max(df_charity.imp[, nm]) - 1
    df_charity.imp[, nm][is.na(df_charity.imp[, nm])] <- mod
    df_charity.imp[, nm] <- as.factor(df_charity.imp[, nm])
    df_charity.imp[, c] <- NULL
  }
}

rm(cols, nm, mod)

# Check for NA's, zero's and blanks
sum(is.na(df_charity.imp)) # 0
sum(df_charity.imp == 0) # 8214
sum(df_charity.imp == "") # 0

for (c in 1:ncol(df_charity.imp)) {
  nas <- sum(is.na(df_charity.imp[, c]))
  zero <- sum(df_charity.imp[, c] == 0)
  blank <- sum(df_charity.imp[, c] == "")
  print(paste(colnames(df_charity.imp)[c], nas, zero, blank))
}

#str(df_charity.imp, list.len=nrow(df_charity.imp))
rm(nas, zero, blank)

#-------------------------------------------------------------------------
# Data trimming
#-------------------------------------------------------------------------

df_charity.trim <- df_charity.imp

# Create trimmed variables
cols <- colnames(df_charity.trim[, sapply(df_charity.trim, is.numeric)])

for (c in cols) {
  min <- min(df_charity.trim[, c])
  max <- min(df_charity.trim[, c])
  p01 <- quantile(df_charity.trim[, c], c(0.01)) 
  p99 <- quantile(df_charity.trim[, c], c(0.99))
  if (p01 > min | p99 < max) {
    nm <- paste(c, "T99", sep="_")
    df_charity.trim[, nm] <- df_charity.trim[, c]
    t99 <- quantile(df_charity.trim[, c], c(0.01, 0.99))
    df_charity.trim[, nm] <- squish(df_charity.trim[, nm], t99)
    #df_charity.trim[, c] <- NULL
  }
}

rm(cols, min, max, p01, p99, nm, t99)


#-------------------------------------------------------------------------
# Data transformations
#-------------------------------------------------------------------------

df_charity.trans <- df_charity.trim

# Create variable transformations
cols <- colnames(df_charity.trans[, sapply(df_charity.trans, is.numeric)])

for (c in cols) {
  nm <- paste(c, "LN", sep="_")
  df_charity.trans[, nm] <- df_charity.trans[, c]
  df_charity.trans[, nm] <- (sign(df_charity.trans[, nm]) * log(abs(df_charity.trans[, nm])+1))
  #df_charity.trans[, c] <- NULL
}

rm(cols, nm)


#-------------------------------------------------------------------------
# Create dummy variables
#-------------------------------------------------------------------------

df_charity.dum <- df_charity.imp

cols <- colnames(df_charity.dum[, sapply(df_charity.dum, is.factor)])

for (c in cols) {
  if (length(unique(df_charity.dum[, c])) <= 10) {
    for(level in unique(df_charity.dum[, c])[1:length(unique(df_charity.dum[, c]))-1]) {
      nm <- paste("DUM", c, level, sep="_")
      df_charity.dum[, nm] <- ifelse(df_charity.dum[, c] == level, 1, 0)
    }
  }
}

rm(cols, nm, level)

#length(df_charity.imp[, grepl("DUM_", names(df_charity.imp))]) #0
df_charity.dum <- df_charity.dum[, grepl("DUM_", names(df_charity.dum))]
df_charity.dum[, "ID"] <- flag_ID.test


#-------------------------------------------------------------------------
# Final prep for train/validation observations
#-------------------------------------------------------------------------

df_charity.trans <- df_charity.trans[, sapply(df_charity.trans, is.numeric)]
df_charity.trans[, "ID"] <- flag_ID.test

df_charity.test <- merge(df_charity.trans, df_charity.dum, all=FALSE)
df_charity.test[, "ID"] <- NULL


#-------------------------------------------------------------------------
# Score Modelling
#-------------------------------------------------------------------------

# Response modelling
# Correct for any missing dummy variables in test set
for (c in cols_DONR) {
  if (!(c %in% colnames(df_charity.test))) { 
    print(c)
    df_charity.test[, c] <- 0
  }
}

# Predict campaign response using optimal model
pred_DONR <- 1 - predict(object=fit_glmnet, newdata=df_charity.test[, cols_DONR], type="prob")[, 1]

# check response rate prediction
sum(pred_DONR >= 0.5) # 400
sum(pred_DONR >= 0.5) / length(pred_DONR) # 0.1993024

# test response is lower than train or validation response, but still higher than typical response
# therefore, we will adjust mail rate provided over test set
trate <- 0.1 # typical response rate is 0.1
vrate <- 0.5 # validation response rate is 0.5
orate <- 0.635778 # optimal model validation rate (see above)
adjtest1 <- orate/(vrate/trate) # adjustment for mail yes
adjtest0 <- (1-orate)/((1-vrate)/(1-trate)) # adjustment for mail no
adjtest <- adjtest1/(adjtest1+adjtest0) # scale into a proportion
nmailtest <- round(nrow(df_charity.test) * adjtest, 0) # calculate number of mailings for test set 

cutofftest <- sort(pred_DONR, decreasing=TRUE)[nmailtest + 1] # set cutoff based on n.mail.test
cutofftest # 0.6552621

temp <- ifelse(pred_DONR > cutofftest, 1, 0) # mail to everyone above the cutoff
sum(temp) / length(temp) # 0.1624315

rm(trate, vrate, orate, adjtest1, adjtest0, adjtest, nmailtest)


# Donation amount modelling
# Correct for any missing dummy variables in test set
for (c in cols_DAMT) {
  if (!(c %in% colnames(df_charity.test))) { 
    print(c)
    df_charity.test[, c] <- 0
  }
}


# Subset data frame for test set based on true resp
#df_charity.test.true <- df_charity.test[pred_DONR >= 0.6552621, ]
#nrow(df_charity.test.true) # 327

#pred_DAMT <- predict(fit_xgb, df_charity.test[, cols_DAMT]) # xgb is superior in dealing with zero inf (incl. non-resp)
pred_DAMT <- predict(fit_rr, df_charity.test[, cols_DAMT]) # rr is superior in dealing with non-zero inf (excl. non-resp)
mean(pred_DAMT) # 13.57757

df_score <- data.frame(ID=flag_ID.test, 
                       donr.prob=pred_DONR, 
                       damt=pred_DAMT)
df_score <- df_score[order(-df_score[, "donr.prob"]),]

df_score[, "donr.bin"] <- ifelse(df_score[, "donr.prob"] >= 0.6552621, 1, 0)

df_score[, "score_all"] <- df_score[, "donr.prob"] * df_score[, "damt"] - 2

df_score[, "score_allscore"] <- 0
df_score[, "score_predprob"] <- 0
df_score[, "score_highprob"] <- 0
df_score[, "score_highval"] <- 0
for (r in 1:nrow(df_score)) {
  if (df_score[r, "score_all"] >= 0) {
    df_score[r, "score_allscore"] <- df_score[r, "score_all"]
  }
  if (df_score[r, "donr.bin"] == 1) {
    df_score[r, "score_predprob"] <- df_score[r, "donr.prob"] * df_score[r, "damt"] - 1
  }
  if (df_score[r, "donr.prob"] >= 0.99) {
    df_score[r, "score_highprob"] <- df_score[r, "donr.prob"] * df_score[r, "damt"] - 1
  }
  if (df_score[r, "damt"] >= 17.50) {
    df_score[r, "score_highval"] <- df_score[r, "donr.prob"] * df_score[r, "damt"] - 1
  }
}

sum(df_score[, "score_all"]) # 2604.805
sum(df_score[, "score_allscore"]) # 4696.197
sum(df_score[, "score_predprob"]) # 3785.715
sum(df_score[, "score_highprob"]) # 678.1682
sum(df_score[, "score_highval"]) # 205.176

nrow(df_score) # 2007
length(df_score[, "ID"][df_score[, "score_all"] >= 0]) # 756
length(df_score[, "ID"][df_score[, "donr.prob"] >= 0.6552621]) # 327
length(df_score[, "ID"][df_score[, "donr.prob"] >= 0.99]) # 50
length(df_score[, "ID"][df_score[, "damt"] >= 17.50]) # 42

# Write score
write.csv(df_score, "score.csv")

df_submit <- df_score[, c("donr.prob", "donr.bin", "damt")]
colnames(df_submit) <- c("chat.prob", "chat.bin", "yhat")

# Write submission
write.csv(df_submit, "submission.csv")