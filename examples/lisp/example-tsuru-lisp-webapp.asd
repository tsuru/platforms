(asdf:defsystem #:example-tsuru-lisp-webapp
    :serial t
    :description "Example lisp app for tsuru"
    :author "Nick Ricketts"
    :license ""
    :depends-on ("alexandria" "wookie")
    :components ((:file "package")
		 (:file "web")))
