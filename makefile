SHELL := /bin/bash
DIRECTORIES:= $(subst /, ,$(subst services/, ,${sort $(dir ${wildcard services/*/})}))
.SILENT:

export COMPOSE_PROJECT_NAME:= MYTHON
export REPO_NAME:= $(lastword $(subst /, , ${shell git config --get remote.origin.url}))
export BRANCH_NAME:=$(subst /,-,${shell git rev-parse --abbrev-ref HEAD})
export COMMIT:=${shell git rev-parse --short HEAD}
export CWD = $(shell pwd)

.PHONY: test

all:
	@awk 'BEGIN {FS = ":.*?## "} /^[\/\.a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init:
	docker compose run web django-admin startproject composeexample .



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

# Maintenance and debug
#
clean:  ## clear the app locally.  This is destructive. You will need to rebuild.
	docker context use development
	-rm *.log
	-docker compose -f docker-compose.yaml kill
	-docker rmi -f $$(docker images --filter='reference=*$(REPO_NAME)*:$(BRANCH_NAME)' -a -q)
	-docker rmi -f $$(docker images --filter='reference=*$(REPO_NAME)*:latest' -a -q)
	-docker rmi -f $$(docker images --quiet --filter "dangling=true")
	-docker rmi -f $$(docker images | grep "^<none>" | awk '{print $3}')

clobber:  ## Warning clears running containers and this projects images
	-docker rmi -f $$(docker images --filter='reference=*$(REPO_NAME)*:base' -a -q)
	-docker stop $$(docker ps -a -q) || true
	-docker rm -f $$(docker ps -a -q) || true
	-docker rmi -f $$(docker images --filter='reference=postgres*' -a -q)
