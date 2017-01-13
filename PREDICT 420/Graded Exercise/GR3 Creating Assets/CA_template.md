
#MSPA PREDICT 420

##Graded Exercise 3: Creating Assets

###Introduction

This document presents the results of the third graded exercise for the Masters of Science in Predictive Analytics course: PREDICT 420. This assessment required the student to create two data "assets" for use by XYZ company, create a relational database for these assets, and create a "flat" file with selected customers and variables.

###Assessment

####0. Accessing Postgres Server on the SSCC

Login to dornick.it


```python
#\ssh -YC xxx@dornick.it.northwestern.edu
```

Login to Postgres server and connect to XYZ


```python
#psql -h 129.105.208.226 -U xxx -d postgres
#\c xyz
```

Create temp view of item, mail and customer tables and copy to csv


```python
#CREATE TEMP VIEW dgb2583item as SELECT * FROM pilot.item;
#\copy (SELECT * FROM dgb2583item) TO 'item.csv' WITH DELIMITER ',' NULL AS '\null' CSV HEADER

#CREATE TEMP VIEW dgb2583mail as SELECT * FROM pilot.mail;
#\copy (SELECT * FROM dgb2583mail) TO 'mail.csv' WITH DELIMITER ',' NULL AS '\null' CSV HEADER

#CREATE TEMP VIEW dgb2583customer as SELECT * FROM pilot.customer;
#\copy (SELECT * FROM dgb2583customer) TO 'customer.csv' WITH DELIMITER ',' NULL AS '\null' CSV HEADER
```

####1. Loading the Data

Load datasets into pandas dataframes.


```python
import pandas as pd    

df_customer = pd.read_csv("data/customer.csv") # Blanks with string if desired, na_values = "N.A."
df_item = pd.read_csv("data/item.csv")
df_mail = pd.read_csv("data/mail.csv")
```

    C:\Users\darry\Anaconda3\lib\site-packages\IPython\core\interactiveshell.py:2902: DtypeWarning: Columns (172) have mixed types. Specify dtype option on import or set low_memory=False.
      interactivity=interactivity, compiler=compiler, result=result)
    

####2. Remove Duplicate Records

Find duplicate records within the 'customer' dataframe.


```python
df_customer["Duplicate"] = df_customer.duplicated(["acctno"])
print("Duplicate customer records:", len(df_customer[df_customer.Duplicate == True]))
```

    Duplicate customer records: 0
    

####3. Check Customer Record Consistency in Item/Mail Dataframes

Find 'acctno' records within the 'item' dataframe which do not appear as 'acctno' records within the 'customer' dataframe.


```python
df_item["Matched"] = df_item["acctno"].isin(df_customer["acctno"])
print("Number of item records with no customer:", len(df_item[df_item.Matched == False]))
```

    Number of item records with no customer: 0
    

Find 'acctno' records within the 'mail' dataframe which do not appear as 'acctno' records within the 'customer' dataframe.


```python
df_mail["Matched"] = df_mail["acctno"].isin(df_customer["acctno"])
print("Number of mail records with no customer:", len(df_mail[df_mail.Matched == False]))
```

    Number of mail records with no customer: 0
    

####4. Create SQLite Database and Write Data


```python
import itertools, pandas, pandas.io.sql, sqlite3

conn = sqlite3.connect("data/db_pilot.db") # Create SQLite database/connection

list_df = [df_customer, df_item, df_mail]
list_tbl = ["customer", "item", "mail"]

for d, t in zip(list_df, list_tbl): # Loop through each dataframe
    dropQuery = "DROP TABLE IF EXISTS " + str(t) # Drop table if already exists in database
    conn.execute(dropQuery).fetchone()
    pandas.io.sql.to_sql(d, t, conn)
    selQuery = "SELECT * FROM " + str(t) # Import dataframe into database
    conn.execute(selQuery).fetchone()

conn.close() # Close SQLite database connection
```

####5. Count Records within each SQLite Database Table


