;;; jde-maven2.el --- Use Apache Maven2 to build your JDE projects

;; $Id: jde-maven2.el,v 2.0 2007/12/28 19:44:00 cplate Exp cplate $

;;
;; Author: Lukas Benda <bendal@quick.cz>
;; Created: 28 Dec 2007
;; Tested on GNU Emacs 22.1.1
;;
;; ----------------------------------------------------------------------------
;; Create from jde-maven.el from Raffael Herzog <herzog@raffael.ch>
;; Updated by Christian Plate <cplate@web.de> to work with
;; CVS Emacs 22.0.50
;; Version 0.1.2
;; ----------------------------------------------------------------------------

;; This file is not part of Emacs

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; Commentary:

;; It's designed to be used in conjunction with JDEE.
;;
;; To install put this file somewhere in your load-path, byte-compile
;; it and add a (require 'jde-maven2) to your .emacs *after* JDEE has
;; been loaded.
;;
;; This plugin support set for more then one project in some time.  It use
;; `jde-project-name' for load goal, arguments and profil
;;
;; If you want set default goal, arguments and profil then you mast add to
;; prj.el this lines:
;;
;; Set default goal to GOAL
;;  (jde-maven2-set-current-goal
;;    (if (jde-maven2-get-goal) (jde-maven2-get-goal) "GOAL"))

;; Set default profile to PROFILE
;;  (jde-maven2-set-current-profile
;;    (if (jde-maven2-get-profile) (jde-maven2-get-profile) "PROFILE"))

;; Set default arguments to ARGUMENTS
;;  (jde-maven2-set-current-arguments
;;    (if (jde-maven2-get-arguments) (jde-maven2-get-arguments) "ARGUMENTS"))

;; See the customization group jde-maven2 for customization options.
;; See the description of the command jde-maven2-build for
;; information on what it does.
;;
;; This provides the following interactive commands:
;;
;; -- jde-maven2-build: Build project with current goal, arguments and profile
;; -- jde-maven2-set-current-goal: This methode set goal for current project
;; -- jde-maven2-set-current-arguments: This methode set arguments for current
;;    project
;; -- jde-maven2-set-current-profile: This methode set profile for current
;;    project
;;
;; TODO:
;;
;; -- Parse output for going to FAIL or ERROR test result
;;
;; -- Is there a way to determine whether the build failed or
;;    succeeded?
;;
;;; History:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'compile)
(require 'jde)

(defgroup jde-maven2 nil
  "Build using maven."
  :group 'jde
  :prefix 'jde-maven2)
(defcustom jde-maven2-command "mvn"
  "The command to run maven"
  :group 'jde-maven2
  :type 'string)
(defcustom jde-maven2-project-file-name "pom.xml"
  "The name of the maven project file."
  :group 'jde-maven2
  :type '(choice (const :tag "Default" "pom.xml")
                 (string :tag "String")))
(defcustom jde-maven2-prompt-project-file nil
  "Prompt for the project file? If this is nil, jde-maven2 will look
  for the next project file the directory tree up the current file.
  The name of the project file can be customized in
  `jde-maven2-project-file-name'."
  :group 'jde-maven2
  :type '(choice (const :tag "No" nil)
                 (const :tag "Yes" t)))
(defcustom jde-maven2-goal nil
  "The name of the goal to attain."
  :group 'jde-maven2
  :type '(choice (const :tag "Default" nil)
                 (string :tag "String")))
(defcustom jde-maven2-prompt-goal nil
  "Prompt for the goal to attain?"
  :group 'jde-maven2
  :type '(choice (const :tag "No" nil)
                 (const :tag "Yes" t)))
(defcustom jde-maven2-arguments ""
  "The arguments to be passed to maven."
  :group 'jde-maven2
  :type 'string)
(defcustom jde-maven2-prompt-arguments nil
  "Prompt for further maven arguments?"
  :group 'jde-maven2
  :type '(choice (const :tag "No" nil)
                 (const :tag "Yes" t)))
(defcustom jde-maven2-prompt-profile nil
  "Prompt for further maven profile?"
  :group 'jde-maven2
  :type '(choice (const :tag "No" nil)
                 (const :tag "Yes" t)))

;;
;; define some variables
;;

(defvar jde-maven2-current-project-file nil
  "The project file last use for normal compilation or the currently running Maven process.")
(defvar jde-maven2-goal-history nil
  "History of goals.")
(defvar jde-maven2-current-goal nil
  "Last used goal in projects.")
(defvar jde-maven2-arguments-history nil
  "History of Maven arguments.")
(defvar jde-maven2-current-arguments nil
  "Last used arguments in projects.")
