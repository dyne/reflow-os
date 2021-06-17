pull:
	if ! [ -r bonfire ]; then git clone https://github.com/bonfire-networks/bonfire-app.git bonfire; fi
	if ! [ -r zenroom ]; then wget https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 -O zenroom && chmod +x zenroom; fi
	docker pull bonfirenetworks/reflow:latest

config:
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire pre-config
	cat conf/bonfire-public.env > bonfire/config/prod/public.env
	cat conf/bonfire-public.env > bonfire/config/dev/public.env
	./conf/bonfire-gensecrets.sh > bonfire/config/prod/secrets.env
	./conf/bonfire-gensecrets.sh > bonfire/config/dev/secrets.env
run:
	cp docker-compose.yml bonfire/docker-compose.release.yml
	FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make -C bonfire rel.run

all: build config

build:
	cd bonfire && FLAVOUR=reflow ORG_NAME=dyne MIX_ENV=prod make rel.build

