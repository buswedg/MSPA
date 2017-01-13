# Math for Modelers Session #2 Python Module #2

# Reading assignment "Think Python" either 2nd or 3rd edition:
#    2nd Edition Chapter 3 (3.4-3.9) and Chapter 10 (10.1-10.12)
#    3rd Edition Chapter 3 (pages 24-29) and Chapter 10 (pages 105-115) 

# Module #2 objective: demonstrate numpy list and array operations.
# (Numpy Lists and arrays are useful data structures that serve multiple 
# purposes. For matrix calculations, arrays must be converted into
# matrices. Array manipulations are valuable for preparing data for
# linear algebra. Matrix calculations are shown in Session 2 Module 3.
# The * following "numpy import" makes all routines within numpy available.)

import numpy 
from numpy import array, absolute

# This example defines a list called t, and shows how elements 1 and 3
# can be located.  The first element in t is indexed as 0.

t= [1, 2, 3]
print ('\nValue at first location:  %r') %t[0]
print ('Value at third location:  %r') %t[2]
print ('Value located using negative index:  %r \n') %t[-2]

# The next two examples demonstrate the difference between concantenation
# and forming an array. result2 is a list of lists or an array.

print ('Comparison of a concatenated list with an array ')
r= [4, 5, 6]
print ('r= %s and t= %s \n') %(r,t)
result1= t + r
print ('Concatenation example using t and r lists.  %s') %result1
result2=array([t,r])
print ('\nComparison of concatenation with array([t,r]).')
print result2

# Note the different results produced by indexing for a list and an array.
print ('\nThe second element of the preceding list and array')
print result1[1]
print result2[1]

# Array slicing is demonstrated briefly with two examples.  The first shows
# how to produce a single element.  The second and third show how to produce
# a reduced array from the original array. Array slicing goes beyond the 
# scope of this course.  It is an essential tool for array operations.

print ('\nSlicing to produce an element, a column and a row of the array')
print result2[0,1]
print result2[:,1]  # Note the horizontal output of a column.
print result2[1,:]

# The next series of examples demonstrates simple array operations.  Arrays may
# be operated on prior to conversion to a matrix for matrix operations.
# Arrays can be constructed directly from lists of data.

print ('\nExample 1 Section 2.3 Lial showing array addition from page 72.')
m= array([[10,12,5],[15, 20, 8]])
n= array([[45, 35, 20],[65, 40, 35]])
q= m + n
print ('\nArrays in order: m , n and m+n')
print m 
print ('\n%s') %n  # Note that context determines the purpose of "n".
print ('\n%s') %q

print ('\nSubtraction of n from m equals q')
q= m - n
print q

s= 2.0
print ('\nMultiplication of q by a scalar %r') %s
q= s*q
print q

print ('\nFunctions can be applied to an array such as absolute value')
q= absolute(q)
print q

# Exercise:  Refer to Lial Section 2.3 Example 7.  Write the code which
# reproduces the calculations shown in that example.  For the array which
# results, slice it to show 1) second row, 2) the third column and 3) the
# single element common to (1) and (2). Use the demonstrated array methods.
# Compare your code and results to the answer sheet.


