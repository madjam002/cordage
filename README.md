Cordage [![Build Status](https://img.shields.io/travis/madjam002/cordage.svg?style=flat)](https://travis-ci.org/madjam002/cordage) [![NPM](https://img.shields.io/npm/v/cordage.svg?style=flat)](https://npmjs.org/package/cordage) ![Downloads](https://img.shields.io/npm/dm/cordage.svg?style=flat)
=======

Cordage is a simple command-line tool which makes it easy to **deploy and manage
your application(s)** across several of your own servers using [Docker](http://docker.io/),
[CoreOS](http://coreos.com) and [fleet](http://github.com/coreos/fleet).

Define the services for your application in `Cordagefile.coffee` and then deploy them
using the command-line tool.

Cordage runs `fleetctl` commands behind the scenes and removes the need of writing systemd
configuration files, as they are generated automatically when you deploy. Cordage makes it easy
to add additional units for a service, making it easy to scale your application when necessary.

Cordage runs locally on your machine, meaning there is no complicated software
to install on your servers. If you're already using CoreOS, then you can get
started straight away.

## Features

- Deploy multiple units/instances of a service easily
- Configure your services so there is only one unit for that service per host
- Automatically detects updates to docker images on deployment
- View your deployed services and units
- Destroy a specific service and/or a specific version of a service

## Upcoming Features

- Quick scaling of services with `cordage addunit` and `cordage removeunit`
- View logs for your services with `cordage logs`
- Automatic deployment of a private docker registry to your cluster for easy image deployment
- Build your application images and push them to a private or public registry with `cordage build`

## Install

```sh
$ npm install -g cordage
```

Cordage depends on [Node.js](http://nodejs.org/), [npm](http://npmjs.org/) and [fleetctl](https://coreos.com/docs/launching-containers/launching/fleet-using-the-client/).
Please make sure these dependencies are installed on your system.

## Usage

### Cordagefile.coffee

Cordage uses a simple file called `Cordagefile.coffee` which should live in the root
of your project repository. This file will define what services will run across your
cluster.

Here is an example `Cordagefile.coffee`:

```coffee
module.exports = ->

  @service 'app',
    description: 'Application Server'
    image: 'nginx'
    rules:
      onePerHost: true
```

*Please note that Cordage is still early days. The configuration format is likely
to change significantly in the future and several more options will be added.*


### Command-line tool

Cordage is just running `fleetctl` commands behind the scenes, so as long as you
can run `fleetctl` commands successfully against your cluster,
Cordage should work just fine.

##### See all available Cordage commands

```sh
$ cordage
```

### Deploying services

Once you have configured your services in `Cordagefile.coffee`, you can deploy
them to your cluster. Cordage will automatically detect new versions of your service
docker images, making it easy to deploy a new version of your application.

##### Build and deploy your services across the cluster

```sh
$ cordage deploy
```

### Listing services and running units

To check that your deployment went smoothly, you can run the list command to view
all of your services and any running units (containers) for each one.

##### List services and units

```sh
$ cordage list
```

### Destroying services

If you want to shutdown and destroy all units for a particular service, then you
can use the destroy command.

##### Destroy all units for a particular service

```sh
$ cordage destroy app
```

##### Destroy all units for a specific version of a service

```sh
$ cordage destroy app:12.04
```


## License

Licensed under the MIT License.

View the full license [here](https://raw.githubusercontent.com/madjam002/cordage/master/LICENSE).
