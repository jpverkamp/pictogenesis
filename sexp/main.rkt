#lang racket

(require "structs.rkt"
         racket/runtime-path)

(define current-terminal-bias (make-parameter 0.5))

(define (choose v)
  (vector-ref v (random (vector-length v))))

(define-runtime-path root-path ".")

(define nodes
  (list->vector 
   (apply 
    append
    (for/list ([path (in-directory (build-path root-path "node-definitions"))]
               #:when (equal? #"rkt" (filename-extension path)))
      
      (define ns (make-base-namespace))
      (eval `(define terminal ,terminal) ns)
      (eval `(define op ,op) ns)
      
      (filter identity
              (for/list ([sexp (in-list (file->list path))])
                (define node (eval sexp ns))
                (and (node? node) node)))))))

(define (random-code type)
  (define which?
    (match (random)
      [(? (curryr < (current-terminal-bias)))
       terminal?]
      [_
       op?]))
       
  (let loop ()
    (define node (choose nodes))
    (cond
      [(or (not (eq? type (node-type node)))
           (not (which? node)))
       (loop)]
      [(terminal? node)
       node]
      [(op? node)
       (cons node (for/list ([type (in-list (op-subtypes node))])
                    (random-code type)))])))

(require images/flomap)
(define ns (make-base-namespace))

(define (sexp->code sexp)
  (cond
    [(list? sexp) (map sexp->code sexp)]
    [else
     (define parts (string-split (symbol->string sexp) ":"))
     (define name:number (string->number (first parts)))
     (define name:symbol (string->symbol (first parts)))
     (define type (string->symbol (second parts)))
     (for/first ([node (in-vector nodes)]
                 #:when (and (eq? type (node-type node))
                             (or (eq? name:number (node-name node))
                                 (eq? name:symbol (node-name node)))))
       node)]))

(define (code->ast code)
  (cond
    [(list? code) (map code->ast code)]
    [else
     (for/first ([node (in-vector nodes)]
                 #:when (eq? code node))
       (node-value code))]))

(define (ast->f ast width height)
  (eval
   `((λ (bands width height)
       (λ (k x y)
         (min (max ,ast 0.0) 1.0)))
     3 ,width ,height)
   ns))

(define (make-image code width height)
  (define f
    (cond
      [(procedure? code) code]
      [(or (node? code) (and (list? code) (node? (first code))))
       (ast->f (code->ast code) width height)]
      [(or (symbol? code) (and (list? code) (symbol? (first code))))
       (ast->f (code->ast (sexp->code code)) width height)]
      [(string? code)
       (ast->f (code->ast (sexp->code (with-input-from-string code read))) width height)]
      [(input-port? code)
       (ast->f (code->ast (sexp->code (read code))) width height)]
      [else
       (error 'make-image "unknown code format: ~a" code)]))
  
  (flomap->bitmap
   (build-flomap 3 width height f)))

(for/list ([i (in-range 10)])
  (define c (random-code 'real))
  (list (make-image c 256 256) c))
