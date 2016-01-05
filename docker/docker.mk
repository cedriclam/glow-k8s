DOCKER_REGISTRY_HOST := docker.io
DOCKER_REGISTRY_PORT := 5000
DOCKER_REGISTRY := $(DOCKER_REGISTRY_HOST):$(DOCKER_REGISTRY_PORT)

DOCKER_IMAGE := clamoriniere/$(notdir $(CURDIR))
VERSION := $(shell git describe --tags --always --dirty)

SHELL := /bin/bash
IMAGE_REPO := otf

.PHONY: all
all: build test

.PHONY: build
build: Dockerfile
	[[ -n "$$NO_CACHE" ]] && NO_CACHE=true || NO_CACHE=false; \
	docker build --no-cache=$$NO_CACHE -t $(DOCKER_IMAGE):$(VERSION) .

.PHONY: test
test:
	echo NO TEST

.PHONY: publish
publish:
	docker tag -f $(DOCKER_IMAGE):$(VERSION) $(DOCKER_REGISTRY_HOST)/$(DOCKER_IMAGE):$(VERSION)
	docker push $(DOCKER_REGISTRY_HOST)/$(DOCKER_IMAGE):$(VERSION)

.PHONY: publish-latest
publish-latest:
	docker tag -f $(DOCKER_IMAGE):$(VERSION) $(DOCKER_REGISTRY_HOST)/$(DOCKER_IMAGE):latest
	docker push $(DOCKER_REGISTRY_HOST)/$(DOCKER_IMAGE):latest

.PHONY: clean
clean:
	-docker rmi $(DOCKER_IMAGE):$(VERSION) $(DOCKER_REGISTRY_HOST)/$(DOCKER_IMAGE):$(VERSION) || true
