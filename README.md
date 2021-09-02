# ReflowOS setup

This repository contains a set of scripts to run the entirety of the ReflowOS on a machine, downloads docker images and binaries built outside of this script.

## Components

- Bonfire (ReflowOS UI at default: http://localhost:4000)
- Zenroom
- Apiroom

- GraphiQL (UI at default: http://localhost:4000/api/explore)

## Pre-installation checks

Ensure that Docker is installed and the docker daemon is running on your host.

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
make pull && make config && make run

```

## Configuration

### Load initial ReflowOS database schema

In the resulting elixir console terminal prompt from `make run`, to reset & initialise an empty database, execute

```
Bonfire.Repo.ReleaseTasks.migrate
```

### Register a User through the UI 

With a browser, open the URL for the UI (**default: http://localhost:4000**)

Click the Signup button and enter a name and password for new user registration.

(The elixir console will log a registration confirmation link)

Copy and Paste the confirmation URL from the elixir console to the browser URL bar to activate the new user.

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

Then press the triangular ⏵ icon to process the query and log into GraphQL.

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

Then press the triangular ⏵ icon to process the query and add the quantity type.

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
make pull && make config && make run

```

Then repeat the Configuration steps
