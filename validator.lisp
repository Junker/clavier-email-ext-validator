(defpackage clavier-email-ext-validator
  (:use #:cl #:clavier)
  (:export #:email-ext-validator))
(in-package #:clavier-email-ext-validator)

(defclass email-ext-validator (clavier:validator)
  ((reject-disposable :type boolean
                      :initarg :reject-disposable
                      :initform nil
                      :accessor validator-reject-disposable)
   (host-check :type boolean
               :initarg :host-check
               :initform nil
               :accessor validator-host-check)
   (mx-check :type boolean
             :initarg :mx-check
             :initform nil
             :accessor validator-mx-check)
   (disposable-domains :type list
                       :initarg :disposable-domains
                       :initform nil
                       :accessor validator-disposable-domains))
  (:default-initargs
   :message (lambda (validator object)
	            (declare (ignorable validator object))
	            (format nil "The email is invalid: ~A" object)))
  (:metaclass closer-mop:funcallable-standard-class))

(defun domain-disposable-p (domain disposable-domains)
  (member domain disposable-domains
          :test #'string-equal))

(defmacro with-dns-distinction (() &body body)
  `(handler-case (progn ,@body)
     (org.shirakumo.dns-client:dns-server-failure (c)
       ;; rcode 3 = NXDOMAIN per RFC 1035: domain does not exist.
       (unless (= 3 (org.shirakumo.dns-client:response-code c))
         (error c)))))

(defun domain-has-mx-record (domain)
  (with-dns-distinction ()
    (getf (org.shirakumo.dns-client:query domain :type :MX) :answers)))

(defun domain-has-a-record (domain)
  (with-dns-distinction ()
    (org.shirakumo.dns-client:resolve domain)))

(defmethod clavier::%validate ((validator email-ext-validator) object &rest args)
  (declare (ignore args))
  (multiple-value-bind (name domain) (email-parse:parse object)
    (and name
         (if (validator-reject-disposable validator)
             (not (domain-disposable-p domain (validator-disposable-domains validator)))
             t)
         (if (validator-mx-check validator)
             (domain-has-mx-record domain)
             t)
         (if (validator-host-check validator)
             (domain-has-a-record domain)
             t))))
