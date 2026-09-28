;;; imood.el --- imood.com through emacs -*- lexical-binding: t; -*-

;;; Author: Benjamin (svn)
;;; License: UNLICENSE (https://unlicense.org/)

;;; Commentary:

;; Update, and view moods through Emacs

;;; Code:

(require 'dom)


(defun imood--get (url)
  "Returns request to a given `URL'"
  (with-current-buffer (url-retrieve-synchronously url t)
    (prog1
        (list url-http-response-status (buffer-substring-no-properties url-http-end-of-headers (point-max)))
      (kill-buffer))))

(defun imood--html-to-xml-list (html)
  "Unwraps an HTML request to get the XML and convert it to a list."
  (with-temp-buffer
    (insert html)
    (nth 2 (nth 2 (libxml-parse-html-region (point-min) (point-max))))))

(defun imood//get-mood-list ()
  "Returns full list of moods"
  (let ((resp (imood--get "https://xml.imood.org/moods.cgi"))) ;; request
    (if (= (car resp) 200) ;; Error checking
        (let ((xml (imood--html-to-xml-list (cadr resp))))
          ;; Find all moods then put it into a list, also remove newline at the end
          (mapcar (lambda (mood) (replace-regexp-in-string "\n" "" (nth 3 mood))) (dom-by-tag xml 'mood)))
      (message (format "Request sent back %i" (car resp)))))) ;; If we don't get back 200 then tell user

(defun imood//get-current-mood (email)
  (let ((resp (imood--get (concat "https://xml.imood.org/query.cgi?email=" email)))) ;; request
    (if (= (car resp) 200) ;; Error checking
        (let ((xml (imood--html-to-xml-list (cadr resp))))
          xml)
      (message (format "Request sent back %i" (car resp)))))
  )

(defun imood//get-own-current-mood ()
  (imood//get-current-mood imood//email))

(imood//get-mood-list)

(imood//get-own-current-mood)

;;; imood.el ends here
