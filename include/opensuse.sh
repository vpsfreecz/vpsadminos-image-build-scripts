#!/bin/bash

. $BASEDIR/include/common.sh

if [ $DISTNAME == "suse-leap" ]; then
	REPOSITORY=http://download.opensuse.org/distribution/leap/$RELVER/repo/oss/
	UPDATES=http://download.opensuse.org/update/leap/$RELVER/oss/
elif [ $DISTNAME == "suse-tumbleweed" ]; then
	REPOSITORY=http://download.opensuse.org/tumbleweed/repo/oss/
	UPDATES=http://download.opensuse.org/update/tumbleweed/
else
	REPOSITORY=http://download.opensuse.org/distribution/$RELVER/repo/oss/
	UPDATES=http://download.opensuse.org/update/$RELVER/
fi

EXTRAPKGS='vim iproute2 net-tools-deprecated'

ZYPPER="zypper -v --root=$INSTALL --non-interactive --no-gpg-checks "

function bootstrap {

	$ZYPPER addrepo --refresh $REPOSITORY openSUSE-oss
	$ZYPPER addrepo --refresh $UPDATES openSUSE-updates
	$ZYPPER install --no-recommends -t pattern minimal_base minimal_base-conflicts
	$ZYPPER install -t pattern sw_management
	$ZYPPER install $EXTRAPKGS

}

function configure-opensuse {
	configure-append <<EOF
systemctl enable  wicked.service
usermod -L root
systemctl enable sshd.service
echo console >> /etc/securetty
sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=900s/' /etc/systemd/system.conf
EOF
}
