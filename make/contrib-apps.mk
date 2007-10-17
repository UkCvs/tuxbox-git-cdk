#######################
#
#   contrib apps
#

contrib_apps: bzip2 console_data console_tools fbset lirc ide_apps lsof dropbear ssh tcpdump bonnie lufs kermit wget ncftp

ide_apps: hdparm utillinux e2fsprogs parted hddtemp xfsprogs smartmontools 

$(DEPDIR)/bzip2: bootstrap @DEPENDS_bzip2@
	@PREPARE_bzip2@
	cd @DIR_bzip2@ && \
	mv Makefile-libbz2_so Makefile && \
		CC=$(target)-gcc \
		$(MAKE) all && \
		@INSTALL_bzip2@
	@CLEANUP_bzip2@
	touch $@

if TARGETRULESET_FLASH
flash-bzip2: $(flashprefix)/root/bin/bzip2

$(flashprefix)/root/bin/bzip2: @DEPENDS_bzip2@ | $(flashprefix)/root
	@PREPARE_bzip2@
	cd @DIR_bzip2@ && \
	mv Makefile-libbz2_so Makefile && \
		CC=$(target)-gcc \
		$(MAKE) all && \
		$(MAKE) install PREFIX=$(flashprefix)/root
	@CLEANUP_bzip2@
	@FLASHROOTDIR_MODIFIED@

endif

$(DEPDIR)/console_data: bootstrap @DEPENDS_console_data@
	@PREPARE_console_data@
	cd @DIR_console_data@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-main_compressor=gzip && \
		@INSTALL_console_data@
	@CLEANUP_console_data@
	touch $@

$(DEPDIR)/console_tools: bootstrap console_data @DEPENDS_console_tools@
	@PREPARE_console_tools@
	cd @DIR_console_tools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		@INSTALL_console_tools@
	@CLEANUP_console_tools@
	touch $@

if TARGETRULESET_FLASH 

# This is ugly, very ugly. But I do not know of a completely clean way
# of installing just the minimum.

flash-german-keymaps: $(DEPDIR)/console_tools
	$(INSTALL) $(targetprefix)/bin/loadkeys $(flashprefix)/root/bin
	$(INSTALL) -d $(flashprefix)/root/share/keymaps/i386/qwertz
	$(INSTALL) -d $(flashprefix)/root/share/keymaps/i386/include
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/qwertz/de-latin1-nodeadkeys.kmap.gz $(flashprefix)/root/share/keymaps/i386/qwertz
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/qwertz/de-latin1.kmap.gz $(flashprefix)/root/share/keymaps/i386/qwertz
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/include/linux-keys-bare.inc.gz $(flashprefix)/root/share/keymaps/i386/include
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/include/linux-with-alt-and-altgr.inc.gz $(flashprefix)/root/share/keymaps/i386/include
	$(INSTALL) -m 444 $(targetprefix)/share/keymaps/i386/include/qwertz-layout.inc.gz $(flashprefix)/root/share/keymaps/i386/include
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@

endif

$(DEPDIR)/directfb_examples: bootstrap libdirectfb @DEPENDS_directfb_examples@
	@PREPARE_directfb_examples@
	cd @DIR_directfb_examples@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_directfb_examples@
	@CLEANUP_directfb_examples@
	touch $@

$(DEPDIR)/fbset: bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		$(MAKE) \
			$(BUILDENV) && \
		@INSTALL_fbset@
	@CLEANUP_fbset@
	touch $@

$(DEPDIR)/lirc: bootstrap @DEPENDS_lirc@ Patches/lirc.diff
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		$(BUILDENV) \
		mknod=/bin/true \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-devdir=/dev \
			--with-driver=none \
			--with-kerneldir=$(buildprefix)/linux \
			--with-moduledir=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
			--without-x && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	touch $@

if TARGETRULESET_FLASH
flash-lircd: $(flashprefix)/root/sbin/lircd

$(flashprefix)/root/sbin/lircd: lirc
	$(INSTALL) $(targetprefix)/sbin/lircd $@
	$(INSTALL) -d $(targetprefix)/var/tuxbox/config/lirc
	@FLASHROOTDIR_MODIFIED@

endif

