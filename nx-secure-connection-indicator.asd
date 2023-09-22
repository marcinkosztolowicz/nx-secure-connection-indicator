;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(asdf:defsystem :nx-secure-connection-indicator
  :description "secure connection indicator in Nyxt!"
  :author "Atlas Engineer LLC"
  :license  "BSD 3-clause"
  :version "0.0.1"
  :serial t
  :depends-on (:nyxt)
  :components ((:file "package")
               (:file "main")))
