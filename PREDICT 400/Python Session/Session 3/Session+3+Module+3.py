# MSPA 400 Session #3 Python Module #3

# Reading assignment:  Investigate the Canopy Doc Manager.  Review the portion 
# dealing with Matplolib.  Review the gallery and the code used.

# Module #3 objectives: 1) plot inequalities, 2) show feasible regions, and 
# 3) solve a linear programming problem.

import matplotlib.pyplot 
from matplotlib.pyplot import *
import numpy 
from numpy import *

# This is a minimization problem. One objective is to demonstrate plotting an 
# unbounded region.  There are four inequalities: x+3y >= 15, 3x+y >= 10,
# x >= 0, y >= 0. One inequality and the objective function have been
# modified for this module. The objective function is z = 2x+3y.  The feasible
# region will be graphed and filled.  Matrix methods will be used to evaluate
# the objective function at each corner.

x= arange(0,20.1,0.1)
y0= arange(0,20.1,0.1)
y1= 10.0-3.0*x
y2= 5.0-x/3.0
# The definition of y3 will allow filling the unbounded region in the plot.
y3= 20+0.0*x
# The filling will be between y3 and the maximum of y1 and y2.  Need to define 
# a new array y4 which will be that maximum.

y4=[0]*len(x)
for k in range(0,len(x)):
    if y1[k] >= y2[k]:
        y4[k]=y1[k]
    if y2[k] > y1[k]:
        y4[k]=y2[k]

# This is the objective function plotted for illustration.
y5= 5.5-2.0*x/3.0

# Plot limits must be set for the graph.
xlim(0,20)
ylim(0,20)

# Plot axes need to be labled,title specified and legend shown.
xlabel('x-axis')
ylabel('y-axis')
title('Shaded Area Shows the Feasible Region')

plot(x,y2,color='b')
plot(x,y1,color='r')

# This next step shows how to plot a line using different symbols.
plot(x,y5,'k--')
print ('Note that the dashed line passes through the optimum point')

# The order of entry of labels in the plt.legend statement must follow
# the order of the plt.plot statements to match colors.

legend(['x+3y >= 15','3x+y >= 10', '16.5 = 2x+3y'], 'best')

fill_between(x,y3,y4, color='grey',alpha=0.2)
show()

# Corner points for evaluation using the objective function.
x= [0, 1.5, 15]
y= [10, 4.5, 0]

# This next step shows how to use matrix calculations to evaluate
# the objective function at each corner point and find the maximum.

obj= matrix([2.0,3.0])
obj= transpose(obj)
corners= matrix([x,y])
corners= transpose(corners)
result= dot(corners,obj)
print ('Value of Objective Function at Each Corner Point\n'), result

# Exercise: Using the matrix methods shown above, verify the calculations
# in Lial Section 4.3 Example 1.  Compare your code to the answer sheet.   


