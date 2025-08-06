;;; null-cpp.el --- summary -*- lexical-binding: t -*-

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

;; commentary

;;; Code:

(require 'null-keybinds)

(setq c-ts-mode-indent-offset 4)

(defun c-ts-mode--indent-styles (mode)
  "Indent rules supported by `c-ts-mode'.
MODE is either `c' or `cpp'."
  (let ((common
         `(((parent-is "translation_unit") column-0 0)
           ((query "(ERROR (ERROR)) @indent") column-0 0)
           ((node-is ")") parent 1)
           ((node-is "]") parent-bol 0)
           ((node-is "else") parent-bol 0)
           ((node-is "case") parent-bol 0)
           ((node-is "preproc_arg") no-indent)
           ;; `c-ts-common-looking-at-star' has to come before
           ;; `c-ts-common-comment-2nd-line-matcher'.
           ((and (parent-is "comment") c-ts-common-looking-at-star)
            c-ts-common-comment-start-after-first-star -1)
           (c-ts-common-comment-2nd-line-matcher
            c-ts-common-comment-2nd-line-anchor
            1)
           ((parent-is "comment") prev-adaptive-prefix 0)

           ;; Labels.
           ((node-is "labeled_statement") standalone-parent 0)
           ((parent-is "labeled_statement")
            c-ts-mode--standalone-grandparent c-ts-mode-indent-offset)

           ;; Preproc directives
           ((node-is "preproc") column-0 0)
           ((node-is "#endif") column-0 0)
           ((match "preproc_call" "compound_statement") column-0 0)

           ;; Top-level things under a preproc directive.  Note that
           ;; "preproc" matches more than one type: it matches
           ;; preproc_if, preproc_elif, etc.
           ((n-p-gp nil "preproc" "translation_unit") column-0 0)
           ;; Indent rule for an empty line after a preproc directive.
           ((and no-node (parent-is ,(rx (or "\n" "preproc"))))
            c-ts-mode--standalone-parent-skip-preproc c-ts-mode--preproc-offset)
           ;; Statement under a preproc directive, the first statement
           ;; indents against parent, the rest statements indent to
           ;; their prev-sibling.
           ((match nil ,(rx "preproc_" (or "if" "elif")) nil 3 3)
            c-ts-mode--standalone-parent-skip-preproc c-ts-mode-indent-offset)
           ((match nil "preproc_ifdef" nil 2 2)
            c-ts-mode--standalone-parent-skip-preproc c-ts-mode-indent-offset)
           ((match nil "preproc_else" nil 1 1)
            c-ts-mode--standalone-parent-skip-preproc c-ts-mode-indent-offset)
           ((parent-is "preproc") c-ts-mode--anchor-prev-sibling 0)

           ((parent-is "function_definition") parent-bol 0)
           ((parent-is "conditional_expression") first-sibling 0)
           ((parent-is "assignment_expression") parent-bol c-ts-mode-indent-offset)
           ((parent-is "concatenated_string") first-sibling 0)
           ((parent-is "comma_expression") first-sibling 0)
           ((parent-is "init_declarator") parent-bol c-ts-mode-indent-offset)
           ((parent-is "parenthesized_expression") first-sibling 1)
           ((parent-is "argument_list") first-sibling 1)
           ((parent-is "parameter_list") first-sibling 1)
           ((parent-is "binary_expression") parent 0)
           ((query "(for_statement initializer: (_) @indent)") parent-bol 5)
           ((query "(for_statement condition: (_) @indent)") parent-bol 5)
           ((query "(for_statement update: (_) @indent)") parent-bol 5)
           ((query "(call_expression arguments: (_) @indent)") parent c-ts-mode-indent-offset)
           ((parent-is "call_expression") parent 0)
           ;; Closing bracket.  This should be before initializer_list
           ;; (and probably others) rule because that rule (and other
           ;; similar rules) will match the closing bracket.  (Bug#61398)
           ((node-is "}") standalone-parent 0)
           ,@(when (eq mode 'cpp)
               '(((node-is "access_specifier") parent-bol 0)
                 ;; Indent the body of namespace definitions.
                 ((parent-is "declaration_list") parent-bol 0)))


           ;; int[5] a = { 0, 0, 0, 0 };
           ((match nil "initializer_list" nil 1 1) parent-bol c-ts-mode-indent-offset)
           ((parent-is "initializer_list") c-ts-mode--anchor-prev-sibling 0)
           ;; Statement in enum.
           ((match nil "enumerator_list" nil 1 1) standalone-parent c-ts-mode-indent-offset)
           ((parent-is "enumerator_list") c-ts-mode--anchor-prev-sibling 0)
           ;; Statement in struct and union.
           ((match nil "field_declaration_list" nil 1 1) standalone-parent c-ts-mode-indent-offset)
           ((parent-is "field_declaration_list") c-ts-mode--anchor-prev-sibling 0)

           ;; Statement in {} blocks.
           ((or (match nil "compound_statement" nil 1 1)
                (match null "compound_statement"))
            standalone-parent c-ts-mode-indent-offset)
           ((parent-is "compound_statement") c-ts-mode--anchor-prev-sibling 0)
           ;; Opening bracket.
           ((node-is "compound_statement") standalone-parent c-ts-mode-indent-offset)
           ;; Bug#61291.
           ((match "expression_statement" nil "body") standalone-parent c-ts-mode-indent-offset)
           ;; These rules are for cases where the body is bracketless.
           ;; Tested by the "Bracketless Simple Statement" test.
           ((parent-is "if_statement") standalone-parent c-ts-mode-indent-offset)
           ((parent-is "for_statement") standalone-parent c-ts-mode-indent-offset)
           ((parent-is "while_statement") standalone-parent c-ts-mode-indent-offset)
           ((parent-is "do_statement") standalone-parent c-ts-mode-indent-offset)

           ((parent-is "case_statement") standalone-parent c-ts-mode-indent-offset)

           ,@(when (eq mode 'cpp)
               `(((node-is "field_initializer_list") parent-bol ,(* c-ts-mode-indent-offset 2)))))))
    `((gnu
       ;; Prepend rules to set highest priority
       ((match "while" "do_statement") parent 0)
       (c-ts-mode--top-level-label-matcher column-0 1)
       ,@common)
      (k&r ,@common)
      (linux
       ;; Reference:
       ;; https://www.kernel.org/doc/html/latest/process/coding-style.html,
       ;; and script/Lindent in Linux kernel repository.
       ((node-is "labeled_statement") column-0 0)
       ,@common)
      (bsd
       ((node-is "}") parent-bol 0)
       ((node-is "labeled_statement") parent-bol c-ts-mode-indent-offset)
       ((parent-is "labeled_statement") parent-bol c-ts-mode-indent-offset)
       ((parent-is "compound_statement") parent-bol c-ts-mode-indent-offset)
       ((parent-is "if_statement") parent-bol 0)
       ((parent-is "for_statement") parent-bol 0)
       ((parent-is "while_statement") parent-bol 0)
       ((parent-is "switch_statement") parent-bol 0)
       ((parent-is "case_statement") parent-bol 0)
       ((parent-is "do_statement") parent-bol 0)
       ,@common))))

(setq c-ts-mode-indent-style 'gnu)

;; Mode
(use-package cc-mode
  :custom
  (ff-search-directories
   '("./base"
     "../"
     "." "../src"
     "../src/*/"
     "../include" "../include/*/"
     "../../src" "../../src/*/"
     "../../include" "../../include/*/"
     "/usr/include" "$PROJECT/*/include"))
  :config
  (add-hook 'c++-ts-mode-hook
          (lambda ()
            (set-fill-column 80))))

(use-package clang-format
  :custom
  (clang-format-style "file"))

;; Cuda
(use-package cuda-mode
  :config
  (define-derived-mode cuda-mode c++-mode "CUDA"
    "CUDA mode."
    (setq c-basic-offset 4))
  (setq auto-mode-alist
        (cons '("\\.cu$" . c++-mode) auto-mode-alist)))

(use-package glsl-mode
  :config
  (define-derived-mode glsl-mode c-ts-mode "GLSL"
    "GLSL mode."
    (setq c-basic-offset 4)))

(use-package bazel
  :custom
  (bazel-command "./bazel.py")
  :config
  (setq auto-mode-alist
        (cons '("\\.bazel" . bazel-mode) auto-mode-alist)))

;; Keybinds
(null-keybinds-major-key-def
  :states '(normal visual)
  :keymaps '(c-ts-base-mode-map
             c++-ts-base-mode-map
             cuda-mode-map
             glsl-mode-map)
  "f" '(ff-find-other-file :wk "find other file")
  "b" '(:ignore t :wk "buffer")
  "b f" '(clang-format-buffer :wk format buffer))

(provide 'null-cpp)

;;; null-cpp.el ends here
