
#MSPA PREDICT 420

##Graded Exercise 1: Flying Around

###Introduction

This document presents the results of first graded exercise for the Masters of Science in Predictive Analytics course: PREDICT 420. This assessment required the student to perform some data wrangling exercises on airline/flight data retrieved from [OpenFlights.org](http://www.openflights.org).

###Assessment

####1. Loading the Data

Load datasets into pandas dataframes.


```python
import pandas as pd    

df_airlines = pd.read_csv("data/airlines.dat", header = None, encoding = "latin-1")
df_airports = pd.read_csv("data/airports.dat", header = None, encoding = "latin-1")
df_routes = pd.read_csv("data/routes.dat", header = None, encoding = "latin-1")
```

####2. Pre-process the Data

Import field names for each dataframe as lists from relevant text files.


```python
import csv

f = open("data/airlines_fields.txt", "r")
reader = csv.reader(f)
airlines_fields = list(reader)

f = open("data/airports_fields.txt", "r")
reader = csv.reader(f)
airports_fields = list(reader)

f = open("data/routes_fields.txt", "r")
reader = csv.reader(f)
routes_fields = list(reader)
```

Show each of the imported field name lists.


```python
airlines_fields
```




    [['airlID',
      'airlName',
      'airlAlias',
      'airlIATA',
      'airlICAO',
      'airlCallsign',
      'airlCountry',
      'airlActive']]




```python
airports_fields
```




    [['airpID',
      'airpName',
      'airpCity',
      'airpCountry',
      'airpIATAFAA',
      'airpICAO',
      'airpLat',
      'airpLong',
      'airpAlt',
      'airpTimezone',
      'airpDST',
      'airpTz']]




```python
routes_fields
```




    [['airlName',
      'airlID',
      'sourceAirpName',
      'sourceAirpID',
      'destAirpName',
      'destAirpID',
      'airlCodeshare',
      'airlStops',
      'airlEquip']]



Use the imported field name lists to set column names for each dataframe.


```python
df_airlines.columns = airlines_fields
df_airports.columns = airports_fields
df_routes.columns = routes_fields
```

Show first three rows of each dataframe.


```python
df_airlines.head(3)
```




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
    </tr>
  </tbody>
</table>
</div>




```python
df_airports.head(3)
```




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
    </tr>
  </tbody>
</table>
</div>




```python
df_routes.head(3)
```




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
    </tr>
  </tbody>
</table>
</div>



Pickle final dataframes, then re-read.


```python
import pickle

df_airlines.to_pickle('data/airlines.p')
df_airports.to_pickle('data/airports.p')
df_routes.to_pickle('data/routes.p')

df_airlines = pd.read_pickle("data/airlines.p")
df_airports = pd.read_pickle("data/airports.p")
df_routes = pd.read_pickle("data/routes.p")
```

####3. What is three letter airport code for the airport that is closest to your home?

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

Apply 'distance_on_unit_sphere' function to each airport within the df_airports dataframe, in order to find the distance between each airport and my hometown 'Rivervale, Western Australia' (latitude -31.9610 and longitude 115.9170).


```python
import numpy as np

rivervale_lat = -31.9610
rivervale_long = 115.9170

df_airports["distToRivervale"] = np.vectorize(distance_on_unit_sphere)(df_airports["airpLat"], 
                                                                       df_airports["airpLong"], 
                                                                       rivervale_lat, 
                                                                       rivervale_long)

min_rivervale_row_index = df_airports["distToRivervale"].idxmin()
```

Return the airport which minimizes the distance to my hometown.


```python
min_rivervale_airport_name = df_airports["airpName"].iloc[min_rivervale_row_index]
min_rivervale_airport_name
```




    'Perth Intl'



Return the airport code associated with 'Perth Intl'.


```python
min_rivervale_airport_code = df_airports["airpIATAFAA"].iloc[min_rivervale_row_index]
print("Three letter airport code for the airport closest to my home:", min_rivervale_airport_code)
```

    Three letter airport code for the airport closest to my home: PER
    

####4. How many departing routes are there from this airport?

Create a new dataframe based on matches of original 'df_routes' dataframe where 'Source_airport' is equal to 'PER'.


```python
min_rivervale_airport_routes = df_routes[df_routes.sourceAirpName == min_rivervale_airport_code]
```

Count rows of matched dataframe.


```python
min_rivervale_routes_count = len(min_rivervale_airport_routes.index)
print("Number of departing routes from PER:", min_rivervale_routes_count)
```

    Number of departing routes from PER: 92
    

####5. How many routes are there coming into the airport with the three letter code "EGO?"

Create a new dataframe based on matches of original 'df_routes' dataframe where 'Source_airport' is equal to 'EGO'.


```python
ego_airport_routes = df_routes[df_routes.destAirpName == "EGO"]
```

Count rows of matched dataframe.


```python
ego_airport_routes_count = len(ego_airport_routes.index)
print("Number of arriving routes at EGO:", ego_airport_routes_count)
```

    Number of arriving routes at EGO: 11
    
