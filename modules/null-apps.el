;;; null-apps.el --- summary -*- lexical-binding: t -*-

;; Author: Christoffer Arvidsson
;; Maintainer: Christoffer Arvidsson
;; Version: version
;; Package-Requires: (dependencies)
;; Homepage: homepage
;; Keywords: keywords


;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; commentary

;;; Code:

(require 'null-keybinds)

(use-package calc)

(use-package vterm
  :general (:states '(normal insert)
                    :keymaps 'vterm-mode-map
                    "C-c" 'vterm-send-C-c)
  :custom
  (vterm-shell shell-file-name)
  (vterm-max-scrollback 2000)
  (vterm-timer-delay 0.01)
  (vterm-always-compile-module t)

  :config
  (add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode 1)))
  (defun null/vterm-project ()
    (interactive)
    (let ((buffer (get-buffer-create (concat "*vterm " (project-name (project-current)) "*"))))
      (with-current-buffer buffer
        (unless (derived-mode-p 'vterm-mode)
          (vterm-mode)))
      (switch-to-buffer-other-window buffer))))

(use-package eshell
  :config
  (defun null/eshell-other-window ()
    (interactive)
    (let ((buf (eshell)))
      (switch-to-buffer (other-buffer buf))
      (switch-to-buffer-other-window buf))))

(use-package ranger
  :config
  (defun null/open-ranger-in-project-root ()
    "Open Ranger in the root directory of the current project."
    (interactive)
    (let* ((project (project-current))
           (project-root (and project (project-root project))))
      (if project-root
          (ranger project-root)
        (message "No project found.")))))

(use-package dired
  :ensure nil  ; built-in
  :custom
  (dired-dwim-target t))

(use-package wdired
  :after dired
  :hook (dired-mode . auto-revert-mode))

(use-package diredfl
  :config
  (diredfl-global-mode t))

(use-package tmr)

;; Non-package keys
(null-keybinds-leader-key-def
  :states 'normal
  "." '(dired :wk "Open dired")
  "o c" '(quick-calc :wk "Quick calculator")
  "o t" '(vterm-other-window :wk "Open vterm popup")
  "o T" '(vterm :wk "Open vterm")
  "p t" '(null/vterm-project :wk "Open vterm in current project")
  "o e" '(null/eshell-other-window :wk "Open eshell popup")
  "o E" '(eshell :wk "Open eshell")
  "o r" '(null/open-ranger-in-project-root :wk "Open ranger in project root")
  "o R" '(ranger :wk "Open ranger")
  "o C" '(calc :wk "Calculator"))


(provide 'null-apps)

;;; null-apps.el ends here