# contains [cs]fdisk etc
$(DEPDIR)/utillinux: bootstrap @DEPENDS_utillinux@
	@PREPARE_utillinux@
	cd @DIR_utillinux@ && \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float -I$(targetprefix)/include/ncurses" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure && \
		$(MAKE) ARCH=ppc all && \
		@INSTALL_utillinux@
	@CLEANUP_utillinux@
	touch $@

if TARGETRULESET_FLASH
flash-sfdisk: $(flashprefix)/root/sbin/sfdisk

$(flashprefix)/root/sbin/sfdisk: utillinux
	$(INSTALL) $(targetprefix)/sbin/sfdisk $@
	@FLASHROOTDIR_MODIFIED@

flash-cfdisk: $(flashprefix)/root/sbin/cfdisk

$(flashprefix)/root/sbin/cfdisk: utillinux
	$(INSTALL) $(targetprefix)/sbin/cfdisk $@
	@FLASHROOTDIR_MODIFIED@

#replaces busybox fdisk
flash-fdisk: $(flashprefix)/root/sbin/fdisk

$(flashprefix)/root/sbin/fdisk: utillinux
	$(INSTALL) $(targetprefix)/sbin/fdisk $@
	@FLASHROOTDIR_MODIFIED@

endif

$(DEPDIR)/e2fsprogs: bootstrap @DEPENDS_e2fsprogs@
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			--disable-nls && \
		$(MAKE) libs progs && \
		$(MAKE) install-libs && \
		@INSTALL_e2fsprogs@
	@CLEANUP_e2fsprogs@
	touch $@

if TARGETRULESET_FLASH

flash-e2fsprogs: $(flashprefix)/root/sbin/e2fsck

$(flashprefix)/root/sbin/e2fsck: bootstrap @DEPENDS_e2fsprogs@ | $(flashprefix)/root
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			--disable-nls && \
		$(MAKE) libs progs && \
		$(MAKE) install-libs && \
		@INSTALL_e2fsprogs@
	$(INSTALL) $(targetprefix)/sbin/badblocks $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/resize2fs $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/tune2fs $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/fsck $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/fsck.ext2 $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/fsck.ext3 $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/mkfs.ext2 $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/mkfs.ext3 $(flashprefix)/root/sbin/
	$(INSTALL) $(targetprefix)/sbin/e2label $(flashprefix)/root/sbin/
		@CLEANUP_e2fsprogs@
	@@FLASHROOTDIR_MODIFIED@@
endif

$(DEPDIR)/parted: bootstrap libreadline e2fsprogs @DEPENDS_parted@
	@PREPARE_parted@
	cd @DIR_parted@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		$(MAKE) all && \
		@INSTALL_parted@
	@CLEANUP_parted@
	touch $@

$(DEPDIR)/lsof: bootstrap @DEPENDS_lsof@
	@PREPARE_lsof@
	cd @DIR_lsof@ && \
	tar xvf @DIR_lsof@_src.tar && \
	cd @DIR_lsof@_src && \
	patch -p1 < ../../Patches/lsof.diff && \
		CROSS_COMPILE=$(target)- \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LSOF_VSTR=$(KERNELVERSION) \
		LINUX_CLIB="-DGLIBCV=202" \
		./Configure -n linux && \
		$(MAKE) all && \
		@INSTALL_lsof@
	@CLEANUP_lsof@
	touch $@

$(DEPDIR)/dropbear: bootstrap libz @DEPENDS_dropbear@ Patches/dropbear-options.h
	@PREPARE_dropbear@
	cd @DIR_dropbear@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-syslog \
			--disable-shadow \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx && \
		cp ../Patches/dropbear-options.h options.h && \
		$(MAKE) PROGRAMS="dropbear dropbearkey scp" MULTI=1 && \
		mkdir -p $(targetprefix)/var/etc/dropbear && \
		mkdir -p $(targetprefix)/var/.ssh && \
		@INSTALL_dropbear@ && \
		$(target)-strip --strip-all $(targetprefix)/sbin/dropbearmulti
	@CLEANUP_dropbear@
	touch $@

if TARGETRULESET_FLASH

flash-dropbear: $(flashprefix)/root/sbin/dropbearmulti

