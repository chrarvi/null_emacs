;;; null-latex.el --- summary -*- lexical-binding: t -*-

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

;; Latex support.

;;; Code:

(use-package tex
  :ensure auctex
  :mode
  ("\\.tex\\'" . latex-mode) ; Must first activate the inferior Emacs latex mode
  :hook
  (LaTeX-mode . TeX-PDF-mode)
  (LaTeX-mode . flyspell-mode)
  (LaTeX-mode . LaTeX-math-mode)
  (LaTeX-mode . reftex-mode)
  (LaTeX-mode . cdlatex-mode)
  :init
  ;; (load "preview-latex.el" nil t t)
  (require 'reftex)

  (setq-default TeX-master 'dwim)

  (setq TeX-data-directory (expand-file-name "auctex" package-user-dir)
        TeX-lisp-directory TeX-data-directory
        preview-TeX-style-dir (concat ".:" (expand-file-name "auctex" package-user-dir) "latex:")

        TeX-parse-self t ; parse on load
        TeX-auto-save t  ; parse on save
        TeX-auto-untabify t ; Automatically remove all tabs from a file before saving it.

                                        ;Type of TeX engine to use.
                                        ;It should be one of the following symbols:
                                        ;* ‘default’
                                        ;* ‘luatex’
                                        ;* ‘omega’
                                        ;* ‘xetex’
        TeX-engine 'xetex
        TeX-auto-local ".auctex-auto" ; Directory containing automatically generated TeX information.
        TeX-style-local ".auctex-style" ; Directory containing hand generated TeX information.

        ;; ##### Enable synctex correlation.
        ;; ##### From Okular just press `Shift + Left click' to go to the good line.
        ;; ##### From Evince just press `Ctrl + Left click' to go to the good line.
        TeX-source-correlate-mode t
        TeX-source-correlate-method 'synctex
        TeX-source-correlate-server t

        ;; automatically insert braces after sub/superscript in math mode
        TeX-electric-sub-and-superscript t
        ;; If non-nil, then query the user before saving each file with TeX-save-document.
        TeX-save-query nil

        TeX-view-program-selection '((output-pdf "PDF Tools"))))


(provide 'null-latex)

;;; null-latex.el ends here
