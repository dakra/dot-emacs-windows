;; Disable Tool- and Menubar in the early-init file via
;; =default-frame-alist=. This is slightly faster than first loading the
;; tool-/menu-bar and then turning it off again.
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)

;; Since Emacs 27.1 we have to disable package.el in the early init file.
(setq package-enable-at-startup nil)

;; Put native compilation cache in no-litter var folder.
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))
