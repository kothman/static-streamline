;;; -*- lexical-binding: t -*-
;;; Org-Mode Export - Publish
(require 'ox-publish)

(defvar directory-name "static-streamline"
  "The directory name this project resides in, to be used by helper
Scripts in determining if the saved-buffer should trigger recompilation.")

;;; Helper functions for publishing the project
(defun my-org-publish ()
  "My function for publishing org projects as HTML."
  (interactive)
  (org-publish-project "org"))
(defun my-org-publish-force ()
  "My function for force-publishing org projects as HTML."
  (interactive)
  (org-publish-project "org" t))

(defun contains (key list)
  "Return t if key is in list."
       (let ((current (car list)))
	 (message "current: %s\nrest: %s\nkey: %s" current list key)
	 ;; If the current item is nil or matches the key,
	 ;; then it can be returned either way.
	 (if (or (equal key current) (equal nil current))
	     current
	     ;; If the current item isn't the key, and isn't nil...
	     ;; recurse into the list
	   (contains key (cdr list)))))

(defun my-org-after-save-hook ()
  "An after-save hook to publish the org files."
  ;; set list-of-path-parts to a list of directory names (and ending
  ;;;; with the file name)
  (let ((list-of-path-parts (split-string (buffer-file-name) "\\/")))
    ;; If and only if the list contains the our project key, the
    ;; directory name
    (when (contains directory-name list-of-path-parts)
      ;; publish the org project
      (org-publish-project "org"))))
;; @todo change this to only add-hook if not in list
(add-hook 'after-save-hook 'my-org-after-save-hook)


;;; Define some kbd shortcuts for publishing the project
(keymap-global-set "C-c o P" 'my-org-publish-force)
(keymap-global-set "C-c o p" 'my-org-publish)

(defvar my-org-index-nav
  '(about projects contact))
(defvar my-org-nav-item-template
  "<li id=\"nav-%s\"><a href=\"#%s\">%s</a></li>")
(defvar my-org-nav-template
  "<header><nav><ul>%s</ul></nav></header>"
  "The template that gets formatted to produce the full navigation HTML.")
(defvar my-org-nav-html
  ""
  "The HTML for the navigation of each page. Set by later function.")

(defun my-org-build-navigation-html (navlist)
  "Get the html for the nav section, built from a list"
  (let ((formatted-item nil)
	(inside-html "<li><a href=\"#title\"><h1>%t</h1><h3>%s</h3></a>"))
    
    (dolist
	;;; (list-item/element, list to loop through,
	;;;    &optional return element )
	(list-item navlist)
      (setq formatted-item
	    (format my-org-nav-item-template
		    list-item list-item list-item))
      (setq inside-html
	    (concat inside-html formatted-item)))
    (setq my-org-nav-html (format my-org-nav-template inside-html)))
  )

;;; Build the html sections that should go on each page
(my-org-build-navigation-html my-org-index-nav)

;;;;;; Set org export variables
;;;;;;
;;; Don't export the Table of Contents
(setq org-export-with-toc nil)
;;; Don't export drawers
(setq org-export-with-drawers nil)
;;; Don't export section numbers
(setq org-export-with-section-numbers nil)
;;; Mark broken links
(setq org-export-with-broken-links 'mark)
;;; Remove the standard title
(setq org-export-with-title nil)

;;;;;;
;;;;;; Set HTML-specific export variables
;;;;;;
;;; Replace the title custom preamble
(setq org-html-preamble t)
;;; Define the preamble format for each language here
(setq org-html-preamble-format
      `(("en" ,my-org-nav-html)))
;;; Customize Postamble
(setq org-html-postamble nil)
;;; Include stylesheet in the head
(setq org-html-head "<link rel=\"stylesheet\" href=\"styles.css\">")
(setq org-html-head-extra nil)
;;; No JavaScript for now
(setq org-html-head-include-scripts nil)
;;; Set our own styles in org-html-head per spec
(setq org-html-head-include-default-style nil)
;;; Not using InfoJS
(setq org-html-use-infojs nil)
;;; Scripts are also set in the org-html-head, if needed
(setq org-html-scripts nil)
;;; Using new HTML5 elements
(setq org-html-html5-fancy t)
;;; Using html5 doctype
(setq org-html-doctype "html5")
;;; Defaults to div, but I like it to be obvious
(setq org-html-container-element "div")
;;; Defaults to content, but I like it to be obvious
(setq org-html-content-class "content")

;;;;;;
;;;;;; Setup org projects for each export type
;;;;;;
(setq org-publish-project-alist
      '(
	;;; Org Notes exports .org files to HTML5
	("org-notes"
	 :base-directory "~/code/static-streamline/src/"
	 :base-extension "org"
	 :publishing-directory "~/code/static-streamline/public/"
	 :recursive t
	 :publishing-function org-html-publish-to-html
	 :headline-levels 4
	 :auto-preamble t)
	("org-static"
	 :base-directory "~/code/static-streamline/src/"
	 :base-extension "css\\|js\\|png\\|jpg\\|jpeg\\|gif"
	 :publishing-directory "~/code/static-streamline/public/"
	 :recursive t
	 :publishing-function org-publish-attachment)
	("org" :components ("org-notes" "org-static"))
	))
