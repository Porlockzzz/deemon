(ql:quickload "analyzer")
(load "./main2.lisp")

(handler-case
    (analyzer:main)
  (sb-sys:interactive-interrupt ()
    (FORMAT T "user invoked shutdown"))
  (error (e)
    (FORMAT T "encountered fatal error '~a'~%" e)))