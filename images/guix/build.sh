cd /tmp
wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh

wget 'https://sv.gnu.org/people/viewgpg.php?user_id=127547' \
-qO - | gpg --import -

wget https://ftp.gnu.org/gnu/guix/guix-binary-1.3.0.x86_64-linux.tar.xz.sig
$ gpg --verify guix-binary-1.3.0.x86_64-linux.tar.xz.sig

chmod +x guix-install.sh
./guix-install.sh

mkdir -p ~root/.config/guix
ln -sf /var/guix/profiles/per-user/root/current-guix ~root/.config/guix/current

GUIX_PROFILE="`echo ~root`/.config/guix/current" ; \
source $GUIX_PROFILE/etc/profile
