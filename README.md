> :warning: PHP 7.3 + Webpack version moved to [webpack branch](/pie-inc/docker-wordpress-multisite/tree/webpack) -- The 7.4 version theme makes use of Vite, so there are breaking updates to current developments!

> :warning: master branch changed to main

# Docker WordPress Multisite
- [Docker WordPress Multisite](#docker-wordpress-multisite)
  - [Pre-requisites](#pre-requisites)
  - [Getting started](#getting-started)
    - [Enabling multisite](#enabling-multisite)
    - [local SSL Certificates](#local-ssl-certificates)
  - [FAQ](#faq)
    - [Does it work immediately?](#does-it-work-immediately)
    - [What if I don't want to use SSL?](#what-if-i-dont-want-to-use-ssl)
    - [I'd like to start fresh, what do I do?](#id-like-to-start-fresh-what-do-i-do)
    - [This is not working properly in Windows... Help!](#this-is-not-working-properly-in-windows-help)

## Pre-requisites
![Nodejs](https://png.icons8.com/color/50/000000/nodejs.png)
* Install [Node](https://nodejs.org/) for your platform.

![Docker](https://png.icons8.com/color/50/000000/docker.png)
* Install [Docker](https://www.docker.com/get-docker) for your platform.
* Install [docker-compose](https://docs.docker.com/compose/install/) for your platform (if necessary).

## Getting started
Clone this repository:
```
git clone git@github.com:pie-inc/docker-wordpress-multisite.git <TARGET FOLDER>
```

Then install dependencies: ```npm i``` or ```yarn```

Once all packages have been installed, run ```yarn start``` to build the docker images, start the docker containers and watch all source files for changes.

Alternatively you can just run ```npm run serve```, ```yarn serve``` or ```docker-compose up -d```[❔](https://docs.docker.com/compose/reference/up/) to download/build the docker images and start the server.

A few folders and files will be created inside ```./data``` for debugging, mainly ```mysql```. These folders are local and will not be included in the git flow.

Go through the famous 5-minute wordpress instalation by going to ```http://localhost:8080```

### Enabling multisite
In line `220` or `data/docker-entrypoint.sh`, update the email section to the admin email.

Jump into the wordpress container, enable multisite with WP-CLI and update the .htaccess, making a backup of the original.

```SHELL
docker-compose exec wp bash
wp core multisite-convert
mv .htaccess backup.htaccess
mv multisite.htaccess .htaccess
```

### local SSL Certificates
You will need install makecert.

Using homebrew:
```SHELL
brew install mkcert
brew install nss # if you use Firefox
mkcert -install
```

Then, you will have to generate the Certificates and dh parameters
```SHELL
mkcert localhost 127.0.0.1 ::1
openssl dhparam -out dh.pem 2066
```

And finally copy the certificates from the mentioned location in the terminal into ```./data/certs/```
nginx expects the files to have the following naming structure: `dh.pem ssl.crt ssl.key`. The nomenclature can be updated at `data/nginx/wordpress.conf`

You can also generate your own, or use existing ones you might have. 
([Using openSSL](https://www.openssl.org/docs/manmaster/man1/openssl-req.html))

## FAQ
### Does it work immediately?
Nope.

### What if I don't want to use SSL?
You have to change quite a few settings, like the nginx configuration file.

### I'd like to start fresh, what do I do?
Type ```npm run reset``` or ```yarn reset``` and voilà!

### This is not working properly in Windows... Help!
Although it might work in Windows, I have only used this process in *NIX machines. Some commands might have to be altered in `package.json` to adapt for proper Windows usage.
