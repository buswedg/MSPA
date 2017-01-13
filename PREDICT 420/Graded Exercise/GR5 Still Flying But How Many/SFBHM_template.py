
# coding: utf-8

# #MSPA PREDICT 420

# ##Graded Exercise 5: Still Flying But How Many

# ###Introduction

# This document presents the results of the forth graded exercise for the Masters of Science in Predictive Analytics course: PREDICT 420.

# ###Assessment

# ####1. Loading the Data

# Load datasets into pandas dataframes.

# In[1]:

import pandas as pd

df_passenger = pd.read_csv("data/2014+CY-YTD+Passenger+Raw+Data_2-1.csv", skiprows = [0], thousands = ",")
df_a2010 = pd.read_table("data/A2010_14.txt", encoding = "latin-1")
df_causefactors = pd.read_table("data/causefactors.txt", header = None)


# ####2. Pre-process the Data

# Set field names for 'passenger' dataframe.

# In[2]:

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


# Confirm dtypes for 'passenger' dataframe fields.

# In[3]:

print(df_passenger.dtypes)


# Print first five records for dataframes.

# In[4]:

df_passenger.head(5)


# In[5]:

import pandas as pd

pd.set_option("display.max_columns", 180)


# In[6]:

df_a2010.head(5)


# In[7]:

import pandas as pd

pd.reset_option("display.max_columns")


# In[8]:

df_causefactors.head(5)


# ####3. Departure and Arrival Statistics

# For airports LAX, SFO, ATL, MIA, and JFK, determine how many passenger departures and arrivals there were during 2014.

# In[9]:

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


# For airports LAX, SFO, ATL, MIA, and JFK, determine which airline was the largest departure carrier.

# In[10]:

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


# For airports LAX, SFO, ATL, MIA, and JFK, determine which airline was the the largest arrival carrier.

# In[11]:

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


# For airports LAX, SFO, ATL, MIA, and JFK, determine what airports the largest number of departures went to.

# In[12]:

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


# For airports LAX, SFO, ATL, MIA, and JFK, determine what airports the largest number of arrivals were from.

# In[13]:

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


# ####4. Accident and Fatality Statistics

# For airports LAX, SFO, ATL, MIA, and JFK, determine the number of accidents or incidents that occurred at them between 2010 and 2014 inclusive, according to the FAA.

# In[14]:

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


# For airports LAX, SFO, ATL, MIA, and JFK, determine the number of deaths that occurred in each event.

# In[15]:

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


# For airports LAX, SFO, ATL, MIA, and JFK, determine what the top ten (primary) causes of 2010-2014 incidents and accidents are for all events resulting in deaths regardless of where they occurred. Provide descriptions (not codes) for the causes.

# In[16]:

import numpy as np

df_a2010 = df_a2010.replace({"c78" : {np.NaN : 0,
                                      "  " : 0}}) # Replace NaN's and blanks within cause factor code column with zero digit.
df_a2010["c78"] = df_a2010["c78"].astype(int) # Convert cause factor code column to integer type.
df_causefactors = df_causefactors[[0, 2]] # Define relevant columns of cause factor code description dataframe.
causedict = df_causefactors.set_index(0).to_dict() # Convert cause factor code description dataframe to dictonary.


# In[17]:

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

