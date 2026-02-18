[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/plops/bacon_fb_test)

# Purpose and Scope

The bacon_fb_test repository demonstrates direct framebuffer manipulation on Android devices with Qualcomm Mobile Display Processor (MDP) hardware. It provides two parallel implementations—one in C and one in Common Lisp—that bypass the Android graphics stack to achieve low-level access to /dev/graphics/fb0. The primary purpose is to showcase advanced Foreign Function Interface (FFI) techniques for hardware control from high-level languages, particularly using cl-autowrap and cl-plus-c to generate Lisp bindings from C headers.

# Qualcomm MSM MDP Hardware Interface

The Qualcomm Mobile Display Processor (MDP) hardware interface as defined in msm_mdp.h. The MDP is part of Qualcomm's Mobile Display SubSystem (MDSS) and provides hardware-accelerated display composition, image processing, and buffer management for Snapdragon SoCs.

The interface exposes MDP functionality through:

* IOCTL commands (MSMFB_* family) for controlling display operations
* Data structures for configuring overlays, blitting, and post-processing
* Hardware capability detection and metadata queries
* Buffer synchronization mechanisms using fence file descriptors

This interface extends the standard Linux framebuffer API (see Linux Framebuffer API Integration) with Qualcomm-specific features.

The MDP provides advanced graphics capabilities beyond standard Linux framebuffer operations, including:

- Multi-layer hardware composition with up to 4 z-order layers
- Hardware-accelerated scaling and rotation
- Color space conversion and post-processing effects
- Overlay management with multiple pipe types (VIG, RGB, DMA)
- Writeback capture for screen recording
- Buffer synchronization with fence mechanisms
- IOMMU-based memory protection for secure content



```
here are some commands that i used to get a debian chroot environment on the phone

# group 3003
adb disconnect
adb root
adb connect 10.87.2.139:5555
adb shell
mkdir /data/debian-9.1-minimal-armhf-2017-08-08
cd /data/debian-9.1-minimal-armhf-2017-08-08
tar xvzf /sdcard/armhf-rootfs-debian-stretch.tar.gz
mkdir -p data/local/tmp

mount --rbind /dev dev
#mount --make-rslave dev
mount --bind /dev/pts dev/pts
mount -t proc /proc proc
mount --rbind /sys sys
#mount --make-rslave sys
#mount --rbind /tmp tmp
mount -t tmpfs shmfs  tmp
mount --bind /data/local/tmp /data/debian-9.1-minimal-armhf-2017-08-08/data/local/tmp                                                         




unset LD_PRELOAD
chroot /data/debian-9.1-minimal-armhf-2017-08-08 /bin/dash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
bash
export HOME=/root
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
apt update
apt install fbterm strace xserver-xorg-video-fbdev ecl libffi-dev emacs
ln -s /dev/graphics/fb0 /dev/fb0
fbterm < /dev/tty

apt install make


to wake up android when it is getting sluggish: adb shell input keyevent KEYCODE_WAKEUP

(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
M-x package-list
paredit ido-hacks
i i x

  (load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation                        
  (setq inferior-lisp-program "ecl")
(package-initialize)

(autoload 'enable-paredit-mode "paredit"
  "Turn on pseudo-structural editing of Lisp code."
  t)


(add-hook 'lisp-mode-hook #'enable-paredit-mode)
(require 'ido-hacks)

(ido-hacks-mode)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode +1)
(tool-bar-mode -1)
(show-paren-mode 1)


stop zygote
stop surfaceflinger


Thanks:

The main work was done by https://github.com/peterbjornx. He figured out the required ioctls by looking at strace outputs of surfaceflinger.

```
