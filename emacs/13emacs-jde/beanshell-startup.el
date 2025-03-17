;;; beanshell-startup.el --- startup beanshell

;; $Id: beanshell-startup.el,v 1.8 2001/11/02 09:43:06 burton Exp $

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

;;; History:

;; - Sun Oct 07 2001 09:52 PM (burton@relativity.yi.org): Make sure
;; standard-output isn't to Messages so that we don't get confusing messages
;; while emacs is running.

;; - Sun Oct 07 2001 09:31 PM (burton@relativity.yi.org): make sure that the
;; window configuration isn't changed.

;; - Sun Oct 07 2001 09:31 PM (burton@relativity.yi.org): init

;;; TODO:
;;
;; - Think about adding a process sentinel for "bsh" so that if it terminates,
;; we can start it up again.
;;
;; - for some reason when I first run (jde-complete-at-point) for the first time
;;   there is a lag.  Do this in the background.
;;
;; -how do we disable (message) output???

(require 'beanshell)

(defvar beanshell-startup-initial-delay 5 "Initial delay before starting the beanshell.")

(defvar beanshell-startup-repeat-delay 60 "Seconds for repeating beanshell startup.")

;;; Code:
(defun beanshell-startup()
  "Require that the beanshell is running."
  (interactive)
  
  (save-excursion
    
    (if (not (bsh-running-p))
        (progn
          (message "Starting beanshell...")
          (bsh-internal nil)
          (message "Starting beanshell...done")))))

(run-with-timer beanshell-startup-initial-delay beanshell-startup-repeat-delay 'beanshell-startup)

(provide 'beanshell-startup)

;;; beanshell-startup.el ends here
