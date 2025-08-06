;;; null-lsp.el --- summary -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(require 'null-keybinds)

(use-package eldoc
  :custom
  (eldoc-idle-delay 0.2)
  (eldoc-echo-area-use-multiline-p nil)
  :config
  (with-eval-after-load 'evil
    (evil-define-key '(normal insert)
      'eglot-mode-map (kbd "M-H") #'eldoc-doc-buffer)))

(use-package eldoc-box
  :after eldoc
  :custom
  (eldoc-box-clear-with-C-g t)
  :config
  (evil-define-key '(normal insert)
    'eglot-mode-map (kbd "M-h") #'eldoc-box-help-at-point))

(use-package eglot
  :after cape
  :hook
  (c-mode . eglot-ensure)
  (c-ts-base-mode . eglot-ensure)
  (c++-ts-base-mode . eglot-ensure)
  (python-base-mode . eglot-ensure)
  :config
  ;; Modes
  (add-to-list 'eglot-server-programs '((c++-ts-mode c++-ts-base-mode cuda-mode c++-mode c-mode) "clangd"))

  ;; Add capfs to eglot
  (defun null/eglot-capf ()
    "Create capf for eglot+cape capfs."
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'eglot-completion-at-point
                       #'tempel-complete
                       #'cape-file))))

  (add-hook 'eglot-managed-mode-hook #'null/eglot-capf)
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-buster))

(use-package eglot-booster
  :after eglot
  :vc (:url "https://github.com/jdtsmith/eglot-booster")
  :config
  (eglot-booster-mode))

(use-package flymake
  :after eglot eldoc
  :custom
  (flymake-fringe-indicator-position 'right-fringe))

(null-keybinds-leader-key-def
  :keymaps 'eglot-mode-map
  "l a" '(eglot-code-actions :wk "code action")
  "l R" '(eglot-rename :wk "rename")
  "l d" '(xref-find-definitions :wk "find definitions")
  "l r" '(xref-find-references :wk "find references")
  "l h" '(eldoc :wk "help")
  "l r" '(eglot-find-declaration :wk "find declaration")
  "l i" '(eglot-find-implementation :wk "find implementation")
  "l e" '(consult-flymake :wk "consult errors")
  "l b" '(:ignore t :wk "buffer")
  "l b f" '(eglot-format-buffer :wk "format buffer")
  "l t" '(eglot-find-typeDefinition :wk "find typeDefinition")
  "l H" '(eglot-inlay-hints-mode :wk "toggle inlay hints"))

(provide 'null-lsp)
;;; null-lsp.el ends here
