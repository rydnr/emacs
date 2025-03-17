;;; jde-overview.el --- Obtain an overview of Java buffers.

;; $Id: jde-overview.el,v 1.3 2003/01/10 05:57:59 burton Exp $

;; Copyright (C) 2000-2003 Free Software Foundation, Inc.
;; Copyright (C) 2000-2003 Kevin A. Burton (burton@openprivacy.org)

;; Author: Kevin A. Burton (burton@openprivacy.org)
;; Maintainer: Kevin A. Burton (burton@openprivacy.org)
;; Location: http://relativity.yi.org
;; Keywords:
;; Version: 1.0.0

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
;; JDE overview provides a quick "overview" of a Java class from its Java
;; source.  This overview provides misc information defined in the source file
;; including class and method declarations.  The main benefit is that since the
;; overview is based on the source file it's format is not modified from how it
;; was entered.
;;
;; The output is in the shape of:
;;
;; //JDE overview for file: /projects/reptile/src/java/org/openprivacy/reptile/actions/UpdateSubscriptions.java
;; 29:  package org.openprivacy.reptile.actions;
;;
;; 56:  public class UpdateSubscriptions implements Action {
;;
;; 58:      public void perform( HttpServletRequest request,
;; 59:                           HttpServletResponse response ) throws Exception {

;;; TODO:
;;
;;

;;; Code:
(defvar jde-overview-buffer-name "*jde-overview*" "Name of the temp buffer.")

(defvar jde-overview-current-class-or-interface nil "If the currently parsed
file is a class the value will be 'class' and if it is an interface it will be
set to 'interface'.")

(defun jde-overview-class-at-point()
  "Get an overview for the class at the current point."
  (interactive)
  
  (save-window-excursion
    (jde-open-class-source)

    (jde-overview))

  (display-buffer jde-overview-buffer-name))
  
(defun jde-overview()
  "Show an overview of the current Java buffer."
  (interactive)

  (save-excursion
    
    (jde-overview-init)
      
    (goto-char (point-min))

    (jde-overview-insert (format "//JDE overview for file: %s\n" (buffer-file-name)) 1)

    (jde-overview-do-package)

    (jde-overview-do-class)
      
    (let(method-start method-end regexp)

      (if (string-equal jde-overview-current-class-or-interface "class")
          (setq regexp "[ ]+public [^{;=]+{")
        (setq regexp "[ ]+public [^{=]+;"))

      ;; should contain ;=
      (while (re-search-forward regexp nil t)

        (setq method-start (match-beginning 0))

        (setq method-end (match-end 0))

        (jde-overview-insert (concat (buffer-substring method-start method-end) "\n\n")
                             (jde-overview-line-number method-start))))
      
    (jde-overview-fontify)
    (display-buffer jde-overview-buffer-name)
    (set-buffer jde-overview-buffer-name)
    (jde-overview-mode)))

(defun jde-overview-do-package()
  "Do the overview entry fo the current package."

  (assert (re-search-forward "^package .*;" nil t)
          nil "Could not find package statement")
  
  (jde-overview-insert (concat (buffer-substring (match-beginning 0)
                                                 (match-end 0))
                               "\n\n")
                       (jde-overview-line-number (match-beginning 0))))
            

(defun jde-overview-do-class()
  "Do the overview entry for the current class."

  (let(start end)
  
      (assert (re-search-forward "public \\(class\\|interface\\)" nil t)
              nil "Could not find class")

      (setq jde-overview-current-class-or-interface (match-string 1))
      
      (setq start (match-beginning 0))

      (assert (re-search-forward "{" nil t)
              nil "Could not find end of class")

      (setq end (match-end 0))

      (jde-overview-insert (concat (buffer-substring start end) "\n\n")
                           (jde-overview-line-number start))))

(defun jde-overview-init()
  "Perform any necesary initialization."

  (save-excursion

    (set-buffer (get-buffer-create jde-overview-buffer-name))

    (toggle-read-only -1)
    
    (erase-buffer)))

(defun jde-overview-fontify()
  "Highlght the buffer where necessary."

  (save-excursion

    (set-buffer (get-buffer-create jde-overview-buffer-name))

    (goto-char (point-min))

    (save-excursion
      (while (re-search-forward "//.+$" nil t)
      
        (add-text-properties (match-beginning 0) (match-end 0)
                             '(comment t face font-lock-comment-face))))

    (save-excursion
      (while (re-search-forward "^[ ]*[0-9]+" nil t)
      
        (add-text-properties (match-beginning 0) (match-end 0)
                             '(face font-lock-variable-name-face))))))

(defun jde-overview-line-number(point)
  "Get the line number for the current point.  If the optional value of point is
given we use this as the base of the line number."

  (1+ (count-lines (point-min) point)))

(defun jde-overview-insert(value line-number)
  "Insert the given value and keep track of the line number it is using."
  
  (let(start end)
    (save-excursion

      (set-buffer (get-buffer-create jde-overview-buffer-name))
      
      (goto-char (point-max))

      (setq start (point))
      (insert value)

      (setq end (point))

      (jde-overview-lineify start end line-number)
      
      (put-text-property start end 'jde-overview-line-number line-number))))

(defun jde-overview-lineify(start end start-line-number)
  "Add line number entries in the overview buffer"

  (save-excursion
    (let(line-distance (i 1))

      (goto-char start)
      (goto-char (point-at-bol))
      
      (setq line-distance (count-lines start end))
      
      (while (< i line-distance)
        
        (goto-char (point-at-bol))
        
        (insert (jde-overview-format-line-number start-line-number))
        
        (forward-line 1)

        (setq start-line-number (1+ start-line-number))
        
        (setq i (1+ i ))))))

(defun jde-overview-format-line-number(line-number)
  "Format a line number including padding for inclusing in the overview buffer."

  (if (< line-number 10)
      (concat (number-to-string line-number) ":   ")
    (if (< line-number 100)
        (concat (number-to-string line-number) ":  ")
      
      (concat (number-to-string line-number) ": "))))
  
(defun jde-overview-goto-line-number()
  "Goto the current line number."
  (interactive)

  (let(filename line-number)

    (save-excursion

      (goto-char (point-min))
      
      (assert (re-search-forward "file: \\(.*\\)$" nil t)
              nil "Could not find filename.")

      (setq filename (match-string 1)))
      
    (setq line-number (get-text-property (point) 'jde-overview-line-number))
      
    (find-file-other-window filename)
    
    (goto-line line-number)))

(define-derived-mode jde-overview-mode fundamental-mode "JDEOverview"
  "Mode for JDE overviews."

  (toggle-read-only 1))

;;key binding so that one can quickly jump an entry in the overview buffer
(define-key jde-overview-mode-map [return] 'jde-overview-goto-line-number)

(define-key java-mode-map [S-C-return] 'jde-overview-class-at-point)

(provide 'jde-overview)

;;; jde-overview.el ends here
