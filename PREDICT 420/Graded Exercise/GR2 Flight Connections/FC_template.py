
# coding: utf-8

# #MSPA PREDICT 420

# ##Graded Exercise 2: Flight Connections

# ###Introduction

# This document presents the results of the second graded exercise for the Masters of Science in Predictive Analytics course: PREDICT 420. This assessment required the student to perform some data wrangling exercises on airline/flight data retrieved from [OpenFlights.org](http://www.openflights.org).

# ###Assessment

# ####1. Loading the Data

# Load datasets into pandas dataframes.

# In[1]:

import pandas as pd
import pickle

df_airlines = pd.read_pickle("data/airlines.p")
df_airports = pd.read_pickle("data/airports.p")
df_routes = pd.read_pickle("data/routes.p")


# ####2. Remove Duplicate Records

# Find duplicate records within the 'airlines' dataframe.

# In[2]:

#Duplicate airline records: 1
df_airlines['Duplicate'] = df_airlines.duplicated(["airlName",
                                                   "airlIATA",
                                                   "airlICAO"])


# Count the number of duplicate records within the 'airlines' dataframe.

# In[3]:

duplicate_airlines_count = len(df_airlines[df_airlines.Duplicate == True])
print("Duplicate airline records:", duplicate_airlines_count)


# Find duplicate records within the 'airports' dataframe.

# In[4]:

#Duplicate airports records: 54
df_airports["Duplicate"] = df_airports.duplicated(["airpName",
                                                   "airpCity",
                                                   "airpCountry",
                                                   "airpIATAFAA",
                                                   "airpICAO"])


# Count the number of duplicate records within the 'airports' dataframe.

# In[5]:

duplicate_airports_count = len(df_airports[df_airports.Duplicate == True])
print("Duplicate airports records:", duplicate_airports_count)


# Find duplicate records within the 'routes' dataframe.

# In[6]:

#Duplicate routes records: 0
df_routes["Duplicate"] = df_routes.duplicated(["airlName",
                                               "sourceAirpName",
                                               "sourceAirpID",
                                               "destAirpName",
                                               "destAirpID"])


# Count the number of duplicate records within the 'routes' dataframe.

# In[7]:

duplicate_routes_count = len(df_routes[df_routes.Duplicate == True])
print("Duplicate routes records:", duplicate_routes_count)


# Eliminate duplicate records from each dataframe.

# In[8]:

df_airlines = df_airlines[df_airlines.Duplicate == False]
df_airports = df_airports[df_airports.Duplicate == False]
df_routes = df_routes[df_routes.Duplicate == False]


# ####3. Print DataTypes for each Dataframe Column

# Create reference table for datatypes and print data types for each column of each dataframe.

# In[9]:

#Source: https://en.wikibooks.org/wiki/Python_Programming/Data_Types
import pandas as pd

df_datatypes = pd.read_csv("data/datatypes.csv")
df_datatypes


# In[10]:

print(df_airlines.drop('Duplicate', 1).dtypes)


# In[11]:

print(df_airports.drop('Duplicate', 1).dtypes)


# In[12]:

print(df_routes.drop('Duplicate', 1).dtypes)


# ####4. Print First 10 Values of the Row Index for each Dataframe

# In[13]:

print(df_airlines.index[0:10]) #Index values
df_airlines[0:10] #Row values


# In[14]:

print(df_airports.index[0:10]) #Index values
df_airports[0:10] #Row values


# In[15]:

print(df_routes.index[0:10]) #Index values
df_routes[0:10] #Row values


# ####5. Remove Defunct Records from Airlines Dataframe

# Count the number of records within the 'airlines' dataframe.

# In[16]:

airlines_count = len(df_airlines)
print("Number of airline records:", airlines_count)


# Count the number of defunct records within the 'airlines' dataframe.

# In[17]:

defunct_airlines_count = len(df_airlines[df_airlines.airlActive == "N"])
print("Number of defunct airline records:", defunct_airlines_count)


# Remove defunct records from the 'airlines' dataframe.

# In[18]:

df_airlines = df_airlines[df_airlines.airlActive == "Y"]


# ####6. Remove 'Flights from Nowhere' Records from Routes Dataframe

# Count the number of records within the 'routes' dataframe.

# In[19]:

routes_count = len(df_routes)
print("Number of routes records:", routes_count)


# Find all 'sourceAirpName' records within the 'routes' dataframe which do not appear within 'airpIATAFAA' records within the 'airports' dataframe. 

# In[20]:

df_routes["Matched"] = df_routes["sourceAirpName"].isin(df_airports["airpIATAFAA"])


# Count the number of 'flights from nowhere' records within the 'routes' dataframe.

# In[21]:

nowhere_routes_count = len(df_routes[df_routes.Matched == False])
print("Number of flights from nowhere routes records:", nowhere_routes_count)


# Remove 'flights from nowhere' records within the 'routes' dataframe.

# In[22]:

df_routes = df_routes[df_routes.Matched == True]


# ####7. Pickle Final Dataframes.

# In[23]:

import pickle

#df_airlines.to_pickle("data/airlines.p")
#df_airports.to_pickle("data/airports.p")
#df_routes.to_pickle("data/routes.p")


# ####8. Find the 10 Longest Flight Routes from Chicago O'Hare

# Import 'distance_on_unit_sphere' function to calculate distance between two latitude/longitude pairs.

# In[24]:

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


# Find the latitude/longitude pair for Chicago O'Hare

# In[25]:

df_chicagoohare = df_airports[df_airports.airpName == "Chicago Ohare Intl"]

chicagoohare_lat = df_chicagoohare.airpLat
chicagoohare_long = df_chicagoohare.airpLong


# Apply 'distance_on_unit_sphere' function to each airport within the df_airports dataframe, in order to find the distance between each airport and 'Chicago O'Hare'.

# In[26]:

import numpy as np

df_airports["distToChicago"] = np.vectorize(distance_on_unit_sphere)(df_airports["airpLat"], 
                                                                       df_airports["airpLong"], 
                                                                       chicagoohare_lat, 
                                                                       chicagoohare_long)


# Return the 10 airports which maximize distance to 'Chicago O'Hare' (distance in kilometres).

# In[27]:

df_airports_distochicagoasc = df_airports.sort_values(by = "distToChicago", ascending = False)[:10]
df_airports_distochicagoasc[["airpName", "distToChicago"]]

