INSTALL = install
RM = rm

PREFIX = /usr/local

SCRIPTS=tar

install:
	$(INSTALL) -d -m755 $(PREFIX)/share/cbt/unpack-plugins
	for script in $(SCRIPTS); do \
	    $(INSTALL) -m644 $$script $(PREFIX)/share/cbt/unpack-plugins; \
	done

uninstall:
	for script in $(SCRIPTS); do \
	    $(RM) -f $(PREFIX)/share/cbt/unpack-plugins/$$script; \
	done
