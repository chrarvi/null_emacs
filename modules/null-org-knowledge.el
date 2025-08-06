;;; null-org-knowledge.el --- summary -*- lexical-binding: t -*-

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

(require 'null-org)

(defconst null/orbit-directory (expand-file-name "orbit" null/org-directory)
  "Path to orbit directory.")

(defconst null/citar-path (concat null/org-directory "bibliography")
  "Path to citar base directory")

(defconst null/citar-bibliography-path (expand-file-name "references.bib" null/citar-path)
  "Path to file bibliography file.")

(defun convert-file-path-to-relative (file-path fixed-directory)
  "Convert FILE-PATH to a relative path based on FIXED-DIRECTORY."
  (let* ((file-directory (file-name-directory file-path))
         (relative-path (file-relative-name fixed-directory file-directory)))
    (concat relative-path "/")))

(defun null/orbit-org-download-screenshot ()
  "Set `org-download-image-dir' to a relative path based on the current buffer's file path."
  (interactive)
  (let* ((file-path (buffer-file-name))
         (relative-path (convert-file-path-to-relative file-path (expand-file-name "articles/assets/images" null/orbit-directory))))
    (setq-local org-download-image-dir relative-path)
    (org-download-screenshot)
    (message "org-download-image-dir set to: %s" relative-path)))

(defun null/org-download-named-screenshot (fname)
  "Download and save a region directly to FNAME."
  (interactive "FEnter Filename:")
  (make-directory (file-name-directory fname) t)
  (if (functionp org-download-screenshot-method)
      (funcall org-download-screenshot-method fname)
    (shell-command-to-string
     (format org-download-screenshot-method fname)))
  (org-download-image fname))

;; I only use this for saving images to my org-roam buffers. All their images will be stored in
;; ../assets/imagse so that the links to those images will also be relative. This is important
;; for export purposes later, since I don't want any absolute paths to images.
(use-package org-download
  :after org
  :config
  (setq org-download-screenshot-method "flameshot gui --raw > %s"
        org-download-method 'directory
        org-download-timestamp "%Y-%m-%d_%H-%M-%S_")
  (setq-default org-download-heading-lvl nil))


(use-package citar
  :after org nerd-icons
  :bind (:map minibuffer-local-map
              ("M-b" . citar-insert-preset))
  :custom
  (org-cite-global-bibliography (list null/citar-bibliography-path))
  (citar-bibliography org-cite-global-bibliography)
  (citar-notes-paths (list null/citar-path))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-symbols
   `((file ,(nerd-icons-faicon "nf-fa-file")))
   `((note ,(nerd-icons-faicon "nf-fa-file_text")))
   `((link ,(nerd-icons-faicon "nf-fa-link"))))
  (citar-symbol-separator "  ")
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup))

(use-package citar-embark
  :after citar embark
  :no-require
  :config (citar-embark-mode))

(use-package org-roam
  :after org
  :init
  (setq org-roam-v2-ack t)
  :hook
  (org-roam-find-file . balance-windows)
  (org-follow-link . balance-windows)
  :custom
  (org-roam-directory (expand-file-name "articles" null/orbit-directory))
  (org-roam-auto-replace-fuzzy-links nil)
  (org-roam-database-connector 'sqlite-builtin)
  (org-roam-completion-everywhere nil)
  (org-roam-db-autosync-mode t)
  :config
  (add-hook 'org-roam-mode-hook #'visual-line-mode)
  (setq org-roam-capture-templates
        `(("l" "lecture note" plain
           (file ,(expand-file-name "templates/lecture_note.org" null/orbit-directory))
           :target (file "%<%Y%m%d%H%M%S>-${slug}.org")
           :unnarrowed t)
          ("p" "permanent note" plain
           (file ,(expand-file-name "templates/basic.org" null/orbit-directory))
           :target (file "%<%Y%m%d%H%M%S>-${slug}.org")
           :unnarrowed t)
          ("m" "metanote" plain
           (file ,(expand-file-name "templates/metanote.org" null/orbit-directory))
           :target (file "%<%Y%m%d%H%M%S>-${slug}.org")
           :unnarrowed t)
          ("r" "paper note" plain
           (file ,(expand-file-name "templates/paper.org" null/orbit-directory))
           :target (file "paper_${slug}.org")
           :unnarrowed t)
          ("n" "notebook" plain
           (file ,(expand-file-name "templates/notebook.org" null/orbit-directory))
           :target (file "%<%Y%m%d%H%M%S>-${slug}.org")
           :unnarrowed t)))

  (setq org-roam-dailies-directory "daily"
        org-roam-dailies-capture-templates
        '(("d" "default" entry "* %?" :unnarrowed t :target
           (file+head "daily_%<%Y_%m_%d>.org" "#+filetags: :daily:\n#+title: %<%Y-%m-%d>\n\n")))))

