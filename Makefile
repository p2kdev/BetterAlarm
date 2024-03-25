export THEOS_PACKAGE_SCHEME=rootless
export TARGET = iphone:clang:13.7:13.0
export ARCHS = arm64 arm64e

PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)

THEOS_DEVICE_IP = 192.168.86.37

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BetterAlarm

BetterAlarm_FILES = $(wildcard sources/*.x sources/*.m)
BetterAlarm_CFLAGS = -fobjc-arc
BetterAlarm_FRAMEWORKS = AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"
