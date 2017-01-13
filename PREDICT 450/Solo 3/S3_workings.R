for(package in c("xlsx",
                 #"data.table",
                 "scales",
                 "randomForest",
                 "caret",
                 "ROCR", "pROC",
                 "gridExtra", "ggplot2")) {
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
# Load the dataset
#-------------------------------------------------------------------------

# Load the dataset
load("data/XYZ_complete_customer_data_frame.RData")
df_cust.raw <- complete.customer.data.frame

# Data structure/stats
#summary(df_cust.raw)
#str(df_cust.raw)
#dim(df_cust.raw)
#temp <- sapply(df_cust.raw, typeof)
#table(temp)
#character    double   integer 
#345       161        48

# Retain only interesting fields
cols <- as.character(read.xlsx("vars.xlsx", sheetName="Sheet1")[, ])
df_cust.cull <- df_cust.raw[, c("ACCTNO", cols)]

rm(cols)

# Data structure/stats
#summary(df_cust.raw)
#str(df_cust.raw)
#dim(df_cust.raw)
#temp <- sapply(df_cust.cull, typeof)
#table(temp)
#character    double   integer 
#119       160        48

# Convert blank to NA
df_cust.cull[df_cust.cull == ""] <- NA


#-------------------------------------------------------------------------
# Variable type conversions
#-------------------------------------------------------------------------

# Identify and convert character/numeric variables where appropriate
#str(df_cust.16, list.len=nrow(df_cust.16))
df_cust.clean <- df_cust.cull

cols <- colnames(df_cust.clean)

for (c in cols) {
  if (is.character(df_cust.clean[, c]) == FALSE) { 
    df_cust.clean[, c] <- as.numeric(df_cust.clean[, c])
  } else {
    df_cust.clean[, c] <- as.factor(df_cust.clean[, c])
  }
}

rm(cols)

#cols <- colnames(df_cust.clean[, sapply(df_cust.clean, is.factor)])
#df_temp <- df_cust.clean[, cols]

#cols <- colnames(df_cust.clean[, sapply(df_cust.clean, is.factor)])
#df_temp <- df_cust.clean[, cols]

#cols <- colnames(df_cust.clean[, sapply(df_cust.clean, function (x) 
#  is.factor(x) & 
#    any(grep("[[:alpha:]]", x)) == FALSE &
#    length(unique(x)) > 10)])
#df_temp <- df_cust.clean[, cols] # Some questionable factor columns, but not enough to worry about

#cols <- colnames(df_cust.clean[, sapply(df_cust.clean, function (x) 
#  is.numeric(x) & 
#    length(unique(x)) <= 10)])
#df_temp <- df_cust.clean[, cols] # Has captured ANY_MAIL_x and RESPONSEx flags, will convert to factor


cols <- colnames(df_cust.clean)

for (c in cols) {
  if ((grepl("ANY_MAIL_", c) == TRUE) | (grepl("RESPONSE", c) == TRUE)) {
    df_cust.clean[, c] <- as.factor(df_cust.clean[, c])
  }
}

rm(cols)

#temp <- sapply(df_cust.clean, typeof)
#table(temp)
#double integer 
#175     152


#-------------------------------------------------------------------------
# Data exploration
#-------------------------------------------------------------------------

df_cust.expl <- df_cust.clean

# Summary statistics
cols <- colnames(df_cust.expl[, !sapply(df_cust.expl, is.factor)])
df_temp <- df_cust.expl[, cols]
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
cols <- colnames(df_cust.expl[, !sapply(df_cust.expl, is.factor)])
df_temp <- t(cor(df_cust.expl["TOTAMT16"], df_cust.expl[cols], use="complete"))
colnames(df_temp) <- "Corr"
round(df_temp, digits=4)
#write.table(df_temp, "temp.csv", sep="\t") 
rm(cols, df_temp)


for (i in c("YTD_SALES_2009", 
            "YTD_TRANSACTIONS_2009", 
            "LTD_SALES", 
            "LTD_TRANSACTIONS", 
            "PRE2009_TRANSACTIONS", 
            "PRE2009_SALES", 
            "TOTAL_MAIL_13", 
            "TOTAL_MAIL_14", 
            "TOTAL_MAIL_15", 
            "SUM_MAIL_12")) {

  df_temp <- df_cust.expl[i]
  rows <- apply(df_temp, 1, function(row) all(row !=0))
  df_temp <- as.data.frame(df_temp[rows, i])
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

rm(df_temp, rows)


df_temp <- df_cust.expl[c("TOTAMT", "QTY", "RESPONSE16")]
rows <- apply(df_temp, 1, function(row) all(row !=0))
df_temp <- as.data.frame(df_temp[rows, c("TOTAMT", "QTY", "RESPONSE16")])
colnames(df_temp) <- c("TOTAMT", "QTY", "RESPONSE16")

plot1 <- ggplot(data=df_cust.expl, aes(x=df_cust.expl[, "RESPONSE16"], y=df_cust.expl[, "TOTAMT"])) +
  geom_boxplot(color="darkblue", fill="lightblue") +
  #ggtitle(paste("Boxplot: TOTAMT by RESPONSE16")) +
  labs(x="RESPONSE16", y="TOTAMT")

plot2 <- ggplot(data=df_cust.expl, aes(x=df_cust.expl[, "RESPONSE16"], y=df_cust.expl[, "QTY"])) +
  geom_boxplot(color="darkblue", fill="lightblue") +
  #ggtitle(paste("Boxplot: QTY by RESPONSE16")) +
  labs(x="RESPONSE16", y="QTY")

png(filename=paste0("images/expl_boxcomp_1.png"), 
    width=1000, height=600, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()
  

df_temp <- df_cust.expl[c("LTD_SALES", "LTD_TRANSACTIONS", "RESPONSE16")]
rows <- apply(df_temp, 1, function(row) all(row !=0))
df_temp <- as.data.frame(df_temp[rows, c("LTD_SALES", "LTD_TRANSACTIONS", "RESPONSE16")])
colnames(df_temp) <- c("LTD_SALES", "LTD_TRANSACTIONS", "RESPONSE16")

plot1 <- ggplot(data=df_cust.expl, aes(x=df_cust.expl[, "RESPONSE16"], y=df_cust.expl[, "LTD_SALES"])) +
  geom_boxplot(color="darkblue", fill="lightblue") +
  #ggtitle(paste("Boxplot: LTD_SALES by RESPONSE16")) +
  labs(x="RESPONSE16", y="LTD_SALES")

plot2 <- ggplot(data=df_cust.expl, aes(x=df_cust.expl[, "RESPONSE16"], y=df_cust.expl[, "LTD_TRANSACTIONS"])) +
  geom_boxplot(color="darkblue", fill="lightblue") +
  #ggtitle(paste("Boxplot: LTD_TRANSACTIONS by RESPONSE16")) +
  labs(x="RESPONSE16", y="LTD_TRANSACTIONS")

png(filename=paste0("images/expl_boxcomp_2.png"), 
    width=1000, height=600, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()


###########################################################################
# Preliminaries - Campaign Response
###########################################################################

#-------------------------------------------------------------------------
# Prep for 16th Campaign observations
#-------------------------------------------------------------------------

# Subset data frame
df_cust.16_clean <- df_cust.clean[df_cust.clean$ANY_MAIL_16 == 1,]
#nrow(df_cust.16_clean) # 14922

# Remove response variables
resp_RESPONSE16.orig <- df_cust.16_clean[, "RESPONSE16"]
resp_QTY16.orig <- df_cust.16_clean[, "QTY16"]
resp_TOTAMT16.orig <- df_cust.16_clean[, "TOTAMT16"]

df_cust.16_clean[, "RESPONSE16"] <- NULL
df_cust.16_clean[, "QTY16"] <- NULL
df_cust.16_clean[, "TOTAMT16"] <- NULL
#df_cust.16_clean[, "SUM_MAIL_16"] <- NULL
#df_cust.16_clean[, "ANY_MAIL_16"] <- NULL
#df_cust.16_clean[, "TOTAL_MAIL_16"] <- NULL


#-------------------------------------------------------------------------
# Data imputation
#-------------------------------------------------------------------------

df_cust.16_imp <- df_cust.16_clean

# Check for NA's, zero's and blanks
sum(is.na(df_cust.16_imp)) # 470867
sum(df_cust.16_imp == 0) # NA
sum(df_cust.16_imp == "") # NA

for (c in 1:ncol(df_cust.16_imp)) {
  
  nas <- sum(is.na(df_cust.16_imp[, c]))
  zero <- sum(df_cust.16_imp[, c] == 0)
  blank <- sum(df_cust.16_imp[, c] == "")
  print(paste(colnames(df_cust.16_imp)[c], nas, zero, blank))
  
}

#str(df_cust.16_imp, list.len=nrow(df_cust.16_imp))
rm(nas, zero, blank)

# Impute numeric
cols <- colnames(df_cust.16_imp[, !sapply(df_cust.16_imp, is.factor)])

for (c in cols) {
  if (sum(is.na(df_cust.16_imp[, c])) > 0) {
    nm <- paste(c, "IMP", sep="_")
    df_cust.16_imp[, nm] <- df_cust.16_imp[, c]
    med <- median(df_cust.16_imp[, nm], na.rm=TRUE)
    df_cust.16_imp[, nm][is.na(df_cust.16_imp[, nm])] <- med
    df_cust.16_imp[, c] <- NULL
  }
}

rm(cols, nm, med)

# Impute factor
cols <- colnames(df_cust.16_imp[, sapply(df_cust.16_imp, is.factor)])
cols <- cols[cols != "ACCTNO"]

for (c in cols) {
  if (sum(is.na(df_cust.16_imp[, c])) > 0) {
    nm <- paste(c, "IMP", sep="_")
    df_cust.16_imp[, nm] <- as.numeric(df_cust.16_imp[, c]) - 1
    mod <- which.max(df_cust.16_imp[, nm]) - 1
    df_cust.16_imp[, nm][is.na(df_cust.16_imp[, nm])] <- mod
    df_cust.16_imp[, nm] <- as.factor(df_cust.16_imp[, nm])
    df_cust.16_imp[, c] <- NULL
  }
}

rm(cols, nm, mod)

# Check for NA's, zero's and blanks
sum(is.na(df_cust.16_imp)) # 0
sum(df_cust.16_imp == 0) # 1509133
sum(df_cust.16_imp == "") # 0

for (c in 1:ncol(df_cust.16_imp)) {
  
  nas <- sum(is.na(df_cust.16_imp[, c]))
  zero <- sum(df_cust.16_imp[, c] == 0)
  blank <- sum(df_cust.16_imp[, c] == "")
  print(paste(colnames(df_cust.16_imp)[c], nas, zero, blank))
  
}

#str(df_cust.16_imp, list.len=nrow(df_cust.16_imp))
rm(nas, zero, blank)

#-------------------------------------------------------------------------
# Data trimming
#-------------------------------------------------------------------------

df_cust.16_trim <- df_cust.16_imp

# Create trimmed variables
cols <- colnames(df_cust.16_trim[, !sapply(df_cust.16_trim, is.factor)])

for (c in cols) {
  min <- min(df_cust.16_trim[, c])
  max <- min(df_cust.16_trim[, c])
  p01 <- quantile(df_cust.16_trim[, c], c(0.01)) 
  p99 <- quantile(df_cust.16_trim[, c], c(0.99))
  if (p01 > min | p99 < max) {
    nm <- paste(c, "T99", sep="_")
    df_cust.16_trim[, nm] <- df_cust.16_trim[, c]
    t99 <- quantile(df_cust.16_trim[, c], c(0.01, 0.99))
    df_cust.16_trim[, nm] <- squish(df_cust.16_trim[, nm], t99)
    #df_cust.16_trim[, c] <- NULL
  }
}

rm(cols, min, max, p01, p99, nm, t99)

#-------------------------------------------------------------------------
# Create dummy variables
#-------------------------------------------------------------------------

df_cust.16_dum <- df_cust.16_imp

cols <- colnames(df_cust.16_dum[, sapply(df_cust.16_dum, is.factor)])

for (c in cols) {
  if (length(unique(df_cust.16_dum[, c])) <= 10) {
    for(level in unique(df_cust.16_dum[, c])[1:length(unique(df_cust.16_dum[, c]))-1]) {
      nm <- paste("DUM", c, level, sep="_")
      df_cust.16_dum[, nm] <- ifelse(df_cust.16_dum[, c] == level, 1, 0)
    }
  }
}

rm(cols, nm, level)

#length(df_cust.16_imp[, grepl("DUM_", names(df_cust.16_imp))]) #0
df_cust.16_dum <- df_cust.16_dum[, grepl("DUM_", names(df_cust.16_dum))]
df_cust.16_dum[, "ACCTNO"] <- df_cust.16_clean[, "ACCTNO"]


#-------------------------------------------------------------------------
# Final prep for 16th Campaign observations
#-------------------------------------------------------------------------

df_cust.16_trim <- df_cust.16_trim[, !sapply(df_cust.16_trim, is.factor)]
df_cust.16_trim[, "ACCTNO"] <- df_cust.16_clean[, "ACCTNO"]

#dt_cust.16_imp <- data.table(df_cust.16_imp, key="ACCTNO") # note: data.table's more mem eff
#dt_cust.16_dum <- data.table(df_cust.16_dum, key="ACCTNO")

df_cust.16_final <- merge(df_cust.16_trim, df_cust.16_dum, all=FALSE)
df_cust.16_final[, "ACCTNO"] <- NULL

#str(df_cust.16_final, list.len=nrow(df_cust.16_final))
#temp <- sapply(df_cust.16_final, typeof)
#table(temp)
rm(df_cust.16_imp, df_cust.16_dum)


###########################################################################
# Estimate Model - Campaign Response
###########################################################################

# Fit randomForest model
set.seed(1)
fit_rf <- randomForest(as.factor(resp_RESPONSE16.orig) ~ ., data=df_cust.16_final, 
                       ntree=60, do.trace=TRUE)

# Varible importance
imp_rf <- varImp(fit_rf, scale=FALSE)
#plot(imp_rf, top=20)
imp_rf[, "Variable"] <- rownames(imp_rf)
imp_rf <- imp_rf[with(imp_rf, order(-Overall)), ]

df_temp <- imp_rf
df_temp <- transform(df_temp, 
                     Variable=reorder(Variable, -Overall))

png(filename="images/varimp_response16.png", 
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
cols_RESPONSE16 <- imp_rf[1:50, "Variable"]
df_cust.16_finalsub <- df_cust.16_final[, cols_RESPONSE16]


# Train and test split
train <- 0.7
randraw <- runif(nrow(df_cust.16_final))

df_cust.16_train <- df_cust.16_final[randraw <= train, ]
df_cust.16_trainsub <- df_cust.16_finalsub[randraw <= train, ]

resp_RESPONSE16.train <- resp_RESPONSE16.orig[randraw <= train]
#resp_QTY16.train <- resp_QTY16.orig[randraw <= train]
#resp_TOTAMT16.train <- resp_TOTAMT16.orig[randraw <= train]

df_cust.16_test <- df_cust.16_final[randraw > train, ]
df_cust.16_testsub <- df_cust.16_finalsub[randraw > train, ]

resp_RESPONSE16.test <- resp_RESPONSE16.orig[randraw > train]
#resp_QTY16.test <- resp_QTY16.orig[randraw > train]
#resp_TOTAMT16.test <- resp_TOTAMT16.orig[randraw > train]

rm(train, randraw)


#-------------------------------------------------------------------------
# Model 1: Naive Bayes
#-------------------------------------------------------------------------

# Fit model # Naive Bayes: nb, Naive Bayes Classifier: nbDiscrete
set.seed(1)
objControl <- trainControl(method="cv", number=3, 
                           returnResamp="none", allowParallel=TRUE, verboseIter=TRUE)
fit_nb <- train(as.factor(resp_RESPONSE16.train) ~ .,
                data=df_cust.16_trainsub,
                method="nb", trControl=objControl)

# ROC Curve - In-Sample
pred_nb_resp <- predict(object=fit_nb, newdata=df_cust.16_trainsub)
pred_nb_prob <- predict(object=fit_nb, newdata=df_cust.16_trainsub, type="prob")

rocr_pred <- prediction(pred_nb_prob[,2], resp_RESPONSE16.train)
rocr_perf <- performance(rocr_pred, measure="tpr", x.measure="fpr")

auc <- performance(rocr_pred, measure='auc')
auc <- auc@y.values[[1]]
print(auc) # 0.8513516

rocr.data <- data.frame(fpr=unlist(rocr_perf@x.values),
                        tpr=unlist(rocr_perf@y.values))

plot1 <- ggplot(rocr.data, aes(x=fpr, ymin=0, ymax=tpr)) + 
  geom_ribbon(alpha=0.2) + 
  geom_line(aes(y=tpr)) + 
  geom_abline(linetype="dashed") + 
  #ggtitle(expression(atop("Naive Bayes", atop("In-Sample ROC Curve")))) +
  ggtitle("In-Sample ROC Curve") +
  labs(x="False Positive Rate", y="True Positive Rate") + 
  annotate("text", x=0.75, y=0.25, label=paste("AUC:", round(auc,2)))

rm(rocr.data, auc)

png(filename="images/resp_m1_nb_insample_roc.png", 
    width=800, height=800, res=150)

plot1

dev.off()

# ROC Curve - Out-of-Sample
pred_nb_resp <- predict(object=fit_nb, newdata=df_cust.16_testsub)
pred_nb_prob <- predict(object=fit_nb, newdata=df_cust.16_testsub, type="prob")

rocr_pred <- prediction(pred_nb_prob[,2], resp_RESPONSE16.test)
rocr_perf <- performance(rocr_pred, measure="tpr", x.measure="fpr")

auc <- performance(rocr_pred, measure='auc')
auc <- auc@y.values[[1]]
print(auc) # 0.8248517

rocr.data <- data.frame(fpr=unlist(rocr_perf@x.values),
                        tpr=unlist(rocr_perf@y.values))

plot2 <- ggplot(rocr.data, aes(x=fpr, ymin=0, ymax=tpr)) + 
  geom_ribbon(alpha=0.2) + 
  geom_line(aes(y=tpr)) + 
  geom_abline(linetype="dashed") + 
  #ggtitle(expression(atop("Naive Bayes", atop("Out-of-Sample ROC Curve")))) +
  ggtitle("Out-of-Sample ROC Curve") +
  labs(x="False Positive Rate", y="True Positive Rate") + 
  annotate("text", x=0.75, y=0.25, label=paste("AUC:", round(auc,2)))

rm(rocr.data, auc)

png(filename="images/resp_m1_nb_outsample_roc.png", 
    width=800, height=800, res=150)

plot2

dev.off()

png(filename="images/resp_m1_nb_sample_roc.png", 
    width=1000, height=600, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()

# Confusion matrix
confmat <- table(round(as.numeric(pred_nb_resp, digits=0)),
                 resp_RESPONSE16.test)
row.names(confmat) = c(0,1)
confusionMatrix(confmat, positive="1")
rm(confmat)

#Confusion Matrix and Statistics

#resp_RESPONSE16.test
#0    1
#0 3503  246
#1  496  218

#Accuracy : 0.8337          
#95% CI : (0.8225, 0.8446)
#No Information Rate : 0.896           
#P-Value [Acc > NIR] : 1               

#Kappa : 0.2793          
#Mcnemar's Test P-Value : <2e-16          

#Sensitivity : 0.46983         
#Specificity : 0.87597         
#Pos Pred Value : 0.30532         
#Neg Pred Value : 0.93438         
#Prevalence : 0.10397         
#Detection Rate : 0.04885         
#Detection Prevalence : 0.15998         
#Balanced Accuracy : 0.67290         

#'Positive' Class : 1


#-------------------------------------------------------------------------
# Model 2: Random Forest
#-------------------------------------------------------------------------

# Fit model # Random Forest: ranger, Parallel Random Forest: parRF
set.seed(1)
objControl <- trainControl(method="cv", number=3, 
                           returnResamp="none", allowParallel=TRUE, verboseIter=TRUE)
fit_rfc <- train(as.factor(resp_RESPONSE16.train) ~ .,
                data=df_cust.16_trainsub,
                method="parRF", trControl=objControl) 

# ROC Curve - In-Sample
pred_rf_resp <- predict(object=fit_rfc, newdata=df_cust.16_trainsub)
pred_rf_prob <- predict(object=fit_rfc, newdata=df_cust.16_trainsub, type="prob")

rocr_pred <- prediction(pred_rf_prob[,2], resp_RESPONSE16.train)
rocr_perf <- performance(rocr_pred, measure="tpr", x.measure="fpr")

auc <- performance(rocr_pred, measure='auc')
auc <- auc@y.values[[1]]
print(auc) # 1

rocr.data <- data.frame(fpr=unlist(rocr_perf@x.values),
                        tpr=unlist(rocr_perf@y.values))

plot1 <- ggplot(rocr.data, aes(x=fpr, ymin=0, ymax=tpr)) + 
  geom_ribbon(alpha=0.2) + 
  geom_line(aes(y=tpr)) + 
  geom_abline(linetype="dashed") +
  #ggtitle(expression(atop("Random Forest", atop("In-Sample ROC Curve")))) +
  ggtitle("In-Sample ROC Curve") +
  labs(x="False Positive Rate", y="True Positive Rate") + 
  annotate("text", x=0.75, y=0.25, label=paste("AUC:", round(auc,2)))

rm(rocr.data, auc)

png(filename="images/resp_m2_rf_insample_roc.png", 
    width=800, height=800, res=150)

plot1

dev.off()

# ROC Curve - Out-of-Sample
pred_rf_resp <- predict(object=fit_rfc, newdata=df_cust.16_testsub)
pred_rf_prob <- predict(object=fit_rfc, newdata=df_cust.16_testsub, type="prob")

rocr_pred <- prediction(pred_rf_prob[,2], resp_RESPONSE16.test)
rocr_perf <- performance(rocr_pred, measure="tpr", x.measure="fpr")

auc <- performance(rocr_pred, measure='auc')
auc <- auc@y.values[[1]]
print(auc) # 0.8537735

rocr.data <- data.frame(fpr=unlist(rocr_perf@x.values),
                        tpr=unlist(rocr_perf@y.values))

plot2 <- ggplot(rocr.data, aes(x=fpr, ymin=0, ymax=tpr)) + 
  geom_ribbon(alpha=0.2) + 
  geom_line(aes(y=tpr)) + 
  geom_abline(linetype="dashed") +
  #ggtitle(expression(atop("Random Forest", atop("Out-of-Sample ROC Curve")))) +
  ggtitle("Out-of-Sample ROC Curve") +
  labs(x="False Positive Rate", y="True Positive Rate") + 
  annotate("text", x=0.75, y=0.25, label=paste("AUC:", round(auc,2)))

rm(rocr.data, auc)

png(filename="images/resp_m2_rf_outsample_roc.png", 
    width=800, height=800, res=150)

plot2

dev.off()

png(filename="images/resp_m2_rf_sample_roc.png", 
    width=1000, height=600, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()

# Confusion matrix
confmat <- table(round(as.numeric(pred_rf_resp, digits=0)),
                 resp_RESPONSE16.test)
row.names(confmat) = c(0,1)
confusionMatrix(confmat, positive="1")

rm(confmat)

#Confusion Matrix and Statistics

#resp_RESPONSE16.test
#0    1
#0 3992  452
#1    7   12

#Accuracy : 0.8972          
#95% CI : (0.8879, 0.9059)
#No Information Rate : 0.896           
#P-Value [Acc > NIR] : 0.4151          

#Kappa : 0.0419          
#Mcnemar's Test P-Value : <2e-16          

#Sensitivity : 0.025862        
#Specificity : 0.998250        
#Pos Pred Value : 0.631579        
#Neg Pred Value : 0.898290        
#Prevalence : 0.103966        
#Detection Rate : 0.002689        
#Detection Prevalence : 0.004257        
#Balanced Accuracy : 0.512056        

#'Positive' Class : 1


#-------------------------------------------------------------------------
# Model 3: GLMnet
#-------------------------------------------------------------------------

# Fit model # glmnet: glmnet
set.seed(1)
objControl <- trainControl(method="cv", number=3, 
                           returnResamp="none", allowParallel=TRUE, verboseIter=TRUE)
fit_glmnet <- train(as.factor(resp_RESPONSE16.train) ~ .,
                    data=df_cust.16_trainsub,
                    method="glmnet", trControl=objControl)

# ROC Curve - In-Sample
pred_glmnet_resp <- predict(object=fit_glmnet, newdata=df_cust.16_trainsub)
pred_glmnet_prob <- predict(object=fit_glmnet, newdata=df_cust.16_trainsub, type="prob")

rocr_pred <- prediction(pred_glmnet_prob[,2], resp_RESPONSE16.train)
rocr_perf <- performance(rocr_pred, measure="tpr", x.measure="fpr")

auc <- performance(rocr_pred, measure='auc')
auc <- auc@y.values[[1]]
print(auc) # 0.8762759

rocr.data <- data.frame(fpr=unlist(rocr_perf@x.values),
                        tpr=unlist(rocr_perf@y.values))

plot1 <- ggplot(rocr.data, aes(x=fpr, ymin=0, ymax=tpr)) + 
  geom_ribbon(alpha=0.2) + 
  geom_line(aes(y=tpr)) + 
  geom_abline(linetype="dashed") + 
  #ggtitle(expression(atop("GLMnet", atop("In-Sample ROC Curve")))) +
  ggtitle("In-Sample ROC Curve") +
  labs(x="False Positive Rate", y="True Positive Rate") + 
  annotate("text", x=0.75, y=0.25, label=paste("AUC:", round(auc,2)))

rm(rocr.data, auc)

png(filename="images/resp_m3_glm_insample_roc.png", 
    width=800, height=800, res=150)

plot1

dev.off()

# ROC Curve - Out-of-Sample
pred_glmnet_resp <- predict(object=fit_glmnet, newdata=df_cust.16_testsub)
pred_glmnet_prob <- predict(object=fit_glmnet, newdata=df_cust.16_testsub, type="prob")

rocr_pred <- prediction(pred_glmnet_prob[,2], resp_RESPONSE16.test)
rocr_perf <- performance(rocr_pred, measure="tpr", x.measure="fpr")

auc <- performance(rocr_pred, measure='auc')
auc <- auc@y.values[[1]]
print(auc) # 0.85903

rocr.data <- data.frame(fpr=unlist(rocr_perf@x.values),
                        tpr=unlist(rocr_perf@y.values))

plot2 <- ggplot(rocr.data, aes(x=fpr, ymin=0, ymax=tpr)) + 
  geom_ribbon(alpha=0.2) + 
  geom_line(aes(y=tpr)) + 
  geom_abline(linetype="dashed") + 
  #ggtitle(expression(atop("GLMnet", atop("Out-of-Sample ROC Curve")))) +
  ggtitle("Out-of-Sample ROC Curve") +
  labs(x="False Positive Rate", y="True Positive Rate") + 
  annotate("text", x=0.75, y=0.25, label=paste("AUC:", round(auc,2)))

rm(rocr.data, auc)

png(filename="images/resp_m3_glm_outsample_roc.png", 
    width=800, height=800, res=150)

plot2

dev.off()

png(filename="images/resp_m3_glm_sample_roc.png", 
    width=1000, height=600, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()

# Confusion matrix
confmat <- table(round(as.numeric(pred_glmnet_resp, digits=0)),
                 resp_RESPONSE16.test)
row.names(confmat) = c(0,1)
confusionMatrix(confmat, positive="1")

rm(confmat)

#Confusion Matrix and Statistics

#resp_RESPONSE16.test
#0    1
#0 4004  416
#1   20   38

#Accuracy : 0.9026          
#95% CI : (0.8936, 0.9112)
#No Information Rate : 0.8986          
#P-Value [Acc > NIR] : 0.1936          

#Kappa : 0.1284          
#Mcnemar's Test P-Value : <2e-16          

#Sensitivity : 0.083700        
#Specificity : 0.995030        
#Pos Pred Value : 0.655172        
#Neg Pred Value : 0.905882        
#Prevalence : 0.101385        
#Detection Rate : 0.008486        
#Detection Prevalence : 0.012952        
#Balanced Accuracy : 0.539365        

#'Positive' Class : 1


###########################################################################
# Estimate Model - Net Revenue
###########################################################################

# Fit randomForest model
set.seed(1)
fit_rf <- randomForest(resp_TOTAMT16.orig ~ ., data=df_cust.16_final, 
                       ntree=20, importance=TRUE, do.trace=TRUE)

# Varible importance
imp_rf <- varImp(fit_rf, scale=FALSE)
#plot(imp_rf, top=20)
imp_rf[, "Variable"] <- rownames(imp_rf)
imp_rf <- imp_rf[with(imp_rf, order(-Overall)), ]

df_temp <- imp_rf
df_temp <- transform(df_temp, 
                     Variable=reorder(Variable, -Overall))

png(filename="images/varimp_totamt16.png", 
    width=1000, height=600, res=150)

ggplot(df_temp[1:20, ], aes(Variable, Overall)) +
  geom_bar(stat="identity", fill="steelblue") +
  scale_fill_manual() +
  labs(x="",
       y="Importance") +
       #title="TOTAMT16 - Variable Importance") + 
  theme(text=element_text(size=10), axis.text.x=element_text(angle=270, hjust=0))

dev.off()

rm(df_temp)

# Subset dataset
cols_TOTAMT16 <- imp_rf[1:50, "Variable"]
df_cust.16_finalsub <- df_cust.16_final[, cols_TOTAMT16]


# Train and test split
train <- 0.7
randraw <- runif(nrow(df_cust.16_final))

df_cust.16_train <- df_cust.16_final[randraw <= train, ]
df_cust.16_trainsub <- df_cust.16_finalsub[randraw <= train, ]

#resp_RESPONSE16.train <- resp_RESPONSE16.orig[randraw <= train]
#resp_QTY16.train <- resp_QTY16.orig[randraw <= train]
resp_TOTAMT16.train <- resp_TOTAMT16.orig[randraw <= train]

df_cust.16_test <- df_cust.16_final[randraw > train, ]
df_cust.16_testsub <- df_cust.16_finalsub[randraw > train, ]

#resp_RESPONSE16.test <- resp_RESPONSE16.orig[randraw > train]
#resp_QTY16.test <- resp_QTY16.orig[randraw > train]
resp_TOTAMT16.test <- resp_TOTAMT16.orig[randraw > train]

rm(train, randraw)


#-------------------------------------------------------------------------
# Model 1: Multiple Linear Regression (Stepwise)
#-------------------------------------------------------------------------

# Fit model # Linear Regression: lm
set.seed(1)
objControl <- trainControl(method="cv", number=3, 
                           returnResamp="none", allowParallel=TRUE, verboseIter=TRUE)
fit_lms <- train(resp_TOTAMT16.train ~ .,
                 data=df_cust.16_trainsub,
                 method="lmStepAIC", trControl=objControl)

summary(fit_lms)
#Residual standard error: 165.2 on 10448 degrees of freedom
#Multiple R-squared:   0.18,	Adjusted R-squared:  0.1782 
#F-statistic: 99.74 on 23 and 10448 DF,  p-value: < 2.2e-16

pred_lms <- predict(fit_lms, df_cust.16_trainsub)
pred_lms[pred_lms <= 0] <- 0

# GOF
k <- 23
n <- length(resp_TOTAMT16.train)
resid <- resp_TOTAMT16.train - pred_lms
sst <- sum((resp_TOTAMT16.train - mean(resp_TOTAMT16.train))^2)
sse <- sum(resid^2)
ssr <- sst - sse
mae <- mean(abs(resid))
mse <- mean((resid)^2)
rmse <- sqrt(mse)
r2 <- ssr / sst
adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
print(paste0(cat("sst: ", round(sst, 2), "\n",
                 "sse: ", round(sse, 2), "\n",
                 "ssr: ", round(ssr, 2), "\n", 
                 "mae: ", round(mae, 2), "\n", 
                 "mse: ", round(mse, 2), "\n",
                 "rmse: ", round(rmse, 2), "\n",
                 "r2: ", round(r2, 4), "\n",
                 "adjr2 ", round(adjr2, 4), sep="")))
rm(k, n, resid, sst, sse, ssr, mae, mse, r2, adjr2)
#sst: 347935483
#sse: 283326687
#ssr: 64608796
#mae: 49.13
#mse: 27055.64
#rmse: 164.49
#r2: 0.1857
#adjr2 0.1839

# Plot of actual vs. predicted
plot1 <- ggplot(aes(x=actual,y=pred), data=data.frame(actual=resp_TOTAMT16.train, pred=pred_lms)) + 
  geom_point() + 
  geom_abline(color='red') + 
  #ggtitle(expression(atop("MLR (Stepwise Sel.)", atop("In-Sample Predict vs. Actuals")))) +
  ggtitle("In-Sample Predict vs. Actuals") +
  labs(x="Actual", y="Prediction") 

png(filename="images/totamt_m1_lms_insample_pred.png", 
    width=800, height=800, res=150)

plot1

dev.off()

pred_lms <- predict(fit_lms, df_cust.16_testsub)
pred_lms[pred_lms <= 0] <- 0

# GOF
k <- 23
n <- length(resp_TOTAMT16.test)
resid <- resp_TOTAMT16.test - pred_lms
sst <- sum((resp_TOTAMT16.test - mean(resp_TOTAMT16.test))^2)
sse <- sum(resid^2)
ssr <- sst - sse
mae <- mean(abs(resid))
mse <- mean((resid)^2)
rmse <- sqrt(mse)
r2 <- ssr / sst
adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
print(paste0(cat("sst: ", round(sst, 2), "\n",
                 "sse: ", round(sse, 2), "\n",
                 "ssr: ", round(ssr, 2), "\n", 
                 "mae: ", round(mae, 2), "\n", 
                 "mse: ", round(mse, 2), "\n",
                 "rmse: ", round(rmse, 2), "\n",
                 "r2: ", round(r2, 4), "\n",
                 "adjr2 ", round(adjr2, 4), sep="")))
rm(k, n, resid, sst, sse, ssr, mae, mse, r2, adjr2)
#sst: 163228224
#sse: 140334741
#ssr: 22893483
#mae: 54.33
#mse: 31535.9
#rmse: 177.58
#r2: 0.1403
#adjr2 0.1358

# Plot of actual vs. predicted
plot2 <- ggplot(aes(x=actual,y=pred), data=data.frame(actual=resp_TOTAMT16.test, pred=pred_lms)) + 
  geom_point() + 
  geom_abline(color='red') + 
  #ggtitle(expression(atop("MLR (Stepwise Sel.)", atop("Out-of-Sample Predict vs. Actuals")))) +
  ggtitle("Out-of-Sample Predict vs. Actuals") +
  labs(x="Actual", y="Prediction")

png(filename="images/totamt_m1_lms_outsample_pred.png", 
    width=800, height=800, res=150)

plot2

dev.off()

png(filename="images/totamt_m1_lms_sample_pred.png", 
    width=1000, height=600, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()


#-------------------------------------------------------------------------
# Model 2: Random Forest
#-------------------------------------------------------------------------

# Fit model # Random Forest: ranger, Parallel Random Forest: parRF
set.seed(1)
objControl <- trainControl(method="cv", number=3, 
                           returnResamp="none", allowParallel=TRUE, verboseIter=TRUE)
fit_rfr <- train(resp_TOTAMT16.train ~ .,
                data=df_cust.16_trainsub,
                method="parRF", trControl=objControl)

summary(fit_rfr)

pred_rf <- predict(fit_rfr, df_cust.16_trainsub)
pred_rf[pred_rf <= 0] <- 0

# GOF
k <- 50
n <- length(resp_TOTAMT16.train)
resid <- resp_TOTAMT16.train - pred_rf
sst <- sum((resp_TOTAMT16.train - mean(resp_TOTAMT16.train))^2)
sse <- sum(resid^2)
ssr <- sst - sse
mae <- mean(abs(resid))
mse <- mean((resid)^2)
rmse <- sqrt(mse)
r2 <- ssr / sst
adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
print(paste0(cat("sst: ", round(sst, 2), "\n",
                 "sse: ", round(sse, 2), "\n",
                 "ssr: ", round(ssr, 2), "\n", 
                 "mae: ", round(mae, 2), "\n", 
                 "mse: ", round(mse, 2), "\n",
                 "rmse: ", round(rmse, 2), "\n",
                 "r2: ", round(r2, 4), "\n",
                 "adjr2 ", round(adjr2, 4), sep="")))
rm(k, n, resid, sst, sse, ssr, mae, mse, r2, adjr2)
#sst: 347935483
#sse: 103213033
#ssr: 244722450
#mae: 28.42
#mse: 9856.1
#rmse: 99.28
#r2: 0.7034
#adjr2 0.7019

# Plot of actual vs. predicted
plot1 <- ggplot(aes(x=actual,y=pred), data=data.frame(actual=resp_TOTAMT16.train, pred=pred_rf)) + 
  geom_point() + 
  geom_abline(color='red') + 
  #ggtitle(expression(atop("Random Forest", atop("In-Sample Predict vs. Actuals")))) +
  ggtitle("In-Sample Predict vs. Actuals") +
  labs(x="Actual", y="Prediction") 

png(filename="images/totamt_m2_rf_insample_pred.png", 
    width=800, height=800, res=150)

plot1

dev.off()

pred_rf <- predict(fit_rfr, df_cust.16_testsub)
pred_rf[pred_rf <= 0] <- 0

# GOF
k <- 50
n <- length(resp_TOTAMT16.test)
resid <- resp_TOTAMT16.test - pred_rf
sst <- sum((resp_TOTAMT16.test - mean(resp_TOTAMT16.test))^2)
sse <- sum(resid^2)
ssr <- sst - sse
mae <- mean(abs(resid))
mse <- mean((resid)^2)
rmse <- sqrt(mse)
r2 <- ssr / sst
adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
print(paste0(cat("sst: ", round(sst, 2), "\n",
                 "sse: ", round(sse, 2), "\n",
                 "ssr: ", round(ssr, 2), "\n", 
                 "mae: ", round(mae, 2), "\n", 
                 "mse: ", round(mse, 2), "\n",
                 "rmse: ", round(rmse, 2), "\n",
                 "r2: ", round(r2, 4), "\n",
                 "adjr2 ", round(adjr2, 4), sep="")))
rm(k, n, resid, sst, sse, ssr, mae, mse, r2, adjr2)
#sst: 163228224
#sse: 143665153
#ssr: 19563071
#mae: 54.48
#mse: 32284.3
#rmse: 179.68
#r2: 0.1199
#adjr2 0.1098

# Plot of actual vs. predicted
plot2 <- ggplot(aes(x=actual,y=pred), data=data.frame(actual=resp_TOTAMT16.test, pred=pred_rf)) + 
  geom_point() + 
  geom_abline(color='red') + 
  #ggtitle(expression(atop("Random Forest", atop("Out-of-Sample Predict vs. Actuals")))) +
  ggtitle("Out-of-Sample Predict vs. Actuals") +
  labs(x="Actual", y="Prediction")

png(filename="images/totamt_m2_rf_outsample_pred.png", 
    width=800, height=800, res=150)

plot2

dev.off()

png(filename="images/totamt_m2_rf_sample_pred.png", 
    width=1000, height=600, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()


#-------------------------------------------------------------------------
# Model 3: eXtreme Gradient Boost
#-------------------------------------------------------------------------

# Fit model # eXtreme Gradient Boosting: xgbLinear
set.seed(1)
objControl <- trainControl(method="cv", number=3, 
                           returnResamp="none", allowParallel=TRUE, verboseIter=TRUE)
fit_xgb <- train(resp_TOTAMT16.train ~ .,
                 data=df_cust.16_trainsub,
                 method="xgbLinear", trControl=objControl)

summary(fit_xgb)

pred_xgb <- predict(fit_xgb, df_cust.16_trainsub)
pred_xgb[pred_xgb <= 0] <- 0

# GOF
k <- 50
n <- length(resp_TOTAMT16.train)
resid <- resp_TOTAMT16.train - pred_xgb
sst <- sum((resp_TOTAMT16.train - mean(resp_TOTAMT16.train))^2)
sse <- sum(resid^2)
ssr <- sst - sse
mae <- mean(abs(resid))
mse <- mean((resid)^2)
rmse <- sqrt(mse)
r2 <- ssr / sst
adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
print(paste0(cat("sst: ", round(sst, 2), "\n",
                 "sse: ", round(sse, 2), "\n",
                 "ssr: ", round(ssr, 2), "\n", 
                 "mae: ", round(mae, 2), "\n", 
                 "mse: ", round(mse, 2), "\n",
                 "rmse: ", round(rmse, 2), "\n",
                 "r2: ", round(r2, 4), "\n",
                 "adjr2 ", round(adjr2, 4), sep="")))
rm(k, n, resid, sst, sse, ssr, mae, mse, r2, adjr2)
#sst: 347935483
#sse: 21002405
#ssr: 326933078
#mae: 18.96
#mse: 2005.58
#rmse: 44.78
#r2: 0.9396
#adjr2 0.9393

# Plot of actual vs. predicted
plot1 <- ggplot(aes(x=actual,y=pred), data=data.frame(actual=resp_TOTAMT16.train, pred=pred_xgb)) + 
  geom_point() + 
  geom_abline(color='red') + 
  #ggtitle(expression(atop("Extreme Grad Boost", atop("In-Sample Predict vs. Actuals")))) +
  ggtitle("In-Sample Predict vs. Actuals") +
  labs(x="Actual", y="Prediction") 

png(filename="images/totamt_m3_xgb_insample_pred.png", 
    width=800, height=800, res=150)

plot1

dev.off()

pred_xgb <- predict(fit_xgb, df_cust.16_testsub)
pred_xgb[pred_xgb <= 0] <- 0

# GOF
k <- 50
n <- length(resp_TOTAMT16.test)
resid <- resp_TOTAMT16.test - pred_xgb
sst <- sum((resp_TOTAMT16.test - mean(resp_TOTAMT16.test))^2)
sse <- sum(resid^2)
ssr <- sst - sse
mae <- mean(abs(resid))
mse <- mean((resid)^2)
rmse <- sqrt(mse)
r2 <- ssr / sst
adjr2 <- 1 - (sse/(n-k-1)) / (sst/(n-1))
print(paste0(cat("sst: ", round(sst, 2), "\n",
                 "sse: ", round(sse, 2), "\n",
                 "ssr: ", round(ssr, 2), "\n", 
                 "mae: ", round(mae, 2), "\n", 
                 "mse: ", round(mse, 2), "\n",
                 "rmse: ", round(rmse, 2), "\n",
                 "r2: ", round(r2, 4), "\n",
                 "adjr2 ", round(adjr2, 4), sep="")))
rm(k, n, resid, sst, sse, ssr, mae, mse, r2, adjr2)
#sst: 163228224
#sse: 159789658
#ssr: 3438566
#mae: 45.48
#mse: 35907.79
#rmse: 189.49
#r2: 0.0211
#adjr2 0.0099

# Plot of actual vs. predicted
plot2 <- ggplot(aes(x=actual,y=pred), data=data.frame(actual=resp_TOTAMT16.test, pred=pred_xgb)) + 
  geom_point() + 
  geom_abline(color='red') + 
  #ggtitle(expression(atop("Extreme Grad Boost", atop("Out-of-Sample Predict vs. Actuals")))) +
  ggtitle("Out-of-Sample Predict vs. Actuals") +
  labs(x="Actual", y="Prediction")

png(filename="images/totamt_m3_xgb_outsample_pred.png", 
    width=800, height=800, res=150)

plot2

dev.off()

png(filename="images/totamt_m3_xgb_sample_pred.png", 
    width=1000, height=600, res=150)

grid.arrange(plot1, plot2, ncol=2)

dev.off()


###########################################################################
# Create Customer Score
###########################################################################

#-------------------------------------------------------------------------
# Prep for non-16th Campaign observations
#-------------------------------------------------------------------------

# Subset data frame
df_cust.ne16_clean <- df_cust.clean[df_cust.clean$ANY_MAIL_16 == 0,]
#nrow(df_cust.ne16_clean) # 15857

# Remove response variables
resp_RESPONSE16.orig <- df_cust.ne16_clean[, "RESPONSE16"]
resp_QTY16.orig <- df_cust.ne16_clean[, "QTY16"]
resp_TOTAMT16.orig <- df_cust.ne16_clean[, "TOTAMT16"]

df_cust.ne16_clean[, "RESPONSE16"] <- NULL
df_cust.ne16_clean[, "QTY16"] <- NULL
df_cust.ne16_clean[, "TOTAMT16"] <- NULL
#df_cust.ne16_clean[, "SUM_MAIL_16"] <- NULL
#df_cust.ne16_clean[, "ANY_MAIL_16"] <- NULL
#df_cust.ne16_clean[, "TOTAL_MAIL_16"] <- NULL


#-------------------------------------------------------------------------
# Data imputation
#-------------------------------------------------------------------------

df_cust.ne16_imp <- df_cust.ne16_clean

# Check for NA's, zero's and blanks
sum(is.na(df_cust.ne16_imp)) # 507771
sum(df_cust.ne16_imp == 0) # NA
sum(df_cust.ne16_imp == "") # NA

for (c in 1:ncol(df_cust.ne16_imp)) {
  
  nas <- sum(is.na(df_cust.ne16_imp[, c]))
  zero <- sum(df_cust.ne16_imp[, c] == 0)
  blank <- sum(df_cust.ne16_imp[, c] == "")
  print(paste(colnames(df_cust.ne16_imp)[c], nas, zero, blank))
  
}

#str(df_cust.ne16_imp, list.len=nrow(df_cust.ne16_imp))
rm(nas, zero, blank)

# Impute numeric
cols <- colnames(df_cust.ne16_imp[, !sapply(df_cust.ne16_imp, is.factor)])

for (c in cols) {
  if (sum(is.na(df_cust.ne16_imp[, c])) > 0) {
    nm <- paste(c, "IMP", sep="_")
    df_cust.ne16_imp[, nm] <- df_cust.ne16_imp[, c]
    med <- median(df_cust.ne16_imp[, nm], na.rm=TRUE)
    df_cust.ne16_imp[, nm][is.na(df_cust.ne16_imp[, nm])] <- med
    df_cust.ne16_imp[, c] <- NULL
  }
}

rm(cols, nm, med)

# Impute factor
cols <- colnames(df_cust.ne16_imp[, sapply(df_cust.ne16_imp, is.factor)])
cols <- cols[cols != "ACCTNO"]

for (c in cols) {
  if (sum(is.na(df_cust.ne16_imp[, c])) > 0) {
    nm <- paste(c, "IMP", sep="_")
    df_cust.ne16_imp[, nm] <- as.numeric(df_cust.ne16_imp[, c]) - 1
    mod <- which.max(df_cust.ne16_imp[, nm]) - 1
    df_cust.ne16_imp[, nm][is.na(df_cust.ne16_imp[, nm])] <- mod
    df_cust.ne16_imp[, nm] <- as.factor(df_cust.ne16_imp[, nm])
    df_cust.ne16_imp[, c] <- NULL
  }
}

rm(cols, nm, mod)

# Check for NA's, zero's and blanks
sum(is.na(df_cust.ne16_imp)) # 0
sum(df_cust.ne16_imp == 0) # 1794487
sum(df_cust.ne16_imp == "") # 0

for (c in 1:ncol(df_cust.ne16_imp)) {
  
  nas <- sum(is.na(df_cust.ne16_imp[, c]))
  zero <- sum(df_cust.ne16_imp[, c] == 0)
  blank <- sum(df_cust.ne16_imp[, c] == "")
  print(paste(colnames(df_cust.ne16_imp)[c], nas, zero, blank))
  
}

#str(df_cust.ne16_imp, list.len=nrow(df_cust.ne16_imp))
rm(nas, zero, blank)

#-------------------------------------------------------------------------
# Data trimming
#-------------------------------------------------------------------------

df_cust.ne16_trim <- df_cust.ne16_imp

# Create trimmed variables
cols <- colnames(df_cust.ne16_trim[, !sapply(df_cust.ne16_trim, is.factor)])

for (c in cols) {
  min <- min(df_cust.ne16_trim[, c])
  max <- min(df_cust.ne16_trim[, c])
  p01 <- quantile(df_cust.ne16_trim[, c], c(0.01)) 
  p99 <- quantile(df_cust.ne16_trim[, c], c(0.99))
  if (p01 > min | p99 < max) {
    nm <- paste(c, "T99", sep="_")
    df_cust.ne16_trim[, nm] <- df_cust.ne16_trim[, c]
    t99 <- quantile(df_cust.ne16_trim[, c], c(0.01, 0.99))
    df_cust.ne16_trim[, nm] <- squish(df_cust.ne16_trim[, nm], t99)
    #df_cust.ne16_trim[, c] <- NULL
  }
}

rm(cols, min, max, p01, p99, nm, t99)

#-------------------------------------------------------------------------
# Create dummy variables
#-------------------------------------------------------------------------

df_cust.ne16_dum <- df_cust.ne16_imp

cols <- colnames(df_cust.ne16_dum[, sapply(df_cust.ne16_dum, is.factor)])

for (c in cols) {
  if (length(unique(df_cust.ne16_dum[, c])) <= 10) {
    for(level in unique(df_cust.ne16_dum[, c])[1:length(unique(df_cust.ne16_dum[, c]))-1]) {
      nm <- paste("DUM", c, level, sep="_")
      df_cust.ne16_dum[, nm] <- ifelse(df_cust.ne16_dum[, c] == level, 1, 0)
    }
  }
}

rm(cols, nm, level)

#length(df_cust.ne16_imp[, grepl("DUM_", names(df_cust.ne16_imp))]) #0
df_cust.ne16_dum <- df_cust.ne16_dum[, grepl("DUM_", names(df_cust.ne16_dum))]
df_cust.ne16_dum[, "ACCTNO"] <- df_cust.ne16_clean[, "ACCTNO"]


#-------------------------------------------------------------------------
# Final prep for non-16th Campaign observations
#-------------------------------------------------------------------------

df_cust.ne16_trim <- df_cust.ne16_trim[, !sapply(df_cust.ne16_trim, is.factor)]
df_cust.ne16_trim[, "ACCTNO"] <- df_cust.ne16_clean[, "ACCTNO"]

#dt_cust.16_imp <- data.table(df_cust.ne16_imp, key="ACCTNO") # note: data.table's more mem eff
#dt_cust.16_dum <- data.table(df_cust.ne16_dum, key="ACCTNO")

df_cust.ne16_final <- merge(df_cust.ne16_trim, df_cust.ne16_dum, all=FALSE)
df_cust.ne16_final[, "ACCTNO"] <- NULL

#str(df_cust.ne16_final, list.len=nrow(df_cust.ne16_final))
#temp <- sapply(df_cust.ne16_final, typeof)
#table(temp)
rm(df_cust.ne16_imp, df_cust.ne16_dum)


#-------------------------------------------------------------------------
# Customer Score Modelling
#-------------------------------------------------------------------------

#resp_RESPONSE16.orig <- df_cust.ne16_final[, "RESPONSE16"]
#resp_QTY16.orig <- df_cust.ne16_final[, "QTY16"]
#resp_TOTAMT16.orig <- df_cust.ne16_final[, "TOTAMT16"]

#df_cust.ne16_final[, "RESPONSE16"] <- NULL
#df_cust.ne16_final[, "QTY16"] <- NULL
#df_cust.ne16_final[, "TOTAMT16"] <- NULL

# RESPOSNE16 prediction - glmnet
for (c in cols_RESPONSE16) {
  if (!(c %in% colnames(df_cust.ne16_final))) { 
    print(c)
    df_cust.ne16_final[, c] <- 0
  }
}

pred_RESPONSE16 <- 1 - predict(object=fit_glmnet, newdata=df_cust.ne16_final[, cols_RESPONSE16], type="prob")[, 1]
#sum(as.numeric(predict(object=fit_glmnet, newdata=df_cust.ne16_final[, cols_RESPONSE16]))-1) # 71

# TOTAMT16 prediction - mlr step
for (c in cols_TOTAMT16) {
  if (!(c %in% colnames(df_cust.ne16_final))) { 
    print(c)
    df_cust.ne16_final[, c] <- 0
  }
}

pred_TOTAMT16 <- predict(fit_lms, df_cust.ne16_final[, cols_TOTAMT16])

df_score <- data.frame(ACCTNO=df_cust.ne16_clean[, "ACCTNO"], 
                       RESPONSE16=pred_RESPONSE16, 
                       TOTAMT16=pred_TOTAMT16)
df_score <- df_score[order(-df_score[, "RESPONSE16"]),] 
#sum(df_score[, "RESPONSE16"]) / nrow(df_score)

df_score[, "TOTAMT16"][df_score[, "TOTAMT16"] < 0] <- 0
df_score[, "NETAMT16"] <- 0.1 * df_score[, "TOTAMT16"]
df_score[, "SCORE16_ALL"] <- df_score[, "RESPONSE16"] * df_score[, "NETAMT16"] - 1

df_score[, "SCORE16_ALLSCORE"] <- 0
df_score[, "SCORE16_HIGHPROB"] <- 0
df_score[, "SCORE16_HIGHVAL"] <- 0
df_score[, "SCORE16_HIGHSCORE"] <- 0
for (r in 1:nrow(df_score)) {
  if (df_score[r, "SCORE16_ALL"] >= 0) {
    df_score[r, "SCORE16_ALLSCORE"] <- df_score[r, "SCORE16_ALL"]
  }
  if (df_score[r, "RESPONSE16"] >= 0.7) {
    df_score[r, "SCORE16_HIGHPROB"] <- df_score[r, "RESPONSE16"] * df_score[r, "NETAMT16"] - 1
  }
  if (df_score[r, "TOTAMT16"] >= 300) {
    df_score[r, "SCORE16_HIGHVAL"] <- df_score[r, "RESPONSE16"] * df_score[r, "NETAMT16"] - 1
  }
  if (df_score[r, "SCORE16_ALL"] >= 20) {
    df_score[r, "SCORE16_HIGHSCORE"] <- df_score[r, "RESPONSE16"] * df_score[r, "NETAMT16"] - 1
  }
}

sum(df_score[, "SCORE16_ALL"]) # -10916.25
sum(df_score[, "SCORE16_ALLSCORE"]) # 2640.325
sum(df_score[, "SCORE16_HIGHPROB"]) # 390.0568
sum(df_score[, "SCORE16_HIGHVAL"]) # 692.0733
sum(df_score[, "SCORE16_HIGHSCORE"]) # 545.9349

nrow(df_score) # 15857
length(df_score[, "ACCTNO"][df_score[, "SCORE16_ALL"] >= 0]) # 1111
length(df_score[, "ACCTNO"][df_score[, "RESPONSE16"] >= 0.7]) # 19
length(df_score[, "ACCTNO"][df_score[, "TOTAMT16"] >= 500]) # 20
length(df_score[, "ACCTNO"][df_score[, "SCORE16_ALL"] >= 20]) # 19

mean(df_score[, "TOTAMT16"][df_score[, "RESPONSE16"] >= 0.5]) # 203.902

# Write score
write.csv(df_score, "score.csv")

# Comparison
table(df_cust.clean$ANY_MAIL_16, df_cust.clean$RESPONSE16)

df_comparison <- df_cust.clean[df_cust.clean$ANY_MAIL_16 == 1,]
df_comparison[, "NETAMT16"] <- 0.1 * df_comparison[, "TOTAMT16"]
df_comparison[, "RESPONSE16"] <- as.numeric(df_comparison[, "RESPONSE16"]) - 1
df_comparison[, "SCORE16_ALL"] <- df_comparison[, "RESPONSE16"] * df_comparison[, "NETAMT16"] - 1

df_comparison[, "SCORE16_ALLSCORE"] <- 0
df_comparison[, "SCORE16_HIGHVAL"] <- 0
df_comparison[, "SCORE16_HIGHSCORE"] <- 0
for (r in 1:nrow(df_comparison)) {
  if (df_comparison[r, "SCORE16_ALL"] >= 0) {
    df_comparison[r, "SCORE16_ALLSCORE"] <- df_comparison[r, "SCORE16_ALL"]
  }
  if (df_comparison[r, "TOTAMT16"] >= 300) {
    df_comparison[r, "SCORE16_HIGHVAL"] <- df_comparison[r, "RESPONSE16"] * df_comparison[r, "NETAMT16"] - 1
  }
  if (df_comparison[r, "SCORE16_ALL"] >= 20) {
    df_comparison[r, "SCORE16_HIGHSCORE"] <- df_comparison[r, "RESPONSE16"] * df_comparison[r, "NETAMT16"] - 1
  }
}

sum(df_comparison[, "SCORE16_ALL"]) # 34396.29
sum(df_comparison[, "SCORE16_ALLSCORE"]) # 47878.29
sum(df_comparison[, "SCORE16_HIGHVAL"]) # 35292.26
sum(df_comparison[, "SCORE16_HIGHSCORE"]) # 40094.85

nrow(df_comparison) # 14922
length(df_comparison[, "ACCTNO"][df_comparison[, "SCORE16_ALL"] >= 0]) # 1440
length(df_comparison[, "ACCTNO"][df_comparison[, "TOTAMT16"] >= 500]) # 278
length(df_comparison[, "ACCTNO"][df_comparison[, "SCORE16_ALL"] >= 20]) # 671

mean(df_comparison[, "TOTAMT16"][df_comparison[, "RESPONSE16"] == 1]) # 342.4881