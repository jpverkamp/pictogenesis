#lang racket

(require "state.rkt"
         "language.rkt"
         "assembler.rkt"
         "evaluator.rkt")

(require images/flomap)

(define subdirectory (symbol->string (gensym)))
(make-directory* (build-path "images" subdirectory))

(define PROGRAM-LENGTH 256)
(define FUEL 256)

(printf "run ~a\n" subdirectory)

(let loop ([i 0])
  (flush-output)
  
  (define program (list->bytes (for/list ([i (in-range PROGRAM-LENGTH)]) (random 256))))
  (define function (->function program #:fuel FUEL))
  
  (define boring? #t)
  (define pixel #f)
  
  (define start-rendering (current-inexact-milliseconds))
  (define rendered
    (flomap->bitmap
     (build-flomap 
      3 100 100 
      (λ (k x y)
        (define c (function k x y))
        (when (not pixel) (set! pixel c))
        (when (not (= pixel c)) (set! boring? #f))
        (/ c 256.0)))))
  (define end-rendering (current-inexact-milliseconds))
  (define time-to-render (/ (- end-rendering start-rendering) 1000))
  
  (cond
    [boring? 
     (printf "boring in ~a seconds, skipping\n" time-to-render)
     (loop i)]
    [else
     (define filename 
       (build-path "images" 
                   subdirectory
                   (~a i #:min-width 8 #:align 'right #:left-pad-string "0")))
     
     (printf "interesting in ~a seconds, saving as ~a\n" time-to-render filename)
     (with-output-to-file (~a filename ".txt")
       (λ ()
         (displayln (disassemble program))))
     
     (send rendered save-file (~a filename ".png") 'png)
     (loop (+ i 1))]))