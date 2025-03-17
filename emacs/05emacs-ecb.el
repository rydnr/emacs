;;; 05emacs-ecb.el

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

(defun find-ecb-source-paths (base-dirs)
  "Finds the ECB sources in given directories."
  (let (result)
    (while base-dirs
      (let ((aux
            (find-ecb-children-source-paths
             (car base-dirs))))
        (if (null result)
            (setq result aux)
          (setq result (append result aux))))
      (setq base-dirs (cdr base-dirs)))
    result))

(defun find-ecb-children-source-paths (base-dir)
  "Finds the ECB sources in given directory."
  (interactive "DDirectory name: ")
  (let (ecb-sources-list
        (current-directory-list
         (directory-files-and-attributes base-dir t)))
    (while current-directory-list
      (let ((current-item (car (car current-directory-list))))
        (if
            (and
             (not
              (or
               (equal "_" (substring current-item -1))
               (equal ".bak" (substring current-item -4))
               (equal "/." (substring current-item -2))
               (equal "/.." (substring current-item -3))))
             (eq t (car (cdr (car current-directory-list)))))
            (setq
             ecb-sources-list (cons current-item ecb-sources-list))))
      (setq current-directory-list (cdr current-directory-list)))
    ecb-sources-list))

(require-or-install 'eieio)
(require-or-install 'ede)
(require-or-install 'semantic)
(require-or-install 'cogre)

(require-or-install 'speedbar)
(global-set-key [(f4)] 'speedbar-get-focus)
   ;; Texinfo fancy chapter tags
(add-hook 'texinfo-mode-hook (lambda () (require 'sb-texinfo)))
   ;; HTML fancy chapter tags
   (add-hook 'html-mode-hook (lambda () (require 'sb-html)))

(require-or-install 'srecode)
(require-or-install 'cedet)
(global-ede-mode 1)
(semantic-load-enable-gaudy-code-helpers)
(semantic-load-enable-all-exuberent-ctags-support)
(global-srecode-minor-mode 1)
(require-or-install 'ecb)

;;(setq ecb-source-path (append (find-ecb-source-paths my-ecb-source-paths) ecb-source-path))

;;(ecb-activate)
