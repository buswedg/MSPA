
#MSPA PREDICT 420

##Graded Exercise 2: Flight Connections

###Introduction

This document presents the results of the second graded exercise for the Masters of Science in Predictive Analytics course: PREDICT 420. This assessment required the student to perform some data wrangling exercises on airline/flight data retrieved from [OpenFlights.org](http://www.openflights.org).

###Assessment

####1. Loading the Data

Load datasets into pandas dataframes.


```python
import pandas as pd
import pickle

df_airlines = pd.read_pickle("data/airlines.p")
df_airports = pd.read_pickle("data/airports.p")
df_routes = pd.read_pickle("data/routes.p")
```

####2. Remove Duplicate Records

Find duplicate records within the 'airlines' dataframe.


```python
#Duplicate airline records: 1
df_airlines['Duplicate'] = df_airlines.duplicated(["airlName",
                                                   "airlIATA",
                                                   "airlICAO"])
```

Count the number of duplicate records within the 'airlines' dataframe.


```python
duplicate_airlines_count = len(df_airlines[df_airlines.Duplicate == True])
print("Duplicate airline records:", duplicate_airlines_count)
```

    Duplicate airline records: 1
    

Find duplicate records within the 'airports' dataframe.


```python
#Duplicate airports records: 54
df_airports["Duplicate"] = df_airports.duplicated(["airpName",
                                                   "airpCity",
                                                   "airpCountry",
                                                   "airpIATAFAA",
                                                   "airpICAO"])
```

Count the number of duplicate records within the 'airports' dataframe.


```python
duplicate_airports_count = len(df_airports[df_airports.Duplicate == True])
print("Duplicate airports records:", duplicate_airports_count)
```

    Duplicate airports records: 54
    

Find duplicate records within the 'routes' dataframe.


```python
#Duplicate routes records: 0
df_routes["Duplicate"] = df_routes.duplicated(["airlName",
                                               "sourceAirpName",
                                               "sourceAirpID",
                                               "destAirpName",
                                               "destAirpID"])
```

Count the number of duplicate records within the 'routes' dataframe.


```python
duplicate_routes_count = len(df_routes[df_routes.Duplicate == True])
print("Duplicate routes records:", duplicate_routes_count)
```

    Duplicate routes records: 0
    

Eliminate duplicate records from each dataframe.


```python
df_airlines = df_airlines[df_airlines.Duplicate == False]
df_airports = df_airports[df_airports.Duplicate == False]
df_routes = df_routes[df_routes.Duplicate == False]
```

####3. Print DataTypes for each Dataframe Column

Create reference table for datatypes and print data types for each column of each dataframe.


```python
#Source: https://en.wikibooks.org/wiki/Python_Programming/Data_Types
import pandas as pd

df_datatypes = pd.read_csv("data/datatypes.csv")
df_datatypes
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Native Data Type</th>
      <th>Pandas Data Type</th>
      <th>Class</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>int</td>
      <td>int64</td>
      <td>Numeric types</td>
      <td>Integers</td>
    </tr>
    <tr>
      <th>1</th>
      <td>float</td>
      <td>float64</td>
      <td>Numeric types</td>
      <td>Floating-point numbers</td>
    </tr>
    <tr>
      <th>2</th>
      <td>str</td>
      <td>object</td>
      <td>Sequences</td>
      <td>String</td>
    </tr>
  </tbody>
</table>
</div>




```python
print(df_airlines.drop('Duplicate', 1).dtypes)
```

    airlID           int64
    airlName        object
    airlAlias       object
    airlIATA        object
    airlICAO        object
    airlCallsign    object
    airlCountry     object
    airlActive      object
    dtype: object
    


```python
print(df_airports.drop('Duplicate', 1).dtypes)
```

    airpID            int64
    airpName         object
    airpCity         object
    airpCountry      object
    airpIATAFAA      object
    airpICAO         object
    airpLat         float64
    airpLong        float64
    airpAlt           int64
    airpTimezone    float64
    airpDST          object
    airpTz           object
    dtype: object
    


```python
print(df_routes.drop('Duplicate', 1).dtypes)
```

    airlName          object
    airlID            object
    sourceAirpName    object
    sourceAirpID      object
    destAirpName      object
    destAirpID        object
    airlCodeshare     object
    airlStops          int64
    airlEquip         object
    dtype: object
    

####4. Print First 10 Values of the Row Index for each Dataframe


```python
print(df_airlines.index[0:10]) #Index values
df_airlines[0:10] #Row values
```

    Int64Index([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], dtype='int64')
    




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>airlID</th>
      <th>airlName</th>
      <th>airlAlias</th>
      <th>airlIATA</th>
      <th>airlICAO</th>
      <th>airlCallsign</th>
      <th>airlCountry</th>
      <th>airlActive</th>
      <th>Duplicate</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>Private flight</td>
      <td>\N</td>
      <td>-</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>Y</td>
      <td>False</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>135 Airways</td>
      <td>\N</td>
      <td>NaN</td>
      <td>GNL</td>
      <td>GENERAL</td>
      <td>United States</td>
      <td>N</td>
      <td>False</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>1Time Airline</td>
      <td>\N</td>
      <td>1T</td>
      <td>RNX</td>
      <td>NEXTIME</td>
      <td>South Africa</td>
      <td>Y</td>
      <td>False</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>2 Sqn No 1 Elementary Flying Training School</td>
      <td>\N</td>
      <td>NaN</td>
      <td>WYT</td>
      <td>NaN</td>
      <td>United Kingdom</td>
      <td>N</td>
      <td>False</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>213 Flight Unit</td>
      <td>\N</td>
      <td>NaN</td>
      <td>TFU</td>
      <td>NaN</td>
      <td>Russia</td>
      <td>N</td>
      <td>False</td>
    </tr>
    <tr>
      <th>5</th>
      <td>6</td>
      <td>223 Flight Unit State Airline</td>
      <td>\N</td>
      <td>NaN</td>
      <td>CHD</td>
      <td>CHKALOVSK-AVIA</td>
      <td>Russia</td>
      <td>N</td>
      <td>False</td>
    </tr>
    <tr>
      <th>6</th>
      <td>7</td>
      <td>224th Flight Unit</td>
      <td>\N</td>
      <td>NaN</td>
      <td>TTF</td>
      <td>CARGO UNIT</td>
      <td>Russia</td>
      <td>N</td>
      <td>False</td>
    </tr>
    <tr>
      <th>7</th>
      <td>8</td>
      <td>247 Jet Ltd</td>
      <td>\N</td>
      <td>NaN</td>
      <td>TWF</td>
      <td>CLOUD RUNNER</td>
      <td>United Kingdom</td>
      <td>N</td>
      <td>False</td>
    </tr>
    <tr>
      <th>8</th>
      <td>9</td>
      <td>3D Aviation</td>
      <td>\N</td>
      <td>NaN</td>
      <td>SEC</td>
      <td>SECUREX</td>
      <td>United States</td>
      <td>N</td>
      <td>False</td>
    </tr>
    <tr>
      <th>9</th>
      <td>10</td>
      <td>40-Mile Air</td>
      <td>\N</td>
      <td>Q5</td>
      <td>MLA</td>
      <td>MILE-AIR</td>
      <td>United States</td>
      <td>Y</td>
      <td>False</td>
    </tr>
  </tbody>
</table>
</div>




```python
print(df_airports.index[0:10]) #Index values
df_airports[0:10] #Row values
```

    Int64Index([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], dtype='int64')
    




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>airpID</th>
      <th>airpName</th>
      <th>airpCity</th>
      <th>airpCountry</th>
      <th>airpIATAFAA</th>
      <th>airpICAO</th>
      <th>airpLat</th>
      <th>airpLong</th>
      <th>airpAlt</th>
      <th>airpTimezone</th>
      <th>airpDST</th>
      <th>airpTz</th>
      <th>Duplicate</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>Goroka</td>
      <td>Goroka</td>
      <td>Papua New Guinea</td>
      <td>GKA</td>
      <td>AYGA</td>
      <td>-6.081689</td>
      <td>145.391881</td>
      <td>5282</td>
      <td>10</td>
      <td>U</td>
      <td>Pacific/Port_Moresby</td>
      <td>False</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>Madang</td>
      <td>Madang</td>
      <td>Papua New Guinea</td>
      <td>MAG</td>
      <td>AYMD</td>
      <td>-5.207083</td>
      <td>145.788700</td>
      <td>20</td>
      <td>10</td>
      <td>U</td>
      <td>Pacific/Port_Moresby</td>
      <td>False</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>Mount Hagen</td>
      <td>Mount Hagen</td>
      <td>Papua New Guinea</td>
      <td>HGU</td>
      <td>AYMH</td>
      <td>-5.826789</td>
      <td>144.295861</td>
      <td>5388</td>
      <td>10</td>
      <td>U</td>
      <td>Pacific/Port_Moresby</td>
      <td>False</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>Nadzab</td>
      <td>Nadzab</td>
      <td>Papua New Guinea</td>
      <td>LAE</td>
      <td>AYNZ</td>
      <td>-6.569828</td>
      <td>146.726242</td>
      <td>239</td>
      <td>10</td>
      <td>U</td>
      <td>Pacific/Port_Moresby</td>
      <td>False</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>Port Moresby Jacksons Intl</td>
      <td>Port Moresby</td>
      <td>Papua New Guinea</td>
      <td>POM</td>
      <td>AYPY</td>
      <td>-9.443383</td>
      <td>147.220050</td>
      <td>146</td>
      <td>10</td>
      <td>U</td>
      <td>Pacific/Port_Moresby</td>
      <td>False</td>
    </tr>
    <tr>
      <th>5</th>
      <td>6</td>
      <td>Wewak Intl</td>
      <td>Wewak</td>
      <td>Papua New Guinea</td>
      <td>WWK</td>
      <td>AYWK</td>
      <td>-3.583828</td>
      <td>143.669186</td>
      <td>19</td>
      <td>10</td>
      <td>U</td>
      <td>Pacific/Port_Moresby</td>
      <td>False</td>
    </tr>
    <tr>
      <th>6</th>
      <td>7</td>
      <td>Narsarsuaq</td>
      <td>Narssarssuaq</td>
      <td>Greenland</td>
      <td>UAK</td>
      <td>BGBW</td>
      <td>61.160517</td>
      <td>-45.425978</td>
      <td>112</td>
      <td>-3</td>
      <td>E</td>
      <td>America/Godthab</td>
      <td>False</td>
    </tr>
    <tr>
      <th>7</th>
      <td>8</td>
      <td>Nuuk</td>
      <td>Godthaab</td>
      <td>Greenland</td>
      <td>GOH</td>
      <td>BGGH</td>
      <td>64.190922</td>
      <td>-51.678064</td>
      <td>283</td>
      <td>-3</td>
      <td>E</td>
      <td>America/Godthab</td>
      <td>False</td>
    </tr>
    <tr>
      <th>8</th>
      <td>9</td>
      <td>Sondre Stromfjord</td>
      <td>Sondrestrom</td>
      <td>Greenland</td>
      <td>SFJ</td>
      <td>BGSF</td>
      <td>67.016969</td>
      <td>-50.689325</td>
      <td>165</td>
      <td>-3</td>
      <td>E</td>
      <td>America/Godthab</td>
      <td>False</td>
    </tr>
    <tr>
      <th>9</th>
      <td>10</td>
      <td>Thule Air Base</td>
      <td>Thule</td>
      <td>Greenland</td>
      <td>THU</td>
      <td>BGTL</td>
      <td>76.531203</td>
      <td>-68.703161</td>
      <td>251</td>
      <td>-4</td>
      <td>E</td>
      <td>America/Thule</td>
      <td>False</td>
    </tr>
  </tbody>
</table>
</div>




```python
print(df_routes.index[0:10]) #Index values
df_routes[0:10] #Row values
```

    Int64Index([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], dtype='int64')
    




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>airlName</th>
      <th>airlID</th>
      <th>sourceAirpName</th>
      <th>sourceAirpID</th>
      <th>destAirpName</th>
      <th>destAirpID</th>
      <th>airlCodeshare</th>
      <th>airlStops</th>
      <th>airlEquip</th>
      <th>Duplicate</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2B</td>
      <td>410</td>
      <td>AER</td>
      <td>2965</td>
      <td>KZN</td>
      <td>2990</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2B</td>
      <td>410</td>
      <td>ASF</td>
      <td>2966</td>
      <td>KZN</td>
      <td>2990</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2B</td>
      <td>410</td>
      <td>ASF</td>
      <td>2966</td>
      <td>MRV</td>
      <td>2962</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2B</td>
      <td>410</td>
      <td>CEK</td>
      <td>2968</td>
      <td>KZN</td>
      <td>2990</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2B</td>
      <td>410</td>
      <td>CEK</td>
      <td>2968</td>
      <td>OVB</td>
      <td>4078</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>5</th>
      <td>2B</td>
      <td>410</td>
      <td>DME</td>
      <td>4029</td>
      <td>KZN</td>
      <td>2990</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>6</th>
      <td>2B</td>
      <td>410</td>
      <td>DME</td>
      <td>4029</td>
      <td>NBC</td>
      <td>6969</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>7</th>
      <td>2B</td>
      <td>410</td>
      <td>DME</td>
      <td>4029</td>
      <td>TGK</td>
      <td>\N</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>8</th>
      <td>2B</td>
      <td>410</td>
      <td>DME</td>
      <td>4029</td>
      <td>UUA</td>
      <td>6160</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
    <tr>
      <th>9</th>
      <td>2B</td>
      <td>410</td>
      <td>EGO</td>
      <td>6156</td>
      <td>KGD</td>
      <td>2952</td>
      <td>NaN</td>
      <td>0</td>
      <td>CR2</td>
      <td>False</td>
    </tr>
  </tbody>
</table>
</div>



####5. Remove Defunct Records from Airlines Dataframe

Count the number of records within the 'airlines' dataframe.


```python
airlines_count = len(df_airlines)
print("Number of airline records:", airlines_count)
```

    Number of airline records: 6047
    

Count the number of defunct records within the 'airlines' dataframe.


```python
defunct_airlines_count = len(df_airlines[df_airlines.airlActive == "N"])
print("Number of defunct airline records:", defunct_airlines_count)
```

    Number of defunct airline records: 4885
    

Remove defunct records from the 'airlines' dataframe.


```python
df_airlines = df_airlines[df_airlines.airlActive == "Y"]
```

####6. Remove 'Flights from Nowhere' Records from Routes Dataframe

Count the number of records within the 'routes' dataframe.


```python
routes_count = len(df_routes)
print("Number of routes records:", routes_count)
```

    Number of routes records: 67663
    

Find all 'sourceAirpName' records within the 'routes' dataframe which do not appear within 'airpIATAFAA' records within the 'airports' dataframe. 


```python
df_routes["Matched"] = df_routes["sourceAirpName"].isin(df_airports["airpIATAFAA"])
```

Count the number of 'flights from nowhere' records within the 'routes' dataframe.


```python
nowhere_routes_count = len(df_routes[df_routes.Matched == False])
print("Number of flights from nowhere routes records:", nowhere_routes_count)
```

    Number of flights from nowhere routes records: 235
    

Remove 'flights from nowhere' records within the 'routes' dataframe.


```python
df_routes = df_routes[df_routes.Matched == True]
```

####7. Pickle Final Dataframes.


```python
import pickle

#df_airlines.to_pickle("data/airlines.p")
#df_airports.to_pickle("data/airports.p")
#df_routes.to_pickle("data/routes.p")
```

####8. Find the 10 Longest Flight Routes from Chicago O'Hare

Import 'distance_on_unit_sphere' function to calculate distance between two latitude/longitude pairs.


```python
#Source: http://www.johndcook.com/blog/python_longitude_latitude/
import math

def distance_on_unit_sphere(lat1, long1, lat2, long2):
    degrees_to_radians = math.pi/180.0
    phi1 = (90.0 - lat1)*degrees_to_radians
    phi2 = (90.0 - lat2)*degrees_to_radians
    theta1 = long1*degrees_to_radians
    theta2 = long2*degrees_to_radians
    
    cos = (math.sin(phi1)*math.sin(phi2)*math.cos(theta1 - theta2) + 
           math.cos(phi1)*math.cos(phi2))
    arc = math.acos( cos )
    
    return arc*6373
```

Find the latitude/longitude pair for Chicago O'Hare


```python
df_chicagoohare = df_airports[df_airports.airpName == "Chicago Ohare Intl"]

chicagoohare_lat = df_chicagoohare.airpLat
chicagoohare_long = df_chicagoohare.airpLong
```

Apply 'distance_on_unit_sphere' function to each airport within the df_airports dataframe, in order to find the distance between each airport and 'Chicago O'Hare'.


```python
import numpy as np

df_airports["distToChicago"] = np.vectorize(distance_on_unit_sphere)(df_airports["airpLat"], 
                                                                       df_airports["airpLong"], 
                                                                       chicagoohare_lat, 
                                                                       chicagoohare_long)
```

Return the 10 airports which maximize distance to 'Chicago O'Hare' (distance in kilometres).


```python
df_airports_distochicagoasc = df_airports.sort_values(by = "distToChicago", ascending = False)[:10]
df_airports_distochicagoasc[["airpName", "distToChicago"]]
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>airpName</th>
      <th>distToChicago</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>7655</th>
      <td>Brusselton</td>
      <td>17785.379366</td>
    </tr>
    <tr>
      <th>6923</th>
      <td>Rottnest Island</td>
      <td>17672.610324</td>
    </tr>
    <tr>
      <th>5108</th>
      <td>Albany Airport</td>
      <td>17659.811127</td>
    </tr>
    <tr>
      <th>3248</th>
      <td>Perth Jandakot</td>
      <td>17651.854742</td>
    </tr>
    <tr>
      <th>6418</th>
      <td>Burswood Park Helipad</td>
      <td>17644.395508</td>
    </tr>
    <tr>
      <th>3255</th>
      <td>Perth Intl</td>
      <td>17635.275374</td>
    </tr>
    <tr>
      <th>5416</th>
      <td>RAAF Pearce</td>
      <td>17614.200347</td>
    </tr>
    <tr>
      <th>6922</th>
      <td>Cunderdin</td>
      <td>17517.892454</td>
    </tr>
    <tr>
      <th>5141</th>
      <td>Geraldton Airport</td>
      <td>17513.563857</td>
    </tr>
    <tr>
      <th>5150</th>
      <td>Kalbarri Airport</td>
      <td>17461.577215</td>
    </tr>
  </tbody>
</table>
</div>


