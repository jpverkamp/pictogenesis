 ; Integer arithmetic
(op '+ '+ 'integer '(integer integer))
(op '- '- 'integer '(integer integer))
(op '* '* 'integer '(integer integer))
(op '/ '(λ (a b) (if (zero? b) 0 (quotient a b))) 'integer '(integer integer))
(op '% '(λ (a b) (if (zero? b) 0 (remainder a b))) 'integer '(integer integer))