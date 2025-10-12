;;; null-org-agenda.el --- summary -*- lexical-binding: t -*-

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

(require 'org-habit)
(require 'null-org)
(add-to-list 'org-modules 'org-habit)

(defun null/org-agenda-open-todos (&optional arg)
  "Open todo view."
  (interactive "P")
  (org-agenda arg "t"))

(defun null/org-agenda-open-work (&optional arg)
  "Open work agenda view."
  (interactive "P")
  (org-agenda arg "w"))

(defun null/org-agenda-open-personal (&optional arg)
  "Open personal agenda view."
  (interactive "P")
  (org-agenda arg "a"))

(defun null/org-capture-to-project-heading ()
  "Capture to a project heading via completion."
  (interactive)
  (let ((projects
         (org-map-entries `(lambda () (nth 4 (org-heading-components)))
                          "+project+LEVEL=2" (list null/org-capture-work-file))))
    (setq choice (completing-read "Project: " projects nil t nil nil))
    (org-capture-set-target-location (list 'file+headline null/org-capture-work-file choice))))

(defun null/consult-clock-in ()
  "Clock into an Org agenda heading."
  (interactive)
  (save-window-excursion
    (consult-org-agenda)
    (org-clock-in)))

(defun null/consult-clock-in-recent (&optional match scope resolve)
  "Clock into an Org heading."
  (interactive (list nil nil current-prefix-arg))
  (require 'org-clock)
  (org-clock-load)
  (save-window-excursion
    (consult-org-heading
     match
     (or scope
         (thread-last org-clock-history
                      (mapcar 'marker-buffer)
                      (mapcar 'buffer-file-name)
                      (delete-dups)
                      (delq nil))
         (user-error "No recent clocked tasks")))
    (org-clock-in nil (when resolve
                        (org-resolve-clocks)
                        (org-read-date t t)))))

(with-eval-after-load 'consult
  (consult-customize null/consult-clock-in
                     :prompt "Clock in: "
                     :preview-key (kbd "M-."))
  (consult-customize null/consult-clock-in-recent
                     :prompt "Clock in: "
                     :preview-key (kbd "M-.")
                     :group
                     (lambda (cand transform)
                       (let* ((marker (get-text-property 0 'consult--candidate cand))
                              (name (if (member marker org-clock-history)
                                        "*Recent*"
                                      (buffer-name (marker-buffer marker)))))
                         (if transform (substring cand (1+ (length name))) name)))))

(with-eval-after-load 'org
  (add-hook 'after-save-hook
            (lambda () (if (derived-mode-p 'org-mode)
                           (org-update-statistics-cookies t))))

  (org-clock-persistence-insinuate) ; hooks for clock persistence
  (setq null/org-capture-todo-file null/org-capture-todo-file
        org-capture-journal-file null/org-capture-journal-file

        org-agenda-files (list null/org-capture-todo-file null/org-capture-work-file)
        org-refile-targets '((org-agenda-files :maxlevel . 2))
        org-refile-allow-creating-parent-nodes 'confirm
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil

        ; habit
        org-habit-graph-column 60
        org-log-done 'time
        org-log-into-drawer t
        org-agenda-window-setup 'other-frame
        org-agenda-start-with-log-mode t

        ;; clock
        org-clock-persist t ; persist clock
        )

  ;; Todo keyswords
  (setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d!)" "CANC(c@)")
                            (sequence "[ ](T)" "[>](N)" "[?](W@/!)" "|" "[X](D!)" "[-](C@)")))

  (setq org-todo-keyword-faces '(("TODO" . org-warning)
                                 ("NEXT" . org-priority)
                                 ("WAIT" . org-table)
                                 ("DONE" . org-done)
                                 ("CANC" . org-upcoming-distant-deadline)
                                 ("[ ]". org-warning)
                                 ("[>]" . org-priority)
                                 ("[?]" . org-table)
                                 ("[X]" . org-done)
                                 ("[-]" . org-distant-deadline))))


;; Cleaner agenda
(with-eval-after-load 'org
  (setq mixed-pitch-fixed-pitch-faces
        (quote (line-number-current-line line-number font-lock-comment-face org-done org-todo org-todo-keyword-outd org-todo-keyword-kill org-todo-keyword-wait org-todo-keyword-done org-todo-keyword-habt org-todo-keyword-todo org-tag org-ref-cite-face org-property-value org-special-keyword org-date diff-added org-drawer diff-context diff-file-header diff-function diff-header diff-hunk-header diff-removed font-latex-math-face font-latex-sedate-face font-latex-warning-face font-latex-sectioning-5-face font-lock-builtin-face font-lock-comment-delimiter-face font-lock-constant-face font-lock-doc-face font-lock-function-name-face font-lock-keyword-face font-lock-negation-char-face font-lock-preprocessor-face font-lock-regexp-grouping-backslash font-lock-regexp-grouping-construct font-lock-string-face font-lock-type-face font-lock-variable-name-face markdown-code-face markdown-gfm-checkbox-face markdown-inline-code-face markdown-language-info-face markdown-language-keyword-face markdown-math-face message-header-name message-header-to message-header-cc message-header-newsgroups message-header-xheader message-header-subject message-header-other mu4e-header-key-face mu4e-header-value-face mu4e-link-face mu4e-contact-face mu4e-compose-separator-face mu4e-compose-header-face org-block org-block-begin-line org-block-end-line org-document-info-keyword org-code org-indent org-latex-and-related org-checkbox org-formula org-meta-line org-table org-verbatim)))

  (setq org-agenda-block-separator (string-to-char " ")
        org-agenda-block-separator nil
        org-agenda-start-with-entry-text-mode nil
        org-agenda-breadcrumbs-separator " ❱ "
        org-agenda-entry-text-leaders "        "
        org-habit-today-glyph ?◌
        org-habit-graph-column 60

        org-habit-following-days 1
        org-habit-show-habits t
        org-habit-completed-glyph ?●
        org-habit-preceding-days 10
        org-habit-show-habits-only-for-today t
        org-habit-missed-glyph ?○
        org-agenda-hidden-separator "‌‌ "
        org-fontify-done-headline t
        org-fontify-whole-heading-line t
        org-fontify-quote-and-verse-blocks t)

  (with-eval-after-load 'nerd-icons
    (setq org-agenda-category-icon-alist
          `(
            ("todo" ,(nerd-icons-faicon "nf-fa-check_square"))
            ("music" ,(nerd-icons-faicon "nf-fa-music"))
            ("chore" ,(nerd-icons-faicon "nf-fa-repeat"))
            ("idea" ,(nerd-icons-faicon "nf-fa-lightbulb_o")
             ("scheduled" ,(nerd-icons-faicon "nf-fa-calendar_check_o"))
             ("class" ,(nerd-icons-faicon "nf-fa-book"))
             ("loop" ,(nerd-icons-faicon "nf-fa-repeat"))
             ("work" ,(nerd-icons-faicon "nf-fa-briefcase"))
             ("project" ,(nerd-icons-faicon "nf-fa-flag"))
             ("meeting" ,(nerd-icons-faicon "nf-fa-calendar_o"))
             ("todo" ,(nerd-icons-faicon "nf-fa-check"))))))

  (setq org-agenda-custom-commands
        '(
          ("a" "Personal Agenda"
           (
            (agenda "" (
                        (org-agenda-skip-scheduled-if-done nil)
                        (org-agenda-time-leading-zero t)
                        (org-agenda-timegrid-use-ampm nil)
                        (org-agenda-skip-timestamp-if-done t)
                        (org-agenda-skip-deadline-if-done t)
                        (org-agenda-start-day "+0d")
                        (org-agenda-span 2)
                        (org-agenda-overriding-header " Calendar")
                        (org-agenda-repeating-timestamp-show-all nil)
                        (org-agenda-remove-tags t)
                        (org-agenda-prefix-format "   %i %?-2 t%s")
                        ;; (org-agenda-prefix-format "  %-3i  %-15b%t %s")
                        ;; (concat "  %-3i  %-15b %t%s" org-agenda-hidden-separator))
                        ;; (org-agenda-todo-keyword-format " ☐ ")
                        (org-agenda-todo-keyword-format "")
                        (org-agenda-time)
                        (org-agenda-current-time-string "┈┈┈┈┈┈┈ Now")
                        (org-agenda-scheduled-leaders '("" ""))
                        (org-agenda-deadline-leaders '("Deadline:  " "In %3d d.: " "%2d d. ago: "))
                        (org-agenda-time-grid (quote ((today require-timed remove-match) () "      " "┈┈┈┈┈┈┈┈┈┈┈┈┈")))))

            (tags "-work+TODO=\"TODO\"|-work+TODO=\"DONE\"" (
                                                             (org-agenda-overriding-header "\n Today")
                                                             (org-agenda-sorting-strategy '(priority-down))
                                                             (org-agenda-remove-tags t)
                                                             (org-agenda-skip-function '(org-agenda-skip-entry-if 'timestamp 'scheduled))
                                                             ;; (org-agenda-todo-ignore-scheduled 'all)
                                                             (org-agenda-prefix-format "   %-2i %?b")
                                                             ;; (org-agenda-todo-keyword-format "")
                                                             ))

            (tags "-work+TODO=\"NEXT\"" (
                                         (org-agenda-overriding-header "\n Next")
                                         (org-agenda-sorting-strategy '(priority-down))
                                         (org-agenda-remove-tags t)
                                         ;; (org-agenda-skip-function '(org-agenda-skip-entry-if 'timestamp))
                                         (org-agenda-todo-ignore-scheduled 'all)
                                         (org-agenda-prefix-format "   %-2i %?b")
                                         (org-agenda-todo-keyword-format "")))


            (tags "-work+project-CATEGORY=\"work\"" (
                                                     (org-agenda-overriding-header "\n Projects")
                                                     (org-agenda-remove-tags t)
                                                     (org-tags-match-list-sublevels nil)
                                                     (org-agenda-show-inherited-tags nil)
                                                     (org-agenda-prefix-format "   %-2i %?b")
                                                     (org-agenda-todo-keyword-format "")))
            ))

          ("w" "Work Agenda"
           (
            (agenda "" (
                        (org-agenda-skip-scheduled-if-done nil)
                        (org-agenda-time-leading-zero t)
                        (org-agenda-skip-timestamp-if-done t)
                        (org-agenda-skip-deadline-if-done t)
                        (org-agenda-entry-text-leaders "")
                        (org-agenda-start-day "+0d")
                        (org-agenda-span 2)
                        (org-agenda-log-mode-items '(clock))
                        (org-agenda-overriding-header "\n Calendar")
                        (org-agenda-remove-tags t)
                        (org-agenda-prefix-format "    %i %?-2 t %?-8T %s")
                        (org-agenda-todo-keyword-format "")
                        (org-agenda-time)
                        (org-agenda-current-time-string "┈┈┈┈┈┈┈┈ Now ┈┈┈┈┈┈┈┈")
                        (org-agenda-scheduled-leaders '("" ""))
                        (org-agenda-deadline-leaders '("Deadline:  " "In %3d d.: " "%2d d. ago: "))
                        (org-agenda-time-grid (quote ((today require-timed remove-match) () "      " "┈┈┈┈┈┈┈┈┈┈┈┈┈")))))

            (tags "+work+TODO=\"TODO\"-CATEGORY=\"project\"" (
                                                              (org-agenda-overriding-header "\n Inbox")
                                                              (org-agenda-sorting-strategy '(priority-down))
                                                              (org-agenda-remove-tags t)
                                                              (org-agenda-todo-ignore-scheduled 'all)
                                                              (org-agenda-prefix-format "   %-2i ")))
            (tags "LEVEL>1+work+CATEGORY=\"loop\"" (
                                                    (org-agenda-overriding-header "\n Habit")
                                                    (org-agenda-sorting-strategy '(priority-down))
                                                    (org-agenda-remove-tags t)
                                                    (org-agenda-todo-ignore-scheduled 'all)
                                                    (org-agenda-prefix-format "%i  %-2i ")))
            (tags "+work+TODO=\"NEXT\"" (
                                         (org-agenda-overriding-header "\n Next")
                                         (org-agenda-sorting-strategy '(priority-down))
                                         (org-agenda-remove-tags t)
                                         (org-agenda-todo-ignore-scheduled 'all)
                                         (org-agenda-prefix-format "    %-2i ")))
            (tags "+work+TODO=\"WAIT\"" (
                                         (org-agenda-overriding-header "\n Waiting")
                                         (org-agenda-sorting-strategy '(priority-down))
                                         (org-agenda-remove-tags t)
                                         (org-agenda-todo-ignore-scheduled 'all)
                                         (org-agenda-prefix-format "    %-2i ")))

            (tags "LEVEL>1+work+CATEGORY=\"project\"-TODO=\"DONE\"-TODO=\"CANC\"" (
                                                                                   (org-agenda-overriding-header "\n Projects")
                                                                                   (org-agenda-remove-tags t)
                                                                                   (org-tags-match-list-sublevels 'indentend)
                                                                                   (org-agenda-show-inherited-tags nil)
                                                                                   (org-agenda-prefix-format "%l%l%i "))))))))

(use-package org-drill
  :after org
  :custom
  (org-drill-file null/org-drill-file))

(null-keybinds-major-key-def
  :states 'normal
  :keymaps 'org-mode-map
  ;; Schedule
  "d s" 'org-schedule
  "d d" 'org-deadline

  ;; Clocks
  "c -" 'org-clock-timestamps-down
  "c =" 'org-clock-timestamps-up
  "c c" 'org-clock-cancel
  "c e" 'org-clock-modify-effort-esimate
  "c g" 'org-clock-goto
  "c i" 'org-clock-in
  "c l" 'org-clock-in-last
  "c o" 'org-clock-out
  "c R" 'org-clock-report)

(null-keybinds-leader-key-def
  :keymaps 'global-map
  "X" 'org-capture
  "o a /" 'consult-org-agenda
  "o a A" 'org-agenda
  "o a t" 'null/org-agenda-open-todos
  "o a w" 'null/org-agenda-open-work
  "o a p" 'null/org-agenda-open-personal

 ;; clocks
 "c i" 'consult-clock-in
 "c r" 'consult-clock-in
  "c g" 'org-clock-goto
 "c c" 'org-clock-cancel
  "c l" 'org-clock-in-last
  "c o" 'org-clock-out)

(provide 'null-org-agenda)

;;; null-org-agenda.el ends here
