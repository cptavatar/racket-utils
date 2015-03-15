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

;; Retrive json from a URL
(define (retrieve-json urlstring)
  (call/input-url (string->url urlstring)
                  get-pure-port
                  read-json))

;; build up the base url for what nodes are available for which versions for an env
(define (build-services-url env)
  (string-append services-prefix env services-postfix))

;; build up the base url to figure out which service versions are active
(define (build-cdc-url env)
  (string-append cdc-prefix (env) cdc-postfix))

;; for a given env and set of applications we care about, build
;; up a hashtable of app to active version
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