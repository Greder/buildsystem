#
# image
#
image: release
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), fortis_hdbox octagon1008 ipbox55 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd spark spark7162 atevio7500 tf7700 ufs910 ufs912 ufs913 ufs922 hl101))
	$(MAKE) usb-image-$(BOXTYPE) flash-image-$(BOXTYPE)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo vuduo2 gb800se bre2zet2c osnino osninoplus osninopro))
	$(MAKE) flash-image-$(BOXTYPE)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k h7 hd51 hd61 osmini4k osmio4k osmio4kplus e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-rootfs flash-image-$(BOXTYPE)-disk $(MAKE) flash-image-$(BOXTYPE)-online
endif
ifeq ($(BOXTYPE), hd60)
	$(MAKE) flash-image-$(BOXTYPE)-multi-disk
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vusolo4k vuultimo4k vuuno4k vuuno4kse vuzero4k))
	$(MAKE) flash-image-$(BOXTYPE)-rootfs flash-image-$(BOXTYPE)-disk $(MAKE) flash-image-$(BOXTYPE)-online
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vuduo4k))
	$(MAKE) flash-image-$(BOXTYPE)-rootfs flash-image-$(BOXTYPE)-multi-disk $(MAKE) flash-image-$(BOXTYPE)-online
endif
	@echo "*****************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of $(GUI) images for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "*****************************************************************"

#
# image-clean
#
image-clean:
	cd $(IMAGE_DIR) && rm -rf *

