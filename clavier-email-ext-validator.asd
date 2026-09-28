(defsystem clavier-email-ext-validator
  :version "0.1.0"
  :author "Dmitrii Kosenkov"
  :license "MIT"
  :description "Extended email validator for Clavier"
  :homepage "https://github.com/Junker/clavier-email-ext-validator"
  :source-control (:git "https://github.com/Junker/clavier-email-ext-validator.git")
  :depends-on ("clavier" "email-parse" "dns-client" "closer-mop")
  :components ((:file "validator"))
  :in-order-to ((test-op (test-op "clavier-email-ext-validator/tests"))))

(defsystem clavier-email-ext-validator/tests
  :depends-on ("clavier-email-ext-validator" "parachute")
  :components ((:file "tests"))
  :perform (test-op (o c) (uiop:symbol-call :parachute :test
                                            :clavier-email-ext-validator/tests)))
