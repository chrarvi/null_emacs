;;; init.el -*- lexical-binding: t; -*-

;;; Code:

;; Find the user configuration file
(defvar null-config-file (expand-file-name "config.el" user-emacs-directory)
  "The user's configuration file.")

;; Add the modules/packages to load-path
(add-to-list 'load-path (expand-file-name "modules/" user-emacs-directory))
(let ((default-directory (expand-file-name "lisp/" user-emacs-directory)))
  (normal-top-level-add-subdirs-to-load-path))

;; No littering (load as early as possible)
(use-package no-littering
  :config
  ;; Littering settings
  (require 'recentf)
  (setq recentf-save-file (no-littering-expand-etc-file-name "recentf")
        recentf-keep '(file-remote-p file-readable-p)
        recentf-auto-cleanup 'never)
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory)
  (recentf-mode 1)
  (run-at-time nil (* 1 60) 'recentf-save-list)
  (no-littering-theme-backups)
  (setq custom-file (no-littering-expand-etc-file-name "custom.el")))

(elpaca-wait)

;; Load the user configuration file if it exists
(when (file-exists-p null-config-file)
  (load null-config-file nil 'nomessage))
