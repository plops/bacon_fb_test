(ql:quickload :cl-autowrap)
(ql:quickload :cl-plus-c)



(defpackage :g (:use :cl
		     :autowrap))
(in-package :g)

(progn
  (with-open-file (s "/tmp/frame0.h"
		     :direction :output
		     :if-does-not-exist :create
		     :if-exists :supersede)
    (format s "#include \"/root/stage/bacon_fb_test/msm_mdp.h\"~%")
    (format s "#include <sys/mman.h>~%")
    ;(format s "#include <errno.h>~%")
    )
  (autowrap::run-check autowrap::*c2ffi-program*
		       (autowrap::list "/tmp/frame0.h"
				       "-D" "null"
				       "-M" "/tmp/frame_macros.h"
				       "-A" "arm-pc-linux-gnu"))
  
  (with-open-file (s "/tmp/frame1.h"
		     :direction :output
		     :if-does-not-exist :create
		     :if-exists :supersede)

    ;;(format s "#include <asm-generic/int-ll64.h>~%")
    ;;(format s "#include <linux/types.h>~%")
    (format s "#include <sys/types.h>~%")

    
    (format s "#include <linux/i2c.h>~%")
    
    ;;(format s "#include <sys/stat.h>~%")
    (format s "#include <sys/ioctl.h>~%")
    (format s "#include <linux/fb.h>~%")
    (format s "#include <stdint.h>~%") ;; uint32_t
    (format s "#include \"/tmp/frame0.h\"~%")
    (format s "#include \"/tmp/frame_macros.h\"~%")))


#+nil
(delete-file )
#+nil
(directory "/root/stage/bacon_fb_test/*spec")
(c-include "/tmp/frame1.h"
	   :trace-c2ffi t
	   :spec-path "/root/stage/bacon_fb_test/"
	   ;;:exclude-sources ("")
	   :exclude-definitions (".*"
				"__*")
	   :sysincludes '("/usr/include/arm-linux-gnueabihf/")
	   :include-sources ("/usr/include/linux/ioctl.h"
			     "/usr/include/linux/fb.h")
	   :exclude-arch ("i386-unknown-freebsd"
			  "i386-unknown-openbsd"
			  "i686-apple-darwin9"
			  "i686-pc-linux-gnu"
			  "i686-pc-windows-msvc"
			  "x86_64-apple-darwin9"
			  "x86_64-pc-linux-gnu"
			  "x86_64-pc-windows-msvc"
			  "x86_64-unknown-freebsd"
			  "x86_64-unknown-openbsd"
			  )
	   :include-definitions ("__u32"
				 "uint32_t"
				 "size_t"
				 "__off_t"
				 "FBIOGET_VSCREENINFO"
				 "FBIOPUT_VSCREENINFO"
				 "FBIOGET_FSCREENINFO"
				 "FBIOPUT_FSCREENINFO"
				 "FB_ACTIVATE_FORCE"
				 "fb_var_screeninfo"
				 "fb_fix_screeninfo"
				 "mdp_display_commit"
				 "mdp_rect"
				 "MDP_DISPLAY_COMMIT_OVERLAY"
				 "MSMFB_DISPLAY_COMMIT"
				 "MAP_SHARED"
				 "PROT_READ"
				 "PROT_WRITE"
				 "mmap" "munmap" "ioctl"
)
	   )

(cffi:defcvar "errno" :int)


(progn ; with-open-file (s "/dev/graphics/fb0" :direction :io :element-type '(unsigned-byte 8))
  (let ((fd ;(sb-sys:fd-stream-fd s)
	 (sb-posix:open "/dev/graphics/fb0" sb-posix:o-rdwr)
	 ))
    (autowrap:with-alloc (finfo '(:struct (fb-fix-screeninfo)))
      (assert (<= 0 (ioctl fd +FBIOGET-FSCREENINFO+ :pointer (AUTOWRAP:PTR finfo))))
      (autowrap:with-alloc (vinfo '(:struct (fb-var-screeninfo)))
	(assert (<= 0 (ioctl fd +FBIOGET-VSCREENINFO+ :pointer (AUTOWRAP:PTR vinfo))))
	(setf (fb-var-screeninfo.activate vinfo) +FB-ACTIVATE-FORCE+
	      ;;(fb-var-screeninfo.yoffset vinfo) 0
	      )
	(autowrap:with-alloc (commit '(:struct (mdp-display-commit)))
	  (autowrap::c-memset (autowrap:ptr commit) 0 (autowrap:sizeof '(:struct (mdp-display-commit))))
	  (setf (mdp-display-commit.flags commit)
		(logior +MDP-DISPLAY-COMMIT-OVERLAY+ (mdp-display-commit.flags commit)))
	  (autowrap::c-memcpy (mdp-display-commit.var& commit)
			      (autowrap:ptr vinfo)
			      (autowrap:sizeof '(:struct (fb-var-screeninfo))))
	  (assert (<= 0 (ioctl fd +MSMFB-DISPLAY-COMMIT+ :pointer (AUTOWRAP:PTR commit))))
	  (assert (<= 0 (ioctl fd +FBIOPUT-VSCREENINFO+ :pointer (AUTOWRAP:PTR vinfo))))
	  (let* ((screensize (/ (* (fb-var-screeninfo.xres-virtual vinfo)
				   (fb-var-screeninfo.yres-virtual vinfo)
				   (fb-var-screeninfo.bits-per-pixel vinfo))
				8))
		 (smem-len (fb-fix-screeninfo.smem-len finfo))
		 (fbp (mmap (cffi:null-pointer) smem-len (logior +PROT-READ+ +PROT-WRITE+)
			    +MAP-SHARED+ fd 0)))
	    (format t "fbp=~a ~a" fbp errno) ;; errno = 13 permission denied
	    (assert (/= (sb-sys:sap-int fbp) #XFFFFFFFF))

	    (autowrap::c-memset (autowrap:ptr fbp) 255 smem-len)
	    (assert (<= 0 (ioctl fd +FBIOPUT-VSCREENINFO+ :pointer (AUTOWRAP:PTR vinfo))))
	    (sleep 3)
	    (munmap fbp smem-len)))))
    (sb-posix:close fd)))

(sb-sys:sap-int *fbp*)

(logior +PROT-READ+ +PROT-WRITE+)

(plus-c:c-let ((fix (:struct (fb-fix-screeninfo)) :free t))
)

(sb-alien:sap-alien (sb-sys:int-sap 32) sb-alien:double )


(type-of (sb-sys:int-sap 32)) 


  #+nil
(progn
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


  )
  #+nil
(defparameter *fd* (%open "/dev/graphics/fb0" '(:rdwr) #o644))


#+nil
(with-open-file (s (first (directory "/dev/graphics/fb*"))
		   :direction :output
		   :element-type '(unsigned-byte 8))
  (let ((a (make-array (* 1920 1080 4) :element-type '(unsigned-byte 8)
		       :initial-element 255)))
    (write-sequence a s)))
