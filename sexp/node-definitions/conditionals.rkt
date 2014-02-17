; Necessary constants
(terminal 'true #t 'boolean)
(terminal 'false #f 'boolean)

; If statements returning numeric values
(op 'if 'if 'integer '(boolean integer integer))
(op 'if 'if 'real '(boolean real real))

; Different behavior depending on which band you are in
(op 'band-cond '(λ (a b c) (case k [(0) a] [(1) b] [(2) c])) 'real '(real real real))

; Logical operators
(op 'and 'and 'boolean '(boolean boolean))
(op 'or  'or  'boolean '(boolean boolean))
(op 'not 'not 'boolean '(boolean))
(op 'xor '(λ (a b) (or (and a (not b)) (and b (not a)))) 'boolean '(boolean boolean))

; Comparators
(op '< '< 'boolean '(integer integer))
(op '< '< 'boolean '(real real))
(op '= '= 'boolean '(integer integer))
(op '= '= 'boolean '(real real))
(op '> '> 'boolean '(integer integer))
(op '> '> 'boolean '(real real))

; Numeric tests
(op 'zero? 'zero? 'boolean '(integer))
(op 'even? 'even? 'boolean '(integer))
(op 'odd? 'odd? 'boolean '(integer))
(op '>0.5 '(λ (x) (> 0.5 x)) 'boolean '(real))
