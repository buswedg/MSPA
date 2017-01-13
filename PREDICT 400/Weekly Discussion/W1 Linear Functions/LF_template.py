
# coding: utf-8

# #MSPA PREDICT 400

# ##Discussion Topic: Week 1 Linear Functions

# ###Introduction

# This document presents the results of the first weeks discussion topic for the Masters of Science in Predictive Analytics course: PREDICT 400. This assessment required the student to find an article that discusses some form of linear function, to summarize that article and reproduce analysis contained within the article.

# ###Article

# For this assessment, I selected the article 'A Model of Australian Household Leverage' (the article). A copy of the article can be found <a href = "http://www.pimco.com.au/EN/Insights/Pages/A-Model-of-Australian-Household-Leverage.aspx">here</a>. The article focuses on answering a) which variables have explanatory power over household leverage (household debt to income ratio), b) if an increase in household wealth does in fact lead to an increase in consumption, and c) how households are likely to react to a potential decline in wealth. In order to address these questions, the article makes use of a vector autoregressive modelling framework with exogenous variables (VARX) relevant to both the Australian and U.S. markets. 

# ###Relevance

# Prior to estimating the VARX for each country, the article tests the significance of predictors using simple linear regression. In order to address the requirements of this week's discussion topic, this assessment focuses on reproducing this preliminary linear regression analysis for the proposed Australian market predictors.

# ###Data

# This assessment makes use of the same Australian predictors referenced by the article with a few exceptions. Predictors form a mix of economic and financial time series (quarterly) datasets, obtained from the Reserve Bank of Australia (RBA) and Australian Bureau of Statistics (ABS). These include:
# 
# - Household debt to income ratio, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID BHFDDIT
# 
# - Wages and salaries, source <a href = "http://www.abs.gov.au">ABS</a>, Series ID A2302464V
# 
# - Net disposable income per capita, source <a href = "http://www.abs.gov.au">ABS</a>, Series ID A2302466X
# 
# - Unemployment rate, source <a href = "http://www.abs.gov.au">ABS</a>, Series ID A84423092X
# 
# - Household net worth, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID BSPNSHUNW
# 
# - Household asset values, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID BSPNSHNFD
# 
# - Mortgage Rate, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID FILRHLBV
# 
# - House debt payment to disposable income, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID BHFIPDH
# 
# 
# Note:
# 
# - This assessment did not make use of the 'Westpac-Melbourne Institute Consumer Confidence' data series.
# 
# - All ABS data series used as part of this assessment are reported by the ABS as 'original' rather than 'seasonally' or 'trend' adjusted.
# 
# - The article refers to the Australian predictor dataset as having a sample period of June 1971 to June 2014, however, the RBA sourced data series mentioned above have limited this assessment to a sample period of September 1988 to September 2015.

# ###Assessment

# ####1. Loading the Data

# Load datasets into a pandas dataframe.

# In[1]:

import pandas as pd

houselev_raw_df = pd.read_csv("data/household_leverage.csv")
houselev_raw_df.head(10)


# Check data types of each series.

# In[2]:

print(houselev_raw_df.dtypes)


# Build a reference table for each data series.

# In[3]:

data = ["BHFDDIT", 
        "A2302464V", 
        "A2302466X", 
        "A84423092X", 
        "BSPNSHUNW", 
        "BSPNSHNFD", 
        "FILRHLBV", 
        "BHFIPDH"]

desc = ["Household debt to income ratio", 
        "Wages and salaries", 
        "Net disposable income per capita", 
        "Unemployment rate", 
        "Household net worth", 
        "Household asset values", 
        "Mortage rate", 
        "House debt payment to disposable income"]

index = pd.DataFrame(desc, data)
index.columns = ["Description"]
index


# ####2. Pre-process the Data

# Calculate percent changes between each quarter for all data series, and derive lagged data series up to five periods.

# In[4]:

