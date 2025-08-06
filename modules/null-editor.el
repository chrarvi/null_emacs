;;; null-editor.el -*- lexical-binding: t; -*-

(require 'null-keybinds)
(require 'null-defaults)

(use-package rainbow-delimiters
  :ghook 'prog-mode-hook)

(use-package rainbow-mode
  :hook
  (prog-mode . rainbow-mode)
  (conf-mode . rainbow-mode))

(use-package smartparens)

(use-package evil-snipe
  :after evil
  :hook (magit-mode . turn-off-evil-snipe-override-mode)
  :config
  (evil-snipe-mode +1)
  (evil-snipe-override-mode +1))

(use-package evil-quickscope
  :config
  (global-evil-quickscope-mode +1))

(use-package evil-fringe-mark
  :config
  (setq-default evil-fringe-mark-side 'left-fringe)
  (global-evil-fringe-mark-mode 1))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

;; Align stuff
(use-package evil-lion
  :config
  (evil-lion-mode))

;; Extra text objects
(use-package evil-args
  :config
  ;; bind evil-args text objects
  (define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
  (define-key evil-outer-text-objects-map "a" 'evil-outer-arg)

  ;; bind evil-forward/backward-args
  (define-key evil-normal-state-map "L" 'evil-forward-arg)
  (define-key evil-normal-state-map "H" 'evil-backward-arg)
  (define-key evil-motion-state-map "L" 'evil-forward-arg)
  (define-key evil-motion-state-map "H" 'evil-backward-arg)

  ;; bind evil-jump-out-args
  (define-key evil-normal-state-map "K" 'evil-jump-out-args))

;; Indent text object
(use-package evil-indent-plus
  :config
  (evil-indent-plus-default-bindings))

;; Nerd commenter
(use-package evil-nerd-commenter
  :config
  (general-define-key
   :states 'normal
   "g c" '(evilnc-comment-operator :wk "Comment operator")))

(use-package evil-multiedit
  :after evil
  :config
  (evil-multiedit-default-keybinds))

(use-package evil-mc
  :after evil
  :config
  (global-evil-mc-mode +1))

(use-package drag-stuff
  :config
  (drag-stuff-global-mode +1)
  (drag-stuff-define-keys))

(use-package avy
  :custom
  (avy-timeout-seconds 0.3)
  (avy-background t)
  (avy-single-candidate-jump nil)
  :config
  (general-define-key
   :states 'normal
   "g s" 'evil-avy-goto-char-timer)

  (defun avy-action-kill-whole-line (pt)
    (save-excursion
      (goto-char pt)
      (kill-whole-line))
    (select-window
     (cdr
      (ring-ref avy-ring 0)))
    t)

  (defun avy-action-copy-whole-line (pt)
    (save-excursion
      (goto-char pt)
      (cl-destructuring-bind (start . end)
          (bounds-of-thing-at-point 'line)
        (copy-region-as-kill start end)))
    (select-window
     (cdr
      (ring-ref avy-ring 0)))
    t)

  (defun avy-action-yank-whole-line (pt)
    (avy-action-copy-whole-line pt)
    (save-excursion (yank))
    t)

  (defun avy-action-teleport-whole-line (pt)
    (avy-action-kill-whole-line pt)
    (save-excursion (yank)) t)

  (defun avy-action-mark-to-char (pt)
    (activate-mark)
    (goto-char pt))

  (defun avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  (defun avy-action-exchange (pt)
    "Exchange sexp at PT with the one at point."
    (set-mark pt)
    (transpose-sexps 0))

  (setq avy-keys '(?q ?e ?w ?u ?o ?a ?s ?f ?g ?h ?j ?k ?l ?' ?c ?v ?b ?n ?, ?/))

  (setf (alist-get ?p avy-dispatch-alist) 'avy-action-yank
        (alist-get ?P avy-dispatch-alist) 'avy-action-yank-whole-line
        (alist-get ?d avy-dispatch-alist) 'avy-action-kill-stay
        (alist-get ?D avy-dispatch-alist) 'avy-action-kill-whole-line
        (alist-get ?y avy-dispatch-alist) 'avy-action-copy
        (alist-get ?Y avy-dispatch-alist) 'avy-action-copy-whole-line
        (alist-get ?t avy-dispatch-alist) 'avy-action-teleport
        (alist-get ?T avy-dispatch-alist) 'avy-action-teleport-whole-line
        (alist-get ?x avy-dispatch-alist) 'avy-action-exchange
        (alist-get ?  avy-dispatch-alist) 'avy-action-mark-to-char
        (alist-get ?. avy-dispatch-alist) 'avy-action-embark))

(use-package iedit)

(use-package undo-tree
  :config
  (global-undo-tree-mode))

(use-package dogears)

(null-keybinds-leader-key-def
  :states 'normal
  "s m" '(evil-collection-consult-mark :wk "consult marks")
  "o u" '(undo-tree-visualize :wk "show undo-tree")

  "j a" 'dogears-remember
  "j g" 'dogears-go
  "j p" 'dogears-back
  "j n" 'dogears-forward
  "j o" 'dogears-list)


(provide 'null-editor)
