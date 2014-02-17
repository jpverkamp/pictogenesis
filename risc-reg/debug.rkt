#lang racket

(provide (all-defined-out))

; Debug only printing
(define currently-debugging (make-parameter #f))
(define (debug-printf fmt . args)
  (when (currently-debugging)
    (apply printf (cons fmt args))))
