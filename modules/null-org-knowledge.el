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

(use-package citar-org-node
  :vc ( :url "https://github.com/krisbalintona/citar-org-node.git"
        :rev :newest)
  :config (citar-org-node-mode)
  (setq citar-org-node-note-title-template "${author:%etal} :: ${title}"))

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

  (org-node-creation-fn #'org-capture)
  (org-node-file-slug-fn #'org-node-slugify-like-roam-default)
  (org-node-file-timestamp-format "%Y%m%d%H%M%S-")

  :config
  (setq org-capture-templates
        `(("l" "Lecture note"
           plain (function org-node-capture-target)
           (file ,(expand-file-name "templates/lecture_note.org" null/orbit-directory))
           :empty-lines-after 1
           :unnarrowed t)

          ("p" "Permanent note"
           plain (function org-node-capture-target)
           (file ,(expand-file-name "templates/basic.org" null/orbit-directory))
           :empty-lines-after 1
           :unnarrowed t)

          ("m" "Metanote"
           plain (function org-node-capture-target)
           (file ,(expand-file-name "templates/metanote.org" null/orbit-directory))
           :empty-lines-after 1
           :unnarrowed t)

          ("r" "Paper note"
           plain (function org-node-capture-target)
           (file ,(expand-file-name "templates/paper.org" null/orbit-directory))
           :empty-lines-after 1
           :unnarrowed t)

          ("n" "Notebook"
           plain (function org-node-capture-target)
           (file ,(expand-file-name "templates/notebook.org" null/orbit-directory))
           :empty-lines-after 1
           :unnarrowed t)))


  (org-node-cache-mode +1)
  (org-node-complete-at-point-mode t))

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
  "n r" '(:ignore t :wk "Org node")
  "n r f" '(org-node-find :wk "Find node")
  "n r a" '(org-node-alias-add :wk "Add alias")
  "n r c" '(citar-open :wk "Find cite")
  "n r n" '(citar-open-note :wk "Find cite note")
  "n r p" '(citar-open-files :wk "Find cite pdf")
  "n r i" '(org-node-insert-link :wk "Insert node")
  "n r r" '(org-node-visit-random :wk "Random node")
  "n r t" '(org-node-tag-add :wk "Add tag")
  "n a" '(:ignore t :wk "Org node attach")
  "n a c" '(null/orbit-org-download-screenshot :wk "Download screenshot")

  "t z" '(writeroom-mode :wk "Toggle writeroom mode")
  "t Z" '(global-writeroom-mode :wk "Toggle global writeroom mode")
  "t i" '(org-toggle-inline-images :wk "Toggle inline images")

  "z =" '(jinx-correct :wk "Jinx correct at point"))


(provide 'null-org-knowledge)

;;; null-org-knowledge.el ends here
