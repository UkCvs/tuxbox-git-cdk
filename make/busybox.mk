if ENABLE_IDE
POSSIBLY_IDE=-Dide
endif
if ENABLE_EXT3
POSSIBLY_EXT3=-Dext3
endif

$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@ Patches/busybox.config.m4 Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dyadd $(POSSIBLY_IDE) $(POSSIBLY_EXT3) -DPREFIX="\"$(targetprefix)\"" Patches/busybox.config.m4 > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
	@CLEANUP_busybox@
	touch $@


if TARGETRULESET_FLASH

flash-busybox: bootstrap $(flashprefix)/root @DEPENDS_busybox@ Patches/busybox.config.m4 Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dflash $(POSSIBLY_IDE) $(POSSIBLY_EXT3) -DPREFIX="\"$(flashprefix)/root\"" Patches/busybox.config.m4 > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) all install \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
	@CLEANUP_busybox@
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: flash-busybox
