;;; init.el --- user-init-file                    -*- lexical-binding: t -*-

;; Deactivate tool- and menu-bar for terminal Emacs. (For GUI it's disabled in early-init.el)
(tool-bar-mode -1)
(menu-bar-mode -1)
;; Disable the scroll-bar
(scroll-bar-mode -1)

(setq gc-cons-threshold (* 256 1024 1024))  ;; 256MB

;; Disable startup screen and startup echo area message and select the scratch buffer by default
(setq inhibit-startup-buffer-menu t)
(setq inhibit-startup-screen t)
(setq inhibit-startup-echo-area-message user-login-name)
(setq initial-buffer-choice t)
(setq initial-scratch-message nil)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq use-package-enable-imenu-support t)
(require 'use-package)
(if nil  ; Toggle init debug
    (setq use-package-verbose t
          use-package-expand-minimally nil
          use-package-compute-statistics t
          debug-on-error t)
  (setq use-package-verbose nil
        use-package-expand-minimally t))

(use-package bind-key :defer t)

(use-package no-littering
  :demand t
  :config
  (setq server-auth-dir (no-littering-expand-var-file-name "server"))
  ;; /etc is version controlled and I want to store mc-lists in git
  (setq mc/list-file (no-littering-expand-etc-file-name "mc-list.el"))
  ;; Put the auto-save and backup files in the var directory to the other data files
  (no-littering-theme-backups))

(use-package emacs
  :config
  ;; Compile loaded .elc files asynchronously
  (setq native-comp-jit-compilation t
        native-comp-async-jobs-number 4)

  ;; NOTE: To compile eln files you first have to byte-compile them with something like:
  ;; (byte-recompile-directory (expand-file-name "~/.emacs.d/elpa") 0)

  (add-to-list 'default-frame-alist '(font . "Fira Code-10:weight=regular:width=normal"))
  (set-frame-font "Fira Code-10:weight=regular:width=normal" nil t)
  (set-fontset-font t 'emoji (font-spec :family "Segoe UI Emoji") nil 'append)

  ;; (require-theme 'modus-themes) ; `require-theme' is ONLY for the built-in Modus themes

  ;; Add all your customizations prior to loading the themes
  ;; (setq modus-themes-italic-constructs t
  ;;       modus-themes-bold-constructs nil)

  ;; Load the theme of your choice.
  ;; (load-theme 'modus-vivendi)

  ;; Register all left windows-key presses as "super".
  ;; Doesn't work for "s-l" as this always locks Windows on a low level.
  (if (eq system-type 'windows-nt)
      (progn
        (prefer-coding-system 'utf-8-dos)

        (setq w32-lwindow-modifier 'super
              w32-pass-lwindow-to-system nil
              w32-pass-alt-to-system nil)
        (w32-register-hot-key [M-])
        (w32-register-hot-key [s-]))
    (prefer-coding-system 'utf-8))

  ;; Always just use left-to-right text. This makes Emacs a bit faster for very long lines
  (setq-default bidi-paragraph-direction 'left-to-right)

  (setq-default indent-tabs-mode nil)  ;; Don't use tabs to indent
  (setq-default tab-width 4)
  (setq tab-always-indent 'complete)  ;; smart tab behavior - indent or complete
  (setq require-final-newline t)  ;; Newline at end of file
  (setq mouse-yank-at-point t)  ;; Paste with middle mouse button doesn't move the cursor
  (delete-selection-mode t)  ;; Delete the selection with a keypress
  (setq auth-source-save-behavior nil)  ;; Don't ask to store credentials in .authinfo.gpg
  (setq truncate-string-ellipsis "…")  ;; Use 'fancy' ellipses for truncated strings

  ;; Focus follows mouse for Emacs windows and frames
  (setq mouse-autoselect-window t)
  (setq focus-follows-mouse t)

  ;; Activate character folding in searches i.e. searching for 'a' matches 'ä' as well
  (setq search-default-mode 'char-fold-to-regexp)

  ;; Only split horizontally if there are at least 90 chars column after splitting
  (setq split-width-threshold 180)
  ;; Only split vertically on very tall screens
  (setq split-height-threshold 120)

  ;; Save whatever’s in the current (system) clipboard before
  ;; replacing it with the Emacs’ text.
  (setq save-interprogram-paste-before-kill t)

  ;; Accept 'UTF-8' (uppercase) as a valid encoding in the coding header
  (define-coding-system-alias 'UTF-8 'utf-8)

  ;; Increase the amount of data which Emacs reads from the process
  ;; (Useful for LSP where the LSP responses are in the 800k - 3M range)
  (setq read-process-output-max (* 1024 1024)) ;; 1mb

  ;; Allow some commands as safe by default
  ;; allow horizontal scrolling with "M-x >"
  (put 'scroll-left 'disabled nil)
  ;; enable narrowing commands
  (put 'narrow-to-region 'disabled nil)
  (put 'narrow-to-page 'disabled nil)
  (put 'narrow-to-defun 'disabled nil)
  ;; enabled change region case commands
  (put 'upcase-region 'disabled nil)
  (put 'downcase-region 'disabled nil)
  ;; enable erase-buffer command
  (put 'erase-buffer 'disabled nil)

  ;; Enable y/n answers
  (fset 'yes-or-no-p 'y-or-n-p)

  ;; Disable blinking cursor and the bell ring
  (blink-cursor-mode -1)
  (setq ring-bell-function 'ignore)

  (setq create-lockfiles nil)  ; disable lock file symlinks

  (setq make-backup-files t    ;; backup of a file the first time it is saved.
        backup-by-copying t    ;; don't clobber symlinks
        version-control t      ;; version numbers for backup files
        delete-old-versions t  ;; delete excess backup files silently
        kept-old-versions 6    ;; oldest versions to keep when a new numbered backup is made
        kept-new-versions 9)   ;; newest versions to keep when a new numbered backup is made

  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Support opening new minibuffers from inside existing minibuffers.
  (setq enable-recursive-minibuffers t)

  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond Vertico.
  (setq read-extended-command-predicate #'command-completion-default-include-p))

(use-package simple
  :bind (("C-/"   . undo-only)
         ("C-z"   . undo-only)
         ("C-S-z" . undo-redo)
         ("C-?"   . undo-redo)
         ("C-a"   . move-beginning-of-line-or-indentation)
         ("C-x k" . kill-current-buffer)
         ("M-u"   . dakra-upcase-dwim)
         ("M-U"   . dakra-downcase-dwim)
         ("M-c"   . dakra-capitalize-dwim))
  :hook (((mu4e-compose-mode markdown-mode rst-mode git-commit-setup) . text-mode-autofill-setup)
         ((visual-fill-column-mode markdown-mode) . word-wrap-whitespace-mode))
  :config
  ;; mode line settings
  (line-number-mode t)
  (column-number-mode t)
  (size-indication-mode t)

  (defun move-beginning-of-line-or-indentation ()
    "Move to beginning of line or indentation."
    (interactive)
    (let ((orig-point (point)))
      (back-to-indentation)
      (when (= orig-point (point))
        (beginning-of-line))))

  ;; Hide commands in M-x which do not apply to the current mode.
  (setq read-extended-command-predicate #'command-completion-default-include-p)

  (defun text-mode-autofill-setup ()
    "Set fill-column to 68 and turn on auto-fill-mode."
    (setq-local fill-column 68)
    (auto-fill-mode))

  ;; Autofill (e.g. M-x autofill-paragraph or M-q) to 80 chars (default 70)
  (setq-default fill-column 80)

  (defmacro dakra-define-up/downcase-dwim (case)
    (let ((func (intern (concat "dakra-" case "-dwim")))
          (doc (format "Like `%s-dwim' but %s from beginning when no region is active." case case))
          (case-region (intern (concat case "-region")))
          (case-word (intern (concat case "-word"))))
      `(defun ,func (arg)
         ,doc
         (interactive "*p")
         (save-excursion
           (if (use-region-p)
               (,case-region (region-beginning) (region-end))
             (beginning-of-thing 'symbol)
             (,case-word arg))))))
  (dakra-define-up/downcase-dwim "upcase")
  (dakra-define-up/downcase-dwim "downcase")
  (dakra-define-up/downcase-dwim "capitalize"))

(use-package moe-theme
  :load-path "lib/moe-theme"  ;; Symlinks are difficult in Windows environments without admin access
  :config (load-theme 'moe-dark t))

;; highlight the current line
(use-package hl-line
  :init
  (global-hl-line-mode))

(use-package abbrev
  :hook (text-mode . abbrev-mode)
  ;; :hook ((message-mode org-mode markdown-mode rst-mode) . abbrev-mode)
  :config
  ;; Don't ask to save abbrevs when saving all buffers
  (setq save-abbrevs 'silently)
  ;; I want abbrev saved in my config/version control and not in the var folder
  (setq abbrev-file-name (no-littering-expand-etc-file-name "abbrev.el")))

;; Saveplace: Remember your location in a file
(use-package saveplace
  :unless noninteractive
  :demand t
  :config
  (setq save-place-limit 1000)
  (save-place-mode))

;; Savehist: Keep track of minibuffer history
(use-package savehist
  :unless noninteractive
  :hook (after-init . savehist-mode)
  :config
  (setq savehist-additional-variables
        '(compile-command kill-ring regexp-search-ring corfu-history)))

(use-package windmove
  :bind (("M-i" . windmove-up)
         ("M-k" . windmove-down)
         ("M-j" . windmove-left)
         ("M-l" . windmove-right)
         ("M-J" . windmove-swap-states-left)
         ("M-K" . windmove-swap-states-down)
         ("M-I" . windmove-swap-states-up)
         ("M-L" . windmove-swap-states-right)))

;; So-long: Mitigating slowness due to extremely long lines
(use-package so-long
  :defer 5
  :config
  (global-so-long-mode))

(use-package compile
  :config
  (setq compilation-ask-about-save nil  ;; Always save before compiling
        compilation-always-kill t  ;; Kill old compile processes before starting a new one
        compilation-scroll-output t))  ;; Scroll with the compilation output

(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

(use-package eglot
  :defer t
  :config
  (setq eglot-extend-to-xref t)
  (setq eglot-autoshutdown t))

(use-package eglot-java
  :disabled t
  :after eglot
  :config
  (setq eglot-java-eclipse-jdt-cache-directory
        (no-littering-expand-var-file-name "eglot/java/eglot-java-eclipse-jdt-cache"))
  (setq eglot-java-server-install-dir (no-littering-expand-var-file-name "eglot/java/eclipse.jdt.ls"))
  (setq eglot-java-junit-platform-console-standalone-jar
        (no-littering-expand-var-file-name "eglot/java/junit-platform-console-standalone/junit-platform-console-standalone.jar")))

(use-package flycheck
  :hook (((prog-mode
           conf-mode
           ledger-mode
           systemd-mode
           mu4e-compose-mode
           markdown-mode
           rst-mode) . flycheck-mode)
         (flycheck-mode . mp-flycheck-prefer-eldoc))
  :config
  ;; Only do flycheck when I actually safe the buffer
  (setq flycheck-check-syntax-automatically '(save mode-enable))

  ;; Work with `eldoc-documentation-functions'
  ;; From https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc
  (defun mp-flycheck-eldoc (callback &rest _ignored)
    "Print flycheck messages at point by calling CALLBACK."
    (when-let ((flycheck-errors (and flycheck-mode (flycheck-overlay-errors-at (point)))))
      (mapc
       (lambda (err)
         (funcall callback
                  (format "%s: %s"
                          (let ((level (flycheck-error-level err)))
                            (pcase level
                              ('info (propertize "I" 'face 'flycheck-error-list-info))
                              ('error (propertize "E" 'face 'flycheck-error-list-error))
                              ('warning (propertize "W" 'face 'flycheck-error-list-warning))
                              (_ level)))
                          (flycheck-error-message err))
                  :thing (or (flycheck-error-id err)
                             (flycheck-error-group err))
                  :face 'font-lock-doc-face))
       flycheck-errors)))

  (defun mp-flycheck-prefer-eldoc ()
    (add-hook 'eldoc-documentation-functions #'mp-flycheck-eldoc nil t)
    (setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
    (setq flycheck-display-errors-function nil)
    (setq flycheck-help-echo-function nil)))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (((java-mode java-ts-mode) . lsp-deferred)
         (lsp-completion-mode . lsp-mode-setup-orderless))
  :bind (:map lsp-mode-map
              ("C-c C-a" . lsp-execute-code-action)
              ("M-." . lsp-find-definition-other)
              ("M-," . lsp-find-references-other))
  :init (setq lsp-keymap-prefix nil)  ; Don't map the lsp keymap to any key
  :config
  ;; Shutdown lsp-server when all buffers associated with that server are closed
  (setq lsp-keep-workspace-alive nil)

  (require 'lsp-completion)
  (setq lsp-completion-provider :none)  ;; we use Corfu

  (defun lsp-mode-setup-orderless ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))

  (setq lsp-enable-on-type-formatting nil
        lsp-enable-indentation nil
        lsp-enable-snippet nil
        lsp-semantic-tokens-enable t)

  (defun lsp-find-definition-other (other?)
    "Like `lsp-find-definition' but open in other window when called with prefix arg."
    (interactive "P")
    (if other?
        (lsp-find-definition :display-action 'window)
      (lsp-find-definition)))
  (defun lsp-find-references-other (other?)
    "Like `lsp-find-references' but open in other window when called with prefix arg."
    (interactive "P")
    (if other?
        (lsp-find-references :display-action 'window)
      (lsp-find-references)))

  ;; Don't watch `build' and `.gradle' directories for file changes
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]build$")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]\\.gradle$")

  ;; (require 'yasnippet)  ;; We use yasnippet for lsp snippet support
  (setq-default flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck c/c++-gcc)))

(use-package lsp-ui
  :after lsp-mode
  :bind (:map lsp-mode-map
              ("M-?" . lsp-ui-doc-toggle))
  :config
  (defun lsp-ui-doc-toggle ()
    "Shows or hides lsp-ui-doc popup."
    (interactive)
    (if lsp-ui-doc--bounds
        (lsp-ui-doc-hide)
      (lsp-ui-doc-show)))

  ;; Deactivate most of the annoying "fancy features"
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-doc-use-childframe t)
  (setq lsp-ui-doc-include-signature t)
  (setq lsp-ui-doc-position 'at-point)
  (setq lsp-lens-enable nil)  ;; "1 reference" etc at the end of the line
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-ui-sideline-show-symbol nil))

(use-package lsp-treemacs
  :after lsp-mode
  :config
  ;; Enable bidirectional synchronization of lsp workspace folders and treemacs
  (lsp-treemacs-sync-mode))

(use-package lsp-java
  :after lsp-mode
  :hook (((java-mode java-ts-mode conf-javaprop-mode) . lsp-java-boot-lens-mode))
  :config
  (setq lsp-java-compile-null-analysis-mode "automatic")
  
  ;; Use Google style formatting by default
  ;; (setq lsp-java-format-settings-url
  ;;      "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml")
  ;; (setq lsp-java-format-settings-profile "GoogleStyle")

  (setq lsp-java-vmargs
        '("-noverify"
          "-XX:+UseParallelGC"
          "-XX:GCTimeRatio=4"
          "-XX:AdaptiveSizePolicyWeight=90"
          "-XX:+UseStringDeduplication"
          "-Dsun.zip.disableMemoryMapping=true"
          "-Xmx4G"
          "-Xms100m"))
  
  ;; Use 3rd party decompiler
  (setq lsp-java-content-provider-preferred "fernflower"))

(use-package dap-mode
  :after lsp-mode
  :bind (:map dap-server-log-mode-map
              ("g" . recompile)
              :map dap-mode-map
              ([f9]    . dap-continue)
              ([S-f9]  . dap-disconnect)
              ([f10]   . dap-next)
              ([f11]   . dap-step-in)
              ([S-f11] . dap-step-out))
  :config
  (setq dap-auto-configure-features '(sessions locals controls tooltip))
  (dap-auto-configure-mode))

(use-package dap-java
  :after dap-mode)

(use-package eldoc
  :hook (prog-mode . eldoc-mode)
  :config
  (setq eldoc-documentation-default 'eldoc-documentation-compose-eagerly)
  (eldoc-add-command-completions "sp-")
  (eldoc-add-command-completions "paredit-"))

(use-package shrink-whitespace
  :bind ("M-SPC" . shrink-whitespace))

(use-package minions
  :unless noninteractive
  :defer 2
  :config
  (setq minions-mode-line-lighter "+")
  (setq minions-prominent-modes '(multiple-cursors-mode))
  (minions-mode))

(use-package vertico
  :demand t
  :config
  (vertico-mode))

(use-package vertico-buffer
  :after vertico
  :config
  (setq vertico-buffer-display-action '(display-buffer-below-selected
                                        (window-height . ,(+ 3 vertico-count))))
  (vertico-buffer-mode))

(use-package vertico-multiform
  :after vertico
  :config
  (setq vertico-multiform-commands
        '((consult-line buffer)
          (consult-buffer buffer)
          (consult-org-heading buffer)
          (consult-imenu buffer)
          (consult-project-buffer buffer)
          (consult-project-extra-find buffer)))
  (vertico-multiform-mode))

(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))
                                        (eglot (styles orderless))
                                        (eglot-capf (styles orderless)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c M" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b"   . consult-buffer)              ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ;; Custom M-# bindings for fast register access
         ("M-#"   . consult-register-load)
         ("M-'"   . consult-register-store)        ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y"      . consult-yank-pop)           ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ;; ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-m"   . consult-imenu)
         ("C-M-m"   . consult-imenu-multi)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("s-c d" . consult-find)
         ("s-c D" . consult-locate)
         ("s-c g" . consult-grep)
         ("s-c G" . consult-git-grep)
         ("s-c r" . consult-ripgrep)
         ("s-c l" . consult-line)
         ("s-c L" . consult-line-multi)
         ("s-c m" . consult-multi-occur)
         ("s-c k" . consult-keep-lines)
         ("s-c u" . consult-focus-lines)
         ;; Isearch integration
         ("C-s" . consult-line)
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi))           ;; needed by consult-line to detect isearch
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  ;; (setq consult-preview-key "M-.")
  (consult-customize
   consult-theme
   :preview-key "M-."
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-recent-file consult--source-project-recent-file consult--source-bookmark
   :preview-key '(:debounce 0.2 any))

  (setq consult-narrow-key "<"))

(use-package consult-project-extra
  :defer t)

(use-package embark
  :bind (("C-." . embark-act)         ;; pick some comfortable binding
         ("C-," . embark-dwim)        ;; good alternative: M-.
         ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :hook (((prog-mode conf-mode) . corfu-mode)
         (eshell-mode . corfu-no-auto-mode))
  :bind (:map corfu-map
              ("RET" . nil))
  :config
  (defun corfu-no-auto-mode ()
    "Activate corfu but with auto mode disabled."
    (setq-local corfu-auto nil)
    (corfu-mode))

  (setq corfu-cycle t
        corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 2))

(use-package corfu-history
  :after corfu
  :config
  (corfu-history-mode))

(use-package corfu-popupinfo
  :after corfu
  :config
  (setq corfu-popupinfo-max-height 30)
  (corfu-popupinfo-mode))

(use-package wgrep
  :bind (:map grep-mode-map
              ("C-x C-q" . wgrep-change-to-wgrep-mode))
  :config (setq wgrep-auto-save-buffer t))

(use-package undo-fu-session
  :hook (after-init . undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

(use-package vundo
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols))

(use-package ligature
  :hook (prog-mode . ligature-mode)
  :config
  ;; Some ligatures supported by most fonts. E.g. Fira Code, Victor Mono
  (ligature-set-ligatures 'prog-mode '("~~>" "##" "|-" "-|" "|->" "|=" ">-" "<-" "<--" "->"
                                       "-->" "-<" ">->" ">>-" "<<-" "<->" "->>" "-<<" "<-<"
                                       "==>" "=>" "=/=" "!==" "!=" "<==" ">>=" "=>>" ">=>"
                                       "<=>" "<=<" "=<=" "=>=" "<<=" "=<<"
                                       "=:=" "=!=" "==" "=~" "!~" "===" "::" ":=" ":>" ">:"
                                       ";;" "__" "..." ".." "&&" "++")))

(use-package subword
  :hook ((python-mode yaml-ts-mode conf-mode go-mode go-ts-mode clojure-mode cider-repl-mode
                      java-mode java-ts-mode cds-mode js-mode js-ts-mode) . subword-mode))

(use-package aggressive-indent
  :hook ((emacs-lisp-mode lisp-mode hy-mode clojure-mode css js-mode) . aggressive-indent-mode)
  :config
  (setq aggressive-indent-region-function
        (lambda (start end)
          "indent-region but without the annoying =reporter= message."
          (let ((inhibit-message t))
            (indent-region start end)))))

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode lisp-mode hy-mode clojure-mode cider-repl-mode sql-mode) . rainbow-delimiters-mode))

(use-package hippie-exp
  :bind (("M-/" . hippie-expand)))

;; Do action that normally works on a region to the whole line if no region active.
;; That way you can just C-w to copy the whole line for example.
(use-package whole-line-or-region
  :hook (after-init . whole-line-or-region-global-mode))

(use-package symbol-overlay
  :hook ((prog-mode html-mode css-mode) . symbol-overlay-mode)
  :bind (("C-c s" . symbol-overlay-put)
         :map symbol-overlay-mode-map
         ("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev)
         :map symbol-overlay-map
         ("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev)
         ("C-c C-s r" . symbol-overlay-rename)
         ("C-c C-s k" . symbol-overlay-remove-all)
         ("C-c C-s q" . symbol-overlay-query-replace)
         ("C-c C-s t" . symbol-overlay-toggle-in-scope)
         ("C-c C-s n" . symbol-overlay-jump-next)
         ("C-c C-s p" . symbol-overlay-jump-prev))
  :init (setq symbol-overlay-scope t)
  :config
  ;;(set-face-background 'symbol-overlay-temp-face "gray30")
  ;; Remove all default bindings
  (setq symbol-overlay-map (make-sparse-keymap)))

(use-package smartparens
  :hook ((
          emacs-lisp-mode lisp-mode lisp-data-mode clojure-mode cider-repl-mode hy-mode
          prolog-mode go-mode go-ts-mode cc-mode python-mode
          typescript-mode json-mode json-ts-mode javascript-mode java-mode
          java-ts-mode typescript-ts-mode python-ts-mode js-ts-mode json-ts-mode
          ) . smartparens-strict-mode)
  :bind (:map smartparens-mode-map
              ;; This is the paredit mode map minus a few key bindings
              ;; that I use in other modes (e.g. M-?)
              ("C-M-f" . sp-forward-sexp) ;; navigation
              ("C-M-b" . sp-backward-sexp)
              ("C-M-u" . sp-backward-up-sexp)
              ("C-M-d" . sp-down-sexp)
              ("C-M-p" . sp-backward-down-sexp)
              ("C-M-n" . sp-up-sexp)
              ("C-w" . whole-line-or-region-sp-kill-region)
              ("M-s" . sp-splice-sexp) ;; depth-changing commands
              ("M-r" . sp-splice-sexp-killing-around)
              ("M-(" . sp-wrap-round)
              ("C-)" . sp-forward-slurp-sexp) ;; barf/slurp
              ("M-0" . sp-forward-slurp-sexp)
              ("C-<right>" . sp-forward-slurp-sexp)
              ("C-}" . sp-forward-barf-sexp)
              ("C-<left>" . sp-forward-barf-sexp)
              ("C-(" . sp-backward-slurp-sexp)
              ("M-9" . sp-backward-slurp-sexp)
              ("C-M-<left>" . sp-backward-slurp-sexp)
              ("C-{" . sp-backward-barf-sexp)
              ("C-M-<right>" . sp-backward-barf-sexp)
              ("M-S" . sp-split-sexp))
  :config
  (require 'smartparens-config)
  (setq sp-base-key-bindings 'paredit)
  (setq sp-autoskip-closing-pair 'always)

  ;; Always highlight matching parens
  (show-smartparens-global-mode)
  (setq blink-matching-paren nil)  ;; Don't blink matching parens

  (defun whole-line-or-region-sp-kill-region (prefix)
    "Call `sp-kill-region' on region or PREFIX whole lines."
    (interactive "*p")
    (whole-line-or-region-wrap-beg-end 'sp-kill-region prefix))

  ;; Don't include semicolon ; when slurping
  (add-to-list 'sp-sexp-suffix '(java-mode regexp ""))
  (add-to-list 'sp-sexp-suffix '(java-ts-mode regexp "")))

(use-package expand-region
  :defer t)

(use-package smart-region
  ;; C-SPC is smart-region
  :bind (([remap set-mark-command] . smart-region)))

(use-package selected
  :hook ((text-mode prog-mode) . selected-minor-mode)
  :init (defvar selected-org-mode-map (make-sparse-keymap))
  :bind (:map selected-keymap
              ("q" . selected-off)
              ("u" . upcase-region)
              ("d" . downcase-region)
              ("w" . count-words-region)
              ("m" . apply-macro-to-region-lines)
              ;; multiple cursors
              ("v" . mc/vertical-align-with-space)
              ("a" . mc/mark-all-dwim)
              ("A" . mc/mark-all-like-this)
              ("m" . mc/mark-more-like-this-extended)
              ("p" . mc/mark-previous-like-this)
              ("P" . mc/unmark-previous-like-this)
              ("S" . mc/skip-to-previous-like-this)
              ("n" . mc/mark-next-like-this)
              ("N" . mc/unmark-next-like-this)
              ("s" . mc/skip-to-next-like-this)
              ("r" . mc/edit-lines)
              :map selected-org-mode-map
              ("t" . org-table-convert-region)))

(use-package multiple-cursors
  :bind (("C-c m" . mc/mark-all-dwim)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         :map mc/keymap
         ("C-x v" . mc/vertical-align-with-space)
         ("C-x n" . mc-hide-unmatched-lines-mode))
  :config
  (with-eval-after-load 'multiple-cursors-core
    ;; Immediately load mc list, otherwise it will show as
    ;; changed as empty in my git repo
    (mc/load-lists)

    (define-key mc/keymap (kbd "M-T") 'mc/reverse-regions)
    (define-key mc/keymap (kbd "C-,") 'mc/unmark-next-like-this)
    (define-key mc/keymap (kbd "C-.") 'mc/skip-to-next-like-this)))

(use-package recentf
  :demand t
  :config
  (add-to-list 'recentf-exclude "^/\\(?:ssh\\|su\\|sudo\\)?:")
  (add-to-list 'recentf-exclude no-littering-var-directory)

  (setq recentf-max-saved-items 500
        recentf-max-menu-items 15
        ;; disable recentf-cleanup on Emacs start, because it can cause
        ;; problems with remote files
        recentf-auto-cleanup 'never)

  (recentf-mode))

(use-package hideshow
  :hook (prog-mode . hs-minor-mode)
  :bind (:map hs-minor-mode-map
              ([C-tab] . hs-toggle-hiding)))

(use-package avy
  :bind ("C-;" . avy-goto-char-timer)
  :config
  (setq avy-background t)
  (setq avy-style 'at-full)
  (setq avy-timeout-seconds 0.2))

(use-package gumshoe
  :defer 1
  :bind (("C-x SPC" . gumshoe-backtrack)
         ("C-x C-SPC" . gumshoe-buf-backtrack)
         ("C-x M-SPC" . global-gumshoe-backtracking-mode-forward)
         :map global-gumshoe-backtracking-mode-map
         ("n" . global-gumshoe-backtracking-mode-back)
         ("p" . global-gumshoe-backtracking-mode-forward)
         ("SPC" . global-gumshoe-backtracking-mode-back)
         ("C-SPC" . global-gumshoe-backtracking-mode-forward))
  :config
  (setq gumshoe-ignored-major-modes '(fundamental-mode minibuffer-mode treemacs-mode))
  (global-gumshoe-mode))

(use-package proced
  :bind ("C-x p" . proced)
  :config
  (setq-default proced-filter 'all)
  (setq proced-format 'medium)
  (setq proced-tree-flag t))

(use-package dired
  :bind (("C-x d" . dired)
         :map dired-mode-map
         ("j" . consult-line)
         ("M-u" . dired-up-directory)
         ("M-RET" . emms-play-dired)
         ("C-RET" . dired-open-xdg)
         ([(control return)] . dired-open-xdg)
         ("e" . dired-ediff-files)
         ("C-c C-d" . dired-dragon-popup)
         ("C-c C-e" . dired-toggle-read-only))
  :config
  ;; Allow drag and drop out of dired into other apps (e.g. browser)
  (setq dired-mouse-drag-files t)
  ;; Open directories in same buffer
  (setq dired-kill-when-opening-new-dired-buffer t)
  ;; always delete and copy recursively
  (setq dired-recursive-deletes 'always)
  (setq dired-recursive-copies 'always)
  (setq dired-dwim-target t))

(use-package eshell
  :bind (("C-x m" . eshell))
  :init
  (setq eshell-aliases-file (no-littering-expand-etc-file-name "eshell-aliases"))
  :config
  (setq eshell-scroll-to-bottom-on-input 'all
        eshell-error-if-no-glob t
        eshell-hist-ignoredups t
        eshell-visual-commands '("ptpython" "ipython" "pshell" "tail" "vi" "vim" "watch"
                                 "nmtui" "dstat" "mycli" "pgcli" "vue" "ngrok"
                                 "tmux" "screen" "top" "htop" "less" "more" "ncftp")
        eshell-prefer-lisp-functions nil))

(use-package eat
  :load-path "lib/eat"
  :commands (eat)
  :hook (eshell-load-hook . eat-eshell-visual-command-mode))

(use-package project
  :bind-keymap (("s-p"   . project-prefix-map)  ; projectile-command-map
                ("C-c p" . project-prefix-map))
  :bind (("C-x C-x" . consult-project-extra-find)
         :map project-prefix-map
         ("SPC" . consult-project-extra-find)
         ("d"   . project-dired)
         ("D"   . project-edit-deps-edn)
         ("s"   . consult-ripgrep)
         ("E"   . project-edit-dir-locals)
         ("P"   . project-run-python))
  :config
  ;; Ignore clj-kondo and cljs-runtime folder by default
  (setq project-vc-ignores '(".clj-kondo/" "cljs-runtime/"))

  (defun project-edit-dir-locals ()
    "Open buffer with .dir-locals.el for current project."
    (interactive)
    (->> (project-current)
         (project-root)
         (expand-file-name ".dir-locals.el")
         (find-file)))

  (defun project-edit-deps-edn ()
    "Open buffer with deps.edn for current project."
    (interactive)
    (->> (project-current)
         (project-root)
         (expand-file-name "deps.edn")
         (find-file)))

  (require 'python)
  (defun project-run-python ()
    "Run a dedicated inferior Python process for the current project.
Like `run-python' started with a prefix-arg and then choosing to
created a dedicated process for the project."
    (interactive)
    (run-python (python-shell-calculate-command) 'project t))

  ;; Don't show a dispatch menu when switching projects but always choose project buffer/file
  (setq project-switch-commands #'consult-project-extra-find))

(use-package org
  :mode ("\\.\\(org\\|org_archive\\)\\'" . org-mode)
  :bind (("C-c a"   . org-agenda)
         :map org-mode-map
         ("<M-return>" . org-insert-todo-heading-respect-content)
         ("<M-S-return>" . org-meta-return)
         ("M-." . org-open-at-point)  ; So M-. behaves like in source code.
         ("M-," . org-mark-ring-goto)
         ("M-;" . org-comment-dwim)
         ("M-m" . consult-org-heading)
         ;; Disable adding and removing org-agenda files via keybinding.
         ("C-c [" . nil)
         ("C-c ]" . nil)
         ("\C-c TAB" . nil)  ;; Remove for tempel-expand
         ("C-a" . org-beginning-of-line)
         ("M-p" . org-previous-visible-heading)
         ("M-n" . org-next-visible-heading)
         ("<M-up>" . org-metaup)
         ("<M-down>" . org-metadown)
         :map org-src-mode-map
         ("C-x n" . org-edit-src-exit))
  :config
  (setq org-auto-align-tags nil
        org-tags-column 0
        org-fold-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t
        org-startup-with-inline-images t
        org-imenu-depth 5
        org-special-ctrl-a/e t
        org-special-ctrl-k t
        org-startup-indented nil  ;; Doesn't play nice with org-modern
        ;; Org styling, hide markup etc.
        org-hide-emphasis-markers t
        org-pretty-entities t
        ;; Ellipsis styling
        org-ellipsis "…"
        ;; But Don't print "bar" as subscript in "foo_bar"
        org-pretty-entities-include-sub-superscripts nil
        ;; And also don't display ^ or _ as super/subscripts
        org-use-sub-superscripts nil)
  (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil))

(use-package org-clock
  :bind (("<f7>"    . org-clock-goto)
         ("C-c o i" . org-clock-in)
         ("C-c C-x C-j" . org-clock-goto)
         ("C-c C-x C-i" . org-clock-in)
         ("C-c C-x C-o" . org-clock-out))
  :config
  (setq org-clock-history-length 30)

  ;; Save the running clock and all clock history when exiting Emacs, load it on startup
  (setq org-clock-persist t)
  (org-clock-persistence-insinuate)

  ;; Resume clocking task on clock-in if the clock is open
  (setq org-clock-in-resume t)

  ;; org-clock-display (C-c C-x C-d) shows times for this month by default
  (setq org-clock-display-default-range 'thismonth)

  ;; Only show the current clocked time in mode line (not all)
  (setq org-clock-mode-line-total 'current)

  ;; Clocktable (C-c C-x C-r) defaults
  ;; Use fixed month instead of (current-month) because I want to keep a table for each month
  (setq org-clock-clocktable-default-properties
        `(:block ,(format-time-string "%Y-%m") :scope file-with-archives))

  ;; Clocktable (reporting: r) in the agenda
  (setq org-clocktable-defaults
        '(:maxlevel 3 :lang "en" :scope file-with-archives
                    :wstart 1 :mstart 1 :tstart nil :tend nil :step nil :stepskip0 t :fileskip0 t
                    :tags nil :emphasize nil :link t :narrow 70! :indent t :formula nil :timestamp nil
                    :level nil :tcolumns nil :formatter nil))

  ;; Resume clocking task on clock-in if the clock is open
  (setq org-clock-in-resume t)
  ;; Log all State changes to drawer
  (setq org-log-into-drawer t)
  ;; make time editing use discrete minute intervals (no rounding) increments
  (setq org-time-stamp-rounding-minutes (quote (1 1)))
  ;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
  (setq org-clock-out-remove-zero-time-clocks t)
  ;; Don't clock out when moving task to a done state
  (setq org-clock-out-when-done nil)

  ;; Enable auto clock resolution for finding open clocks
  (setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
  ;; Include current clocking task in clock reports
  (setq org-clock-report-include-clocking-task t))

(use-package ol  ;; org-link
  :bind (("C-c l" . org-store-link))
  :config
  ;; Don't remove links after inserting
  (setq org-link-keep-stored-after-insertion t))

(use-package org-agenda
  :defer t
  :config
  (setq org-agenda-window-setup 'current-window
        org-agenda-tags-column 0
        org-agenda-block-separator ?─
        org-agenda-time-grid
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string
        "◀── now ─────────────────────────────────────────────────"))

(use-package ob
  :after org
  :hook ((org-babel-after-execute . org-display-inline-images))
  :config
  ;; don't prompt me to confirm every time I want to evaluate a block
  (setq org-confirm-babel-evaluate nil)

  ;; Add more languages to org-babel
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (awk)
     (calc . t)
     (clojure . t)
     (css)
     (ditaa . t)
     (dot . t)
     (emacs-lisp . t)
     (gnuplot . t)
     (haskell)
     (java . t)
     (js . t)
     (latex)
     (lisp)
     (lua . t)
     (matlab)
     (ocaml)
     (octave . t)
     (perl)
     (plantuml . t)
     (python . t)
     (restclient . t)
     (ruby)
     (sass)
     (scala)
     (scheme)
     (shell . t)
     (sql . t)
     (sqlite . t))))

(use-package ob-restclient
  :after ob)

(use-package org-src
  :after org
  :config
  ;; Always split babel source window below.
  ;; Alternative is `current-window' to don't mess with window layout at all
  (setq org-src-window-setup 'split-window-below)

  (setq org-edit-src-content-indentation 0)

  ;; Add 'conf-mode' to org-babel
  (add-to-list 'org-src-lang-modes '("ini" . conf))
  (add-to-list 'org-src-lang-modes '("conf" . conf)))

(use-package ol
  :after org
  :config
  (setq org-link-keep-stored-after-insertion t))

;; org-link support for magit buffers
(use-package orgit
  ;; Automatically copy orgit link to last commit after commit
  :hook (git-commit-post-finish . orgit-store-after-commit)
  :config
  (defun orgit-store-after-commit ()
    "Store orgit-link for latest commit after commit message editor is finished."
    (let* ((repo (abbreviate-file-name default-directory))
           (rev (magit-git-string "rev-parse" "HEAD"))
           (link (format "orgit-rev:%s::%s" repo rev))
           (summary (substring-no-properties (magit-format-rev-summary rev)))
           (desc (format "%s (%s)" summary repo)))
      (push (list link desc) org-stored-links))))

(use-package org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-hide-stars nil
        org-modern-star 'replace
        org-modern-replace-stars "❶❷❸❹❺❻❼"))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks nil))

(use-package tempel
  :bind (("\C-c TAB" . tempel-complete)
         :map tempel-map
         ([tab] . tempel-next)
         ([backtab] . tempel-previous))
  :hook ((text-mode prog-mode) . tempel-setup-capf)
  :config
  ;; Load templates from etc folder
  (setq tempel-path (no-littering-expand-etc-file-name "tempel.eld"))

  ;; Don't auto reload templates.
  ;; `(setq tempel--path-templates nil)' if you want to force a reload.
  (setq tempel-auto-reload nil)

  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions))))

(use-package markdown-mode
  :mode (("\\.markdown\\'" . gfm-mode)
         ("README\\.md\\'" . gfm-mode))
  :bind (:map markdown-mode-map
              ("C-c =" . markdown-insert-header-dwim))
  :config
  ;; Display remote images
  (setq markdown-display-remote-images t)
  ;; Enable fontification for code blocks
  (setq markdown-fontify-code-blocks-natively t)
  ;; Add some more languages
  (dolist (x '(("ini" . conf-mode)
               ("clj" . clojure-mode)
               ("cljs" . clojure-mode)
               ("cljc" . clojure-mode)))
    (add-to-list 'markdown-code-lang-modes x))

  ;; use pandoc with source code syntax highlighting to preview markdown (C-c C-c p)
  (setq markdown-command "pandoc -s --highlight-style pygments -f markdown_github -t html5"))

(use-package with-editor
  ;; Use local Emacs instance as $EDITOR (e.g. in `git commit' or `crontab -e')
  :hook ((shell-mode eshell-mode vterm-mode term-exec) . with-editor-export-editor))

(use-package transient
  :defer t
  :config
  ;; Display transient buffer below current window
  ;; and not bottom of the complete frame (minibuffer like)
  (setq transient-display-buffer-action '(display-buffer-below-selected)))

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x G" . magit-dispatch)
         ("C-x M-g" . magit-dispatch)
         ("s-m p" . magit-list-repositories)
         ("s-m m" . magit-status)
         ("s-m f" . magit-file-dispatch)
         ("s-m l" . magit-log)
         ("s-m L" . magit-log-buffer-file)
         ("s-m b" . magit-blame-addition)
         ("s-m B" . magit-blame)
         :map magit-process-mode-map
         ("k" . magit-process-kill))
  :hook (after-save . magit-after-save-refresh-status)
  :config
  ;; Set remote.pushDefault
  (setq magit-remote-set-if-missing 'default)

  ;; Don't override date for extend or reword
  (setq magit-commit-extend-override-date nil)
  (setq magit-commit-reword-override-date nil)

  ;; Always show recent/unpushed/unpulled commits
  (setq magit-section-initial-visibility-alist '((unpushed . show)
                                                 (unpulled . show)))

  ;; Show submodules section to magit status
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-modules
                          'magit-insert-stashes
                          'append)

  ;; Show ignored files section to magit status
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-ignored-files
                          'magit-insert-untracked-files
                          nil)

  ;; Disable safety nets
  (setq magit-commit-squash-confirm nil)
  (setq magit-save-repository-buffers 'dontask)
  (setf (nth 2 (assq 'magit-stash-pop  magit-dwim-selection)) t)
  (dolist (x '(rename resurrect untrack stage-all-changes unstage-all-changes))
    (add-to-list 'magit-no-confirm x t))

  ;; When showing refs (In magit status press `y y') show only merged into master by default
  (setq magit-show-refs-arguments '("--merged=master"))
  ;; Show color and graph in magit-log. Since color makes it a bit slow, only show the last 128 commits
  (setq magit-log-arguments '("--graph" "--color" "--decorate" "-n128"))
  ;; Always highlight word differences in diff
  (setq magit-diff-refine-hunk 'all)

  ;; Don't change my window layout after quitting magit
  ;; Often I invoke magit and then do a lot of things in other windows
  ;; On quitting, magit would then "restore" the window layout like it was
  ;; when I first invoked magit. Don't do that!
  (setq magit-bury-buffer-function 'magit-mode-quit-window)

  ;; Show magit status in the same window
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package ssh-agency
  :after magit)

(use-package diff-hl
  :hook (((prog-mode conf-mode vc-dir-mode ledger-mode) . turn-on-diff-hl-mode)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  ;; Disable diff-hl in Tramp
  (setq diff-hl-disable-on-remote t)
  (setq diff-hl-draw-borders nil))

(use-package git-link
  :bind (("C-c G" . git-link))
  :config
  (setq git-link-use-commit t
        git-link-open-in-browser t))

(use-package treemacs
  :bind (([f8] . treemacs-toggle-or-select)
         :map treemacs-mode-map
         ("M-l" . nil)  ;; We bind `M-l' to `windmove-right'
         ("C-t a" . treemacs-add-project-to-workspace)
         ("C-t d" . treemacs-remove-project)
         ("C-t r" . treemacs-rename-project)
         ;; If we only hide the treemacs buffer (default binding) then, when we switch
         ;; a frame to a different project and toggle treemacs again we still get the old project
         ("q" . treemacs-kill-buffer))
  :config
  (defun treemacs-toggle-or-select (&optional arg)
    "Initialize or toggle treemacs.
- If the treemacs window is visible and selected, hide it.
- If the treemacs window is visible select it with cursor on current file.
- If a treemacs buffer exists, but is not visible show it.
- If no treemacs buffer exists for the current frame create and show it.
- If the workspace is empty additionally ask for the root path of the first
  project to add.

With one `C-u' prefix argument, display current project exclusively.
With two `C-u' `C-u' prefix args, add and display current project."
    (interactive "p")
    (cond ((or (not arg) (eq arg 1))
           (pcase (treemacs-current-visibility)
             ('visible (if (string-prefix-p treemacs--buffer-name-prefix (buffer-name))
                           (delete-window (treemacs-get-local-window))
                         (when (buffer-file-name)
                           (treemacs-find-file))
                         (treemacs--select-visible-window)))
             ('exists  (treemacs-select-window))
             ('none    (treemacs--init))))
          ((eq arg 4) (treemacs-add-and-display-current-project-exclusively))
          ((eq arg 16) (treemacs-add-and-display-current-project))))

  (defun treemacs-ignore-python-files (file _)
    (or (s-ends-with-p ".pyc" file)
        (string= file "__pycache__")))
  (add-to-list 'treemacs-ignored-file-predicates 'treemacs-ignore-python-files)

  ;; Read input from minibuffer instead of childframe (which requires an extra package)
  (setq treemacs-read-string-input 'from-minibuffer)

  (setq treemacs-follow-after-init          t
        treemacs-indentation                1
        treemacs-width                      30
        treemacs-collapse-dirs              5
        treemacs-silent-refresh             nil
        treemacs-is-never-other-window      t)
  (treemacs-filewatch-mode t)
  (treemacs-follow-mode -1)
  (treemacs-git-mode 'simple))

;; Use magit hooks to notify treemacs of git changes
(use-package treemacs-magit
  :after treemacs)

(use-package treemacs-icons-dired
  :after dired
  :config (treemacs-icons-dired-mode))

(use-package restclient
  :mode ("\\.rest\\'" . restclient-mode)
  :hook (restclient-mode . restclient-outline-mode)
  :config
  ;; Open application/edn responses in clojure mode
  (add-to-list 'restclient-content-type-modes '("application/edn" . clojure-mode))

  (defun restclient-outline-mode ()
    (outline-minor-mode)
    (setq-local outline-regexp "##+")))

(use-package elisp-mode
  :bind (:map emacs-lisp-mode-map
              ("C-c C-c" . eval-defun)
              ("C-c C-b" . eval-buffer)
              ("C-c C-k" . eval-buffer)
              ("C-c C-;"   . eval-print-as-comment)
              :map lisp-interaction-mode-map  ; Scratch buffer
              ("C-c C-c" . eval-defun)
              ("C-c C-b" . eval-buffer)
              ("C-c C-k" . eval-buffer)
              ("C-c C-;"   . eval-print-as-comment))
  :config
  (defvar eval-print-as-comment-prefix ";;=> ")

  (defun eval-print-as-comment (&optional arg)
    (interactive "P")
    (let ((start (point)))
      (eval-print-last-sexp arg)
      (save-excursion
        (goto-char start)
        (save-match-data
          (re-search-forward "[[:space:]\n]*" nil t)
          (insert eval-print-as-comment-prefix))))))

(use-package clojure-mode
  :bind (:map clojure-mode-map
              ("C-M-;" . clojure-toggle-ignore))
  :config
  ;; Eval top level forms inside comment forms instead of the comment form itself
  (setq clojure-toplevel-inside-comment-form t)

  ;; Don't align the body of clojure.core/match with the first argument
  (put-clojure-indent 'match 1))

(use-package groovy-mode
  :defer t)

(use-package kubel
  :bind ((:map kubel-mode-map
               ("N" . kubel-set-namespace)
               ("P" . kubel-port-forward-pod)
               ("n" . next-line)
               ("p" . previous-line))))

;; Load personal config that shouldn't end up on github
(load-file (expand-file-name "personal.el" user-emacs-directory))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit request lsp-mode smartparens vertico undo-fu-session groovy-mode flycheck dap-mode lsp-java lsp-treemacs lsp-ui eldoc clojure-mode multiple-cursors ob-restclient restclient orgit org-appear diff-hl git-link avy gumshoe markdown-mode tempel ligature moe-theme treemacs-icons-dired treemacs-magit treemacs corfu wgrep minions ssh-agency kubel shrink-whitespace selected symbol-overlay embark-consult consult-project-extra whole-line-or-region vundo smart-region rainbow-delimiters org-modern orderless no-littering marginalia embark consult aggressive-indent)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
