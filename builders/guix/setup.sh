cat <<EOF > /etc/config.scm
;; Module imports
(use-modules (gnu) (guix))
(use-service-modules networking ssh)
(use-package-modules bootloaders)

;; Operating system description
(define os
  (operating-system
    (locale "en_US.utf8")
    (timezone "America/New_York")
    (keyboard-layout (keyboard-layout "us" "altgr-intl"))
    (bootloader (bootloader-configuration
                 (bootloader grub-bootloader)
                 (target "/dev/sda")
                 (keyboard-layout keyboard-layout)))
    (file-systems (cons* (file-system
                          (mount-point "/")
                          (device "/dev/sda1")
                          (type "ext4"))
                         %base-file-systems))
    (host-name "alyssas-home-server")
    (users (cons* (user-account
                   (name "alyssa")
                   (comment "Alyssa")
                   (group "users")
                   (home-directory "/home/alyssa")
                   (supplementary-groups
                    '("wheel" "netdev" "audio" "video")))
                  %base-user-accounts))
    (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL\n"))
    (services (append
               (list (service openssh-service-type
                              (openssh-configuration
                               (permit-root-login #t)))
                     (service dhcp-client-service-type))
               %base-services))))
EOF

# Configure the system
guix system reconfigure /etc/config.scm
