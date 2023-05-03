TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard

ifneq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET := iphone:clang:14.2:11.0
PREFIX = /Applications/Xcode-11.7.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ColorHomeBar

$(TWEAK_NAME)_FILES = Tweak.x $(wildcard ColorCube/Framework/ColorCube/ColorCube/Source/*.m)
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaPlayer
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -IColorCube/Framework/ColorCube/ColorCube/Source

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	@cp ColorCube/LICENSE $(THEOS_STAGING_DIR)/DEBIAN/ColorCube_LICENSE