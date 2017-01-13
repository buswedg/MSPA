# MSPA 400 Session #2 Python Module #1

# Reading assignment "Think Python" either 2nd or 3rd edition:
#    2nd Edition Chapter 3 (3.4-3.9), Chapter 10 (10.1-10.12)
#    3rd Edition Chapter 3 (pages 24-29), Chapter 10 (pages 105-115) 

# Module #1 objectives: 1) reproduce examples from Lial using Python, 
# and 2) demonstrate how to plot a system of nonlinear equations with Python.

# Instructions---

# Execute this script as a single program. The results will appear below 
# or in separate windows showing the plots.  Matplotlib.pyplot and numpy are
# necessary software which must be imported.  They are used frequently.

import matplotlib.pyplot
from matplotlib.pyplot import *
import numpy 
from numpy import linspace

# The example shows how to plot a system of consistent equations.
# This is Example 1 Section 2.1 of Lial.  The function linspace divides the
# interval [-1,15] into 100 points. For each value in x, y1 and y2 will have
# a corresponding value based on the calculations shown below.

x= linspace(-1,15,100)
y1= 115.0/10.0 - (3.0/10.0)*x
y2= 95.0/4.0 - (11.0/4.0)*x

# Plots can be built up in layers.  What follows shows how to plot individual
# colored lines.  plt.legend will associate the indicated equations to the 
# preceding plt.plot statements.  The order of appearance must be the same. 
# loc=3 places the legend in the lower left corner.

xlabel('x-axis')
ylabel('y-axis')
plot (x, y1, 'r')
plot (x, y2, 'b')
legend (('3x+10y=115','11x+4y=95'),loc=3)
title ('Solving a System of Equations with a Unique Solution')
show()

# This example shows a plot of a system of inconsistent equations. It is 
# Example 2 Section 2.1 of Lial.  It is not necessary to always specify colors
# for line plots particularly if no legend is involved.  The computer will
# select colors for you.  Color codes may be found by entering plot? in the 
# interpreter.  Check the answer sheet Session 1 Python Module 2.

# The statement figure() separates the subsequent plot from the preceeding
# plot.  Without it the two plots will be superimposed on each other.  Take
# note of the order of statements.  First, the variables being plotted are 
# defined. The plot statements begin with figure() and end with show().
# If a legend is used, the order of appearance of the plot statements must 
# correspond to the terms used in the plt.legend statement.

x= linspace(0,6,100)
y1= 6.0/(-3.0)+(2.0/3.0)*x
y2= 8.0/6.0 +(4.0/6.0)*x
figure()
plot (x, y1)
plot (x, y2)
xlabel('x-axis')
ylabel('y-axis')
title ('Showing an Inconsistent System of Equations')
show()

# This next example will show how to plot and solve a consistent system 
# of non-linear equations using Python.

x= linspace(0,2,100)
y1= 2.0 - x**2
y2= x**2
figure()
plot (x, y1)
plot (x, y2)
xlabel('x-axis')
ylabel('y-axis')
title ('Showing a Consistent System of Non-linear Equations')
show()

# If loc='best' is used, Python will pick the best location for the legend.

x=linspace(0,100,100)
y=x*x+x
y1=y+1000.0
figure()
xlabel('x-axis')
ylabel('Y-axis')
title ('Plot Showing Inconsistent Nonlinear Equations')
plot(x,y, c='b')
plot(x,y1,c='r')
legend(('y=x**2+x','y=x**2+x+1000'),loc='best')
show()

# Exercise:  Refer to Lial Section 2.1 Problem 46 on page 53.  Solve for a 
# and b using the Echlon Method.  Plot the resulting quadratic function.
# Compare the code and plot with the answer sheet. 

