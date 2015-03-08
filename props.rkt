#lang racket/base

(provide services-prefix
         services-postfix
         cdc-prefix
         cdc-postfix
         logs-home)

(require json)

(define (load-properties )
  (call-with-input-file (build-path (find-system-path 'home-dir ) ".cobalt.props.json") read-json))

(define props (load-properties))

(define (prop key)
  (hash-ref props key))

(define services-prefix (prop 'services-prefix))
(define services-postfix (prop 'services-postfix))
(define cdc-prefix (prop 'cdc-prefix))
(define cdc-postfix (prop 'cdc-postfix))
(define logs-home (prop 'logs-home))