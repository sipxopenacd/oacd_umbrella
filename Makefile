prefix=/usr/local
exec_prefix=$(prefix)

bindir=$(exec_prefix)/bin
sysconfdir=$(prefix)/etc
libdir=$(exec_prefix)/lib
localstatedir=$(prefix)/var

RUNNER_USER=

BASEDIR=.

CORE_GIT=git@github.com:sipxopenacd/oacd_core.git
CORE_DIR=$(BASEDIR)/core/oacd_core

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
	# Binary
	mkdir -p $(DESTDIR)$(bindir)
	sed \
	-e "s|%RUNNER_USER%|$(RUNNER_USER)|g" \
	-e "s|%BIN_DIR%|$(bindir)|g" \
	-e "s|%SYSCONFIG_DIR%|$(sysconfdir)|g" \
	-e "s|%LOCALSTATE_DIR%|$(localstatedir)|g" \
	-e "s|%LIB_DIR%|$(libdir)|g" \
	./templates/scripts/openacd > $(DESTDIR)$(bindir)/openacd
	chmod 744 $(DESTDIR)$(bindir)/openacd

	# Config
	mkdir -p $(DESTDIR)$(sysconfdir)/openacd
	sed \
	-e "s|%LOG_DIR%|$(localstatedir)/log/openacd|g" \
	-e "s|%PLUGIN_DIR%|$(libdir)/openacd/plugins|g" \
	./templates/conf/sys.config > $(DESTDIR)$(sysconfdir)/openacd/sys.config

	# Logs
	mkdir -p $(DESTDIR)$(localstatedir)/log/openacd

	# Plugins
	mkdir -p $(DESTDIR)$(libdir)/openacd/plugins

	# Core
	mkdir -p $(DESTDIR)$(libdir)/openacd/core/oacd_core
	mkdir -p $(DESTDIR)$(libdir)/openacd/core/oacd_core/ebin
	mkdir -p $(DESTDIR)$(libdir)/openacd/core/oacd_core/include
	install -m 644 ./core/oacd_core/ebin/oacd_core.app $(DESTDIR)$(libdir)/openacd/core/oacd_core/ebin
	install -m 644 ./core/oacd_core/ebin/*.beam $(DESTDIR)$(libdir)/openacd/core/oacd_core/ebin
	install -m 644 ./core/oacd_core/include/*.hrl $(DESTDIR)$(libdir)/openacd/core/oacd_core/include

dist:
	mkdir -p dist
	# TODO other args?
	make DESTDIR=dist install

.PHONY: all deps compile checkout install update dist

