for(package in c('cluster', 'factoextra', 'fpc', 'NbClust',
                 'reshape', 'plyr',
                 'ggplot2', 'scales', 'grid', 'gridExtra')) {
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

# http://www.stat.berkeley.edu/~s133/Cluster2a.html
# http://rstatistics.net/cluster-analysis/
# http://stackoverflow.com/questions/15376075/cluster-analysis-in-r-determine-the-optimal-number-of-clusters
# http://deepaksinghviblog.blogspot.com.au/2014/09/cluster-analysis-using-r-with-banking.html

#-------------------------------------------------------------------------
# Data prep
#-------------------------------------------------------------------------

# Load the dataset
load('data/appHappyData-sp2016.RData')
df_appnum.raw <- apphappy.4.num.frame
df_applab.raw <- apphappy.4.labs.frame

# Subset the data for attitudinal variables
colstart <- which(colnames(df_appnum.raw) == 'q24r1')
colend <- which(colnames(df_appnum.raw) == 'q26r17')
df_appnum.att = df_appnum.raw[,c(colstart:colend)]
df_applab.att = df_applab.raw[,c(colstart:colend)]

# Subset the data for nonattitudinal variables
df_appnum.nonatt = df_appnum.raw[,c(-colstart:-colend)]
df_applab.nonatt = df_applab.raw[,c(-colstart:-colend)]

# Count NA rows for attitudinal variables
inclna <- nrow(df_appnum.att) 
exclna <- nrow(na.omit(df_appnum.att))
#print(paste0("Basis observations: ", inclna - exclna)) #0

# Count NA rows for non-attitudinal variables
inclna <- nrow(df_appnum.nonatt) 
exclna <- nrow(na.omit(df_appnum.nonatt))
#print(paste0("Non-basis observations: ", inclna - exclna)) #585

# Count NA rows for original dataset
inclna <- nrow(df_appnum.raw) 
exclna <- nrow(na.omit(df_appnum.raw))
#print(paste0("Dataset observations: ", inclna - exclna)) #585

rm(apphappy.4.num.frame, apphappy.4.labs.frame, colstart, colend)


###########################################################################
# Non-hierarchical Clustering
###########################################################################

#-------------------------------------------------------------------------
# Determine number of clusters
#-------------------------------------------------------------------------

# Method: kmeans, Distance: euclidean
#nbc.eu <- NbClust(df_appnum.att, 
#                  min.nc=2, max.nc=10, distance='euclidean', 
#                  method='kmeans', index='all')
#table(nc$Best.n[1,])

#plot1 <- fviz_nbclust(nbc.eu) + 
#  ggtitle('NbClust Criterion\nK-means + Euclidean Distance')

#rm(nbc.eu)


# Method: medoid, Distance: euclidean
##pamk.eu <- pamk(df_appnum.att, diss=FALSE, krange=1:10, 
##                criterion='asw', critout=TRUE)

##df_pamk <- melt(pamk.eu$crit)
##df_pamk$index <- rownames(df_pamk)

##plot2 <- ggplot(df_pamk, aes(x=index, y=value)) +
##  geom_bar(stat='identity', fill='steelblue') + 
##  scale_x_discrete(limits=c(1:10)) +
##  ggtitle('Silhouette Width Criterion\n') +
##  labs(x='Number of clusters k', y='Average silhouette width criterion value')

#rm(pamk.eu, df_pamk)


# Method: medoid, Distance: gower
dist.daisy <- daisy(df_applab.att, metric='gower', stand=FALSE)
pamk.gow <- pamk(dist.daisy, diss=TRUE, krange=1:10, 
                 criterion='asw', critout=TRUE)

df_pamk <- melt(pamk.gow$crit)
df_pamk$index <- rownames(df_pamk)

plot3 <- ggplot(df_pamk, aes(x=index, y=value)) +
  geom_bar(stat='identity', fill='steelblue') + 
  scale_x_discrete(limits=c(1:10)) +
  ggtitle('Silhouette Width Criterion\nMedoid + Gower Distance') +
  labs(x='Number of clusters k', y='Average silhouette width criterion value')

rm(dist.daisy, pamk.gow, df_pamk)


#png(filename='images/nonhier_kcrit.png', 
#    width = 1000, height = 600, res = 100)

#grid.arrange(plot1, plot3, ncol=2)

#dev.off()

rm(plot1, plot2, plot3)

#-------------------------------------------------------------------------
# Clustering analysis
#-------------------------------------------------------------------------

# Method: kmeans, Distance: euclidean
k = 2 # Set cluster center count according to no. clust criterion

set.seed(1)
res.km <- kmeans(df_appnum.att, centers=k)

plot1 <- fviz_cluster(res.km, df_appnum.att,
                      show.clust.cent=TRUE, geom='point',
                      title='Cluster Plot\nK-means + Euclidean Distance')


# Method: medoid, Distance: euclidean
##k = 2 # Set cluster center count according to no. clust criterion

##set.seed(1)
##res.pam1 <- pam(df_appnum.att, k=k, diss=FALSE, 
##                metric='euclidean',
##                stand=FALSE, cluster.only=FALSE)

##plot2 <- fviz_cluster(res.pam1,
##                      show.clust.cent=TRUE, geom='point',
##                      title='Cluster Plot\nMedoid + Euclidean Distance')


# Method: medoid, Distance: gower
k = 2 # Set cluster center count according to no. clust criterion

set.seed(1)
dist.daisy <- daisy(df_applab.att, metric='gower', stand=FALSE)
res.pam2 <- pam(dist.daisy, k=k, diss=TRUE,
                metric='euclidean',
                stand=FALSE, cluster.only=FALSE)

plot3 <- fviz_cluster(list(data=df_appnum.att, 
                           cluster=res.pam2$cluster),
                      show.clust.cent=TRUE, geom='point',
                      title='Cluster Plot\nMedoid + Gower Distance')

rm(dist.daisy)


png(filename='images/nonhier_clust.png', 
    width = 1000, height = 600, res = 100)

grid.arrange(plot1, plot3, ncol=2)
#grid.arrange(plot1, plot2, plot3, ncol=3)

dev.off()

rm(plot1, plot2, plot3)
rm(k)


###########################################################################
# Hierarchical Clustering
###########################################################################

#-------------------------------------------------------------------------
# Determine number of clusters
#-------------------------------------------------------------------------

# Method: ward.D, Distance: euclidean
#nbc.eu <- NbClust(df_appnum.att, diss=NULL,
#                  min.nc=2, max.nc=10, distance='euclidean',
#                  method='ward.D2', index='all')
#table(nbc.eu$Best.n[1,])

#plot1 <- fviz_nbclust(nbc.eu) + 
#  ggtitle('NbClust Criterion\nWard + Euclidean Distance')


# Method: ward.D, Distance: manhattan
#nbc.man <- NbClust(df_appnum.att, diss=NULL,
#                   min.nc=2, max.nc=10, distance='manhattan',
#                   method='ward.D2', index='all')
#table(nbc.man$Best.n[1,])

#plot2 <- fviz_nbclust(nbc.eu) + 
#  ggtitle('NbClust Criterion\nWard + Manhattan Distance')


# Method: ward.D, Distance: gower
#dist.daisy <- daisy(df_applab.att, metric='gower', stand=FALSE)
#nbc.gow <- NbClust(df_appnum.att, diss=dist.daisy,
#                   min.nc=2, max.nc=10, distance=NULL,
#                   method='ward.D2', index='all')
#table(nbc.gow$Best.n[1,])

#plot3 <- fviz_nbclust(nbc.gow) + 
#  ggtitle('NbClust Criterion\nWard + Gower Distance')


#png(filename='images/hier_kcrit.png', 
#    width = 1000, height = 600, res = 100)

#grid.arrange(plot1, plot3, ncol=2)

#dev.off()

rm(plot1, plot2, plot3)

#-------------------------------------------------------------------------
# Clustering analysis
#-------------------------------------------------------------------------

# Method: ward.D, Distance: euclidean
k = 3 # Color dendogram according to no. clust criterion

set.seed(1)
res.hcut1 <- hcut(df_appnum.att, k=k, isdiss=FALSE, 
                  hc_func='hclust', hc_metric='euclidean',
                  hc_method='ward.D2', stand=FALSE)

plot1a <- fviz_silhouette(res.hcut1) +
  scale_y_continuous(limits = c(-0.25, 0.5)) +
  ggtitle('Silhouette Plot\nWard + Euclidean Distance') +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

plot1b <- fviz_cluster(res.hcut1, df_appnum.att, 
                      show.clust.cent=TRUE, geom='point',
                      title='Cluster Plot\nWard + Euclidean Distance')


# Method: ward.D, Distance: manhattan
##k = 3 # Color dendogram according to no. clust criterion

##set.seed(1)
##res.hcut2 <- hcut(df_appnum.att, k=k, isdiss=FALSE, 
##                  hc_func='hclust', hc_metric='manhattan',
##                  hc_method='ward.D2', stand=FALSE)

##plot2a <- fviz_silhouette(res.hcut2) +
##  scale_y_continuous(limits = c(-0.25, 0.5)) +
##  ggtitle('Silhouette Plot\nWard + Manhattan Distance') +
##  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

##plot2b <- fviz_cluster(res.hcut2, df_appnum.att, 
##                      show.clust.cent=TRUE, geom='point',
##                      title='Cluster Plot\nWard + Manhattan Distance')


# Method: ward.D, Distance: gower
k = 2 # Color dendogram according to no. clust criterion

set.seed(1)
dist.daisy <- daisy(df_applab.att, metric='gower', stand=FALSE)
res.hcut3 <- hcut(dist.daisy, k=k, isdiss=TRUE,
                  hc_func='hclust', hc_metric='euclidean',
                  hc_method='ward.D2', stand=FALSE)

plot3a <- fviz_silhouette(res.hcut3) +
  scale_y_continuous(limits = c(-0.25, 0.5)) +
  ggtitle('Silhouette Plot\nWard + Gower Distance') +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

plot3b <- fviz_cluster(res.hcut3, df_appnum.att, 
                      show.clust.cent=TRUE, geom='point',
                      title='Cluster Plot\nWard + Gower Distance')

rm(dist.daisy)


#png(filename='images/hier_den.png', 
#    width = 1000, height = 600, res = 100)

#par(mfrow=c(1,2))

#fviz_dend(res.hcut1, k=3, 
#          cex=0.5, show_labels=FALSE, rect=TRUE,
#          main='Dendogram\nWard + Euclidean Distance')

##fviz_dend(res.hcut2, k=3, 
##          cex=0.5, show_labels=FALSE, rect=TRUE,
##          main='Dendogram\nWard + Manhattan Distance')

#fviz_dend(res.hcut3, k=2,
#          cex=0.5, show_labels=FALSE, rect=TRUE,
#          main='Dendogram\nWard + Gower Distance')

#par()
#dev.off()


# Method: ward.D, Distance: gower
k = 3 # Re-run for four clusters based on interpretation of dendogram

set.seed(1)
dist.daisy <- daisy(df_applab.att, metric='gower', stand=FALSE)
res.hcut3 <- hcut(dist.daisy, k=k, isdiss=TRUE,
                  hc_func='hclust', hc_metric='euclidean',
                  hc_method='ward.D2', stand=FALSE)

plot3a <- fviz_silhouette(res.hcut3) +
  scale_y_continuous(limits = c(-0.25, 0.5)) +
  ggtitle('Silhouette Plot\nWard + Gower Distance') +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

plot3b <- fviz_cluster(res.hcut3, df_appnum.att, 
                       show.clust.cent=TRUE, geom='point',
                       title='Cluster Plot\nWard + Gower Distance')

rm(dist.daisy)


png(filename='images/hier_sil.png', 
    width = 1000, height = 600, res = 100)

grid.arrange(plot1a, plot3a, ncol=2)
#grid.arrange(plot1a, plot2a, plot3a, ncol=3)

dev.off()

rm(plot1a, plot2a, plot3a)

png(filename='images/hier_clust.png', 
    width = 1000, height = 600, res = 100)

grid.arrange(plot1b, plot3b, ncol=2)
#grid.arrange(plot1b, plot2b, plot3b, ncol=3)

dev.off()

rm(plot1b, plot2b, plot3b)
rm(k)


###########################################################################
# Statistical Confirmation
###########################################################################

ls_nm <- list('res.km', 'res.pam2', 'res.hcut1', 'res.hcut3')
ls_df <- list(res.km, res.pam2, res.hcut1, res.hcut3)

# Calculate the AIC for each clustering method, for each question
apply.glm.f <- function(y,class){
  return(glm(y~class)$aic)
}

df_temp <- data.frame(names = rownames(t(df_appnum.raw)))

for (i in 1:length(ls_nm)){
  df_appnum.raw$cluster <- ls_df[[i]]$cluster
  df_aic <- data.frame(apply(df_appnum.raw, 2, 
                             apply.glm.f, class=df_appnum.raw$cluster))
  names(df_aic)[1] <- ls_nm[[i]]
  df_aic$names <- rownames(df_aic)
  
  df_temp <- merge(x=df_temp, y=df_aic, by.x='names', all=TRUE)
}

rownames(df_temp) <- df_temp[, 1]
df_temp <- df_temp[-c(1:2),-1]

df_aic <- df_temp[is.finite(rowSums(df_temp)), ]
colnames(df_aic) <- c('k-means + Euclidean', 'Medoid + Gower',
                      'Ward + Eucildean', 'Ward + Gower')
write.table(round(df_aic, 3), 'aic.csv')
apply(df_aic, 2, mean)


# Calculate the Chi for each clustering method, for each question
sim.chisq.pval.f <- function(x,class){
  return(chisq.test(x,class,
                    rescale.p=TRUE,
                    simulate.p.value=TRUE)$p.value)
}

df_temp <- data.frame(names = rownames(t(df_appnum.raw)))

for (i in 1:length(ls_nm)){
  df_appnum.raw$cluster <- ls_df[[i]]$cluster
  df_chi <- data.frame(apply(df_appnum.att, 2,
                             sim.chisq.pval.f, class=df_appnum.raw$cluster))
  names(df_chi)[1] <- ls_nm[[i]]
  df_chi$names <- rownames(df_chi)
  
  df_temp <- merge(x=df_temp, y=df_chi, by.x='names', all=TRUE)
}

rownames(df_temp) <- df_temp[, 1]
df_temp <- df_temp[-c(1:2),-1]

df_chi <- df_temp[is.finite(rowSums(df_temp)), ]
colnames(df_chi) <- c('k-means + Euclidean', 'Medoid + Gower',
                      'Ward + Eucildean', 'Ward + Gower')
apply(df_chi, 2, mean)


rm(ls_nm, ls_df, df_temp)


###########################################################################
# Cluster Exploration
###########################################################################

#colnames(df_applab.raw)
# q1. Which of the following best describes your age?
# q2. Do you own any of the following smartphones or other web-enabled devices?
# q4. Do you use any of the following kinds of Apps?
# q11. How many Apps do you have on your smartphone/iPod Touch/Tablet? If you have more than of these device, please tell us the total number of Apps.
# q12. Of your Apps, what percent were free to download?
# q13. How many times per week do you visit each of the following websites?
# q24. Please tell us how much you agree or disagree with each of the following statements.
# q25. And how much do you agree or disagree with each of the following?
# q26. And finally how much do you agree or disagree with each of these statements?
# q48. Which of the following best describes the highest level of education you have attained?
# q49. Which of the following best describe your marital status?
# q50. Do you currently have any children in the following age groups?
# q54. Which of the following best describes your race?
# q55. Do you consider yourself to be of Hispanic or Latino ethnicity?
# q56. Which of the following best describes your household annual income before taxes?
# q57. Please indicate your gender.

# Select clustering method
res.sel <- res.km # res.km, res.pam1, res.pam2, res.hcut1, res.hcut2, res.hcut3
df_appnum.raw$cluster <- res.sel$cluster
df_applab.raw$cluster <- res.sel$cluster

df_means <- ddply(df_appnum.raw, 
                  .(df_appnum.raw$cluster), colwise(mean))

# Basic Cluster Profiling
with(df_applab.raw, table(q1, cluster))
with(df_applab.raw, table(q11, cluster))
with(df_applab.raw, table(q12, cluster))
with(df_applab.raw, table(q48, cluster))
with(df_applab.raw, table(q49, cluster))
with(df_applab.raw, table(q54, cluster))
with(df_applab.raw, table(q56, cluster))

plot(df_means$q1, type='b', main='Age by Cluster')
plot(df_means$q11, type='b', main='# of Apps by Cluster')
plot(df_means$q12, type='b', main='% of Free Apps by Cluster')
plot(df_means$q48, type='b', main='Education by Cluster')
plot(df_means$q49, type='b', main='Martial Status by Cluster')
plot(df_means$q54, type='b', main='Ethnicity by Cluster')
plot(df_means$q56, type='b', main='Income by Cluster')

anova(aov(q1~cluster, data=df_appnum.raw))
anova(aov(q11~cluster, data=df_appnum.raw))
anova(aov(q12~cluster, data=df_appnum.raw))
anova(aov(q48~cluster, data=df_appnum.raw))
anova(aov(q49~cluster, data=df_appnum.raw))
anova(aov(q54~cluster, data=df_appnum.raw))
anova(aov(q56~cluster, data=df_appnum.raw))


# Recategorize high level fields
df_applab.raw$q1.recat <- as.character(df_applab.raw$q1)
df_applab.raw$q1.recat[df_applab.raw$q1.recat == 'Under 18' | 
                         df_applab.raw$q1.recat == '18-24'] <- '0-18'
df_applab.raw$q1.recat[df_applab.raw$q1.recat == '25-29' | 
                         df_applab.raw$q1.recat == '30-34'] <- '25-34'
df_applab.raw$q1.recat[df_applab.raw$q1.recat == '35-39' | 
                         df_applab.raw$q1.recat == '40-44'] <- '35-44'
df_applab.raw$q1.recat[df_applab.raw$q1.recat == '45-49' | 
                         df_applab.raw$q1.recat == '50-54'] <- '45-54'
df_applab.raw$q1.recat[df_applab.raw$q1.recat == '55-59' | 
                         df_applab.raw$q1.recat == '60-64' | 
                         df_applab.raw$q1.recat == '65 or over'] <- '55 or over'
df_applab.raw$q1.recat <- as.factor(df_applab.raw$q1.recat)

df_applab.raw$q11.recat <- df_applab.raw$q11
df_applab.raw$q11.recat <- as.character(df_applab.raw$q11)
df_applab.raw$q11.recat[grepl("Don", df_applab.raw$q11.recat)] <- NA
df_applab.raw$q11.recat[df_applab.raw$q11.recat == 'None' | 
                          df_applab.raw$q11.recat == '1-5'] <- '1: 0-5'
df_applab.raw$q11.recat[df_applab.raw$q11.recat == '6-10'] <- '2: 6-10'
df_applab.raw$q11.recat[df_applab.raw$q11.recat == '11-30'] <- '3: 11-30'
df_applab.raw$q11.recat[df_applab.raw$q11.recat == '31+'] <- '4: 31+'
df_applab.raw$q11.recat <- as.factor(df_applab.raw$q11.recat)

df_applab.raw$q12.recat <- df_applab.raw$q12
df_applab.raw$q12.recat[df_applab.raw$q12.recat == 'None of my Apps were free'] <- NA

df_applab.raw$q56.recat <- as.character(df_applab.raw$q56)
df_applab.raw$q56.recat[df_applab.raw$q56.recat == 'Under $10,000' | 
                          df_applab.raw$q56.recat == '$10,000-$14,999'] <- '1: Less than $14,999'
df_applab.raw$q56.recat[df_applab.raw$q56.recat == '$15,000-$19,999' | 
                          df_applab.raw$q56.recat == '$20,000-$29,999'] <- '2: $15,000-$29,999'
df_applab.raw$q56.recat[df_applab.raw$q56.recat == '$30,000-$39,999' | 
                          df_applab.raw$q56.recat == '$40,000-$49,999'] <- '3: $30,000-$49,999'
df_applab.raw$q56.recat[df_applab.raw$q56.recat == '$50,000-$59,999' | 
                          df_applab.raw$q56.recat == '$60,000-$69,999'] <- '4: $50,000-$69,999'
df_applab.raw$q56.recat[df_applab.raw$q56.recat == '$70,000-$79,999' | 
                          df_applab.raw$q56.recat == '$80,000-$89,999'] <- '5: $70,000-$99,999'
df_applab.raw$q56.recat[df_applab.raw$q56.recat == '$90,000-$99,999' | 
                          df_applab.raw$q56.recat == '$100,000-$124,999'] <- '6: $100,000-$124,999'
df_applab.raw$q56.recat[df_applab.raw$q56.recat == '$125,000-$149,999' |
                          df_applab.raw$q56.recat == '$150,000 and over'] <- '7: $125,000 and over'
df_applab.raw$q56.recat <- as.factor(df_applab.raw$q56.recat)

#lapply(df_applab.raw, class)


# Loop through plots
ls_aes.q2 <- list('q2r1', 'q2r2', 'q2r3', 'q2r4', 'q2r5', 
                  'q2r6', 'q2r7', 'q2r8', 'q2r9', 'q2r10')
ls_sub.q4 <- list('q4r1', 'q4r2', 'q4r3', 'q4r4', 'q4r5', 
                  'q4r6', 'q4r7', 'q4r8', 'q4r9', 'q4r10', 'q4r11')
ls_sub.q13 <- list('q13r1', 'q13r2', 'q13r3', 'q13r4', 'q13r5', 'q13r6', 
                   'q13r7', 'q13r8', 'q13r9', 'q13r10', 'q13r11', 'q13r12', 'q13r13')
ls_sub.q24 <- list('q24r1', 'q24r2', 'q24r3', 'q24r4', 'q24r5', 'q24r6', 
                   'q24r7', 'q24r8', 'q24r9', 'q24r10', 'q24r11', 'q24r12')
ls_sub.q25 <- list('q25r1', 'q25r2', 'q25r3', 'q25r4', 'q25r5', 'q25r6', 
                   'q25r7', 'q25r8', 'q25r9', 'q25r10', 'q25r11', 'q25r12')
ls_sub.q26 <- list('q26r1', 'q26r2', 'q26r3', 'q26r4', 'q26r5', 'q26r6', 'q26r7', 'q26r8', 
                   'q26r9', 'q26r10', 'q26r11', 'q26r12', 'q26r13', 'q26r14', 'q26r15', 'q26r16', 'q26r17')
ls_sub.q50 <- list('q50r1', 'q50r2', 'q50r3', 'q50r4', 'q50r5')

ls_aes <- list('q1.recat', 'q11.recat', 'q12.recat', 'q48', 'q49', 'q54', 'q55', 'q56.recat', 'q57',
               ls_aes.q2, ls_sub.q4, ls_sub.q13, ls_sub.q24, ls_sub.q25, ls_sub.q26, ls_sub.q50) 

ls_title <- c('q1. Which of the following best describes your age?\n',
              'q11. How many Apps do you have on your smartphone/iPod Touch/Tablet?\n',
              'q12. Of your Apps, what percent were free to download?\n',
              'q48. Which of the following best describes the\nhighest level of education you have attained?\n',
              'q49. Which of the following best describe your marital status?\n',
              'q54. Which of the following best describes your race?\n',
              'q55. Do you consider yourself to be of Hispanic or Latino ethnicity?\n',
              'q56. Which of the following best describes your\nhousehold annual income before taxes?\n',
              'q57. Please indicate your gender',
              'q2. Do you own any of the following smartphones\nor other web-enabled devices?',
              'q4. Do you use any of the following kinds of Apps?',
              'q13. How many times per week do you visit each of the following websites?',
              'q24. Please tell us how much you agree or disagree\nwith each of the following statements.',
              'q25. And how much do you agree or disagree with each of the following?',
              'q26. And finally how much do you agree or disagree\nwith each of these statements?',
              'q50. Do you currently have any children in the following age groups?')

for (i in 1:length(ls_aes)){
  
  df_temp <- df_applab.raw[ , names(df_applab.raw) %in% c(ls_aes[[i]], 'cluster')]
  df_temp <- melt(df_temp, id.vars=c('cluster'))
  df_temp <- df_temp[!grepl("NO TO", df_temp$value), ]
  
  df_temp[, 'cluster'] <- as.factor(df_temp[, 'cluster'])
  df_temp[, 'value'] <- as.factor(df_temp[, 'value'])
  
  plot1 <- ggplot(na.omit(df_temp), aes_string(x='value', fill='cluster')) + 
    geom_bar(position='dodge') +
    scale_fill_brewer(palette='Paired') +
    #scale_y_continuous(limits = c(0, 250)) +
    #ggtitle(ls_title[i]) +
    labs(x='', y='Responses') +
    #guides(fill=guide_legend(reverse=TRUE)) +
    theme(axis.text.x=element_text(angle=45, hjust=1), 
          legend.position='bottom')
  
  df_temp[, 'cluster'] <- as.numeric(df_temp[, 'cluster'])
  df_temp[, 'value'] <- as.character(df_temp[, 'value'])
  
  legrow <- round(length(unique(df_temp[, 'value'])) / 2, 0)
  
  plot2 <- ggplot(na.omit(df_temp), aes_string(x='cluster', fill='value')) + 
    geom_bar(position='fill') +
    scale_fill_brewer(palette='PuBuGn') +
    scale_y_continuous(labels=percent) +
    scale_x_discrete(limits = c('Cluster 1', 'Cluster 2')) +
    #ggtitle(ls_title[i]) +
    labs(x='', y='Proportion of Responses') +
    guides(fill=guide_legend(nrow=legrow)) +
    theme(axis.text.x=element_text(angle=45, hjust=1), 
          legend.title=element_blank(), legend.position='bottom')
  
  filenm <- paste0('images/barplot_', ls_aes[[i]][[1]], '.png')
  
  png(filename=filenm, width = 1000, height = 600, res = 100)
  
  grid.arrange(plot1, plot2, ncol=2,
               top=textGrob(ls_title[i],
                            gp=gpar(fontsize=16,font=3)))
  
  dev.off()
  
  print(paste0('saved: ', filenm))
  
}

rm(ls_aes.q2, ls_sub.q4, ls_sub.q13, ls_sub.q24, ls_sub.q25, ls_sub.q26, ls_sub.q50, ls_aes, ls_title)
rm(i, df_temp, legrow, filenm, plot1, plot2)


#                   cluster1	                cluster2
#q1	  age	          younger	                  older

#q48	education	    more educated             less educated

#q49	status	      more seperated            less seperated
#                   less single with partner  more single with partner

#q50	children	    less younger children	    more younger children
#                   more older children       less older children

#q54	race	        more white or caucasian	  less white or caucasian

#q56	income	      higher incomes	          lower incomes

#q2	  devices	      more iphone bias	        less iphone bias
#                   more android bias	        less android bias
#                   less ipod bias	          more ipod bias
#                   less tablet device bias	  more tablet device bias

#q4   apps	        less entertainment bias	  more entertainment bias
#                   more gaming bias	        less gaming bias
#                   more music bias	          less music bias
#                   more social bias	        less social bias
#                   less tv bias	            more tv bias

#q11  no. apps	    less apps	                more apps

#q12	free apps	    more free apps	          less free apps

#q13	no. websites  less visits	              more visits