$(flashprefix)/root/sbin/dropbearmulti: $(DEPDIR)/dropbear | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/sbin/dropbearmulti $(flashprefix)/root/sbin
	for i in dropbear scp dropbearkey; do \
		ln -sf dropbearmulti $(flashprefix)/root/sbin/$$i; done;
	mkdir -p $(flashprefix)/root/var/.ssh
	mkdir -p $(flashprefix)/root/var/etc/dropbear
	ln -sf /var/.ssh $(flashprefix)/root/.ssh
	@FLASHROOTDIR_MODIFIED@

endif

$(DEPDIR)/ssh: bootstrap libcrypto libz @DEPENDS_ssh@
	@PREPARE_ssh@
	cd @DIR_ssh@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--sysconfdir=/etc/ssh \
			--without-shadow \
			--with-4in6 \
			--disable-suid-ssh \
			--with-path="/bin:/sbin" \
			--with-privsep-user=sshd \
			--with-privsep-path=/share/empty && \
		$(MAKE) all && \
		@INSTALL_ssh@
	@CLEANUP_ssh@
	touch $@

if TARGETRULESET_FLASH
flash-ssh: $(flashprefix)/root/bin/ssh

$(flashprefix)/root/bin/ssh: $(flashprefix)/root $(DEPDIR)/ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh

flash-sshd: $(flashprefix)/root/sbin/sshd

$(flashprefix)/root/sbin/sshd: $(DEPDIR)/ssh | $(flashprefix)/root
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
#??#	cp -rd $(targetprefix)/etc/init.d/start_sshd $(flashprefix)/root/etc/init.d/
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin
	@FLASHROOTDIR_MODIFIED@
endif

$(DEPDIR)/tcpdump: bootstrap libpcap @DEPENDS_tcpdump@
	@PREPARE_tcpdump@
	cd @DIR_tcpdump@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-smb \
			--disable-ipv6 \
			--without-crypto && \
		$(MAKE) all && \
		@INSTALL_tcpdump@
	@CLEANUP_tcpdump@
	touch $@

$(DEPDIR)/bonnie: bootstrap @DEPENDS_bonnie@
	@PREPARE_bonnie@
	cd @DIR_bonnie@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all WFLAGS= && \
                $(target)-strip -s bonnie++ &&\
		cp bonnie++ $(targetprefix)/sbin/bonnie
	@CLEANUP_bonnie@
	touch $@

if TARGETRULESET_FLASH
flash-bonnie: $(flashprefix)/root/sbin/bonnie

$(flashprefix)/root/sbin/bonnie: bonnie | $(flashprefix)/root
	cp $(targetprefix)/sbin/bonnie $@
	@FLASHROOTDIR_MODIFIED@

endif

$(DEPDIR)/vdr: bootstrap @DEPENDS_vdr@
	@PREPARE_vdr@
	cd @DIR_vdr@ && \
		$(BUILDENV) \
		DVBDIR="$(driverdir)/dvb" \
		$(MAKE) all DRIVERDIR=$(driverdir) && \
		$(MAKE) plugins PREFIX=$(prefix) DRIVERDIR=$(driverdir) && \
		@INSTALL_vdr@
	@CLEANUP_vdr@
	touch $@

$(DEPDIR)/lufs: bootstrap @DEPENDS_lufs@
	@PREPARE_lufs@
	cd @DIR_lufs@ && \
		$(BUILDENV) \
		aclocal && \
		libtoolize --force && \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--exec_prefix=$(targetprefix) \
			--disable-kernel-support && \
		$(MAKE) all && \
		@INSTALL_lufs@ && \
		ln -sf ../bin/lufsd $(targetprefix)/sbin/mount.lufs
	@CLEANUP_lufs@
	touch $@

if TARGETRULESET_FLASH
flash-lufsd: $(flashprefix)/root/bin/lufsd

$(flashprefix)/root/bin/lufsd: bootstrap @DEPENDS_lufs@ | $(flashprefix)/root
	@PREPARE_lufs@
	cd @DIR_lufs@ && \
		$(BUILDENV) \
		aclocal && \
		libtoolize --force && \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(flashprefix)/root \
			--exec_prefix=$(flashprefix)/root \
			--disable-kernel-support && \
		$(MAKE) all install
	rm $(flashprefix)/root/bin/auto.ftpfs
	rm $(flashprefix)/root/bin/auto.sshfs
	rm $(flashprefix)/root/bin/lufsmount
	rm $(flashprefix)/root/bin/lufsumount
	rm $(flashprefix)/root/bin/lussh
	rm $(flashprefix)/root/etc/auto.sshfs
	rm $(flashprefix)/root/etc/auto.ftpfs
	rm $(flashprefix)/root/lib/liblufs-sshfs.*
	ln -sf ../bin/lufsd $(flashprefix)/root/sbin/mount.lufs
	@CLEANUP_lufs@
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@
endif

