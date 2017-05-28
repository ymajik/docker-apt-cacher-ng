all: build

build:
	@docker build --tag=ymajik/apt-cacher-ng .
