SKYLIGHT_AVAILABLE := $(shell test -d /System/Library/PrivateFrameworks/SkyLight.framework && echo 1 || echo 0)
override CXXFLAGS += -O2 -Wall -fobjc-arc -D"NS_FORMAT_ARGUMENT(A)=" -D"SKYLIGHT_AVAILABLE=$(SKYLIGHT_AVAILABLE)"

APP_NAME ?= AutoRaise
BUNDLE_ID ?= com.iamandrii.autoraise

.PHONY: all clean install build dev run debug update

all: AutoRaise AutoRaise.app

clean:
	rm -f AutoRaise AutoRaiseDev
	rm -rf AutoRaise.app AutoRaiseDev.app

install: AutoRaise.app
	rm -rf /Applications/AutoRaise.app
	cp -r AutoRaise.app /Applications/

AutoRaise: AutoRaise.mm
        ifeq ($(SKYLIGHT_AVAILABLE), 1)
	    g++ $(CXXFLAGS) -o $@ $^ -framework AppKit -framework ServiceManagement -F /System/Library/PrivateFrameworks -framework SkyLight
        else
	    g++ $(CXXFLAGS) -o $@ $^ -framework AppKit -framework ServiceManagement
        endif

AutoRaise.app: AutoRaise Info.plist AutoRaise.icns
	./create-app-bundle.sh $(APP_NAME) $(BUNDLE_ID)

build: clean
	make CXXFLAGS="-DOLD_ACTIVATION_METHOD -DEXPERIMENTAL_FOCUS_FIRST"

dev: clean
	make APP_NAME=AutoRaiseDev BUNDLE_ID=com.iamandrii.autoraise.dev CXXFLAGS="-DOLD_ACTIVATION_METHOD -DEXPERIMENTAL_FOCUS_FIRST"
	cp AutoRaise AutoRaiseDev

run: dev
	./AutoRaiseDev

debug: dev
	./AutoRaiseDev -verbose 1

update: build install
