(defsystem "clavier-email-ext-validator"
  :version "0.1.0"
  :author "Dmitrii Kosenkov"
  :license "MIT"
  :depends-on ("clavier" "email-parse" "dns-client")
  :components ((:file "package")
               (:file "validator")))