$(DEPDIR)/kermit: bootstrap @DEPENDS_kermit@ libcrypto Patches/kermit.diff
	@echo "Kermit is licensed differently from other software (more restrictively),"
	@echo "see http://www.columbia.edu/kermit/licensing.html"
	@PREPARE_kermit@
	cd @DIR_kermit@ && \
		$(BUILDENV) \
		$(MAKE) tuxbox && \
		@INSTALL_kermit@
	ln -sf ./kermit $(targetprefix)/bin/kermit-sshsub
	[ -d $(targetprefix)/var/lock ] ||  mkdir $(targetprefix)/var/lock
	@CLEANUP_kermit@
	touch $@

$(DEPDIR)/hdparm: bootstrap @DEPENDS_hdparm@
	@PREPARE_hdparm@
	cd @DIR_hdparm@ && \
		$(BUILDENV) \
		$(MAKE) CROSS=$(target)- all && \
		@INSTALL_hdparm@
		@CLEANUP_hdparm@
	touch $@

if TARGETRULESET_FLASH
flash-hdparm: $(flashprefix)/root/sbin/hdparm

$(flashprefix)/root/sbin/hdparm: bootstrap @DEPENDS_hdparm@ | $(flashprefix)/root
	@PREPARE_hdparm@
	cd @DIR_hdparm@ && \
		$(BUILDENV) \
		$(MAKE) CROSS=$(target)- all && \
		$(MAKE) install DESTDIR=$(targetprefix)
		$(INSTALL) $(targetprefix)/sbin/hdparm $(flashprefix)/root/sbin/
	@CLEANUP_hdparm@
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@

endif

$(DEPDIR)/hddtemp: bootstrap @DEPENDS_hddtemp@
	@PREPARE_hddtemp@
	cd @DIR_hddtemp@ && \
		$(BUILDENV) \
		./configure \
		--with-db-path=/share/tuxbox/hddtemp.db \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=$(targetprefix)
		$(INSTALL) -m 644 Patches/hddtemp.db $(targetprefix)/share/tuxbox
	@CLEANUP_hddtemp@
	touch $@ 

if TARGETRULESET_FLASH
flash-hddtemp: $(flashprefix)/root/sbin/hddtemp

$(flashprefix)/root/sbin/hddtemp: bootstrap @DEPENDS_hddtemp@ | $(flashprefix)/root
	@PREPARE_hddtemp@
	cd @DIR_hddtemp@ && \
		$(BUILDENV) \
		./configure \
		--with-db-path=/share/tuxbox/hddtemp.db \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=$(flashprefix)/root
		$(INSTALL) -m 644 Patches/hddtemp.db $(flashprefix)/root/share/tuxbox
	@CLEANUP_hddtemp@
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@

endif

# xfsprogs needs "special" built libtool and uuid header/lib of e2fsprogs
$(DEPDIR)/xfsprogs: bootstrap libtool @DEPENDS_e2fsprogs@ @DEPENDS_xfsprogs@
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		RANLIB=$(target)-ranlib \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix= \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			--disable-nls && \
		$(MAKE) libs && \
		$(INSTALL) -d $(targetprefix)/include/uuid && \
		$(INSTALL) -m 644 lib/uuid/uuid.h $(targetprefix)/include/uuid && \
		$(INSTALL) -m 644 lib/uuid/uuid_types.h $(targetprefix)/include/uuid && \
		$(INSTALL) lib/uuid/libuuid.a $(targetprefix)/lib && \
		$(INSTALL) lib/uuid/libuuid.so.1.2 $(targetprefix)/lib && \
		ln -sf libuuid.so.1.2 $(targetprefix)/lib/libuuid.so.1 && \
		ln -sf libuuid.so.1 $(targetprefix)/lib/libuuid.so
