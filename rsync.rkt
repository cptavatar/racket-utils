#lang racket
;
; rsync.rkt
; 
; All the functions required to build up our rsync command
; turns out its a bit complicated.
;
(require "props.rkt")

(provide
 gen-rsync-cmd
 )

;; generate the paths where the logs live for the given environment 
;; in the form of rsync compatible wildcards
(define (gen-remote-paths env) 
  (cond
    [(equal? env "prod") '( "social/tukpdmgsmm*/social*/*" "services/tukpdmgopen*/social*1.0.0*/*.log*" )]
    [(equal? env "dev-5") '( "social/app*/social*/*" "services/app*/social*/*"  )]
    [ else '( "social/cobnop*/social*/*" "services/cobnop*/social*/*" ) ]))

;; generate the user@server:/path string we'll use for rsync
(define (gen-server-string user env)
  (string-append user "@"
                 (cond
                   ([equal? env "prod"] (string-append logserver-tuk ":/opt/"))
                   [else (string-append logserver-dc2 ":/opt/logs/" env "/") ])))

;; create our rsync command 
(define (gen-rsync-cmd user env logs-dir)
  (string-join (list "rsync -azv"                 
                     (string-join (convert-to-include (gen-remote-paths env)))
                     "--exclude=\"*\""
                     (gen-server-string user env)
                     logs-dir
                     )))

;; given a list of of paths, convert them to rsync include
;; paths 
(define (convert-to-include path-list)
  (foldl merge '() (list
                    (foldr (lambda (x l1) 
                             (merge (foldr (lambda (y l2)
                                             (cons (string-append "--include=\"" y "\"") l2))
                                           '()
                                           (expand-path-to-list x)) l1))                 
                           '()
                           path-list )))) 

;; merge 2 lists - why isn't this built in? Or am i missing something?
(define (merge list-one list-two)
  (cond
    [(empty? list-one) list-two]
    [(empty? list-two) list-one]
    [else (merge (cdr list-one) (cons (car list-one) list-two))]))

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