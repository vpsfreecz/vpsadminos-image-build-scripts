DISTNAME=suse
SPIN=tumbleweed
SPINVER=$(date +%Y%m%d)
RELVER=$SPIN-$SPINVER

. $INCLUDE/opensuse.sh

bootstrap
configure-common

configure-opensuse

run-configure
