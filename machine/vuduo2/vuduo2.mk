BOXARCH = mips
OPTIMIZATIONS ?= size
WLAN ?= 
MEDIAFW ?= gstreamer
INTERFACE ?=lua-python
CICAM = ci-cam
SCART = scart
LCD = 4-digits
FKEYS =

#
# kernel
#
KERNEL_VER             = 3.13.5
KERNEL_SRC             = stblinux-${KERNEL_VER}.tar.bz2
KERNEL_URL             = http://archive.vuplus.com/download/kernel
KERNEL_CONFIG          = $(BOXTYPE)_defconfig
KERNEL_DIR             = $(BUILD_TMP)/linux
KERNELNAME             = vmlinux
CUSTOM_KERNEL_VER      = $(KERNEL_VER)

KERNEL_PATCHES_MIPSEL = \
		mips/vuduo2/kernel-add-support-for-gcc5.patch \
		mips/vuduo2/kernel-add-support-for-gcc6.patch \
		mips/vuduo2/kernel-add-support-for-gcc7.patch \
		mips/vuduo2/kernel-add-support-for-gcc8.patch \
		mips/vuduo2/kernel-add-support-for-gcc9.patch \
		mips/vuduo2/kernel-add-support-for-gcc10.patch \
		mips/vuduo2/rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
		mips/vuduo2/add-dmx-source-timecode.patch \
		mips/vuduo2/af9015-output-full-range-SNR.patch \
		mips/vuduo2/af9033-output-full-range-SNR.patch \
		mips/vuduo2/as102-adjust-signal-strength-report.patch \
		mips/vuduo2/as102-scale-MER-to-full-range.patch \
		mips/vuduo2/cxd2820r-output-full-range-SNR.patch \
		mips/vuduo2/dvb-usb-dib0700-disable-sleep.patch \
		mips/vuduo2/dvb_usb_disable_rc_polling.patch \
		mips/vuduo2/it913x-switch-off-PID-filter-by-default.patch \
		mips/vuduo2/tda18271-advertise-supported-delsys.patch \
		mips/vuduo2/mxl5007t-add-no_probe-and-no_reset-parameters.patch \
		mips/vuduo2/linux-tcp_output.patch \
		mips/vuduo2/linux-3.13-gcc-4.9.3-build-error-fixed.patch \
		mips/vuduo2/rtl8712-fix-warnings.patch \
		mips/vuduo2/0001-Support-TBS-USB-drivers-3.13.patch \
		mips/vuduo2/0001-STV-Add-PLS-support.patch \
		mips/vuduo2/0001-STV-Add-SNR-Signal-report-parameters.patch \
		mips/vuduo2/0001-stv090x-optimized-TS-sync-control.patch \
		mips/vuduo2/0002-cp1emu-do-not-use-bools-for-arithmetic.patch \
		mips/vuduo2/0003-log2-give-up-on-gcc-constant-optimizations.patch \
		mips/vuduo2/blindscan2.patch \
		mips/vuduo2/linux_dvb_adapter.patch \
		mips/vuduo2/genksyms_fix_typeof_handling.patch \
		mips/vuduo2/test.patch \
		mips/vuduo2/0001-tuners-tda18273-silicon-tuner-driver.patch \
		mips/vuduo2/T220-kern-13.patch \
		mips/vuduo2/01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
		mips/vuduo2/02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
		mips/vuduo2/CONFIG_DVB_SP2.patch \
		mips/vuduo2/dvbsky.patch \
		mips/vuduo2/fix_hfsplus.patch \
		mips/vuduo2/mac80211_hwsim-fix-compiler-warning-on-MIPS.patch \
		mips/vuduo2/prism2fw.patch \
		mips/vuduo2/mm-Move-__vma_address-to-internal.h-to-be-inlined-in-huge_memory.c.patch \
		mips/vuduo2/compile-with-gcc9.patch

KERNEL_PATCHES = $(KERNEL_PATCHES_MIPSEL)

$(ARCHIVE)/$(KERNEL_SRC):
	$(WGET) $(KERNEL_URL)/$(KERNEL_SRC)

$(D)/kernel.do_prepare: $(ARCHIVE)/$(KERNEL_SRC) $(PATCHES)/$(BOXARCH)/$(KERNEL_CONFIG)
	$(START_BUILD)
	rm -rf $(KERNEL_DIR)
	$(UNTAR)/$(KERNEL_SRC)
	set -e; cd $(KERNEL_DIR); \
		for i in $(KERNEL_PATCHES); do \
			echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; \
			$(PATCH)/$$i; \
		done
	install -m 644 $(PATCHES)/$(BOXARCH)/$(KERNEL_CONFIG) $(KERNEL_DIR)/.config
