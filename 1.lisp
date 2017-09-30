
(ql:quickload :cl-autowrap)



(defpackage :g (:use :cl
		     :autowrap))
(in-package :g)

(progn
  (with-open-file (s "/tmp/frame0.h"
		     :direction :output
		     :if-does-not-exist :create
		     :if-exists :supersede)
    (format s "#include \"/root/stage/bacon_fb_test/msm_mdp.h\"~%"))
  (autowrap::run-check autowrap::*c2ffi-program*
		       (autowrap::list "/tmp/frame0.h"
				       "-D" "null"
				       "-M" "/tmp/frame_macros.h"
				       "-A" "arm-pc-linux-gnu"))
  
  (with-open-file (s "/tmp/frame1.h"
		     :direction :output
		     :if-does-not-exist :create
		     :if-exists :supersede)

    ;;(format s "#include <sys/types.h>~%")
    ;;(format s "#include <sys/stat.h>~%")
    ;;(format s "#include <sys/ioctl.h>~%")
    (format s "#include \"/tmp/frame0.h\"~%")
    (format s "#include \"/tmp/frame_macros.h\"~%")))


(c-include "/usr/include/linux/types.h")
(c-include "/usr/include/linux/fb.h")

(c-include "msm_mdp.h" :trace-c2ffi t :exclude-arch ("i386-unknown-freebsd"
						      "i386-unknown-openbsd"
						      "i686-apple-darwin9"
						      "i686-pc-linux-gnu"
						      "i686-pc-windows-msvc"
						      "x86_64-apple-darwin9"
						      "x86_64-pc-linux-gnu"
						      "x86_64-pc-windows-msvc"
						      "x86_64-unknown-freebsd"
						      "x86_64-unknown-openbsd"
						      
						      ))

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


#+nil
(defparameter *fd* (%open "/dev/graphics/fb0" '(:rdwr) #o644))


#+nil
(with-open-file (s (first (directory "/dev/graphics/fb*"))
		   :direction :output
		   :element-type '(unsigned-byte 8))
  (let ((a (make-array (* 1920 1080 4) :element-type '(unsigned-byte 8)
		       :initial-element 255)))
    (write-sequence a s)))
