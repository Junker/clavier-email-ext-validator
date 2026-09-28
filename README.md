# clavier-email-ext-validator

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Common Lisp](https://img.shields.io/badge/Common%20Lisp-library-orange.svg)](https://common-lisp.net/)

An **extended email validator** for
[Clavier](https://github.com/mmontone/clavier), the general purpose
validation library for Common Lisp.

It goes beyond basic syntax checking by relying on
[email-parse](https://github.com/pyramidi0n/email-parse) for strictly
RFC–compliant parsing, and optionally verifies the mail domain over DNS
using [dns-client](https://shinmera.github.io/dns-client) — MX record
lookups, host (A record) resolution and disposable-domain rejection.


## Installation

This system can be installed from [UltraLisp](https://ultralisp.org/) like this:

```lisp
(ql-dist:install-dist "http://dist.ultralisp.org/"
                      :prompt nil)
(ql:quickload :clavier-email-ext-validator)
```

## Usage

The validator is an ordinary Clavier validator instance:

```lisp
(defparameter *validator* (make-instance 'email-ext-validator))

(clavier:validate *validator* "user@example.com")
;=> T

(clavier:validate *validator* "not-an-email" :error-p nil)
;=> NIL
;   "The email is invalid: not-an-email"
```

### All options enabled

```lisp
(defparameter *validator*
  (make-instance 'email-ext-validator
                 :mx-check           t     ; domain must have an MX record
                 :host-check         t     ; domain must resolve (A record)
                 :reject-disposable  t     ; reject disposable domains
                 :disposable-domains '("example.com"
                                       "example.org")))
```

| Option                | Default  | Description                                                     |
|-----------------------|----------|-----------------------------------------------------------------|
| `:mx-check`           | `nil`    | Domain must have an MX record (`dns-client:query` type `:MX`).  |
| `:host-check`         | `nil`    | Domain must resolve to an A record (`dns-client:resolve`).      |
| `:reject-disposable`  | `nil`    | Reject domains listed in `:disposable-domains`.                 |
| `:disposable-domains` | `nil`    | List of domains to reject when `:reject-disposable` is enabled. |
| `:message`            | function | Validation error message.                                       |
