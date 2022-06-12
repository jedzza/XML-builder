(ql:quickload :clog)
(ql:quickload :xmls)
(ql:quickload :cl-ppcre)
(ql:quickload :xuriella)
(defpackage #:XML-GUI
  (:use #:cl #:clog #:clog-gui #:XMLS #:ppcre)
  (:export start-app))

(in-package XML-GUI)

;CLOG uses asdf to configure the directory for static file serving - I couldn't get it working reliably
;so I have created an acceptor to serve images etc that looks in the "./www" directory to make it portable
;TODO work out why asdf isn't working to reduce the need for an extra port
(defvar *acceptor* (make-instance 'hunchentoot:easy-acceptor
        :port 4242
        :document-root (truename "./www/")))

;these just here for making the editor easier to read. Global variables for DRY reasons. TODO write some css that makes these
;unecessary
(defvar *colors* '("bg-light" "bg-secondary" "bg-white" "bg-dark"))
(defvar *text* '("text-dark" "text-white" "text-dark" "text-white"))

;for finding namespaces - a hack from early on in the process TODO get rid of this
(defvar *allowed-list* '())

;to handle the loaded XML and schema prior to launching the builder window - can't seem to get the functions in the menu
;to alter a locally created version and hand this to the window functions TODO work out why and make these loacl variables
(defvar *schema* "")
(defvar *loaded* (xmls:make-node))

;Open a dialogue and save given S expression to file as XML. TODO Allow for user to specify stylesheet.
(defun save-file (node)
  (lambda (obj)
     (server-file-dialog obj "save" "./www/" (lambda (fname)
                                         (cond ((not (equalp fname nil))
                                                (let (
                                                      (string (concatenate 'string "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
                                         <?xml-stylesheet type=\"text/xsl\" href=\"MAP_stylesheet.xsl\"?>" (xmls:toxml node)))
                                                      )
                                                (with-open-file
                                                 (stream (merge-pathnames fname
                                                                  (user-homedir-pathname))
                                              :direction :output
                                              :if-exists :supersede
                                              :if-does-not-exist :create)
                                               (format stream (print string))))))))))
(defun view-output (node)
  (lambda (obj)
  (let* (
         (stylesheet (xuriella:parse-stylesheet #p"/Users/jedic/common-lisp/XML-builder-GUI/www/MAP_stylesheet.xsl"))
         (display (xuriella:apply-stylesheet stylesheet (xmls:toxml node) :output nil))
         (display (ppcre:regex-replace-all "\"" display "'"))
         (display (ppcre:regex-replace-all "&" display "&amp;amp;"))
         (output-view (create-gui-window obj
				   :title   (xmls:node-name node)
				   :width   800
				   :height  800
                   :top 100
                   :client-movement nil))
         (button (create-button (window-content output-view) :content "refresh"))
         (tmp (create-div (window-content output-view) :content (format nil
                                                                        "<iframe srcdoc=\"~a\" height='800' width='800'></iframe>" display)))
         )
    (set-on-click button
                  (lambda (obj)
                    (let* (
                    (stylesheet (xuriella:parse-stylesheet #p"/Users/jedic/common-lisp/XML-builder-GUI/www/MAP_stylesheet.xsl"))
                    (display (xuriella:apply-stylesheet stylesheet (xmls:toxml node) :output nil))
                    (display (ppcre:regex-replace-all "\"" display "'"))
                    (display (ppcre:regex-replace-all "&" display "&amp;amp;"))
                    )
                    (destroy tmp)
                    (setf tmp (create-div (window-content output-view) :content
                                          (format nil "<iframe srcdoc=\"~a\" height='800' width='800'></iframe>" display)))))))))

;takes a pathname and returns file contents as a string
(defun read-file (infile)
  (with-open-file (instream infile :direction :input :if-does-not-exist nil)
    (when instream
      (let ((string (make-string (file-length instream))))
        (read-sequence string instream)
        string))))

;load schema from a file TODO remove need for global variable here
(defun load-schema (obj)
  (server-file-dialog obj "choose schema" "./www/" (lambda (fname)
                                                 (setf *schema* (xmls:parse (read-file fname))))))

;Load XML from a file TODO remove need for global variable here
(defun load-XML (obj)
    (server-file-dialog obj "load XML" "./www/" (lambda (fname)
                                            (setf *loaded* (xmls:parse (read-file fname))))))

;A popup window to view the currently loaded XML outside of the editor TODO another global variable to purge
(defun view-loaded-xml (obj)
    (let* (
         (XML (create-gui-window obj
                                 :top 100
                                 :title (format nil "~a XML" (xmls:node-name *loaded*))
                                 :content (xmls:toxml (xmls:toxml *loaded*)))))))

;View the loaded schema outside the editor TODO global variable
(defun view-schema (obj)
  (let* ((about (create-gui-window obj
				   :title   "About"
				   :content (xmls:toxml (xmls:toxml *schema*))
				   :width   800
				   :height  800
                   :top 100
                   :client-movement t)))))

;View the XML local to the current editor window
(defun view-xml (node)
(lambda (obj)
  (let* (
         (XML (create-gui-window obj
                                 :top 100
                                 :title (format nil "~a XML" (xmls:node-name node))
                                 :content (xmls:toxml (xmls:toxml node))))))))

;opens a window to create a new XML document using the loaded schema TODO *schema* global variable
(defun builder (obj)
  (let* (
        (new-root (xmls:make-node))
        (output-view (create-gui-window obj
				   :title   "XML-Builder"
				   :width   800
				   :height  800
                   :top 100
                   :client-movement t))
        (menu (create-gui-menu-bar (window-content output-view) :class "w3-red"))
        (tmp (create-gui-menu-icon menu :image-url "http://127.0.0.1:4242/img/M-Wrike.png" :class "w3-white"))
        (file (create-gui-menu-drop-down menu :content "file"))
        (tmp (create-gui-menu-item file :content "save"))
        (tmp (create-gui-menu-item file :content "save as" :on-click (save-file new-root)))
        (view (create-gui-menu-drop-down menu :content "view"))
        (tmp (create-gui-menu-item view :content "view XML" :on-click (view-xml new-root)))
        (tmp (create-gui-menu-item view :content "view the output" :on-click (view-output new-root)))
        (builder-body (create-div (window-content output-view)))
        )
    (clear-allowed-list)
    (next-element '() *schema*)
    (root-element builder-body new-root)))

;creates a window and then populates it with the appropriate HTML for loading an XML file with a schema
;TODO *schema* again
(defun editor (obj)
  (let* (
         (new-root (xmls:make-node))
         (win (create-gui-window obj
                                 :title "XML-Builder"
                                 :width 800
                                 :height 800
                                 :top 100
                                 :client-movement t))
        (menu (create-gui-menu-bar (window-content win) :class "w3-red"))
        (tmp (create-gui-menu-icon menu :image-url "http://127.0.0.1:4242/img/M-Wrike.png" :class "w3-white"))
        (file (create-gui-menu-drop-down menu :content "file"))
        (tmp (create-gui-menu-item file :content "save"))
        (tmp (create-gui-menu-item file :content "save as" :on-click (save-file new-root)))
        (view (create-gui-menu-drop-down menu :content "view"))
        (tmp (create-gui-menu-item view :content "view XML" :on-click (view-xml new-root) ))
        (tmp (create-gui-menu-item view :content "view the output" :on-click (view-output new-root)))
        (builder-body (create-div (window-content win)))
         )
    (clear-allowed-list)
    (next-element '() *schema*)
    (xml-load new-root builder-body)))

;opens a window to allow for freeform creation of an XML document
(defun creator (obj)
 (let* (
         (new-root (xmls:make-node))
         (win (create-gui-window obj
                                 :title "XML-Builder"
                                 :width 800
                                 :height 800
                                 :top 100
                                 :client-movement t))
        (menu (create-gui-menu-bar (window-content win) :class "w3-red"))
        (tmp (create-gui-menu-icon menu :image-url "http://127.0.0.1:4242/img/M-Wrike.png" :class "w3-white"))
        (file (create-gui-menu-drop-down menu :content "file"))
        (tmp (create-gui-menu-item file :content "save"))
        (tmp (create-gui-menu-item file :content "save as" :on-click (save-file new-root)))
        (view (create-gui-menu-drop-down menu :content "view"))
        (tmp (create-gui-menu-item view :content "view XML" :on-click (view-xml new-root) ))
        (tmp (create-gui-menu-item view :content "view the output" :on-click (view-output new-root)))
        (builder-body (create-div (window-content win)))
         )
    (freeform-root-element builder-body new-root)))

(defun freeform-editor (obj)
 (let* (
         (new-root (xmls:make-node))
         (win (create-gui-window obj
                                 :title "XML-Builder"
                                 :width 800
                                 :height 800
                                 :top 100
                                 :client-movement t))
        (menu (create-gui-menu-bar (window-content win) :class "w3-red"))
        (tmp (create-gui-menu-icon menu :image-url "http://127.0.0.1:4242/img/M-Wrike.png" :class "w3-white"))
        (file (create-gui-menu-drop-down menu :content "file"))
        (tmp (create-gui-menu-item file :content "save"))
        (tmp (create-gui-menu-item file :content "save as" :on-click (save-file new-root)))
        (view (create-gui-menu-drop-down menu :content "view"))
        (tmp (create-gui-menu-item view :content "view XML" :on-click (view-xml new-root) ))
        (tmp (create-gui-menu-item view :content "view the output" :on-click (view-output new-root)))
        (builder-body (create-div (window-content win)))
         )
    (freeform-xml-load new-root builder-body)))


;pretty sure this isn't necessary but got added in early in the proceess TODO get rid
(defun clear-allowed-list ()
  (setf *allowed-list* '()))

;loops recursively over the schema looking for elements or attributes which are valid to add as children
(defun add-all-valid-children (node)
  (dolist (x (xmls:node-children node))
    (if (xmls:node-p x)
        (cond ((not (or (equalp (xmls:node-name x) "element") (equalp (xmls:node-name x) "attribute"))) (add-all-valid-children x))
          (t (push (xmls:xmlrep-attrib-value "name" x) *allowed-list*))))))

;loops over the schema given a path(namespace) and looks for the next "element" or "attribute" - totally ignores everthing else
;TODO grow this into a fully fleshed XSD reader that returns a set of instructions
(defun next-element (namespace root-node)
  (if (equalp namespace nil)
      (dolist (x (xmls:node-children root-node))
        (add-all-valid-children root-node))
      (dolist (x (xmls:node-children root-node))
        (if (xmls:node-p x)
            (cond ((not (or (equalp (xmls:node-name x) "element") (equalp (xmls:node-name x) "attribute"))) (next-element namespace x))
              ((equalp (xmls:xmlrep-attrib-value "name" x) (car namespace))
               (cond ((equalp (cdr namespace) nil) (add-all-valid-children x))
                     (t (next-element (cdr namespace) x)))))))))

;TODO almost certainly unecessary
(defun create-local-allowed-list (list)
  (loop for x in list
        collect x))

;creates an s expression representation of XML element and builds a form which allows for interractive filling in of the
;element - does not support attributes (none of the editors do)
(defun freeform-form-generate (nodename parent-element parent-node namespace &optional node-text)
  (let* (
         (xml-node (xmls:make-xmlrep nodename))
         (new-namespace namespace)
         (color (elt *colors* (mod (length new-namespace) 4)))
         (text (elt *text* (mod (length new-namespace) 4)))
         (node-body (create-div parent-element :class (format nil "p-2 rounded m-2 ~a ~a" color text)))
         (debug (create-section node-body :h4  :content namespace))
         (br (create-br node-body))
         (content-label (create-div node-body :content  (concatenate 'string "content for " nodename)))
         (node-content (create-text-area node-body))
         (child-label (create-div node-body :content (concatenate 'string "add child element to " nodename)))
         (select (create-text-area node-body))
         (start-button (create-button node-body :content "Add a Child"))
         (delete-button (create-button node-body :content "Delete this element"))
         )
    (cond ((not (equalp node-text nil))
           (setf (text-value node-content) node-text)
           (setf (xmls:node-children xml-node) '())
           (push (text-value node-content) (xmls:node-children xml-node))))
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
                    (freeform-form-generate (text-value select) node-body xml-node new-namespace)))
    (values (text-value select) node-body xml-node new-namespace)))

;Same as above but schema aware - the oprional argument is to allow for fillin in the fields when rebuilding
;state from a loaded XML doc
(defun form-generate (nodename parent-element parent-node namespace &optional node-text)
  (let* (
         (newlist (create-local-allowed-list *allowed-list*))
         (xml-node (xmls:make-xmlrep nodename))
         (new-namespace namespace)
         (color (elt *colors* (mod (length new-namespace) 4)))
         (text (elt *text* (mod (length new-namespace) 4)))
         (node-body (create-div parent-element :class (format nil "p-2 rounded m-2 ~a ~a" color text)))
         (debug (create-section node-body :h4  :content namespace))
         (br (create-br node-body))
         (content-label (create-div node-body :content  (concatenate 'string "content for " nodename)))
         (node-content (create-text-area node-body))
         (child-label (create-div node-body :content (concatenate 'string "add child element to " nodename " options are: ")))
         (select (create-select node-body))
         (start-button (create-button node-body :content "Add a Child"))
         (delete-button (create-button node-body :content "Delete this element"))
         )
    (cond ((not (equalp node-text nil))
           (setf (text-value node-content) node-text)
           (setf (xmls:node-children xml-node) '())
           (push (text-value node-content) (xmls:node-children xml-node))))
    (loop for x in newlist
          do (setf option (create-option select :content x)))
    (if (not (equalp newlist nil)) (setf (hiddenp content-label) t))
    (if (not (equalp newlist nil)) (setf (hiddenp node-content) t))
    (if (equalp newlist nil) (setf (hiddenp select) t))
    (if (equalp newlist nil) (setf (hiddenp start-button) t))
    (if (equalp newlist nil) (setf (hiddenp child-label) t))
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
                    (next-element new-namespace *schema*)
                    (form-generate (text-value select) node-body xml-node new-namespace)))
    (values (text-value select) node-body xml-node new-namespace)))

;After the root value has been chosen, this function allows for the choosing of elements 1 level below
(defun freeform-first-child (nodename parent-element parent-node namespace)
  (let*(
        (new-namespace namespace)
        (child-div (create-div parent-element :class "bg-secondary text-white"))
        (child-content (create-div child-div :content (concatenate 'string "add child element to " nodename )))
        (select (create-text-area child-div))
        (child-submit-button (create-button child-div :content "add child"))
        )
    (set-on-click child-submit-button
                  (lambda (obj)
                    (setf new-namespace (append namespace (list (text-value select))))
                    (freeform-form-generate (text-value select) parent-element parent-node new-namespace)))
    (values (text-value select) parent-element parent-node new-namespace)))

;same as above but schema aware
  (defun first-child (nodename parent-element parent-node namespace)
  (let*(
        (newlist (create-local-allowed-list *allowed-list*))
        (new-namespace namespace)
        (child-div (create-div parent-element :class "bg-secondary text-white"))
        (child-content (create-div child-div :content (concatenate 'string "add child element to " nodename )))
        (select (create-select child-div))
        (child-submit-button (create-button child-div :content "add child"))
        )
 (loop for x in newlist
          do (setf option (create-option select :content x)))
    (set-on-click child-submit-button
                  (lambda (obj)
                    (setf new-namespace (append namespace (list (text-value select))))
                    (clear-allowed-list)
                    (next-element new-namespace *schema*)
                    (form-generate (text-value select) parent-element parent-node new-namespace)))
    (values (text-value select) parent-element parent-node new-namespace)))

;create the root element of the schema
(defun freeform-root-element (parent-div root)
  (let* (
         (root-div (create-div parent-div :class  "bg-secondary text-white"))
         (debug-div (create-div root-div :content "create Root element"))
         (select (create-text-area root-div))
         (submit-root (create-button root-div :content "submit"))
         )
    (set-on-click submit-root
                  (lambda (obj)
                    (setf (xmls:node-name root) (text-value select))
                    (freeform-first-child (text-value select) root-div root (list (text-value select)))))
    (values (text-value select) root-div root (list (text-value select)))))

;same as above but with schema
(defun root-element (parent-div root)
  (let* (
         (newlist (create-local-allowed-list *allowed-list*))
         (root-div (create-div parent-div :class  "bg-secondary text-white"))
         (debug-div (create-div root-div :content "create Root element"))
         (select (create-select root-div))
         (submit-root (create-button root-div :content "submit"))
         )
    (loop for x in newlist
          do (setf option (create-option select :content x)))
    (set-on-click submit-root
                  (lambda (obj)
                    (clear-allowed-list)
                    (next-element (list (text-value select)) *schema*)
                    (setf (xmls:node-name root) (text-value select))
                    (first-child (text-value select) root-div root (list (text-value select)))))
    (values (text-value select) root-div root (list (text-value select)))))

;given an xml document, this loops over it and recreates the appropriate state so that you can keep editing it
(defun xml-load (node div)
  (multiple-value-bind (root-name root-div new-root namespace)(root-element div node)
    (clear-allowed-list)
    (next-element namespace *schema*)
    (setf (xmls:node-name node) (xmls:node-name *loaded*))
    (multiple-value-bind (child-name parent-element parent-node namespace)(first-child root-name root-div node namespace)

    ;now we have set up the root node, we need to recurse through all children, and call form-generate each call to form generate will need
    ;to be passed the appropriate variables
    (loop for x in (xmls:node-children *loaded*)
          do (printer x parent-element parent-node namespace)))))

(defun freeform-xml-load (node div)
  (multiple-value-bind (root-name root-div new-root namespace)(freeform-root-element div node)
    (setf (xmls:node-name node) (xmls:node-name *loaded*))
    (multiple-value-bind (child-name parent-element parent-node namespace)(freeform-first-child (xmls:node-name *loaded*) root-div node namespace)

    ;now we have set up the root node, we need to recurse through all children, and call form-generate each call to form generate will need
    ;to be passed the appropriate variables
    (loop for x in (xmls:node-children *loaded*)
          do (freeform-printer x parent-element parent-node namespace)))))

;same function as above, this is the recursive part - used to create all the parts below the root element
(defun printer (node parent-div parent-node namespace)
      (if (xmls:node-p node)
       (let*(
        (new-namespace namespace)
        )
    (setf new-namespace (append namespace (list (xmls:node-name node))))
    (clear-allowed-list)
    (next-element new-namespace *schema*)
        (loop for x in (xmls:node-children node)
            do (cond ((xmls:node-p x)
                      (multiple-value-bind (nodename parent-element new-parent-node namespace)
                          (form-generate (xmls:node-name node) parent-div parent-node new-namespace)
                      (printer x parent-element new-parent-node namespace)))
                     (t
                      (setf (xmls:node-children parent-node) (remove x (xmls:node-children parent-node)))
                      (form-generate (xmls:node-name node) parent-div parent-node new-namespace x)))))))

;TODO this will have the same function as above, but for loading XML without a schema - not currently called from anywhere
(defun freeform-printer (node parent-div parent-node namespace)
  (if (xmls:node-p node)
      (let* (
             (new-namespace namespace)
             )
        (setf new-namespace (append namespace (list (xmls:node-name node))))
        (loop for x in (xmls:node-children node)
              do (cond ((xmls:node-p x)
                        (multiple-value-bind (nodename parent-element new-parent-node namespace)
                            (freeform-form-generate (xmls:node-name node) parent-div parent-node new-namespace)
                          (freeform-printer x parent-element new-parent-node namespace)))
                       (t
                        (setf (xmls:node-children parent-node) (remove x (xmls:node-children parent-node)))
                        (freeform-form-generate (xmls:node-name node) parent-div parent-node new-namespace x)))))))


;sets up the root menu TODO allow for loading alternative stylesheets
(defun on-new-window (body)
 (if (not (hunchentoot:started-p *acceptor*))
  (hunchentoot:start *acceptor*))
  (load-css (html-document body) "https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css")
  (load-script (html-document body) "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js")
  (load-script (html-document body) "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js")
  (setf (title (html-document body)) "Mattereum XML tool")
  (clog-gui-initialize body)
  (let* (
         (menu (create-gui-menu-bar body :class "w3-red"))
         (tmp (create-gui-menu-icon menu :image-url "http://127.0.0.1:4242/img/M-Wrike.png" :class "w3-white"))
         (file (create-gui-menu-drop-down menu :content "file"))
         (tmp (create-gui-menu-item file :content "load schema" :on-click 'load-schema))
         (tmp (create-gui-menu-item file :content "load XML file" :on-click 'load-XML))
         (view (create-gui-menu-drop-down menu :content "view"))
         (tmp (create-gui-menu-item view :content "view the schema" :on-click 'view-schema))
         (tmp (create-gui-menu-item view :content "view the XML" :on-click 'view-loaded-xml))
         (Run (create-gui-menu-drop-down menu :content "Run"))
         (tmp (create-gui-menu-item Run :content "structured create (schema loaded)" :on-click 'builder))
         (tmp (create-gui-menu-item Run :content "edit XML (with schema)" :on-click 'editor))
         (tmp (create-gui-menu-item Run :content "freeform create (no schema)" :on-click 'creator))
         (tmp (create-gui-menu-item Run :content "edit XML (no schema)" :on-click 'freeform-editor))
         (help (create-gui-menu-drop-down menu :content "help"))
         (tmp (create-a help :content "schema builder" :link "https://www.freeformatter.com/xsd-generator.html"))
         (tmp (create-gui-menu-item help :content "view the documentation")))))

;run the app
(defun start-app ()
  (initialize 'on-new-window)
  (open-browser))
