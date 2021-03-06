#######################
#
#   contrib apps
#

contrib_apps: bzip2 console_data kbd fbset lirc lsof dropbear ssh tcpdump bonnie @LUFS@ kermit wget ncftp screen lzma lzma_host ntpd ntpclient links links_g esound python ser2net ipkg openvpn htop netio netio_host

CONTRIB_DEPSCLEANUP = rm -f .deps/bzip2 .deps/console_data .deps/kbd .deps/directfb_examples .deps/fbset .deps/lirc .deps/lsof .deps/ssh .deps/tcpdump .deps/bonnie .deps/vdr .deps/lufs .deps/dropbear .deps/kermit .deps/wget .deps/ncftp .deps/screen .deps/lzma .deps/lzma_host .deps/ntpd .deps/ntpclient .deps/links .deps/links_g .deps/esound .deps/openntpd .deps/python .deps/ser2net .deps/ipkg .deps/openvpn .deps/htop .deps/netio .deps/netio_host

if ENABLE_SSL
SSL_DEPS=libcrypto
SSL_WGET_OPTS=--with-ssl=openssl
SSL_LINKS_OPTS=--with-ssl=$(targetprefix)
else
SSL_DEPS=
SSL_WGET_OPTS=--without-ssl
SSL_LINKS_OPTS=--without-ssl
endif

#bzip2
$(DEPDIR)/bzip2: bootstrap @DEPENDS_bzip2@
	@PREPARE_bzip2@
	cd @DIR_bzip2@ && \
	mv Makefile-libbz2_so Makefile && \
		CC=$(target)-gcc \
		$(MAKE) all && \
		@INSTALL_bzip2@
	@CLEANUP_bzip2@
	touch $@

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

#console_data console_tools
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

$(DEPDIR)/kbd: bootstrap console_data @DEPENDS_kbd@
	@PREPARE_kbd@
	cd @DIR_kbd@ && \
		autoconf && \
		sed -i \
		-e "s:install -s:install:" \
		src/Makefile.in && \
		$(BUILDENV) \
		ac_cv_func_realloc_0_nonnull=yes \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		$(BUILDENV) \
		@INSTALL_kbd@
	@CLEANUP_kbd@
	touch $@

# This is ugly, very ugly. But I do not know of a completely clean way
# of installing just the minimum.

flash-german-keymaps: $(DEPDIR)/kbd
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


#fbset
$(DEPDIR)/fbset: bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		$(BUILDENV) \
		$(MAKE) && \
		@INSTALL_fbset@
	@CLEANUP_fbset@
	touch $@

#lirc
$(DEPDIR)/lirc: bootstrap @DEPENDS_lirc@
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		$(BUILDENV) \
		mknod=/bin/true \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-devdir=/dev \
			--with-driver=tuxbox \
			--with-kerneldir=$(buildprefix)/linux \
			--with-moduledir=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
			--without-x && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	touch $@

flash-lircd: $(flashprefix)/root/sbin/lircd

$(flashprefix)/root/sbin/lircd: lirc
	$(INSTALL) $(targetprefix)/sbin/lircd $@
	$(INSTALL) -d $(targetprefix)/var/tuxbox/config/lirc
	@FLASHROOTDIR_MODIFIED@

#lsof
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

#dropbear
$(DEPDIR)/dropbear: bootstrap libz @DEPENDS_dropbear@
	@PREPARE_dropbear@
	cd @DIR_dropbear@ && \
		autoconf && \
		$(BUILDENV_BIN) \
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
		$(MAKE) PROGRAMS="dropbear dropbearkey scp dbclient" MULTI=1 && \
		mkdir -p $(targetprefix)/var/etc/dropbear && \
		mkdir -p $(targetprefix)/var/ssh && \
		@INSTALL_dropbear@ && \
		$(target)-strip --strip-all $(targetprefix)/sbin/dropbearmulti
	@CLEANUP_dropbear@
	touch $@

flash-dropbear: $(flashprefix)/root/sbin/dropbearmulti

