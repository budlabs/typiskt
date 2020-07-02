PROGNM ?= typiskt
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
SHRDIR ?= $(PREFIX)/share
MANDIR ?= $(SHRDIR)/man/man1

MANPAGE  = $(PROGNM).1
ASSETDIR = $(SHRDIR)/$(PROGNM)


.PHONY: install
install: $(PROGNM)mod
	install -d  $(DESTDIR)$(BINDIR)
	install -m755 $(PROGNM)mod  $(DESTDIR)$(BINDIR)/$(PROGNM)
	rm $(PROGNM)mod
	install -Dm644 wordlists/*   -t $(DESTDIR)$(ASSETDIR)/wordlists
	install -Dm644 wordmasks     -t $(DESTDIR)$(ASSETDIR)
	install -Dm644 $(MANPAGE)    -t $(DESTDIR)$(MANDIR)
	install -Dm644 LICENSE       -t $(DESTDIR)$(SHRDIR)/licenses/$(PROGNM)


$(PROGNM)mod:
	./installprep.sh $(ASSETDIR) $(PROGNM)

.PHONY: uninstall
uninstall:
	rm $(DESTDIR)$(BINDIR)/$(PROGNM)
	rm -rf $(DESTDIR)$(ASSETDIR)
	rm $(DESTDIR)$(MANDIR)/$(MANPAGE)
	rm -rf $(DESTDIR)$(SHRDIR)/licenses/$(PROGNM)
