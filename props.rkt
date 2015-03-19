#lang racket/base

(provide services-prefix
         services-postfix
         cdc-prefix
         cdc-postfix
         logs-base
         logserver-tuk
         logserver-dc2)

(require json)

;; props.rkt
;; 
;; provide properties for either mutable entities, servernames, or various things I don't 
;; want to stick up on the net. Load up from JSON file located in home dir

(define (load-properties )
  (call-with-input-file (build-path (find-system-path 'home-dir ) ".cobalt.props.json") read-json))

(define props (load-properties))

(define (prop key)
  (hash-ref props key))

(define services-prefix (prop 'services-prefix))
(define services-postfix (prop 'services-postfix))
(define cdc-prefix (prop 'cdc-prefix))
(define cdc-postfix (prop 'cdc-postfix))
(define logs-base (prop 'logs-base))
(define logserver-tuk (prop 'logserver-tuk))
(define logserver-dc2 (prop 'logserver-dc2))