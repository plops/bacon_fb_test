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