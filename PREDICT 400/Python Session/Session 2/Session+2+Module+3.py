# MSPA 400 Session #2 Python Module #3

# Reading assignment "Think Python" either 2nd or 3rd edition:
#    2nd Edition Chapter 3 (3.4-3.9) and Chapter 10 (10.1-10.12)
#    3rd Edition Chapter 3 (pages 24-29) and Chapter 10 (pages 105-115) 

# Module #3 objective:  demonstrate numpy matrix calculations.  For
# matrix calculations, arrays must be converted into numpy matrices.

import numpy 
from numpy import *
from numpy.linalg import *

# With numpy matrices, you can add, subtract, multiply, find the transpose
# find the inverse, solve systems of linear equations and much more.

# Solve a system of consistent linear equations.  Refer to Lial Section 2.5
# Example 7 Cryptography for the calculation

# Right hand side of system of equations has data entered as a list
# and converted to 3x1 matrix and then a 1x3 matrix using the transpose
# function. Similar steps are taken for the matrix A.

rhs= [96, 87, 74]
rhs=matrix(rhs)
rhs=transpose(rhs)
print ('\nRight Hand Side of Equation')
print rhs

A =[[1, 3, 4], [2, 1, 3], [4, 2, 1]]
A= matrix(A)
print ('\nMatrix A')
print A

# Numpy has various functions to perform matrix calculations.  The inverse
# function inv() is one of those.

# Find inverse of A.
print ('\nInverse of A')
IA= inv(A)
print IA

# In what follows, I am converting matrices with floating point numbers  to
# matrices with integer numbers.  This is optional and being done to show
# that it is possible to do so with numpy matrices.

# Note that the function dot() performs matrix multiplication.
# Verify inverse by multiplying matrix A and its inverse IA.

print ('\nIdentity Matrix')
I= dot(IA,A)
I= int_(I)               # This converts floating point to integer.
print I

# Solve the system of equations and convert to integer values.
# With numpy it is necessary to use dot() for the product.

result = dot(IA,rhs)
result = int_(result)    # This converts floating point to integer.
print ('\nSolution to Problem')
print result

# There is a more efficient way to do this with the linalg.solve() function.

print ('\nIllustration of solution with linalg.solve(,) function')
result2= linalg.solve(A,rhs)
print int_(result2)    # This converts floating point to integer.

# Some square matrices do not have inverses. The following example shows
# how this is handled with numpy.  Note the magnitude of the elements.

print ('\nExample of an inverse matrix for inconsistent equations')
A= [[1,2,3],[-3,-2,-1], [-1,0,1]]
A= array(A)
IA= inv(A)
print IA

# Exercises: 

# Part 1. Refer to Lial Section 2.5 Example 2.  Write the code to 
# reproduce the results in the example.  Form the matrix A, find its inverse
# and verify such by multiplying the two to form the identity matrix.
# Show the code, matrix A, inverse of A and the Identity matrix.

# Part 2. Refer to Lial Section 2.5 page 96 problem #1.  Write the code
# which solves the problem.  Use linalg.solve(,).





