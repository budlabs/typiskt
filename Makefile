SCRIPT  = typiskt
MANPAGE = $(SCRIPT).1
PREFIX  = /usr
DESTDIR =
INSTDIR = $(DESTDIR)$(PREFIX)
CONFDIR = $(INSTDIR)/share/$(SCRIPT)
CORPDIR = $(CONFDIR)/wordlists
INSTBIN = $(INSTDIR)/bin
INSTMAN = $(INSTDIR)/share/man/man1

install: $(SCRIPT)mod
	test -d $(INSTBIN) || mkdir -p $(INSTBIN)
	test -d $(INSTMAN) || mkdir -p $(INSTMAN)
	test -d $(CORPDIR) || mkdir -p $(CORPDIR)

	@for corpus in wordlists/* ; do           \
		test -f $(CORPDIR)/$${corpus##*/}       \
		|| install -m 0644 $$corpus $(CORPDIR); \
	done

	install -m 0755 $(SCRIPT)mod  $(INSTBIN)/$(SCRIPT)
	install -m 0644 $(MANPAGE) $(INSTMAN)
	install -m 0644 wordmasks  $(CONFDIR)
.PHONY: install

$(SCRIPT)mod:
	./installprep.sh $(CONFDIR) $(SCRIPT)

uninstall:
	$(RM) $(INSTBIN)/$(SCRIPT)
	$(RM) $(INSTMAN)/$(MANPAGE)

	@for corpus in wordlists/* ; do              \
		$(RM) $(INSMAN) $(CORPDIR)/$${corpus##*/}; \
	done
.PHONY: uninstall
