
#MSPA PREDICT 400

##Discussion Topic: Week 8 The Fundamental Theorem of Calculus

###Introduction

This document presents the results of the eigth weeks discussion topic for the Masters of Science in Predictive Analytics course: PREDICT 400. This assessment required the student to explain what the Fundamental Theorem of Calculus is and what it means, using a specific example (or examples) to illustrate their point.

###Fundamental Theorem of Calculus

The fundamental theorem of calculus is a theorem that links the concept of the derivative of a function with the concept of the function's integral.

####First Fundamental Theorem of Calculus

According to <a href = "https://en.wikipedia.org/wiki/Fundamental_theorem_of_calculus">wikipedia</a>, the first fundamental theorem of calculus holds that the definite integration of a function is related to its antiderivative, and can be reversed by differentiation.

That is, if we have a function, $F(x)$, which defines the area between some other function, $f(t)$ for all $x$ in [$a$,$b$]:

$F(x)=\int_a^xf(t)dt$

then,

$F′(x) = f(x)$

for all $x$ in [$a$,$b$].

<a href = "http://averylaird.com/blog/proving-the-first-fundamental-theorem-of-calculus-with-python/">This</a> page does a good job of explaining the theorm using Python. I have leveraged this code below.

First, find the area under the function $f(x)=x^2$ for the range of $x=1$ to $x=3$, using integrals.


```python
import scipy.integrate as integrate

a, e = integrate.quad(lambda x: x**2, 1, 3)
print(a)
```

    8.666666666666668
    

That is,

$F(x)=\int_a^xf(t)dt=8.\bar{6}$

where,

$f(x)=x^2$

For this example, we can define $f(t)$ with a variable amount of increments (rectangles) using Riemann sums. We do this by first declaring a function to return area under $x^2$ for the given range, based on a variable amount of increments.


```python
def f(t): 
    return t**2
```

Check using four rectangles:


```python
delta_x = (3-1)/4

area = 0
for n in range(3, 7):
    area += float(delta_x) * f(delta_x*n)
print(area)
```

    10.75
    

Check using 50 rectangles:


```python
delta_x = (3-1)/50

area = 0
for n in range(1, 51):
    area += float(delta_x) * f(delta_x*n + 1)
print(area)
```

    8.827200000000001
    

Using 1000 rectangles:


```python
delta_x = (3-1)/1000

area = 0
for n in range(1, 1001):
    area += float(delta_x) * f(delta_x*n + 1)
print(area)
```

    8.674667999999999
    

We can see that as we increase the amount of increments towards infinity, $f(t)$ moves closer towards the integrated solution.

We then define $F(x)$, which calls $\int_a^xf(t)dt$ for any given amount of increments over the desired range.


```python
def F(x):
    delta_x = float((3-1)/x)
    area = 0
    for n in range(1, x+1):
        area += float(delta_x) * f(delta_x*n + 1)
    return area
```

Check using four rectangles:


```python
F(4)
```




    10.75



Check using 50 rectangles:


```python
F(50)
```




    8.827200000000001



Check using 1000 rectangles:


```python
F(1000)
```




    8.674667999999999



We have now proven that we have working definitions within Python for both $F(x)$ and $\int_a^xf(t)dt$.

Finally, it can be shown that $F′(x) = f(x)$:


```python
def F(x, rectangles=1000):
    delta_x = float((x-1)/rectangles)
    area = 0
    for n in range(1, rectangles+1):
        area += float(delta_x) * f(delta_x*n + 1)
    return area

def derivative(f, h=0.1e-5):
    def df(x):
        return (f(x+h/2) - f(x-h/2))/h
    return df

d = derivative(F)
```


```python
print(d(2))
print(f(2))
```

    4.003500499560886
    4
    


```python
print(d(3))
print(f(3))
```

    9.010001999598671
    9
    

####Second Fundamental Theorem of Calculus

According to <a href = "https://en.wikipedia.org/wiki/Fundamental_theorem_of_calculus">wikipedia</a>, the second fundamental theorem of calculus is that that the definite integral of a function can be computed by using any one of its infinitely-many antiderivatives.

That is, if we have a function, $F(x)$, which defines the area between some other function, $f(t)$ for all $x$ in [$a$,$b$] and the first theorem holds:

$F′(x) = f(x)$

then,

$\int_a^bf(x)dx = F(b)-F(a)$

for all $x$ in [$a$,$b$]

Again, we first find the area under the function $f(x)=x^2$ for the range of $x=1$ to $x=3$, using integrals.


```python
import scipy.integrate as integrate

a, e = integrate.quad(lambda x: x**2, 1, 3)
print(a)
```

    8.666666666666668
    

By leveraging the definition for $F(x)$ shown above, we can find $F(b)-F(a)$


```python
F(3) - F(1)
```




    8.674667999999999


