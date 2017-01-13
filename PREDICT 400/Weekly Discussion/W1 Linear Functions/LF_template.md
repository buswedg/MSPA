
#MSPA PREDICT 400

##Discussion Topic: Week 1 Linear Functions

###Introduction

This document presents the results of the first weeks discussion topic for the Masters of Science in Predictive Analytics course: PREDICT 400. This assessment required the student to find an article that discusses some form of linear function, to summarize that article and reproduce analysis contained within the article.

###Article

For this assessment, I selected the article 'A Model of Australian Household Leverage' (the article). A copy of the article can be found <a href = "http://www.pimco.com.au/EN/Insights/Pages/A-Model-of-Australian-Household-Leverage.aspx">here</a>. The article focuses on answering a) which variables have explanatory power over household leverage (household debt to income ratio), b) if an increase in household wealth does in fact lead to an increase in consumption, and c) how households are likely to react to a potential decline in wealth. In order to address these questions, the article makes use of a vector autoregressive modelling framework with exogenous variables (VARX) relevant to both the Australian and U.S. markets. 

###Relevance

Prior to estimating the VARX for each country, the article tests the significance of predictors using simple linear regression. In order to address the requirements of this week's discussion topic, this assessment focuses on reproducing this preliminary linear regression analysis for the proposed Australian market predictors.

###Data

This assessment makes use of the same Australian predictors referenced by the article with a few exceptions. Predictors form a mix of economic and financial time series (quarterly) datasets, obtained from the Reserve Bank of Australia (RBA) and Australian Bureau of Statistics (ABS). These include:

- Household debt to income ratio, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID BHFDDIT

- Wages and salaries, source <a href = "http://www.abs.gov.au">ABS</a>, Series ID A2302464V

- Net disposable income per capita, source <a href = "http://www.abs.gov.au">ABS</a>, Series ID A2302466X

- Unemployment rate, source <a href = "http://www.abs.gov.au">ABS</a>, Series ID A84423092X

- Household net worth, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID BSPNSHUNW

- Household asset values, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID BSPNSHNFD

- Mortgage Rate, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID FILRHLBV

- House debt payment to disposable income, source <a href = "http://www.rba.gov.au">RBA</a>, Series ID BHFIPDH


Note:

- This assessment did not make use of the 'Westpac-Melbourne Institute Consumer Confidence' data series.

- All ABS data series used as part of this assessment are reported by the ABS as 'original' rather than 'seasonally' or 'trend' adjusted.

- The article refers to the Australian predictor dataset as having a sample period of June 1971 to June 2014, however, the RBA sourced data series mentioned above have limited this assessment to a sample period of September 1988 to September 2015.

###Assessment

####1. Loading the Data

Load datasets into a pandas dataframe.


