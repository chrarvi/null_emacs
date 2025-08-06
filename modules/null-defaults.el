;;; null-defaults.el -*- lexical-binding: t; -*-

(require 'null-keybinds)

(setq-default tab-width 4)
(setq-default evil-shift-width tab-width)
(setq-default indent-tabs-mode nil)
(setq tramp-default-method "ssh")
(with-eval-after-load 'tramp
    (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(setq display-line-numbers-type 'relative)
(setq global-display-line-numbers-mode t)
(setq global-display-fill-column-indicator-modes
      '((not dired-mode)
        (not special-mode)
        t))
(setq load-prefer-newer t)

;; bookmarks
(setq bookmark-default-file "~/.config/null_emacs/var/bookmarks")  ;;define file to use.
(setq bookmark-save-flag 1)  ;save bookmarks to .emacs.bmk after each entry

;; yes or no
(defalias 'yes-or-no-p 'y-or-n-p)
(setq use-dialog-box nil)

;; Default shell
(setq shell-file-name "/usr/bin/zsh")

;; Save history
(use-package savehist
  :custom
  (history-length 128)
  :init
  (savehist-mode 1))

(use-package saveplace
  :config
  (save-place-mode 1))

(use-package autorevert
  :config
  (global-auto-revert-mode 1))

(global-display-fill-column-indicator-mode +1)

;; Repeat mode
(repeat-mode 1)

(use-package super-save
  :custom
  (super-save-auto-save-when-idle t)
  (super-save-idle-duration 10)
  (auto-save-default nil)
  (super-save-remote-files nil)
  :config
  (super-save-mode +1))

(setq split-width-threshold nil)
(setq split-height-threshold  nil)

(defun stop-using-minibuffer ()
  "kill the minibuffer"
  (when (and (>= (recursion-depth) 1) (active-minibuffer-window))
    (abort-recursive-edit)))

(add-hook 'mouse-leave-buffer-hook 'stop-using-minibuffer)

;; Open pdfs with zathura
(use-package openwith
  :custom
  (openwith-associations '(("\\.pdf\\'" "sioyek --shared-database-path $HOME/Dropbox/org/bibliography/sioyek/shared.db " (file))))
  :config
  (openwith-mode t))

;; Delete trailing junk
(defun no-junk-please-were-unixish ()
  (let ((coding-str (symbol-name buffer-file-coding-system)))
    (when (string-match "-\\(?:dos\\|mac\\)$" coding-str)
      (set-buffer-file-coding-system 'unix))))

(add-hook 'find-file-hooks 'no-junk-please-were-unixish)

;; Helpful
(use-package helpful)

;; Cleanup whitespace on save
(add-hook 'before-save-hook 'whitespace-cleanup)

;; Suggest VLF mode for large files
(use-package vlf
  :config
  (require 'vlf-setup))

(general-define-key
 :states 'normal
 "C-h f" 'helpful-callable
 "C-h v" 'helpful-variable
 "C-h k" 'helpful-key
 "K" 'helpful-at-point)

(null-keybinds-leader-key-def
  :states 'normal
  "h f" 'helpful-callable
  "h v" 'helpful-variable
  "h k" 'helpful-key
  "h d" 'helpful-at-point
  "h c" 'describe-char
  "h M" 'man)

(provide 'null-defaults)
