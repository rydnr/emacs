;;; 19emacs-slime.el

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
;;; slime -> Superior Lisp Interaction Mode for Emacs
;;(add-to-list 'load-path "~/emacs/site/slime")
;;(require-or-install 'slime)
;;(slime-setup)

;;(push "/home/chous/emacs//slime" load-path)
;; Common Lisp Mode
(add-to-list 'auto-mode-alist '("\\.lisp$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.cl$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.asd$" . lisp-mode))
(load (expand-file-name "~/quicklisp/slime-helper.el"))
(require 'slime)
(slime-setup)
(eval-after-load "slime"
 '(progn
    (setq inferior-lisp-program "/usr/bin/sbcl"
          lisp-indent-function 'common-lisp-indent-function
          slime-complete-symbol*-fancy t
          slime-complete-symbol-function 'slime-fuzzy-complete-symbol
          slime-when-complete-filename-expand t
          slime-truncate-lines nil
          common-lisp-hyperspec-root "file:///usr/share/doc/hyperspec/"
          slime-autodoc-use-multiline-p t)
    (setf slime-translate-to-lisp-filename-function
          (lambda (file-name)
               (subseq file-name (length "/scp:jlean:")))
          slime-translate-from-lisp-filename-function
          (lambda (file-name)
               (concat "/scp:jlean:" file-name)))
    (slime-setup '(slime-fancy slime-asdf))
    (define-key slime-repl-mode-map (kbd "C-c ;")
      'slime-insert-balanced-comments)
    (define-key slime-repl-mode-map (kbd "C-c M-;")
      'slime-remove-balanced-comments)
    (define-key slime-mode-map (kbd "C-c ;")
      'slime-insert-balanced-comments)
    (global-set-key [f6] 'slime-selector)
    (define-key slime-mode-map (kbd "C-c M-;")
      'slime-remove-balanced-comments)
    (define-key slime-mode-map (kbd "RET") 'newline-and-indent)
    (define-key slime-mode-map (kbd "C-j") 'newline)))
(add-hook 'lisp-mode-hook (lambda ()
                           (cond ((not (featurep 'slime))
                                  (require 'slime)
                                  (normal-mode)))))
;;                           (indent-tabs-mode nil)
                             (slime-mode t)
;;                           (pair-mode t)))
(add-hook 'inferior-lisp-mode-hook (lambda () (inferior-slime-mode t)))



(defun clisp-debug-keys ()
  "Binds locally some keys to send clisp debugger commands to the inferior-lisp
<f5> step into
<f6> next
<f7> step over
<f8> continue
"
  (interactive)
  (macrolet ((cmd (string)
               `(lambda ()
                  (interactive)
                  (comint-send-string (inferior-lisp-proc)
                                      ,(format "%s\n" string)))))
    (local-set-key (kbd "<f5>") (cmd ":s"))
    (local-set-key (kbd "<f6>") (cmd ":n"))
    (local-set-key (kbd "<f7>") (cmd ""))
    (local-set-key (kbd "<f8>") (cmd ":c"))))

(defun ecl-debug-keys ()
  "Binds locally some keys to send clisp debugger commands to the inferior-lisp
<f5> step into
<f6> next
<f7> step over
<f8> continue
"
  (interactive)
  (macrolet ((cmd (string)
               `(lambda ()
                  (interactive)
                  (comint-send-string (inferior-lisp-proc)
                                      ,(format "%s\n" string)))))

    (local-set-key (kbd "<f5>") (cmd ""))
    (local-set-key (kbd "<f6>") (cmd ""))
    (local-set-key (kbd "<f7>") (cmd ":skip"))
    (local-set-key (kbd "<f8>") (cmd ":exit"))))

(defun sbcl-debug-keys ()
  "Binds locally some keys to send clisp debugger commands to the inferior-lisp
<f5> step into
<f6> next
<f7> step over
<f8> continue
"
  (interactive)
  (macrolet ((cmd (string)
               `(lambda ()
                  (interactive)
                  (comint-send-string (inferior-lisp-proc)
                                      ,(format "%s\n" string)))))
    (local-set-key (kbd "<f5>") (cmd "step"))
    (local-set-key (kbd "<f6>") (cmd "next"))
    (local-set-key (kbd "<f7>") (cmd "over"))
    (local-set-key (kbd "<f8>") (cmd "out"))))

(defun allegro-debug-keys ()
  "Binds locally some keys to send allegro debugger commands to the inferior-lisp
<f5> step into
<f7> step over
<f8> continue
"
  (interactive)
  (macrolet ((cmd (string)
               `(lambda ()
                  (interactive)
                  (comint-send-string (inferior-lisp-proc)
                                      ,(format "%s\n" string)))))
    (local-set-key (kbd "<f5>") (cmd ":scont 1"))
    ;; (local-set-key (kbd "<f6>") (cmd ))
    (local-set-key (kbd "<f7>") (cmd ":sover"))
    (local-set-key (kbd "<f8>") (cmd ":continue"))))
