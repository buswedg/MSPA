# -*- coding: utf-8 -*-
# Math for Modelers Session #6 Python Module #2

# Reading assignment:
# "Think Python" 2nd Edition Chapter 7 (7.1-7.7)
# “Think Python” 3rd Edition Chapter 7 (pages 75-81)

# Module #2 objectives: 1) demonstrate numerical differentialtion,
# and 2) illustrate results graphically.

import numpy 
from numpy import arange, cos
import matplotlib.pyplot 
from matplotlib.pyplot import *

# A general function for calculating the slope between two points: x and 
# x+delta.  See Lial Section 11.3 dealing with instantaneous rates of change.

def der(x,delta):
    delta = float(delta)
    if delta < (0.0000001):
        print ('Value chosen for delta is too small.')
        return 1/delta
    else:
        slope = (f(x + delta) - f(x))/delta
        return slope

# Define a function for demonstration.  This function may be changed.

def f(x):
    f = cos(x)    
    return f
    
point = 1.0  #This is a point at which a derivative will be calculated.
# The following statements initialize variables for computation.


number = 510
increment =10
y = []
x = []

# What follows shows calculations and list manipulations. Recall that a range
# statement is inclusive of the first number and exclusive of the last.  In this
# example we are incrementing by units of 10 from 1 to 500.  We are reducing
# the distance between x=1.0 and x=1.0+delta by reducing delta.  The slopes
# being calculated are stored in the list y.

for k in range(increment, number, increment):
    delta = 1.0/(k+1)
    d = der(point,delta)
    x = x + [k]
    y = y + [d]
    max_x = k + increment

limit=der(point,0.000001)    
print "Final value equals %2.3f " %limit

# The plot shows convergence of the slopes to the instantaneous rate of change. 
# Black dots mark computed slopes as delta was reduced.  The x-axis is plotted
# using values of k from the range statement in the for loop.

figure()
xlim(0, max_x+50 )
ylim(min(y)-0.05, max(y)+0.05)

scatter(540,limit,color='g',s=40,label='limiting slope')
legend(['limiting slope'],'best')
scatter(x,y,c='k',s=20)

title ('Example of Convergence to Instanteous Rate of Change')
xlabel('x-axis')
ylabel('y-axis')
ylabel('y-axis')
plot(x,y)
show()

# The next section will show the tangent line at the point x=1.0.
# We are using the equation for a straight line y=mx+b where the slope is
# y[-1] from above and the point given above is x=1.0.  We are only going 
# to plot this tangent line over a limited distance given by w defined below.

# Calculate values for the tangent.
w=arange(point-1.0,point+1.1,0.1)
t=f(point)+limit*(w-point)

# Now we are going to plot the original function over a wider range.
# Define a domain for the function.
domain=3.14

# Calculate values for the function on both sides of x=1.0.
u=arange(point-domain,point+domain+0.1,0.1)
z=f(u)

# This allows us to plot in layers showing the tangent and the function.
# The scatter command allows a single point to be plotted.
figure()
xlim(point-domain-.1,point+domain+0.1)
ylim(max(z)+.5,min(z)-.5)

plot(w,t,c='r')                        # This plots the tangent line.
plot(u,z,c='b')                        # This plots the curve itself.
scatter(point,f(point),c='g',s=40)     # This is the point of contact.
xlabel('x-axis')
ylabel('y-axis')
title('Plot showing function and tangent at a point')
show()

# Exercise #1:  Refer to Lial Section 11.3 Examples 3-5.  Using the function 
# der() as defined, calculate approximate slopes for the functions given in 
# Lial Section 11.3 Examples 3(b), 4(c), & 5.  Use a small value for delta and 
# evaluate der() at the points used in the examples. Round to 4 decimal places.

# Exercise #2: Refer to Lial 11.1 Example 1.  This was used in Session 6 
# Module1. The solution code is presented in the answer sheet.  Modify the code
# so that the tangent line at x=2 appears on the preceeding plot.  This 
# necessitates determining the linear equation for the tangent line using
# y=mx+b and writing the statements to plot this line on the existing plot.
# Use arange().