#		$(MAKE) libs
#		$(MAKE) install-libs DESTDIR=$(targetprefix)
	@CLEANUP_e2fsprogs@
	@PREPARE_xfsprogs@
	cd @DIR_xfsprogs@ && \
		LIBTOOL=$(hostprefix)/bin/libtool \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix=$(targetprefix) &&\
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(targetprefix)
	@CLEANUP_xfsprogs@
	touch $@

if TARGETRULESET_FLASH
flash-xfsprogs: $(flashprefix)/root/sbin/mkfs.xfs

$(flashprefix)/root/sbin/mkfs.xfs: bootstrap libtool @DEPENDS_e2fsprogs@ @DEPENDS_xfsprogs@ | $(flashprefix)/root
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		RANLIB=$(target)-ranlib \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix= \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--enable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			--disable-nls && \
		$(MAKE) libs && \
		$(INSTALL) -d $(targetprefix)/include/uuid && \
		$(INSTALL) -m 644 lib/uuid/uuid.h $(targetprefix)/include/uuid && \
		$(INSTALL) -m 644 lib/uuid/uuid_types.h $(targetprefix)/include/uuid && \
		$(INSTALL) lib/uuid/libuuid.a $(targetprefix)/lib && \
		$(INSTALL) lib/uuid/libuuid.so.1.2 $(targetprefix)/lib && \
		ln -sf libuuid.so.1.2 $(targetprefix)/lib/libuuid.so.1 && \
		ln -sf libuuid.so.1 $(targetprefix)/lib/libuuid.so
#		$(MAKE) libs
#		$(MAKE) install-libs DESTDIR=$(targetprefix)
	@CLEANUP_e2fsprogs@
	@PREPARE_xfsprogs@
	cd @DIR_xfsprogs@ && \
		LIBTOOL=$(hostprefix)/bin/libtool \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix=$(targetprefix) && \
		$(MAKE) && \
		for i in mkfs/mkfs.xfs repair/xfs_repair; do \
			$(INSTALL) $$i $(flashprefix)/root/sbin; done;
	@CLEANUP_xfsprogs@
	@FLASHROOTDIR_MODIFIED@

endif

$(DEPDIR)/smartmontools: bootstrap @DEPENDS_smartmontools@
	@PREPARE_smartmontools@
	cd @DIR_smartmontools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix=$(targetprefix) &&\
		$(MAKE) && \
		$(MAKE) install DESTDIR=
	@CLEANUP_smartmontools@
	touch $@

if TARGETRULESET_FLASH
flash-smartmontools: $(flashprefix)/root/sbin/smartctl

$(flashprefix)/root/sbin/smartctl: bootstrap @DEPENDS_smartmontools@ | $(flashprefix)/root
	@PREPARE_smartmontools@
	cd @DIR_smartmontools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--includedir=$(targetprefix)/include \
			--prefix=$(targetprefix) &&\
		$(MAKE) && \
		for i in smartctl ; do \
			$(INSTALL) $$i $(flashprefix)/root/sbin; done;
	@CLEANUP_smartmontools@
	@FLASHROOTDIR_MODIFIED@

endif

$(DEPDIR)/wget: bootstrap @DEPENDS_wget@
	@PREPARE_wget@
	cd @DIR_wget@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
	$(MAKE) install $(targetprefix)/bin
	@CLEANUP_wget@
	touch $@

if TARGETRULESET_FLASH
flash-wget: $(flashprefix)/root/bin/wget

$(flashprefix)/root/bin/wget: wget | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/wget
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/wget $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

endif

$(DEPDIR)/ncftp: bootstrap Archive/ncftp-3.2.0-src.tar.bz2
	( rm -rf ncftp-3.2.0 || /bin/true ) && bunzip2 -cd Archive/ncftp-3.2.0-src.tar.bz2 | TAPE=- tar -x
	cd ncftp-3.2.0 && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) clean all LD=$(target)-ld && \
		$(MAKE) install DESTDIR=$(targetprefix)
	rm -rf ncftp-3.2.0
	touch $@


if TARGETRULESET_FLASH

flash-ncftp: $(flashprefix)/root/bin/ncftp

$(flashprefix)/root/bin/ncftp: ncftp | $(flashprefix)/root
	@$(INSTALL) -d $(flashprefix)/root/sbin
	@for i in ncftp ncftpbatch ncftpget ncftpls ncftpput ncftpspooler; do \
	$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; done;
	@FLASHROOTDIR_MODIFIED@

endif

