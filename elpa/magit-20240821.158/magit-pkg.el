(define-package "magit" "20240821.158" "A Git porcelain inside Emacs"
  '((emacs "26.1")
    (compat "30.0.0.0")
    (dash "2.19.1")
    (git-commit "4.0.0")
    (magit-section "4.0.0")
    (seq "2.24")
    (transient "0.7.4")
    (with-editor "3.4.1"))
  :commit "e9ebf8ec23558ac5e438fbedd5f380b4d2a3147e" :authors
  '(("Marius Vollmer" . "marius.vollmer@gmail.com")
    ("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev"))
  :maintainers
  '(("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev")
    ("Kyle Meyer" . "kyle@kyleam.com"))
  :maintainer
  '("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev")
  :keywords
  '("git" "tools" "vc")
  :url "https://github.com/magit/magit")
;; Local Variables:
;; no-byte-compile: t
;; End: