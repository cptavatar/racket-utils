#!/usr/local/bin/racket
#lang racket/base
;
; syncLogs.rkt
;
; Utility to rsync logs for the given environment, extract/collate the logs for the latest version deployed for
; each of the products we care about.
;

(require 
  racket/cmdline
  racket/system
  racket/string
  racket/port
  racket/set
  racket/list)

(require 
  "apptech-service.rkt"
  "shell-helper.rkt"
  "props.rkt"
  "application.rkt"
  "rsync.rkt"
  )


;; Set up our command line parameters 
;; the defaults are set here, 
;; the actual values are retrieved by calling the function
(define envp (make-parameter "qa-2"))
(define userp (make-parameter (run-with-output-trimmed "whoami")))
(command-line  #:multi
               [("-u" "--user") u "Specify user for rsync"
                                (userp u)]
               [("-e" "--env") e "Specify env for rsync"
                               (envp e)])

;; define the logs dir based on the environment
;; logs-base is property
(define logs-dir (string-append logs-base "/" (envp))) 


;; run the sync command, then clean the logs
(system (gen-rsync-cmd (userp) (envp) logs-dir))
(system (clean-logs-cmd logs-dir))

(for ([app apps])
  (let* ([most-recent-fullname (run-with-output-trimmed (most-recent-package-cmd (app-log-base app) logs-dir))]
         [version (extract-version most-recent-fullname)]
         [files (run-with-output-split (find-log-files-cmd  (logfile app) (gen-find-dir app logs-dir most-recent-fullname)))])
    (printf "App: ~a Newest:~a Version:~a \n ~a\n" app most-recent-fullname version files)
    (for ([f files])
      (system (combine-file-cmd f (string-append app "." version ".newest") logs-dir))
    )
  ))






