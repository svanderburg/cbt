HELP2MAN = help2man
INSTALL = install
RM = rm

PREFIX = /usr/local

export CBT_BINDIR := $(CURDIR)/../bin
export CBT_DATADIR := $(CURDIR)/..

man:
	$(HELP2MAN) -N -n "set breakpoint after next script in execution" ../bin/cbt-break-next -o cbt-break-next.1
	$(HELP2MAN) -N -n "set breakpoint after script in a sequence" ../bin/cbt-break-seq -o cbt-break-seq.1
	$(HELP2MAN) -N -n "configure scripts in a sequence" ../bin/cbt-cfg-seq -o cbt-cfg-seq.1
	$(HELP2MAN) -N -n "clear breakpoint" ../bin/cbt-clear-brk -o cbt-clear-brk.1
	$(HELP2MAN) -N -n "run script phases" ../bin/cbt-run-phases -o cbt-run-phases.1
	$(HELP2MAN) -N -n "run an individual script" ../bin/cbt-run-script-impure -o cbt-run-script.1
	$(HELP2MAN) -N -n "run a sequence" ../bin/cbt-run-seq -o cbt-run-seq.1
	$(HELP2MAN) -N -n "show dependencies of a script" ../bin/cbt-script-deps -o cbt-script-deps.1
	$(HELP2MAN) -N -n "show dependencies of a sequence" ../bin/cbt-seq-deps -o cbt-seq-deps.1
	$(HELP2MAN) -N -n "show script properties" ../bin/cbt-show-script -o cbt-show-script.1
	$(HELP2MAN) -N -n "show sequence properties" ../bin/cbt-show-seq -o cbt-show-seq.1
	$(HELP2MAN) -N -n "generically uncompress file" ../bin/cbt-uncompress -o cbt-uncompress.1
	$(HELP2MAN) -N -n "generically unpack file" ../bin/cbt-unpack -o cbt-unpack.1

installmandir:
	$(INSTALL) -d -m755 $(PREFIX)/share/man/man1

installmans: *.1
	$(INSTALL) -m644 $? $(PREFIX)/share/man/man1

install: installmandir installmans

uninstallmans: *.1
	cd $(PREFIX)/share/man/man1; \
	$(RM) -f $?

uninstall: uninstallmans
