# Math for Modelers Session #3 Module #1

# Reading assignment:  Investigate the Canopy Doc Manager.  Review the portion 
# dealing with Matplolib.  Review the gallery and the code used.

# Module #1 objectives: 1) plot inequalities with Matplotlib, and 
# 2) demonstrate how to show feasible regions.

import matplotlib.pyplot 
from matplotlib.pyplot import *
import numpy 
from numpy import arange

# The first example will be from Lial Chapter 3 Section 3.1 Example 2.
# A graph of the inequality x - 4y > 4 will be shown. The first step is
# to generate a range of values for x. Then compute values for y.  This
# section will use arange() in place of linspace().  This function will
# generate a list of equally spaced values using the specified interval 0.1.
# It is inclusive of -2 and exclusive of 6.1.  We use 6.1 to insure inclusion
# of 6.0 in the resulting array x.

# Whenever a question arises about a function such as arange, the interpreter
# may be used to find additional information.  Enter arange? into the 
# interpreter to see how this works.

x= arange(-2,6.1,0.1)
y= -1.0 + x/4.0


# Plot limits must be set for the graph.

xlim(-1,6)

# Plot axes must be specified.  Setting the grid is optional. 

xlabel('x-axis')
ylabel('y-axis')
hlines(0,-2,6,color='r')
vlines(0,-2,6,color='r')
grid(True)

# Data points are plotted using variable z to define a boundary for the
# filled area.  z is a list with the same dimension as x and y.  It provides a
# lower boundary for the plot so that the region can be filled.  

plot(x,y)
z= -2.0 + 0.0*x
plot(x,z)

# Region is filled to show the region.  fill_between() will fill between two
# lines.  It is difficult to use with irregular polygons.

fill_between(x,y,z, color= 'b')
title ('Shaded Area Shows the Linear Inequality x-4y > 4')
show()

# The next example shows how to plot a feasible region.  Refer to 
# Lial Section 3.1 Example 5.  This involves four inequalities;
# 2x-5y <= 10, x+2y <= 8, x >= 0, and y >= 0.  The steps are similar
# to what was shown above. figure() separates the two plots

figure()
x= arange(-3,10.1,0.1)
y= arange(-3,10.1,0.1)
y1= 0.4*x-2.0
y2= 4.0-0.5*x

xlim(-3,10)
ylim(-3,10)
hlines(0,-3,10,color='k')
vlines(0,-3,10,color='k')
grid(True)

xlabel('x-axis')
ylabel('y-axis')
title ('Shaded Area Shows the Feasible Region')

plot(x,y1,color='b')
plot(x,y2,color='r')
legend(['2x-5y=10','x+2y=8'])

# The simplest approach for filling a polygon is to locate the
# corner points. Matplotlib will fill within these points.

x= [0.0, 0.0, 6.67,5.0]
y= [0.0, 4.0, .67, 0.0]
fill(x,y)
show()

# Exercise: Refer to Lial Section 3.1 page 118. Write the code to reproduce
# Figure 10.  Compare your code and the resulting plot to the answer sheet.


