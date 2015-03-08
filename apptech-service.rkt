#lang racket/base

(provide retrieve-json 
         build-cdc-url
         build-services-url
         create-active-map)

(require net/url)
(require racket/port)
(require json)
(require racket/set)
(require racket/string)
(require racket/format)

(require "props.rkt")

(define props (load-properties))

(define (retrieve-json urlstring)
  (call/input-url (string->url urlstring)
                get-pure-port
                read-json))

(define (build-services-url env)
  (string-append services-prefix env services-postfix))

(define (build-cdc-url env)
  (string-append cdc-prefix (env) cdc-postfix))


(define (create-active-map env app-set)
  (for/fold ([x (hash)])
            ([app (retrieve-json (build-cdc-url env))]
             #:when (and (set-member? app-set (hash-ref app 'name))
                      (hash-ref app 'active)))
     (hash-set x (hash-ref app 'name)(hash-ref app 'candidate))))

;(define (create-node-map env)
;  (for/fold ([x (hash)])
 ;           ([
  
  ;)