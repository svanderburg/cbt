INSTALL = install
RM = rm

PREFIX = /usr/local

SCRIPTS=bunzip2 \
	gunzip

install:
	$(INSTALL) -d -m755 $(PREFIX)/share/cbt/uncompress-plugins
	for script in $(SCRIPTS); do \
	    $(INSTALL) -m644 $$script $(PREFIX)/share/cbt/uncompress-plugins; \
	done

uninstall:
	for script in $(SCRIPTS); do \
	    $(RM) -f $(PREFIX)/share/cbt/uncompress-plugins/$$script; \
	done
