;    
;     File:   safe-load.el  (939 bytes) 
;     Date:   Tue Dec  1 09:26:25 1992
;     Author: Lawrence Buja <ccmproc2@sunny>
;    
(defvar safe-load-error-list ""
        "*List of files that reported errors when loaded via safe-load")

(defun locate-file-recursively (base-dir file)
  "Finds out where given file is."
  (interactive "DDirectory name: FFile name:")
  (if (not (or (null base-dir)
           (null file)))
      (let (result
        (current-directory-list
             (directory-files-and-attributes base-dir t)))
        (while (and
        (not (null current-directory-list))
        (null result))
          (let ((current-item (car (car current-directory-list)))
        (dir-flag (car (cdr (car current-directory-list)))))
            (progn
            (if (and
         (string-match
          (concat (concat ".*/" file) "$") current-item)
                 (null dir-flag))
                (progn
          (setq result current-item))
          (if (and
           (eq t dir-flag)
           (not (string-match ".*/\\." current-item))
           (not (string-match ".*/\\.." current-item)))
              (setq result (locate-file-recursively current-item file))))))
          (setq current-directory-list (cdr current-directory-list)))
        result)))

(defun safe-load (file &optional noerror nomessage nosuffix)
  "Load a file.  If error when loading, report back, wait for
   a key stroke then continue on"
  (interactive "f")
  (condition-case nil (load file noerror nomessage nosuffix) 
    (error 
      (progn 
       (setq safe-load-error-list  (concat safe-load-error-list  " " file))
       (message "****** [Return to continue] Error loading %s" safe-load-error-list )
        (sleep-for 1)
       nil))))

(defun safe-load-check ()
 "Check for any previous safe-load loading errors.  (safe-load.el)"
  (interactive)
  (if (string-equal safe-load-error-list "") () 
               (message (concat "****** error loading: " safe-load-error-list))))

