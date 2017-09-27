
(ql:quickload :cffi)

(defpackage :g (:use :cl
		     :cffi
		     ))
(in-package :g)

(defctype off-t :int "C type off_t")



;; 'prot' protection flags for mmap.
(defbitfield mmap-prot-flags
    (:prot-none #x00)
  (:prot-read #x04)
  (:prot-write #x02)
  (:prot-exec #x01))

;; Specifies the type of the object in mmap 'flags'.
(defbitfield mmap-map-flags
    (:map-file #x0001)
  (:map-type #x000f)
  (:map-shared #x0010)
  (:map-private #x0000)
  (:map-fixed #x0100)
  (:map-noextend #x0200)
  (:map-hassemphore #x0400)
  (:map-inherit #x0800)
  (:map-anon #x0002))

(defcfun ("mmap" %mmap)
    :pointer
  (addr :pointer)
  (len :unsigned-int)
  (prot mmap-prot-flags)
  (flags mmap-map-flags)
  (filedes :int)
  (off off-t))

(defun mmap (addr len prot flags filedes off)
  "Map files or devices into memory."
  (let ((ptr (%mmap addr len prot flags filedes off)))
					; Mmap returns -1 in case of error
    (if (= (pointer-address ptr) #xffffffff)
	nil
	ptr)))

(defcfun ("munmap" %munmap) :int
  (addr :pointer)
  (len :unsigned-int))

(defun munmap (addr len)
  "Remove a mapping."
  (cond
    ((zerop len) t)
    ((null addr) nil)
    (t
     (let ((result (%munmap addr len)))
					; In case of success, munmap returns 0.
       (= result 0)))))

(defbitfield open-flags
    (:rdonly #x0000)
  :wronly              ;#x0001
  :rdwr                ;&hellip;
  :nonbloc
  :append
      (:creat  #x0200))

(defcfun ("open" %open) :int
  (path :string)
  (flags open-flags)
  (mode :uint16)) ; unportable

(defparameter *fd* (%open "/dev/graphics/fb0" '(:rdwr) #o644))


(with-open-file (s (first (directory "/dev/graphics/fb*"))
		   :direction :output
		   :element-type '(unsigned-byte 8))
   (let ((a (make-array (* 1920 1080 4) :element-type '(unsigned-byte 8)
		       :initial-element 255)))
    (write-sequence a s)))
