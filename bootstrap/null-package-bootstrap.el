(require 'package)

(setq package-archives '(("gnu-devel" . "https://elpa.gnu.org/devel/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(defun null-package-initialize ()
  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents)))

(require 'use-package-ensure)
(setq use-package-always-pin  "melpa"
      use-package-always-ensure t
      use-package-compute-statistics t
      use-package-verbose t
      use-package-always-defer nil)

(provide 'null-package/package)
