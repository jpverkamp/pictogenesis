#lang racket


(provide assemble disassemble)

(require "language.rkt"
         "state.rkt")

(define (string-last str) (string-ref str (- (string-length str) 1)))
(define (string-but-last str) (substring str 0 (- (string-length str) 1)))

; Assemble a list of instructions
(define (assemble [in/str (current-input-port)])
  (define label-targets (make-hash))
  (define label-sources (make-hash))
  
  (define resulting-bytes
    (list->bytes
     (parameterize ([current-input-port (if (string? in/str) (open-input-string in/str) in/str)])
       (let loop ([index 0])
         (define next (read))
         (cond 
           ; End of program
           [(eof-object? next) '()]
           ; Label
           [(eq? #\: (string-last (string-upcase (symbol->string next))))
            (hash-set! label-targets (string->symbol (string-but-last (string-upcase (symbol->string next)))) index)
            (loop index)]
           ; Code
           [else
            ; Pull the op code
            (define op-asm (string-upcase (symbol->string next)))
            
            ; Check if it's conditional (ends with a ?)
            (define conditional? #f)
            (when (eq? #\? (string-last op-asm))
              (set! op-asm (string-but-last op-asm))
              (set! conditional? #t))
            
            ; Check if it's immediate (ends with an I, before the ? if also conditional)
            (define immediate? #f)
            (when (eq? #\I (string-last op-asm))
              (set! op-asm (string-but-last op-asm))
              (set! immediate? #t))
            
            ; Decode the op to get both the opcode and the arity
            (set! op-asm (string->symbol op-asm))
            (match-define (list op-code op)
              (for/first ([op-code (in-naturals)]
                          [op (in-vector language)]
                          #:when (equal? (op-name op) op-asm))
                (list op-code op)))
            
            ; Combine the op-code and flags
            (define bits
              (bitwise-ior
               (arithmetic-shift op-code 4)
               (arithmetic-shift (if immediate? 1 0) 3)
               (arithmetic-shift (if conditional? 1 0) 2)))
            
            ; Add that and the arguments to the vector
            ; Sometimes they'll be written as lists, decode those
            (append (list bits)
                    (for/list ([i (in-range (op-arity op))])
                      (define next (read))
                      (cond
                        [(eof-object? next) 
                         (error 'assemble "not enough arguments")]
                        [(number? next)     
                         next]
                        [(list? next)
                         (if (symbol? (first next))
                             (hash-ref named-registers (first next))
                             (first next))]
                        [(symbol? next)
                         (hash-set! label-sources (+ index i 1) (string->symbol (string-upcase (symbol->string next))))
                         #xFF]
                        [else
                         (error 'assemble "unknown argument type: ~a" next)]))
                    (loop (+ index (op-arity op) 1)))])))))
  
  (for ([(index label) (in-hash label-sources)])
    (bytes-set! resulting-bytes index (hash-ref label-targets label)))
  
  resulting-bytes)

(define (disassemble bytes)
  (let loop ([index 0] [code '()])
    
    (cond
      [(>= index (bytes-length bytes))
       (string-join (map (λ (instr) (string-join (map ~a instr)))
                         (reverse code)) 
                    "\n")]
      [else
       (define byte (bytes-ref bytes index))
       (define op-code (arithmetic-shift byte -4))
       (define immediate? (not (zero? (bitwise-and byte   #b00001000))))
       (define conditional? (not (zero? (bitwise-and byte #b00000100))))
       
       (match-define (op name arity _) (vector-ref language op-code))
       
       (define op-asm
         (string->symbol
          (~a name
              (if immediate? "!" "")
              (if conditional? "?" ""))))
       
       (cond
         [(< (+ index arity 1) (bytes-length bytes))
          (define op+args
            (cons op-asm
                  (for/list ([offset (in-range arity)])
                    (bytes-ref bytes (+ index offset 1)))))
          
          (loop (+ index arity 1)
                (cons op+args code))]
         [else
          (loop (+ index arity 1)
                (cons '(NOP) code))])])))
    
    
       
      
            
  