$(flashprefix)/root/sbin/dropbearmulti: $(DEPDIR)/dropbear | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/sbin/dropbearmulti $(flashprefix)/root/sbin
	for i in dropbear scp dropbearkey dbclient; do \
		ln -sf dropbearmulti $(flashprefix)/root/sbin/$$i; done;
	mkdir -p $(flashprefix)/root/var/ssh
	mkdir -p $(flashprefix)/root/var/etc/dropbear
	ln -sf /var/ssh $(flashprefix)/root/.ssh
	@FLASHROOTDIR_MODIFIED@

#ssh
$(DEPDIR)/ssh: bootstrap libcrypto libz @DEPENDS_ssh@
	@PREPARE_ssh@
	cd @DIR_ssh@ && \
		autoconf && \
		$(BUILDENV) \
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

#tcpdump
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

#bonnie
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

flash-bonnie: $(flashprefix)/root/sbin/bonnie

$(flashprefix)/root/sbin/bonnie: bonnie | $(flashprefix)/root
	cp $(targetprefix)/sbin/bonnie $@
	@FLASHROOTDIR_MODIFIED@

#vdr
$(DEPDIR)/vdr: bootstrap @DEPENDS_vdr@
	@PREPARE_vdr@
	cd @DIR_vdr@ && \
		$(BUILDENV) \
		DVBDIR="$(driverdir)/dvb" \
		$(MAKE) all DRIVERDIR=$(driverdir) && \
		$(BUILDENV) \
		$(MAKE) plugins PREFIX=$(prefix) DRIVERDIR=$(driverdir) && \
		@INSTALL_vdr@
	@CLEANUP_vdr@
	touch $@

if ENABLE_FS_LUFS
#lufs
$(DEPDIR)/lufs: bootstrap @DEPENDS_lufs@
	@PREPARE_lufs@
	cd @DIR_lufs@ && \
		aclocal && \
		case `libtoolize --version | head -n 1 | awk '{ print $$(NF); }'` in \
		    0.*|1.*)    libtoolize --force ;; \
		    *)          libtoolize --force --install ;; \
		esac && \
		autoconf && \
		$(BUILDENV) \
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

flash-lufsd: $(flashprefix)/root/bin/lufsd

$(flashprefix)/root/bin/lufsd: bootstrap @DEPENDS_lufs@ | $(flashprefix)/root
	@PREPARE_lufs@
	cd @DIR_lufs@ && \
		aclocal && \
		case `libtoolize --version | head -n 1 | awk '{ print $$(NF); }'` in \
		    0.*|1.*)    libtoolize --force ;; \
		    *)          libtoolize --force --install ;; \
		esac && \
		autoconf && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(flashprefix)/root \
			--exec_prefix=$(flashprefix)/root \
			--disable-kernel-support && \
		$(MAKE) all && \
		$(MAKE) install
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

#kermit
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

#wget
$(DEPDIR)/wget: bootstrap libz $(SSL_DEPS) @DEPENDS_wget@
	@PREPARE_wget@
	cd @DIR_wget@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--disable-ipv6 \
			--disable-nls \
			--disable-opie \
			--disable-digest \
			$(SSL_WGET_OPTS) \
			--prefix=&& \
		$(MAKE) all && \
		@INSTALL_wget@
	@CLEANUP_wget@
	touch $@

flash-wget: $(flashprefix)/root/bin/wget

$(flashprefix)/root/bin/wget: wget | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/wget
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/wget $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

#ncftp
$(DEPDIR)/ncftp: bootstrap @DEPENDS_ncftp@
	@PREPARE_ncftp@
	cd @DIR_ncftp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) clean && \
		$(MAKE) all LD=$(target)-ld && \
		@INSTALL_ncftp@
	@CLEANUP_ncftp@
	touch $@

flash-ncftp: $(flashprefix)/root/bin/ncftp

$(flashprefix)/root/bin/ncftp: ncftp | $(flashprefix)/root
	@$(INSTALL) -d $(flashprefix)/root/sbin
	@for i in ncftp ncftpbatch ncftpget ncftpls ncftpput ncftpspooler; do \
	$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; done;
	@FLASHROOTDIR_MODIFIED@

#screen
$(DEPDIR)/screen: bootstrap libncurses @DEPENDS_screen@
	@PREPARE_screen@
	cd @DIR_screen@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_screen@
	@CLEANUP_screen@
	touch $@

