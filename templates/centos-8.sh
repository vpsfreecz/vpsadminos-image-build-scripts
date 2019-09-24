DISTNAME=centos
RELVER=8
POINTVER=${RELVER}.0
BUILD=1905
RELEASE=http://mirror.centos.org/centos/${POINTVER}.${BUILD}/BaseOS/x86_64/os/Packages/centos-release-${POINTVER}-0.${BUILD}.0.9.el8.x86_64.rpm
BASEURL=http://mirror.centos.org/centos/${POINTVER}.${BUILD}/BaseOS/x86_64/os/

# CentOS 8 does not seem to have an updates repo, so this variable is used to
# add AppStream repository just for the installation process.
UPDATES=http://mirror.centos.org/centos/${POINTVER}.${BUILD}/AppStream/x86_64/os/

GROUPNAME='core'
EXTRAPKGS='vim man network-scripts'

. $INCLUDE/redhat-family.sh

bootstrap
configure-common

configure-redhat-common

configure-append <<EOF
/usr/bin/systemctl disable NetworkManager.service
/usr/bin/systemctl disable NetworkManager-wait-online.service
/usr/bin/systemctl disable NetworkManager-dispatcher.service
/usr/bin/systemctl enable  network.service
/usr/bin/systemctl disable firewalld.service
/usr/bin/systemctl mask auditd.service
/usr/bin/systemctl mask kdump.service
/usr/bin/systemctl mask plymouth-start.service
/usr/bin/systemctl mask tuned.service
EOF

run-configure
