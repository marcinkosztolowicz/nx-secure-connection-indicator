
#+(or nyxt-3 nyxt-4)
(nyxt:define-package :nx-secure-connection-indicator)

(in-package #:nyxt)
 ;set parameter in plist checkout (inspect 'nyxt::format-status-buttons)
(if (eq (get 'nyxt::format-status-buttons 'nyxt::nyxt-status-default-method-definition) 'nil)
    (setf (get 'nyxt::format-status-buttons 'nyxt::nyxt-status-default-method-definition) (fdefinition 'nyxt::format-status-buttons))
    )
 ; test in slime repl (format-status-load-status (status-buffer (current-window)))
(defun format-status-buttons (status)
  (let ((format-status-buttons-default (get 'nyxt::format-status-buttons 'nyxt::nyxt-status-default-method-definition))
        (buffer (current-buffer (window status))))
    (format nil "~a~%  ~a" (funcall format-status-buttons-default status)  (nx-secure-connection-indicator::tlshtmlbutton (nx-secure-connection-indicator::tlsstr buffer) status)   )))


(in-package :nx-secure-connection-indicator)


(defclass raw-tls-info ()
  ((is-using-https
    :initarg :is-using-https
    :accessor is-using-https)
   (certificate-flags-int
    :initarg :certificate-flags-int
    :accessor certificate-flags-int)))

(defclass tls-info-render ()
  ((secure-symbol
    :initarg :secure-symbol
    :accessor secure-symbol)
   (color
    :initarg :color
    :accessor color)
   (text-info
    :initarg :text-info
    :accessor text-info)
   ))


;https://webkitgtk.org/reference/webkit2gtk/2.5.1/WebKitWebView.html
;https://api.gtkd.org/gio.c.types.GTlsCertificateFlags.html
(defun get-tls-info-with-pointer (my-ptr-to-int buffer)
  ""
  (let ((result (webkit:webkit-web-view-get-tls-info (NYXT/RENDERER/GTK:GTK-OBJECT buffer) (cffi:null-pointer) my-ptr-to-int)))
    (make-instance 'raw-tls-info
     :is-using-https result
     :certificate-flags-int (cffi:mem-aref my-ptr-to-int :int)))
  )


(defun get-tls-info (buffer)
  ""
  (cffi:with-foreign-object (pointer :int 1)
    (get-tls-info-with-pointer pointer buffer)
    )
  )

(defun list-of-bits (integer)
  (loop for index below 8 collect (if (logbitp index integer) 1 0)))



(defun tlsstr (buffer)
  ""
  (if (and (typep buffer 'nyxt::web-buffer) (eq (nyxt::status buffer) :finished))

      (let
          ((raw-tls-info-value (get-tls-info buffer)))
        (map-tls-info-render raw-tls-info-value)
        )

      (make-instance 'tls-info-render
                     :secure-symbol "?"
                     :color "#888888"
                     :text-info "certificate satatus is unknown"
                     )
      )
  )


(defun map-tls-info-render (raw-tls-info-value)
  ""
  (cond
    ((eq (is-using-https raw-tls-info-value) 'nil)
     (make-instance 'tls-info-render
                     :secure-symbol "X"
                     :color "#f9c80e"
                     :text-info "HTTP (not secure)") )
    ((= (certificate-flags-int raw-tls-info-value) 0)
     (make-instance 'tls-info-render
                     :secure-symbol "S"
                     :color "#43bccd"
                     :text-info "HTTPS ( secure)"))
    (t
     ( make-instance 'tls-info-render
                     :secure-symbol "⚠"
                     :color "#ea3546"
                     :text-info (format nil "https certificate issue: ~a" (list-of-bits (certificate-flags-int raw-tls-info-value))))))

  )


(defun tlshtmlbutton (tls-info-render-value status)
  ""
  (spinneret:with-html-string
      (:div
       :id "tls"
       :style "float:right;margin-right: +10px;"
       (:nbutton

        :buffer status
        :text (format nil "[~a]" (secure-symbol tls-info-render-value))

        :title (text-info tls-info-render-value)
        :style (format nil "background-color:~a;color: black;width: 22px" (color tls-info-render-value))
        '(nyxt:set-url)))))