flash-screen: $(flashprefix)/root/bin/screen

$(flashprefix)/root/bin/screen: screen | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/screen
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/screen $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

#lzma
$(DEPDIR)/lzma: bootstrap @DEPENDS_lzma@
	@PREPARE_lzma@
	cd @DIR_lzma@ && \
		$(BUILDENV) \
		$(MAKE) -C CPP/7zip/Compress/LZMA_Alone -f makefile.gcc && \
		@INSTALL_lzma@
	@CLEANUP_lzma@
	touch $@

flash-lzma: $(flashprefix)/root/bin/lzma
flash-lzma_alone: $(flashprefix)/root/bin/lzma_alone

$(flashprefix)/root/bin/lzma: lzma | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/lzma
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/lzma $(flashprefix)/root/bin; done
	@FLASHROOTDIR_MODIFIED@

$(flashprefix)/root/bin/lzma_alone: lzma | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/lzma_alone
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/lzma_alone $(flashprefix)/root/bin; done
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/lzma_host: directories @DEPENDS_lzma_host@
	@PREPARE_lzma_host@
	cd @DIR_lzma_host@ && \
		$(MAKE) -C CPP/7zip/Compress/LZMA_Alone -f makefile.gcc && \
		@INSTALL_lzma_host@
	@CLEANUP_lzma_host@
	touch $@

$(DEPDIR)/links: bootstrap @DEPENDS_links@
	@PREPARE_links@
	cd @DIR_links@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_links@
	@CLEANUP_links@
	touch $@

flash-links: $(flashprefix)/root/bin/links

$(flashprefix)/root/bin/links: $(DEPDIR)/links | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/bin/links $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/links_g: bootstrap libdirectfb kb2rcd links-plugin $(SSL_DEPS) @DEPENDS_links_g@
	@PREPARE_links_g@
	cd @DIR_links_g@ && \
		$(BUILDENV_BIN) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-graphics \
			--without-x \
			$(SSL_LINKS_OPTS) \
			--oldincludedir=$(targetprefix)/include:$(targetprefix)/include/directfb && \
		$(MAKE) all && \
		@INSTALL_links_g@
	@CLEANUP_links_g@
	$(INSTALL) $(appsdir)/tuxbox/tools/kb2rcd/kb2rcd_links.conf $(targetprefix)/var/tuxbox/config
	touch $@

flash-links_g: flash-kb2rcd flash-links-plugin $(flashprefix)/root/bin/links_g

$(flashprefix)/root/bin/links_g: $(DEPDIR)/links_g | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/bin/links_g $(flashprefix)/root/bin
	$(INSTALL) $(appsdir)/tuxbox/tools/kb2rcd/kb2rcd_links.conf $(flashprefix)/root/var/tuxbox/config
	cp -va $(targetprefix)/lib/directfb-1.0-0 $(flashprefix)/root/lib/
	@FLASHROOTDIR_MODIFIED@

# ntpd
$(DEPDIR)/ntpd: bootstrap @DEPENDS_ntpd@
	@PREPARE_ntpd@
	cd @DIR_ntpd@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=&& \
		$(MAKE) all && \
		@INSTALL_ntpd@
	@CLEANUP_ntpd@
	touch $@

flash-ntpd: $(flashprefix)/root/bin/ntpd

$(flashprefix)/root/bin/ntpd: ntpd | $(flashprefix)/root
	@$(INSTALL) -d $(flashprefix)/root/bin
		@for i in ntpd ntpdate ntpdc ntp-keygen ntptime ntptrace ntp-wait; do \
		$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; done;
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/ntpclient: bootstrap @DEPENDS_ntpclient@
	@PREPARE_ntpclient@
	cd @DIR_ntpclient@ && \
		$(BUILDENV) \
		$(MAKE) all && \
		@INSTALL_ntpclient@
	@CLEANUP_ntpclient@
	touch $@

flash-ntpclient: $(flashprefix)/root/bin/ntpclient

