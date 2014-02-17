#lang racket/base

(provide (all-defined-out))

; Store the current state of a function, PC and registers are preserved on CALL/RET
(struct state (running pc reg)
  #:transparent #:mutable)

(define (state-copy s)
  (state (state-running s)
         (state-pc      s)
         (state-reg     s)))

; Current state of the VM
(define current-state (make-parameter #f))
(define current-stack (make-parameter #f))
(define current-mem   (make-parameter #f))

; Helpers to get/set the current pc/reg
(define (pc [v #f])    
  (cond
    [v    (set-state-pc! (current-state) v)]
    [else (state-pc (current-state))]))

(define (reg k [v #f]) 
  (let ([k (remainder k 16)])
    (cond
      [v    (bytes-set! (state-reg (current-state)) k v)]
      [else (bytes-ref (state-reg (current-state)) k)])))

; Update stack 
(define (stack-push) 
  (current-stack (cons (state-copy (current-state)) (current-stack))))

(define (stack-pop)  
  (begin 
    (current-state (car (current-stack)))
    (current-stack (cdr (current-stack)))))

; Get/set memory
(define (mem k [v #f])
  (let ([k (clamp k)])
    (cond
      [v    (bytes-set! (current-mem) k v)]
      [else (bytes-ref (current-mem) k)])))

; Should functions be running in immediate mode?
(define i? (make-parameter #f))
(define (reg/imm k) (if (i?) k (reg k)))

; Force all values to be bytes
(define (clamp n) (min (max n 0) 255))



; Various named registers
(define named-registers
  (hash 'R 15   ; Return value from functions
        'C 14)) ; Conditional register