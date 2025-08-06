;;; null-keybinds.el -*- lexical-binding: t; -*-

;;; Code:

;; General leader

(defgroup null-keybinds '()
  "Keybind related configuration."
  :tag "Null keybinds")

(defcustom null-keybinds-leader-key "SPC"
  "The leader key used by general."
  :group 'null-keybinds
  :type 'string)

(defcustom null-keybinds-major-key "SPC m"
  "The major mode key used by general."
  :group 'null-keybinds
  :type 'string)

(defcustom null-keybinds-ctrl-c-key "C-c"
  "The ctrl-c key used by general."
  :group 'null-keybinds
  :type 'string)

;; General
(use-package general
  :config
  (general-override-mode)
  (general-evil-setup t)

  (general-create-definer null-keybinds-leader-key-def
    :states '(normal motion visual emacs)
    :keymaps 'override
    :prefix null-keybinds-leader-key)

  (general-create-definer null-keybinds-major-key-def
    :states '(normal visual emacs)
    :prefix null-keybinds-major-key)

  (general-create-definer null-keybinds-ctrl-c-key-def
    :prefix null-keybinds-ctrl-c-key)

  (defun my-keyboard-escape-quit--around (orig-fun &rest args)
    (let (orig-one-window-p)
      (fset 'orig-one-window-p (symbol-function 'one-window-p))
      (fset 'one-window-p (lambda (&optional nomini all-frames) t))
      (unwind-protect
          (apply orig-fun args)
        (fset 'one-window-p (symbol-function 'orig-one-window-p)))))

  (advice-add 'keyboard-escape-quit :around #'my-keyboard-escape-quit--around))

;; Evil mode
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump t
        evil-want-Y-yank-to-eol t
        evil-jumps-cross-buffers t
        evil-kill-on-visual-paste nil
        evil-undo-system 'undo-tree
        evil-symbol-word-search t
        evil-respect-visual-line-mode t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after (evil magit)
  :init
  :custom
  (evil-collection-outline-bind-tab-p nil)
  :config
  (delete 'lispy evil-collection-mode-list)
  (delete 'org-present evil-collection-mode-list)
  (evil-collection-init)

  ;; Unbind escape in magit mode
  (evil-define-key* 'normal magit-status-mode-map [escape] nil)

  ;; Rebind unimpaired next/prev error to emacs built-in instead of flymake's
  (evil-collection-define-key 'normal 'evil-collection-unimpaired-mode-map
    "[q" 'previous-error
    "]q" 'next-error
    "[Q" 'first-error
    ;; TODO: implement "]Q" last error somehow
    ))

;; Which key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; Non-package keys
(null-keybinds-leader-key-def
  :states 'normal
  "" '(nil :wk "Leader")
  "'" '(:ignore t :wk "harpoon")
  "b" '(:ignore t :wk "buffer")
  "f" '(:ignore t :wk "file")
  "g" '(:ignore t :wk "git")
  "h" '(:ignore t :wk "help")
  "i" '(:ignore t :wk "insert")
  "l" '(:ignore t :wk "lsp")
  "o" '(:ignore t :wk "open")
  "p" '(:ignore t :wk "project")
  "q" '(:ignore t :wk "quit")
  "s" '(:ignore t :wk "search")
  "t" '(:ignore t :wk "toggle")
  "w" '(:ignore t :wk "window")
  "z" '(:ignore t :wk "util")
  "u" 'universal-argument
  "RET" '(consult-bookmark :wk "Jump to bookmark")
  "q r" '(restart-emacs :wk "Restart emacs")
  "q q" '(quit-window :wk "Quit emacs"))

(provide 'null-keybinds)
