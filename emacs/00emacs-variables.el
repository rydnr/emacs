;;; 00emacs-variables.el.sample

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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-byte-compile t)
 '(TeX-command-list (quote (("TeX" "%(PDF)%(tex) %`%S%(PDFout)%(mode)%' %t" TeX-run-TeX nil (plain-tex-mode texinfo-mode ams-tex-mode) :help "Run plain TeX") ("LaTeX" "%`%l%(mode)%' %t" TeX-run-TeX nil (latex-mode doctex-mode) :help "Run LaTeX") ("Makeinfo" "makeinfo %t" TeX-run-compile nil (texinfo-mode) :help "Run Makeinfo with Info output") ("Makeinfo HTML" "makeinfo --html %t" TeX-run-compile nil (texinfo-mode) :help "Run Makeinfo with HTML output") ("AmSTeX" "%(PDF)amstex %`%S%(PDFout)%(mode)%' %t" TeX-run-TeX nil (ams-tex-mode) :help "Run AMSTeX") ("ConTeXt" "texexec --once --texutil %(execopts)%t" TeX-run-TeX nil (context-mode) :help "Run ConTeXt once") ("ConTeXt Full" "texexec %(execopts)%t" TeX-run-TeX nil (context-mode) :help "Run ConTeXt until completion") ("BibTeX" "bibtex %s" TeX-run-BibTeX nil t :help "Run BibTeX") ("View" "latexmk -pvc %t" TeX-run-discard t t :help "Run Viewer") ("Print" "%p" TeX-run-command t t :help "Print the file") ("Queue" "%q" TeX-run-background nil t :help "View the printer queue" :visible TeX-queue-command) ("File" "%(o?)dvips %d -o %f " TeX-run-command t t :help "Generate PostScript file") ("Index" "makeindex %s" TeX-run-command nil t :help "Create index file") ("Check" "lacheck %s" TeX-run-compile nil (latex-mode) :help "Check LaTeX file for correctness") ("Spell" "(TeX-ispell-document \"\")" TeX-run-function nil t :help "Spell-check the document") ("Clean" "TeX-clean" TeX-run-function nil t :help "Delete generated intermediate files") ("Clean All" "(TeX-clean t)" TeX-run-function nil t :help "Delete generated intermediate and output files") ("Other" "" TeX-run-command t t :help "Run an arbitrary command"))))
 '(auto-coding-alist (quote (("\\.\\(arc\\|zip\\|lzh\\|zoo\\|jar\\|tar\\|tgz\\|war\\|cache\\)\\'" . no-conversion) ("\\.\\(gz\\|Z\\|bz\\|bz2\\|gpg\\)\\'" . no-conversion))))
 '(auto-compression-mode t nil (jka-compr))
 '(auto-save-default nil)
 '(backup-directory-alist (quote (("*" . "~/.emacs-backups"))))
 '(browse-url-browser-function (quote browse-url-firefox))
 '(browse-url-generic-program "konqueror")
 '(browse-url-netscape-program "firefox")
 '(bsh-jar "/home/chous/.m2/repository/bsh/bsh/2.0b2/bsh-2.0b2.jar")
 '(c-default-style (quote ((c-mode . "") (c++-mode . "") (objc-mode . "") (java-mode . "java") (idl-mode . "") (pike-mode . "") (other . "gnu"))))
 '(calendar-week-start-day 1)
 '(case-fold-search t)
 '(chess-default-engine (quote (chess-gnuchess chess-crafty chess-phalanx)))
 '(color-theme-is-cumulative t)
 '(compilation-scroll-output t)
 '(compile-command "mvn install")
 '(current-language-environment "UTF-8")
 '(default-input-method "UTF8")
 '(delete-selection-mode nil)
 '(dired-omit-files "^\\.?#\\|^\\.$\\|^\\.\\.$\\|^\\..*$")
 '(dired-recursive-deletes (quote top))
 '(ecb-add-path-for-not-matching-files (quote (nil)))
 '(ecb-auto-activate t)
 '(ecb-compilation-buffer-names (quote (("*PMD*") ("*findbugs*") ("*Malabar Compilation*") ("*Malabar Compile Server*") ("*compilation*") ("*Calculator*") ("*vc*") ("*vc-diff*") ("*Apropos*") ("*Occur*") ("*e?shell*" . t) ("\\*[cC]ompilation.*\\*" . t) ("\\*i?grep.*\\*" . t) ("*JDEE Compile Server*") ("*Help*") ("*Completions*") ("*Backtrace*") ("*Compile-log*") ("*bsh*") ("*Messages*"))))
 '(ecb-compile-window-height 6)
 '(ecb-compile-window-temporally-enlarge (quote both))
 '(ecb-directories-menu-user-extension-function (quote ignore))
 '(ecb-enlarged-compilation-window-max-height (quote half))
 '(ecb-history-menu-user-extension-function (quote ignore))
 '(ecb-layout-name "leftright1")
 '(ecb-layout-window-sizes (quote (("leftright1" (0.22435897435897437 . 0.390625) (0.22435897435897437 . 0.296875) (0.22435897435897437 . 0.296875) (0.23717948717948717 . 0.984375)))))
 '(ecb-methods-menu-user-extension-function (quote ignore))
 '(ecb-options-version "2.40")
 '(ecb-source-file-regexps (quote ((".*" ("\\(^\\(\\.\\|#\\)\\|\\(~$\\|\\.\\(elc\\|obj\\|o\\|class\\|lib\\|dll\\|a\\|so\\|cache|bak\\)$\\)\\)") ("^\\.\\(emacs\\|gnus\\)$" "^\\.\\(java\\|groovy\\|stg\\|properties\\|xml\\|lisp\\|el\\)$")))))
 '(ecb-source-path (quote (("/home/chous/dev/acmsl/git/queryj" "queryj") ("/home/chous/dev/acmsl/git/commons" "acmsl-commons") ("/home/chous/dev/ventura24/svn/nlp-webapp/trunk" "nlp-webapp") ("/home/chous/dev/ventura24/svn/nlp-games/trunk" "nlp-games") ("/home/chous/dev/ventura24/svn/commons/trunk" "v24-commons") ("/home/chous/dev/ventura24/svn/nlp-usermanagement/trunk" "nlp-um") ("/home/chous/dev/ventura24/svn/nlp-processes-api/trunk" "nlp-processesapi") ("/home/chous/dev/ventura24/svn/nlp-processes/trunk" "nlp-processes"))))
 '(ecb-sources-menu-user-extension-function (quote ignore))
 '(ecb-tip-of-the-day nil)
 '(ecb-tree-indent 2)
 '(ecb-vc-enable-support t)
 '(face-font-family-alternatives (quote (("andale mono" "courier" "fixed") ("helv" "helvetica" "arial" "fixed"))))
 '(file-coding-system-alist (quote (("\\.xml\\'" . utf-8) ("\\.dz\\'" no-conversion . no-conversion) ("\\.g?z\\(~\\|\\.~[0-9]+~\\)?\\'" no-conversion . no-conversion) ("\\.tgz\\'" no-conversion . no-conversion) ("\\.tbz\\'" no-conversion . no-conversion) ("\\.bz2\\'" no-conversion . no-conversion) ("\\.Z\\(~\\|\\.~[0-9]+~\\)?\\'" no-conversion . no-conversion) ("\\.elc\\'" emacs-mule . emacs-mule) ("\\.utf\\(-8\\)?\\'" . utf-8) ("\\(\\`\\|/\\)loaddefs.el\\'" raw-text . raw-text-unix) ("\\.tar\\'" no-conversion . no-conversion) ("" undecided))))
 '(findbugs-home "/home/chous/toolbox/findbugs")
 '(findbugs-java-home "/home/chous/.gentoo/java-config-2/current-user-vm")
 '(flymake-allowed-file-name-masks (quote ((".+\\.java$" flymake-jde-jikes-java-init flymake-simple-java-cleanup flymake-get-real-file-name) (".+\\.c$" flymake-simple-make-init flymake-simple-cleanup flymake-get-real-file-name) (".+\\.cpp$" flymake-simple-make-init flymake-simple-cleanup flymake-get-real-file-name) (".+\\.cs$" flymake-simple-make-init flymake-simple-cleanup flymake-get-real-file-name) (".+\\.pl$" flymake-perl-init flymake-simple-cleanup flymake-get-real-file-name) (".+\\.h$" flymake-master-make-header-init flymake-master-cleanup flymake-get-real-file-name) (".+\\.java$" flymake-simple-java-cleanup flymake-get-real-file-name) (".+[0-9]+\\.tex$" flymake-master-tex-init flymake-master-cleanup flymake-get-real-file-name) (".+\\.tex$" flymake-simple-tex-init flymake-simple-cleanup flymake-get-real-file-name) (".+\\.idl$" flymake-simple-make-init flymake-simple-cleanup flymake-get-real-file-name))))
 '(flymake-master-file-dirs (quote ("." "./src/main/java" "./src/test/java")))
 '(fortune-dir "~/.fortunes")
 '(frame-background-mode (quote dark))
 '(gc-cons-threshold 20000000)
 '(glasses-face (quote bold))
 '(glasses-separate-parentheses-p nil)
 '(glasses-separator "")
 '(global-font-lock-mode t nil (font-lock))
 '(gnus-nntp-server "news.ya.com")
 '(gnus-secondary-select-methods (quote ((nntp "news.ya.com"))))
 '(indent-tabs-mode nil)
 '(inferior-lisp-program "lein repl")
 '(inhibit-startup-screen t)
 '(jabber-nickname "chous")
 '(jabber-server "amessage.de")
 '(jabber-username "chous")
 '(java-indent-level 4)
 '(jde-build-function (quote (jde-ant-build)))
 '(jde-checkstyle-classpath (quote ("/home/chous/toolbox/checkstyle/checkstyle-5.3-all.jar")))
 '(jde-checkstyle-finish-hook nil)
 '(jde-checkstyle-option-allow-package nil)
 '(jde-checkstyle-option-allow-protected nil)
 '(jde-checkstyle-option-block-catch (list "stmt"))
 '(jde-checkstyle-option-block-finally (list "stmt"))
 '(jde-checkstyle-option-header-ignoreline (quote (1 2 4 30)))
 '(jde-checkstyle-option-ignore-imports t)
 '(jde-checkstyle-option-ignore-public-in-interface t)
 '(jde-checkstyle-option-ignore-whitespace t)
 '(jde-checkstyle-option-ignore-whitespace-cast t)
 '(jde-checkstyle-option-illegal-instantiations (quote ("java.lang.Boolean")))
 '(jde-checkstyle-option-javadoc-check-unused-throws t)
 '(jde-checkstyle-option-javadoc-scope (quote ("anoninner")))
 '(jde-checkstyle-option-lcurly-method (quote ("nl")))
 '(jde-checkstyle-option-lcurly-other (quote ("nl")))
 '(jde-checkstyle-option-lcurly-type (quote ("nl")))
 '(jde-checkstyle-option-localvar-format "^t_[a-zA-Z0-9]*$")
 '(jde-checkstyle-option-maxconstructorlen 50)
 '(jde-checkstyle-option-maxlinelen 79)
 '(jde-checkstyle-option-maxmethodlen 200)
 '(jde-checkstyle-option-member-format "^m__[a-zA-Z0-9]*$")
 '(jde-checkstyle-option-public-member-format "^INVALID$")
 '(jde-checkstyle-option-rcurly (quote ("alone")))
 '(jde-checkstyle-option-require-packagehtml nil)
 '(jde-checkstyle-option-static-format "^m__[a-zA-Z0-9]*$")
 '(jde-checkstyle-option-tab-width 4)
 '(jde-checkstyle-option-wrap-operator t)
 '(jde-checkstyle-style "/home/chous/dev/ventura24/svn/v24-pom/trunk/build-tools/src/main/resources/nlp/etc/code-conventions/nlp_checks_5.0.xml" t)
 '(jde-compile-enable-kill-buffer t)
 '(jde-compile-option-classpath nil)
 '(jde-compile-option-debug (quote ("all" (t nil t))))
 '(jde-compile-option-depend nil)
 '(jde-compile-option-directory "./target/classes")
 '(jde-compile-option-hide-classpath nil)
 '(jde-compile-option-source (quote ("1.5")))
 '(jde-compile-option-sourcepath nil)
 '(jde-compile-option-target (quote ("1.5")))
 '(jde-compiler (quote ("javac server" "")))
 '(jde-complete-display-qualified-types nil)
 '(jde-complete-function (quote jde-complete-in-line))
 '(jde-db-option-heap-profile (quote (nil "./java.hprof" 5 20 "Live 
objects")))
 '(jde-db-option-java-profile (quote (t . "./java.prof")))
 '(jde-db-option-verbose (quote (t t nil)))
 '(jde-db-source-directories (quote ("./src/java")) t)
 '(jde-debugger (quote ("JDEbug")))
 '(jde-enable-abbrev-mode nil)
 '(jde-find-granularity (quote ("Word")))
 '(jde-findbugs-class-dir nil)
 '(jde-findbugs-directory "/usr/java/findbugs")
 '(jde-flymake-jikes-app-name "/usr/bin/jikes")
 '(jde-flymake-sourcepath (quote ("/home/chous/dev/acmsl/queryj/src/main/java" "/home/chous/dev/acmsl/queryj/src/test/java" "/home/chous/dev/acmsl/commons/src/main/java")))
 '(jde-gen-comments nil)
 '(jde-gen-conditional-padding-1 "  ")
 '(jde-gen-conditional-padding-3 "")
 '(jde-gen-k&r nil)
 '(jde-gen-method-signature-padding-3 "")
 '(jde-gen-println (quote ("(end-of-line) '&" "'>\"LogFactory.getLog(getClass()).info(\"'n'> (P \"Print out: \") \");\" '>'n'>")))
 '(jde-help-docsets (quote (("JDK API" "/usr/share/doc/java-sdk-docs-1.4.2/html/api/" ignore))))
 '(jde-imenu-modifier-abbrev-alist (quote (("public" . 43) ("protected" . 35) ("private" . 45) ("static" . 2215) ("transient" . 2231) ("volatile" . 126) ("abstract" . 63) ("final" . 42) ("native" . 36) ("synchronized" . 64) ("strictfp" . 37))))
 '(jde-imenu-sort (quote asc))
 '(jde-import-auto-sort nil)
 '(jde-import-default-group-name "Importing other classes.")
 '(jde-import-group-of-rules (quote (("^com.ventura24.nlp.backoffice?\\." . "Importing NLP-BackOffice classes.") ("^com.ventura24.nlp.webapp?\\." . "Importing NLP-WebApp classes.") ("^com.ventura24.nlp.games?\\." . "Importing NLP-Games classes.") ("^com.ventura24.nlp.um?\\." . "Importing NLP-UserManagement classes.") ("^com.ventura24.nlp.processesapi?\\." . "Importing NLP-ProcessesApi classes.") ("^com.ventura24.nlp.payment?\\." . "Importing NLP-Payment classes.") ("^com.ventura24.nlp.processes?\\." . "Importing NLP-Processes classes.") ("^com.ventura24.messaging?\\." . "Importing Messaging classes.") ("^com.ventura24.nlp?\\." . "Importing other NLP classes.") ("^com.ventura24?\\." . "Importing other Ventura24 classes.") ("^org.acmsl.queryj?\\." . "Importing QueryJ classes.") ("^org.acmsl.commons?\\." . "Importing ACM-SL Commons classes.") ("^org.apache.commons.logging?\\." . "Importing Apache Commons Logging classes.") ("^org.apache.struts?\\." . "Importing Apache Struts classes.") ("^java?\\." . "Importing JDK classes.") ("^javax?\\." . "Importing Java Extension classes."))))
 '(jde-import-insert-group-names t)
 '(jde-import-sorted-groups (quote gor))
 '(jde-jalopy-option-encoding "ascii")
 '(jde-jalopy-option-nobackup nil)
 '(jde-jalopy-option-path "/usr/java/jalopy")
 '(jde-jalopy-option-preferences-file "/home/chous/dev/jalopy.xml")
 '(jde-javadoc-command-path "ajdoc")
 '(jde-javadoc-gen-destination-directory "Javadoc" t)
 '(jde-javadoc-version-tag-template "\"* @version $Revision: $\"")
 '(jde-jdk-doc-url "/usr/share/doc/jdk-1.4/html/api/index-all.html")
 '(jde-jdk-registry (quote (("1.6" . "/home/chous/.gentoo/java-config-2/current-user-vm"))))
 '(jde-jode-style "gnu")
 '(jde-jode-temp-directory "~/.jde-jode/")
 '(jde-jsee-get-doc-url-function (quote jsee-get-javadoc1\.2-url))
 '(jde-jsee-javadoc-noindex-option nil)
 '(jde-jsee-javadoc-notree-option nil)
 '(jde-jsee-javadoc-others-options "")
 '(jde-lint-option-home "/usr/java/lint4j")
 '(jde-lint-option-target "org.acmsl.*")
 '(jde-make-program "ant" t)
 '(jde-run-option-heap-profile (quote (t "./java.hprof" 5 20 "Live 
objects")))
 '(jde-run-working-directory "./lib")
 '(jde-setnu-mode-enable t)
 '(jde-vm-path "")
 '(jde-wiz-get-javadoc-template (quote ("    /**" "     * Retrieves the <code>%n</code> instance." "     * @return such information." "     */")))
 '(jde-wiz-set-javadoc-template (quote ("    /**" "     * Specifies the <code>%n</code> instance." "     * @param %p such information." "     */")))
 '(jserial-serial-comment "//Generated by jserial")
 '(jserial-serialver-program "~/.gentoo/java-config-2/current-user-vm/bin/serialver")
 '(line-number-mode t)
 '(mail-source-directory "~/.maildir/")
 '(mail-sources (quote ((maildir :path "/home/chous/.maildir" :plugged nil))))
 '(malabar-import-post-insert-function (quote malabar-import-group-imports))
 '(menu-bar-mode nil)
 '(mew-demo-picture nil)
 '(mew-imap-delete nil)
 '(mew-imap-port "imap2" t)
 '(mew-imap-prefix-list nil)
 '(mew-imap-server "192.168.34.1")
 '(mew-imap-ssl nil)
 '(mew-imap-user "jlean")
 '(mew-mail-domain "ventura24.es")
 '(mew-mailbox-type (quote imap))
 '(mew-smtp-helo-domain "acm-sl.org")
 '(mew-smtp-mail-from "chous@acm-sl.org")
 '(mew-smtp-server "mail.acm-sl.org")
 '(mew-smtp-ssl t)
 '(mew-use-biff t)
 '(mew-use-cached-passwd t)
 '(mldonkey-host "localhost")
 '(mldonkey-passwd "admin")
 '(mldonkey-show-active-sources nil)
 '(mldonkey-show-avail t)
 '(mldonkey-show-downloaded nil)
 '(mldonkey-show-finished-network nil)
 '(mldonkey-show-network nil)
 '(mldonkey-show-priority nil)
 '(mldonkey-show-size t)
 '(mldonkey-show-total-sources nil)
 '(mldonkey-user "admin")
 '(mouse-wheel-mode t nil (mwheel))
 '(newsticker-url-list (quote (("Slashdot" "http://www.slashdot.org/rss/index.rss" nil nil nil))))
 '(newsticker-url-list-defaults (quote (("Emacs Wiki" "http://www.emacswiki.org/cgi-bin/wiki.pl?action=rss" nil 3600) ("Quote of the day" "http://www.quotationspage.com/data/qotd.rss" "07:00" 86400) ("slashdot" "http://slashdot.org/index.rss" nil 3600))))
 '(nxml-slash-auto-complete-flag t)
 '(org-agenda-custom-commands (quote (("d" todo "DELEGATED" nil) ("c" todo "DONE|DEFERRED|CANCELLED" nil) ("w" todo "WAITING" nil) ("W" agenda "" ((org-agenda-ndays 21))) ("A" agenda "" ((org-agenda-skip-function (lambda nil (org-agenda-skip-entry-if (quote notregexp) "\\=.*\\[#A\\]"))) (org-agenda-ndays 1) (org-agenda-overriding-header "Today's Priority #A tasks: "))) ("u" alltodo "" ((org-agenda-skip-function (lambda nil (org-agenda-skip-entry-if (quote scheduled) (quote deadline) (quote regexp) "
]+>"))) (org-agenda-overriding-header "Unscheduled TODO entries: "))))))
 '(org-agenda-files (quote ("~/todo.org")))
 '(org-agenda-ndays 7)
 '(org-agenda-show-all-dates t)
 '(org-agenda-skip-deadline-if-done t)
 '(org-agenda-skip-scheduled-if-done t)
 '(org-agenda-start-on-weekday nil)
 '(org-deadline-warning-days 14)
 '(org-default-notes-file "~/notes.org")
 '(org-fast-tag-selection-single-key (quote expert))
 '(org-remember-store-without-prompt t)
 '(org-remember-templates (quote ((116 "* TODO %?
  %u" "~/todo.org" "Tasks") (110 "* %u %?" "~/notes.org" "Notes"))))
 '(org-reverse-note-order t)
 '(pmd-append-output nil)
 '(pmd-home "/home/chous/toolbox/pmd-4.2.5")
 '(pmd-java-home "/home/chous/.gentoo/java-config-2/current-user-vm/bin/java")
 '(pom-project-file-name "./pom.xml")
 '(remember-annotation-functions (quote (org-remember-annotation)))
 '(remember-handler-functions (quote (org-remember-handler)))
 '(safe-local-variable-values (quote ((Package . CL-USER) (Syntax . COMMON-LISP) (Package . HUNCHENTOOT) (Syntax . ANSI-Common-Lisp) (Base . 10) (buffer-file-coding-system . sjis))))
 '(scroll-bar-mode (quote right))
 '(send-mail-function (quote smtpmail-send-it))
 '(shell-file-name "bash")
 '(shell-prompt-pattern ">")
 '(show-paren-mode t)
 '(smtpmail-smtp-server "localhost")
 '(smtpmail-smtp-service 25)
 '(speedbar-frame-parameters (quote ((minibuffer) (width . 30) (border-width . 0) (menu-bar-lines . 0) (unsplittable . t))))
 '(speedbar-tag-split-minimum-length 40)
 '(sql-mysql-options (quote ("--port" "3307" "-h" "127.0.0.1" "--silent" "--skip-column-names" "-A")))
 '(tags-add-tables t)
 '(tex-dvi-view-command "/usr/bin/xdvi")
 '(tool-bar-mode nil nil (tool-bar))
 '(transient-mark-mode t)
 '(uniquify-buffer-name-style nil nil (uniquify))
 '(user-full-name "Jose San Leandro")
 '(w3-use-terminal-characters-on-tty t)
 '(w3m-fill-column 79)
 '(w3m-follow-redirection 30)
 '(w3m-use-cookies t)
 '(wl-from "Jose San Leandro <jose.sanleandro@ventura24.es>" t)
 '(wl-message-buffer-prefetch-folder-type-list (quote (imap4)))
 '(wl-organization nil)
 '(wl-smtp-posting-server "metropolis" t)
 '(wl-smtp-posting-user "jlean"))

;;(set-language-environment "ASCII")

;;; [[ Private Setting ]]

;; Header From:
(setq wl-from "Jose San Leandro <jose.sanleandro@ventura24.es>")

;; If (system-name) does not return FQDN,
;; set following as a local domain name without hostname.
(setq wl-local-domain "ventura24.es")

;;; [[ Server Setting ]]

;; Default IMAP4 server
(setq elmo-imap4-default-server "metropolis")
;; Default POP server
(setq elmo-pop3-default-server "metropolis")
;; SMTP server
(setq wl-smtp-posting-server "localhost")
;; Default NNTP server
(setq elmo-nntp-default-server "news.ya.com")
;; NNTP server name for posting
(setq wl-nntp-posting-server elmo-nntp-default-server)

;; IMAP authenticate type setting
(setq elmo-imap4-default-authenticate-type 'clear) ; raw
;(setq elmo-imap4-default-authenticate-type 'cram-md5) ; CRAM-MD5

;; POP-before-SMTP
;(setq wl-draft-send-mail-function 'wl-draft-send-mail-with-pop-before-smtp)

;; (custom-set-faces
;;   ;; custom-set-faces was added by Custom.
;;   ;; If you edit it by hand, you could mess it up, so be careful.
;;   ;; Your init file should contain only one such instance.
;;   ;; If there is more than one, they won't work right.
;;  '(default ((t (:stipple nil :background "#202020" :foreground "peachpuff" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :width normal :family "adobe-courier"))))
;;  '(cursor ((t (:background "blue" :foreground "black"))))
;;  '(fixed-pitch ((t (:family "-*-Lucida Console-normal-r-*-*-14-112-96-96-c-*-iso8859-1"))))
;;  '(highlight-current-line-face ((t (:background "black" :foreground "lightyellow" :inverse-video t :underline "darkgrey"))) t)
;;  '(region ((((class color) (background dark)) (:background "#8888ff")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "#000000" :foreground "#ffffff" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 107 :width normal :foundry "adobe" :family "courier"))))
 '(ecb-default-general-face ((((class color) (background dark)) (:height 0.7))))
 '(ecb-sources-general-face ((((class color) (background dark)) (:inherit ecb-default-general-face)))))
