;;; dogears-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:



;;; Generated autoloads from dogears.el

(defvar dogears-mode nil "\
Non-nil if Dogears mode is enabled.
See the `dogears-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `dogears-mode'.")
(custom-autoload 'dogears-mode "dogears" nil)
(autoload 'dogears-mode "dogears" "\
Never lose your place again.

Like dogeared pages in a book, Dogears mode keeps track of where
you've been and helps you retrace your steps.

This is a global minor mode.  If called interactively, toggle the
`Dogears mode' mode.  If the prefix argument is positive, enable
the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `(default-value \\='dogears-mode)'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(autoload 'dogears-remember "dogears" "\
Remember (\"dogear\") the current place.

(fn &rest IGNORE)" t)
(autoload 'dogears-go "dogears" "\
Go to dogeared PLACE.
Interactively, select PLACE with completion; with universal
prefix, offer all places, otherwise only ones relevant to current
context.  PLACE should be a bookmark record.

(fn PLACE)" t)
(autoload 'dogears-list "dogears" "\
Show dogears list." t)
(autoload 'dogears-sidebar "dogears" "\
Show the Dogears list in a side window." t)
(register-definition-prefixes "dogears" '("dogears-"))

;;; End of scraped data

(provide 'dogears-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; dogears-autoloads.el ends here
