(require 'my-maven)

(defgroup findbugs nil "findbugs"
  :group 'emacs)

(defcustom findbugs-java-home "/usr/local/bin/java"
  "Java binary to run findbugs with."
  :type 'file
  :group 'findbugs )

(defcustom findbugs-home "~/findbugs"
  "Directory where findbugs is installed."
  :type 'directory
  :group 'findbugs)

(defcustom findbugs-options (list "-low")
  "A list of options when launching findbugs."
  :type '(repeat (string :tag "options"))
  :group 'findbugs)

(defcustom findbugs-append-output 'nil
  "If non-nil, append each output to the end of the *findbugs* buffer,
else clear buffer each time."
  :type 'boolean
  :group 'findbugs)

(defun findbugs-mode ()
  "Plugin for findbugs (http://findbugs.sourceforge.net).  Opens a buffer which \
displays the output of findbugs when run on the Java file in the current buffer.
Uses the standard compilation mode for navigation."

  (interactive)
  (kill-all-local-variables)
  (setq mode-name "findbugs Mode" 
   truncate-lines 
nil)
  (compilation-mode))

;;-------------------------
;;Inner workings
;;-------------------------

(defun findbugs-help ()
  "Help for `findbugs-mode'."
  (interactive)
  (describe-function 'findbugs-mode))

;;-------------------------
;; Main functions
;;-------------------------


;;;###autoload 
(defun findbugs-customize ()
  "Customization of group `findbugs' for Findbugs-mode."
  (interactive)
  (customize-group "findbugs"))

;;;###autoload 
(defun findbugs ()
  "Run findbugs on the contents of the current Maven project."
  (interactive)
  (let ((b (buffer-file-name)))
    (if b
        (findbugs-maven (find-maven-root (file-name-directory b)))
        (print "Invalid buffer"))))

(defun findbugs-classpath ()
  (let* ((path-separator (if (eq system-type 'windows-nt) ";" ":"))
         (path-slash     (if (eq system-type 'windows-nt) "\\" "/"))
         (findbugs-lib     (concat findbugs-home path-slash "lib" path-slash)))
    (mapconcat
     (lambda (path)
       path) 
     (directory-files findbugs-lib t "\\.jar$")
     path-separator)))

(defun findbugs-maven (target)
  "Run findbugs on the given Maven project"
  (let* ((path-slash     (if (eq system-type 'windows-nt) "\\" "/"))
         (cmd (concat findbugs-home path-slash "bin" path-slash
                      "findbugs -textui -emacs -sourcepath "
                      target path-slash "src" path-slash "main" path-slash "java -low "
                      target path-slash "target" path-slash "classes\n")))
    (if (eq (count-windows) 1)
        (split-window-vertically))
    (other-window 1)
    (switch-to-buffer (get-buffer-create "*findbugs*"))
    (if findbugs-append-output
        (goto-char (point-max))
        (erase-buffer))
    (findbugs-mode)
    (if buffer-read-only
        (toggle-read-only))
    (insert (concat " findbugs output for " target "\n\n"))
    (insert cmd)
    (insert (concat (shell-command-to-string cmd)))
    (insert "Done.\n")
    (goto-char (point-min))))


(provide 'findbugs)



