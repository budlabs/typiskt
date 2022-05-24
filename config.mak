NAME         := typiskt
DESCRIPTION  := terminal touch typing training
CREATED      := 2020-06-08
UPDATED      := 2022-05-24
VERSION      := 2022.05.24.1
AUTHOR       := budRich
ORGANISATION := budlabs
CONTACT      := https://github.com/budlabs/typiskt
USAGE        := $(NAME) [OPTIONS]
LICENSE      := BSD-2-Clause

# CUSTOM_TARGETS += README.md

README_DEPS =                       \
	$(DOCS_DIR)/readme_banner.md      \
	$(DOCS_DIR)/readme_install.md     \
	$(CACHE_DIR)/help_table.txt       \
	$(DOCS_DIR)/readme_description.md \
	$(DOCS_DIR)/readme_footer.md      \

README.md: $(README_DEPS)
	@$(info making $@)
	{
		echo "# $(NAME) - $(DESCRIPTION)"
		cat $(DOCS_DIR)/readme_banner.md
		cat $(DOCS_DIR)/readme_install.md
		echo "## usage"
		echo "    $(USAGE)"
		sed 's/^/    /g' $(CACHE_DIR)/help_table.txt
		cat $(DOCS_DIR)/readme_description.md
		cat $(DOCS_DIR)/readme_footer.md

	} > $@


MANPAGE_DEPS =                       \
	$(CACHE_DIR)/synopsis.txt          \
	$(CACHE_DIR)/help_table.txt        \
	$(CACHE_DIR)/long_help.md          \
	$(DOCS_DIR)/readme_description.md  \
	$(DOCS_DIR)/manpage_environment.md \
	$(CACHE_DIR)/copyright.txt

# CUSTOM_TARGETS += $(MANPAGE_OUT)
MANPAGE_OUT = $(MANPAGE)
.PHONY: manpage
manpage: $(MANPAGE_OUT)

$(MANPAGE_OUT): config.mak $(MANPAGE_DEPS) 
	@$(info making $@)
	uppercase_name=$(NAME)
	uppercase_name=$${uppercase_name^^}
	{
		# this first "<h1>" adds "corner" info to the manpage
		echo "# $$uppercase_name "           \
				 "$(manpage_section) $(UPDATED)" \
				 "$(ORGANISATION) \"User Manuals\""

		# main sections (NAME|OPTIONS..) should be "<h2>" (##), sub (###) ...
	  printf '%s\n' '## NAME' \
								  '$(NAME) - $(DESCRIPTION)'

		echo "## SYNOPSIS"
		sed 's/^/    /g' $(CACHE_DIR)/synopsis.txt
		echo "## USAGE"
		cat $(DOCS_DIR)/readme_description.md
		echo "## OPTIONS"
		sed 's/^/    /g' $(CACHE_DIR)/help_table.txt
		cat $(CACHE_DIR)/long_help.md
		cat $(DOCS_DIR)/manpage_environment.md

		printf '%s\n' '## CONTACT' \
			"Send bugs and feature requests to:  " "$(CONTACT)/issues"

		printf '%s\n' '## COPYRIGHT'
		cat $(CACHE_DIR)/copyright.txt
	} | go-md2man > $@


# --- INSTALLATION RULES --- #

BINDIR  ?= $(DESTDIR)$(PREFIX)/bin
SHRDIR  ?= $(DESTDIR)$(PREFIX)/share

ASSETDIR = $(SHRDIR)/$(NAME)

installed_manpage    = $(DESTDIR)$(PREFIX)/share/man/man$(manpage_section)/$(MANPAGE)
installed_script    := $(DESTDIR)$(PREFIX)/bin/$(NAME)
installed_license   := $(DESTDIR)$(PREFIX)/share/licenses/$(NAME)/LICENSE

_$(NAME).out: $(MONOLITH)
	m4 -DETC_CONFIG_DIR=$(PREFIX)/share/$(NAME) $< >$@

install: _$(NAME).out all
	install -Dm644 $(MANPAGE_OUT) $(installed_manpage)
	install -Dm755 _$(NAME).out $(installed_script)
	install -Dm644 LICENSE $(installed_license)
	install -Dm755 config/exercises/add-gtypist-exercises.sh  -t $(ASSETDIR)/exercises
	install -Dm644 config/wordlists/*                         -t $(ASSETDIR)/wordlists
	install -Dm644 config/exercises/README.md                 -t $(ASSETDIR)/exercises
	install -Dm644 config/wordmasks                           -t $(ASSETDIR)
	install -Dm644 config/config                              -t $(ASSETDIR)

uninstall:
	rm $(installed_script)
	rm -rf $(ASSETDIR)
	rm $(installed_manpage)
	rm $(installed_license)
	rmdir $(dir $(installed_license))
