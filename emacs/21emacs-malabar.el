(require 'cedet)
(setq semantic-default-submodes '(global-semantic-idle-scheduler-mode
                                  global-semanticdb-minor-mode
                                  global-semantic-idle-summary-mode
                                  global-semantic-mru-bookmark-mode))
;;(semantic-mode 1)

(add-to-list 'compilation-error-regexp-alist-alist
             '(maven "\\[ERROR\\] +\\(.*\\):\\[\\([0-9]+\\),\\([0-9]+\\)\\].*"
               1 2 3))
(add-to-list 'compilation-error-regexp-alist
             'maven)

;;(require 'malabar-mode)
(setq malabar-groovy-lib-dir "/home/chous/emacs/21emacs-malabar/lib")
;;(add-to-list 'auto-mode-alist '("\\.java\\'" . malabar-mode))
;;(add-hook 'malabar-mode-hook
;          (lambda () 
;            (add-hook 'after-save-hook 'malabar-compile-file-silently
;                      nil t)))

;;(load-library "/home/chous/emacs/13emacs-jde/andersl-java-font-lock.el")
;;(require 'andersl-java-font-lock)
(require 'my-maven)
(require 'compile)

(defun my-compile();; &optional comint)
  "Launches maven finding out the correct folder"
  (interactive)
  (let* ((bufferFileName (buffer-file-name))
         (childFolder (if bufferFileName  (file-truename bufferFileName) nil))
         (preamble (if childFolder (concat "cd " (find-maven-root childFolder) ";")
                       "")))
    (compile
     (concat preamble "mvn compile"))))
;;   comint))

;;(semantic-add-system-include "/home/chous/toolbox/openjdk-6-src-b22/jdk/src/share/classes/" 'malabar-mode)

;;(compile "cd /tmp; echo 1")
;; echo '' > new.txt; for f in dss-plugin-printer nlp-games messaging nlp-processes-api nlp-processes nlp-processworkflow nlp-usermanagement nlp-useraccount nlp-dss messaging nlp-messaging-manager nlp-messaging-workflow nlp-dss commons nlp-processworkflow nlp-webapp nlp-backoffice nlp-app nlp-conf nlp-creditcard nlp-creditcard-api nlp-creditcard-spi nlp-payment nlp-payment-api nlp-payment-model nlp-pricemodel primitiva-bo; do find ~/dev/ventura24/svn/${f}/trunk/src/main/java -name "*.java" -exec dirname {} \; 2> /dev/null | uniq | sort | uniq >> new.txt; find ~/dev/ventura24/svn/${f}/trunk/target/generated-sources -name '*.java' -exec dirname {} \; 2> /dev/null | uniq | sort | uniq >> new.txt; done; echo '' > ~/emacs/22emacs-semantic-folders.el; awk -vquote="'" '{printf("(semantic-add-system-include \"%s\" %smalabar-mode)\n", $0, quote);}' new.txt >> ~/emacs/22emacs-semantic-folders.el
