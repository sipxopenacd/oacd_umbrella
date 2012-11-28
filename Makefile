BINDIR=test/bin
ETCDIR=test/etc
LIBDIR=test/lib
VARDIR=test/var

BASEDIR=.

OADIR=$(LIBDIR)/openacd
OALIBDIR=$(OADIR)/lib
OABINDIR=$(OADIR)/bin
OACONFIGDIR=$(ETCDIR)/openacd
OAVARDIR=$(VARDIR)/lib/openacd
OALOGDIR=$(VARDIR)/log/openacd
OADBDIR=$(OAVARDIR)/db
OAPLUGINDIR=$(OADIR)/plugin.d

CORE_GIT=git@github.com:sipxopenacd/oacd_core.git
CORE_DIR=$(BASEDIR)/core/oacd_core

DISTDIR=dist
DISTLIBDIR=$(DISTDIR)/lib/openacd
DISTLIBDIR=$(DISTDIR)/lib/openacd
DISTBINDIR=$(DISTDIR)/lib/openacd/bin
DISTETCDIR=$(DISTDIR)/etc/openacd
DISTLOGDIR=$(DISTDIR)/var/log/openacd
SCRIPTSTPLDIR=templates/scripts
CONFTPLDIR=templates/conf

all: checkout deps update compile

deps:
	./rebar get-deps

compile:
	./rebar compile

checkout: core/oacd_core

update:
	git pull
	$(foreach plugin,$(wildcard core/* plugins/*),cd $(plugin) && git pull; cd - ;)
	./rebar update-deps

core/oacd_core:
	git clone --recursive "$(CORE_GIT)" "$(CORE_DIR)"

install:
	mkdir -p $(DESTDIR)$(PREFIX)$(BINDIR)
	mkdir -p $(DESTDIR)$(PREFIX)$(OADIR)
	mkdir -p $(DESTDIR)$(PREFIX)$(OALIBDIR)
	mkdir -p $(DESTDIR)$(PREFIX)$(OABINDIR)
	mkdir -p $(DESTDIR)$(PREFIX)$(OACONFIGDIR)
	mkdir -p $(DESTDIR)$(PREFIX)$(OAVARDIR)
	mkdir -p $(DESTDIR)$(PREFIX)$(OAPLUGINDIR)
	for dep in deps/*; do \
	  ./install.sh $$dep $(DESTDIR)$(PREFIX)$(OALIBDIR) ; \
	done
	./install.sh . $(DESTDIR)$(PREFIX)$(OALIBDIR)
	for app in ./plugins/*; do \
	  ./install.sh $$app $(DESTDIR)$(PREFIX)$(OALIBDIR) ; \
	done
## Plug-ins
	mkdir -p $(DESTDIR)$(PREFIX)$(OAPLUGINDIR)
## Configurations
	sed \
	-e 's|%LOG_DIR%|$(OALOGDIR)|g' \
	-e 's|%PLUGIN_DIR%|$(PREFIX)$(OAPLUGINDIR)|g' \
	./config/app.config > $(DESTDIR)$(PREFIX)$(OACONFIGDIR)/app.config
	sed \
	-e 's|%DB_DIR%|$(PREFIX)$(OADBDIR)|g' \
	./config/vm.args > $(DESTDIR)$(PREFIX)$(OACONFIGDIR)/vm.args
## Var dirs
	mkdir -p $(DESTDIR)$(PREFIX)$(OADBDIR)
	mkdir -p $(DESTDIR)$(PREFIX)$(OALOGDIR)
## Bin
#dont use DESTDIR in sed here;this is a hack to not get "rpmbuild found in installed files"
	sed \
	-e 's|%OPENACD_PREFIX%|"$(PREFIX)"|g' \
	-e 's|%LIB_DIR%|$(libdir)|g' \
	./scripts/openacd > $(DESTDIR)$(PREFIX)$(OABINDIR)/openacd
	chmod +x $(DESTDIR)$(PREFIX)$(OABINDIR)/openacd
	cp ./scripts/nodetool $(DESTDIR)$(PREFIX)$(OABINDIR)
	cd $(DESTDIR)$(PREFIX)$(BINDIR); \
	ln -sf $(PREFIX)$(OABINDIR)/openacd openacd; \
	ln -sf $(PREFIX)$(OABINDIR)/nodetool nodetool

dist:
	rm -rf $(DISTDIR)
	mkdir -p $(DISTDIR)

	mkdir -p $(DISTLIBDIR)/core
	mkdir -p $(DISTLIBDIR)/core/oacd_core
	cp -r core/oacd_core/ebin $(DISTLIBDIR)/core/ebin
	cp -r core/oacd_core/include $(DISTLIBDIR)/core/include
	mkdir -p $(DISTLIBDIR)/plugins

	mkdir -p $(DISTBINDIR)
	cat $(SCRIPTSTPLDIR)/openacd > $(DISTBINDIR)/openacd
	cat $(SCRIPTSTPLDIR)/nodetool > $(DISTBINDIR)/nodetool
	chmod +x $(DISTBINDIR)/openacd
	chmod +x $(DISTBINDIR)/nodetool

	mkdir -p $(DISTETCDIR)
	cat $(CONFTPLDIR)/sys.config > $(DISTETCDIR)/sys.config
	cat $(CONFTPLDIR)/env.config > $(DISTETCDIR)/env.config
	chmod +x $(DISTETCDIR)/env.config

	mkdir -p $(DISTLOGDIR)

.PHONY: all deps compile checkout install update dist

