PROGNM  ?= typiskt
PREFIX  ?= /usr
BINDIR  ?= $(PREFIX)/bin
SHRDIR  ?= $(PREFIX)/share
MANDIR  ?= $(SHRDIR)/man/man1
CONFDIR ?= /etc

MANPAGE  = $(PROGNM).1
ASSETDIR = $(CONFDIR)/$(PROGNM)


.PHONY: install
install: $(PROGNM).out
	install -d  $(DESTDIR)$(BINDIR)

	install -m755 $(PROGNM).out  $(DESTDIR)$(BINDIR)/$(PROGNM)
	install -Dm755 config/exercises/add-gtypist-exercises.sh  -t $(DESTDIR)$(ASSETDIR)/exercises

	install -Dm644 config/wordlists/*           -t $(DESTDIR)$(ASSETDIR)/wordlists
	install -Dm644 config/exercises/README.md   -t $(DESTDIR)$(ASSETDIR)/exercises
	install -Dm644 config/wordmasks             -t $(DESTDIR)$(ASSETDIR)
	install -Dm644 config/config                -t $(DESTDIR)$(ASSETDIR)
	install -Dm644 $(MANPAGE)                   -t $(DESTDIR)$(MANDIR)
	install -Dm644 LICENSE                      -t $(DESTDIR)$(SHRDIR)/licenses/$(PROGNM)

	rm $(PROGNM).out

$(PROGNM).out: $(PROGNM)
	m4 -DETC_CONFIG_DIR=$(ASSETDIR) $< >$@

.PHONY: uninstall
uninstall:
	rm $(DESTDIR)$(BINDIR)/$(PROGNM)
	rm -rf $(DESTDIR)$(ASSETDIR)
	rm $(DESTDIR)$(MANDIR)/$(MANPAGE)
	rm -rf $(DESTDIR)$(SHRDIR)/licenses/$(PROGNM)
