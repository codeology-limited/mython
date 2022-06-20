SHELL := /bin/bash
DIRECTORIES:= $(subst /, ,$(subst services/, ,${sort $(dir ${wildcard services/*/})}))
MANAGE.PY:=   $(subst /, ,$(subst services/, ,${sort $(dir ${wildcard services/*/manage.py})}))
.SILENT:

export PYTHON:=python3
export COMPOSE_PROJECT_NAME:=mython
export REPO_NAME:= $(lastword $(subst /, , ${shell git config --get remote.origin.url}))
export BRANCH_NAME:=$(subst /,-,${shell git rev-parse --abbrev-ref HEAD})
export COMMIT:=${shell git rev-parse --short HEAD}
export CWD = $(shell pwd)

.PHONY: test

all:
	echo '>> ${MANAGE.PY}'
	@awk 'BEGIN {FS = ":.*?## "} /^[\/\.a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init:
	docker compose run web django-admin startproject composeexample .


${MANAGE.PY}:
	${PYTHON} services/$@/manage.py collectstatic

services/nginx/public:
	$(MAKE) ${MANAGE.PY}

build:  ## Build a new base container then build the project using it
	docker compose \
	-f docker-compose.yaml \
	--project-name ${COMPOSE_PROJECT_NAME}  \
	build --no-cache

up:  ## Start up the project in the development environment
	docker compose \
	-f docker-compose.yaml \
	--project-name ${COMPOSE_PROJECT_NAME} \
	up

down: ## Stand down the project.
	docker compose \
	-f docker-compose.yaml  \
	--project-name ${COMPOSE_PROJECT_NAME} \
	down
	-docker stop $$(docker ps -a -q) || true
	-docker rm -f $$(docker ps -a -q) || true
	-docker compose -f docker-compose.yaml kill


clean:  ## clean artifacts
	-rm *.log
	-rm -R services/nginx/public

clobber:  ## Warning - clears projects images
	-docker rmi -f $$(docker images --filter='reference=*$(REPO_NAME)*:$(BRANCH_NAME)' -a -q)
	-docker rmi -f $$(docker images --filter='reference=*$(REPO_NAME)*:latest' -a -q)
	-docker rmi -f $$(docker images --quiet --filter "dangling=true")
	-docker rmi -f $$(docker images | grep "^<none>" | awk '{print $3}')
	-docker rmi -f $$(docker images --filter='reference=*$(REPO_NAME)*:base' -a -q)
	-docker rmi -f $$(docker images --filter='reference=postgres*' -a -q)
