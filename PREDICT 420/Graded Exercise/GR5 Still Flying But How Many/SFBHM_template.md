
#MSPA PREDICT 420

##Graded Exercise 5: Still Flying But How Many

###Introduction

This document presents the results of the forth graded exercise for the Masters of Science in Predictive Analytics course: PREDICT 420.

###Assessment

####1. Loading the Data

Load datasets into pandas dataframes.


```python
import pandas as pd

df_passenger = pd.read_csv("data/2014+CY-YTD+Passenger+Raw+Data_2-1.csv", skiprows = [0], thousands = ",")
df_a2010 = pd.read_table("data/A2010_14.txt", encoding = "latin-1")
df_causefactors = pd.read_table("data/causefactors.txt", header = None)
```

    C:\Anaconda3\lib\site-packages\IPython\core\interactiveshell.py:2902: DtypeWarning: Columns (9,64,67,76,81) have mixed types. Specify dtype option on import or set low_memory=False.
      interactivity=interactivity, compiler=compiler, result=result)
    

####2. Pre-process the Data

Set field names for 'passenger' dataframe.


```python
df_passenger.columns = ["month",
                        "orgApt",
                        "destApt",
                        "orgWAC",
                        "destWAC",
                        "carrier",
                        "group",
                        "type",
                        "total",
                        "schedule",
                        "charter"]
```

Confirm dtypes for 'passenger' dataframe fields.


```python
print(df_passenger.dtypes)
```

    month        int64
    orgApt      object
    destApt     object
    orgWAC       int64
    destWAC      int64
    carrier     object
    group        int64
    type        object
    total        int64
    schedule     int64
    charter      int64
    dtype: object
    

Print first five records for dataframes.


```python
df_passenger.head(5)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>month</th>
      <th>orgApt</th>
      <th>destApt</th>
      <th>orgWAC</th>
      <th>destWAC</th>
      <th>carrier</th>
      <th>group</th>
      <th>type</th>
      <th>total</th>
      <th>schedule</th>
      <th>charter</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>201401</td>
      <td>AEX</td>
      <td>GUA</td>
      <td>72</td>
      <td>127</td>
      <td>FCQ</td>
      <td>1</td>
      <td>Passengers</td>
      <td>398</td>
      <td>0</td>
      <td>398</td>
    </tr>
    <tr>
      <th>1</th>
      <td>201401</td>
      <td>AEX</td>
      <td>GUA</td>
      <td>72</td>
      <td>127</td>
      <td>XP</td>
      <td>1</td>
      <td>Passengers</td>
      <td>68</td>
      <td>0</td>
      <td>68</td>
    </tr>
    <tr>
      <th>2</th>
      <td>201401</td>
      <td>AEX</td>
      <td>GYE</td>
      <td>72</td>
      <td>337</td>
      <td>FCQ</td>
      <td>1</td>
      <td>Passengers</td>
      <td>202</td>
      <td>0</td>
      <td>202</td>
    </tr>
    <tr>
      <th>3</th>
      <td>201401</td>
      <td>AEX</td>
      <td>MGA</td>
      <td>72</td>
      <td>153</td>
      <td>FCQ</td>
      <td>1</td>
      <td>Passengers</td>
      <td>17</td>
      <td>0</td>
      <td>17</td>
    </tr>
    <tr>
      <th>4</th>
      <td>201401</td>
      <td>AEX</td>
      <td>PAP</td>
      <td>72</td>
      <td>238</td>
      <td>K8</td>
      <td>1</td>
      <td>Passengers</td>
      <td>73</td>
      <td>0</td>
      <td>73</td>
    </tr>
  </tbody>
</table>
</div>




```python
import pandas as pd