(use-package citar-org-roam
  :after citar org-roam
  :no-require
  :config (citar-org-roam-mode)
  (setq citar-org-roam-note-title-template "${author:%etal} :: ${title}"
        citar-org-roam-capture-template-key "r"))

(use-package consult-org-roam

   :after org-roam
   :init
   (require 'consult-org-roam)
   ;; Activate the minor mode
   (consult-org-roam-mode 1)
   :custom
   ;; Use `ripgrep' for searching with `consult-org-roam-search'
   (consult-org-roam-grep-func #'consult-ripgrep)
   ;; Configure a custom narrow key for `consult-buffer'
   (consult-org-roam-buffer-narrow-key ?r)
   ;; Display org-roam buffers right after non-org-roam buffers
   ;; in consult-buffer (and not down at the bottom)
   (consult-org-roam-buffer-after-buffers t))

(defun null/truncate-string-to-width (str max-width &optional ellipsis)
  "Truncate STR to MAX-WIDTH characters, considering display width.
If the truncated string is shorter than STR, append ELLIPSIS if provided."
  (let* ((ellipsis (or ellipsis ""))
         (ellipsis-width (string-width ellipsis))
         (available-width (max 0 (- max-width ellipsis-width)))
         (accum-width 0)
         (result ""))
    (catch 'done
      (dolist (char (string-to-list str))
        (let ((char-width (char-width char)))
          (if (> (+ accum-width char-width) available-width)
              (throw 'done nil)
            (setq result (concat result (string char)))
            (setq accum-width (+ accum-width char-width))))))
    (if (< (string-width result) (string-width str))
        (concat result ellipsis)
      result)))

(defun null/pad-or-truncate-string (str max-width &optional ellipsis)
  "Truncate STR to MAX-WIDTH characters or pad with spaces.
If truncating, append ELLIPSIS if provided.
If STR is nil, treat it as an empty string."
  (let* ((str (or str ""))
         (truncated-str (null/truncate-string-to-width str max-width ellipsis)))
    (if (< (string-width truncated-str) max-width)
        (concat truncated-str (make-string (- max-width (string-width truncated-str)) ? ))
      truncated-str)))

(use-package org-mem
  :defer
  :config
  (setq org-mem-do-sync-with-org-id 1)
  (setq org-mem-watch-dirs (list (expand-file-name "articles" null/orbit-directory)))
  (org-mem-updater-mode))

(use-package org-node
  :after org
  :custom
  (org-node-extra-id-dirs (list (expand-file-name "articles" null/orbit-directory)))
  (org-node-alter-candidates t)

  (org-node-affixation-fn
   (defun my-prefix-with-tag (node title)
     "Let NODE's tags be right-aligned and prefix TITLE."
     (let* ((tags (when-let ((tags (org-node-get-tags-local node)))
                    (concat "#" (string-join tags " #"))))
            (padded-title (null/pad-or-truncate-string title 150 "..."))
            (padded-tags (null/pad-or-truncate-string tags 30 "..."))
            (filepath (f-filename (org-mem-file-truename node))))
       (list nil padded-title
             (concat
              (propertize padded-tags 'face 'font-lock-keyword-face)
              (propertize filepath 'face 'org-tag))))))

  (org-node-creation-fn #'org-node-new-via-roam-capture)
  (org-node-file-slug-fn #'org-node-slugify-like-roam-default)
  (org-node-file-timestamp-format "%Y%m%d%H%M%S-")
  :config
  (org-node-cache-mode)
  (org-node-roam-accelerator-mode)
  (org-node-complete-at-point-mode t))

;; Review dependencies
(use-package ht)
(use-package ts)

(use-package org-roam-review
  :ensure (:host github :repo "chrisbarrett/nursery" :files ("lisp/org-roam-review.el" "lisp/org-tags-filter.el" "lisp/plisty.el"))
  :after (org-roam org-drill ts)
  :hook (org-roam-capture-new-node . org-roam-review-set-seedling)
  :commands (org-roam-review
             org-roam-review-list-by-maturity
             org-roam-review-list-recently-added)
  :general
  (:states '(normal) :keymaps 'org-roam-review-mode-map
           "TAB" 'magit-section-cycle
           "g r" 'org-roam-review-refresh))

(defcustom writeroom-text-scale 2.0 "Scale increase for text in writeroom." :type 'integer)

(use-package writeroom-mode
  :after visual-fill-column
  :hook
  (writeroom-mode-enable . (lambda () (text-scale-increase writeroom-text-scale)))
  (writeroom-mode-disable . (lambda () (text-scale-decrease writeroom-text-scale)))
  :custom
  (writeroom-width 60)
  (writeroom-fullscreen-effect 'maximized)
  (writeroom-restore-window-config t)
  :config
  ;; adjust writeroom one font resize
  (advice-add 'text-scale-adjust :after
              #'visual-fill-column-adjust)
  (advice-add 'mouse-wheel-text-scale :after
              #'visual-fill-column-adjust)
  (advice-add 'mouse-wheel-global-text-scale :after
              #'visual-fill-column-adjust))

(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode))

(use-package jinx
  :hook (after-init-hook . global-jinx-mode)
  :general (:states '(normal) :keymaps 'jinx-mode-map
           "z =" 'jinx-correct))

(null-keybinds-leader-key-def
  :states 'normal
  "n r" '(:ignore t :wk "Org roam")
  "n r f" '(org-node-find :wk "Find node")
  ;; "n r R" '(org-roam-rewrite-rename :wk "Rename node")
  "n r S" '(org-roam-db-sync :wk "Sync roam database")
  "n r a" '(org-node-alias-add :wk "Add alias")
  "n r c" '(citar-open :wk "Find cite")
  "n r n" '(citar-open-note :wk "Find cite note")
  "n r p" '(citar-open-files :wk "Find cite pdf")
  "n r i" '(org-node-insert-link :wk "Insert node")
  "n r r" '(org-node-visit-random :wk "Random node")
  "n r s" '(org-roam-buffer-toggle :wk "Toggle org roam status buffer")
  "n r t" '(org-node-tag-add :wk "Add tag")
  "n r u" '(org-roam-ui-open :wk "Open org roam ui")

  "n c" '(:ignore t :wk "Org roam capture")
  "n c p" '((lambda () (interactive) (org-roam-capture :keys "p")) :wk "permanent note")
  "n c l" '((lambda () (interactive) (org-roam-capture :keys "l")) :wk "lecture")
  "n c m" '((lambda () (interactive) (org-roam-capture :keys "m")) :wk "metanote")
  "n c r" '((lambda () (interactive) (org-roam-capture :keys "r")) :wk "paper")
  "n c n" '((lambda () (interactive) (org-roam-capture :keys "n")) :wk "notebook")

  "n a" '(:ignore t :wk "Org roam attach")
  "n a c" '(null/orbit-org-download-screenshot :wk "Download screenshot")

  "n d" '(:ignore t :wk "Org roam dailies")
  "n d T" '(org-roam-dailies-capture-today :wk "capture today")
  "n d Y" '(org-roam-dailies-capture-yesterday :wk "capture yesterday")
  "n d D" '(org-roam-dailies-capture-date :wk "capture by date")
  "n d t" '(org-roam-dailies-find-today :wk "find today")
  "n d y" '(org-roam-dailies-find-yesterday :wk "find yesterday")
  "n d d" '(org-roam-dailies-find-date :wk "find by date")
  "n d p" '(org-roam-dailies-goto-previous-note :wk "find previous note")
  "n d n" '(org-roam-dailies-goto-next-note :wk "find next note")

  "n e" '(:ignore t :wk "Org roam review")
  "n e a" '(org-roam-review-accept :wk "accept")
  "n e b" '(org-roam-review-set-budding :wk "set budding")
  "n e e" '(org-roam-review-set-evergreen :wk "set evergreen")
  "n e r" '(org-roam-review :wk "review")
  "n e s" '(org-roam-review-set-seedling :wk "set seedling")
  "n e u" '(org-roam-review-bury :wk "bury")
  "n e x" '(org-roam-review-set-excluded :wk "set excluded")

  "n s" '(:ignore t :wk "Org roam consult")
  "n s i" '(consult-org-roam-backlinks :wk "incoming links")
  "n s o" '(consult-org-roam-forward-links :wk "outgoing links")
  "n s /" '(consult-org-roam-search :wk "search")

  "t z" '(writeroom-mode :wk "Toggle writeroom mode")
  "t Z" '(global-writeroom-mode :wk "Toggle global writeroom mode")
  "t i" '(org-toggle-inline-images :wk "Toggle inline images")

  "z =" '(jinx-correct :wk "Jinx correct at point"))


(provide 'null-org-knowledge)

;;; null-org-knowledge.el ends here
