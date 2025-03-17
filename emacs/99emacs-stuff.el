;;; 02emacs-mystuff.el

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
(defun other-window-back ()
  "Goes back to previous window"
  (interactive)
  (other-window -1))

(defun my-insert-macro-counter ()
  "Inserts the value of my-macro-counter in the buffer"
  (interactive)
  (insert (number-to-string my-macro-counter)))

(defun my-macro-counter ()
  "Increases the value of my-macro-counter by 1 and inserts it in the buffer"
  (interactive)
  (setq my-macro-counter (+ my-macro-counter 1))
  (my-insert-macro-counter))

(setq my-macro-counter 0)

(defun find-tags-files (base-dir)
  "Finds the TAGS files in given directory."
  (interactive "DDirectory name: ")
  (let (tags-list
        (current-directory-list
         (directory-files-and-attributes
          base-dir nil '"^TAGS-*")))
    (while current-directory-list
      (let ((current-item (car (car current-directory-list))))
        (setq
         tags-list (cons current-item tags-list)))
      (setq current-directory-list (cdr current-directory-list)))
    tags-list))

(defun visit-my-tags-files ()
  "Visits my TAGS files."
  (interactive)
  (let*
      ((tags-dir
        (if (equal "/" (substring my-tags-dir -1))
            (my-tags-dir)
          (concat my-tags-dir "/")))
       (tags-files (find-tags-files tags-dir)))
    (while tags-files
      (let
          ((current-tags-file
            (concat tags-dir (car tags-files))))
        (progn
          (unwind-protect
              (visit-tags-table current-tags-file))
          (setq tags-files (cdr tags-files)))))
    tags-files))

(defun complete-classpath (base-dir)
  "Finds all jar files belonging to given directory."
  (interactive "DDirectory name: ")
  (if (not (null base-dir))
      (let (result
            (current-directory-list
             (directory-files-and-attributes base-dir t)))
        (while current-directory-list
          (let ((current-item (car (car current-directory-list))))
            (if (equal ".jar" (substring current-item -4))
                (setq result (cons current-item result))
              (if (and
                   (not (equal "/." (substring current-item -2)))
                   (not (equal "/.." (substring current-item -3)))
                   (eq t (car (cdr (car current-directory-list)))))
                (let ((aux (complete-classpath current-item)))
                  (if (not (null aux))
                      (append result aux))))))
        (setq current-directory-list (cdr current-directory-list)))
        result)))

;;(complete-classpath '"/home/chous/dev/acmsl/svn/queryj/branches/br-0_6--ventura24-1_9-synchr/dependencies/lib/java")

(defun find-project-basedir (base-dir)
  (let ((aux
         (jde-find-project-files 
          (expand-file-name "." base-dir))))
    (if (not (null aux))
        (file-name-directory (car aux))
      (nil))))

;;(find-project-basedir '"/home/chous/dev/acmsl/svn/queryj/branches/br-0_6--ventura24-1_9-synchr/dependencies/lib/java")

(defun complete-sourcepath (base-dir)
  "Finds all source paths belonging to given directory."
  (interactive "DDirectory name: ")
  (progn
  (if (not (null base-dir))
      (let ((result (list base-dir))
            (current-directory-list
             (directory-files-and-attributes base-dir t)))
        (message "current-result: %s" result)
        (while current-directory-list
          (let ((current-item (car (car current-directory-list))))
;;            (message "current-item: %s" current-item)
            (if (and
                 (= (length (split-string current-item "/CVS")) 1)
                 (= (length (split-string current-item "/.svn")) 1)
                 (not (equal "/." (substring current-item -2)))
                 (not (equal "/.." (substring current-item -3)))
                 (eq t (car (cdr (car current-directory-list)))))
                (progn
                  (setq result (adjoin current-item result))
                  (let ((aux (complete-sourcepath current-item)))
                    (if (not (null aux))
                        (setq result (union result aux)))))))
          (setq
           current-directory-list
           (cdr current-directory-list)))
          result))))

;;(complete-sourcepath '"/home/chous/dev/acmsl/svn/queryj/branches/br-0_6--ventura24-1_9-synchr/src/main/java/org/acmsl/queryj/tools/metadata/engines")

(defun dont-kill-emacs ()
  (interactive)
  (error (substitute-command-keys "To exit emacs: \\[kill-emacs]")))
