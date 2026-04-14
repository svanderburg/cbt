SED = sed
CHMOD = chmod
INSTALL = install
RM = rm

PREFIX = /usr/local
TARGET_PREFIX = $(PREFIX)

SCRIPTS=cbt-break-next \
	cbt-break-seq \
	cbt-cfg-seq \
	cbt-clear-brk \
	cbt-install-command-wrapper \
	cbt-run-phases \
	cbt-run-script \
	cbt-run-script-impure \
	cbt-run-seq \
	cbt-script-deps \
	cbt-seq-deps \
	cbt-show-script \
	cbt-show-seq \
	cbt-uncompress \
	cbt-unpack

install:
	$(INSTALL) -d -m755 $(PREFIX)/bin
	for script in $(SCRIPTS); do \
	    $(SED) -e 's|$$CBT_BINDIR|$(TARGET_PREFIX)/bin|g' \
	      -e 's|$$CBT_DATADIR|$(TARGET_PREFIX)/share/cbt|g' \
	      -e 's|/usr/local|$(TARGET_PREFIX)|g' \
	      $$script > $(PREFIX)/bin/$$script; \
	    $(CHMOD) 755 $(PREFIX)/bin/$$script; \
	done

uninstall:
	for script in $(SCRIPTS); do \
	    $(RM) -f $(PREFIX)/bin/$$script; \
	done
