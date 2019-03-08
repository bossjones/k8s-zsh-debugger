username := bossjones
container_name := k8s-zsh-debugger

GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION     = $(shell grep "index.docker.io/ubuntu" Dockerfile | head -1 | cut -d":" -f2)
_ARCH       = $(shell uname -p)

RPI_BUILD ?= 'false'
ifeq (${_ARCH}, x86_64)
	override RPI_BUILD = 'false'
# @echo $(value RPI_BUILD)
else
	override RPI_BUILD = 'true'
# @echo $(value RPI_BUILD)
endif


TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif


build:
	docker build --build-arg VCS_REF=$(GIT_SHA) --build-arg BUILD_DATE=$(VERSION) --build-arg RPI_BUILD=$(RPI_BUILD) --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') --tag $(username)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

build-force:
	docker build --rm --force-rm --pull --no-cache -t $(username)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

tag:
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

build-push: build tag
	docker push $(username)/$(container_name):latest
	docker push $(username)/$(container_name):$(GIT_SHA)
	docker push $(username)/$(container_name):$(TAG)

push:
	docker push $(username)/$(container_name):latest
	docker push $(username)/$(container_name):$(GIT_SHA)
	docker push $(username)/$(container_name):$(TAG)

push-force: build-force push

run:
	docker run --rm -it --name tmp-shell $(username)/$(container_name) /bin/zsh -l

# run:
# 	docker run -it --net host $(username)/$(container_name) -- /bin/zsh
run-example:
	docker run --rm --name tmp-shell-zsh -i -t --network container:k8s_POD_docker-registry-ui-db754f8dc-dltz8_default_8b1e8626-25e1-11e9-ae98-000c29089f82_0 bossjones/k8s-zsh-debugger /bin/zsh -l

# tcpdump -i eth0 port 9999 -c 1 -Xvv
#

get-version:
	docker run --rm --name get-version-zsh -i -t $(username)/$(container_name):$(GIT_SHA) /bin/zsh -c "zsh --version"

ci: build get-version



build-rpi:
	docker build --build-arg RPI_BUILD=$(RPI_BUILD) --build-arg VCS_REF=$(GIT_SHA) --build-arg BUILD_DATE=$(VERSION) --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') --tag $(username)/$(container_name):rpi-$(GIT_SHA) . ; \
	docker tag $(username)/$(container_name):rpi-$(GIT_SHA) $(username)/$(container_name):rpi-latest
	docker tag $(username)/$(container_name):rpi-$(GIT_SHA) $(username)/$(container_name):rpi-$(TAG)

build-force-rpi:
	docker build --build-arg RPI_BUILD=$(RPI_BUILD) --rm --force-rm --pull --no-cache -t $(username)/$(container_name):rpi-$(GIT_SHA) . ; \
	docker tag $(username)/$(container_name):rpi-$(GIT_SHA) $(username)/$(container_name):rpi-latest
	docker tag $(username)/$(container_name):rpi-$(GIT_SHA) $(username)/$(container_name):rpi-$(TAG)

tag-rpi:
	docker tag $(username)/$(container_name):rpi-$(GIT_SHA) $(username)/$(container_name):rpi-latest
	docker tag $(username)/$(container_name):rpi-$(GIT_SHA) $(username)/$(container_name):rpi-$(TAG)

build-push-rpi: build-rpi tag-rpi
	docker push $(username)/$(container_name):rpi-latest
	docker push $(username)/$(container_name):rpi-$(GIT_SHA)
	docker push $(username)/$(container_name):rpi-$(TAG)

push-rpi:
	docker push $(username)/$(container_name):rpi-latest
	docker push $(username)/$(container_name):rpi-$(GIT_SHA)
	docker push $(username)/$(container_name):rpi-$(TAG)

push-force-rpi: build-force-rpi push-rpi
