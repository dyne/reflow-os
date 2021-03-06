# ReflowOS setup

This repository contains a set of scripts to run the entirety of the ReflowOS on a machine, downloads docker images and binaries built outside of this script.

## Components

- Bonfire (ReflowOS UI at default: http://localhost:4000)
- Zenroom
- Apiroom
- GraphiQL (UI at default: http://localhost:4000/api/explore)
- Reflow Amsterdam (optional)

## Pre-installation checks

Ensure that Docker is installed and the docker daemon is running on your host.

Optionally, you'll need a ruby 3.0.1 stack for the Reflow Amsterdam scripts.

## Installation

Clone the ReflowOS builder git repository

```
# clone the repo
git clone https://github.com/dyne/reflow-os

# enter local workspace
cd reflow-os
```

```
# start-up the docker instance (the docker daemon must be running)
make config setup run
```

## Configuration

### Register a User through the UI

With a browser, open the URL for the UI (**default: http://localhost:4000**)

Click the Signup button and enter a name and password for new user registration.

(The elixir console will log a registration confirmation link)

Copy and Paste the confirmation URL from the elixir console to the browser URL bar to activate the new user.

### Create users through the command-line

While ReflowOS is not running, you can create users by running:

```
make tasks.create_user email="bob@example.test" pass="bobthehunter2" user="bob" name="Bob Smith"
```

Here, `email` is the email address, `pass` is the passphrase, `user`
is the username, `name` is the full name of the user you want to create.
`email` and `pass` fields are required, but `user` and `name` fields
are optional and will be automatically generated for you if you don't
provide.

`email` must be a valid email address and `pass` must be longer than
8 characters.

This will create a verified user, meaning you don't have to verify your
email address.

### Create Initial Quantity Type

#### Log in to the GraphQL UI

With a browser, open the URL for the GraphiQL UI (**default: http://localhost:4000/api/explore**)

Using the new user credentials entered in registration, copy into the edit window the following template:

```
mutation {
  login(emailOrUsername: "yourusername", password:"yourpassword") {
    currentUsername
  }
}
```

and edit, filling in where "yourusername" is the username just created in the UI, and "yourpassword" is the password given for this user in the registration process through the UI.

Then press the triangular ??? icon to process the query and log into GraphQL.

#### Add initial quantity type (for instance, unit)

Clear the text window of the authentication query and copy and paste the following:

```
mutation {
  createUnit(unit: {
    label:"unit",
    symbol:"u"
  }) {
    unit {
      id
      label
      symbol
    }
  }
}
```

Then press the triangular ??? icon to process the query and add the quantity type.

## Using the ReflowOS UI

### Log into ReflowOS UI

With a browser, return to the URL for the UI (**default: http://localhost:4000**)

Click on the Login icon and use the new user credentials to log in.

Start using the ReflowOS to define and manage processes and inventories.

## Clean Re-install

**Important note: This procedure will reset all database contents.**

If required, take steps to back up the ReflowOS database before following this procedure.

### Clean current docker and workspace of artefacts


```
# clean docker entirely (not needed on first run)
docker container stop $(docker container list -q) && docker system prune --all --force

# clean the repo workspace (not needed on first run)
sudo rm -fr bonfire/ zenroom
```

### Rebuild docker instance

Freshly pull, config and run the ReflowOS docker instance

```
# start-up the docker instance
make
```

Then repeat the Configuration steps

## Running Reflow Amsterdam scripts

After setting up the ReflowOS (`config` and `setup` make targets)
and while it is not running, run `make rfams_config` to set up Reflow
Amsterdam and run one of the scenarios:

- swapshop: `make rfams_swapshop`
- zorgschorten: `make rfams_zorgschorten`
- zorgschorten_simple: `make rfams_zorgschorten_simple`

Don't forget to have a ruby 3.0.1 stack installed for the scripts to work.
