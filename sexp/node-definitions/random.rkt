; Random numbers
(op 'random 'random 'real '())
(op 'birandom '(λ () (if (> (random) 0.5) 1.0 0.0)) 'real '())