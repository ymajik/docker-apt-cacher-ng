NAMESPACE ?= ymajik
VERSION ?= $(shell echo $(git_describe) | sed 's/-.*//')
git_describe = $(shell git describe)
vcs_ref := $(shell git rev-parse HEAD)
build_date := $(shell date -u +%FT%T)
hadolint_available := $(shell hadolint --help > /dev/null 2>&1; echo $$?)
hadolint_command := hadolint --ignore DL3008 --ignore DL3018 --ignore DL3028 --ignore DL4000 --ignore DL4001
hadolint_container := hadolint/hadolint:latest

ifeq ($(IS_RELEASE),true)
	VERSION ?= $(shell echo $(git_describe) | sed 's/-.*//')
	LATEST_VERSION ?= latest
	dockerfile := release.Dockerfile
	dockerfile_context := puppetserver
else
	VERSION ?= edge
	IS_LATEST := false
	dockerfile := Dockerfile
	dockerfile_context := $(PWD)/..
endif

prep:
	@git fetch --unshallow ||:
	@git fetch origin 'refs/tags/*:refs/tags/*'

lint:
	ifeq ($(hadolint_available),0)
	@$(hadolint_command) docker-apt-cacher-ng/Dockerfile
else
	@docker pull $(hadolint_container)
	@docker run --rm -v $(PWD)/docker-apt-cacher-ng/Dockerfile \
		-i $(hadolint_container) $(hadolint_command) Dockerfile
	endif

build: prep
	docker build \
		--pull \
		--build-arg vcs_ref=$(vcs_ref) \
		--build-arg build_date=$(build_date) \
		--build-arg version=$(VERSION) \
		--file docker-apt-cacher-ng-base/Dockerfile \
		--tag $(NAMESPACE)/docker-apt-cacher-ng:$(VERSION) docker-apt-cacher-ng
	docker build \
		--build-arg namespace=$(NAMESPACE) \
		--build-arg vcs_ref=$(vcs_ref) \
		--build-arg build_date=$(build_date) \
		--build-arg version=$(VERSION) \
		--file docker-apt-cacher-ng/$(dockerfile) \
		--tag $(NAMESPACE)/docker-apt-cacher-ng:$(VERSION) $(dockerfile_context)
	

run:
	docker run -d -p 127.0.0.1:3142:3142 --name apt-cacher-ng apt-cacher-ng 	

script:
	docker ps | grep -q apt-cacher-ng

.PHONY: prep lint build run script
