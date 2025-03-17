;;; emacs-start.el

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

;;(server-start)
(set-mark-command nil)
(type-break-mode nil)
(if (not (boundp 'warning-suppress-types))
    (setq warning-suppress-types nil))

;; To disable type-break-mode, such as when executing
;; macros
;(type-break-noninteractive-query)
(require-or-install 'zone)
(defconst animate-n-steps 3)
(require-or-install 'cl)
(random t)
(defun totd ()
  (interactive)
  (let*
      ((commands
        (loop for s being the symbols
              when (commandp s) collect s))
       (command (nth (random (length commands)) commands)))
    (animate-string
     (concat ";; Initialization successful, welcome to "
             (substring (emacs-version) 0 16)
             "\n"
             "Your tip for the day is:\n========================\n\n"
             (describe-function command)
             (delete-other-windows)
             "\n\nInvoke with:\n\n"
             (where-is command t)
             (delete-other-windows) 
             )0 0)))
;;(add-hook 'after-init-hook 'server-start)
;;(add-hook 'server-done-hook
;;          (lambda ()
;;            (shell-command
;;             "screen -r -X select `cat ~/tmp/emacsclient-caller`")))

(add-hook 'after-init-hook 'totd)
(if (and (getenv "STY") (not window-system))
       (global-unset-key "\C-z"))
