#lang racket/base

(require racket/string)

(provide (struct-out node)
         (struct-out terminal)
         (struct-out op))

; Special writer for the nodes that will print eval'able writes
(define (write-node node port mode)
  (case mode
    [(#t) 
     (define rep (struct->vector node))
     (vector-set! rep 0 (string->symbol 
                         (car
                          (reverse
                           (string-split
                            (symbol->string (vector-ref rep 0))
                            ":")))))
     (write (vector->list rep) port)]
    [(#f) (fprintf port "~a:~a" (node-name node) (node-type node))]
    [else (fprintf port "~a:~a" (node-name node) (node-type node))]))

; Base node with common structures, don't create these directly
(struct node (name value type)
  #:transparent
  #:methods gen:custom-write
  [(define write-proc write-node)])

; Terminals are evaluated directly rather than taking arguments
(struct terminal node () #:transparent)

; Ops can have zero or more typed arguments which turn into a single value
(struct op node (subtypes)  #:transparent)