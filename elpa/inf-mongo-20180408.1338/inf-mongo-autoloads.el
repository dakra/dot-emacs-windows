;;; inf-mongo-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from inf-mongo.el

(let ((loads (get 'inf-mongo 'custom-loads))) (if (member '"inf-mongo" loads) nil (put 'inf-mongo 'custom-loads (cons '"inf-mongo" loads)) (put 'inf-mongo 'custom-loads (cons 'inf-mongo (get 'inf-mongo 'custom-loads)))))
(defvar inf-mongo-command "/usr/local/bin/mongo 127.0.0.1:27017" "\
Default MongoDB shell command used.")
(custom-autoload 'inf-mongo-command "inf-mongo" t)
(defvar inf-mongo-mode-hook nil "\
*Hook for customizing inf-mongo mode.")
(custom-autoload 'inf-mongo-mode-hook "inf-mongo" t)
(autoload 'inf-mongo "inf-mongo" "\
Major mode for interacting with an inferior MongoDB shell (mongo) process.

The following commands are available:
\\{inf-mongo-mode-map}

A MongoDB shell process can be fired up with M-x inf-mongo.

Customisation: Entry to this mode runs the hooks on comint-mode-hook and
inf-mongo-mode-hook (in that order).

(fn CMD &optional DONT-SWITCH-P)" t)
(autoload 'mongo-send-region "inf-mongo" "\
Send the current region to the inferior MongoDB process.

(fn START END)" t)
(autoload 'mongo-send-region-and-go "inf-mongo" "\
Send the current region to the inferior MongoDB process.

(fn START END)" t)
(autoload 'mongo-send-last-sexp-and-go "inf-mongo" "\
Send the previous sexp to the inferior Mongo process." t)
(autoload 'mongo-send-last-sexp "inf-mongo" "\
Send the previous sexp to the inferior MongoDB process." t)
(autoload 'mongo-send-buffer "inf-mongo" "\
Send the buffer to the inferior MongoDB process." t)
(autoload 'mongo-send-buffer-and-go "inf-mongo" "\
Send the buffer to the inferior MongoDB process." t)
(autoload 'switch-to-inf-mongo "inf-mongo" "\
Switch to the MongoDB process buffer.
With argument, position cursor at end of buffer.

(fn EOB-P)" t)
(defvar inf-mongo-mode-map (let ((map (make-sparse-keymap))) (define-key map "" 'mongo-send-last-sexp) map))
(autoload 'inf-mongo-mode "inf-mongo" "\


(fn)" t)
(register-definition-prefixes "inf-mongo" '("inf-mongo-"))

;;; End of scraped data

(provide 'inf-mongo-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; inf-mongo-autoloads.el ends here