```python
import pandas, sqlite3

conn = sqlite3.connect("data/db_pilot.db") # Create SQLite database/connection
curs = conn.cursor()

tblQuery = "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY Name" # Select all table query
curs.execute(tblQuery) # Execute select all table query
tables = map(lambda t: t[0], curs.fetchall()) # Fetch list of tables

totalColumns, totalRows, totalCells = 0, 0, 0
resultcols = ["Table Name", "Column Count", "Row (Record) Count", "Cell Count"]

results_df = pd.DataFrame([])

for table in tables:        
    columnsQuery = "PRAGMA table_info(%s)" % table # SQLite table info query
    curs.execute(columnsQuery)
    numberOfColumns = len(curs.fetchall()) # Return column count
    rowsQuery = "SELECT Count() FROM %s" % table # Row count query
    curs.execute(rowsQuery)
    numberOfRows = curs.fetchone()[0] # Return row count
    numberOfCells = numberOfColumns * numberOfRows # Derive cell count
    temp_df = pandas.DataFrame([[table, numberOfColumns, numberOfRows, numberOfCells]], columns = resultcols)
    results_df = results_df.append(temp_df)

curs.close()
conn.close()

results_df.reset_index().drop("index", 1)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Table Name</th>
      <th>Column Count</th>
      <th>Row (Record) Count</th>
      <th>Cell Count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>customer</td>
      <td>453</td>
      <td>50000</td>
      <td>22650000</td>
    </tr>
    <tr>
      <th>1</th>
      <td>item</td>
      <td>10</td>
      <td>77121</td>
      <td>771210</td>
    </tr>
    <tr>
      <th>2</th>
      <td>mail</td>
      <td>19</td>
      <td>30946</td>
      <td>587974</td>
    </tr>
  </tbody>
</table>
</div>



####6. Create XYZ Direct Mail Marketing Dataframe

Create 'drop table' queries for each table.


```python
droptempmailQuery = "DROP TABLE IF EXISTS tempmail"
droptempcustQuery = "DROP TABLE IF EXISTS tempcustomer"
droptempcampQuery = "DROP TABLE IF EXISTS campaign"
```

Query to create temporary mail table which includes sum of all mail fields.


```python
tempmailQuery = """
CREATE TABLE tempmail AS
SELECT acctno,
       (mail.mail_1 + mail.mail_2 + mail.mail_3 + mail.mail_4 + mail.mail_5 +
       mail.mail_6 + mail.mail_7 + mail.mail_8 + mail.mail_9 + mail.mail_10 +
       mail.mail_11 + mail.mail_12 + mail.mail_13 + mail.mail_14 + mail.mail_15 +
       mail.mail_16) AS mail_total
FROM mail
"""
```

Query to create temporary customer table which includes numeric 'zhomeent' and 'zmobav' fields.


```python
tempcustQuery = """
CREATE TABLE tempcustomer AS
SELECT acctno, 
       ytd_sales_2009,
       ytd_transactions_2009,
       zhomeent, 
       CASE zhomeent WHEN "Y" THEN 1 ELSE 0 END AS zhomeent01, 
       zmobav, 
       CASE zmobav WHEN "Y" THEN 1 ELSE 0 END AS zmobav01
FROM customer
"""
```

Query to create campaign table which includes fields from above tables, joined by account number.


```python
campQuery = """
CREATE TABLE campaign AS
SELECT tempmail.acctno AS acctno, 
       tempmail.mail_total AS mailCampaigns, 
       tempcustomer.ytd_sales_2009 AS YTD09transSum, 
       tempcustomer.ytd_transactions_2009 AS YTD09salesSum, 
       tempcustomer.zhomeent AS ZHOMEENT,
       tempcustomer.zhomeent01 AS ZHOMEENT01,
       tempcustomer.zmobav AS ZMOBAV,
       tempcustomer.zmobav01 AS ZMOBAV01
FROM tempmail
JOIN tempcustomer ON tempcustomer.acctno = tempmail.acctno
WHERE tempmail.mail_total >= 5
GROUP BY tempmail.acctno
"""
```

Run each query and export created campaign table as csv file.


```python
#Note: SQLite does not support SELECT INTO
import pandas, sqlite3

conn = sqlite3.connect("data/db_pilot.db") # Create SQLite database/connection
curs = conn.cursor()

