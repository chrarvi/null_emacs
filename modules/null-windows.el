;;; null-windows.el --- summary -*- lexical-binding: t -*-

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

;;; Functions

(defun null/evil-window-swap (direction)
  "Move current window to the next window in DIRECTION.
If there are no windows there and there is only one window, split in that
direction and place this window there.  If there are no windows and this isn't
the only window, use evil-window-move-* (e.g. `evil-window-move-far-left')."
  (when (window-dedicated-p)
    (user-error "Cannot swap a dedicated window"))
  (let* ((this-window (selected-window))
         (this-buffer (current-buffer))
         (that-window (windmove-find-other-window direction nil this-window))
         (that-buffer (window-buffer that-window)))
    (when (or (minibufferp that-buffer)
              (window-dedicated-p this-window))
      (setq that-buffer nil that-window nil))
    (if (not (or that-window (one-window-p t)))
        (funcall (pcase direction
                   ('left  #'evil-window-move-far-left)
                   ('right #'evil-window-move-far-right)
                   ('up    #'evil-window-move-very-top)
                   ('down  #'evil-window-move-very-bottom)))
      (unless that-window
        (setq that-window
              (split-window this-window nil
                            (pcase direction
                              ('up 'above)
                              ('down 'below)
                              (_ direction))))
        (with-selected-window that-window
          (switch-to-buffer (doom-fallback-buffer)))
        (setq that-buffer (window-buffer that-window)))
      (with-selected-window this-window
        (switch-to-buffer that-buffer))
      (with-selected-window that-window
        (switch-to-buffer this-buffer))
      (select-window that-window))))

(defun null/evil-window-move-left ()
  "Swap windows to the left."
  (interactive) (null/evil-window-swap 'left))
(defun null/evil-window-move-right ()
  "Swap windows to the right."
  (interactive) (null/evil-window-swap 'right))
(defun null/evil-window-move-up ()
  "Swap windows upward."
  (interactive) (null/evil-window-swap 'up))
(defun null/evil-window-move-down ()
  "Swap windows downward."
  (interactive) (null/evil-window-swap 'down))

(defun null/windows-scroll-half-page-down ()
  "Scrolls exactly half page down keeping cursor/point position."
  (interactive)
  (null/windows-scroll-half-page nil))

(defun null/windows-scroll-half-page-up ()
  "Scrolls exactly half page up keeping cursor/point position."
  (interactive)
  (null/windows-scroll-half-page t))

(defun null/toggle-maximize-window ()
  "Toggle full view of selected window."
  (interactive)
  (if (window-parent)
      (delete-other-windows)
    (winner-undo)))

;; Split priority
(setq split-height-threshold nil
      split-width-threshold nil
      evil-vsplit-window-right t
      evil-split-window-below t)

;; Packages
(use-package winner
  :config
  ;; Allow restoring window changes
  (winner-mode +1))

(defun null/text-scale-increase ()
  "Increase text scale by 4 step."
  (interactive)
  (global-text-scale-adjust 4))

(defun null/text-scale-decrease ()
  "Decrease text scale by -4 step."
  (interactive)
  (global-text-scale-adjust -4))

(use-package shackle
  :commands shackle-mode
  :hook (after-init . shackle-mode)
  :config
  (setq shackle-default-alignment 'below
        shackle-default-size 0.4
        shackle-rules
        '(("*org-roam*"                    :align right  :size 0.3    :select t)
          ("\\*Embark Export:"             :regexp t   :align below :size 0.25 :select t)
          ("\\*Embark Live:"               :regexp t   :align right :size 0.5 :select t)
          (embark-collect-mode             :regexp nil :align below :size 0.25 :select t)
          ("*Org Links*"                   :noselect nil :size 0.1)
          ("*Org Export Process*"          :noselect t   :size 0.25 :align below)
          ("*Backtrace*"                   :noselect t   :align below :size 0.25)
          ("*Warnings*"                    :noselect t   :align below :size 0.25)
          ("*Error*"                       :noselect t   :size 0.25)
          ("*compilation*"                 :noselect t   :size 0.33 :align below)
          ("*eldoc"                        :regexp t     :noselect t   :size 0.33 :align below)
          (vterm-mode                      :select t     :size 0.25 :align below)
          (pike-mode                       :select t :size 0.15 :align below)
          (deadgrep-mode                   :select t :size 0.5 :align right)
          (compilation-mode                :noselect t   :size 0.25)
          (messages-buffer-mode            :noselect t   :align below :size 0.25)
          (help-mode                       :align below  :select t)
          (helpful-mode                    :align below)
          ;; (magit-status-mode               :align right  :inhibit-window-quit t)
          ;; (magit-log-mode                  :same t       :inhibit-window-quit t)
          ;; (magit-commit-mode               :align below)
          ;; (magit-diff-mode                 :select nil   :align left  :size 0.5)
          (git-commit-mode                 :align below  :same t)
          (inferior-python-mode            :noselect t  :size 0.25, :align below)
          (vc-annotate-mode                :same t))))

;;; Bindings
(null-keybinds-leader-key-def
  :states 'normal
  "w m" '(evil-window-left :wk "Select window left")
  "w n" '(evil-window-down :wk "Select window down")
  "w e" '(evil-window-up :wk "Select window up")
  "w i" '(evil-window-right :wk "Select window right")
  "w M" '(null/evil-window-move-left :wk "Move window left")
  "w N" '(null/evil-window-move-down :wk "Move window down")
  "w E" '(null/evil-window-move-up :wk "Move window up")
  "w I" '(null/evil-window-move-right :wk "Move window right")
  "w v" '(evil-window-vsplit :wk "Vertical window split")
  "w s" '(evil-window-split :wk "Horizontal window split")
  "w u" '(winner-undo :wk "Undo layout change")
  "w r" '(winner-redo :wk "Redo layout change")
  "w q" '(evil-quit :wk "Evil quit")
  "w =" '(balance-windows :wk "Balance windows")
  "w o" '(null/toggle-maximize-window :wk "Toggle maximize window")

  ;; For standard vi bindings (incase of non-colemak kb)
  "w h" '(evil-window-left :wk "Select window left")
  "w j" '(evil-window-down :wk "Select window down")
  "w k" '(evil-window-up :wk "Select window up")
  "w l" '(evil-window-right :wk "Select window right")
  "w H" '(null/evil-window-move-left :wk "Move window left")
  "w J" '(null/evil-window-move-down :wk "Move window down")
  "w K" '(null/evil-window-move-up :wk "Move window up")
  "w L" '(null/evil-window-move-right :wk "Move window right")

  "w +" '(null/text-scale-increase :wk "Fontsize increase global")
  "w -" '(null/text-scale-decrease :wk "Fontsize decrease global"))

(provide 'null-windows)

;;; null-windows.el ends here