houselev_df = houselev_raw_df[data].pct_change()
houselev_df = houselev_df.join(houselev_raw_df["Date"])
houselev_df = houselev_df[["Date"] + data]
houselev_df = houselev_df.ix[1: ]

lags = [1, 2, 3, 4, 5]

for l in lags:
    houselev_lag_df = houselev_df.shift(l)
    houselev_lag_df = houselev_lag_df[data]
    houselev_lag_df.columns = houselev_lag_df.columns.map(lambda x: str(x) + "_" + str(l))
    houselev_df = houselev_df.join(houselev_lag_df)
    houselev_df = houselev_df.fillna(0)


# The final post-processed dataset is shown below.

# In[5]:

houselev_df.head(10)


# ####3. Single Linear Regression

# Estimate Ordinary Least Squares (OLS) based linear regression for 'household debt to income ratio' against 'wages and salaries'. Here, 'household debt to income ratio' is the dependent variable and 'wages and salaries' is used as the independent (explanatory) variable.

# In[6]:

import statsmodels.api as sm

label = houselev_df["BHFDDIT"]

feat = houselev_df["A2302464V"]
#feat_c = sm.add_constant(feat)

ols_model = sm.OLS(label, feat)
ols_fitted = ols_model.fit()
ols_fitted.summary()


# We see a positive coefficient, suggesting that an increase (decrease) in 'wages and salaries' tends to coincide with an increase (decrease) in the 'household debt to income ratio'. Do note however, the low R^2 value for this estimation.

# A scatter plot of 'household debt to income ratio' against 'wages and salaries' is shown below, along with a plot of the above linear function. 

# In[7]:

import numpy as np
import matplotlib.pyplot as plt
get_ipython().magic('matplotlib inline')

feat_pred = np.linspace(feat.min(), feat.max())
#feat_pred_c = sm.add_constant(feat_pred)

label_pred = ols_fitted.predict(feat_pred)

plt.scatter(feat, label)
plt.plot(feat_pred, label_pred)
plt.title("BHFDDIT vs A2302464V")
plt.ylabel("BHFDDIT")
plt.xlabel("A2302464V")
plt.show()


# ####4. Linear Regression Loop

# Create a loop function which estimates an OLS based linear regression and prints the 'coefficient', 't-statistic', 'p-value' and 'R^2'. Each of the coefficients shown below are regressed against the same 'household debt to income ratio' dependent variable as per the above estimation.

# In[8]:

import itertools
from scipy.stats import linregress

label = ["BHFDDIT"]

feat = ["A2302464V", 
        "A2302466X", 
        "A84423092X", 
        "BSPNSHUNW", 
        "BSPNSHNFD", 
        "FILRHLBV", 
        "BHFIPDH"]

desc = ["Wages and salaries", 
        "Net disposable income per capita", 
        "Unemployment rate", 
        "Household net worth", 
        "Household asset values", 
        "Mortage rate", 
        "House debt payment to disposable income"]

resultcols = ["Description", 
              "Coefficient", 
              "t-stat", 
              "p-value",
              "R^2"]

results_df = pd.DataFrame([])

for f, d in zip(feat, desc):
    #f_c = sm.add_constant(f)
    ols_model = sm.OLS(houselev_df[label], houselev_df[f])
    ols_fitted = ols_model.fit()
    
    #coefficient
    coeff = ols_fitted.params[0]
    #t-stat
    t_stat = ols_fitted.tvalues[0]
    #p-value
    p_value = ols_fitted.pvalues[0]
    #R^2
    r2 = ols_fitted.rsquared

    temp_df = pd.DataFrame([[d, 
                             coeff, 
                             t_stat, 
                             p_value, 
                             r2]], 
                           index = [f], columns = resultcols)
    
    results_df = results_df.append(temp_df)

results_df


# The polarity of each coefficient seems reasonable. Estimations suggest an increase in 'wage and salaries', 'net disposable income per capita', 'household net worth', household asset values', or 'house debt payment to disposable income' tends to coincide with an increase in 'household debt to income ratio'. While an increase in 'unemployment rate' or 'mortgage rate' tends to coincide with a decrease in 'household debt to income ratio'.

