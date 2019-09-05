DISTNAME=suse
SPIN=leap
SPINVER=15.1
RELVER=$SPIN-$SPINVER

. $INCLUDE/opensuse.sh

bootstrap
configure-common

configure-opensuse

run-configure
