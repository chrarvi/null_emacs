;;; null-org-latex.el --- summary -*- lexical-binding: t -*-

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

;; (defun my-latex-export-example-blocks (text backend info)
;;   "Export example blocks as listings env."
;;   (when (org-export-derived-backend-p backend 'latex)
;;     (with-temp-buffer
;;       (insert text)
;;       ;; replace verbatim env by listings
;;       (goto-char (point-min))
;;       (replace-string "\\begin{verbatim}" "\\begin{lstlisting}")
;;       (replace-string "\\end{verbatim}" "\\end{lstlisting}")
;;       (buffer-substring-no-properties (point-min) (point-max)))))

;; (add-to-list 'org-export-filter-example-block-functions
;;          'my-latex-export-example-blocks)

(defun null/setup-minted ()
  (setq org-latex-listings 'minted
        org-latex-custom-lang-environments '((emacs-lisp "common-lispcode"))
        org-latex-minted-options
        '(("bgcolor" "bgcode")
          ("fontsize" "\\scriptsize")
          ("baselinestretch" "0.9")
          ("framesep" "3mm")
          ("breaklines" "true")
          ("linenos" "true")
          ("numbersep" "2mm")
          ("xleftmargin" "6mm"))))

;; Scale up latex fragments
(with-eval-after-load 'org
  ;; (null/setup-minted)
  (setq org-latex-default-class "orbit"
        org-export-with-toc nil
        org-latex-packages-alist
        '(("dvipsnames" "xcolor")
          ;; ("" "minted")
          ("" "gentium")
          ("" "amsmath")
          ("" "amssymb")
          ("" "fancyhdr")
          ("" "microtype")
          ("" "mathtools")
          ("" "optidef")
          ("" "bm")
          ("ruled,vlined" "algorithm2e")
          ("" "esvect")
          ("" "esdiff")
          ("parfill" "parskip")
          ("" "pgf")
          ("" "fancyvrb")
          ("" "fvextra")
          ("" "etoolbox")
          ("" "booktabs"))
        org-cite-export-processors '((t csl))
        org-latex-tables-booktabs t
        org-latex-pdf-process '("LC_ALL=en_US.UTF-8 latexmk -f -pdf -%latex -shell-escape -interaction=nonstopmode -output-directory=%o %f"))

  (plist-put org-format-latex-options :scale 1.0))

(with-eval-after-load 'ox-latex


  (defun org-export-id-link-removal (backend)
    "Inspired by 'org-attach-expand-links' ，which is in 'org-export-before-parsing-functions' "
    (save-excursion
      (while (re-search-forward "id:" nil t)
        (let ((link (org-element-context)))
          (if (and (eq 'link (org-element-type link))
                   (string-equal "id"
                                 (org-element-property :type link)))
              (let ((description (and (org-element-property :contents-begin link)
                                      (buffer-substring-no-properties
                                       (org-element-property :contents-begin link)
                                       (org-element-property :contents-end link))))
                    )
                (goto-char (org-element-property :end link))
                (skip-chars-backward " \t")
                (delete-region (org-element-property :begin link) (point))
                (insert description))
            )))))

  (add-to-list 'org-export-before-parsing-functions #'org-export-id-link-removal)

  (add-to-list 'org-latex-classes
               '("orbit"
                 "
\\documentclass[a4paper,11pt]{article}
\\usepackage[a4paper, margin=3cm]{geometry}

[PACKAGES]
[EXTRA]
\\usepackage[colorlinks]{hyperref}

\\definecolor{bgcode}{rgb}{0.95,0.95,0.95}

\\AtBeginEnvironment{tabular}{\\scriptsize}

\\DefineVerbatimEnvironment{wideverbatim}{Verbatim}{%
  gobble=0,
  numbers=left,
  numbersep=1mm,
  fontsize=\\scriptsize,
  rulecolor=\color{gray},
  xleftmargin=10mm,
  breaklines=true,
}

\\RecustomVerbatimEnvironment{verbatim}{Verbatim}{%
  gobble=0,
  fontsize=\\scriptsize,
  rulecolor=\color{gray},
  xleftmargin=5mm,
  breaklines=true,
  breakanywhere=true,
}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;; (use-package org-latex-preview
;;   :hook (org-mode . org-latex-preview)
;;   :config
;;   ;; Increase preview width
;;   (plist-put org-latex-preview-appearance-options
;;              :page-width 1.0)

;;   ;No blur when scaling
;;   (setq org-latex-preview-process-default 'dvisvgm)

;;   ;; Turn on auto-mode, it's built into Org and much faster/more featured than
;;   ;; org-fragtog. (Remember to turn off/uninstall org-fragtog.)
;;   (add-hook 'org-mode-hook 'org-latex-preview-auto-mode)
;;   ;; Block C-n and C-p from opening up previews when using auto-mode
;;   (add-hook 'org-latex-preview-auto-ignored-commands 'next-line)
;;   (add-hook 'org-latex-preview-auto-ignored-commands 'previous-line)

;;   ;; Enable consistent equation numbering
;;   (setq org-latex-preview-numbered t)

;;   ;; Bonus: Turn on live previews.  This shows you a live preview of a LaTeX
;;   ;; fragment and updates the preview in real-time as you edit it.
;;   ;; To preview only environments, set it to '(block edit-special) instead
;;   (setq org-latex-preview-live t)

;;   ;; More immediate live-previews -- the default delay is 1 second
;;   (setq org-latex-preview-live-debounce 0.25)

;;   (defun my/org-latex-preview-uncenter (ov)
;;     (overlay-put ov 'before-string nil))
;;   (defun my/org-latex-preview-recenter (ov)
;;     (overlay-put ov 'before-string (overlay-get ov 'justify)))
;;   (defun my/org-latex-preview-center (ov)
;;     (save-excursion
;;       (goto-char (overlay-start ov))
;;       (when-let* ((elem (org-element-context))
;;                   ((or (eq (org-element-type elem) 'latex-environment)
;;                        (string-match-p "^\\\\\\[" (org-element-property :value elem))))
;;                   (img (overlay-get ov 'display))
;;                   (prop `(space :align-to (- center (0.55 . ,img))))
;;                   (justify (propertize " " 'display prop 'face 'default)))
;;         (overlay-put ov 'justify justify)
;;         (overlay-put ov 'before-string (overlay-get ov 'justify)))))
;;   (define-minor-mode org-latex-preview-center-mode
;;     "Center equations previewed with `org-latex-preview'."
;;     :global nil
;;     (if org-latex-preview-center-mode
;;         (progn
;;           (add-hook 'org-latex-preview-overlay-open-functions
;;                     #'my/org-latex-preview-uncenter nil :local)
;;           (add-hook 'org-latex-preview-overlay-close-functions
;;                     #'my/org-latex-preview-recenter nil :local)
;;           (add-hook 'org-latex-preview-overlay-update-functions
;;                     #'my/org-latex-preview-center nil :local))
;;       (remove-hook 'org-latex-preview-overlay-close-functions
;;                     #'my/org-latex-preview-recenter)
;;       (remove-hook 'org-latex-preview-overlay-update-functions
;;                     #'my/org-latex-preview-center)
;;       (remove-hook 'org-latex-preview-overlay-open-functions
;;                     #'my/org-latex-preview-uncenter))))

;; Beamer support
(use-package ox-beamer-lecture)

;; Latex
;; (use-package org-fragtog
;;   :hook (org-mode . org-fragtog-mode)
;;   :config
  ;; (setq org-fragtog-ignore-predicates '(org-at-table-p)))

;; (setq org-preview-latex-default-process 'dvisvgm) ;No blur when scaling

;; (defun my/text-scale-adjust-latex-previews ()
;;   "Adjust the size of latex preview fragments when changing the
;; buffer's text scale."
;;   (pcase major-mode
;;     ('latex-mode
;;      (dolist (ov (overlays-in (point-min) (point-max)))
;;        (if (eq (overlay-get ov 'category)
;;                'preview-overlay)
;;            (my/text-scale--resize-fragment ov))))
;;     ('org-mode
;;      (dolist (ov (overlays-in (point-min) (point-max)))
;;        (if (eq (overlay-get ov 'org-overlay-type)
;;                'org-latex-overlay)
           ;; (my/text-scale--resize-fragment ov))))))

;; (defun my/text-scale--resize-fragment (ov)
;;   (overlay-put
;;    ov 'display
;;    (cons 'image
;;          (plist-put
;;           (cdr (overlay-get ov 'display))
;;           :scale (+ 1.0 (* 0.25 text-scale-mode-amount))))))

;; (add-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews)

(use-package cdlatex
  :custom
  (cdlatex-use-dollar-to-ensure-math nil)
  :hook (org-mode . org-cdlatex-mode)
  :bind (:map cdlatex-mode-map
              ("<tab>" . cdlatex-tab)))

;; Numbered equations all have (1) as the number for fragments with vanilla
;; org-mode. This code injects the correct numbers into the previews so they
;; look good.
;; (defun scimax-org-renumber-environment (orig-func &rest args)
;;   "A function to inject numbers in LaTeX fragment previews."
;;   (let ((results '())
;;         (counter -1)
;;         (numberp))
;;     (setq results (cl-loop for (begin . env) in
;;                            (org-element-map (org-element-parse-buffer) 'latex-environment
;;                              (lambda (env)
;;                                (cons
;;                                 (org-element-property :begin env)
;;                                 (org-element-property :value env))))
;;                            collect
;;                            (cond
;;                             ((and (string-match "\\\\begin{equation}" env)
;;                                   (not (string-match "\\\\tag{" env)))
;;                              (cl-incf counter)
;;                              (cons begin counter))
;;                             ((string-match "\\\\begin{align}" env)
;;                              (prog2
;;                                  (cl-incf counter)
;;                                  (cons begin counter)
;;                                (with-temp-buffer
;;                                  (insert env)
;;                                  (goto-char (point-min))
;;                                  ;; \\ is used for a new line. Each one leads to a number
;;                                  (cl-incf counter (count-matches "\\\\$"))
;;                                  ;; unless there are nonumbers.
;;                                  (goto-char (point-min))
;;                                  (cl-decf counter (count-matches "\\nonumber")))))
;;                             (t
;;                              (cons begin nil)))))

;;     (when (setq numberp (cdr (assoc (point) results)))
;;       (setf (car args)
;;             (concat
;;              (format "\\setcounter{equation}{%s}\n" numberp)
;;              (car args)))))

;;   (apply orig-func args))


;; (defun scimax-toggle-latex-equation-numbering ()
;;   "Toggle whether LaTeX fragments are numbered."
;;   (interactive)
;;   (if (not (get 'scimax-org-renumber-environment 'enabled))
;;       (progn
;;         (advice-add 'org-create-formula-image :around #'scimax-org-renumber-environment)
;;         (put 'scimax-org-renumber-environment 'enabled t)
;;         (message "Latex numbering enabled"))
;;     (advice-remove 'org-create-formula-image #'scimax-org-renumber-environment)
;;     (put 'scimax-org-renumber-environment 'enabled nil)
;;     (message "Latex numbering disabled.")))

;; (advice-add 'org-create-formula-image :around #'scimax-org-renumber-environment)
;; (put 'scimax-org-renumber-environment 'enabled t)

(provide 'null-org-latex)

;;; null-org-latex.el ends here