(defvar jde-maven2-current-profile nil
  "Last used profiles in projects")
(defvar jde-maven2-profile-history nil
  "History of Maven profile.")

;;
;; some constants
;;

(defconst jde-maven2-console-process-name "Maven2"
  "The name of the Maven process.")
(defconst jde-maven2-console-log-buffer-name "*Maven2*"
  "The name of the buffer containing the Maven log.")
(defconst jde-maven2-console-compilation-buffer-name "*compilation*"
  "The name of the compilation buffer to use.")

;;
;; generic functions for jde-maven2
;;

(defun jde-maven2-get-project-file()
  "Determine the path to the project file according to the user's
preferences. It either prompts for a project file if
`jde-maven2-prompt-project-file' is t, or it searches for a file
called `jde-maven2-projecct-file-name' the directory tree upwards
from the current file."
  (let ((project-file nil))
    (setq project-file
          (if jde-maven2-prompt-project-file
              (read-file-name "Project File: " jde-maven2-current-project-file jde-maven2-current-project-file t)
            (catch 'found
              (let ((last-directory nil))
                (setq project-file (file-name-directory (buffer-file-name)))
                (while (not (string= last-directory project-file))
                  (message (concat project-file jde-maven2-project-file-name))
                  (when (file-regular-p (concat project-file jde-maven2-project-file-name))
                    (throw 'found (concat project-file jde-maven2-project-file-name)))
                  (setq last-directory project-file)
                  (setq project-file (file-name-directory (directory-file-name project-file))))
                (error (concat "No " jde-maven2-project-file-name " found."))))))
    (setq project-file (expand-file-name project-file))
    ;;(setq jde-maven2-current-project-file project-file)
    (setq project-file (if (file-directory-p project-file)
                           (concat (file-name-as-directory project-file) jde-maven2-project-file-name)
                         project-file))
    (if (not (file-regular-p project-file))
        (error (concat project-file " does not exist or is not a regular file")))
    project-file))

(defun jde-maven2-get-goal()
  "Methode which return current goal for the project. It use `jde-project-name' get variable jde-maven2-current-goal (jde-project-name) it must be declared in prj.el file for every project."
  (if jde-maven2-prompt-goal
      (read-string "Goal: " (if jde-maven2-goal-history
                                   (car jde-maven2-goal-history)
                                 (nth 0 (cdr (assoc jde-project-name jde-maven2-current-goal))))
                   '(jde-maven2-goal-history . 1))
   (nth 0 (cdr (assoc jde-project-name jde-maven2-current-goal)))))

(defun jde-maven2-set-current-goal (goal)
  "Function which set current goal for project use `jde-project-name'.
If profile is nil then will be delete goal for project"
  (interactive "MGoal: ")
  (if goal
      (setq jde-maven2-current-goal
            (append (list (list jde-project-name goal))
                    (remove (assoc jde-project-name jde-maven2-current-goal)
                            jde-maven2-current-goal)))
    (remove (assoc jde-project-name jde-maven2-current-goal)
            jde-maven2-current-goal)))

(defun jde-maven2-get-arguments()
  "Methode which return current arguments for the project. It use `jde-project-name' get variable jde-maven2-current-arguments (jde-project-name) it must be declared in prj.el file for every project."
  (if jde-maven2-prompt-arguments
      (read-string "Arguments: " (if jde-maven2-arguments-history
                                   (car jde-maven2-arguments-history)
                                 (nth 0 (cdr (assoc jde-project-name jde-maven2-current-arguments))))
                   '(jde-maven2-arguments-history . 1))
   (nth 0 (cdr (assoc jde-project-name jde-maven2-current-arguments)))))

(defun jde-maven2-set-current-arguments (arguments)
  "Function which set current arguments for project use `jde-project-name'.
If profile is nil then will be delete arguments for project"
  (interactive "MArguments: ")
  (if goal
      (setq jde-maven2-current-arguments
            (append (list (list jde-project-name arguments))
                    (remove (assoc jde-project-name jde-maven2-current-arguments)
                            jde-maven2-current-arguments)))
    (remove (assoc jde-project-name jde-maven2-current-arguments)
            jde-maven2-current-arguments)))

(defun jde-maven2-set-current-profile (profile)
  "Function which set curretn profile for project use `jde-project-name'.
If profile is nil then will be delete profile for project"
  (interactive "MName of profile: ")
  (if profile
      (setq jde-maven2-current-profile
            (append (list (list jde-project-name profile))
                    (remove (assoc jde-project-name jde-maven2-current-profile)
                            jde-maven2-current-profile)))
    (remove (assoc jde-project-name jde-maven2-current-profile)
            jde-maven2-current-profile)))

(defun jde-maven2-get-profile()
  "Methode which return current profile for the project. It use `jde-project-name' get variable jde-maven2-current-profile (jde-project-name) it must be declared in prj.el file for every project."
  (if jde-maven2-prompt-profile
      (read-string "Profile: " (if jde-maven2-profile-history
                                   (car jde-maven2-profile-history)
                                 (nth 0 (cdr (assoc jde-project-name jde-maven2-current-profile))))
                   '(jde-maven2-profile-history . 1))
   (nth 0 (cdr (assoc jde-project-name jde-maven2-current-profile)))))

;;
;; Build command line and build function
;;

(defun jde-maven2-build-command-line-attributes(project-file goal arguments profile)
  "Make command line atributes for Maven command"
  (concat (if project-file (concat " -f " project-file) "")
          (if goal (concat " " goal) "")
          (if profile (concat " -P " profile) "")
          (if arguments (concat " " arguments) "")))

(defun jde-maven2-build-command-line(project-file goal arguments profile)
  "Build a Maven command line."
   (concat jde-maven2-command
           (jde-maven2-build-command-line-attributes project-file goal
                                                     arguments profile)))

(defun jde-maven2-build (&optional project-file goal args profile)
  "Do a standard maven build. prject-file is absolute path to pom.xml file. Goal is run goal, args is some aditional argumets and profile is profile which will be run"
  (interactive)
  (compile (jde-maven2-build-command-line
            (if project-file project-file (jde-maven2-get-project-file))
            (if goal goal (jde-maven2-get-goal))
            (if args args (jde-maven2-get-arguments))
            (if profile profile (jde-maven2-get-profile)))))

(defun jde-maven2-recreate-project-file-if-change (version &rest arguments)
  "Function wihich run recreate command if changes in pom.xml was done.
Arguments is represent set of arguments for creating prj.el.
Version is version of jdee version"
  (interactive)
  (if (time-less-p
       (nth 5 (file-attributes jde-maven-project-file-name))
       (nth 5 (file-attributes jde-current-project)))
      nil
    (list (message "start recreating project file from maven2")
          (if (get-buffer "*mvn-recreate*") (kill-buffer "*mvn-recreate*")  nil)
          (set-process-sentinel
           (eval (append (list 'start-process
                               "mvn-recreate" (get-buffer-create "*mvn-recreate*")
                               jde-maven2-command "-f"
                               (jde-maven2-get-project-file)
                               (concat "org.apache.maven.plugin:maven-emacs-plugin:"
                                       version ":jdee"))
                         arguments))
           (lambda (process event)
             "Reaction if status of process is changed"
             (if (= 0 (process-exit-status process))
                 (list (message "Succesfull recreating project file from maven2")
                       (run-at-time "5 sec" nil
                                    (lambda ()
                                      "Killing create buffer"
                                      (kill-buffer "*mvn-recreate*")))
                       (load-library jde-current-project))
               (princ (format "Process: %s had the event `%s'" process event)))))
          (switch-to-buffer-other-window (get-buffer "*mvn-recreate*")))))

;;
;; process communication stuff
;;

;; Thanks to Jack Donohue <donohuej@synovation.com>.
(defun jde-maven2-finish-kill-buffer (buf msg)
  "Removes the jde-compile window after a few seconds if no errors."
  (save-excursion
    (set-buffer buf)
    (if (null (or (string-match ".*exited abnormally.*" msg)
                  (string-match ".*BUILD FAILED.*" (buffer-string))))
        ;;no errors, make the compilation window go away in a few seconds
        (lexical-let ((compile-buffer buf))
          (run-at-time
           "2 sec" nil 'jde-compile-kill-buffer
           compile-buffer)
          (message "No compilation errors"))
      ;;there were errors, so jump to the first error
      ;;(if jde-compile-jump-to-first-error (next-error 1)))))
      )))

;; Add to error regexp
(add-to-list
 'compilation-error-regexp-alist
 '("^\\(.*\\):\\[\\([0-9]+\\),\\([0-9]+\\)\\]" 1 2 3 2 1))

(setq jde-key-bindings (append jde-key-bindings
                               (list
  (cons "[?\C-c ?\C-v ?\C-m g]" 'jde-maven2-set-current-goal)
  (cons "[?\C-c ?\C-v ?\C-m p]" 'jde-maven2-set-current-profile)
  (cons "[?\C-c ?\C-v ?\C-m a]" 'jde-maven2-set-current-arguments))))

(provide 'jde-maven2)
