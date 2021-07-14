# Reflow OS setup

This repository contains a set of scripts to run the entirety of the Reflow OS on a machine, downloads docker images and binaries built outside of this script.

## Components

- Bonfire (UI at default: http://localhost:4000)
- Zenroom
- Apiroom

- GraphiQL (default: http://localhost:4000/api/explore)

## Quick start

Ensure the Docker daemon on your host is running.

```
# enter this repo
cd reflow-os
# clear old build (not needed on first run)
docker container stop $(docker container list -q) && docker system prune --all --force
sudo rm -fr bonfire/ zenroom
```

```
# start-up the docker instance
make pull && make config && make run
```

in the resulting elixir console terminal, to reset & initialise the system, execute

```
Bonfire.Repo.ReleaseTasks.migrate
```

Register a user through the UI (default: http://localhost:4000)

(The elixir console will log the registration confirmation link, which can be copied and pasted immediately to activate the new user).

next, we create a default quantity type for valueflows by first logging into the GraphQL interface (default at http://localhost:4000/api/explore) with the user credentials we just created.

```
mutation {
  login(emailOrUsername: "yourusername", password:"yourpassword") {
    currentUsername
  }
}
```

where "yourusername" is the username just created in the UI, and "yourpassword" is the password given for this user in the registration process through the UI.

then we create a default quantity type (for instance, unit)

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