```python
import pandas as pd

houselev_raw_df = pd.read_csv("data/household_leverage.csv")
houselev_raw_df.head(10)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Date</th>
      <th>BHFDDIT</th>
      <th>A2302464V</th>
      <th>A2302466X</th>
      <th>A84423092X</th>
      <th>BSPNSHUNW</th>
      <th>BSPNSHNFD</th>
      <th>FILRHLBV</th>
      <th>BHFIPDH</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>30/09/1988</td>
      <td>63.000691</td>
      <td>158070</td>
      <td>8401</td>
      <td>6.9</td>
      <td>1068.653</td>
      <td>634.7</td>
      <td>8.05</td>
      <td>5.219343</td>
    </tr>
    <tr>
      <th>1</th>
      <td>31/12/1988</td>
      <td>66.603995</td>
      <td>172717</td>
      <td>9274</td>
      <td>6.9</td>
      <td>1117.892</td>
      <td>683.0</td>
      <td>8.05</td>
      <td>5.350265</td>
    </tr>
    <tr>
      <th>2</th>
      <td>31/03/1989</td>
      <td>68.137013</td>
      <td>155626</td>
      <td>8118</td>
      <td>6.7</td>
      <td>1147.106</td>
      <td>713.8</td>
      <td>8.05</td>
      <td>5.524976</td>
    </tr>
    <tr>
      <th>3</th>
      <td>30/06/1989</td>
      <td>68.894535</td>
      <td>163547</td>
      <td>8570</td>
      <td>5.8</td>
      <td>1179.259</td>
      <td>736.4</td>
      <td>8.05</td>
      <td>5.786236</td>
    </tr>
    <tr>
      <th>4</th>
      <td>30/09/1989</td>
      <td>68.253159</td>
      <td>166761</td>
      <td>8721</td>
      <td>6.0</td>
      <td>1216.935</td>
      <td>752.8</td>
      <td>8.05</td>
      <td>6.184814</td>
    </tr>
    <tr>
      <th>5</th>
      <td>31/12/1989</td>
      <td>68.635029</td>
      <td>178154</td>
      <td>9373</td>
      <td>5.9</td>
      <td>1228.812</td>
      <td>764.1</td>
      <td>8.05</td>
      <td>5.940397</td>
    </tr>
    <tr>
      <th>6</th>
      <td>31/03/1990</td>
      <td>69.380467</td>
      <td>158881</td>
      <td>8096</td>
      <td>6.5</td>
      <td>1244.017</td>
      <td>780.5</td>
      <td>8.05</td>
      <td>5.832948</td>
    </tr>
    <tr>
      <th>7</th>
      <td>30/06/1990</td>
      <td>71.040716</td>
      <td>165254</td>
      <td>8467</td>
      <td>6.4</td>
      <td>1257.470</td>
      <td>797.0</td>
      <td>8.05</td>
      <td>5.780391</td>
    </tr>
    <tr>
      <th>8</th>
      <td>30/09/1990</td>
      <td>69.830578</td>
      <td>166709</td>
      <td>8515</td>
      <td>7.3</td>
      <td>1256.250</td>
      <td>795.9</td>
      <td>8.05</td>
      <td>5.693462</td>
    </tr>
    <tr>
      <th>9</th>
      <td>31/12/1990</td>
      <td>70.423586</td>
      <td>176782</td>
      <td>9072</td>
      <td>8.1</td>
      <td>1259.080</td>
      <td>801.1</td>
      <td>8.30</td>
      <td>5.463346</td>
    </tr>
  </tbody>
</table>
</div>



Check data types of each series.


```python
print(houselev_raw_df.dtypes)
```

    Date           object
    BHFDDIT       float64
    A2302464V       int64
    A2302466X       int64
    A84423092X    float64
    BSPNSHUNW     float64
    BSPNSHNFD     float64
    FILRHLBV      float64
    BHFIPDH       float64
    dtype: object
    

Build a reference table for each data series.


```python
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
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>BHFDDIT</th>
      <td>Household debt to income ratio</td>
    </tr>
    <tr>
      <th>A2302464V</th>
      <td>Wages and salaries</td>
    </tr>
    <tr>
      <th>A2302466X</th>
      <td>Net disposable income per capita</td>
    </tr>
    <tr>
      <th>A84423092X</th>
      <td>Unemployment rate</td>
    </tr>
    <tr>
      <th>BSPNSHUNW</th>
      <td>Household net worth</td>
    </tr>
    <tr>
      <th>BSPNSHNFD</th>
      <td>Household asset values</td>
    </tr>
    <tr>
      <th>FILRHLBV</th>
      <td>Mortage rate</td>
    </tr>
    <tr>
      <th>BHFIPDH</th>
      <td>House debt payment to disposable income</td>
    </tr>
  </tbody>
</table>
</div>



####2. Pre-process the Data

Calculate percent changes between each quarter for all data series, and derive lagged data series up to five periods.


```python
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
```

The final post-processed dataset is shown below.


