INSTALL = install
RM = rm
RMDIR = rmdir

PREFIX = /usr/local

install:
	$(INSTALL) -d -m755 $(PREFIX)/share/cbt/common
	$(INSTALL) -m644 desktopItemFunctions $(PREFIX)/share/cbt/common

uninstall:
	$(RM) -f $(PREFIX)/share/cbt/common/desktopItemFunctions
	$(RMDIR) $(PREFIX)/share/cbt/common
