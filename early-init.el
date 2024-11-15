(setq load-prefer-newer t)

;; Since Emacs 27.1 we have to disable package.el in the early init file.
(setq package-enable-at-startup nil)

;; Put native compilation cache in no-litter var folder.
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))
