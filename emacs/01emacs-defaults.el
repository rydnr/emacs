;;;  01emacs-defaults.el

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
;; Set the debug option to enable a backtrace when a
;; problem occurs.
(setq debug-on-error t)

;; Are we running XEmacs or Emacs?
(defvar running-xemacs (string-match "XEmacs\\|Lucid" emacs-version))

;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)
;;(normal-erase-is-backspace-mode 1)
(global-set-key "\?" 'help-command)
;;(global-set-key  "?\C-h" 'delete-backward-char)
;;(keyboard-translate ?\C-h ?\C-?)
;;(keyboard-translate ?\C-? ?\C-h)
;;(keyboard-translate ?\M-h ?\C-h)
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(global-set-key [insertchar] 'overwrite-mode)

;; Turn on font-lock mode for Emacs
(cond ((not running-xemacs)
    (global-font-lock-mode t)
))

;; mouse wheel support
;; (require-or-install 'mwheel)
;; (mwheel-install)
;;(setq mouse-wheel t)

;; Always end a file with a newline
(setq require-final-newline t)

;; Stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)

(normal-erase-is-backspace-mode)