```python
houselev_df.head(10)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Date</th>
      <th>BHFDDIT</th>
      <th>A2302464V</th>
      <th>A2302466X</th>
      <th>A84423092X</th>
      <th>BSPNSHUNW</th>
      <th>BSPNSHNFD</th>
      <th>FILRHLBV</th>
      <th>BHFIPDH</th>
      <th>BHFDDIT_1</th>
      <th>...</th>
      <th>FILRHLBV_4</th>
      <th>BHFIPDH_4</th>
      <th>BHFDDIT_5</th>
      <th>A2302464V_5</th>
      <th>A2302466X_5</th>
      <th>A84423092X_5</th>
      <th>BSPNSHUNW_5</th>
      <th>BSPNSHNFD_5</th>
      <th>FILRHLBV_5</th>
      <th>BHFIPDH_5</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1</th>
      <td>31/12/1988</td>
      <td>0.057195</td>
      <td>0.092661</td>
      <td>0.103916</td>
      <td>0.000000</td>
      <td>0.046076</td>
      <td>0.076099</td>
      <td>0.000000</td>
      <td>0.025084</td>
      <td>0.000000</td>
      <td>...</td>
      <td>0</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>2</th>
      <td>31/03/1989</td>
      <td>0.023017</td>
      <td>-0.098954</td>
      <td>-0.124650</td>
      <td>-0.028986</td>
      <td>0.026133</td>
      <td>0.045095</td>
      <td>0.000000</td>
      <td>0.032655</td>
      <td>0.057195</td>
      <td>...</td>
      <td>0</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>3</th>
      <td>30/06/1989</td>
      <td>0.011118</td>
      <td>0.050898</td>
      <td>0.055679</td>
      <td>-0.134328</td>
      <td>0.028030</td>
      <td>0.031662</td>
      <td>0.000000</td>
      <td>0.047287</td>
      <td>0.023017</td>
      <td>...</td>
      <td>0</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>4</th>
      <td>30/09/1989</td>
      <td>-0.009310</td>
      <td>0.019652</td>
      <td>0.017620</td>
      <td>0.034483</td>
      <td>0.031949</td>
      <td>0.022271</td>
      <td>0.000000</td>
      <td>0.068884</td>
      <td>0.011118</td>
      <td>...</td>
      <td>0</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>5</th>
      <td>31/12/1989</td>
      <td>0.005595</td>
      <td>0.068319</td>
      <td>0.074762</td>
      <td>-0.016667</td>
      <td>0.009760</td>
      <td>0.015011</td>
      <td>0.000000</td>
      <td>-0.039519</td>
      <td>-0.009310</td>
      <td>...</td>
      <td>0</td>
      <td>0.025084</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0.000000</td>
      <td>0</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>6</th>
      <td>31/03/1990</td>
      <td>0.010861</td>
      <td>-0.108182</td>
      <td>-0.136242</td>
      <td>0.101695</td>
      <td>0.012374</td>
      <td>0.021463</td>
      <td>0.000000</td>
      <td>-0.018088</td>
      <td>0.005595</td>
      <td>...</td>
      <td>0</td>
      <td>0.032655</td>
      <td>0.057195</td>
      <td>0.092661</td>
      <td>0.103916</td>
      <td>0.000000</td>
      <td>0.046076</td>
      <td>0.076099</td>
      <td>0</td>
      <td>0.025084</td>
    </tr>
    <tr>
      <th>7</th>
      <td>30/06/1990</td>
      <td>0.023930</td>
      <td>0.040112</td>
      <td>0.045825</td>
      <td>-0.015385</td>
      <td>0.010814</td>
      <td>0.021140</td>
      <td>0.000000</td>
      <td>-0.009010</td>
      <td>0.010861</td>
      <td>...</td>
      <td>0</td>
      <td>0.047287</td>
      <td>0.023017</td>
      <td>-0.098954</td>
      <td>-0.124650</td>
      <td>-0.028986</td>
      <td>0.026133</td>
      <td>0.045095</td>
      <td>0</td>
      <td>0.032655</td>
    </tr>
    <tr>
      <th>8</th>
      <td>30/09/1990</td>
      <td>-0.017034</td>
      <td>0.008805</td>
      <td>0.005669</td>
      <td>0.140625</td>
      <td>-0.000970</td>
      <td>-0.001380</td>
      <td>0.000000</td>
      <td>-0.015039</td>
      <td>0.023930</td>
      <td>...</td>
      <td>0</td>
      <td>0.068884</td>
      <td>0.011118</td>
      <td>0.050898</td>
      <td>0.055679</td>
      <td>-0.134328</td>
      <td>0.028030</td>
      <td>0.031662</td>
      <td>0</td>
      <td>0.047287</td>
    </tr>
    <tr>
      <th>9</th>
      <td>31/12/1990</td>
      <td>0.008492</td>
      <td>0.060423</td>
      <td>0.065414</td>
      <td>0.109589</td>
      <td>0.002253</td>
      <td>0.006533</td>
      <td>0.031056</td>
      <td>-0.040418</td>
      <td>-0.017034</td>
      <td>...</td>
      <td>0</td>
      <td>-0.039519</td>
      <td>-0.009310</td>
      <td>0.019652</td>
      <td>0.017620</td>
      <td>0.034483</td>
      <td>0.031949</td>
      <td>0.022271</td>
      <td>0</td>
      <td>0.068884</td>
    </tr>
    <tr>
      <th>10</th>
      <td>31/03/1991</td>
      <td>0.008882</td>
      <td>-0.115922</td>
      <td>-0.145392</td>
      <td>0.185185</td>
      <td>0.026808</td>
      <td>0.021720</td>
      <td>0.000000</td>
      <td>-0.056435</td>
      <td>0.008492</td>
      <td>...</td>
      <td>0</td>
      <td>-0.018088</td>
      <td>0.005595</td>
      <td>0.068319</td>
      <td>0.074762</td>
      <td>-0.016667</td>
      <td>0.009760</td>
      <td>0.015011</td>
      <td>0</td>
      <td>-0.039519</td>
    </tr>
  </tbody>
</table>
<p>10 rows × 49 columns</p>
</div>



####3. Single Linear Regression

Estimate Ordinary Least Squares (OLS) based linear regression for 'household debt to income ratio' against 'wages and salaries'. Here, 'household debt to income ratio' is the dependent variable and 'wages and salaries' is used as the independent (explanatory) variable.


```python
import statsmodels.api as sm

