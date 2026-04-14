INSTALL = install
RM = rm
RMDIR = RMDIR

PREFIX = /usr/local

SCRIPTS=deployDesktopItem \
	deployDesktopSourcePackage \
	deployPackage \
	deployPhases \
	deploySourcePackage \
	deployStage1SourcePackage \
	deployStage2SourcePackage \
	deployStage3SourcePackage \
	deployTrivialPackage

install:
	$(INSTALL) -d -m755 $(PREFIX)/share/cbt/functions
	for script in $(SCRIPTS); do \
	    $(INSTALL) -m644 $$script $(PREFIX)/share/cbt/functions; \
	done

uninstall:
	for script in $(SCRIPTS); do \
	    $(RM) -f $(PREFIX)/share/cbt/functions/$$script; \
	done
	$(RMDIR) $(PREFIX)/share/cbt/functions
