; Based on band or coordinate of a given pixel (in the range [0.0, 1.0])
(terminal 'k '(/ k bands) 'real)
(terminal 'x '(/ x width) 'real)
(terminal 'y '(/ y height) 'real)

; Coordinates of a given pixel in polar notation
(terminal 'r '(let ([x (/ x width)]
                    [y (/ y height)])
                (sqrt (+ (* x x) (* y y)))) 'real)

(terminal 'θ '(if (zero? x)
                  0
                  (let ([x (/ x width)]
                        [y (/ y height)])
                    (atan (/ y x)))) 'real)

; Constants
(terminal 0 0.0 'real)
(terminal 0.5 0.5 'real)
(terminal 1 1.0 'real)