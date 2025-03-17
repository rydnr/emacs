;;; jde-jode.el --- jode java decompiler integration for the JDE.

;; $Id: jde-jode.el,v 1.5 2003/01/10 05:57:59 burton Exp $

;; Copyright (C) 2000-2003 Free Software Foundation, Inc.
;; Copyright (C) 2000-2003 Kevin A. Burton (burton@openprivacy.org)

;; Author: Kevin A. Burton (burton@openprivacy.org)
;; Maintainer: Kevin A. Burton (burton@openprivacy.org)
;; Location: http://relativity.yi.org
;; Keywords:
;; Version: 1.1.0

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
;; This package provides JODE ( http://jode.sourceforge.net ) decompiler support
;; for the JDE.
;;
;; It allows you to quicky decompile a class and view it in source form.  Using
;; the function jde-jode-find-class-source will prompt you for a classname and then use JODE
;; to decompile it.
;;
;; This also attempts to trick the JDE into invoking JODE so that the JDE
;; doesn't even realize that a file isn't available in source form.  This comes
;; in very handy for packages/functions that navigate using the classname.

;;; History:
;;
;; Wed Jan 02 2002 06:43 PM (burton@openprivacy.org): now using
;; jde-jode-find-class-source instead of jde-jode-open
;;
;; Wed Jan 02 2002 05:57 PM (burton@openprivacy.org): Now using a customization
;; group of jde-jode

;;; TODO:
;;
;; - consider adding the ability to decompile a .class file when you open it
;;   like decompile.el.  Also add the ability to browse a .jar and open a .class
;;   file there as well.
;; 
;;     - consider adding a hook to archive-extract-hooks that we can use to
;;       decompile a .class from an archive.
;;    
;; - include a header with a timestamp in the source file.  This way the user
;;   can now what time the file was opened.
;;
;; - note the .jar file JODE loaded this from.  Right now JODE doesn't provide
;;   this information.
;;
;; - Use the '--dest' option in Jode 1.1 so that we can output to the directory
;;   without having to snarf through the output buffer.
;;
;; - need the ability to 'always decompile' so that we can view source that was
;; directly from a .jar or your classpath.

(defcustom jde-jode-decompiler-classname "jode.decompiler.Main" "Java classname for jode."
  :type 'string
  :group 'jde-jode)

(defcustom jde-jode-temp-buffer-name "*jde-jode*"
  "Name of temp buffer to use."
  :type 'string
  :group 'jde-jode)

(defcustom jde-jode-temp-directory (concat (getenv "TEMP") "/jde-jode/")
  "Temp directory used for saving decompiled classes."
  :type 'string
  :group 'jde-jode)

(defvar jde-jode-within-advice nil "True if we are within advice.")

(defcustom jde-jode-force-decompile nil "If non-nil always decompile.  If nil we
check if a file is already decompiled, if it is then we don't do a decompile.
This could be dangerous if you have multiple class libraries in your classpath."
  :type 'boolean
  :group 'jde-jode)

(defcustom jde-jode-style "sun" "Should be 'sun' or 'gnu'.

GNU formatted code will look like:

method()
{

}

SUN formatted code will look like:

method() {

}

"
  :type 'string
  :group 'jde-jode)

(defcustom jde-jode-decompile-on-class t
  "If non-nil, we will decompile a .class file when opened."
  :type 'boolean
  :group 'jde-jode)

(defun jde-jode-decompile(classname)
  "Decompile the given classname with jode and return the file it is saved in."

  (let(filename)

    (setq filename (jde-jode-get-filename classname))

    ;;determine if we should decompile..

    (if (or jde-jode-force-decompile
            (not (file-exists-p filename)))
    
        (save-excursion

          (set-buffer (get-buffer-create jde-jode-temp-buffer-name))
          
          (erase-buffer)
          
          (message "Using JODE to decompile: %s..." classname)

          (call-process "java" nil jde-jode-temp-buffer-name nil jde-jode-decompiler-classname
                                                                 "-style"
                                                                 jde-jode-style
                                                                 classname)
          
          (message "Using JODE to decompile: %s...done" classname)
          
          (jde-jode-snarf-output filename)))
    
    filename))

(defun jde-jode-toggle-force-decompile()
  "Toggle the `jde-jode-force-decompile' variable.  If this is true decompiles
are always done.  If it is false we will only decompile if the classname doesn't
exist on disk. "
  (interactive)
  
  (if jde-jode-force-decompile
      (progn 
        (setq jde-jode-force-decompile nil)
        (message "Force decompile: off"))
    (setq jde-jode-force-decompile t)
    (message "Force decompile: on")))

(defun jde-jode-get-filename(classname)
  "Get the filename we should use to store the given classname."

    ;;now save the output from the temp buffer into the filesystem.
  
  (let(package filename directory fullpath)

    ;;get the package
    (string-match "^\\([a-z]+\\.\\)*" classname)
    (setq package (substring classname (match-beginning 0) (1- (match-end 0))))

    ;;get the classname
    (string-match "[A-Za-z]+$" classname)
    (setq filename (substring classname (match-beginning 0) (match-end 0)))
    
    (setq directory (concat jde-jode-temp-directory package))

    ;;replace all "." items in the classpath with "/"

    (while (string-match "\\." directory)
      (setq directory (replace-match "/" nil nil directory)))

    ;;make all necessary dirs..

    (make-directory directory t)
    
    (setq fullpath (concat directory "/" filename ".java"))

    fullpath))

(defun jde-jode-find-class-source(classname)
  "Decompile the given classname and open it."
  (interactive
   (list
    (jde-jode-read-classname)))

  (find-file (jde-jode-decompile classname)))

(defun jde-jode-snarf-output(filename)
  "Snarf the output from the last jode decompile into the given filename"

  (save-excursion
    (let(content found)

      (setq found t) ;; by default we assume it is found and try to prove otherwise
      
      (set-buffer jde-jode-temp-buffer-name)

      (goto-char (point-min))

      ;;make sure we actually have data...
      (save-excursion
        (if (re-search-forward "^java.io.FileNotFoundException" nil t)
            (setq found nil)))

      (if found
          (progn 
            (assert (re-search-forward "^/\\*" nil t)
                    nil "Could not find beginning of java file..")
            
            (setq content (buffer-substring (match-beginning 0)
                                            (point-max)))
            
            (set-buffer (find-file-noselect filename))
            
            (erase-buffer) ;;just incase...
            
            (insert content)
            
            (save-buffer)
            
            (goto-char (point-min)))
        (message "JODE was unable to decompile this class.")))))

(defun jde-jode-require(classname)
  "Require that the given classname is available.  If it is available as source,
don't do anything."

  (if (not (jde-find-class-source-file classname))
      (progn 
        (message "") ;; HACK to get rid of jde-find-class-source-file messages
      
        (jde-jode-decompile classname))))

(defun jde-jode-read-classname()
  "Read a classname from the minibuffer."

  (read-string "Classname: "))

(defun jde-jode-archive-hook()
  "A hook used to decompile a class when opened from a .jar file.  The
  buffer-file-name will be in the format of:

/usr/lib/java/jars/xalanj1compat.jar:org/apache/xalan/xslt/XSLTProcessorFactory.class

"
  (when jde-jode-decompile-on-class

    ))
(add-hook 'archive-extract-hooks 'jde-jode-archive-hook)

(defun jde-jode-find-file-hook()
  "A hook used to decompile a class file is opened."

  (when (and jde-jode-decompile-on-class
             (string-match "\\.class$" (buffer-file-name)))

    (message "Decompiling file %s..." (buffer-file-name))

    ;;(setq buffer-read-only t)
    
    (message "Decompiling file %s...done" (buffer-file-name))))

(add-hook 'find-file-hooks 'jde-jode-find-file-hook)

(defadvice jde-find-class-source-file(before jde-jode-find-class-source-file-require(class))
  "Decompile the given class from the classpath it if isn't in the sourcepath."

  (if (not jde-jode-within-advice)
      (progn

        (setq jde-jode-within-advice t)
        
        (jde-jode-require class)

        (setq jde-jode-within-advice nil))))
(ad-activate 'jde-find-class-source-file)
  
;;add the decompile directory to jde-db-source-directories so that it is
;;available for use within other jde packages.

(add-to-list 'jde-db-source-directories jde-jode-temp-directory)

(provide 'jde-jode)

;;; jde-jode.el ends here
