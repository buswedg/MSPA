# MSPA 400 Session #3 Python Module #2

# Reading assignment:  Investigate the Canopy Doc Manager.  Review the portion 
# dealing with Matplolib.  Review the gallery and the code used.

# Module #2 objectivse: 1) plot inequalities, 2) show feasible
# regions, and 3) solve a linear programming problem.

import matplotlib.pyplot 
from matplotlib.pyplot import *
import numpy
from numpy import *


# This demonstration is from Lial Chapter 3 Section 3.2 Example 1.
# An additional constraint will be added to the example, but the final 
# solution will be the same. There are five inequalities: 2x+y <= 4, 
# -x+2y <= 4, x <= 1.5, x >= 0, y >= 0. The objective function is z = 3x+4y.
# The feasible region will be graphed and filled.  Matrix methods will be
# used to evaluate the objective function at each corner.  The goal is to
# maximize the objective function.

x=arange(0,4.1,0.1)
y0=arange(0,4.1,0.1)
y1= 4.0-2.0*x
y2= 2.0+x/2.0
y= 3-.75*x

# The variable x1 may seem odd, but this is one way to code and plot a vertical 
# line at x=1.5.  This is necessary since arange() produces a list with
# a defined number of elements.  x1 must have the same number of elements as 
# the other variables so that it may be plotted.

x1= 1.5+0.0*y0

# Plot limits must be set for the graph.

xlim(0,4)
ylim(0,4)

# Plot axes need to be labled,title specified and legend shown.

xlabel('x-axis')
ylabel('y-axis')
title('Shaded Area Shows the Feasible Region')

plot(x,y2,'b')
plot(x,y1,'r')
plot(x1,y0,'g')

# The order of entry of labels in the legend statement must follow
# the order of the plot statements to match colors.  The word 'best'
# allows the computer to pick the optimum location for the legend.

# This next step shows how to plot a line using different symbols.

print ('The dashed black line represents the objective function.')
plot(x,y,'k--')

legend(['-x+2y <= 4','2x+y <= 4', 'x=1.5','12 = 3x+4y'], 'best')

# Matplotlib will fill irregular polygons if the corner points are given.
# Different colors are possible.  Alpha controls the level of darkness.

x= [0, 0, .8, 1.5, 1.5]
y= [0, 2.0, 2.4, 1.0, 0]
fill(x,y, color='grey', alpha=0.2)
show()

# This next step shows how to use matrix calculations to evaluate
# the objective function at each corner point and find the maximum.

obj= matrix([3.0,4.0])
obj= transpose(obj)
corners= matrix([x,y])
corners= transpose(corners)
result= dot(corners,obj)
print ('Value of Objective Function at Each Corner Point:\n'), result

# Exercise:  Refer to Lial Section 3.2 Example 3.  Using matrix methods  
# evaluate the objective function at each corner point and determine both
# the maximum and the minimum.  Compare your code and solutions with the 
# answer sheet. 