pd.set_option("display.max_columns", 180)
```


```python
df_a2010.head(5)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>c5</th>
      <th>c1</th>
      <th>c2</th>
      <th>c3</th>
      <th>c4</th>
      <th>c6</th>
      <th>c7</th>
      <th>c8</th>
      <th>c9</th>
      <th>c10</th>
      <th>c75</th>
      <th>c132</th>
      <th>c134</th>
      <th>c136</th>
      <th>c138</th>
      <th>c139</th>
      <th>c140</th>
      <th>c141</th>
      <th>c144</th>
      <th>c145</th>
      <th>c147</th>
      <th>c149</th>
      <th>c151</th>
      <th>c152</th>
      <th>c153</th>
      <th>c155</th>
      <th>c157</th>
      <th>c160</th>
      <th>c162</th>
      <th>c203</th>
      <th>c204</th>
      <th>c214</th>
      <th>c233</th>
      <th>c234</th>
      <th>c790</th>
      <th>c22</th>
      <th>c23</th>
      <th>c24</th>
      <th>c25</th>
      <th>c26</th>
      <th>c27</th>
      <th>c30</th>
      <th>c31</th>
      <th>c32</th>
      <th>c33</th>
      <th>c34</th>
      <th>c35</th>
      <th>c36</th>
      <th>c37</th>
      <th>c38</th>
      <th>c39</th>
      <th>c11</th>
      <th>c12</th>
      <th>c13</th>
      <th>c14</th>
      <th>c15</th>
      <th>c16</th>
      <th>c17</th>
      <th>c18</th>
      <th>c19</th>
      <th>c20</th>
      <th>c21</th>
      <th>c102</th>
      <th>c104</th>
      <th>c106</th>
      <th>c108</th>
      <th>c110</th>
      <th>c112</th>
      <th>c113</th>
      <th>c114</th>
      <th>c115</th>
      <th>c117</th>
      <th>c118</th>
      <th>c143</th>
      <th>c240</th>
      <th>c241</th>
      <th>c242</th>
      <th>c243</th>
      <th>c61</th>
      <th>c62</th>
      <th>c63</th>
      <th>c64</th>
      <th>c65</th>
      <th>c66</th>
      <th>c67</th>
      <th>c68</th>
      <th>c69</th>
      <th>c70</th>
      <th>c71</th>
      <th>c72</th>
      <th>c73</th>
      <th>c74</th>
      <th>c76</th>
      <th>c250</th>
      <th>c205</th>
      <th>c206</th>
      <th>c207</th>
      <th>c208</th>
      <th>c210</th>
      <th>c41</th>
      <th>c43</th>
      <th>c45</th>
      <th>c47</th>
      <th>c49</th>
      <th>c50</th>
      <th>c52</th>
      <th>c53</th>
      <th>c54</th>
      <th>c55</th>
      <th>c56</th>
      <th>c57</th>
      <th>c58</th>
      <th>c59</th>
      <th>c119</th>
      <th>c120</th>
      <th>c121</th>
      <th>c122</th>
      <th>c126</th>
      <th>c127</th>
      <th>c128</th>
      <th>c129</th>
      <th>c130</th>
      <th>c78</th>
      <th>c80</th>
      <th>c82</th>
      <th>c84</th>
      <th>c86</th>
      <th>c88</th>
      <th>c90</th>
      <th>c92</th>
      <th>c94</th>
      <th>c96</th>
      <th>c98</th>
      <th>c100</th>
      <th>c111</th>
      <th>c123</th>
      <th>c124</th>
      <th>c125</th>
      <th>c184</th>
      <th>c192</th>
      <th>c244</th>
      <th>c40</th>
      <th>c44</th>
      <th>c46</th>
      <th>c48</th>
      <th>c51</th>
      <th>c77</th>
      <th>c79</th>
      <th>c81</th>
      <th>c83</th>
      <th>c85</th>
      <th>c87</th>
      <th>c89</th>
      <th>c91</th>
      <th>c93</th>
      <th>c95</th>
      <th>c97</th>
      <th>c99</th>
      <th>c101</th>
      <th>c103</th>
      <th>c105</th>
      <th>c107</th>
      <th>c109</th>
      <th>c131</th>
      <th>c133</th>
      <th>c135</th>
      <th>c137</th>
      <th>c146</th>
      <th>c148</th>
      <th>c150</th>
      <th>c154</th>
      <th>c156</th>
      <th>c158</th>
      <th>c161</th>
      <th>c163</th>
      <th>c183</th>
      <th>c191</th>
      <th>c229</th>
      <th>c230</th>
      <th>end_of_record</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>20100101025609A</td>
      <td>A</td>
      <td>091</td>
      <td></td>
      <td></td>
      <td>2010</td>
      <td>01</td>
      <td>01</td>
      <td>20100101</td>
      <td>1940</td>
      <td>9</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>NaN</td>
      <td></td>
      <td></td>
      <td></td>
      <td>CV</td>
      <td></td>
      <td></td>
      <td>197646</td>
      <td>02560</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>2028U</td>
      <td>MAULE</td>
      <td>M-4-220C</td>
      <td></td>
      <td></td>
      <td></td>
      <td>STRD</td>
      <td>1599</td>
      <td>*</td>
      <td></td>
      <td>FRANKL</td>
      <td>6V 350 SERIES</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>SW</td>
      <td>SW17</td>
      <td>TX</td>
      <td>PEARSALL</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>3</td>
      <td>2</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>20100706</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>20150131</td>
      <td>01</td>
      <td>N</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>25</td>
      <td>NaN</td>
      <td>13</td>
      <td>300</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>PILOT STATED THAT HE COULD NOT FIND CRYSTAL CI...</td>
      <td>N/A</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>EX</td>
      <td>S</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>PRIVATE PILOT</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Descent</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Wheeled-Conventional</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>NaN</td>
      <td>NaN</td>
      <td></td>
    </tr>
    <tr>
      <th>1</th>
      <td>20100101025799A</td>
      <td>A</td>
      <td>137</td>
      <td></td>
      <td></td>
      <td>2010</td>
      <td>01</td>
      <td>01</td>
      <td>20100101</td>
      <td>1142</td>
      <td>9</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>NaN</td>
      <td></td>
      <td></td>
      <td></td>
      <td>SD</td>
      <td></td>
      <td></td>
      <td>197802</td>
      <td>02579</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>440NR</td>
      <td>HILLER</td>
      <td>UH-12E</td>
      <td></td>
      <td></td>
      <td></td>
      <td>REST</td>
      <td>8000</td>
      <td>*</td>
      <td></td>
      <td>LYCOMI</td>
      <td>VO-540 SERIES</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>WP</td>
      <td>WP17</td>
      <td>CA</td>
      <td>TIPTON</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>20100706</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>20120525</td>
      <td>03</td>
      <td>N</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>5000</td>
      <td>NaN</td>
      <td>100</td>
      <td>13000</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>WEATHER WAS OVERCAST FOR THE FIRST PART OF THE...</td>
      <td>N/A</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>OT</td>
      <td>S</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>COMMERCIAL PILOT</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Other, Specify</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Skids</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>19740916</td>
      <td>NaN</td>
      <td></td>
    </tr>
    <tr>
      <th>2</th>
      <td>20100101025829I</td>
      <td>I</td>
      <td>091</td>
      <td></td>
      <td></td>
      <td>2010</td>
      <td>01</td>
      <td>01</td>
      <td>20100101</td>
      <td>910</td>
      <td>9</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>1H72</td>
      <td>1</td>
      <td>H</td>
      <td>7</td>
      <td>2</td>
      <td>3O</td>
      <td></td>
      <td></td>
      <td>TR</td>
      <td></td>
      <td></td>
      <td>197155</td>
      <td>02582</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>303CP</td>
      <td>CESSNA</td>
      <td>560</td>
      <td></td>
      <td></td>
      <td></td>
      <td>STRD</td>
      <td>NaN</td>
      <td>*</td>
      <td></td>
      <td>P&amp;W CA</td>
      <td>JT15D 5 SER</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>NM</td>
      <td>NM11</td>
      <td>ID</td>
      <td>HAILEY</td>
      <td>FRIEDMAN MEMORIAL</td>
      <td>NaN</td>
      <td>KSUN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>KSUN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>7</td>
      <td>5</td>
      <td>0</td>
      <td>0</td>
      <td>2</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>20100706</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>20150131</td>
      <td>F9</td>
      <td>N</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>376</td>
      <td>NaN</td>
      <td>50</td>
      <td>9208</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>CREW WAS UNAWARE THAT THE GROUND CREW HAD BEGU...</td>
      <td>N/A</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>TX</td>
      <td>M</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>A/LINE TRANSPORT PLT</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Taxi</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>UNDER 12501 LBS</td>
      <td>MONOPLANE-HIGH WING/PARA WING</td>
      <td>POWERED</td>
      <td></td>
      <td></td>
      <td>Wheeled-Tricycle</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>NaN</td>
      <td>NaN</td>
      <td></td>
    </tr>
    <tr>
      <th>3</th>
      <td>20100101030559I</td>
      <td>I</td>
      <td>091</td>
      <td></td>
      <td></td>
      <td>2010</td>
      <td>01</td>
      <td>01</td>
      <td>20100101</td>
      <td>900</td>
      <td>9</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>1L72</td>
      <td>1</td>
      <td>L</td>
      <td>7</td>
      <td>2</td>
      <td>3O</td>
      <td></td>
      <td></td>
      <td>TR</td>
      <td></td>
      <td></td>
      <td>197689</td>
      <td>03055</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>3840X</td>
      <td>BEECH</td>
      <td>58</td>
      <td></td>
      <td></td>
      <td></td>
      <td>STRD</td>
      <td>4310</td>
      <td>*</td>
      <td></td>
      <td>CONT M</td>
      <td>IO 520 SERIES</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>SW</td>
      <td>SW31</td>
      <td>MS</td>
      <td>ROLLING FORK</td>
      <td>NICK'S FLYING SERVICE INC AIRP</td>
      <td>NaN</td>
      <td>04MS</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>04MS</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>20100706</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>20150131</td>
      <td>03</td>
      <td>N</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>0</td>
      <td>NaN</td>
      <td>0</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>FROM PILOT'S STATEMENT;LANDED AT ROLLING FORK ...</td>
      <td>BRUCE WAYNE MILLER</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>TX</td>
      <td>M</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>COMMERCIAL PILOT</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Taxi</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>UNDER 12501 LBS</td>
      <td>MONOPLANE-LOW WING</td>
      <td>POWERED</td>
      <td></td>
      <td></td>
      <td>Wheeled-Tricycle</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>NaN</td>
      <td>NaN</td>
      <td></td>
    </tr>
    <tr>
      <th>4</th>
      <td>20100102026249I</td>
      <td>I</td>
      <td>091</td>
      <td></td>
      <td></td>
      <td>2010</td>
      <td>01</td>
      <td>02</td>
      <td>20100102</td>
      <td>1258</td>
      <td>9</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>NaN</td>
      <td></td>
      <td></td>
      <td></td>
      <td>TR</td>
      <td></td>
      <td></td>
      <td>197712</td>
      <td>02624</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>44730</td>
      <td>PIPER</td>
      <td>PA-34-200T</td>
      <td></td>
      <td></td>
      <td></td>
      <td>STRD</td>
      <td>NaN</td>
      <td>*</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>WP</td>
      <td>WP05</td>
      <td>CA</td>
      <td>TORRANCE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>KTOA</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>KTOA</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>2</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>20100706</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>20120525</td>
      <td>NaN</td>
      <td>N</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>0</td>
      <td>NaN</td>
      <td>0</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>ON JAN 2, 2010 JON MOWATT PNF (PILOT NOT FLYIN...</td>
      <td>N/A</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>32</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>LT</td>
      <td>S</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>3230</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Landing: Touchdown</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Wheeled-Tricycle</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td>NaN</td>
      <td>NaN</td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>




```python
import pandas as pd

pd.reset_option("display.max_columns")
```


```python
df_causefactors.head(5)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>0</th>
      <th>1</th>
      <th>2</th>
      <th>3</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0</td>
      <td>NaN</td>
      <td>UNKNOWN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1</td>
      <td>AA</td>
      <td>FAIL ADVISE UNSAFE APT COND</td>
      <td>APT/COND</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2</td>
      <td>AF</td>
      <td>IMPROPER MAINTENANCE APT FAC</td>
      <td>APT/FAC</td>
    </tr>
    <tr>
      <th>3</th>
      <td>3</td>
      <td>AI</td>
      <td>INADEQUATELY MAINTAIN AWY FAC</td>
      <td>AWY/FAC</td>
    </tr>
    <tr>
      <th>4</th>
      <td>4</td>
      <td>AL</td>
      <td>DIDN'T FLY ASG ALT IFR CLRNS</td>
      <td>ASG/ALT</td>
    </tr>
  </tbody>
</table>
</div>



####3. Departure and Arrival Statistics

For airports LAX, SFO, ATL, MIA, and JFK, determine how many passenger departures and arrivals there were during 2014.


```python
apt = ["LAX", "SFO", "ATL", "MIA", "JFK"]

resultcols = ["Departures", 
              "Arrivals"]

results_df = pd.DataFrame([])

for a in apt:
    departures = df_passenger.loc[df_passenger["orgApt"] == a, "total"].sum()
    arrivals = df_passenger.loc[df_passenger["destApt"] == a, "total"].sum()
    temp_df = pd.DataFrame([[departures, arrivals]], index = [a], columns = resultcols)
    results_df = results_df.append(temp_df)

results_df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Departures</th>
      <th>Arrivals</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>LAX</th>
      <td>18681107</td>
      <td>0</td>
    </tr>
    <tr>
      <th>SFO</th>
      <td>10066556</td>
      <td>0</td>
    </tr>
    <tr>
      <th>ATL</th>
      <td>10583444</td>
      <td>0</td>
    </tr>
    <tr>
      <th>MIA</th>
      <td>20020381</td>
      <td>0</td>
    </tr>
    <tr>
      <th>JFK</th>
      <td>27515961</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>



For airports LAX, SFO, ATL, MIA, and JFK, determine which airline was the largest departure carrier.


```python
apt = ["LAX", "SFO", "ATL", "MIA", "JFK"]

resultcols = ["Carrier", 
              "Departures"]

results_df = pd.DataFrame([])

for a in apt:
    df_temp = df_passenger
    df_temp = df_temp[df_temp["orgApt"] == a] # Return matches for desired airport.
    df_temp = df_temp.groupby(["carrier"])["total"].max() # Group based on max occurrences.
    df_temp = df_temp.sort_values(ascending = False) # Sort by descending occurrences.
    temp_df = pd.DataFrame([[df_temp.index[0], df_temp[0]]], index = [a], columns = resultcols)
    results_df = results_df.append(temp_df)
    
results_df = results_df.sort_values(by = "Departures", ascending = False)
results_df 
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Carrier</th>
      <th>Departures</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>JFK</th>
      <td>BA</td>
      <td>134263</td>
    </tr>
    <tr>
      <th>LAX</th>
      <td>AC</td>
      <td>62504</td>
    </tr>
    <tr>
      <th>ATL</th>
      <td>DL</td>
      <td>55480</td>
    </tr>
    <tr>
      <th>MIA</th>
      <td>AA</td>
      <td>51349</td>
    </tr>
    <tr>
      <th>SFO</th>
      <td>AC</td>
      <td>48917</td>
    </tr>
  </tbody>
</table>
</div>



For airports LAX, SFO, ATL, MIA, and JFK, determine which airline was the the largest arrival carrier.


```python
#Note: No arrivals for each
apt = ["LAX", "SFO", "ATL", "MIA", "JFK"]

resultcols = ["Carrier", 
              "Arrivals"]

results_df = pd.DataFrame([])

for a in apt:
    df_temp = df_passenger
    df_temp = df_temp[df_temp["destApt"] == a] # Return matches for desired airport.
    df_temp = df_temp.groupby(["carrier"])["total"].max() # Group based on max occurrences.
    df_temp = df_temp.sort_values(ascending = False) # Sort by descending occurrences.
    #temp_df = pd.DataFrame([[df_temp.index[0], df_temp[0]]], index = [a], columns = resultcols)
    #results_df = results_df.append(temp_df)

#results_df = results_df.sort_values(by = "Arrivals", ascending = False)
results_df 
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>
</div>



For airports LAX, SFO, ATL, MIA, and JFK, determine what airports the largest number of departures went to.


```python
apt = ["LAX", "SFO", "ATL", "MIA", "JFK"]

resultcols = ["Airport", 
              "Departures"]

results_df = pd.DataFrame([])

for a in apt:
    df_temp = df_passenger
    df_temp = df_temp[df_temp["orgApt"] == a] # Return matches for desired airport.
    df_temp = df_temp.groupby(["destApt"])["total"].sum() # Group based on number of occurrences.
    df_temp = df_temp.sort_values(ascending = False) # Sort by descending count of occurrences.
    temp_df = pd.DataFrame([[df_temp.index[0], df_temp[0]]], index = [a], columns = resultcols)
    results_df = results_df.append(temp_df)

results_df = results_df.sort_values(by = "Departures", ascending = False)
results_df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Airport</th>
      <th>Departures</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>JFK</th>
      <td>LHR</td>
      <td>2892396</td>
    </tr>
    <tr>
      <th>LAX</th>
      <td>LHR</td>
      <td>1428718</td>
    </tr>
    <tr>
      <th>MIA</th>
      <td>GRU</td>
      <td>1039120</td>
    </tr>
    <tr>
      <th>SFO</th>
      <td>LHR</td>
      <td>911760</td>
    </tr>
    <tr>
      <th>ATL</th>
      <td>CUN</td>
      <td>704666</td>
    </tr>
  </tbody>
</table>
</div>



For airports LAX, SFO, ATL, MIA, and JFK, determine what airports the largest number of arrivals were from.


```python
#Note: No arrivals for each
apt = ["LAX", "SFO", "ATL", "MIA", "JFK"]

resultcols = ["Airport", 
              "Arrivals"]

results_df = pd.DataFrame([])

for a in apt:
    df_temp = df_passenger
    df_temp = df_temp[df_temp["destApt"] == a] # Return matches for desired airport.
    df_temp = df_temp.groupby(["orgApt"])["total"].sum() # Group based on number of occurrences.
    df_temp = df_temp.sort_values(ascending = False) # Sort by descending count of occurrences.
    #temp_df = pd.DataFrame([[df_temp.index[0], df_temp[0]]], index = [a], columns = resultcols)
    #results_df = results_df.append(temp_df)

#results_df = results_df.sort_values(by = "Arrivals", ascending = False)
results_df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>
</div>



####4. Accident and Fatality Statistics

For airports LAX, SFO, ATL, MIA, and JFK, determine the number of accidents or incidents that occurred at them between 2010 and 2014 inclusive, according to the FAA.


```python
# c143                           Char               4 Airport identification code of the accident/incident location, if on airport.

apt = ["LAX", "SFO", "ATL", "MIA", "JFK"]

resultcols = ["Incidents"]

results_df = pd.DataFrame([])

for a in apt:
    incidents = len(df_a2010[df_a2010["c143"].str.contains(a, na = False)]) # Return count of matches for desired airport.
    temp_df = pd.DataFrame([[incidents]], index = [a], columns = resultcols) # Create dataframe of match count.
    results_df = results_df.append(temp_df) # Append match count to summary dataframe.

results_df = results_df.sort_values(by = "Incidents", ascending = False)
results_df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Incidents</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>ATL</th>
      <td>28</td>
    </tr>
    <tr>
      <th>LAX</th>
      <td>16</td>
    </tr>
    <tr>
      <th>JFK</th>
      <td>13</td>
    </tr>
    <tr>
      <th>MIA</th>
      <td>10</td>
    </tr>
    <tr>
      <th>SFO</th>
      <td>7</td>
    </tr>
  </tbody>
</table>
</div>



For airports LAX, SFO, ATL, MIA, and JFK, determine the number of deaths that occurred in each event.


```python
# c76                            VarChar            3 Total Fatalities
# c78                            Char               2 Primary cause factor code
# c94                            Char               2 Type of accident code
# c143                           Char               4 Airport identification code of the accident/incident location, if on airport.

import numpy as np

apt = ["LAX", "SFO", "ATL", "MIA", "JFK"]

for a in apt:
    df_temp = df_a2010
    df_temp = df_temp[df_temp["c143"].str.contains(a, na = False)] # Return matches for desired airport.
    df_temp = df_temp[["c78", "c94", "c76"]] # Return relevant dataframe columns (see above).
    df_temp = df_temp.replace({"c78" : {np.NaN : "Unknown", "  " : "Unknown"}}) # Replace NaN and blank values with "Unknown".
    df_temp = df_temp.replace({"c94" : {np.NaN : "Unknown", "  " : "Unknown"}}) 
    df_temp.index.name = None
    df_temp.columns = ["causefactorCode", "accidentCode", "fatalities"]
    print(a, df_temp)
    print("")
```

    LAX       causefactorCode accidentCode  fatalities
    312           Unknown      Unknown           0
    706           Unknown      Unknown           0
    1475          Unknown      Unknown           0
    1630               55      Unknown           0
    2151          Unknown      Unknown           0
    2498          Unknown      Unknown           0
    2857          Unknown      Unknown           0
    3847          Unknown      Unknown           0
    5184          Unknown      Unknown           0
    5264               32      Unknown           0
    5615          Unknown      Unknown           0
    5968               32      Unknown           0
    6450          Unknown      Unknown           0
    7764          Unknown      Unknown           0
    9358          Unknown      Unknown           0
    10495         Unknown      Unknown           0
    
    SFO       causefactorCode accidentCode  fatalities
    1721          Unknown      Unknown           0
    1892          Unknown      Unknown           0
    1954               71      Unknown           0
    3150               57      Unknown           0
    4208          Unknown      Unknown           0
    5324               32      Unknown           0
    10842         Unknown      Unknown           3
    
    ATL       causefactorCode accidentCode  fatalities
    7             Unknown      Unknown           0
    25            Unknown      Unknown           0
    42            Unknown      Unknown           0
    95            Unknown      Unknown           0
    152           Unknown      Unknown           0
    159           Unknown      Unknown           0
    173           Unknown      Unknown           0
    210           Unknown      Unknown           0
    220           Unknown      Unknown           0
    223                78      Unknown           0
    242           Unknown      Unknown           0
    245           Unknown      Unknown           0
    283           Unknown      Unknown           0
    458           Unknown      Unknown           0
    501           Unknown      Unknown           0
    847                32      Unknown           0
    848           Unknown      Unknown           0
    2280          Unknown      Unknown           0
    2631          Unknown      Unknown           0
    3294          Unknown      Unknown           0
    3948          Unknown      Unknown           0
    4073          Unknown      Unknown           0
    4257          Unknown      Unknown           0
    5401               75      Unknown           0
    6177          Unknown      Unknown           0
    9593               14      Unknown           0
    9636          Unknown      Unknown           0
    10459         Unknown      Unknown           0
    
    MIA      causefactorCode accidentCode  fatalities
    43           Unknown      Unknown           0
    875          Unknown      Unknown           0
    2367         Unknown      Unknown           0
    2466         Unknown      Unknown           0
    2597         Unknown      Unknown           0
    3433         Unknown      Unknown           0
    3517         Unknown      Unknown           0
    4158         Unknown      Unknown           0
    4600              24      Unknown           0
    8552              54      Unknown           0
    
    JFK       causefactorCode accidentCode  fatalities
    1557          Unknown      Unknown           0
    1848          Unknown      Unknown           0
    2081          Unknown      Unknown           0
    3489          Unknown      Unknown           0
    3493          Unknown      Unknown           0
    3698          Unknown      Unknown           0
    6538          Unknown      Unknown           0
    7777          Unknown      Unknown           0
    8819          Unknown      Unknown           0
    8927          Unknown      Unknown           0
    9037          Unknown      Unknown           0
    9649          Unknown      Unknown           0
    10646         Unknown      Unknown           0
    
    

For airports LAX, SFO, ATL, MIA, and JFK, determine what the top ten (primary) causes of 2010-2014 incidents and accidents are for all events resulting in deaths regardless of where they occurred. Provide descriptions (not codes) for the causes.


```python
import numpy as np

df_a2010 = df_a2010.replace({"c78" : {np.NaN : 0,
                                      "  " : 0}}) # Replace NaN's and blanks within cause factor code column with zero digit.
df_a2010["c78"] = df_a2010["c78"].astype(int) # Convert cause factor code column to integer type.
df_causefactors = df_causefactors[[0, 2]] # Define relevant columns of cause factor code description dataframe.
causedict = df_causefactors.set_index(0).to_dict() # Convert cause factor code description dataframe to dictonary.
```


```python
# c76                            VarChar            3 Total Fatalities
# c78                            Char               2 Primary cause factor code
# c143                           Char               4 Airport identification code of the accident/incident location, if on airport.

import numpy as np

apt = ["LAX", "SFO", "ATL", "MIA", "JFK"]

for a in apt:
    df_temp = df_a2010
    df_temp = df_temp[df_temp["c143"].str.contains(a, na = False)] # Return matches for desired airport.
    df_temp = df_temp[["c78", "c76"]] # Return relevant dataframe columns (see above).
    df_temp = df_temp.replace({"c78" : causedict[2]}) # Replace cause factor code values based on dictonary of descriptions.
    df_temp = df_temp.groupby(["c78"]).sum() # Group based on number of occurrences.
    df_temp = df_temp.sort_values(by = "c76", ascending = False) # Sort by descending count of occurrences.
    df_temp.columns = ["fatalities"]
    df_temp.index.name = None
    print(a, df_temp[0:10])
    print("")
```

    LAX                                 fatalities
    IMPROPER MGT/FUEL TANK SELECTO           0
    INADEQ SPACE AC/WKE TURBULENCE           0
    UNKNOWN                                  0
    
    SFO                                 fatalities
    UNKNOWN                                  3
    AEROBATICS BELOW SAFE ALTITUDE           0
    IMPROPER MGT/FUEL TANK SELECTO           0
    IMPROPER OPERATION OF FAC                0
    
    ATL                                 fatalities
    FAIL TO ATTAIN PROPER OP TEMP            0
    IMPROPER MGT/FUEL TANK SELECTO           0
    ISSUED IMPR CONFLICTING INSTS            0
    PILOT INCAP EXCLUDES ALCOHOL             0
    UNKNOWN                                  0
    
    MIA                                 fatalities
    IMPROPER INST PROC T/O LDG               0
    STARTED ENG W/OUT ASSIST/EQUIP           0
    UNKNOWN                                  0
    
    JFK          fatalities
    UNKNOWN           0
    
    
