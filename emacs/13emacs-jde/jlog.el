;; jlog.el --- Helper for java logging/trace message

;; Copyright (C) 2002 by Alexandre Brillant

;; Author: Alexandre Brillant <abrillant@wanadoo.fr>
;; Maintainer: Alexandre Brillant <abrillant@wanadoo.fr>
;; Created: 22/02/02
;; Version: 1.0
;; Keywords: tools
;; Official site : http://www.djefer.com

;; This file is not part of Emacs

;; This program is free software; you can redistribute it and / or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;

;; Installation
;;
;; Copy jlog.el to an emacs valid path
;; use the following command in your .emacs :
;; (require `jlog)

;;; Commentary:

;; This minor mode helps to manage trace/log in a Java class. Mainly,
;; this is a toolkit for adding/removing println-like trace. This is
;; useful for debugging your code.
;; You can enable/disable this minor mode with the `jlog-mode' command
;; If you don't want to have this minor mode each time you load a 
;; java class, please remove the following line in the code :
;; (add-hook 'java-mode-hook 'jlog-mode)

;;; Commands: 
;;
;; `jlog-insert-message' : Insert a log message, the standard System.out.println 
;; is set by default. The trace contains by default a level of message, 
;; the number of trace function, the current package and your message. You
;; can update the format with the `jlog-current-format' variable. The
;; level of the message is just a string with a set of '*' caracters. 
;; `jlog-increase-level' : Increase the level of each message (interesting for debugging)
;; `jlog-decrease-level' : Decrease the level of each message (interesting for debugging)
;; `jlog-delete-message' : Delete the current log message
;; `jlog-delete-message-region' : Delete all log message for the region
;; `jlog-delete-message-buffer' : Delete all log message for the current buffer
;;
;; Keys: 
;;
;; \C-cm : Call the `jlog-insert-message' command
;; \C-c+ : Call the `jlog-increase-level' command
;; \C-c- : Call the `jlog-decrease-level' command
;; \C-cp : Call the `jlog-delete-message' command
;;
;;; Change Log:
;;

;;; Code:

;; Add the jlog-mode mode with java buffer
(add-hook 'java-mode-hook 'jlog-mode)

(defconst jlog-version "JLog 1.0 by Alexandre Brillant (http://www.djefer.com)"
  "jlog version information")

;; Supported item for trace
(defconst jlog-class-format-item "class")
(defconst jlog-package-format-item "package")
(defconst jlog-counter-format-item "counter")

;; Build it with all *-format-item element 
;; Order if not maintain
(defvar jlog-current-format "class package counter"
  "Format for trace. see the jlog-*-format-item.")

(defvar jlog-level-message 0
  "Level of a message information added")

;; Method name for tracing
(defconst jlog-method "System.out.println"
  "Java Method for log.")
(defconst jlog-comment "//--- jlog-trace do not remove it !"
  "Java comment for detecting jlog-trace.")
;; Option
;; Indent after inserting
(defconst jlog-indent t
  "Decide to indent the trace after inserting.")

;; Level item for information 
(defconst jlog-message-level-item "*"
  "Item for the level information.")

;; Minor mode activation

(defvar jlog-mode nil
  "Mode variable for the jlog minor mode.")
(make-variable-buffer-local 'jlog-mode)

(defun jlog-mode (&optional arg)
  "JLog minor mode."
  (interactive "P")
  (setq jlog-mode
	(if (null arg)
	    (not jlog-mode)
	  (> (prefix-numeric-value arg) 0))))

(if (not (assq 'jlog-mode minor-mode-alist))
    (setq minor-mode-alist
	  (cons '(jlog-mode " JLog" )
		minor-mode-alist)))

;; keymap
(setq jlog-map (make-sparse-keymap))

;; Keys
(define-key jlog-map "\C-cm" 'jlog-insert-message)
(define-key jlog-map "\C-c+" 'jlog-increase-level)
(define-key jlog-map "\C-c-" 'jlog-decrease-level)
(define-key jlog-map "\C-cp" 'jlog-delete-message)

(setq minor-mode-map-alist (cons (cons 'jlog-mode jlog-map) minor-mode-map-alist))

;; Function

;; Insert a trace information
(defun jlog-insert-message(message)
  "Insert a trace/log in the current buffer."
  (interactive "sMessage :")
  (progn
    (insert (jlog-build-message message))
    (if jlog-indent 
	(jlog-indent-message))))

;; Select a level message
(defun jlog-increase-level()
  "Increase the level of the message."
  (interactive)
  (setq jlog-level-message (1+ jlog-level-message))
  (message "Jlog level message : [%s]" (jlog-return-level-message)))

(defun jlog-delete-message()
  "Delete the current message with the jlog comment."
  (interactive)
  (progn
    (save-excursion
      (save-restriction
	(save-match-data
	  (widen)
	  (beginning-of-line)
	  (if (looking-at (concat "^[ \t]*" jlog-method))
	    (progn
	      (setq kill-whole-line-restore kill-whole-line)
	      (setq kill-whole-line t)
	      (kill-line)
	      (forward-line -1)
	      (beginning-of-line)
	      (if (looking-at (concat "^[ \t]*" jlog-comment))
		(kill-line))
	      (setq kill-whole-line kill-whole-line-restore))))))))

(defun jlog-delete-message-region()
  "Delete all jlog message for the current region."
  (interactive)
  (let* ( (current-mark (mark t))
	  (current-point (point))
	  (starting-char (min current-mark current-point))
	  (ending-char (max current-mark current-point)))
    (save-excursion
      (save-restriction
	(save-match-data
	  (widen)
	  (goto-char starting-char)
	  (let ( (regexp (concat "^[ \t]*" jlog-comment)))
	    (while (and (< (point) ending-char) (re-search-forward regexp nil t))
	      (next-line 1)
	      (jlog-delete-message))))))))

(defun jlog-delete-message-buffer()
  "Delete all jlog message for the current buffer."
  (interactive)
  (save-excursion
    (save-restriction
      (save-match-data
	(widen)
	(set-mark (point-min))
	(goto-char (point-max))
	(jlog-delete-message-region)))))

;; Select a level message
(defun jlog-decrease-level()
  "Decrease the level of the message."
  (interactive)
  (setq jlog-level-message (1- jlog-level-message))
  (if (< jlog-level-message 0) (setq jlog-level-message 0))
  (message "Jlog level message : [%s]" (jlog-return-level-message)))

;; Shortcut
(defun jlog-return-level-message()
  (jlog-build-level-message jlog-level-message))

;; Insert format-item-item (class...)
(defun jlog-format-message(message)
  (let ( (return-message ""))
    (if (jlog-is-item jlog-class-format-item jlog-current-format)
	(setq return-message (concat (jlog-extract-class-name) " " return-message)))
    (if (jlog-is-item jlog-package-format-item jlog-current-format)
	(setq return-message (concat (jlog-extract-package-name) " " return-message)))
    (if (jlog-is-item jlog-counter-format-item jlog-current-format)
	(setq return-message (concat "(" (number-to-string (jlog-extract-counter-value)) ") " return-message)))
    (setq return-message (concat return-message (if (> (length return-message) 0) " : ") message))
    return-message))

(defun jlog-build-message(message)
  (let ( (formated-message (jlog-format-message message)) (final-string))
    (setq final-string (concat jlog-comment "\n"))
    (setq formated-message (concat (jlog-return-level-message) formated-message))
    (setq final-string (concat final-string jlog-method "(\"" formated-message "\");"))
    final-string))

;; Toolkit

(defconst jlog-regexp-class-name "class[ \t]*\\([^  \t{]+\\)[ \t]*[^{]*{")
(defconst jlog-regexp-package-name "^package[ ]*\\(.*\\);$")

;; Indent the new message
(defun jlog-indent-message()
  (save-excursion
    (save-restriction
      (save-match-data
	(widen)
	(let ((start 0) (end (point)))
	  (forward-line -2)
	  (beginning-of-line)
	  (setq start (point))
	  (if (> end start)
	      (indent-region start end nil))
	  )))))

;; Check for the item in the format-string
(defun jlog-is-item(item format-string)
  (if (string-match item format-string)
      t
    nil))

;; Extract the current class name
(defun jlog-extract-class-name()
  (save-excursion
    (save-restriction
      (save-match-data
	(widen)
	(goto-char (point-min))
	(if ( re-search-forward jlog-regexp-class-name nil t) 
	    (match-string 1)
	  ""
	  )))))

;; Extract the current package name
(defun jlog-extract-package-name()
  (save-excursion
    (save-restriction
      (save-match-data
	(widen)
	(goto-char (point-min))
	(if (re-search-forward jlog-regexp-package-name nil t)
	    (match-string 1)
	  ""
	  )))))

;; Extract the number of 'jlog-method' field
(defun jlog-extract-counter-value()
  (save-excursion
    (save-restriction
      (save-match-data
	(widen)
	(goto-char (point-min))
	(let ((counter 0))
	  (while (re-search-forward jlog-method nil t)
	    (setq counter (1+ counter)))
	  counter)))))

;; Return a set of '*' caracter for the front message inserted
(defun jlog-build-level-message(size)
  (let ((level ""))
    (while (> size 0)
      (setq level (concat jlog-message-level-item level))
      (setq size (1- size)))
    level))

(provide 'jlog)

;;; jlog.el ends here
