
# coding: utf-8

# #MSPA PREDICT 420

# ##Extra Credit: Top Words

# ###Introduction

# This document presents the results of the extra credit exercise for the Masters of Science in Predictive Analytics course: PREDICT 420.

# ###Assessment

# ####1. Loading the Data

# Load the dataset.

# In[1]:

babble = []
f = open("data/babble-words.txt", "r")
babble = f.read()

print("babble[:500]:\n", babble[:500])


# ####2. Pre-process the Data

# Remove punctuation, remove non-printable characters and convert to lowercase.

# In[2]:

import string

babble = "".join(filter(lambda x: x not in string.punctuation, babble)) # Remove punctuation.
babble = "".join(filter(lambda x: x in string.printable, babble)) # Remove non-printable characters.
babble = babble.lower() # Convert to lowercase.

print("babble[:500]:\n", babble[:500])


# ####3. Word Count

# Count up how many times each word occurs.

# In[3]:

import pandas as pd

babblelist = babble.split() # Convert to dictonary.

worddict = {}
for w in babblelist: # Count words.
    try:
        worddict[w] += 1
    except KeyError:
        worddict[w] = 1
        
df_wordcounttemp = pd.DataFrame(worddict, index = [0]) # Convert to dataframe.
df_wordcount = df_wordcounttemp.transpose()
df_wordcount.columns = ["wordcount"]


# In[4]:

df_wordcount.head(5)


# Output the ten (10) most frequently occurring words, indicating for each word how many times it occurred.

# In[5]:

df_wordcount.sort_values(by = "wordcount", ascending = False, inplace = True) # Sort dataframe.


# In[6]:

df_wordcount.head(10)

