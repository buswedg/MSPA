
#MSPA PREDICT 420

##Extra Credit: Top Words

###Introduction

This document presents the results of the extra credit exercise for the Masters of Science in Predictive Analytics course: PREDICT 420.

###Assessment

####1. Loading the Data

Load the dataset.


```python
babble = []
f = open("data/babble-words.txt", "r")
babble = f.read()

print("babble[:500]:\n", babble[:500])
```

    babble[:500]:
     Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ex risus, porta vitae nisl sit amet, lacinia feugiat nunc. Duis auctor augue sit amet nulla ultrices ultrices. Sed posuere dictum purus non faucibus. Nullam nec consequat urna. Nunc diam leo, luctus eu tincidunt at, laoreet ac lacus. Duis blandit lectus quis massa sagittis consequat. Donec semper quam at ultrices pretium. Morbi varius odio sit amet iaculis imperdiet. Pellentesque a gravida turpis, eget molestie ligula. Donec lobortis
    

####2. Pre-process the Data

Remove punctuation, remove non-printable characters and convert to lowercase.


```python
import string

babble = "".join(filter(lambda x: x not in string.punctuation, babble)) # Remove punctuation.
babble = "".join(filter(lambda x: x in string.printable, babble)) # Remove non-printable characters.
babble = babble.lower() # Convert to lowercase.

print("babble[:500]:\n", babble[:500])
```

    babble[:500]:
     lorem ipsum dolor sit amet consectetur adipiscing elit nulla ex risus porta vitae nisl sit amet lacinia feugiat nunc duis auctor augue sit amet nulla ultrices ultrices sed posuere dictum purus non faucibus nullam nec consequat urna nunc diam leo luctus eu tincidunt at laoreet ac lacus duis blandit lectus quis massa sagittis consequat donec semper quam at ultrices pretium morbi varius odio sit amet iaculis imperdiet pellentesque a gravida turpis eget molestie ligula donec lobortis quis erat at bl
    

####3. Word Count

Count up how many times each word occurs.


```python
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
```


```python
df_wordcount.head(5)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>wordcount</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>a</th>
      <td>5</td>
    </tr>
    <tr>
      <th>ac</th>
      <td>7</td>
    </tr>
    <tr>
      <th>accumsan</th>
      <td>3</td>
    </tr>
    <tr>
      <th>adipiscing</th>
      <td>1</td>
    </tr>
    <tr>
      <th>aenean</th>
      <td>1</td>
    </tr>
  </tbody>
</table>
</div>



Output the ten (10) most frequently occurring words, indicating for each word how many times it occurred.


```python
df_wordcount.sort_values(by = "wordcount", ascending = False, inplace = True) # Sort dataframe.
```


```python
df_wordcount.head(10)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>wordcount</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>sed</th>
      <td>17</td>
    </tr>
    <tr>
      <th>ut</th>
      <td>15</td>
    </tr>
    <tr>
      <th>in</th>
      <td>11</td>
    </tr>
    <tr>
      <th>nulla</th>
      <td>10</td>
    </tr>
    <tr>
      <th>amet</th>
      <td>8</td>
    </tr>
    <tr>
      <th>nec</th>
      <td>8</td>
    </tr>
    <tr>
      <th>turpis</th>
      <td>8</td>
    </tr>
    <tr>
      <th>nunc</th>
      <td>8</td>
    </tr>
    <tr>
      <th>sit</th>
      <td>8</td>
    </tr>
    <tr>
      <th>et</th>
      <td>7</td>
    </tr>
  </tbody>
</table>
</div>


