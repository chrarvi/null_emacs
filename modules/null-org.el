;;; null-org.el --- summary -*- lexical-binding: t -*-

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
(require 'org-indent)
(require 'ox-md)

(defconst null/org-directory (file-truename "~/Dropbox/org/")
  "Path to org directory.")

(defconst null/org-capture-todo-file (expand-file-name "agenda.org" null/org-directory)
  "Path to file containing personal todos.")

(defconst null/org-capture-work-file (expand-file-name "work.org" null/org-directory)
  "Path to file containing work todos.")

(defconst null/org-capture-work-journal-file (expand-file-name "work_journal.org" null/org-directory)
  "Path to file containing work journal.")

(defconst null/org-capture-journal-file (expand-file-name "journal.org" null/org-directory)
  "Path to file containing personal journal.")

(defconst null/org-drill-file (expand-file-name "drill.org" null/org-directory)
  "Path to file containing drills.")

(defun null/org-toggle-properties ()
  "Toggle visibility of properties in current header if it exists."
  (save-excursion
    (when (not (org-at-heading-p))
      (org-previous-visible-heading 1))
    (when (org-header-property-p)
      (let* ((a (re-search-forward "\n\\:" nil t)))
        (if (outline-invisible-p (point))
            (outline-show-entry)
          (org-cycle-hide-drawers 'all))))))

(defun null/org-toggle-link-display ()
  "Toggle the literal or descriptive display of links."
  (interactive)
  (if org-descriptive-links
      (progn (org-remove-from-invisibility-spec '(org-link))
         (org-restart-font-lock)
         (setq org-descriptive-links nil))
    (progn (add-to-invisibility-spec '(org-link))
       (org-restart-font-lock)
       (setq org-descriptive-links t))))

(defun null/org--get-foldlevel ()
  (let ((max 1))
    (save-restriction
      (narrow-to-region (window-start) (window-end))
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (org-next-visible-heading 1)
          (when (outline-invisible-p (line-end-position))
            (let ((level (org-outline-level)))
              (when (> level max)
                (setq max level))))))
      max)))

(defun null/org-show-next-fold-level (&optional count)
  "Decrease the fold-level of the visible area of the buffer. This unfolds
    another level of headings on each invocation."
  (interactive "p")
  (let ((new-level (+ (null/org--get-foldlevel) (or count 1))))
    (outline-hide-sublevels new-level)
    (message "Folded to level %s" new-level)))

(defun null/org-close-all-folds (&optional level)
  "Close all folds in the buffer (or below LEVEL)."
  (interactive "p")
  (outline-hide-sublevels (or level 1)))

(defun null/org-open-all-folds (&optional level)
  "Open all folds in the buffer (or up to LEVEL)."
  (interactive "P")
  (if (integerp level)
      (outline-hide-sublevels level)

    (outline-show-all)))


(defun null/org-mode-setup ()
  (setq fill-column 80)
  (auto-fill-mode t)
  (visual-line-mode 1)

  (dolist (face '((org-level-1 . 1.0)
                  (org-level-2 . 1.0)
                  (org-level-3 . 1.0)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.0)
                  (org-level-6 . 1.0)
                  (org-level-7 . 1.0)
                  (org-level-8 . 1.0)))
    (set-face-attribute (car face) nil :font "Iosevka Nerd Font" :weight 'bold :height (cdr face))))

(use-package org
  :hook
  (org-mode . null/org-mode-setup)
  (org-babel-after-execute . org-redisplay-inline-images)
  (org-capture-mode . evil-insert-state)
  :custom
  (org-confirm-babel-evaluate nil)
  (org-directory null/org-directory)
  (org-hide-leading-stars nil) ; superstar needs this to be nil
  (org-startup-indented t) ; indent mode on startup
  (org-startup-folded 'showeverythin)
  (org-indent-mode-turns-on-hiding-stars nil) ; superstar needs this to be nil
  (org-edit-src-content-indentation 4)


  ;; Visuals
  (org-highlight-latex-and-related '(native))
  (org-image-max-width 0.8)
  (org-image-actual-width t)
  (org-fontify-done-headline t)
  (org-fontify-quote-and-verse-blocks t)
  (org-fontify-whole-heading-line t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities nil)
  (org-startup-truncated nil) ; Force org to not truncate lines
  (org-startup-with-inline-images "inlineimages")

  (org-imenu-depth 3) ; See more levels with imenu
  (org-return-follows-link nil) ; use ret to follow link

  ;; TODO: see https://github.com/syl20bnr/spacemacs/issues/13465
  (org-src-tab-acts-natively nil)

  ;; Export settings
  (org-export-use-babel t) ; eval code on export
  (org-src-preserve-indentation t) ; keep leading whitespace in src blocks on export

  ;; Default apps
  (org-file-apps
   '((auto-mode . emacs)
     ("\\.mm\\'" . default)
     ("\\.x?html?\\'" . "qutebrowser %s")
     ("\\.pdf\\'" . "sioyek --shared-database-path $HOME/Dropbox/org/bibliography/sioyek/shared.db %s")
     ("\\.png\\'" . viewnior)
     ("\\.jpg\\'" . viewnior)
     ("\\.svg\\'" . viewnior))))

;; Pretty bullets
(use-package org-superstar
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-special-todo-items t)
  (org-superstar-leading-bullet ?\s)
  (org-superstar-headline-bullets-list '("◉" "◈" "○" "◇")))

;; Autotangle files marked #+auto_tangle: t
(use-package org-auto-tangle
  :after org
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default nil))

;; Convenient evil bindings
(use-package evil-org
  :after '(org evil)
  :hook
  (org-mode . evil-org-mode)
  (org-agenda-mode . evil-org-mode))

(use-package org-appear
  :after org
  :custom
  (org-appear-trigger 'automatic)
  (org-appear-autolinks nil)
  (org-appear-inside-latex nil)
  :config
  (setq org-appear-trigger 'manual)
  (add-hook 'org-mode-hook (lambda ()
                             (add-hook 'evil-insert-state-entry-hook
                                       #'org-appear-manual-start
                                       nil
                                       t)
                             (add-hook 'evil-insert-state-exit-hook
                                       #'org-appear-manual-stop
                                       nil
                                       t))))

(use-package org-modern
  :after org
  :custom
  ;; Looks bad with mixed pitch for me
  (org-modern-table nil)
  :config
  (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
  (global-org-modern-mode))

(use-package ox-pandoc)

(use-package ox-clip)

(use-package htmlize)

(use-package orgit
  ;; Link to magit buffers in org mode
  :after org
  :hook (git-commit-post-finish  . orgit-store-after-commit)
  :custom
  (orgit-rev-description-format "%%N (%%R): %s (%ai)")
  :config
  (defun orgit-store-after-commit ()
    "Store orgit-link for latest commit after commit message editor is finished.
    Source: https://www.reddit.com/r/emacs/comments/lsr161/wishlist_has_anyone_built_an_orgmode_git_log/
"
    (let* ((repo (abbreviate-file-name default-directory))
           (rev (magit-git-string "rev-parse" "HEAD"))
           (link (format "orgit-rev:%s::%s" repo rev))
           (summary (substring-no-properties (magit-format-rev-summary rev)))
           (desc (format "%s (%s)" summary repo)))
      (push (list link desc) org-stored-links))))

(null-keybinds-leader-key-def
  :states 'normal
  :keymaps 'org-mode-map
  "t l" 'null/org-toggle-link-display)

(null-keybinds-major-key-def
  :states 'normal
  :keymaps 'org-mode-map
  "k s" 'org-babel-demarcate-block
  "i l" 'org-cdlatex-environment-indent
  "i c" 'org-cite-insert
  "i f" 'org-footnote-new
  "i s" 'org-insert-structure-template
  "s n" 'org-toggle-narrow-to-subtree
  "o" 'org-open-at-point
  "t" 'org-todo
  "e" 'org-export-dispatch)

(general-define-key
 :states 'normal
 :keymaps 'org-mode-map
 "z r" 'null/show-next-fold-level
 "z R" 'null/open-all-folds
 "z i" 'org-toggle-inline-images
 "z p" 'null/org-toggle-properties
 "C-n" 'org-babel-next-src-block
 "C-e" 'org-babel-previous-src-block)

(provide 'null-org)

;;; null-org.el ends here
