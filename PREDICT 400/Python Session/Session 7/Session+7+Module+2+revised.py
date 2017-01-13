# MSPA 400 Session 7 Python Module #2.

# Reading assignment:
# "Think Python" 2nd Edition Chapter 8 (8.3-8.11)
# "Think Python" 3td Editon (pages 85-93)

# Module #2 objective:  demonstrate some of the unique capabilities of numpy 
# and scipy.  (Using the poly1d software from numpy, it is possible to 
# differentiate, # integrate, and find the roots of polynomials.  Plotting the
# results illustrates the connection between the different functions.)

import matplotlib.pyplot 
from matplotlib.pyplot import *
import numpy 
from numpy import poly1d, linspace

# The first example shows how to generate and print a second degree
# polynomial with coefficients, 1, -3 and 2.  The software is not limited
# to second degree polynomials.  Higher order can be generated.  The critical
# thing is to have all the coefficients in the right sequence.

p=poly1d([1,-3,2])
print ('Second Degree Polynomial') 
print p 

# Now a fourth degree polynomial will be generated and printed.

q=poly1d([2,1,4,-2,3])
print ('\nFourth Degree Polynomial') 
print q

# It is possible to combine p and q algebraically.

print ('\nCombination')
g=p + p*q
print g

# Derivatives of different orders may be calculated.  This next section will 
# show determination of the first and second derivatives of p.

print ('\nFirst Derivative')
h= p.deriv(m=1)  # First derivative with m=1.
print h

print ('\nSecond Derivative')
t= p.deriv(m=2)  # Second derivative with m=2.
print t

# Using t, the original function p can be restored if the missing 
# coefficients -3 and 2 are supplied.  Different coefficients would result
# in a different function instead of the original p.

print ('\nIntegrated Derivative')
w=t.integ(m=2,k=[-3,2])
print w
print w.coeffs

# Roots may also be found.  This is useful when locating the maxima, minima 
# and inflection points of a function from the first and second derivatives.

print('\nRoots of polynomial')
print w.roots

# Plotting requires defining a domain for the polynomial.  The linspace
# function is used to set boundaries and define the number of points
# used for calculation. A new polynomial p will be defined.

p=poly1d([.3333,0,-1,5])

# As a final example, we will find the first and second derivatives of the
# polynomial p, find the roots of the derivatives and plot the functions.

g=p.deriv(m=1)

print ('\nRoots of First Derivative')
print g.roots

print ('\nRoots of Second Derivative')
q=p.deriv(m=2)
print q.roots

x=linspace(-4,4,101)
y=p(x)
yg=g(x)  # These statements define points for plotting.
yq=q(x)
y0=0*x   # This statement defines the y axis for plotting.

# What is shown below is a different way using a label.  Python
# will pick the colors to assign to the labels and the plotted points.

plot (x,y,label ='y=p(x)')
plot (x,yg,label ='First Derivative')
plot (x,yq,label ='Second Derivative')
legend(loc='best')

plot (x,y0)
xlabel('x-axis')
ylabel('y-axis')
title ('Plot Showing Function, First and Second Derivatives')
show()

# Exercise: Refer to Lial Section 14.1 Example 2.  Duplicate the results 
# showing plots of the function and derivatives.  Compare to the answer sheet.

figure()
p=poly1d([3,-4,-12,0,2])
print ('\nFourth Degree Polynomial') 
print p
print ('\nFirst Derivative')
g= p.deriv(m=1) # First derivative with m=1.
print g
print ('\nSecond Derivative')
q= p.deriv(m=2) # Second derivative with m=2.
print q
x=linspace(-2,3,101)
y=p(x)
yg=g(x) # These statements define points for plotting.
yq=q(x)
y0=0*x # This statement defines the y axis for plotting.
plot (x,y,label ='y=p(x)')
plot (x,yg,label ='First Derivative')
plot (x,yq,label ='Second Derivative')
legend(loc='best')

plot (x,y0)
xlabel('x-axis')
ylabel('y-axis')
title ('Plot Showing Function, First and Second Derivatives')
show()