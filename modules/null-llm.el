;;; null-llm.el --- summary -*- lexical-binding: t -*-

;; Author: Christoffer Arvidsson
;; Version: 1.0
;; Package-Requires:
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

(use-package copilot
    :ensure (:host github :repo "copilot-emacs/copilot.el")
    :custom
    (copilot-idle-delay 0.1)
    :general (:keymaps 'copilot-completion-map
                       "M-]" 'copilot-accept-completion))

(use-package gptel
  :ensure t)

(null-keybinds-leader-key-def
  :states '(normal visual)
  "o l" '(:ignore t :wk "llm")
  "o l n" 'gptel
  "o l o" 'gptel-menu
  "o l s" 'gptel-send
  "o l r" 'gptel-rewrite
  "o l a" 'gptel-add
  "o l A" 'gptel-add-file)

(provide 'null-llm)
;;; null-llm.el ends here
