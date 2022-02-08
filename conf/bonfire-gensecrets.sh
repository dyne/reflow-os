#!/bin/sh

cat << EOF
# for sessions/cookies
SECRET_KEY_BASE=$( (echo "print(OCTET.random(64):base58())" | ./zenroom 2>/dev/null) | tr -d '\0' )
SIGNING_SALT=$( (echo "print(OCTET.random(64):base58())" | ./zenroom 2>/dev/null) | tr -d '\0' )
ENCRYPTION_SALT=$( (echo "print(OCTET.random(64):base58())" | ./zenroom 2>/dev/null) | tr -d '\0' )

# database access
POSTGRES_USER=postgres
POSTGRES_DB=bonfire_db
POSTGRES_PASSWORD=$( (echo "print(OCTET.random(64):base58())" | ./zenroom 2>/dev/null) | tr -d '\0' )
# in ms
POSTGRES_TIMEOUT=10000

# smtp auth configuration
MAIL_FROM=no-reply@dyne.org
MAIL_SERVER=smtp.sendgrid.net
MAIL_USER=apikey
MAIL_PASSWORD=FILL-BY-HAND

# signup to mailgun.com and edit with your domain and API key
MAIL_DOMAIN=mailg.mydomain.net
MAIL_KEY=123

# password for the search index
MEILI_MASTER_KEY=$( (echo "print(OCTET.random(64):base58())" | ./zenroom 2>/dev/null) | tr -d '\0' )

# password for the default admin user if you run the seeds
SEEDS_USER=root
SEEDS_PW=$( (echo "print(OCTET.random(64):base58())" | ./zenroom 2>/dev/null) | tr -d '\0' )

# backend stuff
ERLANG_COOKIE=bonfire_cookie

# Bonfire extensions configs
WEB_PUSH_SUBJECT=mailto:administrator@mydomain.net
WEB_PUSH_PUBLIC_KEY=xyz
WEB_PUSH_PRIVATE_KEY=abc
GEOLOCATE_OPENCAGEDATA=
GITHUB_TOKEN=xyz
EOF