label = houselev_df["BHFDDIT"]

feat = houselev_df["A2302464V"]
#feat_c = sm.add_constant(feat)

ols_model = sm.OLS(label, feat)
ols_fitted = ols_model.fit()
ols_fitted.summary()
```




<table class="simpletable">
<caption>OLS Regression Results</caption>
<tr>
  <th>Dep. Variable:</th>         <td>BHFDDIT</td>     <th>  R-squared:         </th> <td>   0.082</td>
</tr>
<tr>
  <th>Model:</th>                   <td>OLS</td>       <th>  Adj. R-squared:    </th> <td>   0.073</td>
</tr>
<tr>
  <th>Method:</th>             <td>Least Squares</td>  <th>  F-statistic:       </th> <td>   9.531</td>
</tr>
<tr>
  <th>Date:</th>             <td>Fri, 08 Jan 2016</td> <th>  Prob (F-statistic):</th>  <td>0.00257</td>
</tr>
<tr>
  <th>Time:</th>                 <td>21:45:38</td>     <th>  Log-Likelihood:    </th> <td>  298.10</td>
</tr>
<tr>
  <th>No. Observations:</th>      <td>   108</td>      <th>  AIC:               </th> <td>  -594.2</td>
</tr>
<tr>
  <th>Df Residuals:</th>          <td>   107</td>      <th>  BIC:               </th> <td>  -591.5</td>
</tr>
<tr>
  <th>Df Model:</th>              <td>     1</td>      <th>                     </th>     <td> </td>   
</tr>
<tr>
  <th>Covariance Type:</th>      <td>nonrobust</td>    <th>                     </th>     <td> </td>   
</tr>
</table>
<table class="simpletable">
<tr>
      <td></td>         <th>coef</th>     <th>std err</th>      <th>t</th>      <th>P>|t|</th> <th>[95.0% Conf. Int.]</th> 
</tr>
<tr>
  <th>A2302464V</th> <td>    0.0816</td> <td>    0.026</td> <td>    3.087</td> <td> 0.003</td> <td>    0.029     0.134</td>
</tr>
</table>
<table class="simpletable">
<tr>
  <th>Omnibus:</th>       <td> 1.166</td> <th>  Durbin-Watson:     </th> <td>   0.839</td>
</tr>
<tr>
  <th>Prob(Omnibus):</th> <td> 0.558</td> <th>  Jarque-Bera (JB):  </th> <td>   0.684</td>
</tr>
<tr>
  <th>Skew:</th>          <td>-0.031</td> <th>  Prob(JB):          </th> <td>   0.710</td>
</tr>
<tr>
  <th>Kurtosis:</th>      <td> 3.385</td> <th>  Cond. No.          </th> <td>    1.00</td>
</tr>
</table>



We see a positive coefficient, suggesting that an increase (decrease) in 'wages and salaries' tends to coincide with an increase (decrease) in the 'household debt to income ratio'. Do note however, the low R^2 value for this estimation.

A scatter plot of 'household debt to income ratio' against 'wages and salaries' is shown below, along with a plot of the above linear function. 


```python
import numpy as np
import matplotlib.pyplot as plt
%matplotlib inline

