;;; pike.el --- Bookmarking utilities -*- lexical-binding: t -*-

;; Author: Christoffer Arvidsson
;; Maintainer: Christoffer Arvidsson
;; Version: 0.1
;; Package-Requires: ()
;; Homepage: homepage
;; Keywords: tools languages


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

;; Todos
;; - [x] separate by repo
;;   - [x] separate by branch
;; - [ ] make project package selectable
;; - [ ] make binding global vs non-global easier

;;; Code:

(require 'project)
(require 'vc-git)

(defgroup pike nil
  "Quick-jump organization."
  :version "0.1"
  :group 'tools)

(defcustom pike-cache-directory (expand-file-name user-emacs-directory ".local/pike")
  "Where the cache files will be saved."
  :type 'string
  :group 'pike)

(defcustom pike-tab-line-add-non-pike-file t
  "Whether to add the current non-pike file as the 5th tab."
  :type 'boolean
  :group 'pike)

(defun pike--create-cache-directory ()
  "Create cache directory of pike if it doesn't exist."
  (unless (file-directory-p pike-cache-directory)
    (make-directory pike-cache-directory)))

(defun pike--create-cache-file (cache-file)
  "Create CACHE-FILE if it doesn't exist."
  (unless (file-exists-p cache-file)
    (with-temp-buffer (write-file cache-file))))

(defun pike--global-cache-file-path ()
  "Get the file path for the global cache."
  (expand-file-name "pike_global" pike-cache-directory))

(defun pike--project-branch ()
  "Get the project git branch name."
  (car (vc-git-branches)))

(defun pike--project-cache-file-path ()
  "Get the file path for the current project cache."
  (if-let ((project (project-current))
           (root (project-root project))
           (branch (pike--project-branch)))
      (format "%s--%s"
              (expand-file-name (file-name-nondirectory
                                 (directory-file-name root))
                                pike-cache-directory)
              branch)))

(defun pike--cache-file-path (&optional global)
  "Get the cache file path for the current project.
If GLOBAL is non-nil then get the global cache file path."
  (if global
      (pike--global-cache-file-path)
    (pike--project-cache-file-path)))

(defun pike--revert-cache-buffer (cache-file)
  "Revert the CACHE-FILE buffer."
  (when-let (buffer (get-buffer cache-file))
    (with-current-buffer buffer
      (revert-buffer nil t))))

(defun pike--get-cache-buffer (&optional global)
  "Get pike cache buffer.
If GLOBAL is non-nil then get the global pike buffer."
  (find-file-noselect (pike--cache-file-path global)))

(defun pike--num-entries (cache-file)
  "Get number of entries in CACHE-FILE."
  (with-temp-buffer
    (insert-file-contents cache-file)
    (count-lines (point-min) (point-max))))

(defun pike--find-cache-number (cache-file search-string)
  "Get the line number of entry in CACHE-FILE matching SEARCH-STRING, or nil."
  (with-temp-buffer
    (insert-file-contents cache-file)
    (goto-char (point-min))
    (when (search-forward-regexp (regexp-quote search-string) nil t)
      (line-number-at-pos (line-beginning-position)))))

(defun pike--get-cache-key-at-line (cache-file line-number)
  "Get the line from CACHE-FILE at the specified LINE-NUMBER."
  (with-temp-buffer
    (insert-file-contents cache-file)
    (goto-char (point-min))
    (forward-line (1- line-number))
    (let ((row (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
      (if (or (= (length row) 0)
              (not (eq (line-number-at-pos (point)) line-number)))
          nil row))))

(defun pike--get-buffer-from-key (key)
  "Get buffer from pike KEY."
  (if-let ((buffer (get-buffer key)))
      buffer (find-file-noselect key t)))

(defun pike--find (cache-file line-number)
  "Find file at LINE-NUMBER in CACHE-FILE."
  (pike--create-cache-directory)
  (pike--create-cache-file cache-file)
  (if-let ((cache-key (pike--get-cache-key-at-line cache-file line-number))
           (buf (pike--get-buffer-from-key cache-key)))
      (switch-to-buffer buf)
    (message (format "Could not find pike file in entry %d" line-number))))

(defun pike--get-cache-key ()
  "Get the cache key of the current buffer."
  (let ((filename (buffer-file-name)))
    (if filename
        (abbreviate-file-name
         (if (equal major-mode 'dired-mode)
             default-directory filename))
      (if (buffer-name)
          (buffer-name)
        (message "Not a valid buffer to store in pike.")))))

(defun pike--get-buffers (cache-file)
  "Get buffer for each key in CACHE-FILE."
  (with-temp-buffer
    (insert-file-contents cache-file)
    (split-string (buffer-string) hard-newline t)
    (mapcar (lambda (line) (pike--get-buffer-from-key line))
            (split-string (buffer-string) hard-newline t))))

;;;###autoload
(defun pike-clear (&optional global)
  "Clear the global pike files.
If GLOBAL is non-nil then clear the global cache file."
  (interactive)
  (pike--create-cache-directory)
  (with-current-buffer (pike--get-cache-buffer global)
    (progn (erase-buffer)
           (save-buffer)
           (message "Pike buffer cleared."))))

;;;###autoload
(defun pike-add-key (&optional global)
  "Add current key to pike.
If GLOBAL is non-nil then add to global cache."
  (interactive)
  (pike--create-cache-directory)
  (let ((cache-file (pike--cache-file-path global))
        (cache-key (pike--get-cache-key)))
    (pike--create-cache-file cache-file)
    (if (pike--find-cache-number cache-file cache-key)
        (message (format "Key %s already in pike." cache-key))
      (with-current-buffer (pike--get-cache-buffer global)
        (goto-char (point-max))
        (insert cache-key)
        (insert hard-newline)
        (save-buffer)))
    (pike--revert-cache-buffer cache-file)))

;;;###autoload
(defun pike-open-buffer (&optional global)
  "Open the pike cache buffer.
If GLOBAL is non-nil open the global buffer."
  ;; TODO: We want to be able to open the global buffer from the
  ;; non-global ones, and vice-versa. Just checking the mode is not
  ;; enough here.
  (interactive)
  (unless (eq major-mode 'pike-mode)
    (pike--create-cache-directory)
    (pike--create-cache-file (pike--cache-file-path global))
    (let ((buffer (pike--get-cache-buffer global)))
      (with-current-buffer buffer
        (pike-mode))
      (display-buffer buffer))))

;;;###autoload
(defun pike-find-1 ()
  "Find pike file 1."
  (interactive)
  (pike--find (pike--project-cache-file-path) 1))

;;;###autoload
(defun pike-find-2 ()
  "Find pike file 2."
  (interactive)
  (pike--find (pike--project-cache-file-path) 2))

;;;###autoload
(defun pike-find-3 ()
  "Find pike file 3."
  (interactive)
  (pike--find (pike--project-cache-file-path) 3))

;;;###autoload
(defun pike-find-4 ()
  "Find pike file 4."
  (interactive)
  (pike--find (pike--project-cache-file-path) 4))

;;;###autoload
(defun pike-find-global-1 ()
  "Find global pike file 1."
  (interactive)
  (pike--find (pike--global-cache-file-path) 1))

;;;###autoload
(defun pike-find-global-2 ()
  "Find global pike file 2."
  (interactive)
  (pike--find (pike--global-cache-file-path) 2))

;;;###autoload
(defun pike-find-global-3 ()
  "Find global pike file 3."
  (interactive)
  (pike--find (pike--global-cache-file-path) 3))

;;;###autoload
(defun pike-find-global-4 ()
  "Find global pike file 4."
  (interactive)
  (pike--find (pike--global-cache-file-path) 4))

;;;###autoload
(defun pike-next (&optional global)
  "Find the next file in the pike file ring.
Loops around if at the end.
If GLOBAL is non-nil then use the global pike cache."
  (interactive)
  (let* ((cache-file (pike--cache-file-path global))
         (num-lines (pike--num-entries cache-file))
         (line-number (pike--find-cache-number cache-file
                                               (pike--get-cache-key))))
    (if line-number
        (pike--find cache-file (1+ (mod line-number num-lines)))
      (unless (= num-lines 0)
        (pike--find cache-file 1)))))

;;;###autoload
(defun pike-previous (&optional global)
  "Find the previous file in the pike file ring.
Loops around if at the beginning.
If GLOBAL is non-nil then use the global pike cache."
  (interactive)
  (let* ((cache-file (pike--cache-file-path global))
         (num-lines (pike--num-entries cache-file))
         (line-number (pike--find-cache-number cache-file
                                               (pike--get-cache-key))))
    (if line-number
        (pike--find cache-file (1+ (mod (- line-number 2) num-lines)))
      (unless (= num-lines 0)
        (pike--find cache-file 1)))))

;;;###autoload
(defun pike-delete-current ()
  "Delete current visited buffer from pike cache."
  (interactive)
  (pike--create-cache-directory)
  (if-let ((cache-line (pike--find-cache-number (pike--cache-file-path) (pike--get-cache-key))))
      (with-current-buffer (pike--get-cache-buffer)
        (goto-char (point-min))
        (forward-line (1- cache-line))
        (delete-line)
        (save-buffer))))

(define-derived-mode pike-mode nil "Pike"
  "Mode for pike buffer."
  (display-line-numbers-mode t))

(defun pike--move-line (num)
  "Move the current cache line a number of lines up or down."
  (interactive)
  (let ((cache-line (pike--find-cache-number (pike--cache-file-path) (pike--get-cache-key))))
    (if cache-line
        (save-excursion
          (with-current-buffer (pike--get-cache-buffer)
            (goto-char (point-min))
            (forward-line (1- cache-line))
            (let ((line-text (delete-and-extract-region (line-beginning-position) (line-beginning-position 2))))
              (forward-line num)
              (insert line-text)
              (save-buffer))))
      (message "Buffer is not stored in pike."))))

;;;###autoload
(defun pike-promote-current ()
  "Promote the current line based on cache line number."
  (interactive)
  (pike--move-line -1))

;;;###autoload
(defun pike-demote-current ()
  "Demote the current line based on cache line number."
  (interactive)
  (pike--move-line 1))

(defun pike-tab-line-tabs-function ()
  "Create list of buffers of each entry in cache file.
Uses global cache file if project-specific one can't be found."
  (pike--create-cache-directory)
  (if-let* ((project-cache-file (pike--project-cache-file-path))
            (project-tabs (if (and project-cache-file (file-exists-p project-cache-file))
                              (pike--get-buffers project-cache-file)
                            (list)))
            (cur-buf (current-buffer)))
      (if (and pike-tab-line-add-non-pike-file
               (not (member cur-buf project-tabs)))
          (nconc project-tabs (list cur-buf))
        project-tabs)))

(provide 'pike)
;;; pike.el ends here
