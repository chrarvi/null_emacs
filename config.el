;;; Code:

;; core
(require 'null-defaults)
(require 'null-keybinds)
(require 'null-font)
(require 'null-ui)
(require 'null-startup)

;; buffer, files, windows
(require 'null-files)
(require 'null-project)
(require 'null-windows)
(require 'null-pike)

;; editor
(require 'null-completion)
(require 'null-editor)
(require 'null-treesit)
(require 'null-snippets-tempel)
(require 'null-lsp)

;; org
(require 'null-latex)
(require 'null-org)
(require 'null-org-agenda)
(require 'null-org-knowledge)
(require 'null-org-latex)
(require 'null-org-html)
(require 'null-denote)

;; languages
(require 'null-cpp)
(require 'null-elisp)
(require 'null-python)
(require 'null-rust)
(require 'null-sql)
(require 'null-zig)

(require 'null-org-babel)
;; (require 'null-org-publish)

;; other
(require 'null-docker)
(require 'null-apps)
(require 'null-rss)
(require 'null-llm)

;; Personal information
(setq user-full-name "Christoffer Arvidsson"
      user-mail-address "christoffer@arvidson.nu")

;; Theme
(setq null-theme 'ef-dream)

(defun null/init-work-config ()
  "Do work specific initialization."
  (message "using work configuration.")
  (require 'secrets)

  (use-package ox-slack
    :vc (:url "https://github.com/titaniumbones/ox-slack"))

  (setq null-font-preset 'laptop
        null-font-big-preset 'laptop-big))

(defun null/init-shuttle-config ()
  "Do work specific initialization."
  (message "using shuttle configuration.")

  (setq null-font-preset 'laptop
        null-font-big-preset 'laptop-big))

(defun null/init-home-config ()
  "Do home specific initialization."
  (message "using home configuration.")
  (setq null-font-preset 'desktop
        null-font-big-preset 'big)

  (with-eval-after-load 'gptel
    (setq-default
     gptel-model "llama3.2"
     gptel-backend (gptel-make-ollama "Ollama"
                     :host "localhost:11434"
                     :stream t
                     :models '("llama3.2")))))


(pcase (system-name)
  ("u5cg4373yhk" (null/init-work-config))
  ("station" (null/init-home-config))
  ("shuttle" (null/init-shuttle-config))
  (_ (message "No matching system configuration")))

;; Reload the font
(fontaine-set-preset null-font-preset)

(load-theme null-theme t)

(provide 'config)
;;; config.el ends here
