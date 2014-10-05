#!/bin/bash

# The MIT License (MIT)
# 
# Copyright (c) 2014 Ilari Stenroth
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# == create-www-chroot.sh ==
# Version: 0.10 beta (for LAMP with PHP-FPM)
# https://github.com/istenrot/secure-www-chroot
# ==

# This is array of binaries you want to include in your chroot environment
# Modify the array as needed
WANT_BINARIES[${#WANT_BINARIES[@]}]="/bin/sh"
WANT_BINARIES[${#WANT_BINARIES[@]}]="/bin/bash"
WANT_BINARIES[${#WANT_BINARIES[@]}]="/sbin/nologin"
WANT_BINARIES[${#WANT_BINARIES[@]}]="/usr/bin/convert"
WANT_BINARIES[${#WANT_BINARIES[@]}]="/usr/bin/gm"
WANT_BINARIES[${#WANT_BINARIES[@]}]="/usr/bin/gsnd"
WANT_BINARIES[${#WANT_BINARIES[@]}]="/bin/ls"

# Hide all server accounts in /etc/passwd except ones listed in this array
# Comment out the arrray if you don't want to modify /etc/password in chroot environments
# Doesn't support additional groups, only primary group for an account is enabled
# If you need support for additional groups comment out the array
ENABLED_ACCOUNTS[${#ENABLED_ACCOUNTS[@]}]="root"
ENABLED_ACCOUNTS[${#ENABLED_ACCOUNTS[@]}]="apache"


if [[ "$1" == "-u" ]]; then
	CHROOT_DST="`echo \"$2\" | tr -s \"/\"`"
	CHROOT_DST="${CHROOT_DST%%/}"

	if [[ "$CHROOT_DST" == "" ]]; then
		echo "Usage: `basename $0` <chroot-dir>"
		echo "  Creates a new chroot environment and apply bind mounts"
		echo "Usage: `basename $0` -u <chroot-dir>"
		echo "  Unmounts bind mounts from a chroot environment"
		echo ""
		exit 1
	fi

	mountpoint -q "$CHROOT_DST/proc"

	if [[ $? != 0 ]]; then
		echo "Error, $CHROOT_DST is not a chroot path."
		exit $?
	fi

	umount -v "$CHROOT_DST/dev"
	umount -v "$CHROOT_DST/proc"
	umount -v "$CHROOT_DST/sys"
	umount -v "$CHROOT_DST/usr/lib"
	umount -v "$CHROOT_DST/usr/lib64"
	umount -v "$CHROOT_DST/usr/libexec"
	umount -v "$CHROOT_DST/usr/share"
	umount -v "$CHROOT_DST/bin"
	umount -v "$CHROOT_DST/sbin"
	umount -v "$CHROOT_DST/usr/bin"
	umount -v "$CHROOT_DST/usr/sbin"
	umount -v "$CHROOT_DST/usr/local/bin"
	umount -v "$CHROOT_DST/usr/local/sbin"
	umount -v "$CHROOT_DST/lib"
	umount -v "$CHROOT_DST/lib64"
	umount -v "$CHROOT_DST/var/www"
	umount -v "$CHROOT_DST/var/log/php-fpm"
	umount -v "$CHROOT_DST/tmp"
	umount -v "$CHROOT_DST/var/tmp"
	umount -v "$CHROOT_DST/etc/fonts"
	umount -v "$CHROOT_DST/var/cache/fontconfig"

	exit 0
fi


CHROOT_DST="`echo \"$1\" | tr -s \"/\"`"
CHROOT_DST="${CHROOT_DST%%/}"

if [[ "$CHROOT_DST" == "" ]]; then
	echo "Usage: `basename $0` <chroot-dir>"
	echo "  Creates a new chroot environment and apply bind mounts"
	echo "Usage: `basename $0` -u <chroot-dir>"
	echo "  Unmounts bind mounts from a chroot environment"
	echo ""
	exit 1
fi

if [ -e "$CHROOT_DST" ]; then
	if [ \! -d "$CHROOT_DST/proc" ]; then
		echo "Can overwrite only existing chroot environments. Aborting..."
		exit 1
	fi

	mountpoint -q "$CHROOT_DST/proc"

	if [[ $? == 0 ]]; then
		echo "Error, $CHROOT_DST has active bind mounts. Unable to overwrite. Try -u switch first. Aborting..."
		exit 1
	fi

	rm -fr "$CHROOT_DST"
fi

mkdir -p -Z system_u:object_r:root_t:s0 "$CHROOT_DST"

if [[ $? != 0 ]]; then
	echo "Failed to create the destination directory for a new chroot."
	exit $?
fi

# Create chroot directory structure
mkdir -m 755 -Z system_u:object_r:bin_t:s0 "$CHROOT_DST/bin"
mkdir -m 755 -Z system_u:object_r:bin_t:s0 "$CHROOT_DST/sbin"
mkdir -m 755 -Z system_u:object_r:usr_t:s0 "$CHROOT_DST/usr"
mkdir -m 755 -Z system_u:object_r:usr_t:s0 "$CHROOT_DST/usr/local"
mkdir -m 755 -Z system_u:object_r:bin_t:s0 "$CHROOT_DST/usr/bin"
mkdir -m 755 -Z system_u:object_r:bin_t:s0 "$CHROOT_DST/usr/sbin"
mkdir -m 755 -Z system_u:object_r:bin_t:s0 "$CHROOT_DST/usr/local/bin"
mkdir -m 755 -Z system_u:object_r:bin_t:s0 "$CHROOT_DST/usr/local/sbin"
mkdir -m 755 -Z system_u:object_r:etc_t:s0 "$CHROOT_DST/etc"
mkdir -m 755 -Z system_u:object_r:var_t:s0 "$CHROOT_DST/var"
mkdir -m 755 -Z system_u:object_r:var_lib_t:s0 "$CHROOT_DST/var/lib"
mkdir -m 755 -Z unconfined_u:object_r:mysqld_db_t:s0 "$CHROOT_DST/var/lib/mysql"
mkdir -m 755 -Z system_u:object_r:var_t:s0 "$CHROOT_DST/var/cache"
mkdir -m 755 -Z system_u:object_r:var_log_t:s0 "$CHROOT_DST/var/log"
mkdir -m 777 -Z system_u:object_r:tmp_t:s0 "$CHROOT_DST/var/tmp"
mkdir -m 777 -Z system_u:object_r:tmp_t:s0 "$CHROOT_DST/tmp"
mkdir -m 700 -Z system_u:object_r:admin_home_t:s0 "$CHROOT_DST/root"

# Create bind mount points
mkdir -m 700 "$CHROOT_DST/dev"
mkdir -m 700 "$CHROOT_DST/proc"
mkdir -m 700 "$CHROOT_DST/sys"
mkdir -m 700 "$CHROOT_DST/usr/lib"
mkdir -m 700 "$CHROOT_DST/usr/lib64"
mkdir -m 700 "$CHROOT_DST/usr/libexec"
mkdir -m 700 "$CHROOT_DST/usr/share"
mkdir -m 700 "$CHROOT_DST/lib"
mkdir -m 700 "$CHROOT_DST/lib64"
mkdir -m 700 "$CHROOT_DST/etc/fonts"
mkdir -m 700 "$CHROOT_DST/var/www"
mkdir -m 700 "$CHROOT_DST/var/log/php-fpm"
mkdir -m 700 "$CHROOT_DST/var/cache/fontconfig"

# Populate /etc
cp -d --preserve=all /etc/{localtime,hosts,nsswitch.conf,gai.conf,resolv.conf,ld.so.cache,my.cnf,environment} "$CHROOT_DST/etc/" &>/dev/null

# Popupate /etc/{passwd,group} files
if [[ ${#ENABLED_ACCOUNTS[@]} != 0 ]]; then
	for ACCOUNT in ${ENABLED_ACCOUNTS[*]}; do
		grep -P "^$ACCOUNT:" /etc/passwd >> "$CHROOT_DST/etc/passwd"
		ACCOUNT_GID=`grep -P "^$ACCOUNT:" /etc/passwd | sed 's/^.*:.*:.*:\([0-9]\+\):.*$/\1/'`
		grep -o -P "^.*:.*:$ACCOUNT_GID:" /etc/group >> "$CHROOT_DST/etc/group"
	done
	chcon --reference=/etc/passwd "$CHROOT_DST/etc/passwd"
	chcon --reference=/etc/group "$CHROOT_DST/etc/group"
else
	cp -d --preserve=all /etc/{passwd,group} "$CHROOT_DST/etc/"
fi

# cp is a required binary, link it to the chroot environment
ln "/bin/cp" "$CHROOT_DST/bin/cp"

# Link binaries wanted for the chroot environment
for CMD in ${WANT_BINARIES[*]}; do
	test -f "$CMD" && test -x "$CMD" && ln "$CMD" "$CHROOT_DST$CMD"
done

# Create bind mounts and set mount options

# Pseudo file systems
mount -obind /dev "$CHROOT_DST/dev"
mount -obind /proc "$CHROOT_DST/proc"
mount -obind /sys "$CHROOT_DST/sys"

# System libraries
mount -obind /usr/lib "$CHROOT_DST/usr/lib"
mount -oremount,nosuid,nodev "$CHROOT_DST/usr/lib"
mount -obind /usr/lib64 "$CHROOT_DST/usr/lib64"
mount -oremount,nosuid,nodev "$CHROOT_DST/usr/lib64"
mount -obind /usr/libexec "$CHROOT_DST/usr/libexec"
mount -oremount,nosuid,nodev "$CHROOT_DST/usr/libexec"
mount -obind /lib "$CHROOT_DST/lib"
mount -oremount,nosuid,nodev "$CHROOT_DST/lib"
mount -obind /lib64 "$CHROOT_DST/lib64"
mount -oremount,nosuid,nodev "$CHROOT_DST/lib64"

# Non-executable system directories
mount -obind /usr/share "$CHROOT_DST/usr/share"
mount -oremount,noexec,nosuid,nodev "$CHROOT_DST/usr/share"
mount -obind /var/www "$CHROOT_DST/var/www"
mount -oremount,noexec,nosuid,nodev "$CHROOT_DST/var/www"
mount -obind /var/log/php-fpm "$CHROOT_DST/var/log/php-fpm"
mount -oremount,noexec,nosuid,nodev "$CHROOT_DST/var/log/php-fpm"
mount -obind /var/cache/fontconfig "$CHROOT_DST/var/cache/fontconfig"
mount -oremount,noexec,nosuid,nodev "$CHROOT_DST/var/cache/fontconfig"
mount -obind /etc/fonts "$CHROOT_DST/etc/fonts"
mount -oremount,noexec,nosuid,nodev "$CHROOT_DST/etc/fonts"

# Temporary directories
mount -obind "$CHROOT_DST/tmp" "$CHROOT_DST/tmp"
mount -oremount,noexec,nosuid,nodev "$CHROOT_DST/tmp"
mount -obind "$CHROOT_DST/var/tmp" "$CHROOT_DST/var/tmp"
mount -oremount,noexec,nosuid,nodev "$CHROOT_DST/var/tmp"

# Prohobit setuid execution on chroot binaries
mount -obind "$CHROOT_DST/bin" "$CHROOT_DST/bin"
mount -oremount,nosuid,nodev "$CHROOT_DST/bin"
mount -obind "$CHROOT_DST/sbin" "$CHROOT_DST/sbin"
mount -oremount,nosuid,nodev "$CHROOT_DST/sbin"
mount -obind "$CHROOT_DST/usr/bin" "$CHROOT_DST/usr/bin"
mount -oremount,nosuid,nodev "$CHROOT_DST/usr/bin"
mount -obind "$CHROOT_DST/usr/sbin" "$CHROOT_DST/usr/sbin"
mount -oremount,nosuid,nodev "$CHROOT_DST/usr/sbin"
mount -obind "$CHROOT_DST/usr/local/bin" "$CHROOT_DST/usr/local/bin"
mount -oremount,nosuid,nodev "$CHROOT_DST/usr/local/bin"
mount -obind "$CHROOT_DST/usr/local/sbin" "$CHROOT_DST/usr/local/sbin"
mount -oremount,nosuid,nodev "$CHROOT_DST/usr/local/sbin"

# Create mtab for chroot environment
chroot "$CHROOT_DST" /bin/cp -fL /proc/mounts /etc/mtab

# Link MySQL socket to chroot environment
ln /var/lib/mysql/mysql.sock "$CHROOT_DST/var/lib/mysql/mysql.sock"

