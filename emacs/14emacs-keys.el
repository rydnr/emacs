;;; 14emacs-keys.el

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
; set keys
(global-set-key [f1] 'dired)
(global-set-key [f2] 'dired-omit-toggle)
(global-set-key [f3] 'eshell)
(global-set-key [f4] 'find-file)
(global-set-key [f5] 'my-compile)
(global-set-key [f6] 'visit-my-tags-files)
(global-set-key [f7] 'add-change-log-entry-other-window)
(global-set-key [f8] 'find-grep-dired)
(global-set-key [f11] 'calculator)
(if (functionp 'other-window-back)
    (define-key global-map "\C-xp" 'other-window-back))
(if (functionp 'dont-kill-emacs)
    (global-set-key "\C-x\C-c" 'dont-kill-emacs))

;;(define-key jde-mode-map [M-f7]         'flymake-goto-prev-error)
;;(define-key jde-mode-map [M-f8]         'flymake-goto-next-error)
;;(define-key jde-mode-map [M-f9]        'flymake-save-as-kill-err-messages-for-current-line)
