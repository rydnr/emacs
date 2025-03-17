;;; 13emacs-jde.el

;; Copyright (C) 2007 ACM-SL.org
;;
;; Author: chous@acm-sl.org
;; Keywords: initialization, customization
;; Version: $Revision: $
;; X-URL: http://www.acm-sl.org/emacs

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This is part of my Emacs settings and/or initialization
;; mechanisms. They're based on dotemacs.de' *safe-load* function
;; to avoid failing Emacs starts.

;;; Code:
;;------------------------------------------------------------

;; jsp-html-helper-mode.el
(add-hook 'html-helper-load-hook
          (function (lambda ()
                      (load "jsp-html-helper-mode.el"))))

;;------------------------------------------------------------
;; ant compilation support for error messages
(require-or-install 'compile)

;; (setq
;;   new-jde-compilation-error-regexps-alist-alist
;;   (list
;;     '(javac-jde
;;      "^\\s-*\\[[^]]*\\]\\s-*\\(.+\\):\\([0-9]+\\):" 1 2 nil (1))
;;     '(jikes-jde
;;      "^\\s-*\\[[^]]*\\]\\s-*\\(.+\\):\\([0-9]+\\):\\([0-9]+\\):[0-9]+:[0-9]+:" 1 2 3 (1))))
;;(setq
;;  new-jde-compilation-error-regexps
;;  (list
   ;; works for javac
;;   '("^\\s-*\\[[^]]*\\]\\s-*\\(.+\\):\\([0-9]+\\):" 1 2)
   ;; works for jikes
;;   '("^\\s-*\\[[^]]*\\]\\s-*\\(.+\\):\\([0-9]+\\):\\([0-9]+\\):[0-9]+:[0-9]+:" 1 2 3))
;;  )

;; Use only spaces, not tabs.
(setq indent-tabs-mode nil)

;;; don't insert tabs when indenting blocks
;;; indent Java 4 spaces
 
;;(add-hook 'java-mode-hook
;;          '(lambda()
;;             (c-set-style "stroustrup")
;;             (setq c-basic-offset 4)
;;             (flymake-mode)
;;             (jde-mode)
;;            (malabar-mode)
;;             (cond (window-system
;;                    (require 'andersl-java-font-lock)
;;                    (turn-on-font-lock)))
;;             ))

(setq font-lock-maximum-decoration t)

(require-or-install 'facemenu)
(require-or-install 'font-lock)
;;(require 'jde-flymake)

;;(require-or-install 'jde)

;; (if (not (rassoc 'jde-mode auto-mode-alist))
;;     (setq auto-mode-alist
;;           (append
;;            '(("\\.java$'" . jde-mode))
;;            auto-mode-alist)))

;;; JDEE/speedbar settings to make it behave better for AspectJ.  You might
;;; want to do this via a prj.el file (see sample.prj) if you program in
;;; vanilla Java as well.  The sample.prj has settings for spacewar, a more
;;; complicated project.

(require-or-install 'jserial)
(require-or-install 'semantic-fw)
(require-or-install 'semantic-idle)
(require-or-install 'semantic-wisent)
(require-or-install 'semantic-overview)
(add-hook 'semantic-init-hooks
  ( lambda ()
    (imenu-add-to-menubar "TOKENS")))

;; pmd
(require-or-install 'pmd)
(autoload 'pmd-current-buffer "pmd" "PMD Mode" t)
(autoload 'pmd-current-dir "pmd" "PMD Mode" t)

(require-or-install 'beanshell-startup)

(require-or-install 'vvb-mode)
(autoload 'vvb-mode "vvb" "VVB mode." t)
(setq-default vvb-column 80
              vvb-sticky-p nil
              vvb-permanent-p t)
; set autofill and vvb when entering text mode
(add-hook 'text-mode-hook
 '(lambda () (auto-fill-mode 1) (vvb-mode)))

;;(setq auto-mode-alist
;;   (append
;;     '(("\\.java$" . vvb-mode))
;;     auto-mode-alist))
(when (file-exists-p "~/emacs/.emacs-bsh.el")
  (load "~/emacs/.emacs-bsh.el"))

;(c-add-style "acmsl" values t)

;; (setq  c-echo-syntactic-information-p t)
;; (setq  c-style-variables-are-local-p nil)

;;      (defconst my-c-style
;;        '((c-tab-always-indent        . t)
;;          (c-comment-only-line-offset . 4)
;;          (c-hanging-braces-alist     . ((substatement-open after)
;;                                         (brace-list-open)))
;;          (c-hanging-colons-alist     . ((member-init-intro before)
;;                                         (inher-intro)
;;                                         (case-label after)
;;                                         (label after)
;;                                         (access-label after)))
;;          (c-cleanup-list             . (scope-operator
;;                                         empty-defun-braces
;;                                         defun-close-semi))
;;          (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
;;                                         (substatement-open . 0)
;;                                         (case-label        . 4)
;;                                         (block-open        . 0)
;;                                         (knr-argdecl-intro . -)))
;;          (c-echo-syntactic-information-p . t))
;;        "My C Programming Style")
     
;;      ;; offset customizations not in my-c-style
;;      (setq c-offsets-alist '((member-init-intro . ++)))
     
;;      ;; Customizations for all modes in CC Mode.
;;      (defun my-c-mode-common-hook ()
;;        ;; add my personal style and set it for the current buffer
;;        (c-add-style "PERSONAL" my-c-style t)
;;        ;; other customizations
;;        (setq tab-width 8
;;              ;; this will make sure spaces are used instead of tabs
;;              indent-tabs-mode nil)
;;        ;; we like auto-newline and hungry-delete
;;        (c-toggle-auto-hungry-state 1)
;;        ;; key bindings for all supported languages.  We can put these in
;;        ;; c-mode-base-map because c-mode-map, c++-mode-map, objc-mode-map,
;;        ;; java-mode-map, idl-mode-map, and pike-mode-map inherit from it.
;;        (define-key c-mode-base-map "\C-m" 'c-context-line-break))
     
;;      (add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;; from emacs nifty tricks: http://www.emacswiki.org/cgi-bin/wiki/EmacsNiftyTricks#toc13

(defun indent-or-complete ()
  "Complete if point is at end of a word, otherwise indent line."
  (interactive)
  (if (looking-at "\\>")
      (dabbrev-expand nil)
    (indent-for-tab-command)
    ))
(add-hook 'c-mode-common-hook
          (function (lambda ()
                      (local-set-key (kbd "<tab>") 'indent-or-complete)
                      )))
(add-hook 'find-file-hooks (function (lambda ()
                                       (local-set-key (kbd "<tab>") 'indent-or-complete))))

;;; to make all yes or no prompts show y or n instead.
(fset 'yes-or-no-p 'y-or-n-p)

(put 'upcase-region 'disabled nil)

(put 'downcase-region 'disabled nil)

(setq auto-mode-alist (cons '("\\.war$" . archive-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.WAR$" . archive-mode) auto-mode-alist))

(require-or-install 'jde-guess)
(require-or-install 'jde-jalopy)
;;(require-or-install 'my-jde-misc)
;;(require-or-install 'my-jde-functions)
(require-or-install 'jde-stack)
(require-or-install 'jde-overview)
(require-or-install 'jsee)
;;(require-or-install 'jde-findbugs)
(require-or-install 'my-findbugs)
(defun my-jde-mode-hook ()
  (c-toggle-auto-newline)
  (define-key c-mode-base-map "\C-ca" 'jde-javadoc-generate-javadoc-template)
  (define-key c-mode-base-map "\C-m" 'newline-and-indent)  
  (c-set-offset 'inline-open 0)
  (c-set-offset 'substatement-open 0) ; this is the one you care about
  (c-set-offset 'statement-case-open 0)
  (c-set-offset 'case-label '+)
  (fset 'my-javadoc-code
        [?< ?c ?o ?d ?e ?>?< ?/ ?c ?o ?d ?e ?> left left left left left left left])
  (define-key c-mode-base-map "\C-cx" 'my-javadoc-code)
  (abbrev-mode t)
  (setq tab-width 4
        c-block-comment-prefix "* "
        tempo-interactive t
        c-basic-offset 4
 ;; make sure spaces are used instead of tabs
        indent-tabs-mode nil)
;;  (message "my-jde-mode-hook function executed")
  (flymake-mode)
  )

(add-hook 'jde-mode-hook 'my-jde-mode-hook)
;;(remove-hook 'my-jde-mode-hook 'jde-mode-hook)

;;(add-to-list 'load-path "/usr/share/emacs/site-lisp/jde-docindex/lisp")

;;(setq jde-docindex-project-alist '"")
;;(if (null jde-docindex-project-alist)
;;    (setq jde-docindex-project-alist '""))
;;(require-or-install 'jde-docindex)
;;(require-or-install 'tooltip-at-point-jde)
;;(require-or-install 'jde-ant-docindex)
;;(require-or-install 'jde-lint)
;;(if (null compilation-error-regexp-alist-alist)
;;    (setq compilation-error-regexp-alist-alist '(compilation-error-regexp-alist)))
;;(require-or-install 'jde-complete-tooltip)
;;(autoload 'jde-gen-junit-hook "jde-gen-junit" "jde-gen-junit for jde-gen")
;;(add-hook 'jde-mode-hook 'jde-gen-junit-hook)
(defvar jde-new-buffer-menu
  (list
   "JDE New"
   ["Class..."         jde-gen-class-buffer t]
   ["Console..."       jde-gen-console-buffer t]
   ["Other..."         jde-gen-buffer t]
   ["JUnit Test..."    jde-gen-junit-buffer t]
   )
  "Menu for creating new Java buffers.")
(setq jde-db-source-directories jde-sourcepath)
(require-or-install 'jde-jode)
(require-or-install 'jde-properties)
(require-or-install 'jdok)
(require-or-install 'jjar)
(require-or-install 'jlog)
(remove-hook 'jde-mode 'java-mode-hook)
(add-hook 'java-mode-hook 'jlog-mode)
;;(print java-mode-hook)
;;(print jde-mode-hook)
(require-or-install 'jtags)
(setq tags-table-list my-tags-dir)
(require-or-install 'jtemplate)
(require-or-install 'pom)

;;(when (file-exists-p "~/dev/shared-header.txt")
;;  (setq jde-checkstyle-option-header-file "~/dev/shared-header.txt"))
;;(setq jde-checkstyle-option-basedir "~/dev")
(require-or-install 'jde-checkstyle)
(require 'jde-maven2)

(require-or-install 'flymake)

;; (if (not (rassoc 'flymake-mode auto-mode-alist))
;;     (setq auto-mode-alist
;;           (append
;;            '(("\\.java$'" . flymake-mode))
;;            auto-mode-alist)))

(defvar flymake-ecj-jar-location "/usr/share/eclipse-ecj/lib/ecj.jar"
  "The location of the ecj.jar needed by flymake to support Java")

(defun flymake-java-ecj-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'jde-ecj-create-temp-file))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    ;; Change your ecj.jar location here
    (list "java" (list "-jar" flymake-ecj-jar-location "-Xemacs" "-d" "/dev/null" 
                       "-source" "1.5" "-target" "1.5" "-proceedOnError"
                       "-sourcepath" (jde-build-classpath jde-sourcepath) "-classpath" 
                       (jde-build-classpath jde-global-classpath) local-file))))
 
(defun flymake-java-ecj-cleanup ()
  "Cleanup after `flymake-java-ecj-init' -- delete temp file and dirs."
  (flymake-safe-delete-file flymake-temp-source-file-name)
  (when flymake-temp-source-file-name
    (flymake-safe-delete-directory (file-name-directory flymake-temp-source-file-name))))
 
(defun jde-ecj-create-temp-file (file-name prefix)
  "Create the file FILE-NAME in a unique directory in the temp directory."
  (file-truename (expand-file-name (file-name-nondirectory file-name)
                                   (expand-file-name  (int-to-string (random)) (flymake-get-temp-dir)))))
 
(push '(".+\\.java$" flymake-java-ecj-init flymake-java-ecj-cleanup) flymake-allowed-file-name-masks)
 
;;(push '("\\(.*?\\):\\([0-9]+\\): error: \\(.*?\\)\n" 1 2 nil 2 3 (6 compilation-error-face)) compilation-error-regexp-alist)
 
;;(push '("\\(.*?\\):\\([0-9]+\\): warning: \\(.*?\\)\n" 1 2 nil 1 3 (6 compilation-warning-face)) compilation-error-regexp-alist)

(require-or-install 'flymake-helper)

(defun credmp/flymake-display-err-minibuf () 
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)
          )
        )
      (setq count (1- count)))))

(define-key jde-mode-map [M-f7]         'flymake-goto-prev-error)
(define-key jde-mode-map [M-f8]         'flymake-goto-next-error)
(define-key jde-mode-map [M-f9]        'flymake-save-as-kill-err-messages-for-current-line)
