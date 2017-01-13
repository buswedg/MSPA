
# coding: utf-8

# #MSPA PREDICT 420

# ##Graded Exercise 4: Customers of a Hotel Speak

# ###Introduction

# This document presents the results of the forth graded exercise for the Masters of Science in Predictive Analytics course: PREDICT 420. This assessment required the student to work with json formatted TripAdvisor customer review data in order to help understand the feedback from aggregated reviews.

# ###Assessment

# ####1. Loading the Data

# In[1]:

import json

with open("data/100506.json") as input_file:
    jsondat = json.load(input_file)


# ####2. Extract Ratings Data

# Extract ratings data into a list of dictionaries and convert to a dataframe.

# In[2]:

import pandas

#Source: http://stackoverflow.com/questions/38987/how-can-i-merge-two-python-dictionaries-in-a-single-expression
def merge_dicts(*dict_args):
    result = {}
    for dictionary in dict_args:
        result.update(dictionary)
    return result

ratingdictlist = [] # Create ratings dictionary list.
ratingfield = ["Service", # Exhaustive list of rating fields to extract. Note that fields not consistent between records.
               "Sleep Quality", 
               "Check in / front desk", 
               "Rooms", 
               "Cleanliness", 
               "Location", 
               "Business service (e.g., internet access)", 
               "Value",
               "Overall"]

for i in jsondat["Reviews"]: # Loop through each record in 'Reviews'.
    expdict = {"Author" : i["Author"], # Extract 'Author' and 'Date' from first level of record.
               "Date" : i["Date"]}
    
    for r in ratingfield: 
        try: # Try to extract exhaustive list of ratings from second level (of 'Ratings').
            ratingdict = {r : i["Ratings"][r]}
        except KeyError: # NaN if ratings field does not exist for that record.
            ratingdict = {r : "NaN"} 
            
        expdict = merge_dicts(expdict, ratingdict) # Merge extracted ratings to current record dictonary.

    ratingdictlist.append(expdict) # Append current record dictonary to list of dictionaries.

df_ratings = pandas.DataFrame(ratingdictlist) # Convert list of dictionaries to pandas dataframe.


# Rename dataframe fields.

# In[3]:

df_ratings.columns = ["authorName",
                      "busservicesRate", 
                      "fontdeskRate", 
                      "cleanlinessRate", 
                      "reviewDate",
                      "locationRate", 
                      "overallRate",
                      "roomRate", 
                      "serviceRate",
                      "sleepRate",
                      "valueRate"]


# Convert numeric fields to correct dtype.

# In[4]:

numfields = ["busservicesRate", # Identify numeric fields.
             "fontdeskRate", 
             "cleanlinessRate", 
             "locationRate", 
             "overallRate",
             "roomRate", 
             "serviceRate",
             "sleepRate",
             "valueRate"]

df_ratings[numfields] = df_ratings[numfields].apply(pandas.to_numeric, errors = "coerce") # Convert numeric fields to numeric dtype.


# Confirm dtypes for created dataframe.

# In[5]:

print(df_ratings.dtypes)


# Set dataframe index to 'authorName'.

# In[6]:

df_ratings = df_ratings.set_index("authorName")
df_ratings.index.name = None


# Print first five records of created dataframe.

# In[7]:

df_ratings.head(5)


# ####3. Calculate Ratings Data Statistics

# Calculate the minimum value for each rating.

# In[8]:

pandas.DataFrame.min(df_ratings[numfields])


# Calculate the maximum value for each rating.

# In[9]:

pandas.DataFrame.max(df_ratings[numfields])


# Calculate the mean value for each rating.

# In[10]:

pandas.DataFrame.mean(df_ratings[numfields])


# ####4. Extract Comments Data

# In[11]:

import pandas

def merge_dicts(*dict_args):
    result = {}
    for dictionary in dict_args:
        result.update(dictionary)
    return result

contentdictlist = [] # Create comments dictionary list.

for i in jsondat["Reviews"]: # Loop through each record in 'Reviews'.
    expdict = {"Author" : i["Author"], # Extract 'Author', 'Date' and 'Content' from first level of record.
               "Date" : i["Date"],
               "Content" : i["Content"]}

    contentdictlist.append(expdict) # Append current record dictonary to list of dictionaries.

df_content = pandas.DataFrame(contentdictlist) # Convert list of dictionaries to pandas dataframe.


# Rename dataframe fields.

# In[12]:

df_content.columns = ["authorName",
                      "commentString", 
                      "reviewDate"]


# Confirm dtypes for created dataframe.

# In[13]:

print(df_content.dtypes)


# Set dataframe index to 'authorName'.

# In[14]:

df_content = df_content.set_index("authorName")
df_content.index.name = None


# Print first five records of created dataframe.

# In[15]:

df_content.head(5)


# ####5. Pickle Final Dataframes

# In[16]:

import pickle

df_ratings.to_pickle("data/ratings.p")
df_content.to_pickle("data/content.p")


# ####6. Extract Hotel Information

# Create hotel information extraction function.

# In[17]:

import json
from html.parser import HTMLParser
import pandas

#Source: http://stackoverflow.com/questions/753052/strip-html-from-strings-in-python
class MLStripper(HTMLParser):
    def __init__(self):
        self.reset()
        self.strict = False
        self.convert_charrefs= True
        self.fed = []
    def handle_data(self, d):
        self.fed.append(d)
    def get_data(self):
        return ''.join(self.fed)

def strip_tags(html):
    s = MLStripper()
    s.feed(html)
    return s.get_data()

def returninfo(data):
    infodict = {} # Create info dictionary.
    
    with open(data) as input_file:
        jsondat = json.load(input_file)
    
    for i in jsondat["HotelInfo"].keys(): # Loop through keys within 'HotelInfo'.
        j = strip_tags(jsondat["HotelInfo"][i]) # Strip HTML formatting for each keys record.
        infodict[i] = j
    
    df_content = pandas.DataFrame(infodict, index = [0]) # Convert dictonary to dataframe.

    return df_content


# Apply extraction function to provided json files.

# In[18]:

data = ["data/100506.json",
        "data/677703.json",
        "data/1217974.json"]


# In[19]:

returninfo(data[0])


# In[20]:

returninfo(data[1])


# In[21]:

returninfo(data[2])

