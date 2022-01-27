

##@ General

help: ## Display this help.
	@echo "REFLOW OS - https://reflowos.dyne.org"
	@echo
	@echo "First start:   make config ; make setup ; make run"
	@echo "Quick update:  make update ; make setup ; make run"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile


start: config setup run ## configure and run (ctrl-c to quit)

secrets:
	@if ! [ -r conf/secrets.env ]; then \
	 echo "Generating new conf/secrets.env"; \
	 ./conf/bonfire-gensecrets.sh > conf/secrets.env; \
	fi

config: secrets ## configure to run locally
	@if ! [ -r bonfire ]; then git clone https://github.com/dyne/bonfire-app.git bonfire; fi
	@if ! [ -r zenroom ]; then wget https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 -O zenroom && chmod +x zenroom; fi
	@FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire pre-config
	@cat conf/bonfire-public.env > bonfire/config/prod/public.env \
	 && cat conf/bonfire-public.env > bonfire/config/dev/public.env
	@cp conf/secrets.env bonfire/config/prod/secrets.env \
	 && cp conf/secrets.env bonfire/config/dev/secrets.env
	@cp docker-compose.yml bonfire/docker-compose.release.yml

setup:  ## setup migrations before running
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.setup

run:    ## run in foreground (with console)
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.run

bg:     ## run in background
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.run.bg

down:   ## tear down when running in background
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.down

stop:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.stop

reset: stop
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.down

create_user: ## registers a new user with $name $email $pass $user
	$(if ${name},,$(error  "name undefined"))
	$(if ${email},,$(error "email undefined"))
	$(if ${pass},,$(error  "pass undefined"))
	$(if ${user},,$(error  "user undefined"))
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.tasks.create_user email=${email} pass=${pass} user=${user} name=${name}

##@ Docker image development

update: ## update to latest version published online
	cd bonfire && git checkout . && git pull --rebase
	cp docker-compose.yml bonfire/docker-compose.release.yml
	docker pull dyne/reflow:latest

build: ## Build a new docker image locally
	FLAVOUR=reflow ORG_NAME=dyne APP_DOCKER_REPO="dyne/reflow" MIX_ENV=prod make -C bonfire rel.build

latest: ## Build a new docker image locally and tag latest
	FLAVOUR=reflow ORG_NAME=dyne APP_DOCKER_REPO="dyne/reflow" MIX_ENV=prod make -C bonfire rel.tag.latest