ifeq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug))
	@echo "Using kernel debug"
	@grep -v "CONFIG_PRINTK" "$(KERNEL_DIR)/.config" > $(KERNEL_DIR)/.config.tmp
	cp $(KERNEL_DIR)/.config.tmp $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK=y" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK_TIME=y" >> $(KERNEL_DIR)/.config
endif
	@touch $@

$(D)/kernel.do_compile: $(D)/kernel.do_prepare
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips CROSS_COMPILE=$(TARGET)- $(KERNELNAME) modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=mips CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap $(D)/kernel.do_compile
	install -m 644 $(KERNEL_DIR)/$(KERNELNAME) $(TARGET_DIR)/boot/
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-$(BOXARCH)-$(KERNEL_VER)
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)

#
# driver
#
DRIVER_VER = 3.13.5
DRIVER_DATE = 20190429
DRIVER_REV = r0
DRIVER_SRC = vuplus-dvb-proxy-vuduo2-$(DRIVER_VER)-$(DRIVER_DATE).$(DRIVER_REV).tar.gz

$(ARCHIVE)/$(DRIVER_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/$(DRIVER_SRC)

driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	tar -xf $(ARCHIVE)/$(DRIVER_SRC) -C $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(MAKE) platform_util
	$(MAKE) vmlinuz_initrd
	$(TOUCH)

#
# platform util
#
UTIL_VER = 15.1
UTIL_DATE = $(DRIVER_DATE)
UTIL_REV = r0
UTIL_SRC = platform-util-vuduo2-$(UTIL_VER)-$(UTIL_DATE).$(UTIL_REV).tar.gz

$(ARCHIVE)/$(UTIL_SRC):
	$(WGET) http://archive.vuplus.com/download/build_support/vuplus/$(UTIL_SRC)

$(D)/platform_util: $(D)/bootstrap $(ARCHIVE)/$(UTIL_SRC)
	$(START_BUILD)
	$(UNTAR)/$(UTIL_SRC)
	install -m 0755 $(BUILD_TMP)/platform-util-vuduo2/* $(TARGET_DIR)/usr/bin
	$(REMOVE)/platform-util-$(KERNEL_TYPE)
	$(TOUCH)

#
# vmlinuz initrd
#
INITRD_DATE = 20130220
INITRD_SRC = vmlinuz-initrd_vuduo2_$(INITRD_DATE).tar.gz

$(ARCHIVE)/$(INITRD_SRC):
	$(WGET) http://archive.vuplus.com/download/kernel/$(INITRD_SRC)

$(D)/vmlinuz_initrd: $(D)/bootstrap $(ARCHIVE)/$(INITRD_SRC)
	$(START_BUILD)
	tar -xf $(ARCHIVE)/$(INITRD_SRC) -C $(TARGET_DIR)/boot
	$(TOUCH)

#
# release
#
release-vuduo2:
	install -m 0755 $(SKEL_ROOT)/etc/init.d/halt_vuduo2 $(RELEASE_DIR)/etc/init.d/halt
	cp -f $(SKEL_ROOT)/etc/fstab_vuduo2 $(RELEASE_DIR)/etc/fstab
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7425b0 $(RELEASE_DIR)/boot/

#
# flashimage
#
VUDUO_PREFIX = vuplus/duo2

flash-image-vuduo2:
	rm -rf $(IMAGE_BUILD_DIR) || true
	mkdir -p $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)
	mkdir -p $(FLASH_DIR)/$(BOXTYPE)
	touch $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/reboot.update
	cp $(SKEL_ROOT)/boot/splash.bin $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/splash_cfe_auto.bin
	# kernel
	gzip -9c < "$(TARGET_DIR)/boot/vmlinux" > "$(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/kernel_cfe_auto.bin"
	cp $(TARGET_DIR)/boot/vmlinuz-initrd-7425b0 $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/initrd_cfe_auto.bin
	mkfs.ubifs -r $(RELEASE_DIR) -o $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi -m 2048 -e 126976 -c 8192
	echo '[ubifs]' > $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'mode=ubi' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'image=$(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_id=0' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_type=dynamic' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_name=rootfs' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo 'vol_flags=autoresize' >> $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	ubinize -o $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.jffs2 -m 2048 -p 128KiB $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	rm -f $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/root_cfe_auto.ubi
	rm -f $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/ubinize.cfg
	echo $(BOXTYPE)_DDT_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(VUDUO_PREFIX)/imageversion
	cd $(IMAGE_BUILD_DIR)/ && \
	zip -r $(FLASH_DIR)/$(BOXTYPE)/$(BOXTYPE)_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(VUDUO_PREFIX)*
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)



