
#+(or nyxt-3 nyxt-4)
(nyxt:define-package :nx-secure-connection-indicator)

(in-package #:nyxt)
 ;set parameter in plist checkout (inspect 'nyxt::format-status-load-status)
(if (eq (get 'nyxt::format-status-load-status 'nyxt::nyxt-status-default-method-definition) 'nil)
    (setf (get 'nyxt::format-status-load-status 'nyxt::nyxt-status-default-method-definition) (fdefinition 'nyxt::format-status-load-status))
    )
 ; test in slime repl (format-status-load-status (status-buffer (current-window)))
 ; old working version for 3.0.0
(defun format-status-load-status (status)
  (let ((x (get 'nyxt::format-status-load-status 'nyxt::nyxt-status-default-method-definition))
        (buffer (current-buffer (window status))))
    (concatenate 'string (funcall x status) (nx-secure-connection-indicator::tlshtmlbutton (nx-secure-connection-indicator::tlsstr buffer) status) )))

;; (defun format-status-load-status (status)
;;   (nx-secure-connection-indicator::mytest))

;; (defun format-status-load-status (status)
;;   (let ((x (get 'nyxt::format-status-load-status 'nyxt::nyxt-status-default-method-definition))
;;         (buffer (current-buffer (window status))))
;;     (write-to-string (nx-secure-connection-indicator::tlsstr buffer))))




(in-package :nx-secure-connection-indicator)


(defun mytest ()
  "LOL2")

;(in-package #:webkit2)
(defun tlspointer (my-ptr-to-int buffer)
  ""
  (let ((result (webkit:webkit-web-view-get-tls-info (NYXT/RENDERER/GTK:GTK-OBJECT buffer) (cffi:null-pointer) my-ptr-to-int)))
    (list result (cffi:mem-aref my-ptr-to-int :int)))
  )



;;(nyxt::status buffer)
;(nyxt::status buffer)
;;;(nyxt::status (current-buffer))

; list '(T/NIl  flag_value)
(defun tls (buffer)
  ""
  (cffi:with-foreign-object (pointer :int 1)
    (tlspointer pointer buffer)
    )
  )

(defun list-of-bits (integer)
  (loop for index below 8 collect (if (logbitp index integer) 1 0)))

;---

(defun tlsstr (buffer)
  ""
  (if (and (typep buffer 'nyxt::web-buffer) (eq (nyxt::status buffer) :finished))

      (let
          ((result (tls buffer)))
        (list (format nil "[~a]"(cert-status-symbol result)) (format nil "~a" (cert-status-info result)))
        )

      '("?" "certificate satatus is unknown"))
  )

(defun cert-status-symbol (result)
  ""
  (if (eq (nth 0 result) 'nil)
      "X"                               ;http , lock open
      (if (= (nth 1 result) 0)
          "S"                           ; secure https
          "⚠"                           ; unsecure certifcate
          )
      )
  )

(defun cert-status-info (result)
  ""
  (if (eq (nth 0 result) 'nil)
      "not secure connection"                               ;http , lock open
      (if (= (nth 1 result) 0)
          "secure connection"                           ; secure https
          (format nil "certificate issue: ~a" (list-of-bits (nth 1 result))) ; unsecure certifcate
          )
      )
  )



(defun tlshtmlbutton (strings status)
  ""
  (spinneret:with-html-string
      (:nbutton
       :buffer status
       :text (nth 0 strings)
       :title (nth 1 strings)
       :style "background-color:#4CAF50;" ;"background-color:#4CAF50;"
       '(nyxt:set-url))))



;;TODO rewrite with structures
;;https://lispcookbook.github.io/cl-cookbook/data-structures.html#structures




