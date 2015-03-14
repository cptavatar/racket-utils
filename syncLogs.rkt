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
;; of subpaths like '("a/b/c" "a/b" "a")
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

;; given a list of of paths, covert them to rsync include
;; paths while making sure to remove duplicates
(define (convert-to-include path-list)
  (let ([x (mutable-set)])
    (for ([path path-list])
      (for ([elem (map (lambda (y) (string-append "--include=\"" y "\"")) (expand-path-to-list path))])
        (set-add! x elem )
      ))
    (set->list x)
  ))

(define (gen-remote-paths) 
  (cond
    ([equal? e "prod"] '( "tukpdmgsmm*/social*/*" "tukpdmgopen*/social*1.0.0*/*.log*" ))
    ([equal? e "dev-5"] '( ))
    [ else '() ]))
    
(define (gen-server-string)
  (string-append (user) "@"
                 (cond
                   ([equal? e "prod"] (string-append logserver-tuk ":/cobalt/logs/services/"))
                   [else (string-append logserver-dc2 ":/opt/logs/" (env) "/services/") ])))

(define (rsync paths)
  (system (string-join "rsync -avz" 
                       (string-join (convert-to-include paths)))))
                       
                       