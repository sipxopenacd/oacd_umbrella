
all: deps compile

deps: generate_config
	./rebar get-deps

compile: generate_config
	./rebar compile

generate_config:
	cat oacd_core/rebar.config.template | sed -e "s:@OACD_DEPS_DIR@:../deps:g" > oacd_core/rebar.config
	for plugin in oacd_plugins/*; do \
		if [ -f $$plugin/rebar.config.template ]; then \
			cat $$plugin/rebar.config.template | sed -e "s:@OACD_DEPS_DIR@:../../deps:g" > $$plugin/rebar.config; \
		fi \
	done