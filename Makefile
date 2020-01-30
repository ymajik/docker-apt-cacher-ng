NAMESPACE ?= ymajik
VERSION ?= dev
git_describe = $(shell git describe)
vcs_ref := $(shell git rev-parse HEAD)
build_date := $(shell date -u +%FT%T)
hadolint_command := hadolint --ignore DL3008 --ignore DL3018 --ignore DL3028 --ignore DL4000 --ignore DL4001
hadolint_container := hadolint/hadolint:latest

prep:
	@git fetch --unshallow ||:
	@git fetch origin 'refs/tags/*:refs/tags/*'

lint:
	@docker pull $(hadolint_container)
	@docker run --rm -i $(hadolint_container) $(hadolint_command) - < Dockerfile

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
		--file $(dockerfile) \
		--tag docker-apt-cacher-ng:$(VERSION) 
	

run:
	docker run -d -p 127.0.0.1:3142:3142 --name apt-cacher-ng apt-cacher-ng 	

script:
	docker ps | grep -q apt-cacher-ng

.PHONY: prep lint build run script
