(defun find-maven-root (file)
  "Retrieves the maven root folder"
  (interactive)
  (if (is-maven-root file)
      file
      (if (string-equal file "/")
          nil
          (find-maven-root
           (find-parent-folder file)))))

(defun find-parent-folder (file)
  "Retrieves the parent folder"
  (interactive)
  (let* ((path-slash (if (eq system-type 'windows-nt) "\\" "/"))
         (file-name
          (if (string-match "\\(.*\\)/$" file)
              (match-string 1 file)
              file)))
    (file-name-directory (file-truename file-name))))


(defun is-maven-root (file)
  "Checks whether given folder is a maven root folder"
  (interactive)
  (let* ((path-slash (if (eq system-type 'windows-nt) "\\" "/"))
         (src-main-java
          (concat file path-slash "src" path-slash "main" path-slash "java"))
         (target-classes (concat file path-slash "target" path-slash "classes")))
    (and (file-directory-p file)
         (file-exists-p src-main-java)
         (file-directory-p src-main-java)
         (file-exists-p target-classes)
         (file-directory-p target-classes))))

(provide 'my-maven)
