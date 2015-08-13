#lang racket

(require "state.rkt"
         "language.rkt"
         "assembler.rkt"
         "evaluator.rkt")

(define (random-program)
  (list->bytes (for/list ([i (in-range 256)]) (random 256))))

(define (random-function #:fuel [fuel +inf.0])
  (->function (random-program) #:fuel fuel))

(require images/flomap)
(define non-zero #f)

(define (random-image #:fuel [fuel +inf.0])
  (define f (random-function #:fuel fuel))
  (flomap->bitmap
   (build-flomap 3 100 100 (λ (k x y)
                             (define c (f k x y))
                             (when (not (zero? c)) (set! non-zero #t))
                             (/ c 256.0)))))

(let loop ([i 0])
  (make-directory* "images")
  (define fn 
    (build-path "images" 
                (format "~a.png" 
                        (~a i #:min-width 8 #:align 'right #:left-pad-string "0"))))
  (printf "~a\n" fn)
  
  (set! non-zero #f)
  (define start (current-inexact-milliseconds))
  (define bmp (random-image #:fuel 100))
  (printf "took ~a seconds\n" (/ (- (current-inexact-milliseconds) start) 1000))
  (if non-zero
      (send bmp save-file fn 'png)
      (printf "boring...\n"))
  
  (loop (+ i 1)))
