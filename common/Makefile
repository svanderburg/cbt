INSTALL = install
RM = rm
RMDIR = rmdir

PREFIX = /usr/local

SCRIPTS=desktopItemFunctions \
	kde1DesktopItemFunctions \
	xdgDesktopItemFunctions

install:
	$(INSTALL) -d -m755 $(PREFIX)/share/cbt/common
	for script in $(SCRIPTS); do \
	    $(INSTALL) -m644 $$script $(PREFIX)/share/cbt/common; \
	done

uninstall:
	for script in $(SCRIPTS); do \
	    $(RM) -f $(PREFIX)/share/cbt/common/$$script; \
	done
	$(RMDIR) $(PREFIX)/share/cbt/common