feat_pred = np.linspace(feat.min(), feat.max())
#feat_pred_c = sm.add_constant(feat_pred)

label_pred = ols_fitted.predict(feat_pred)

plt.scatter(feat, label)
plt.plot(feat_pred, label_pred)
plt.title("BHFDDIT vs A2302464V")
plt.ylabel("BHFDDIT")
plt.xlabel("A2302464V")
plt.show()
```


![png](output_28_0.png)


####4. Linear Regression Loop

Create a loop function which estimates an OLS based linear regression and prints the 'coefficient', 't-statistic', 'p-value' and 'R^2'. Each of the coefficients shown below are regressed against the same 'household debt to income ratio' dependent variable as per the above estimation.


```python
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
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Description</th>
      <th>Coefficient</th>
      <th>t-stat</th>
      <th>p-value</th>
      <th>R^2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>A2302464V</th>
      <td>Wages and salaries</td>
      <td>0.081561</td>
      <td>3.087229</td>
      <td>2.573100e-03</td>
      <td>0.081789</td>
    </tr>
    <tr>
      <th>A2302466X</th>
      <td>Net disposable income per capita</td>
      <td>0.058281</td>
      <td>2.598742</td>
      <td>1.067568e-02</td>
      <td>0.059369</td>
    </tr>
    <tr>
      <th>A84423092X</th>
      <td>Unemployment rate</td>
      <td>-0.055672</td>
      <td>-2.870357</td>
      <td>4.942458e-03</td>
      <td>0.071494</td>
    </tr>
    <tr>
      <th>BSPNSHUNW</th>
      <td>Household net worth</td>
      <td>0.336079</td>
      <td>7.474830</td>
      <td>2.235241e-11</td>
      <td>0.343047</td>
    </tr>
    <tr>
      <th>BSPNSHNFD</th>
      <td>Household asset values</td>
      <td>0.353942</td>
      <td>8.862252</td>
      <td>1.898103e-14</td>
      <td>0.423303</td>
    </tr>
    <tr>
      <th>FILRHLBV</th>
      <td>Mortage rate</td>
      <td>-0.060206</td>
      <td>-1.109911</td>
      <td>2.695257e-01</td>
      <td>0.011382</td>
    </tr>
    <tr>
      <th>BHFIPDH</th>
      <td>House debt payment to disposable income</td>
      <td>0.073378</td>
      <td>2.103517</td>
      <td>3.776457e-02</td>
      <td>0.039711</td>
    </tr>
  </tbody>
</table>
</div>



The polarity of each coefficient seems reasonable. Estimations suggest an increase in 'wage and salaries', 'net disposable income per capita', 'household net worth', household asset values', or 'house debt payment to disposable income' tends to coincide with an increase in 'household debt to income ratio'. While an increase in 'unemployment rate' or 'mortgage rate' tends to coincide with a decrease in 'household debt to income ratio'.

Apply the loop function to the final Australian predictors presented within Table 4 of the article.


