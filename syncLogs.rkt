#!/usr/local/bin/racket
#lang racket/base
(require racket/cmdline)
(require racket/system)
(require racket/string)
(require racket/port)

; syncLogs.rkt
;
; Utility to rsync logs for the given environment, extract/collate the logs for the latest version deployed for
; each of the products we care about. 

(define env (make-parameter "qa-2"))
(define user (make-parameter (string-trim (with-output-to-string (lambda () (system "whoami"))))))
(define logs-home "~/Documents/logs")

(command-line  #:multi
               [("-u" "--user") u "Specify user for rsync"
                                (user u)]
               [("-e" "--env") e "Specify env for rsync"
                               (env e)]
               )

(define (warpackage package)
  (cond 
    [(equal? package "socialplatform") "socialplatform-service-1.0"]
    [(equal? package "socialnetworkservice") "socialnetwork-service-1.0"]
    [(equal? package "socialsyndicationservice") "socialsyndication-service-1.0"]
    [ else (string-join package "-webapp-1.0")]))

(define (logfile package)
  (cond 
    [(equal? package "socialnetworkservice") "socialnetwork"]
    [(equal? package "socialsyndicationservice") "socialsyndication"]
    [ else package]))

(define (version-exists logs-home-env package)
  (cond 
    [(equal? package "socialnetworkservice") "socialnetwork"]
    [(equal? package "socialsyndicationservice") "socialsyndication"]
    [ else package]))
;(define (collateSide file side package)
;  (if (equal? "socialplatform" package)
;      (define warpackage (
  
;  ))))

(printf "Given arguments: ~s ~s\n"
          (env) (user))
