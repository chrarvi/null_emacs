;; Example Elpaca configuration -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :ensure use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume : t unless otherwise specified.
  (setq elpaca-use-package-by-default t))


;; Block until current queue processed.
(elpaca-wait)

;; (use-package org
;;   :defer t
;;   ;; :ensure `(org
;;   ;;           :remotes ("tecosaur"
;;   ;;                     :repo "https://git.tecosaur.net/tec/org-mode.git"
;;   ;;                     :branch "dev")
;;   ;;           :files (:defaults "etc")
;;   ;;           :build t
;;   ;;           :pre-build
;;   ;;           (with-temp-file "org-version.el"
;;   ;;            (require 'lisp-mnt)
;;   ;;            (let ((version
;;   ;;                   (with-temp-buffer
;;   ;;                     (insert-file-contents "lisp/org.el")
;;   ;;                     (lm-header "version")))
;;   ;;                  (git-version
;;   ;;                   (string-trim
;;   ;;                    (with-temp-buffer
;;   ;;                      (call-process "git" nil t nil "rev-parse" "--short" "HEAD")
;;   ;;                      (buffer-string)))))
;;   ;;             (insert
;;   ;;              (format "(defun org-release () \"The release version of Org.\" %S)\n" version)
;;   ;;              (format "(defun org-git-version () \"The truncate git commit hash of Org mode.\" %S)\n" git-version)
;;   ;;              "(provide 'org-version)\n")))
;;   )

(provide 'null-package/elpaca)

;; Local Variables:
;; no-byte-compile: t
;; no-native-compile: t
;; no-update-autoloads: t
;; End:
