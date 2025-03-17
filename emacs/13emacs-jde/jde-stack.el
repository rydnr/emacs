;;; jde-stack.el --- Jump to source from Java stack trace

;; Copyright (C) 1999 Phillip Lord <p.lord@hgmp.mrc.ac.uk>
;; Copyright (C) 2001 Kevin A. Burton <burton@apache.org>
;; Version: 1.0.3

;; $Id: jde-stack.el,v 1.16 2003/01/10 05:57:59 burton Exp $

;; This file is [not yet] part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation; either version 2 of the License, or any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
;; details.
;;
;; You should have received a copy of the GNU General Public License along with
;; this program; if not, write to the Free Software Foundation, Inc., 59 Temple
;; Place - Suite 330, Boston, MA 02111-1307, USA.

;;; Commentary:
;; 
;; This package provides the ability to jump from stack traces to the relevant
;; part of the java source. There is one main entry point which is a mouse-1
;; click on the stack trace, which will jump to the source suggested at this
;; point. This should also work in other buffers (for instance log files), by
;; calling directly the function `jde-stack-show-at-point'. Following this entry
;; point two functions `jde-stack-show-next' and `jde-stack-show-prev' allow
;; cycling backwards and forwards through the stack trace. Error messages are
;; given when the end of the stack is reached.

;;; TODO/Bugs:
;; - stop using java-open and use the jde package. 
;;
;; - have this update compilation-error-list so that the standard compile.el
;;   functions work correctly.  Some of this is already in the other
;;   jde-stack.el so use this.
;;    - need to update java-open commentary
;;
;; - change the package name to jde-exception.el
;;
;; - native methods are not supported:
;; 	at java.security.AccessController.doPrivileged(Native Method)
;;
;; - rewrite this to use the standard next-error etc compile support
;;
;; - jde-stack navigation doesn't work correctly if we aren't within the jde
;; comint output buffer.
;;

