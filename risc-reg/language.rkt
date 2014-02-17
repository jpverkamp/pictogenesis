#lang racket/base

(require racket/function)

(provide (all-defined-out))

(require "state.rkt")

; Store operations with readable name, number of bytes to read as arguments, and the function to run
(struct op (name arity run)
  #:transparent #:mutable)

; Helpers to define simple operations
(define (monop f) (λ (a b)   (reg a (clamp (f (reg/imm b))))))
(define (binop f) (λ (a b c) (reg a (clamp (f (reg b) (reg/imm c))))))

; The actual language
(define language
  (vector 
   ; No-op
   (op 'NOP   0 (thunk (void)))
   ; Arithmetic operations
   (op 'SET   2 (monop identity))
   (op 'ADD   3 (binop +))
   (op 'SUB   3 (binop -))
   ; Logical operations
   (op 'AND   3 (binop bitwise-and))
   (op 'OR    3 (binop bitwise-ior))
   (op 'XOR   3 (binop bitwise-xor))
   ; Conditionals
   (op 'NEQ   2 (λ (a b) (reg (hash-ref named-registers 'C) (if (= (reg a) (reg/imm b)) 0 1))))
   (op 'EQ    2 (λ (a b) (reg (hash-ref named-registers 'C) (if (= (reg a) (reg/imm b)) 1 0))))
   ; Memory operations
   (op 'SAVE  2 (λ (a b) (mem a       (reg/imm b))))
   (op 'SAVEM 2 (λ (a b) (mem (reg a) (reg/imm b))))
   (op 'LOAD  1 (λ (a)   (mem a)))
   (op 'LOADM 1 (λ (a)   (mem (reg a))))
   ; Jumps
   (op 'JUMP  1 (λ (a)   (pc (reg/imm a))))
   (op 'CALL  1 (λ (a)   (begin 
                           (stack-push)
                           (pc (reg/imm a)))))
   (op 'RET   0 (λ ()    (begin
                           (cond
                             [(null? (current-stack))
                              (set-state-running! (current-state) #f)]
                             [else
                              (define ret-val (reg (hash-ref named-registers 'R)))
                              (stack-pop)
                              (pc (+ (pc) 2)) ; skip the call
                              (reg (hash-ref named-registers 'R) ret-val)]))))))