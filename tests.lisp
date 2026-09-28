(defpackage #:clavier-email-ext-validator/tests
  (:use #:cl #:parachute)
  (:local-nicknames (#:v #:clavier-email-ext-validator)
                    (#:dns #:org.shirakumo.dns-client)))
(in-package #:clavier-email-ext-validator/tests)

(define-test email-ext-validator)

(define-test parse-guards :parent email-ext-validator
  (let ((v (make-instance 'v:email-ext-validator)))
    (false (clavier:validate v "not-an-email" :error-p nil))
    (true (clavier:validate v "user@example.com"))))

(define-test disposable :parent email-ext-validator
  (let ((v (make-instance 'v:email-ext-validator
                          :reject-disposable t
                          :disposable-domains '("mailinator.com"))))
    (true (clavier:validate v "u@example.com"))
    (false (clavier:validate v "u@mailinator.com" :error-p nil))
    (false (clavier:validate v "u@MAILINATOR.com" :error-p nil))))

(define-test host-check :parent email-ext-validator
  (let ((v (make-instance 'v:email-ext-validator :host-check t)))
    (true (clavier:validate v "user@google.com"))
    (false (clavier:validate v "user@this-domain-does-not-exist-xyz-12345.com"
                            :error-p nil))))

(define-test mx-check :parent email-ext-validator
  (let ((v (make-instance 'v:email-ext-validator :mx-check t)))
    (true (clavier:validate v "user@google.com"))
    (false (clavier:validate v "user@this-domain-does-not-exist-xyz-12345.com"
                            :error-p nil))))

(define-test outage-signals :parent email-ext-validator
  (let ((v (make-instance 'v:email-ext-validator :mx-check t))
        (dns:*dns-servers* '("192.0.2.1"))) ; TEST-NET-1.
    (fail (clavier:validate v "user@example.com")
        'dns:dns-servers-exhausted)))

(define-test validation-error-message :parent email-ext-validator
  (let ((v (make-instance 'v:email-ext-validator)))
    (is string= "The email is invalid: not-an-email"
        (nth-value 1 (clavier:validate v "not-an-email" :error-p nil)))))
