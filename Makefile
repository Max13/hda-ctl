VERSION=5.4.1
RPMBUILDDIR=$(HOME)/rpmbuild

# SIGN=--sign

CFLAGS='-Wall'

all: rpm

dist: hda-ctl-hup
	(mkdir -p release && cd release && mkdir -p hda-ctl-$(VERSION))
	rsync -Ca hda-ctl hda-ctl-hup.c hda-ctl.spec hda-ctl.initscript hda-install \
	        debian hda-install-gem hda-ctl.service hda-ctl.logrotate \
		amahi-hda httpd samba desktop-icons hda-ctl.sysconfig \
		hda-settings hda-register-apps hda-install-file hda-alias \
		hda-update hda-change-gw hda-change-dns amahi-installer.service \
		web-installer amahi-installer hda-php-zone-change hda-fix-sudoers \
		hda-privs networking.ubuntu 70-amahi.preset hda-change-network \
		release/hda-ctl-$(VERSION)/
	(cd release && tar -czvf hda-ctl-$(VERSION).tar.gz hda-ctl-$(VERSION))
	(cd release && rm -rf hda-ctl-$(VERSION))
update-header:
	sed -i -e "s/version *= *\"[0-9.]*\"/version = \"$(VERSION)\"/" hda-ctl
	sed -i -e "s/version *= *\"[0-9.]*\"/version = \"$(VERSION)\"/" hda-install
	sed -i -e 's/^Version:\s*[0-9.]*\s*$$/Version: $(VERSION)/' hda-ctl.spec

rpm: update-header dist
	(cd release && rpmbuild $(SIGN) -ta hda-ctl-$(VERSION).tar.gz)
	mv $(RPMBUILDDIR)/RPMS/*/hda-ctl-$(VERSION)-*.rpm release/
	mv $(RPMBUILDDIR)/SRPMS/hda-ctl-$(VERSION)-*.src.rpm release/

deb: update-header dist
	(cd release && ln -sf hda-ctl-$(VERSION).tar.gz hda-ctl_$(VERSION).orig.tar.gz)
	(cd release && tar -zxf hda-ctl_$(VERSION).orig.tar.gz)
#Commenting out until can figure out why debuild -S is not working	
	#(cd release/hda-ctl-$(VERSION)/debian && debuild -uc -us && debuild -S -uc -us)
	(cd release/hda-ctl-$(VERSION)/debian && debuild -uc -us)

clean:
	(cd release/hda-ctl-$(VERSION)/ && dh_clean)

install: rpm
	(cd release && sudo rpm -Uvh hda-ctl-$(VERSION)-*.rpm)
