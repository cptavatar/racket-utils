#!/usr/local/bin/racket
#lang racket/base
(require racket/cmdline)
(require racket/system)
(require racket/string)
(require racket/port)
(require racket/set)
(require racket/list)

(require "apptech-service.rkt")
(require "props.rkt")

; syncLogs.rkt
;
; Utility to rsync logs for the given environment, extract/collate the logs for the latest version deployed for
; each of the products we care about. 

(define env (make-parameter "qa-2"))
(define user (make-parameter (string-trim (with-output-to-string (lambda () (system "whoami"))))))

(define apps (list->set '("socialnetworkservice"
                          "socialdashboard" 
                          "socialbatch" 
                          "social" 
                          "socialmanager-server"
                          "socialsyndicationservice")))

(define versioned-set (list->set '("socialnetworkservice"
                                   "socialdashboard" 
                                   "social" 
                                   "socialmanager-server")))

(command-line  #:multi
               [("-u" "--user") u "Specify user for rsync"
                                (user u)]
               [("-e" "--env") e "Specify env for rsync"
                               (env e)])


(define (warpackage package)
  (cond 
    [(equal? package "socialplatform-batch") "socialplatform-batch-1.0"]
    [(equal? package "socialsyndication") "socialsyndication-webapp-1.0"]
    [ else (string-append package "_1.0.0")]))

(define (offset-url package active-version)
  (string-append "/" 
                 (warpackage package) 
                 (if (set-member? versioned-set package)
                     (string-append "-" active-version)
                     "")))

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

;; given a path string like "a/b/c", return a list 
;; of subpaths like '("a" "a/b" "a/b/c")
(define (expand-path-to-list path)
  (define (expand-path-to-list from-list to-list)
    (if (empty? from-list) 
        to-list
        (expand-path-to-list (cdr from-list) 
                          (cons (if (empty? to-list)
                                    (car from-list)
                                    (string-append  (car to-list) "/" (car from-list))) 
                                to-list)))
    )(expand-path-to-list (string-split path "/" ) '()))

;; merge 2 lists - why isn't this built in? Or am i missing something?
(define (merge list-one list-two)
  (cond
     [(empty? list-one) list-two]
     [(empty? list-two) list-one]
     [else (merge (cdr list-one) (cons (car list-one) list-two))]))

;; given a list of of paths, covert them to rsync include
;; paths 
(define (convert-to-include path-list)
    (foldl merge '() (list
      (foldr (lambda (x l1) 
               (merge (foldr (lambda (y l2)
                             (cons (string-append "--include=\"" y "\"") l2))
                      '()
                      (expand-path-to-list x)) l1))                 
             '()
             path-list
      ))))     

(define (gen-remote-paths) 
  (cond
    [(equal? (env) "prod") '( "tukpdmgsmm*/social*/*" "tukpdmgopen*/social*1.0.0*/*.log*" )]
    [(equal? (env) "dev-5") '( "social/app*/social*/*" "services/app*/social*/*"  )]
    [ else '( "social/cobnop*/social*/*" "services/cobnop*/social*/*" ) ]))
    
(define (gen-server-string)
  (string-append (user) "@"
                 (cond
                   ([equal? (env) "prod"] (string-append logserver-tuk ":/cobalt/logs/services/"))
                   [else (string-append logserver-dc2 ":/opt/logs/" (env) "/") ])))

(define (gen-rsync-cmd )
   (string-join (list "rsync -azv"                 
                       (string-join (convert-to-include (gen-remote-paths)))
                       "--exclude=\"*\""
                       (gen-server-string)
                       (string-append logs-home "/" (env))
                       )))

(define cmd (gen-rsync-cmd))

;(system (gen-rsync-cmd))

;; figure out the most recent version of an application
(define (most-recent-package app)
  (printf "~a" (with-output-to-string (lambda () (system (string-append "ls " logs-home "/" (env) "/*/* | grep \"" app "-\" | grep \"v-1\" | sort -r | head -1 "
                     ))))))