;;; History:
;;
;; Thu Jan 17 2002 03:51 PM (burton@openprivacy.org): added jde-stack-mode-on to
;; jde-ant-build-hook
;; 
;; Wed Dec 05 2001 07:01 PM (burton@openprivacy.org): can now accept packages
;; with numbers in them (0-9).
;;
;; Tue Dec 04 2001 03:10 PM (burton@openprivacy.org): reduced complexity or
;; regexp so that we match non stack traces that are similar to standard stack
;; traces.
;;
;; Fri Nov 30 2001 04:29 PM (burton@openprivacy.org): We now goto the other
;; buffer when navigating the stack (just like the regular navigation features)
;;
;; Tue Nov 06 2001 06:07 PM (burton@openprivacy.org): remove the at-mouse
;; functionality from the keymap.  This had a tendency to break things if you
;; just wanted to update the point.
;;
;; Sat Mar  3 14:43:37 2001 (burton@relativity.yi.org): now supports underlines
;; within classnames and methods.  
;;
;; Sat Mar  3 14:39:13 2001 (burton@relativity.yi.org): now support internal
;; classnames
;;
;; Thu Feb 22 21:19:20 2001 (burton@relativity.yi.org): use multiple
;; font-locks... one for the class, one for the buffer name, one for the line
;; number.
;;
;; Mon Feb 19 16:15:24 2001 (burton@relativity.yi.org): Added font-lock support
;; so that stack lines are highlighted.  `jde-stack-mode' is now on during
;; `jde-run-mode'.
;;
;; Sat Feb 10 20:20:40 2001 (burton@relativity.yi.org): Fixed this bug:
;; Its a little bit limited at the moment, in that it parses by a simple
;; regexp. It will also fail totally if a JIT is being used. It also uses the
;; JDE to translate between the unqualified class name, and the full name, even
;; though its given in the stack trace. This is entirely the fault of the JVM
;; which gives stack traces of the form (Blah.java:999). This is so easy to
;; regexp search, that I couldnt turn down the oppurtunity.
;; 
;;
;; Sat Feb 10 18:18:40 2001 (burton@relativity.yi.org): cleaned up source.
;; added versioning information.  Created `jde-stack-mode' and moved key
;; bindings to this.
;; 

;;; TODO:

;; need to temporarily highlight the line when we go to it... use a timer to
;; deactivate the highlight?

(require 'jde)
;;(require 'java-open)

;;; Code:

(defvar jde-stack-mode nil "True if `jde-stack-mode' is on.")
(make-variable-buffer-local 'jde-stack-mode)

(defvar jde-stack-mode-string " Stack"
  "String for the mode line when jde-stack-mode is on.")

(defvar jde-stack-classname-regexp "[a-z._]*[A-Z][a-zA-Z0-9_]+"
  "Regular expression for finding classes.")

(defvar jde-stack-linenumber-regexp "[0-9]+"
  "Regular expression for finding line numbers.")

(defvar jde-stack-find-exception-regexp (concat "^" jde-stack-classname-regexp "Exception" ))

(defvar jde-stack-mode-map nil "Mode specific keymap for function `jde-stack-mode'.")
(setq jde-stack-mode-map  (let ((map (make-sparse-keymap)))
                            (define-key map "\C-c\C-v\C-[" 'jde-stack-prev)
                            (define-key map "\C-c\C-v\C-]" 'jde-stack-next)
                            (define-key map [C-return] 'jde-stack-show-at-point)
                            map))

(defvar jde-stack-current-buffer nil "Current buffer with stack info.")

(defvar jde-stack-current-point nil "Current point where stack info was found.")

(defun jde-stack-show-class-stack(class line current-window)
  ;; jde-show-class-source switches automatically to other
  ;; window. Makes sense there, screws things up here. So switching to
  ;; window -1 here makes it switch back to where we started. Arrgh!!!
  (if current-window
      (other-window -1))
  (jde-show-class-source class)
  (set-buffer (concat class ".java" ))
  (goto-line (string-to-number line)))

(defun jde-stack-show-at-mouse (event)
  "Jump to the stack at the mouse click."
  (interactive "e" )
  (save-excursion
    (set-buffer (jde-stack-url-event-buffer event))
    (goto-char (jde-stack-event-point event))
    (jde-stack-show-at-point)))
    
(defun jde-stack-show-at-point()
  "Displays the stack on this current line"
  (interactive)
  (if (not (jde-stack-show-on-line))
      (message "Unable to parse stack on this line")))

(defun jde-stack-show-on-line()
  "Show the stack trace on this line."

  (let ((line-ending (progn
                       (goto-char (point-at-eol))
                       (point)))
        (filename nil)
        (classname nil)
        (linenumber nil)
        (stack-buffer nil)
        (case-fold-search nil))

    (save-excursion
      (goto-char (point-at-bol))
    
      ;;get the buffer that currently has the stack..
      (setq stack-buffer (current-buffer))

      ;;add support for internal clases.

      (if (re-search-forward jde-stack-classname-regexp line-ending t)
          (setq classname (match-string-no-properties 0)))
      
      (if (search-forward ":" nil t)
          (if (re-search-forward jde-stack-linenumber-regexp line-ending t)
              (setq linenumber (string-to-number (match-string-no-properties 0)))))
      
      (assert classname nil "Unable to determine classname")
      (assert linenumber nil "Unable to determine linenumber")

      (jde-stack-save-buffer))

    ;;make sure we send the point to the beginning.
    (save-excursion
      (jde-stack-beginning-of-line)
      
      (setq filename (jde-find-class-source-file classname)))
      
    (if filename
        (progn

          (delete-other-windows)

          (save-excursion

            (set-buffer (find-file-noselect filename))

            ;;use set-window-point??
            
            (goto-line linenumber)

            (set-window-point (get-buffer-window (current-buffer)) (point)))
          
          ;;restore the original buffer
          ;;(set-buffer jde-stack-current-buffer)

          (split-window)
          (other-window 1)
          (switch-to-buffer (get-file-buffer filename)))
      (error "Count not find file for classname: %s" classname))))

(defun jde-stack-beginning-of-line()
  "Go to the beginning of a stack line."
  
  (goto-char (point-at-bol))
  (if (search-forward "at " nil t)
      (goto-char (match-beginning 0))
    (goto-char (point-at-bol))))

;;stolen from browse-url. I have no idea what they do. Perhaps they
;;are useless, who can tell???
(defun jde-stack-url-event-buffer (event)

  (window-buffer (posn-window (event-start event))))

(defun jde-stack-event-point (event)

  (posn-point (event-start event)))

(defun jde-stack-restore-buffer()

  (set-buffer jde-stack-current-buffer)
  (goto-char jde-stack-current-point))

(defun jde-stack-save-buffer()
  ;;update the buffer info so that we can navigate stacks...
  (setq jde-stack-current-buffer (current-buffer))
  (setq jde-stack-current-point (point)))

(defun jde-stack-next()
  "Shows the source next in the stack trace"
  (interactive)

  (set-buffer jde-stack-current-buffer)

  (forward-line 1)
  
  (if (jde-stack-show-on-line)
      (jde-stack-beginning-of-line)
     (error "The end of the stack has been reached" )))

(defun new-jde-stack-next()
  (interactive)

  (jde-stack-restore-buffer)

  (forward-line 1)

  (jde-stack-save-buffer)

  (if (not (jde-stack-show-on-line))
     (error "The end of the stack has been reached" )))

;;(jde-stack-show-on-line))

(defun jde-stack-prev()
  "Shows the source previous in the stack trace"
  (interactive)
  (jde-stack-restore-buffer)

  (forward-line -1)
  (if (jde-stack-show-on-line)
      (jde-stack-beginning-of-line)
    (error "The start of the stack has been reached" )))

(defun jde-stack-mode(&optional arg)
  "Turn jde-stack-mode on/off"
  (interactive)
  (if (if arg
          (> (prefix-numeric-value arg) 0)
        (not jde-stack-mode))
      (jde-stack-mode-on)
    (jde-stack-mode-off)))

(defun jde-stack-mode-on()
  "Turn on mc-mode."
  (interactive)
  (setq jde-stack-mode t)

  (font-lock-mode 1)

  (jde-stack-font-lock-setup))

(defun jde-stack-mode-off()
  "Turn off mc-mode."
  (interactive)
  (setq jde-stack-mode nil))

(defun jde-stack-font-lock-setup()
    ;;setup the correct font-lock stuff

  ;;font lock setup notes
  ;;
  ;; the actual exception class -> font-lock-keyword-face
  ;; exception message -> font-lock-string-face
  ;; stack entry class and method -> font-lock-constant-face
  ;; stack entry file -> font-lock-variable-name-face
  ;; stack entry line number -> font-lock-type-face

  (font-lock-add-keywords nil '(("\\(^[a-z._]*[a-zA-Z0-9_]*Exception\\)\\(: \\)?\\(.*\\)?"
                                 (1 'font-lock-keyword-face append)
                                 (3 'font-lock-string-face append))))
  
  (font-lock-add-keywords nil '(("\\([a-z0-9._]*[a-zA-Z0-9_$]+\\.[a-zA-Z0-9_]*\\)(\\([a-zA-Z0-9]+.java\\):\\([0-9]+\\))$"
                                 (1 'font-lock-constant-face append)
                                 (2 'font-lock-variable-name-face append)
                                 (3 'font-lock-type-face append))))

  (font-lock-add-keywords nil '(("\\([a-z0-9._]*[a-zA-Z0-9_$]+\\.<init>\\)(\\([a-zA-Z0-9]+.java\\):\\([0-9]+\\))$"
                                 (1 'font-lock-constant-face append)
                                 (2 'font-lock-variable-name-face append)
                                 (3 'font-lock-type-face append))))

  (font-lock-fontify-buffer))

(defun jde-stack-find-exception()
  "Find an exception within this buffer."
  (interactive)

  (let(exception-found)
    (save-excursion
      (forward-line 1)
      
      (setq exception-found (re-search-forward jde-stack-find-exception-regexp
                                               nil t)))

      (if exception-found
          (progn
            (goto-char exception-found)
            (goto-char (point-at-bol)))
        (error "Cound not find a stack trace."))))
 
(defun jde-stack-update-highline()
  "Make sure to update highline if the user runs it."

  (if (featurep 'highline)
      (highline-highlight-current-line)))

;;(add-hook 'font-lock-mode-hook 'jde-stack-font-lock-setup)
(add-hook 'jde-run-mode-hook 'jde-stack-mode-on)
(add-hook 'jde-ant-build-hook 'jde-stack-mode-on)

;;add to minor-mode
(add-to-list 'minor-mode-alist
             '(jde-stack-mode jde-stack-mode-string))
(let ((a (assoc 'jde-stack-mode minor-mode-map-alist)))
  (if a
      (setcdr a jde-stack-mode-map)
    (add-to-list 'minor-mode-map-alist
                 (cons 'jde-stack-mode jde-stack-mode-map))))

;;add keys for jde mode..
(define-key jde-mode-map "\C-c\C-v\C-[" 'jde-stack-prev)
(define-key jde-mode-map "\C-c\C-v\C-]" 'jde-stack-next)

(defadvice jde-run-mode(after jde-stack-activate())
  "Activeate jde-stack-mode after jde-run-mode "
  
  (jde-stack-mode-on))

(ad-activate 'jde-run-mode)

(provide 'jde-stack)
;;; jde-stack.el ends here
