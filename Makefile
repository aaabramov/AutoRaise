SKYLIGHT_AVAILABLE := $(shell test -d /System/Library/PrivateFrameworks/SkyLight.framework && echo 1 || echo 0)
override CXXFLAGS += -O2 -Wall -fobjc-arc -D"NS_FORMAT_ARGUMENT(A)=" -D"SKYLIGHT_AVAILABLE=$(SKYLIGHT_AVAILABLE)"

APP_NAME ?= Hoist
BUNDLE_ID ?= com.iamandrii.hoist
VERSION ?= $(or $(GITHUB_REF_NAME),$(shell git describe --tags --abbrev=0 2>/dev/null),0.0)

SRCS = HoistGlobals.mm HoistHelpers.mm HoistConfig.mm HoistUI.mm HoistWatcher.mm HoistMain.mm
OBJS = $(SRCS:.mm=.o)

FRAMEWORKS = -framework AppKit -framework ServiceManagement
ifeq ($(SKYLIGHT_AVAILABLE), 1)
    FRAMEWORKS += -F /System/Library/PrivateFrameworks -framework SkyLight
endif

.PHONY: all clean install build dev run debug update

all: Hoist Hoist.app

clean:
	rm -f Hoist HoistDev *.o
	rm -rf Hoist.app HoistDev.app

install: Hoist.app
	rm -rf /Applications/Hoist.app
	cp -r Hoist.app /Applications/

%.o: %.mm Hoist.h
	g++ $(CXXFLAGS) -c -o $@ $<

Hoist: $(OBJS)
	g++ $(CXXFLAGS) -o $@ $^ $(FRAMEWORKS)

Hoist.app: Hoist Info.plist Hoist.icns
	./create-app-bundle.sh $(APP_NAME) $(BUNDLE_ID) $(VERSION)

build: clean
	make CXXFLAGS="-DOLD_ACTIVATION_METHOD -DEXPERIMENTAL_FOCUS_FIRST"

dev: clean
	make APP_NAME=HoistDev BUNDLE_ID=com.iamandrii.hoist.dev CXXFLAGS="-DOLD_ACTIVATION_METHOD -DEXPERIMENTAL_FOCUS_FIRST"
	cp Hoist HoistDev

run: dev
	./HoistDev

debug: dev
	./HoistDev -verbose 1

update: build install
