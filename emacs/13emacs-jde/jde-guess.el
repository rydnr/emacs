;;; jde-guess.el --- guess information about java buffers.

;; $Id: jde-guess.el,v 1.12 2003/01/10 05:57:59 burton Exp $

;; Copyright (C) 1997-2000 Free Software Foundation, Inc.

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

;;; TODO:

;; - By default all functions should be silent.  If we what to display
;;   information we should call -show.  If we want then fixed we should call -fix
;;   or -setup functions.
;; 
;; - this package should also function as a library.  Most methods would take
;;   parameters.
;;
;; - test all these functions with .java files that have no package.
;;
;; - classname guessing doesn't work with "public abstract class"

;;; History:

;;; Code:
(defvar jde-guess-package-buffer "*jde-guess-package-buffer*"
  "Temp buffer for guessing.")

(defvar jde-guess-imports '() "Additional imports required for .java files.
Should be a list of packages classes (import qualifiers) to import.  Example:
java.util.* java.lang.String")

(defun jde-guess-base-directory()
  "Guess the base directory of a java file based on its package.  Example.  If a
file were stored in '/home/foo/projects/java/lang/String.java' the package would
be removed and this would return '/home/foo/projects'."
   
  (assert (equal major-mode
                 'jde-mode) nil "Not a java buffer.")

  (save-excursion
    (let((directory nil)
         (package nil)
         (package-path nil)
         (java-file (buffer-file-name)))

      (setq package (jde-guess-package))
      
      (set-buffer (get-buffer-create jde-guess-package-buffer))
      (erase-buffer)

      ;;get the path section as the package...
      (insert package)
      (goto-char (point-min))
      (jde-guess-replace-string "."  "/")
      (setq package-path (buffer-substring (point-min) (point-max)))

      (erase-buffer)
      (insert java-file)
      (jde-guess-replace-string ".java" "")
      (goto-char (point-max))
      (if (search-backward package-path)
          (replace-match ""))
      (jde-guess-replace-string (concat "/" (file-name-nondirectory java-file)) "")

      (setq directory (buffer-substring (point-min) (point-max)))
      
      directory)))
  
(defun jde-guess-packages(directory &optional root)
  "Given a directory, go through all sub-directories and find packages.  The
given directory is assumed to be the based for the packages."

  ;;directory should always be expanded so that we have a trailing slash
  (if (not (string-match "[/.]$" directory))
      (setq directory (concat directory "/")))

  (if (null root)
      (setq root directory))
  
  (let((packages '())
       new-package
       current-file
       files
       (still-need-package t)
       (index 0))

    (setq files (directory-files directory t))

    (while (< index (length files))
      (setq current-file (elt files index))

      ;;figure out what to do based on the filename

      ;;ignore certain directories

      (if (and (not (string-match "CVS$" directory))
               (not (string-match "\\.$" directory))
               (not (string-match "\\.\\.$" directory)))
          (progn
            
            ;;if it is a directory... dive into it.
            (if (and (file-directory-p current-file)
                     (not (string-equal directory current-file)))
                (let(next-level-packages)

                  (setq next-level-packages (jde-guess-packages current-file
                                                                root))

                  (setq packages (append packages next-level-packages))))
      
            (if (and still-need-package
                     (string-match "\\.java$" current-file))
                (progn

                  (set-buffer (get-buffer-create jde-guess-package-buffer))
                  (erase-buffer)
                  (insert current-file)
                  (goto-char (point-min))
                  (jde-guess-replace-string root "")
                  (jde-guess-replace-string (concat "/" (file-name-nondirectory current-file)) "")
                  (goto-char (point-min))
                  (jde-guess-replace-string "/" ".")
            
                  (setq new-package (buffer-substring (point-min) (point-max)))

                  (setq still-need-package nil)
                  (add-to-list 'packages new-package)))))
      (setq index (1+ index)))
    packages))

(defun jde-guess-setup-class-or-interface()
  "Setup the java class or interface correctly."
  (interactive)
  
  (save-excursion
    (goto-char (point-min))

    (let(class old-class)

      (setq class (jde-guess-class))

      (if (re-search-forward "^public.*\\(class\\|interface\\) " nil t)
          (progn
            
            ;;now replace find the class.
            (re-search-forward "[a-zA-Z0-9]+" nil t)

            (setq old-class (match-string 0))
            
            (replace-match class))
        (error "Unable to find class or interface"))

      (query-replace old-class class))))

(defun jde-guess-setup-import()
  "Setup java class imports...  Require that java.util.*, java.net.* and
java.io.* are imported and then sort the imports."
  (interactive)

  ;;FIXME: make sure there is at least one line before and after the imports.
  
  (assert (equal major-mode
                 'jde-mode) nil "Not a java buffer.")

  (if jde-guess-imports
      (let((import nil)
           (index 0))
        (assert (listp jde-guess-imports)
                nil "jde-guess-imports must be a list.")

        (while (< index (length jde-guess-imports))

          (setq import (elt jde-guess-imports index))

          (jde-guess-import-require-import import)
          
          (setq index (1+ index)))))

  (jde-guess-import-require-import "java.util.*")
  (jde-guess-import-require-import "java.io.*")
  (jde-guess-import-require-import "java.net.*")
  
  ;;now sort the imports
  (jde-import-sort))

(defun jde-guess-import-require-import( target )
  "Require that the given target is imported within this java class."

  (assert (equal major-mode
                 'jde-mode) nil "Not a java buffer.")
  
  (save-excursion
    (let(class-begin import-begin)
      (goto-char (point-min))

      (save-excursion
        (if (re-search-forward "^import" nil t)
            (setq import-begin (match-beginning 0)))

        ;;is no imports... to find the package and use the next line.
        (if (and (null import-begin)
                 (re-search-forward "^package" nil t))
            (progn
              (forward-line 2)
              (setq import-begin (point))))

        ;;find the class or interface
        (if (re-search-forward "^public \\(class\\|interface\\)" nil t)
            (setq class-begin (match-beginning 0)))
        
        (assert import-begin
                nil "Could not find import statement")

        (assert class-begin
                nil "Could not find class statement"))

        (if (not (re-search-forward (concat "^import " target ) class-begin t))
            (progn
              ;;insert this required class
              (goto-char import-begin)
              (insert (concat "import " target ";\n")))))))

(defun jde-guess-setup-buffer()
  "Guess certain values about the current buffer and update it so that it is
correct. This will correct import statements by calling `jde-guess-import-setup'
and will also update the classname.  It will also setup the correct package."
  (interactive)

  (if (= (buffer-size) 0)
      (insert "package UNKNOWN;\n\nimport java.util.*;\n\n public class UNKNOWN { "))
  
  ;;fix imports.
  (jde-guess-setup-import)

  ;;fix the package statement
  (jde-guess-setup-package)
  
  ;;fix the public class declaration
  (jde-guess-setup-class-interface))

(defun jde-guess-setup-package()
  "Find the correct package (if possible) and then update the 'package'
statement."
  (interactive)

  (let (real-package)
    (setq real-package (jde-guess-package))

    (save-excursion
      (goto-char (point-min))
      (if (re-search-forward "^package .*$" nil t)
          (replace-match (concat (format "package %s;" real-package)))
        (error "Package declaration not found")))))

(defun jde-guess-package-incorrect()
  "Determine if the 'package' statement in this .java buffer is incorrect."
  (interactive)
  
  (assert (equal major-mode 'jde-mode) nil "Must be run from jde-mode")

  (let(default-package real-package)

    (setq default-package (jde-guess-current-package))

    (setq real-package (jde-guess-package))

    (if (not (string-equal default-package
                           real-package))
        (error "The package declaration in this buffer is incorrect, it should be: %s" real-package))))

(defun jde-guess-current-package()
  "Get the current package or nil if there is no package statement.  This just
looks for the 'package NAME;' statement in the current buffer and just parses
that."

  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward "^package " nil t)
        (let(begin end package)
          (setq begin (match-end 0))

          (if (re-search-forward ";$"nil t)
              (setq end (match-beginning 0)))

          (assert (and begin end) nil "Unable to determine begin and end of package")

          (setq package (buffer-substring begin end))

         package)
      (message "No package found")
      nil)))
  
(defun jde-guess-package()
  "This should try to determine the package based on the filename and
java sourcepath."
  (interactive)

  (assert (equal major-mode 'jde-mode) nil "Must be run from jde-mode")
  
  (save-excursion
      (let((package-name nil)
           (classname nil))
        (setq package-name (jde-guess-classname))

        (assert package-name
                nil "Unable to determine package name.")
        
        (set-buffer (get-buffer-create jde-guess-package-buffer))
        (erase-buffer)
        (insert package-name)
        (goto-char (point-min))
        (goto-char (point-at-eol))
        (search-backward ".")
        (setq package-name (buffer-substring (point-min) (point)))
        (message "Package: %s" package-name)
        package-name)))

(defun jde-guess-class()
  "This should try to determine the class based on the filename."
  (interactive)

  (assert (equal major-mode 'jde-mode)
          nil "Must be run from jde-mode")

  (save-excursion
    (let((class (buffer-file-name)))

      (setq class (file-name-nondirectory class))

      (if (string-match "\\(.*\\)\\.java$" class)
          (setq class (match-string 1 class))
        (setq class nil))

      class)))

(defun jde-guess-classname()
  "This should try to determine the fully qualified classname (FQCN) based on
the filename and the java sourcepath."
  (interactive)

  (let((sourcepath jde-db-source-directories))

    (assert (and sourcepath (listp sourcepath))
            nil "sourcepath must have a value and should be a list")

    (assert (equal major-mode 'jde-mode) nil "Must be run from jde-mode")

    (save-excursion
      (let((match nil)
           (classname nil)
           (current-directory nil)
           (index 0)
           (found nil)
           (file-name (file-truename (buffer-file-name))))

        (while (and (not found)
                    (< index (length sourcepath)))
                  
          (setq current-directory (file-truename  (elt sourcepath index)))

          (setq match (string-match current-directory file-name))

          (if (and match
                   (= match 0))
              (progn
                ;;mark as found
                (setq found t)

                ;;rip the directory off, rip .java off and replace all "/" chars
                ;;with "."
                (set-buffer (get-buffer-create jde-guess-package-buffer))
                (erase-buffer)
                (insert file-name)
                (goto-char (point-min))
                ;;add a trailing / to the dir just in case.
                (jde-guess-replace-string (concat current-directory "/" ) "")
                (jde-guess-replace-string current-directory "")
                (goto-char (point-min))
                (jde-guess-replace-string ".java" "")
                (goto-char (point-min))
                (jde-guess-replace-string "/" ".")
                (setq classname (buffer-substring (point-min) (point-max)))))

          (setq index (1+ index)))

        (assert found
                nil "Unable to find the filename within the current sourcepath")
        
        (message "Classname: %s" classname)
        classname))))

(defun jde-guess-replace-string(from-string to-string)
  "Replace strings"
  
  (while (search-forward from-string nil t)
    (replace-match to-string)))

(defun jde-guess-root-package-directories(directory &optional directory-list)
  "Given a project directory, find all source java directories it contains."

  (let((files nil)
       (current-file nil)
       (current-file-path nil)
       (i 0))

    ;;strip the trailing / of the given directory

    (if (string-match "/$" directory)
        (setq directory (substring directory 0 (1- (length directory)))))
    
    (setq files (directory-files directory))

    (while (< i (length files))

      (setq current-file (elt files i))

      (setq current-file-path (concat directory "/" current-file))
      
      (if (and (not (string-equal current-file "."))
               (not (string-equal current-file "..")))
          (progn

            ;;see if this is a java directory...
            (if (or (string-equal current-file "org")
                    (string-equal current-file "net")
                    (string-equal current-file "com"))
                (progn
                  ;;cool.  This looks like a java root directory.

                  (add-to-list 'directory-list directory))
              
              ;;else, see if we need to keep moving..
              (if (file-directory-p current-file-path)
                  (setq directory-list (jde-guess-root-package-directories current-file-path directory-list))))))
      
      (setq i (1+ i))))

  directory-list)

(provide 'jde-guess)

;;; jde-guess.el ends here
