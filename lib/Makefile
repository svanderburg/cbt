SED = sed
INSTALL = install
RM = rm
RMDIR = rmdir

PREFIX = /usr/local
TARGET_PREFIX = $(PREFIX)

SCRIPTS=break \
	checks \
	dialog \
	groupSelector \
	script \
	sequence \
	status

install:
	$(INSTALL) -d -m755 $(PREFIX)/share/cbt/lib
	for script in $(SCRIPTS); do \
	    $(SED) -e 's|$$CBT_BINDIR|$(TARGET_PREFIX)/bin|g' \
	      -e 's|$$CBT_DATADIR|$(TARGET_PREFIX)/share/cbt|g' \
	      $$script > $(PREFIX)/share/cbt/lib/$$script; \
	done

uninstall:
	for script in $(SCRIPTS); do \
	    $(RM) -f $(PREFIX)/share/cbt/lib/$$script; \
	done
	$(RMDIR) $(PREFIX)/share/cbt/lib
