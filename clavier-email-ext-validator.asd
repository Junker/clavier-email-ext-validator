(defsystem clavier-email-ext-validator
  :version "0.1.0"
  :author "Dmitrii Kosenkov"
  :license "MIT"
  :description "Extended email validator for Clavier"
  :homepage "https://github.com/Junker/clavier-email-ext-validator"
  :source-control (:git "https://github.com/Junker/clavier-email-ext-validator.git")
  :depends-on ("clavier" "email-parse" "dns-client")
  :components ((:file "package")
               (:file "validator")))