# Apply the loop function to the final Australian predictors presented within Table 4 of the article.

# In[9]:

label = ["BHFDDIT"]

feat = ["BSPNSHNFD", 
        "BSPNSHNFD_1",
        "BSPNSHNFD_2",
        "BSPNSHUNW_1",
        "BSPNSHUNW_2",
        "FILRHLBV_3",
        "BSPNSHUNW",
        "FILRHLBV_4",
        "A84423092X",
        "FILRHLBV_2",
        "BHFIPDH_2",
        "BHFIPDH_3",
        "A2302466X"]
             
desc = ["Household asset values",
        "Household asset values (lag 1)",
        "Household asset values (lag 2)",
        "Household net worth (lag 1)",
        "Household net worth (lag 2)",
        "Mortage rate (lag 3)", 
        "Household net worth", 
        "Mortage rate (lag 4)", 
        "Unemployment rate", 
        "Mortage rate (lag 2)", 
        "House debt payment to disposable income (lag 2)",
        "House debt payment to disposable income (lag 3)",
        "Net disposable income per capita"]

resultcols = ["Description", 
              "Coefficient", 
              "t-stat", 
              "p-value",
              "R^2"]

results_df = pd.DataFrame([])

for f, d in zip(feat, desc):
    #f_c = sm.add_constant(f)
    ols_model = sm.OLS(houselev_df[label], houselev_df[f])
    ols_fitted = ols_model.fit()
    
    #coefficient
    coeff = ols_fitted.params[0]
    #t-stat
    t_stat = ols_fitted.tvalues[0]
    #p-value
    p_value = ols_fitted.pvalues[0]
    #R^2
    r2 = ols_fitted.rsquared

    temp_df = pd.DataFrame([[d, 
                             coeff, 
                             t_stat, 
                             p_value, 
                             r2]], 
                           index = [f], columns = resultcols)
    
    results_df = results_df.append(temp_df)

results_df


# Although the polarity of each coefficient reported above matches those shown within the article, the actual coefficient values and their associated statistics do not. However, the above results are consistent with the article in reporting that 'households asset values' has the greatest absolute coefficient and greatest R^2.

# ####5. Scatter Plot Loop

# Finally, a loop function is created which produces a scatter and linear plot for the variable combinations shown within Figure 1 of the article.

# In[10]:

import statsmodels.api as sm
import numpy as np
import matplotlib.pyplot as plt
get_ipython().magic('matplotlib inline')

label = ["BHFDDIT"]

feat = ["BSPNSHNFD",
        "BSPNSHNFD_1",
        "BSPNSHNFD_2",
        "FILRHLBV_2"]

for f in feat:
    label = houselev_df["BHFDDIT"]
    
    feat = houselev_df[f]
    #feat_c = sm.add_constant(f)
    
    ols_model = sm.OLS(label, feat)
    ols_fitted = ols_model.fit()

    feat_pred = np.linspace(feat.min(), feat.max())
    #feat_pred_c = sm.add_constant(feat_pred)

    label_pred = ols_fitted.predict(feat_pred)

    plt.scatter(feat, label)
    plt.plot(feat_pred, label_pred)
    plt.title("BHFDDIT" + " vs " + f)
    plt.ylabel("BHFDDIT")
    plt.xlabel(f)
    plt.show()


# Each plot shown above bears some resemblance to the plots shown in Figure 1 of the article.

# ###Conclusion

# This assessment was able to reproduce similar results to the preliminary Australian predictor regression analysis shown within the article. The most likely reason for the inability to exactly reproduce the article's results relates back to inconsistencies between datasets. As noted, I was unable to reconcile back to the same sample period as that noted by the article. There may also have been mismatches between selected ABS based data series, i.e. I made a conscious effort to select 'original' datasets rather than those that have been 'seasonally' or 'trend' adjusted, however a preference was not noted by the article.
