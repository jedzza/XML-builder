;;;; XML-editor.asd

(asdf:defsystem #:XML-editor
  :description "Describe XML-editor here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:clog #:xmls)
  :components ((:file "package")
               (:file "XML-editor")))
