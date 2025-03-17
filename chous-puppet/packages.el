;;; packages.el --- chous-puppet Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2015 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; List of all packages to install and/or initialize. Built-in packages
;; which require an initialization must be listed explicitly in the list.
(add-to-list 'load-path "/home/chous/toolbox/ssm-elisp/puppetfile-mode.el")

(defconst chous-puppet-packages
    '(
      ;; package names go here
      (puppetfile-mode :location local)
      ))

;; List of packages to exclude.
(defconst chous-puppet-excluded-packages '())

;; For each package, define a function chous-puppet/init-<package-name>
;;
;; (defun chous-puppet/init-my-package ()
;;   "Initialize my package"
;;   )
;;
(defun chous-puppet/init-puppetfile-mode()
  (use-package puppetfile-mode)
  )
;; Often the body of an initialize function uses `use-package'
;; For more info on `use-package', see readme:
;; https://github.com/jwiegley/use-package