```python
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
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Description</th>
      <th>Coefficient</th>
      <th>t-stat</th>
      <th>p-value</th>
      <th>R^2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>BSPNSHNFD</th>
      <td>Household asset values</td>
      <td>0.353942</td>
      <td>8.862252</td>
      <td>1.898103e-14</td>
      <td>0.423303</td>
    </tr>
    <tr>
      <th>BSPNSHNFD_1</th>
      <td>Household asset values (lag 1)</td>
      <td>0.295371</td>
      <td>6.658483</td>
      <td>1.227156e-09</td>
      <td>0.292961</td>
    </tr>
    <tr>
      <th>BSPNSHNFD_2</th>
      <td>Household asset values (lag 2)</td>
      <td>0.265380</td>
      <td>5.707860</td>
      <td>1.032718e-07</td>
      <td>0.233413</td>
    </tr>
    <tr>
      <th>BSPNSHUNW_1</th>
      <td>Household net worth (lag 1)</td>
      <td>0.301756</td>
      <td>6.391537</td>
      <td>4.385056e-09</td>
      <td>0.276302</td>
    </tr>
    <tr>
      <th>BSPNSHUNW_2</th>
      <td>Household net worth (lag 2)</td>
      <td>0.269179</td>
      <td>5.473577</td>
      <td>2.932802e-07</td>
      <td>0.218750</td>
    </tr>
    <tr>
      <th>FILRHLBV_3</th>
      <td>Mortage rate (lag 3)</td>
      <td>-0.004043</td>
      <td>-0.073523</td>
      <td>9.415271e-01</td>
      <td>0.000051</td>
    </tr>
    <tr>
      <th>BSPNSHUNW</th>
      <td>Household net worth</td>
      <td>0.336079</td>
      <td>7.474830</td>
      <td>2.235241e-11</td>
      <td>0.343047</td>
    </tr>
    <tr>
      <th>FILRHLBV_4</th>
      <td>Mortage rate (lag 4)</td>
      <td>-0.029918</td>
      <td>-0.544863</td>
      <td>5.869817e-01</td>
      <td>0.002767</td>
    </tr>
    <tr>
      <th>A84423092X</th>
      <td>Unemployment rate</td>
      <td>-0.055672</td>
      <td>-2.870357</td>
      <td>4.942458e-03</td>
      <td>0.071494</td>
    </tr>
    <tr>
      <th>FILRHLBV_2</th>
      <td>Mortage rate (lag 2)</td>
      <td>-0.060373</td>
      <td>-1.104231</td>
      <td>2.719702e-01</td>
      <td>0.011267</td>
    </tr>
    <tr>
      <th>BHFIPDH_2</th>
      <td>House debt payment to disposable income (lag 2)</td>
      <td>-0.001930</td>
      <td>-0.053991</td>
      <td>9.570430e-01</td>
      <td>0.000027</td>
    </tr>
    <tr>
      <th>BHFIPDH_3</th>
      <td>House debt payment to disposable income (lag 3)</td>
      <td>-0.005199</td>
      <td>-0.145419</td>
      <td>8.846537e-01</td>
      <td>0.000198</td>
    </tr>
    <tr>
      <th>A2302466X</th>
      <td>Net disposable income per capita</td>
      <td>0.058281</td>
      <td>2.598742</td>
      <td>1.067568e-02</td>
      <td>0.059369</td>
    </tr>
  </tbody>
</table>
</div>



Although the polarity of each coefficient reported above matches those shown within the article, the actual coefficient values and their associated statistics do not. However, the above results are consistent with the article in reporting that 'households asset values' has the greatest absolute coefficient and greatest R^2.

####5. Scatter Plot Loop

Finally, a loop function is created which produces a scatter and linear plot for the variable combinations shown within Figure 1 of the article.


```python
import statsmodels.api as sm
import numpy as np
import matplotlib.pyplot as plt
%matplotlib inline

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
```


![png](output_38_0.png)



![png](output_38_1.png)



![png](output_38_2.png)



![png](output_38_3.png)


Each plot shown above bears some resemblance to the plots shown in Figure 1 of the article.

###Conclusion

This assessment was able to reproduce similar results to the preliminary Australian predictor regression analysis shown within the article. The most likely reason for the inability to exactly reproduce the article's results relates back to inconsistencies between datasets. As noted, I was unable to reconcile back to the same sample period as that noted by the article. There may also have been mismatches between selected ABS based data series, i.e. I made a conscious effort to select 'original' datasets rather than those that have been 'seasonally' or 'trend' adjusted, however a preference was not noted by the article.
