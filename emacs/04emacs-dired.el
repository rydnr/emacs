;;; 04emacs-dired.el

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
;; Autoload `dired-jump' and `dired-jump-other-window'.
;; We autoload from FILE dired.el.  This will then load dired-x.el
;; and hence define `dired-jump' and `dired-jump-other-window'.
(define-key global-map "\C-x\C-j" 'dired-jump)
(define-key global-map "\C-x4\C-j" 'dired-jump-other-window)

(autoload (quote dired-jump) "dired" "\
     Jump to Dired buffer corresponding to current buffer.
     If in a file, Dired the current directory and move to file's line.
     If in Dired already, pop up a level and goto old directory's line.
     In case the proper Dired file line cannot be found, refresh the Dired
     buffer and try again." t nil)

(autoload (quote dired-jump-other-window) "dired" "\
     Like \\[dired-jump] (dired-jump) but in other window." t nil)

(require 'dired-x)

; enhance dired mode
; this does not seem to work on xemacs
(add-hook 'dired-load-hook (function (lambda ()(load "dired-x"))))
;;(setq dired-omit-files-p nil)
;;; dired-tar.el
(require-or-install 'dired-tar)

(put 'dired-find-alternate-file 'disabled nil)

(add-hook 'dired-load-hook
          (lambda ()
            (load "dired-x")
            ;; Set dired-x global variables here.  For example:
            ;; (setq dired-guess-shell-gnutar "gtar")
            ;; (setq dired-x-hands-off-my-keys nil)
            ))
(add-hook 'dired-mode-hook
(lambda ()
  ;; Set dired-x buffer-local variables here.  For example:
  (dired-omit-mode 1)
  ))

(eval-after-load "dired"
 '(progn
    (defadvice dired-advertised-find-file (around dired-subst-directory activate)
      "Replace current buffer if file is a directory."
      (interactive)
      (let* ((orig (current-buffer))
             (filename (dired-get-filename))
             (bye-p (file-directory-p filename)))
        ad-do-it
        (when (and bye-p (not (string-match "[/\\\\]\\.$" filename)))
          (kill-buffer orig))))))

(setq dired-omit-files
      "\\|^RCS$\\|,v$\\|^\\.svn$\\|^CVS$\\|^semantic.cache$\\|^.git$\\|\\~$")

(defun dired-do-info ()
    (interactive)
    "In dired, read the Info file named on this line."
    (info (dired-get-filename)))
  
(add-hook 'dired-mode-hook
          (lambda ()
            (local-set-key "I" 'dired-do-info)))
