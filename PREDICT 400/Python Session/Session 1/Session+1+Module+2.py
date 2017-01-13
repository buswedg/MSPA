# Math for Modelers Session#1 Python Module #2

# Reading assignment "Think Python" either 2nd or 3rd edition:
#    2nd Edition Chapter 2, Chapter 3 (3.1-3.3), and Chapter 8 (8.1-8.2)
#    3rd Edition Chapter 2, Chapter 3 (pages 23-25). and Chapter 8 (pages 85-88) 
# Also review the handouts dealing with numpy and Matplotlib

# Module #2 objectives: 1) demonstrate computational capabilities of 
# Python and 2) illustrate some of Python's printing and plotting capabilities.
# (This will require importing software that provides the necessary capabilities.
# Matplotlib and numpy are commonly used.)

# Instructions---

# Execute this script as a single program.  The results will appear below or
# in a separate window which will reveal the plots.  Print statements will be 
# used to separate sections.

# matplotlibe.pyplot is a library of plotting software for Python.
# numpy is the library of numerical functions and software for Python.
# Note the difference in the import statements.  Because of the number of
# functions used for plotting, the asterisk is being used.

import matplotlib.pyplot 
from matplotlib.pyplot import *
import numpy 
from numpy import linspace

# The first example will demonstrate calculation of the slope for a linear
# equation using Example 5 from Section 1.1 of Lial.

# The use of \n causes a line to be skipped before the text is printed.  The
# characters \n are otherwise ignored.

print ('\nlinear equation construction')
x1= 5.0
y1= 4.0
x2= -10.0
y2= -2.0
slope= (y2-y1)/(x2-x1)
print ('\nslope of line =  %r') %slope

# The next example will show how to use the calculated slope to form the 
# linear equation and calculate a result.  

x= 1.0
y= y1 + slope*(x-x1)
print ('\nValue of y if x is 1.0 equals %r') %y

# The next section shows how to assign a string to a variable for printing
# purposes.  The variable is called "equation" and it will be printed as a
# string.  This is a useful technique that will be used in later modules.
# Note the use of %s in the print statement.  The s denotes the output is a
# string.  Note the compound print statement for x1 and y1.

equation= str('y = y1 + slope*(x-x1)')
print ('\nEquation of a line is %s') %equation
print ('\nx1 equals %r and y1 equals %r ') % (x1, y1)

# The next example will show how to plot Example 11 from Section 1.1 of Lial.
# Plotting limits need to be set to define the dimensions of the plot.  The 
# linspace statement divides the interval [-1,8] into 100 points including
# the first, -1, and the last 100. If you have doubts about the contents or the 
# length of x, enter either the statements print x or len(x) in the interpreter
# to see the contents or find out the length.

x= linspace(-1,8,100)
y= 6.0 - 1.5*x  
title('Plot of Linear Equation  '+equation)  # Note how the title appears.
plot(x,y)
show()

# The next example will show how to solve Example 6 Section 1.2 of Lial
# graphically using Python.  Note that integers and floating point numbers can 
# combined in the same equation.  The result is a floating point number.  The
# figure() statement separates the following plot from the previous plot. 
# Two windows will appear with separate plots one behind the other.

x= linspace(0,50,100)
y= 20*x+100.0
z= 24*x

# loc=2 places the legend in he upper left corner.  The order in which these
# statements appear is important.  legend() will associate 'cost' with the 
# first statement and 'revenue' with the second. For more information about
# plot(), type the phrase  plot?  in the interpreter and enter.

figure()  
plot (x,y)
plot (x,z)
legend (('cost','revenue'),loc=2)
title ('Breakeven Analysis')
show()

# Exercise #1: Use Python graphically to solve the supply and demand problem
# shown in Example 2 Section 1.2 of Lial. Compare your code and plot to the
# answer sheet.  


# Exercise #2: Using Python as a calculator, calculate the correlation 
# coefficient in Example 4 of Section 1.3 of Lial.  Compare your code and
# computed result with the answer sheet.





