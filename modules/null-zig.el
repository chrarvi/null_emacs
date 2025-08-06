;;; null-zig.el --- zig configuration -*- lexical-binding: t -*-

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

;; Zig related packages.

;;; Code:

(require 'null-keybinds)

(use-package zig-mode
  :custom
  (zig-format-on-save nil))

;; Keybinds
(null-keybinds-major-key-def
  :states '(normal visual)
  :keymaps '(zig-mode-map)
  "b" '(:ignore t :wk "buffer")
  "b f" '(zig-format-buffer :wk format buffer))


(provide 'null-zig)
;;; null-zig.el ends here
