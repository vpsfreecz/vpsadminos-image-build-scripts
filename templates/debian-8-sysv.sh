DISTNAME=debian
RELVER=8
RELNAME=jessie
EXTRAVER=sysv
BASEURL=http://ftp.cz.debian.org/debian

. $INCLUDE/debian.sh

bootstrap

configure-common
configure-debian

cat > $INSTALL/etc/apt/sources.list <<SOURCES
deb $BASEURL $RELNAME main
deb-src $BASEURL $RELNAME main

deb $BASEURL $RELNAME-updates main
deb-src $BASEURL $RELNAME-updates main

deb http://security.debian.org/ $RELNAME/updates main 
deb-src http://security.debian.org/ $RELNAME/updates main
SOURCES

configure-append <<EOF
sed -i -e '/^PermitRootLogin/ s/^#*/#/' /etc/ssh/sshd_config
ln -s /dev/null /etc/systemd/system/proc-sys-fs-binfmt_misc.automount
EOF

cat > $INSTALL/etc/apt/preferences.d/local-pin-init <<EOF
Package: systemd-sysv
Pin: release o=Debian
Pin-Priority: -1
EOF

run-configure
