;;; early-init.el -*- lexical-binding: t; -*-

(setq gc-cons-threshold (* 50 1000 1000))

;; Silence compiler warnings as they can be pretty disruptive
(setq native-comp-async-report-warnings-errors nil)
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))
;; enable async native compilation
(setq native-comp-deferred-compilation t)

(defvar null-bootstrap-directory (expand-file-name "bootstrap/" user-emacs-directory)
  "Package system bootstrap configuration.")

(load (expand-file-name "null-package-bootstrap.el" null-bootstrap-directory))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 100 1000 1000))
(setq read-process-output-max (* 3 1024 1024)) ;; 3mb
