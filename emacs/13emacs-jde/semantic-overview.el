;;; semantic-overview.el --- 

;; $Id: semantic-overview.el,v 1.4 2003/01/10 05:57:59 burton Exp $

;; Copyright (C) 2000-2003 Free Software Foundation, Inc.
;; Copyright (C) 2000-2003 Kevin A. Burton (burton@openprivacy.org)

;; Author: Kevin A. Burton (burton@openprivacy.org)
;; Maintainer: Kevin A. Burton (burton@openprivacy.org)
;; Location: http://relativity.yi.org
;; Keywords: 
;; Version: 1.0.0

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

;; The semantic-overview package is an Emacs and Semantic plugin that allow the
;; user to receive an overview for the current source file being edited by the
;; user.  The only requirement is that the file format supports indexing by
;; Emacs Semantic Bovinator [1].
;;
;; At this time of this writing this included most standard languages such as
;; Lisp, Scheme, Java, C, C++, etc.
;;
;; There are still a few more features I want to add.  Specifically speed could
;; be improved and I could add some more features such as optional sorting
;; order, etc.
;;
;; It would be interesting to provide an implementation of method tracking as
;; implement within the Emacs Class Browser.

;; - NOTE: acts like a thin ECB
;;
;; - NOTE: implement a very tiny window manager similar to the ECB but without
;; all the bagage.
;;
;;    - should handle popping up the semantic browser based on the orientation
;;    setting of the user.

;; 1. http://www.xemacs.org/Documentation/packages/html/semantic.html

;; NOTE: If you enjoy this software, please consider a donation to the EFF
;; (http://www.eff.org)

;;; Code:

;;; TODO:
;;
;; - Use format strings so that everything lines up correctly
;;
;; - speed improvements: set faces on text when I insert it instead of my
;; fontify function that parses the buffer afterwards.
;;
;; - count lines fix!
;;
;; - all highlights should be done with text properties
;;
;; - pop to the buffer while we are STILL adding text... this way it feels faster!
;;
;; - point should be around the current nonterminal with in the buffer (where
;; the point is..)

(defvar semantic-overview-buffer-name "*semantic-overview*" "Name of the temp buffer.")

(defface semantic-overview-blink-line-face '((t (:background "DarkBlue")))
  "Face used for the last available match."
  :group 'semantic-overview)

(defun semantic-overview()
  "Show semantic token names for the current buffer."
  (interactive)

  ;;erase the dest buffer.

  (let((source-buffer (current-buffer)))
    
    (save-excursion 

      (set-buffer (get-buffer-create semantic-overview-buffer-name))
      
      (toggle-read-only -1)
      
      (erase-buffer)
      
      (insert (format "//Semantic overview for file: %s\n" (buffer-file-name source-buffer))))

    ;;if this buffer isn't bovinated go ahead and do it... this only happens
    ;;the first time we run ig.
    (semantic-bovinate-toplevel)

    (save-excursion

      (goto-char (point-min))

      (let((nonterminal nil))
        (while (setq nonterminal (semantic-find-nonterminal-by-overlay-next (point)))

          (when nonterminal

            ;;goto the end of the nonterminal for better performance.
            (save-excursion 
  
              (set-buffer (get-buffer-create semantic-overview-buffer-name))

              (let((begin (point)))

                ;;FIXME: don't alwasy count lines from point 1!!!  Waste of
                ;;time!  Instead could from where we last left off.
                (semantic-overview-insert (concat (number-to-string
                                                   (save-excursion
                                                     (set-buffer source-buffer)
                                                     (count-lines 1 (semantic-token-start nonterminal)))) ":")
                                          6) ;;with a margin of 6

                (semantic-overview-insert (symbol-name (semantic-token-token nonterminal)) 10)

                (insert "  ")
            
                (insert (semantic-uml-prototype-nonterminal nonterminal nil t))

                (insert "\n")
                
                (put-text-property begin (point) 'semantic-overview-point
                                   (semantic-token-start nonterminal))))

            (if (eq 'type (semantic-token-token nonterminal))
                (goto-char (semantic-token-start nonterminal))
              (goto-char (semantic-token-end nonterminal)))))))

    (pop-to-buffer semantic-overview-buffer-name)
    (goto-char (point-min))
    (semantic-overview-mode)))

(defun semantic-overview-insert(text min-width)
  "Insert the give width making sure it is at least min-width (and padd it)."

  (insert text)

  (if (< (string-width text) min-width)
      (insert (make-string (- min-width (string-width text)) ? ))))

(define-derived-mode semantic-overview-mode fundamental-mode "SemanticOverview"
  "Mode for Semantic Overviews."

  (semantic-overview-fontify)
  (toggle-read-only 1))

(defun semantic-overview-goto-line-number()
  "Goto the current line number."
  (interactive)

  (let(filename line-number)

    (save-excursion

      (goto-char (point-min))
      
      (assert (re-search-forward "file: \\(.*\\)$" nil t)
              nil "Could not find filename.")

      (setq filename (match-string 1)))
      
    (setq point (get-text-property (point) 'semantic-overview-point))
      
    (find-file-other-window filename)
    
    (goto-char point)
    (semantic-overview-blink-line)))

(defun semantic-overview-fontify()
  "Highlght the buffer where necessary."

  (save-excursion

    (set-buffer (get-buffer-create semantic-overview-buffer-name))

    (goto-char (point-min))

    (save-excursion
      (while (re-search-forward "//.+$" nil t)
      
        (add-text-properties (match-beginning 0) (match-end 0)
                             '(comment t face font-lock-comment-face))))

    (save-excursion
      (while (re-search-forward "^[ ]*[0-9]+" nil t)
      
        (add-text-properties (match-beginning 0) (match-end 0)
                             '(face font-lock-variable-name-face))))))

(defun semantic-overview-blink-line()
  "Blink the currently selected line."
  (interactive)

  (let((overlay (make-overlay (point-at-bol) (1+ (point-at-eol)) (current-buffer))))

    (overlay-put overlay 'face 'semantic-overview-blink-line-face)

    (overlay-put overlay 'priority 1)

    (setq semantic-overview-blink-line-overlay overlay)
    
    ;;delete this overlay...
    (add-hook 'pre-command-hook 'semantic-overview-unblink-line)))

(defun semantic-overview-unblink-line()

  (delete-overlay semantic-overview-blink-line-overlay)

  (setq semantic-overview-blink-line-overlay nil)
  
  (remove-hook 'pre-command-hook 'semantic-overview-unblink-line))

;;key binding so that one can quickly jump an entry in the overview buffer
(define-key semantic-overview-mode-map [return] 'semantic-overview-goto-line-number)

(provide 'semantic-overview)

;;; semantic-overview.el ends here