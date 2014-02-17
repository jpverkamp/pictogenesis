; Real arithmetic
(op '+ '+ 'real '(real real))
(op '- '- 'real '(real real))
(op '* '* 'real '(real real))
(op '/ '(λ (a b) (if (zero? b) 0 (/ a b))) 'real '(real real))
(op '// '(λ (a b) (if (zero? b) 0.0 (/ a b))) 'real '(integer integer))