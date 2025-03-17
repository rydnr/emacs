;; Edit this
(defconst css-validator "java -jar ~/emacs/20emacs-cssflymake/css-validator.jar")

(defun flymake-css-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list css-validator (list "-output gnu" (concat "file:" local-file)))))

(require 'flymake)
(push '(".+\\.css$" flymake-css-init) flymake-allowed-file-name-masks)

(push '("^file:\\([^:]+\\):\\([^:]+\\):\\(.*\\)" 1 2 nil 3) flymake-err-line-patterns)
