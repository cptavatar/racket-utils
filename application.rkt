#lang racket
;
; application.rkt
; 
; the applications we are are working with: their names, 
; their paths, their versions, etc
;
(provide 
 apps
 versioned-set
 extract-version
 logfile
 app-log-base
 gen-find-dir
 )

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

;; Extract the version from a pkg string
(define (extract-version pkg-string)
  (let ([match (regexp-match #px"c\\d+" pkg-string)])
    (if (pair? match)
        (car match)
        "not-found"
        )))

;; sadly, our naming conventions are not uniform.
;; handle some of the differences
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
(define (app-log-base package)
  (cond 
    [(equal? package "socialmanager-server") "socialmanager-server_1.0"]
    [ else (string-append package "-1.0.0")]))

(define (gen-find-dir app logs-dir pkg-version)
  (string-append
   logs-dir "/*/*/" pkg-version (if (equal? app "socialmanager-server") "/*" "")))

(define (logfile package)
  (cond 
    [(equal? package "socialnetworkservice") "socialnetwork.log"]
    [(equal? package "socialsyndicationservice") "socialsyndication.log"]
    [(equal? package "socialmanager-server") "*.[eo][ru][tr]"]
    [(equal? package "social") "socialplatform.log"]
    [ else (string-append package ".log")]))

(define (version-exists logs-home-env package)
  (cond 
    [(equal? package "socialnetworkservice") "socialnetwork"]
    [(equal? package "socialsyndicationservice") "socialsyndication"]
    [ else package]))
