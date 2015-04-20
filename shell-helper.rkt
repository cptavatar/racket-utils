#lang racket/base

;
; shell-helper.rkt
;
; functions for interacting with the shell
;

(require 
  racket/port
  racket/system
  racket/string
         )

(provide run-with-output
         run-with-output-trimmed
         run-with-output-split
         most-recent-package-cmd
         find-log-files-cmd
         combine-file-cmd
         clean-logs-cmd)



(define (run-with-output cmd)
  (with-output-to-string (lambda () (system cmd))))

(define (run-with-output-trimmed cmd)
  (string-trim (run-with-output cmd)))

(define (run-with-output-split cmd)
  (string-split (run-with-output cmd) "\n" ))

(define (most-recent-package-cmd app-base logs-dir )
  (string-append "ls " logs-dir "/*/* | grep " app-base " | sort -r | head -1 "
                     ))

(define (find-log-files-cmd log-name find-dir)
  (string-append "find " find-dir " -name " log-name ))

(define (combine-file-cmd file new-name logs-dir)
  (string-append "cat " file " >> " logs-dir "/" new-name ".log"))

(define (clean-logs-cmd logs-dir )
  (string-append "rm " logs-dir "/*.log"))