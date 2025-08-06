;;; Code:

(use-package rg
  :config
  (rg-enable-default-bindings))

;; Dumb jump for jumping to symbol
(use-package dumb-jump
  :hook (xref-backend-functions . #'dumb-jump-xref-activate)
  :custom
  (dumb-jump-prefer-searcher 'rg))

(use-package compile
  :config
  ;; Handle ansi characters in compilation buffer
  ;; https://emacs.stackexchange.com/questions/8135/why-does-compilation-buffer-show-control-characters
  (require 'ansi-color)
  (defun my/ansi-colorize-buffer ()
    (let ((buffer-read-only nil))
      (ansi-color-apply-on-region (point-min) (point-max))))
  (add-hook 'compilation-filter-hook 'my/ansi-colorize-buffer))

(use-package project
  :config
  ;; Handle ansi characters in compilation buffer
  ;; https://emacs.stackexchange.com/questions/8135/why-does-compilation-buffer-show-control-characters
  (require 'ansi-color)
  (defun my/ansi-colorize-buffer ()
    (let ((buffer-read-only nil))
      (ansi-color-apply-on-region (point-min) (point-max))))
  (add-hook 'compilation-filter-hook 'my/ansi-colorize-buffer)

  (defun null-project-override (dir)
    (let ((override (locate-dominating-file dir ".project.el")))
      (if override
          (cons 'transient override)
        nil)))

  (add-to-list 'project-find-functions #'null-project-override)

  ;; Magit
  (define-key project-prefix-map "m" #'magit-project-status)
  (add-to-list 'project-switch-commands '(magit-project-status "Magit") t)
  ;; consult ripgrep
  (define-key project-prefix-map "/" #'consult-ripgrep)
  (add-to-list 'project-switch-commands '(consult-ripgrep "Search") t)
  ;; Dired
  (define-key project-prefix-map "." #'project-dired)
  (add-to-list 'project-switch-commands '(project-dired "Dired") t))

(use-package consult-project-extra
  :after consult)

;;; Version control

(use-package ediff
  :custom
  (ediff-keep-variants nil)
  (ediff-split-window-function 'split-window-horizontally)
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  (ediff-highlight-all-diffs t))

(use-package transient)

(use-package magit
  :custom
  (magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1)
  (magit-section-disable-line-numbers nil)
  :config
  (setenv "SSH_AUTH_SOCK" "/run/user/1400946984/ssh-agent.socket")

  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-branch-description
                          nil t)
  (magit-add-section-hook 'magit-refs-sections-hook
                          'magit-insert-branch-description))

(use-package hydra)

(use-package smerge-mode
  :after hydra
  :config
  (defhydra unpackaged/smerge-hydra
    (:color pink :hint nil :post (smerge-auto-leave))
    "
^Move^       ^Keep^               ^Diff^                 ^Other^
^^-----------^^-------------------^^---------------------^^-------
_n_ext       _b_ase               _<_: upper/base        _C_ombine
_p_rev       _u_pper              _=_: upper/lower       _r_esolve
^^           _l_ower              _>_: base/lower        _k_ill current
^^           _a_ll                _R_efine
^^           _RET_: current       _E_diff
"
    ("n" smerge-next)
    ("p" smerge-prev)
    ("b" smerge-keep-base)
    ("u" smerge-keep-upper)
    ("l" smerge-keep-lower)
    ("a" smerge-keep-all)
    ("RET" smerge-keep-current)
    ("\C-m" smerge-keep-current)
    ("<" smerge-diff-base-upper)
    ("=" smerge-diff-upper-lower)
    (">" smerge-diff-base-lower)
    ("R" smerge-refine)
    ("E" smerge-ediff)
    ("C" smerge-combine-with-next)
    ("r" smerge-resolve)
    ("k" smerge-kill-current)
    ("ZZ" (lambda ()
            (interactive)
            (save-buffer)
            (bury-buffer))
     "Save and bury buffer" :color blue)
    ("q" nil "cancel" :color blue))
  :hook (magit-diff-visit-file . (lambda ()
                                   (when smerge-mode
                                     (unpackaged/smerge-hydra/body)))))

(use-package git-gutter-fringe
  :config
  ;; places the git gutter outside the margins.
  (setq-default fringes-outside-margins t)
  ;; thin fringe bitmaps
  (define-fringe-bitmap 'git-gutter-fr:added [224]
    nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224]
    nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240]
    nil nil 'bottom)
  (global-git-gutter-mode +1))

(use-package git-timemachine
  :after magit
  :config
  (evil-make-overriding-map git-timemachine-mode-map 'normal)
  ;; force update evil keymaps after git-timemachine-mode loaded
  (add-hook 'git-timemachine-mode-hook #'evil-normalize-keymaps))

;; Use ripgrep over grep
(use-package grep
  :config
  (grep-apply-setting
   'grep-find-command
   '("rg -n -H --hidden --no-heading -e '' $(git rev-parse --show-toplevel || pwd)" . 27)))

(setq compilation-scroll-output t)

;; Ansi colors in compilation mode
(use-package fancy-compilation
  :commands (fancy-compilation-mode)
  :config
  (fancy-compilation-mode +1))

(null-keybinds-leader-key-def
  :states '(normal visual)
  "p c" '(project-compile :wk "Compile project")
  "p C" '(kill-compilation :wk "Kill compilation")
  "p f" '(project-find-file :wk "Find file in project")
  "p F" '(consult-project-extra-find :wk "Find file in project")
  "p p" '(project-switch-project :wk "Switch project")
  "p b" '(consult-project-buffer :wk "Switch to project buffer")
  "p ." '(project-dired :wk "Open dired in projcet")
  "/" '(consult-ripgrep :wk "Search project")

  "g B" '(magit-blame :wk "Magit blame")
  "g s" '(magit :wk "Magit status")
  "g c" '(magit-clone :wk "Magit clone")
  "g t" '(git-timemachine :wk "Git timemachine")
  "g m" '(null/smerge-body :wk "Smerge hydra")
  "g i" '(magit-init :wk "Magit init"))


(provide 'null-project)
