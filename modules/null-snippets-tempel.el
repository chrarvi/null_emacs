;;; null-snippets-tempel.el --- Snippet support with tempel -*- lexical-binding: t -*-

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

;;; Code:

(require 'null-keybinds)

(defvar null-snippets-directory (concat user-emacs-directory "misc/snippets_tempel")
  "Snippets directory.")

(use-package tempel
  ;; Require trigger prefix before template name when completing.
  :custom
  (tempel-trigger-prefix "<")
  (tempel-path (expand-file-name "*.eld" null-snippets-directory))
  :bind (("C-' S" . tempel-complete)
         (:map tempel-map
               ("C-<right>" . tempel-next)
               ("C-<left>" . tempel-previous)))
  :init
  ;; Setup completion at point
  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions
                (cons #'tempel-complete
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))

(use-package tempel-collection)

(use-package eglot-tempel
  :after eglot
  :config
  (eglot-tempel-mode +1))

(null-keybinds-leader-key-def
  :states 'normal
  "i s" '(tempel-insert :wk "insert snippet"))

(provide 'null-snippets-tempel)

;;; null-snippets-tempel.el ends here
