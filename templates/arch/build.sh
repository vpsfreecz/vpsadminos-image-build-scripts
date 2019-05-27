. "$TEMPLATEDIR"/config.sh
BASEURL=https://mirror.vpsfree.cz/archlinux/iso/latest

require_cmd curl

bootstrap-arch() {
	# Find out the bootstrap archive's name from checksum list
	rx='archlinux-bootstrap-\d+\.\d+\.\d+-x86_64\.tar\.gz'
	curl "$BASEURL/sha1sums.txt" | grep -P "$rx" > "$DOWNLOAD/sha1sums.txt"
	bfile=$(grep -oP "$rx" "$DOWNLOAD/sha1sums.txt")

	# Download the bootstrap archive and verify checksum
	curl -o "$DOWNLOAD/$bfile" "$BASEURL/$bfile"
	if ! (cd "$DOWNLOAD" ; sha1sum -c sha1sums.txt) ; then
		echo "Bootstrap checksum wrong! Quitting."
		exit 1
	fi

	# Extract
	tar -xzf "$DOWNLOAD/$bfile" --preserve-permissions --preserve-order --numeric-owner \
		-C "$INSTALL"

	# Bootstrap the base system to $INSTALL/root.x86_64/mnt
	local BOOTSTRAP="$INSTALL/root.x86_64"
	local SETUP="/install.sh"

	sed -i 's/CheckSpace/#CheckSpace/' "$BOOTSTRAP/etc/pacman.conf"
	sed -ri 's/^#(.*vpsfree\.cz.*)$/\1/' "$BOOTSTRAP/etc/pacman.d/mirrorlist"
	echo nameserver 8.8.8.8 > "$BOOTSTRAP/etc/resolv.conf"

	# pacstrap tries to mount /dev as devtmpfs, which is not possible in
	# an unprivileged container
	sed -i 's/devtmpfs/tmpfs/' "$BOOTSTRAP/bin/pacstrap"

	# and in a tmpfs, we need to manually mkdir directories
	sed -i 's/chroot_add_mount devpts/mkdir "\$1\/dev\/pts" \&\& chroot_add_mount devpts/' \
		   "$BOOTSTRAP/bin/pacstrap"
	sed -i 's/chroot_add_mount shm/mkdir "\$1\/dev\/shm" \&\& chroot_add_mount shm/' \
		   "$BOOTSTRAP/bin/pacstrap"

	cat <<EOF > "$BOOTSTRAP/$SETUP"
#!/bin/bash

pacman-key --init
pacman-key --populate archlinux

pacstrap -dG /mnt base openssh

gpg-connect-agent --homedir /etc/pacman.d/gnupg "SCD KILLSCD" "SCD BYE" /bye
gpg-connect-agent --homedir /etc/pacman.d/gnupg killagent /bye
EOF

	chmod +x "$BOOTSTRAP/$SETUP"
	do-chroot "$BOOTSTRAP" "$SETUP"

	# Replace bootstrap with the base system
	mv "$BOOTSTRAP"/mnt/* "$INSTALL/"
	rm -rf "$BOOTSTRAP"
}

configure-arch() {
	configure-append <<EOF
cat <<EOT > /etc/resolv.conf
$(cat /etc/resolv.conf)
EOT

cat >> /etc/fstab <<EOT
devpts       /dev/pts        devpts  gid=5,mode=620    0       0
tmpfs        /tmp            tmpfs   nodev,nosuid      0       0
EOT

pacman-key --init
pacman-key --populate archlinux
pacman -Rns --noconfirm linux
pacman -Scc --noconfirm

gpg-connect-agent --homedir /etc/pacman.d/gnupg "SCD KILLSCD" "SCD BYE" /bye
gpg-connect-agent --homedir /etc/pacman.d/gnupg killagent /bye

ln -s /usr/share/zoneinfo/Europe/Prague /etc/localtime
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=900s/' /etc/systemd/system.conf
systemctl enable sshd
systemctl disable systemd-resolved
usermod -L root

echo > /etc/resolv.conf

EOF
}

bootstrap-arch
configure-arch
run-configure