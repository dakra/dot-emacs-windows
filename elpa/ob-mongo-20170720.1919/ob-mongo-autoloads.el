;;; ob-mongo-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from ob-mongo.el

(autoload 'org-babel-execute:mongo "ob-mongo" "\
org-babel mongo hook.

(fn BODY PARAMS)")
(eval-after-load "org" '(add-to-list 'org-src-lang-modes '("mongo" . js)))
(register-definition-prefixes "ob-mongo" '("ob-mongo"))

;;; End of scraped data

(provide 'ob-mongo-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; ob-mongo-autoloads.el ends here