temp = conn.execute(droptempmailQuery) # drop tempmail if exists
temp = conn.execute(droptempcustQuery) # drop tempcustomer if exists
temp = conn.execute(droptempcampQuery) # drop campaign if exists

temp = conn.execute(tempmailQuery) # create tempmail
temp = conn.execute(tempcustQuery) # create tempcustomer

temp = conn.execute(campQuery) # create campaign

exp_df =  pandas.io.sql.read_sql("SELECT * FROM campaign", conn)
if "index" in exp_df:
    exp_df = exp_df.drop("index", 1)
    
exp_file = "data/campaign.csv"
exp_df.to_csv(exp_file, index = False)

curs.close()
conn.close()
```

####7. Confirm Campaign Output

Load dataset into pandas dataframes.


```python
import pandas as pd    

df_campaign = pd.read_csv("data/campaign.csv")
```

Print last five records of dataframe.


```python
df_campaign[-5:]
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>acctno</th>
      <th>mailCampaigns</th>
      <th>YTD09transSum</th>
      <th>YTD09salesSum</th>
      <th>ZHOMEENT</th>
      <th>ZHOMEENT01</th>
      <th>ZMOBAV</th>
      <th>ZMOBAV01</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>11387</th>
      <td>YYWSAQLL</td>
      <td>7</td>
      <td>336</td>
      <td>1</td>
      <td>U</td>
      <td>0</td>
      <td>U</td>
      <td>0</td>
    </tr>
    <tr>
      <th>11388</th>
      <td>YYYGSWDG</td>
      <td>11</td>
      <td>801</td>
      <td>1</td>
      <td>U</td>
      <td>0</td>
      <td>U</td>
      <td>0</td>
    </tr>
    <tr>
      <th>11389</th>
      <td>YYYHGQYW</td>
      <td>10</td>
      <td>0</td>
      <td>0</td>
      <td>U</td>
      <td>0</td>
      <td>U</td>
      <td>0</td>
    </tr>
    <tr>
      <th>11390</th>
      <td>YYYWSGGA</td>
      <td>8</td>
      <td>249</td>
      <td>1</td>
      <td>U</td>
      <td>0</td>
      <td>U</td>
      <td>0</td>
    </tr>
    <tr>
      <th>11391</th>
      <td>YYYWYPDH</td>
      <td>5</td>
      <td>0</td>
      <td>0</td>
      <td>U</td>
      <td>0</td>
      <td>U</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>



Count number of records within dataframe.


```python
print("Number of records within campaign dataframe:", len(df_campaign))
```

    Number of records within campaign dataframe: 11392
    

Confirm recoding for 'ZHOMEENT' and 'ZMOBAV' fields.


```python
import pandas as pd

pd.crosstab(df_campaign.ZHOMEENT, df_campaign.ZHOMEENT01, margins = True) # Blanks filled with NaN
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th>ZHOMEENT01</th>
      <th>0</th>
      <th>1</th>
      <th>All</th>
    </tr>
    <tr>
      <th>ZHOMEENT</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>U</th>
      <td>8586</td>
      <td>0</td>
      <td>8586</td>
    </tr>
    <tr>
      <th>Y</th>
      <td>0</td>
      <td>1909</td>
      <td>1909</td>
    </tr>
    <tr>
      <th>All</th>
      <td>9483</td>
      <td>1909</td>
      <td>11392</td>
    </tr>
  </tbody>
</table>
</div>




```python
import pandas as pd

pd.crosstab(df_campaign.ZMOBAV, df_campaign.ZMOBAV01, margins = True) # Blanks filled with NaN
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th>ZMOBAV01</th>
      <th>0</th>
      <th>1</th>
      <th>All</th>
    </tr>
    <tr>
      <th>ZMOBAV</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>U</th>
      <td>10166</td>
      <td>0</td>
      <td>10166</td>
    </tr>
    <tr>
      <th>Y</th>
      <td>0</td>
      <td>329</td>
      <td>329</td>
    </tr>
    <tr>
      <th>All</th>
      <td>11063</td>
      <td>329</td>
      <td>11392</td>
    </tr>
  </tbody>
</table>
</div>



Pickle final dataframe.


```python
import pickle

df_campaign.to_pickle("data/campaign.p")
```
