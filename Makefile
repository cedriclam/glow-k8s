
# GO WORKSPACE
WORKSPACE := src
GOPATH := $(PWD)/$(WORKSPACE)
# Build tools
SHELL := /bin/bash
GBGOPATH := $(PWD)/hack/gb
GB := $(GBGOPATH)/bin/gb
ROOT := $(PWD)

# These are the values we want to pass for Version and BuildTime
VERSION := $(shell git describe --tags --always --dirty)
BUILD_TIME=$(shell date +%FT%T%z)

# Setup the -ldflags option for go build here, interpolate the variable values
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}"

.PHONY: all
all: $(GB) $(GOLINT) $(GO2XUNIT) $(GOCOV) $(GOCOVXML) install build test cover-extra

$(GB):
	@cd $(GBGOPATH) && GOPATH=$(GBGOPATH) go install github.com/constabulary/gb/...

$(GEN):
	@cd $(GENGOPATH) && GOPATH=$(GENGOPATH) go install github.com/clipperhouse/gen

$(GOLINT):
	@cd $(GOLINTGOPATH) && GOPATH=$(GOLINTGOPATH) go install github.com/golang/lint/golint

$(GO2XUNIT):
	@cd $(GO2XUNITGOPATH) && GOPATH=$(GO2XUNITGOPATH) go install bitbucket.org/tebeka/go2xunit

$(GOCOV):
	@cd $(GOCOVGOPATH) && GOPATH=$(GOCOVGOPATH) go install github.com/axw/gocov/gocov

$(GOCOVXML):
	@cd $(GOCOVXMLGOPATH) && GOPATH=$(GOCOVXMLGOPATH) go install github.com/AlekSi/gocov-xml

$(PROTOC):
	@cd $(PROTOCGOPATH) && GOPATH=$(PROTOCGOPATH) go install github.com/golang/protobuf/{proto,protoc-gen-go}


.PHONY: install
install: $(GB)
	PATH=$(PATH):$(GBGOPATH)/bin/ && $(GB) vendor restore -precaire

.PHONY: vendor-update
vendor-update: $(GB)
	PATH=$(PATH):$(GBGOPATH)/bin/ && $(GB) vendor update -precaire

.PHONY: build
build: $(GB)
	GOPATH=$(ROOT) $(GB) build $(LDFLAGS)

.PHONY: linux
linux: $(GB)
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOPATH=$(ROOT) $(GB) build $(LDFLAGS)
	
.PHONY: test
test: $(GB)
	GOPATH=$(ROOT) $(GB) test -v ./...

## Linux binaries
.PHONY: c
build-linux:
	@cd $(ROOT) && \
		GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOPATH=$(ROOT):$(ROOT)/vendor go build 	\
			-o $(ROOT)/docker/glow-job/glowk8s \
			$(LDFLAGS) \
			src/glowk8s/counter.go

.PHONY: docker
docker: build-linux
	$(MAKE) -C docker build

.PHONY: publish
publish: docker
	$(MAKE) -C docker publish

.PHONY: publish-latest
publish-latest: docker
	$(MAKE) -C docker publish-latest

mkdir_reports:
	$(shell mkdir -p $(ROOT)/_reports)

.PHONY: usage
usage:
	@echo "Usage: make [<target>]"
	@echo ""
	@echo "Targets:"
	@echo "	- all: build and test everything."
	@echo "	- build: build all binaries."
	@echo "	- test: test all binaries."
	@echo "	- test-xml: test all binaries and generate xml report."
	@echo "	- cover: run coverage on all source files."
	@echo "	- cover-xml: run coverage all source files and generate xml report."
	@echo "	- install: restore gb dependencies"
	@echo "	- format: call go fmt and go vet"
	@echo "	- build-linux: build linux binary files"
	@echo "	- docker: generate docker image"
	@echo "	- publish: publish the generated docker image"
	@echo "	- publish-production: publish the generated docker image in the production artifactory"
	@echo "	- clean: clean everything"
	@echo ""

.PHONY: clean
clean:
	@rm -rf _reports
	@rm -rf bin
	@rm -rf pkg
	@rm -rf hack/gb/bin
	@rm -rf hack/gb/pkg
	@rm -rf hack/golint/bin
	@rm -rf hack/golint/pkg
	@rm -rf hack/go2xunit/bin
	@rm -rf hack/go2xunit/pkg
	@rm -rf hack/gocov/bin
	@rm -rf hack/gocov/pkg
	@rm -rf hack/gocov-xml/bin
	@rm -rf hack/gocov-xml/pkg
	@rm -rf hack/protoc/bin
	@rm -rf hack/protoc/pkg