$(flashprefix)/root/bin/ntpclient: ntpclient | $(flashprefix)/root
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/ntpclient $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/openntpd: bootstrap @DEPENDS_openntpd@
	@PREPARE_openntpd@
	cd @DIR_openntpd@ && \
		ln -s `which $(target)-strip` strip; \
		echo "ac_cv_path_AR=$(target)-ar" > config.cache; \
		echo "ac_cv_func_setproctitle=no" >> config.cache; \
		echo "ac_cv_func_arc4random=no" >> config.cache; \
		echo "ac_cv_func_strlcpy=no" >> config.cache; \
		$(BUILDENV) ./configure --cache-file=config.cache \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-builtin-arc4random \
			--sysconfdir=/var/etc --with-privsep-user=nobody --with-privsep-path=/share/empty && \
		$(MAKE) all &&\
		PATH=.:$(PATH) @INSTALL_openntpd@
	@CLEANUP_openntpd@
	touch $@

flash-openntpd: $(flashprefix)/root/sbin/ntpd
$(flashprefix)/root/sbin/ntpd: openntpd | $(flashprefix)/root
	@$(INSTALL) -d $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/ntpd $(flashprefix)/root/sbin
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/esound: bootstrap @DEPENDS_esound@
	@PREPARE_esound@
	cd @DIR_esound@ && \
		$(BUILDENV_BIN) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-ipv6 \
			--disable-alsa \
			--disable-arts && \
		$(MAKE) all && \
		@INSTALL_esound@
	@CLEANUP_esound@
	touch $@

flash-esound: $(flashprefix)/root/bin/esd

$(flashprefix)/root/bin/esd: $(DEPDIR)/esound | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/bin/esd $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/python: bootstrap libz @DEPENDS_python@
	@PREPARE_python@
	cd @DIR_python@ && \
		for f1 in config.guess config.sub; do ln -s $(buildprefix)/Patches/$$f1 $$f1; done && \
		autoconf && \
		$(BUILDENV) \
		LDSHARED=powerpc-tuxbox-linux-gnu-ld \
		CROSS_ROOT=$(targetprefix) \
		CROSS_COMPILING=yes \
		PYTHON_FOR_BUILD=/usr/bin/python \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-threads \
			--with-pymalloc \
			--with-cyclic-gc \
			--without-cxx \
			--with-signal-module \
			--with-wctype-functions \
			--enable-shared && \
		$(MAKE) all && \
		@INSTALL_python@
	@CLEANUP_python@
	touch $@

$(DEPDIR)/ser2net: bootstrap @DEPENDS_ser2net@
	@PREPARE_ser2net@
	cd @DIR_ser2net@ && \
		autoreconf -f -i && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) && \
		@INSTALL_ser2net@
	@CLEANUP_ser2net@
	touch $@

$(DEPDIR)/ucl: @DEPENDS_ucl@
	@PREPARE_ucl@
	cd @DIR_ucl@ && \
		./configure \
			--enable-shared \
			--disable-static \
			--prefix=$(hostprefix) && \
		@INSTALL_ucl@
	@CLEANUP_ucl@
	touch $@

$(DEPDIR)/upx_host: directories ucl @DEPENDS_upx_host@
	@PREPARE_upx_host@
	mkdir -p @DIR_upx_host@/lzma443
	cd @DIR_upx_host@/lzma443 && \
	bunzip2 -cd $(archivedir)/lzma443.tar.bz2 | TAPE=- tar -x
	cd @DIR_upx_host@ && \
		UPX_UCLDIR=$(hostprefix) \
		UPX_LZMADIR=$(buildprefix)/@DIR_upx_host@/lzma443 \
		LIBS="-Wl,-R$(hostprefix)/lib -Wl,-L$(hostprefix)/lib" \
		@INSTALL_upx_host@
	@CLEANUP_upx_host@
	touch $@

$(DEPDIR)/openvpn: bootstrap libcrypto @DEPENDS_openvpn@
	@PREPARE_openvpn@
	cd @DIR_openvpn@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-lzo && \
		$(MAKE) all && \
	@INSTALL_openvpn@
	@CLEANUP_openvpn@
	touch $@

if ENABLE_OPENVPN
# enable target only when OpenVPN kernel support is enabled
flash-openvpn: $(flashprefix)/root/sbin/openvpn

