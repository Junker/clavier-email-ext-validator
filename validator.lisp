(defpackage clavier-email-ext-validator
  (:use #:cl #:clavier)
  (:export #:email-ext-validator
           #:*disposable-domains*))
(in-package #:clavier-email-ext-validator)

(defvar *disposable-domains* (uiop:read-file-lines
                              (merge-pathnames #P"res/disposable-domains.lst"
                                               (asdf:system-source-directory :clavier-email-ext-validator))))

(defclass email-ext-validator (clavier:validator)
  ((reject-disposable :type 'boolean
                      :initarg :reject-disposable
                      :initform nil
                      :accessor validator-reject-disposable)
   (host-check :type 'boolean
               :initarg :host-check
               :initform nil
               :accessor validator-host-check)
   (mx-check :type 'boolean
             :initarg :mx-check
             :initform nil
             :accessor validator-mx-check)
   (disposable-domains :type 'list
                       :initarg :disposable-domains
                       :initform nil
                       :accessor validator-disposable-domains))
  (:default-initargs
   :message (lambda (validator object)
	            (declare (ignorable validator object))
	            (format nil "The email is invalid: ~A" object)))
  (:metaclass closer-mop:funcallable-standard-class))

(defun domain-disposable-p (domain &optional disposable-domains)
  (member domain
          (or disposable-domains *disposable-domains*)
          :test #'string=))

(defun domain-has-mx-record (domain)
  (getf (org.shirakumo.dns-client:query domain :type :MX) :answers))

(defun domain-has-a-record (domain)
  (org.shirakumo.dns-client:resolve domain))

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
