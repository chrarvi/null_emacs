;;; null-denote.el --- Denote module -*- lexical-binding: t -*-

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

(use-package denote
  :custom
  (denote-directory "~/notes")
  (denote-known-keywords '("work")))

(use-package denote-journal
  :after denote
  :hook (calendar-mode . denote-journal-calendar-mode)
  :config
  (setq denote-journal-directory
        (expand-file-name "journal" denote-directory))
  (setq denote-journal-keyword "journal"))

(null-keybinds-leader-key-def
  :keymaps 'global-map
  "n w" '(:ignore t :wk "Denote")
  "n w f" 'denote-open-or-create
  "n w i" 'denote-insert-link
  "n w R" 'denote-rename-file
  "n w c" 'denote-create-note

  "n w j" 'denote-journal-new-or-existing-entry
  "n w J" 'denote-journal-new-entry)

(provide 'null-denote)

;;; null-denote.el ends here