$(flashprefix)/root/sbin/openvpn: libcrypto openvpn | $(flashprefix)/root
	rm -f $(flashprefix)/root/sbin/openvpn
	@$(INSTALL) -d $(flashprefix)/root/sbin
	$(INSTALL) $(targetprefix)/sbin/openvpn $(flashprefix)/root/sbin
	@FLASHROOTDIR_MODIFIED@
endif

$(DEPDIR)/ipkg: bootstrap @DEPENDS_ipkg@
	@PREPARE_ipkg@
	cd @DIR_ipkg@ && \
		$(BUILDENV) \
		./configure \
			crosscompiling=yes \
			--build=$(build) \
			--host=$(target) \
			--with-ipkglibdir=/var/ && \
		$(MAKE) all && \
		$(INSTALL) -d $(targetprefix)/bin && \
		mv .libs/ipkg-cl .libs/ipkg && \
		ln -sf /var/etc/ipkg.conf $(targetprefix)/etc/ipkg.conf && \
		$(INSTALL) .libs/ipkg $(targetprefix)/bin && \
		$(INSTALL) .libs/libipkg.so.0 $(targetprefix)/lib 
	@CLEANUP_ipkg@
	touch $@

flash-ipkg: ipkg $(flashprefix)/root/bin/ipkg

$(flashprefix)/root/bin/ipkg: | $(flashprefix)/root
	rm -f $(flashprefix)/root/bin/ipkg
	@$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/ipkg $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/lib/libipkg.so.0 $(flashprefix)/root/lib 
	ln -sf  /var/etc/ipkg.conf $(flashprefix)/root/etc/ipkg.conf
	@FLASHROOTDIR_MODIFIED@

#htop
$(DEPDIR)/htop: libncurses @DEPENDS_htop@
	@PREPARE_htop@
	cd @DIR_htop@ && \
		$(BUILDENV) \
		[ ! -f $(targetprefix)/include/curses.h ] && \
			ln -s $(targetprefix)/include/ncurses/curses.h \
				$(targetprefix)/include/curses.h ; \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			ac_cv_file__proc_stat=yes \
			ac_cv_file__proc_meminfo=yes \
			ac_cv_func_malloc_0_nonnull=yes \
			ac_cv_func_realloc_0_nonnull=yes && \
		$(MAKE) all && \
		@INSTALL_htop@
	@CLEANUP_htop@
	touch $@

flash-htop: $(flashprefix)/root/bin/htop

$(flashprefix)/root/bin/htop: $(DEPDIR)/htop | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/bin/htop $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/netio: bootstrap @DEPENDS_netio@
	@PREPARE_netio@
	cd @DIR_netio@ && \
		sed "s/gcc/\$$(CC)/" Makefile > Makefile.org && \
		mv Makefile.org Makefile && \
		$(BUILDENV) \
		make linux && \
		@INSTALL_netio@
	@CLEANUP_netio@
	touch $@

flash-netio: $(flashprefix)/root/bin/netio

$(flashprefix)/root/bin/netio: $(DEPDIR)/netio | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/bin/netio $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/netio_host: @DEPENDS_netio_host@
	@PREPARE_netio_host@
	cd @DIR_netio_host@ && \
		$(BUILDENV) \
		make linux && \
		@INSTALL_netio_host@
	@CLEANUP_netio_host@
	touch $@

flash-inadyn-mt: $(flashprefix)/root/bin/inadyn-mt

$(flashprefix)/root/bin/inadyn-mt: $(DEPDIR)/inadyn-mt | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/bin/inadyn-mt $(flashprefix)/root/bin
	@FLASHROOTDIR_MODIFIED@

$(DEPDIR)/inadyn-mt: bootstrap @DEPENDS_inadyn_mt@
	@PREPARE_inadyn_mt@
	cd @DIR_inadyn_mt@ && \
		$(BUILDENV_BIN) \
		ac_cv_func_realloc_0_nonnull=yes \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-sound && \
		$(MAKE) all && \
	@INSTALL_inadyn_mt@
	@CLEANUP_inadyn_mt@
	touch $@

