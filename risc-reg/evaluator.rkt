#lang racket

(provide (all-defined-out))

(require "assembler.rkt"
         "debug.rkt"
         "language.rkt"
         "state.rkt")
         

; Run a program
(define (run program [initial-registers '()] #:fuel [fuel +inf.0])
  ; Set up the program 
  (parameterize ([current-state (state #t 0 (list->bytes (append initial-registers (make-list (- 16 (length initial-registers)) 0))))]
                 [current-stack '()]
                 [current-mem   (bytes-append program (make-bytes (- 256 (bytes-length program)) 0))])
    ; Run until we either run out of fuel or hit a RET
    (let loop ([fuel fuel])
      (debug-printf "
   pc: ~s
 regs: ~s
stack: ~s
  mem: ~s
" 
              (pc) 
              (bytes->list (state-reg (current-state)))
              (current-stack)
              (bytes->list (current-mem)))
      
      (when (and (state-running (current-state)) (> fuel 0))
        ; Get the next instruction
        (define pc-now (pc))
        (define mem-now (mem pc-now))
        
        (define opcode     (arithmetic-shift (bitwise-and #b11110000 mem-now) -4))
        (define immediate? (= 1 (arithmetic-shift (bitwise-and #b00001000 mem-now) -3)))
        (define skipped?   (and (= 1 (arithmetic-shift (bitwise-and #b00000100 mem-now) -2))
                                (zero? (reg (hash-ref named-registers 'C)))))
        
        ; Use conditional and immediate flags, then run the command
        ; Update the PC if we didn't jump
        (parameterize ([i? immediate?])
          (define op (vector-ref language opcode))
          (define args (for/list ([i (in-range (op-arity op))]) (mem (+ (pc) i 1))))
          (debug-printf "~a~a~a ~a\n" (if skipped? "(skip) " "") (op-name op) (if immediate? "i" "") args)
          
          (when (not skipped?)
            (apply (op-run op) args))
              
          (when (= pc-now (pc))
            (pc (+ (pc) (op-arity op) 1))))
        
        ; Use up some fuel each loop
        (loop (- fuel 1))))
    
    ; Return value is the RET register
    (reg (hash-ref named-registers 'R))))

; Convert a string, bytes, or an assembled program into a Racket function
(define (->function [in/str/bytes (current-input-port)] #:fuel [fuel +inf.0])
  (define bytecode (if (bytes? in/str/bytes) in/str/bytes (assemble in/str/bytes)))
  (λ args
    (run bytecode args #:fuel fuel)))