;;; Finds all init files
(defun find-emacs-init-files (base-dir)
  "Finds the Emacs init files in given directory."
  (interactive "DDirectory name: ")
  (let (init-file-list
        (current-directory-list
         (directory-files-and-attributes
          base-dir nil '"^[0-9]\\{2\\}emacs-.*\\.el$")))
    (while current-directory-list
      (let ((current-item (car (car current-directory-list))))
        (setq
         init-file-list (cons current-item init-file-list)))
      (setq current-directory-list (cdr current-directory-list)))
    (sort init-file-list #'string<)))

;;(find-emacs-init-files my-emacs-init-dir)

;;(file-directory-p "/home/chous/emacs/04emacs-dired")
;;(directory-files-and-attributes "/home/chous/emacs" nil "04emacs-dired")
;;(get-init-file-subfolder "04emacs-dired.el" "/home/chous/emacs")
(defun get-init-file-subfolder (init-file base-dir)
  "Finds the subfolder for a given Emacs init file"
  (interactive "IInit file: ")
  (let ((subfolder (concat base-dir "/" (replace-regexp-in-string "\\(.*\\)\\(.el\\)" "" init-file nil nil 2))))
    (if (file-directory-p subfolder)
        subfolder
        nil)))
;; safe-loads all init files
(defun safe-load-emacs-init-files (base-dir)
  "Loads safely all Emacs init files in given directory."
  (interactive "DDirectory name: ")
  (let ((init-file-list
        (find-emacs-init-files base-dir)))
    (while init-file-list
      (let* ((current-item (car init-file-list))
             (current-item-subfolder (get-init-file-subfolder current-item base-dir)))
;;        (when current-item-subfolder
;;            (message "(safe-load-emacs-init-files '\"%s\")" current-item-subfolder)
;;            (safe-load-el-files current-item-subfolder))
        (message "(safe-load '\"%s\")" current-item)
        (safe-load current-item)
      (setq init-file-list (cdr init-file-list))))
    nil))

(defun safe-load-el-files (base-dir)
  "Loads safely all Emacs init files in given directory."
  (interactive "DDirectory name: ")
  (let ((init-file-list
        (find-el-files base-dir)))
    (while init-file-list
      (let* ((current-item (car init-file-list))
             (current-item-subfolder (get-init-file-subfolder current-item base-dir)))
        (when current-item-subfolder
            (message "(safe-load-el-files '\"%s\")" current-item-subfolder)
            (safe-load-el-files current-item-subfolder))
        (message "(safe-load '\"%s\")" current-item)
        (safe-load current-item)
      (setq init-file-list (cdr init-file-list))))
    nil))

(require 'cl)

(defun find-el-files (base-dir)
  "Finds all Emacs Lisp files in given directory."
  (interactive "DDirectory name: ")
  (if (not (null base-dir))
      (let (result
            (current-directory-list
             (directory-files-and-attributes base-dir t)))
        (while current-directory-list
          (let ((current-item (car (car current-directory-list))))
;;            (message "%s" (null (string-match "/\.\#.*\.el$" current-item)))
            (if (and
                 (equal ".el" (substring current-item -3))
                 (null (string-match "/\.\#.*\.el$" current-item))
                 (null
                     (car 
                      (cdr 
                       (car
                        current-directory-list)))))
                (setq result (adjoin current-item result))))
          (setq current-directory-list (cdr current-directory-list)))
        (sort result 'string<))))

(defun byte-compile-el-files (base-dir)
  "Byte-compiles all Emacs Lisp files in given directory."
  (interactive "DDirectory name: ")
  (if (not (null base-dir))
      (let ((files (find-el-files base-dir)))
        (while files
          (let* ((current-file (car files))
                 (compiled-file
                  (directory-files-and-attributes
                   base-dir
                   t
                   (concat
                    (replace-regexp-in-string
                     ".*/"
                     ""
                     current-file)
                    "c"))))
            (if (null compiled-file)
                (progn
;;                  (message
;;                   "Byte-compiling %s since %s does not exist"
;;                   current-file
;;                   (concat current-file "c"))
                  (byte-compile-file current-file)))
            (setq files (cdr files)))))))

(defun build-loadpath (base-dir)
  "Finds all child paths to given directory."
  (interactive "DDirectory name: ")
  (if (not (null base-dir))
      (let (result
            (current-directory-list
             (directory-files-and-attributes base-dir t)))
        (while current-directory-list
          (let ((current-item (car (car current-directory-list))))
            (if (and
                 (not (equal "/." (substring current-item -2)))
                 (not (equal "/.." (substring current-item -3)))
                 (not (equal "/.svn" (substring current-item -5)))
                 (not (equal "/.git" (substring current-item -5)))
                 (not (equal "/.jde" (substring current-item -5)))
                 (not (equal "/CVS" (substring current-item -4)))
                 (eq t (car (cdr (car current-directory-list)))))
                (progn
                  (setq result (adjoin current-item result))
                  (let ((aux (build-loadpath current-item)))
                    (if (not (null aux))
                        (setq result (union result aux)))))))
          (setq current-directory-list (cdr current-directory-list)))
        result)))

(defun complete-loadpath (base-dir)
  "Adds all child paths to the load-path."
  (interactive "DDirectory name: ")
  (if (not (null base-dir))
      (let ((current-directory-list
             (build-loadpath base-dir)))
        (while current-directory-list
          (let ((current-item (car current-directory-list)))
            (message "Adding %s" current-item)
            (add-to-list 'load-path current-item t))
          (setq current-directory-list (cdr current-directory-list))))))

;;(complete-loadpath "/home/chous/emacs")
(defun byte-compile-loadpath ()
  "Adds all child paths to the load-path."
  (interactive "DDirectory name: ")
  (let ((current-directory-list load-path))
    (while current-directory-list
      (let ((current-item (car current-directory-list)))
;;        (message "Adding %s" current-item))
;;        (byte-recompile-directory current-item))
        (byte-compile-el-files current-item))
      (setq
       current-directory-list
       (cdr current-directory-list)))))

(defun autocompile ()
     "compile itself if ~/.emacs or ~/emacs/.emacs*"
     (interactive)
     (require-or-install 'bytecomp)
     (if (or
          (string= (buffer-file-name) (expand-file-name "~/.emacs"))
          (string= (buffer-file-name) (expand-file-name (concat my-emacs-init-dir "/.emacs")))
          (string-match (expand-file-name (concat my-emacs-init-dir "/.*\.el$")) (buffer-file-name))
          (string-match '".*/prj\.el$" (buffer-file-name)))
         (byte-compile-file (buffer-file-name))))

;; make sure the require-or-install is available.
(add-to-list 'load-path (concat my-emacs-init-dir "/misc") t)
(require 'require-or-install)
