<p align="center">
    <img src="./logo.png" alt="" width="300"/>  
</p>

# Ferdi-server-docker
[Ferdi](https://github.com/getferdi/ferdi) is a hard-fork of [Franz](https://github.com/meetfranz/franz), adding awesome features and removing unwanted ones. Ferdi-server is an unofficial replacement of the Franz server for use with the Ferdi Client. 

This is a dockerized version of [Ferdi-server](https://github.com/getferdi/server) running on Alpine Linux and Node.js (v10.16.3).

## Why use a custom Ferdi-server?
A custom ferdi-server allows you to experience the full potential of the Ferdi client. It allows you to use all Premium features (e.g. Workspaces and custom URL recipes) and [adding your own recipes](#creating-and-using-custom-recipes).

## Features
- [x] User registration and login
- [x] Service creation, download, listing and removing
- [x] Workspace support
- [x] Functioning service store
- [x] User dashboard
- [ ] Password recovery
- [ ] Export/import data to other ferdi-servers
- [ ] Recipe update

## Installation & Setup

Here are some example snippets to help you get started creating a container.

The docker can be run as is, with the default sqlite database, or you can modifying your ENV variables to use an external database (e.g. MYSql, MariaDB, Postgres, etc). After setting up the docker container you will need to create a NGINX reverse proxy to access Ferdi-server outside of your home network. 

### docker

Pull the docker image:

    docker pull xthursdayx/ferdi-server-docker

To create the docker container with the proper parameters:

	docker create \
	  --name=ferdi-server \
	  -e NODE_ENV=development \
	  -e DB_CONNECTION=<database> \
	  -e DB_HOST=<yourdbhost> \
	  -e DB_PORT=<yourdbPORT> \
	  -e DB_USER=<yourdbuser> \
	  -e DB_PASSWORD=<yourdbpass> \
	  -e DB_DATABASE=<yourdbdatabase> \
	  -e IS_CREATION_ENABLED=true \
	  -e CONNECT_WITH_FRANZ=true \
	  -p <port>:80 \
	  -v <path to data>:/config \
	  --restart unless-stopped \
	  xthursdayx/ferdi-server-docker

### docker-compose

Compatible with docker-compose v2 schemas:

```
---
version: "2"
services:
  ferdi-server:
    image: xthursday/ferdi-server-docker
    container_name: ferdi-server
    environment:
	  - NODE_ENV=development
      - DB_CONNECTION=<database>
      - DB_HOST=<yourdbhost>
      - DB_PORT=<yourdbPORT>
      - DB_USER=<yourdbuser>
	  - DB_PASSWORD=<yourdbpass>
      - DB_DATABASE=<yourdbdatabase>
      - IS_CREATION_ENABLED=true/false
	  - CONNECT_WITH_FRANZ=true/flase  
    volumes:
      - <path to data>:/config
    ports:
      - <port>:80
    restart: unless-stopped
```

## Configuration

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 3333:80` would expose port `80` from inside the container to be accessible from the host's IP on port `3333` outside the container. 
After the first run, Ferdi-server's configuration is saved inside the `config.txt` file inside your persistent data directory (`/config` in the container).

| Parameter | Function |
| :----: | --- |
| `-p <port>:80` | will map the container's port 80 to a port on the host, default is 3333 |
| `-e NODE_ENV=development` | for specifying Node environment, production or development, default is development |
| `-e DB_CONNECTION=sqlite` | for specifying the database being used, default is sqlite |
| `-e DB_HOST=<yourdbhost>` | for specifying the database host, default is 127.0.0.1 |
| `-e DB_PORT=<yourdbport>` | for specifying the database port, default is 3306 |
| `-e DB_USER=<yourdbuser>` | for specifying the database user, default is root |
| `-e DB_PASSWORD=<yourdbpass>` | for specifying the database password, default is empty |
| `-e DB_DATABASE=adonis` | for specifying the database to be used, adonis |
| `-e IS_CREATION_ENABLED=true` | for specifying whether to enable the [creation of custom recipes](#creating-and-using-custom-recipes), default is true |
| `-e CONNECT_WITH_FRANZ=true` | for specifying whether to enable connections to the Franz server, default is true |
| `-v <path to data>:/config` | this will store persistent data on the docker host |

By enabling the `CONNECT_WITH_FRANZ` option, Ferdi-server can:
    - Show the full Franz recipe library instead of only custom recipes
    - Import Franz accounts

## Supported databases and drivers

To use a different database than the default SQLite enter the driver code below in your ENV configuration. 

| Database | Driver |
| :----: | --- |
| MariaDB | mysql |
| MySQL | mysql |
| PostgreSQL | pg |
| SQLite3 | sqlite |
 
## NGINX config block
To access Ferdi-server from outside of your home network on a subdomain use this server block:

```
# Ferdi-server
server {
        listen 443 ssl http2;
        server_name ferdi.my.website;

       	# all ssl related config moved to ssl.conf
        include /config/nginx/ssl.conf;

        location / {
             proxy_pass              http://<Ferdi-IP>:3333;
             proxy_set_header        X-Real-IP            $remote_addr;
             proxy_set_header        X-Forwarded-For	  $proxy_add_x_forwarded_for;
             proxy_set_header        Host                 $host;
             proxy_set_header        X-Forwarded-Proto    $scheme;
        }
}
```

## Importing your Franz account
Ferdi-server allows you to import your full Franz account, including all its settings.

To import your Franz account, open `http://[YOUR FERDI-SERVER]/import` in your browser and login using your Franz account details. Ferdi-server will create a new user with the same credentials and copy your Franz settings, services and workspaces.

## Creating and using custom recipes
Ferdi-server allows to extends the Franz recipe catalogue with custom Ferdi recipes.

For documentation on how to create a recipe, please visit [the official guide by Franz](https://github.com/meetfranz/plugins/blob/master/docs/integration.md).

To add your recipe to Ferdi-server, open `http://[YOUR FERDI-SERVER]/new` in your browser. You can now define the following settings:
- `Author`: Author who created the recipe
- `Name`: Name for your new service. Can contain spaces and unicode characters
- `Service ID`: Unique ID for this recipe. Does not contain spaces or special characters (e.g. `google-drive`)
- `Link to PNG/SVG image`: Direct link to a 1024x1024 PNG image and SVG that is used as a logo inside the store. Please use jsDelivr when using a file uploaded to GitHub as raw.githubusercontent files won't load
- `Recipe files`: Recipe files that you created using the [Franz recipe creation guide](https://github.com/meetfranz/plugins/blob/master/docs/integration.md). Please do *not* package your files beforehand - upload the raw files (you can drag and drop multiple files). ferdi-server will automatically package and store the recipe in the right format. Please also do not drag and drop or select the whole folder, select the individual files.

### Listing custom recipes
Inside Ferdi, searching for `ferdi:custom` will list all your custom recipes.

## Support Info

* Shell access while the container is running: `docker exec -it ferdi-server /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f ferdi-server`

## Updating Info

Below are the instructions for updating the container to get the most recent version of Ferdi-server:

### Via Docker Run/Create
* Update the image: `docker pull xthursdayx/ferdi-server-docker`
* Stop the running container: `docker stop ferdi-server`
* Delete the container: `docker rm ferdi-server`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and your ENV settings will be preserved)
* Start the new container: `docker start ferdi-server`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull ferdi-server`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d ferdi-server`
* You can also remove the old dangling images: `docker image prune`

## Building locally

If you want to make local modifications to this image for development purposes or just to customize the logic:
```
git clone https://github.com/xthursdayx/ferdi-server-docker.git
cd ferdi-server-docker
docker build \
  --no-cache \
  --pull \
  -t xthursdayx/ferdi-server-docker:latest .
```

## Versions

* **25.09.19:** - Initial Release.

## License
Ferdi-server-docker and ferdi-server are licensed under the MIT License.
