SHELL := /bin/bash

SUBDIRS := $(sort $(dir $(wildcard */Dockerfile*)))

TARGETS := all \
	build \
	test \
	publish \
	publish-latest \
	clean

define rule
.PHONY: $(1) $(addprefix $(1)_,$(SUBDIRS))

$(1): $(addprefix $(1)_,$(SUBDIRS))

$(addprefix $(1)_,$(SUBDIRS)):
	$$(MAKE) -C $$(@:$(1)_%=%) $(1)
endef

$(foreach target,$(TARGETS),$(eval $(call rule,$(target))))
