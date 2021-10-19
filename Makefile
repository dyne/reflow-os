all: pull config setup run

pull:
	if ! [ -r bonfire ]; then git clone https://github.com/dyne/bonfire-app.git bonfire; fi
	if ! [ -r zenroom ]; then wget https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 -O zenroom && chmod +x zenroom; fi
	docker pull dyne/reflow:latest

update:
	cd bonfire && git pull
	docker pull dyne/reflow:latest

config:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire pre-config
	cat conf/bonfire-public.env > bonfire/config/prod/public.env
	cat conf/bonfire-public.env > bonfire/config/dev/public.env
	./conf/bonfire-gensecrets.sh > bonfire/config/prod/secrets.env
	./conf/bonfire-gensecrets.sh > bonfire/config/dev/secrets.env
	cp docker-compose.yml bonfire/docker-compose.release.yml

setup:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.setup

run:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.run

bg:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.run.bg

down:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.down

stop:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.stop

reset: stop
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.down

build:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.build

tasks.create_user:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.tasks.create_user email=${email} pass=${pass} user=${user} name=${name}
