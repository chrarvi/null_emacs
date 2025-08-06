;;; null-completion.el -*- lexical-binding: t; -*-

;;; Code:
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package corfu
  :after orderless
  :general (:keymaps 'corfu-mode-map
                     "M-m" #'corfu-move-to-minibuffer)
  :custom
  (corfu-on-exact-match nil)
  (corfu-cycle t)
  (corfu-auto-delay 0.05)
  (corfu-auto-prefix 1)
  (corfu-auto t)
  (corfu-quit-no-match 'separator)
  (corfu-popupinfo-delay 0.25)
  :config
  (defun corfu-move-to-minibuffer ()
    (interactive)
    (when completion-in-region--data
      (let ((completion-extra-properties corfu--extra)
            completion-cycle-threshold completion-cycling)
        (apply #'consult-completion-in-region completion-in-region--data))))
  (add-to-list 'corfu-continue-commands #'corfu-move-to-minibuffer)

  (corfu-echo-mode +1)
  (corfu-popupinfo-mode +1)
  :init
  (global-corfu-mode))

(use-package cape
  :bind (("C-' p" . completion-at-point) ;; capf
         ("C-' t" . complete-tag)        ;; etags
         ("C-' d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-' h" . cape-history)
         ("C-' f" . cape-file)
         ("C-' k" . cape-keyword)
         ("C-' s" . cape-elisp-symbol)
         ("C-' e" . cape-elisp-block)
         ("C-' a" . cape-abbrev)
         ("C-' l" . cape-line)
         ("C-' w" . cape-dict)
         ("C-' :" . cape-emoji)
         ("C-' \\" . cape-tex)
         ("C-' _" . cape-tex)
         ("C-' ^" . cape-tex)
         ("C-' &" . cape-sgml)
         ("C-' r" . cape-rfc1345))
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(use-package vertico
  :custom
  (vertico-cycle t)
  (vertico-count 13)
  (vertico-resize nil)
  :config
  (vertico-mode))

(defun just-one-face (fn &rest args)
  (let ((orderless-match-faces [completions-common-part]))
    (apply fn args)))

(use-package orderless
  :custom
  (completion-styles '(orderless partial-completion basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((eglot (styles orderless))
                                   (eglot-capf (styles orderless))))
  (orderless-component-separator "[ &]"))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (consult-ripgrep-args "rg --hidden --null --line-buffered --color=never --max-columns=1000 --path-separator /   --smart-case --no-heading --with-filename --line-number --search-zip")
  :bind (:map minibuffer-local-map
              ("M-s". consult-history)
              ("M-r". consult-history))
  :config
  ; fd support
  (defun consult--fd-builder (input)
    (let ((fd-command
           (if (eq 0 (process-file-shell-command "fdfind"))
               "fdfind"
             "fd")))
      (pcase-let* ((`(,arg . ,opts) (consult--command-split input))
                   (`(,re . ,hl) (funcall consult--regexp-compiler
                                          arg 'extended t)))
        (when re
          (cons (append
                 (list fd-command
                       "--color=never" "--full-path"
                       (consult--join-regexps re 'extended))
                 opts)
                hl)))))

  (defun consult-fd (&optional dir initial)
    (interactive "P")
    (pcase-let* ((`(,prompt ,paths ,dir) (consult--directory-prompt "Fd" dir))
                 (default-directory dir))
      (find-file (consult--find prompt #'consult--fd-builder initial))))

  ; Add selected text to initial query on search
  (consult-customize consult-line
                     consult-ripgrep
                     :preview-key '(:debounce 0.0 any)
                     :add-history (seq-some #'thing-at-point '(region symbol))))

;; Embark
(use-package embark
  :after vertico
  :general (:keymaps 'vertico-map
            "C-." 'embark-act
            "C-," 'embark-export
            "M-." 'embark-dwim
            "C-h B" 'embark-bindings))

(use-package embark-consult
  :after embark consult
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Prescient
(use-package prescient
  :config
  (prescient-persist-mode +1))

;; (use-package corfu-prescient
;;   :after (corfu prescient)
;;   :config
;;   (corfu-prescient-mode +1))

(use-package vertico-prescient
  :after (vertico prescient)
  :config
  (vertico-prescient-mode +1))

;; For completion
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
(setq completion-cycle-threshold 3)
(defun crm-indicator (args)
  (cons (concat "[CRM] " (car args)) (cdr args)))
(advice-add #'completing-read-multiple :filter-args #'crm-indicator)
(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(setq enable-recursive-minibuffers t)

(provide 'null-completion)
