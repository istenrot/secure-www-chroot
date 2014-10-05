# Security hardened chroot for servers

## Introduction

So, you're installing up a server for your shiny new web site. And as a security savvy programmer you're hardening your new server as well as you can. That's right! You configure PHP-FPM to disable unsafe PHP functions like `exec, passthru, shell_exec, system, proc_open,popen, curl_exec, curl_multi_exec` and you're feeling confident that your web site is as tough as it gets. It's all good, you think. But then all of a sudden you realize that your web CMS is unable to modify images with ImageMagick or create PDF files with Ghostscript. You feel disappointed. All that hard work you had made for the security of your web site have to be stripped down now. Quality optimized images are more important for you than an extreme level of security. You wish there was an easy way to harden your server while keeping option to execute some nice binaries directly from your CMS. You know that **chroot** might be the right solution for this problem but you fear it's far too complicated task to set up. Fear not! Here's a helpful script that automates secure chroot install tasks.

The script called *create-www-chroot.sh* is a Bash script designed for EL6 and compatible Linux distributions to install security hardened chroot environments automatically. It's originally developed for LAMP servers running PHP-FPM in mind but with minor modifications it can be adapted for servers running for example PostgreSQL DBMS and some other FastCGI server.

Without modifications the script expects that server's document root is under */var/www* and temporary directories are */tmp* and */var/tmp*.

## Features

* You don't need to update chroot environments separately from the base system, all binaries are hard linked and libraries are bind mounted
* You don't need to rebuild chroot environments to add system fonts
* It creates temporary directories isolated from the base system for chroot environments
* It uses bind mounts to set safe mount options for temporary directories
* It prohibits use of setuid binaries
* Supports SELinux

## How to install

Copy the script file *create-www-chroot.sh* to */usr/local/sbin*.

## Usage

Here we use */srv/php-chroot* as an example destination for a new chroot environment.

Add this to */etc/rc.local*:
```
/usr/local/sbin/create-www-chroot.sh /srv/php-chroot
```

You may now reboot. Or run the script with root privileges without need to reboot: `sudo create-www-chroot.sh /srv/php-chroot`

In order to rebuild a chroot environment you need to unmount all bind mounts related to the chroot environment first: `sudo create-www-chroot.sh -u /srv/php-chroot`
Then you can rebuild: `sudo create-www-chroot.sh /srv/php-chroot`

## PHP-FPM build-in chroot support

PHP-FPM has buid-in support for spawning child processes into a chroot environment. It's easy to configure. For example you add a line like this to */etc/php-fpm.d/www.conf*:
```
chroot = /srv/php-chroot
```

## License

The MIT License (MIT)

Copyright (c) 2014 Ilari Stenroth

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

