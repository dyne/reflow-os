##@ General

help:
	@echo "REFLOW OS - https://reflowos.dyne.org"
	@echo
	@echo "First start:   \033[36mmake config ; make setup ; make run\033[0m"
	@echo "Quick update:  \033[36mmake update ; make setup ; make run\033[0m"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

secrets:
	@if ! [ -r zenroom ]; then wget https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 -O zenroom && chmod +x zenroom; fi
	@if ! [ -r conf/secrets.env ]; then \
	 echo "Generating new conf/secrets.env"; \
	 ./conf/bonfire-gensecrets.sh > conf/secrets.env; \
	fi

config: secrets ## configure to run locally
	@if ! [ -r bonfire ]; then git clone https://github.com/dyne/bonfire-app.git bonfire; fi
	@FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire pre-config
	@cat conf/bonfire-public.env > bonfire/config/prod/public.env \
	 && cat conf/bonfire-public.env > bonfire/config/dev/public.env
	@cp conf/secrets.env bonfire/config/prod/secrets.env \
	 && cp conf/secrets.env bonfire/config/dev/secrets.env
	@cp docker-compose.yml bonfire/docker-compose.release.yml

setup:  ## setup migrations before running
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.setup

run:    ## run in foreground (ctrl-c to quit)
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.run

bg:     ## run in background
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.run.bg

down:   ## tear down when running in background
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.down

stop:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.stop

reset: stop
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.down

tasks.create_user: ## registers a new user with $name $email $pass $user
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


##@ Reflow Amsterdam (ruby scripts to run various scenarios to fill the database)

rfams_config: ## configure reflow amsterdam
	@if ! test -d rfams ; then \
		git clone https://gitlab.waag.org/code/reflow_amsterdam.git rfams; \
		cd rfams/sim || exit 1 ; \
		git checkout -q f4f892995a4777a72fceb31ac1f34a316e3cf180 ; \
		bundle config set --local path vendor/bundle || exit 1 ; \
		bundle install ; \
	fi

rfams_swapshop: bg ## run the swapshop scenario
	@cd rfams/sim || exit 1 ; \
	    REFLOW_OS_PATH=$$PWD/../.. bundle exec ruby swapshop/simulation.rb && \
	    cd ../.. && make down

rfams_zorgschorten: bg ## run the zorgschorten scenario
	@cd rfams/sim || exit 1 ; \
	    REFLOW_OS_PATH=$$PWD/../.. bundle exec ruby zorgschorten/zorgschorten.rb && \
	    cd ../.. && make down

rfams_zorgschorten_simple: bg ## run the zorgschorten_simple scenario
	@cd rfams/sim || exit 1 ; \
	    REFLOW_OS_PATH=$$PWD/../.. bundle exec ruby zorgschorten/zorgschorten_simple.rb && \
	    cd ../.. && make down
