;;;; XML-editor.lisp

(defpackage #:XML-editor
  (:use #:cl #:clog #:xmls)
  export (||)
  (in-package #:XML-editor)

  (defvar colors '("bg-light" "bg-secondary" "bg-white" "bg-dark"))
(defvar text '("text-dark" "text-white" "text-dark" "text-white"))
(defvar output "")
(defvar allowed-list '())

(defun setup (body)
  (load-css (html-document body) "https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css")
  (load-script (html-document body) "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js")
  (load-script (html-document body) "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js")
  (let* (
         (clear-allowed-list)
         (schema-div (create-div body))
         (schema-content (create-text-area schema-div :label
                                       (create-label schema-div :content "paste the schema here")))
         (XML-content (create-text-area schema-div :label
                                        (create-label schema-div :content "paste existing XML here to edit")))
         (schema-commit-button (create-button schema-div :content "submit schema"))
         (XML-commit-button (create-button schema-div :content "Load XML"))
         (output-button (create-button schema-div :content "Write XML to file"))
         (schema (xmls:make-xmlrep ""))
	 (viewer (create-div body :content "<iframe src=\"http://127.0.0.1:4242/passport.xml\"></iframe>"))
         (view-results (create-a schema-div :content "view results" :link "http://127.0.0.1:4242/passport.xml" ))
         )
    (set-on-click XML-commit-button
                  (lambda (obj)
                   (setf (text-value viewer) (format nil "<iframe srcdoc=\"~a\"></iframe>"output))))
    (set-on-click schema-commit-button
                  (lambda (obj)
                    (setf schema (xmls:parse (text-value schema-content)))
                    (clear-allowed-list)
                    (next-element '() schema)
                    (root-element schema output-button schema-div)))))

(defun root-element (schema output-button parent-div)
  (let* (
         (newlist (create-local-allowed-list allowed-list))
         (root (xmls:make-node))
         (root-div (create-div parent-div :class  "bg-secondary text-white"))
         (debug-div (create-div root-div :content "create Root element"))
         (select (create-select root-div))
         (submit-root (create-button root-div :content "submit"))
         (xml-button (create-button root-div :content "(DEBUG) display XML"))
         )
    (loop for x in newlist
          do (setf option (create-option select :content x)))
    (set-on-click xml-button
                  (lambda (obj)
                    (setf (text-value debug-div)(write (xmls:toxml root)))))
     (set-on-click output-button
                  (lambda (obj)
                    (setf output (concatenate 'string
                                              "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
                                              <?xml-stylesheet type=\"text/xsl\" href=\"MAP_stylesheet.xsl\"?>"
                                              (xmls:toxml root)))
                    (with-open-file (stream (merge-pathnames #p"/Users/jedic/quicklisp/dists/quicklisp/software/hunchentoot-v1.3.0/www/passport.xml"
                                                             (user-homedir-pathname))
                      :direction :output
                    :if-exists :supersede
                    :if-does-not-exist :create)
                  (format stream (print output)))))
    (set-on-click submit-root
                  (lambda (obj)
                    (clear-allowed-list)
                    (next-element (list (text-value select)) schema)
                    (setf (xmls:node-name root) (text-value select))
                    (first-child schema (text-value select) root-div root (list (text-value select)))))))

(defun first-child (schema nodename parent-element parent-node namespace)
  (let*(
        (newlist (create-local-allowed-list allowed-list))
        (new-namespace namespace)
        (child-div (create-div parent-element :class "bg-secondary text-white"))
        (child-content (create-div child-div :content (concatenate 'string "add child element to " nodename )))
        (select (create-select child-div))
        (child-submit-button (create-button child-div :content "add child")))
   ; (push xml-node (xmls:node-children parent-node))
 (loop for x in newlist
          do (setf option (create-option select :content x)))
    (set-on-click child-submit-button
                  (lambda (obj)
                    (setf new-namespace (append namespace (list (text-value select))))
                    (clear-allowed-list)
                    (next-element new-namespace schema)
                  ;  (setf (xmls:node-name xml-node) (text-value select))
                    (form-generate schema (text-value select) parent-element parent-node new-namespace)))))

(defun form-generate (schema nodename parent-element parent-node namespace)
  (let* (
         (newlist (create-local-allowed-list allowed-list))
         (xml-node (xmls:make-xmlrep nodename))
         (new-namespace namespace)
         (color (elt colors (mod (length new-namespace) 4)))
         (text (elt text (mod (length new-namespace) 4)))
         (node-body (create-div parent-element :class (format nil "p-2 rounded m-2 ~a ~a" color text)))
         (debug (create-section node-body :h4  :content namespace))
         (br (create-br node-body))
         (content-label (create-div node-body :content  (concatenate 'string "content for " nodename)))
         (node-content (create-text-area node-body))
         (child-label (create-div node-body :content (concatenate 'string "add child element to " nodename " options are: ")))
        ; (child-name (create-text-area node-body))
         (select (create-select node-body))
         (start-button (create-button node-body :content "Add a Child"))
         (delete-button (create-button node-body :content "Delete this element"))
         )
    (loop for x in newlist
          do (setf option (create-option select :content x)))
    (if (not (equalp allowed-list nil)) (setf (hiddenp content-label) t))
    (if (not (equalp allowed-list nil)) (setf (hiddenp node-content) t))
    (if (equalp allowed-list nil) (setf (hiddenp select) t))
    (if (equalp allowed-list nil) (setf (hiddenp start-button) t))
    (if (equalp allowed-list nil) (setf (hiddenp child-label) t))
    (if (equalp (xmls:node-children parent-node) nil)
        (push xml-node (xmls:node-children parent-node))
        (push xml-node (cdr (last (xmls:node-children parent-node)))))
    (set-on-click delete-button
                  (lambda (obj)
                    (setf (xmls:node-children parent-node) (remove xml-node (xmls:node-children parent-node)))
                    (destroy node-body)))
    (set-on-change node-content
                   (lambda (obj)
                     (setf (xmls:node-children xml-node) '())
                     (push (text-value node-content) (xmls:node-children xml-node))))
    (set-on-click start-button
                  (lambda (obj)
                    (setf new-namespace (append namespace (list (text-value select))))
                    (clear-allowed-list)
                    (next-element new-namespace schema)
                    (form-generate schema (text-value select) node-body xml-node new-namespace)))))

(defun load-XML (schema node)
  )



(defun clear-allowed-list ()
  (setf allowed-list '()))

(defun add-all-valid-children (node)
  (dolist (x (xmls:node-children node))
    (cond ((not (or (equalp (xmls:node-name x) "element") (equalp (xmls:node-name x) "attribute"))) (add-all-valid-children x))
          (t (push (xmls:xmlrep-attrib-value "name" x) allowed-list)))))

(defun next-element (namespace root-node)
  (if (equalp namespace nil)
      (dolist (x (xmls:node-children root-node))
        (add-all-valid-children root-node))
      (dolist (x (xmls:node-children root-node))
        (cond ((not (or (equalp (xmls:node-name x) "element") (equalp (xmls:node-name x) "attribute"))) (next-element namespace x))
              ((equalp (xmls:xmlrep-attrib-value "name" x) (car namespace))
               (cond ((equalp (cdr namespace) nil) (add-all-valid-children x))
                     (t (next-element (cdr namespace) x))))))))

(defun create-local-allowed-list (list)
  (loop for x in list
        collect x))

(defun || ()
  (initialize 'setup
	      :static-root (merge-pathnames "./www/"
			     (asdf:system-source-directory :XML-editor)))
  (open-browser))
