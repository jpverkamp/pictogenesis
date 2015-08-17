Stack based
===========

PUSH v - add to stack
POP - remove from stack
SWAP - swap the top two values of the stack
DUP - duplicate the top value of the stack

READ c - read a channel (r g b x y r theta)
???
???
???

ADD - pop add the top two values, push the result
SUB - same, except subtract
MUL - same, except multiply
DIV - same, except divide

LABEL v a - overwrite label v with this location, a is arity
CALL v - jump to or call label v
RET - return to last CALL location or from MAIN, push top of that stack
???

Register based
==============
each last value can either be a register or an immediate value (literal)

SET r1 r2/v - set r1 to r2/v
READ r1 c - read channel (r g b x y r theta) into r1
???
???

ADD r1 r2 r3/v is r1 = r2 + r3
SUB r1 r2 r3/v is r1 = r2 - r3
MUL r1 r2 r3/v is r1 = r2 * r3
DIV r1 r2 r3/v is r1 = r2 / r3 (integer division)

CMP r1 r2/v - set the comparison register if r1 == r2/v
???
???
???

LABEL v - overwrite a jump target here
CALL v - jump to label v (or call that function if no label), copying registers
RET - return from a function, copying register 0 back as return value
???

Functional
==========

TODO

Pre-defined functions
=====================

random - generate a random number [0, 1]
binomial m d - generate a random number with a binomial distribution (mean, std dev)

min a b - return the smaller of a and b
max a b - return the larger of a and b

sin v - sin of v
cos v - cos of v
tan v - tan of v

arcsin v - arcsin of v (?)
arccos v - arccos of v (?)
arctan v - arctan of v (?)

exp v e - calculate v ** e
log v - calculate the natural log of v
sqrt v - calculate the square root of v
