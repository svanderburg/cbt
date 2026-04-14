INSTALL = install
RMDIR = rmdir

PREFIX = /usr/local

SUBDIRS=bin \
	common \
	functions \
	lib \
	man \
	uncompress-plugins \
	unpack-plugins \

install:
	$(INSTALL) -d -m755 $(PREFIX)/share/cbt
	for subdir in $(SUBDIRS); do \
	    (cd $$subdir; $(MAKE) $@) || exit 1; \
	done

uninstall:
	for subdir in $(SUBDIRS); do \
	    (cd $$subdir; $(MAKE) $@) || exit 1; \
	done
	$(RMDIR) $(PREFIX)/share/cbt
