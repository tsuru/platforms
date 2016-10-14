(in-package #:web)

(defroute (:get "/") (req res)
  (send-response res :body "Hello world from tsuru"))

(defun start ()
  (with-event-loop (:catch-app-errors t)
    (start-server (make-instance 'listener :port 8888))))
