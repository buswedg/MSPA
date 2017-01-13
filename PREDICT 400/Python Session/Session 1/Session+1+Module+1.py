# MSPA 400 Session #1 Python Module #1
# Reading assignment "Think Python" either 2nd or 3rd edition:
#    2nd Edition Chapter 2, Chapter 3 (3.1 to 3.3), Chapter 8 (8.1-8.2)
#    3rd Edition Chapter 2, Chapter 3 (pages 23-25), Chapter 8 (pages 85-88)   

# Module #1 objectives: 1) demonstrate the order of operations showing
# calculations with integers and floating point numbers, 2) introduce strings
# and demonstrate string manipulations, 3) use built-in Python functions, 
# 4) demonstrate calculations using Python, and 5) execute script using
# Enthought Canopy.

# Instructions---

# Execute this script as a single program.  The results will appear below.
# To follow along it is handy to refer to the associated assignment page which
# has the output printed out.   
  
# Print statements will be used to separate sections.  Note the format for these
# statements. The \n which precedes the title causes a new line to appear.

# The first examples deal with integer calculations.  Division will truncate 
# integer calculations and the % operator will produce the remainder.  Note that
# z/y = 0 and z%y = 3.  The statement x=2 is called an assignment statement.

print ('\nInteger calculations')
x=-2
y=4
z=3
print x+y, x*y, z/x, z/y, z%x, z%y

# We repeat with floating point calculations using "float" which is a 
# built-in Python function that converts integers to floating point numbers.
# Also shown is "int" which converts floating point numbers to integers. Note
# that when an integer and floating point number are involved in the same
# calculation, the result is a floating point number.

print ('\nFloating point calculations and conversions')
x = float(x)
y = float(y)
z = float(z)
print x, y, z
print z/x, z/y, int(z/y)

print ('\nNote the type conversion integer to floating point.')
print int(z/x)*(1)        # This produces an integer.
print int(z/x)*(1.0)      # This produces a floating point number.

# Whenever there is doubt about a variable's type, the interpreter can be used.
# For any variable such as x, enter type(x) in the interpreter and the type of
# variable will be displayed.  The order of operations can be remembered using
# the acronym PEMDAS.  Note the difference between * and **.    

print ('\nOrder of Operations calculations')  
print 1+2*5, (1+2)*5, (4-2)**0.5
print  y*x, y*(1/x), y**x

# Functions and operations can be combined.  Note the use of % and int(). The  
# absolute value function is abs().  Round() will round a number to a specific
# number of decimal places.  Round(12.345,2)= 12.35.

print ('\nCombination of Functions and operations')
print int((4-2)**0.5)
print y*(1%x)             # Note that -2.0 does not divide 1 so 1%(-2.0)=-1.0.
print int(y*(1%x))

# A string is a sequence of characters.  If the sequence involves numbers,
# they are treated as characters.  The built-in function len() tells us the
# length of the string.  The first character in a string is indexed by the
# number zero.  A negative index can be used.  This starts the counting from 
# end of the string.  All indexes are placed within brackets as shown below.
# Python is memoryless.  The variables x, y and z can be defined as strings
# even though they were initially integers and then floating point numbers.

print ('\nString operations')
x='aax'
y='bbb'
z='123'
print x[0], x[2], z[-1], x*5, len(x*5)

print('\nExamples of concatenation and use of len() and indexing:')
print x+y, (x+y+z*2), len(x+y+z*2), (x+y+z*2)[6], (x+y+z*2)[-6]

# Polynomials and other equations may be coded and Python used as a calculator.
# This is demonstrated using Example 4 of Section R.4 Lial.  Note the different
# role played by % in print statements and how results are printed.

print ('\nQuadratic Formula Section R.4 Example 4 Lial\n')
a=1.0
b=-4.0
c=-5.0
root_1=(-b+(b**2-4*a*c)**0.5)/(2*a)
root_2=(-b-(b**2-4*a*c)**0.5)/(2*a)
print ('Root_1=  %r') %root_1   # %r indicates a variable will be printed.
print ('Root_2=  %r') %root_2   # %root_2 indicates root_2 is to be printed.

# A handy function is round().  It rounds to an specified number of decimal
# places.  For example round(3.14159,2)=3.14.  Check the output.

print ('\n3.14159 rounded to two decimal places is %r') %round(3.14159,2)

# Write and execute code for the following exercises.  Compare to the answer 
# sheets.  These problems can be solved using the interpreter.

# Exercise 2.4 of "Think Python" is repeated below.  Do these
# calculations.  For the value of pi, use 3.14159.  

# Exercise #1:  The volume of a sphere with radius r is (4/3)(pi)r**3.  What
# is the volume of a sphere with radius 5?  (392.6 is wrong!)

# Exercise #2:  Suppose the cover price of a book is $24.95, but bookstores get
# a 40% discount.  Shipping costs $3 for the first copy and 75 cents for each 
# additional copy.  What is the total wholesale cost for 60 copies?

# Exercise #3:  If I leave my house at 6:52 am and run 1 mile at an easy pace
# (8:15 per mile), then 3 miles at tempo (7:12 per mile) and 1 mile at easy
# pace again, what time do I get home for breakfast?

