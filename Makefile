RELEASE=0
DPKG_NAME=naviserver-revproxy
INSTALL_PATH=/usr/lib/naviserver/tcl/revproxy
TEMP_PATH=/tmp/revproxy
MAINTAINER=support@qcode.co.uk
REMOTE_USER=deb
REMOTE_HOST=deb.qcode.co.uk
REMOTE_DIR=deb.qcode.co.uk

.PHONY: all

all: check-version package clean
package: check-version
	# Copy files to pristine temporary directory
	rm -rf $(TEMP_PATH)
	mkdir $(TEMP_PATH)
	curl --fail -K ~/.curlrc_github -L -o v$(VERSION).tar.gz https://api.github.com/repos/qcode-software/naviserver-revproxy/tarball/v$(VERSION)
	tar --strip-components=1 --exclude Makefile --exclude description-pak --exclude README.md \
	-xzvf v$(VERSION).tar.gz -C $(TEMP_PATH)
	# checkinstall
	fakeroot checkinstall -d2 -D --deldoc --backup=no --install=no --pkgname=$(DPKG_NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) --pkglicense="BSD" -A all -y --maintainer $(MAINTAINER) --reset-uids=yes --requires="naviserver\(\>=4.99.20\),nsf,nsf-shells" --replaces none --conflicts none make install

install:
	mkdir -p $(INSTALL_PATH)
	cp $(TEMP_PATH)/revproxy-procs.tcl $(INSTALL_PATH)

upload: check-version
	scp $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTE_USER)@$(REMOTE_HOST):debs"	
	ssh $(REMOTE_USER)@$(REMOTE_HOST) reprepro includedeb stretch debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTE_USER)@$(REMOTE_HOST) reprepro copy buster stretch $(DPKG_NAME)
	ssh $(REMOTE_USER)@$(REMOTE_HOST) rm -f debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

clean:
	rm -rf $(TEMP_PATH)
	rm -f $(DPKG_NAME)*_all.deb
	rm -f postinstall-pak
	rm -f v$(VERSION).tar.gz

check-version:
ifndef VERSION
    $(error VERSION is undefined. Usage make VERSION=x.x.x)
endif
