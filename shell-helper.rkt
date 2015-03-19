#!/usr/local/bin/racket

#lang racket/base

(require 
  racket/port
  racket/system
  racket/string
         )

(provide run-with-output
         run-with-output-trimmed
         most-recent-package-cmd
         find-log-files-cmd
         clean-logs-cmd)



(define (run-with-output cmd)
  (with-output-to-string (lambda () (system cmd))))

(define (run-with-output-trimmed cmd)
  (string-trim (run-with-output cmd)))
  

(define (most-recent-package-cmd app logs-dir)
  (string-append "ls " logs-dir "/*/* | grep \"" app "-\" | grep \"v-1\" | sort -r | head -1 "
                     ))

(define (find-log-files-cmd pkg-version log-name logs-dir)
  (string-append "find " logs-dir "/*/*/" pkg-version " -name " log-name ".log"))

(define (combine-file-cmd file pkg-version logs-dir)
  (string-append "cat " file " >> " logs-dir "/" pkg-version ".log"))

(define (clean-logs-cmd logs-dir )
  (string-append "rm " logs-dir "/*.log"))