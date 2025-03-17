;;; jde-properties.el --- ADD BASIC DESCRIPTION

;; $Id: jde-properties.el,v 1.3 2002/07/03 03:15:43 burton Exp $

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

;;; Code:

(defvar jde-properties-mode-hook nil
  "")

(defvar jde-properties-mode-map (make-sparse-keymap)
  "Keymap for Text mode.
Many other modes, such as Mail mode, Outline mode and Indented Text mode,
inherit all the commands defined in this map.")

(defun jde-properties-mode ()
  "Major mode for editing text written for humans to read.
In this mode, paragraphs are delimited only by blank or white lines.
You can thus get the full benefit of adaptive filling
 (see the variable `adaptive-fill-mode').
\\{text-mode-map}
Turning on Text mode runs the normal hook `text-mode-hook'."
  (interactive)
  (kill-all-local-variables)
  (use-local-map jde-properties-mode-map)

  (setq mode-name "Properties")
  (setq major-mode 'jde-properties-mode)

  (make-local-variable 'comment-start)

  (setq comment-start  "#")

  (font-lock-mode)

  (font-lock-add-keywords nil (list (list (concat "\\(^[ ]*" comment-start ".*$\\)") 0 'font-lock-comment-face t)))

  (font-lock-mode 1)

  (run-hooks 'jde-properties-mode-hook))

;;add a font lock so that nested properties work... IE.
;; test.test.name=value

(font-lock-add-keywords 'jde-properties-mode '(("\\<\\([a-zA-Z0-9_.-]+[ ]*\\)\\(=\\)\\(.*$\\)"
                                                (1 'font-lock-variable-name-face append)
                                                (2 'font-lock-warning-face append)
                                                (3 'font-lock-builtin-face append))))

;;java property detection
(add-to-list 'auto-mode-alist '("\\.properties\\'" . jde-properties-mode))
(add-to-list 'auto-mode-alist '("java.security\\'" . jde-properties-mode))

(provide 'jde-properties)

;;; jde-properties.el ends here
