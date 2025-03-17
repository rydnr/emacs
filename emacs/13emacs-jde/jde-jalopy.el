;;; JDE-JALOPY.EL --- JALOPY interface for JDE

;; Copyright (C) 2002 Nascif A. Abousalh Neto

;; Author: Nascif A. Abousalh Neto <nascif at acm dot org>
;; Maintainer: Nascif A. Abousalh Neto <nascif@acm.org>
;; Keywords: java, beautifier, pretty printer, tools
;; Time-stamp: <2002-12-04 00:48:50 nascif>
;; 
;; Version: 1.2
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 1, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; A copy of the GNU General Public License can be obtained from the Free
;; Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:
;; This package provides an interface from JDE (see http://jde.sunsite.dk/) to Jalopy
;; (see http://jalopy.sourceforge.net/).
;; Jalopy is a `a source code formatter for the Sun Java programming language. It
;; layouts any valid Java source code according to some widely configurable rules; 
;; to meet a certain coding style without putting a formatting burden on individual 
;; developers.'

;; Installation:
;;
;;  1) Download and install the Jalopy console plug-in package from:
;;  http://jalopy.sourceforge.net/download.html
;;
;;  2) Put this file on your Emacs-Lisp load path and add the following into
;;  your .emacs startup file
;;
;;      (require 'jde-jalopy)
;;
;;  3) Customize the variable `jde-jalopy-option-path' to point to the Jalopy
;;  installation directory.
;;
;;  4) Make sure JDE is properly configured. In particular set the variables
;;  jde-jdk-registry and jde-jdk so that the JVM launcher can be found.

;;; Usage:
;;
;;  M-x `jde-jalopy-file' to reformat the Java source file associated to the current buffer.
;;

;;; Customization:
;;
;;  To customize the Jalopy-Emacs interface options, use the command:
;;  M-x `jde-jalopy-customize' 
;;
;;  The default behavior for Jalopy is to format the code according to the Sun Code
;;  conventions. If you want to customize the formatting behavior (and Jalopy supports a
;;  large number of customization options), use the command:
;;  M-x `jde-jalopy-preferences'  
;;
;;  This command will launch the Jalopy Preferences editor GUI-based tool. You
;;  can use it to create a file with your customized preferences. Point the
;;  variable `jde-jalopy-option-preferences-file' to this file. I suggest you
;;  save the file in the XML format, so that you can edit the preferences file
;;  directly in an Emacs buffer later.

;;; Acknowledgements:
;;
;; This code is heavily based on jde-check.el, by Markus Mohnen.

;;; ChangeLog:
;;
;;  1.2 - jde-jalopy-buffer renamed to jde-jalopy-file to clarify its behavior.
;;
;;  1.1 - updates to support Jalopy 1.0b10 (changes in location of jar files)
;;
;;  1.0 - first version, supporting Jalopy 1.0b8

;;; Code:

(require 'jde-compile)

(if (fboundp 'jde-build-classpath)
    nil
  (require 'jde-run)
  (defalias 'jde-build-classpath 'jde-run-build-classpath-arg)
  )

(defconst jde-jalopy-version "1.0b10")

(defgroup jde-jalopy nil
  "JDE Jalopy Options"
  :group 'jde
  :prefix "jde-jalopy-option-")

(defcustom jde-jalopy-option-class "de.hunsicker.jalopy.plugin.console.ConsolePlugin"
  "*Jalopy console plug-in class.  Specifies the Jalopy console plug-in
class. There is typically no need to change this variable."
  :group 'jde-jalopy
  :type 'string)

(defcustom jde-jalopy-option-preferences-class 
  "de.hunsicker.jalopy.swing.SettingsDialog"
  "*Jalopy console plug-in class.  Specifies the Jalopy console plug-in
class. There is typically no need to change this variable."
  :group 'jde-jalopy
  :type 'string)

(defcustom jde-jalopy-option-path ""
  "*Specify installation path of the Jalopy Console plug-in.  This path will be
used to find the Jalopy .jar files in order to construct a -classpath argument
to pass to the Java interpreter. This option overrides the
`jde-global-classpath' option."
  :group 'jde-jalopy
  :type 'string)

(defcustom jde-jalopy-option-read-args nil
  "*Specify whether to prompt for additional jalopy arguments.
If this variable is non-nil, the jde-jalopy command prompts
you to enter additional jalopy arguments in the minibuffer.
These arguments are appended to those specified by customization
variables. The JDE maintains a history list of arguments 
entered in the minibuffer."
  :group 'jde-jalopy
  :type 'boolean)

(defvar jde-interactive-jalopy-args ""
  "String of jalopy arguments entered in the minibuffer.")

(defcustom jde-jalopy-option-command-line-args ""
  "*Specify options as a string of command-line arguments.  The value of this
variable should be a string of switches understood by Jalopy. This variable is
intended to be used to set options not otherwise defined by this version
of jde-jalopy."
  :group 'jde-jalopy
  :type 'string)

(defcustom jde-jalopy-option-encoding "Cp1252"
  "*Encoding of input files. Must be one of the JDK supported encodings."
  :group 'jde-jalopy
  :type 'string)

(defcustom jde-jalopy-option-format "AUTO"
  "*Output file format - one of UNIX, DOS, MAC, AUTO (the default) or DEFAULT
(all case-insensitive)."
  :group 'jde-jalopy
  :type 'string)

(defcustom jde-jalopy-option-force nil
  "*Force format even if file is up-to-date." 
  :group 'jde-jalopy
  :type 'boolean)  

(defcustom jde-jalopy-option-nobackup nil
  "*If true disable the creation of keep backup files."
  :group 'jde-jalopy
  :type 'boolean)

(defcustom jde-jalopy-option-preferences-file ""
  "*Preferences file. Used to configure the many Jalopy options on how to format
the code."
  :group 'jde-jalopy
  :type 'file)

(defcustom jde-jalopy-option-thread 1
  "*Specifies the number of processing threads to be used. This settingg should be
equal to the number of processors your system has."
  :group 'jde-jalopy
  :type 'integer)

(defun jde-jalopy-get-java ()
  "Returns the name of the JVM launcher application."
  (if (string< jde-version "2.2.9")
      (if (eq system-type 'windows-nt)
          jde-run-java-vm-w
        jde-run-java-vm)
    (oref (jde-run-get-vm) :path)))

(defun jde-jalopy-get-options ()
  "Constructs a command-line argument string for jalopy.
The string consists of the contents of the jde-jalopy-options
variable concatenated with the various jde-jalopy-option
settings.
"
  (let (options)
    (if (not (string= jde-jalopy-option-encoding ""))
        (setq options (concat options " --encoding=" jde-jalopy-option-encoding)))
    (if (not (string= jde-jalopy-option-format ""))
        (setq options (concat options " --format=" jde-jalopy-option-format)))
    (if jde-jalopy-option-force
        (setq options (concat options " --force")))
    (if jde-jalopy-option-nobackup
        (setq options (concat options " --nobackup")))
    (if (not (string= jde-jalopy-option-preferences-file ""))
        (setq options (concat options " --style=" 
                              (jde-normalize-path jde-jalopy-option-preferences-file))))
    (if (not (= jde-jalopy-option-thread 1))
        (setq options (concat options " --thread=" 
                              (int-to-string jde-jalopy-option-thread))))
    
    (if (not (string= jde-jalopy-option-command-line-args ""))
        (setq options (concat options " " jde-jalopy-option-command-line-args)))
    options))

(defun jde-jalopy-get-classpath ()
  "Returns a string with the classpath used to call the Jalopy console plug-in.
"
  (let ((classpath) 
        (save-jde-expand-classpath-p jde-expand-classpath-p)
        (save-jde-lib-directory-names jde-lib-directory-names))
    (if jde-jalopy-option-path
        (progn
          (setq jde-expand-classpath-p t)
          (setq jde-lib-directory-names (list "^lib"))
          (setq classpath
                (concat classpath " -classpath \'"
                        (jde-build-classpath (list (jde-jalopy-get-install-path)))
                        "\'"))
          (setq jde-expand-classpath-p save-jde-expand-classpath-p)
          (setq jde-lib-directory-names save-jde-lib-directory-names))
      (if (and (boundp 'jde-global-classpath)
               jde-global-classpath)
          (setq classpath
                (concat classpath " -classpath \'"
                        (jde-build-classpath jde-global-classpath)
                        "\'"))))
    classpath))

(defun jde-jalopy-get-install-path ()
  (concat jde-jalopy-option-path
          (if (string-match ".*[/\\]$" jde-jalopy-option-path)
              "" 
            (if (eq system-type 'windows-nt) "\\" "/"))
          "lib"))

;;;###autoload
(defun jde-jalopy-customize ()
  "Customization of the group jde-jalopy."
  (interactive)
  (customize-group "jde-jalopy"))

(defun jde-jalopy-make-command (more-args)
  "Constructs the java jalopy command as: jde-jalopy + options + buffer file name."
  (concat 
   (jde-jalopy-get-java)
   (jde-jalopy-get-classpath)
   (if (not (string= more-args "")) (concat " " more-args))
   " "
   jde-jalopy-option-class 
   " "
   (jde-jalopy-get-options) 
   " "   
   (file-name-nondirectory buffer-file-name)))

(defun jde-jalopy-make-preferences-command ()
  "Constructs the java jalopy Preferences command."
  (concat 
   (jde-jalopy-get-java)
   (jde-jalopy-get-classpath)
   " "
   jde-jalopy-option-preferences-class))

;;;###autoload
(defun jde-jalopy-file ()
  "Formats the Java source code in the current buffer.
This command invokes the code formatter specified by `jde-jalopy-class'
with the options specified by the JDE customization variables
that begin with `jde-jalopy'. If the variable
`jde-option-read-args' is non-nil, this command reads
additional compilation options from the minibuffer, with
history enabled."
  (interactive)

  (if jde-jalopy-option-read-args
      (setq jde-interactive-jalopy-args
            (read-from-minibuffer 
             "Jalopy args: "
             jde-interactive-jalopy-args
             nil nil
             '(jde-interactive-jalopy-arg-history . 1))))

  (let ((jalopy-command
         (jde-jalopy-make-command jde-interactive-jalopy-args)))
    
    ;; Force save-some-buffers to use the minibuffer
    ;; to query user about whether to save modified buffers.
    ;; Otherwise, when user invokes jde-jalopy from
    ;; menu, save-some-buffers tries to popup a menu
    ;; which seems not to be supported--at least on
    ;; the PC.
    (if (and (eq system-type 'windows-nt)
             (not jde-xemacsp)) 
        (let ((temp last-nonmenu-event))
          ;; The next line makes emacs think that jde-jalopy
          ;; was invoked from the minibuffer, even when it
          ;; is actually invoked from the menu-bar.
          (setq last-nonmenu-event t)
          (save-some-buffers (not compilation-ask-about-save) nil)
          (setq last-nonmenu-event temp))
      (save-some-buffers (not compilation-ask-about-save) nil))
    (compile-internal jalopy-command "No more errors")))

(defun jde-jalopy-preferences ()
  "Launches the Jalopy Preferences editor."
  (interactive)

  (let ((jalopy-command
         (jde-jalopy-make-preferences-command)))
    
    (compile-internal jalopy-command "No more errors")))


(provide 'jde-jalopy)

;;; JDE-JALOPY.EL ends here

;; (defcustom jde-jalopy-option-recursive 0
;;   "*Recurse into directories, up to NUM levels. If negative, recurses indefinitely"
;;   :group 'jde-jalopy
;;   :type 'integer)

;;     (if (not (= jde-jalopy-option-recursive 0))
;;         (setq options (concat options " --recursive"
;;                               (if (> jde-jalopy-option-recursive 0)
;;                                   (concat "=" (int-to-string jde-jalopy-option-recursive))))))

;; (defcustom jde-jalopy-option-dest nil
;;   "*Base output directory for the formatted code.
;; If not specified the formatted code will be sent to the output buffer."
;;   :group 'jde-jalopy
;;   :type '(file :tag "Path"))

;;     (if (not (string= jde-jalopy-option-dest ""))
;;         (setq options (concat options " --dest=" jde-jalopy-option-dest)))
