# -*- coding: utf-8 -*-
# MSPA 400 Session #6 Python Module #1

# Reading assignment:
# "Think Python" 2nd Edition Chapter 7 (7.1-7.7)
# “Think Python” 3rd Edition Chapter 7 (pages 75-81)

# Module #1 objectives:  1) to demonstrate numerical limits, and 2)  illustrate
# convergence graphically. 

import numpy 
from numpy import sin, arange
import matplotlib.pyplot 
from matplotlib.pyplot import *

# Students can substitute their own functions to observe convergence
# to limiting values.

def g(x):
    g = (sin(x))  #This is where a student's function can be substituted.
    return g

# An example will be used to show right and left convergence to a value.        
# Convergence at x=0 will be shown graphically using g(x).

n=5  # This determines the number of values calculated on each side of x=0.

powers=arange(0,n+1)
denominator=2.0**powers  # denominator contains exponentiated values of 2.0. 
delta=2.0           # This is the interval used on either side of the origin.

# The following are values of x and f(x) trending to the limit.
# Delta is being divided by powers of 2 to reduce the distance from the limit.
# The letter "r" denotes from the right, and "l" denotes from the left.

x_r=delta/denominator
y_r=g(x_r) 
x_l=-x_r   # The negative sign generates a symmetric point on the left.
y_l=g(x_l)

# The following determines the vertical boundaries of the resulting plot.

ymax=max(abs(y_r))+0.5
ymin=-ymax

figure()
xlim(-delta-0.5,delta+0.5)
ylim(ymin,ymax)

# Plotting is being done in layers.  First the line plot then the points.

plot(x_r,y_r, color='b')
plot(x_l,y_l,color='r')

# The black points were computed.  The yellow point marks the limit.

scatter(x_r,y_r,color='k',s=30)
scatter(x_l,y_l,color='k',s=30)
scatter(0.0,g(0.0),c='y',s=40)

title ('Example of Convergence to a Functional Value')
xlabel('x-axis')
ylabel('y-axis')
show()

# Define a different function.  This one is from Lial Section 11.1 Example 12.
# As x goes to infinity, f tends to 8/3=2.667 (rounded to 3 digits).

def f(x):
    f = (8.0*x)/(3*x-1)
    return f
       
# The next section shows convergence to a limit at infinity.
# The coding shows list manipulations resulting in a plot.
# For simplicity, equal intervals between calculated points will be used.
 
number = 210  # This is the number of points calculated (minus the increment).
increment =10  # This is the increment between the points.
 
y = []
x = []

# The for loop traverses between 10 and 200 in increments of 10.  
# A range statement is inclusive of the first number and exclusive of the last.

for k in range(increment, number, increment):
    w=float(k)
    x = x + [k]
    y = y + [f(w)]
    
print "Final value equals %2.4f  " %(y[-1])  #Floating point with 4 decimals.
    
figure()
xlim(0,number+increment)
ylim(min(y)-0.1, max(y)+0.1)

# The black points were computed.  The yellow point indicates the limit.

plot(x,y, color='r')
scatter(x,y,color='k',s=30)
scatter(number,y[-1],c='y',s=40)

title ('Example of Convergence to a Limit at Infinity')
xlabel('x-axis')
ylabel('y-axis')
show()  # Plot shows convergence to limit at infinity 

# Exercise #1: Refer to Lial Section 11.1 Example 1.  Generalize the code 
# for the function indicated to determine a limit when x=2. Compare the
# code and the resulting plot to the answer sheet.

# Exercise #2: Generalize the code which was used to determine a limiting
# value at infinity.  Apply to Lial Section 11.1 Example 11.


