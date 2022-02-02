# Running with Docker Compose

Although not used to deploy containers in a production environment, 
[Docker Compose](https://docs.docker.com/compose/) is a great tool for a simplified container-based deployment for development and testing. Please see [kubernetes README here](/k8s/README.md) 

## Installing Docker Compose

Docker Compose is already included with Docker for Mac, but additional installation options 
are provided in [the official documentation](https://docs.docker.com/compose/install/).

## Setup License

```
export CONTRAST_LICENSE=$(cat contrast-06-30-2021.lic)
```
OR by using your HUB credentials:
```
- CONTRAST_HUB_USERNAME=
- CONTRAST_HUB_PASSWORD=
```

## Starting the Compose services

All of the Compose services can be started with a single command:

To run in detached mode:
```
docker-compose up -d
```

To run in active mode
```
docker-compose up
```

Teamserver can be accessed on http://locahost/Contrast

## Changing the Contrast UI version

To utilize specific versions of the Contrast UI, the following line in the  `docker-compose.yaml` file can be updated.

```
image: ghcr.io/contrast-security-inc/contrast:latest
```
to
```
image: ghcr.io/contrast-security-inc/contrast:3.7.11.53849
```

See the following link for a list of availible versions:

https://github.com/orgs/Contrast-Security-Inc/packages/container/package/contrast

## Configuring JVM OPTIONS

JVM options can be added/updated via the `/conf/jvm.options` file. 
This file will get mounted under `/opt/contrast/conf` in the container


## Configuration Contrast Property settings

To updating Contrast property settings for supported values can be done in `/props/contrast.properties`.

Example of some properties that can be set here:
```
server.external.host=localhost
server.external.port=8080
server.external.protocol=http
authenticator.saml.keystore.path=/opt/contrast/conf/samlKeystore2.jks
authenticator.saml.keystore.default.key=some-alias
```

## Adding an LDAP server to the containers

Uncommment the following section in the compose file:
```
  ldap:
    build:
      context: ./ldap
    ports:
      - 389:389
    environment:
      - LDAPS=false
    volumes:
      - $PWD/ldap/data:/ldif
```
Ref https://contrast.atlassian.net/wiki/spaces/ENG/pages/731381778/LDAP+Scenarios for configuring the LDAP fields.

For the hostname and port use the internal name of the container `ldap` and port `389`

## Configuring distributed mysql 

You can also just run the Teamserver container without Mysql and point to an existing Mysql server.

### First comment out the Mysql container and dependancies in the `docker-compose.yaml` file. 
```
  # contrast-database:
  #   image: mysql:8.0.21
  #   command: --log-bin-trust-function-creators=ON
  #   environment:
  #     - MYSQL_RANDOM_ROOT_PASSWORD=yes
  #     - MYSQL_DATABASE=contrast
  #     - MYSQL_USER=contrast
  #     - MYSQL_PASSWORD=default1!
  #   ports:
  #     - '3306'
```
and
```
    # depends_on:
    #   - contrast-database
```

### Then update the Mysql 

#### MySQL running on your local System:
```
# FOR Localhost MySQ
- CONTRAST_JDBC_URL=jdbc:mysql://host.docker.internal:3306/contrast
- CONTRAST_JDBC_USER=<enter user>
- CONTRAST_JDBC_PASS=<enter password>
```
#### MySQL running on RDS:
```
# FOR RDS MySQL
- CONTRAST_JDBC_URL=jdbc:mysql://user.c0lasdae9lf.us-east-2.rds.amazonaws.com:3306/contrast
- CONTRAST_JDBC_USER=<enter user>
- CONTRAST_JDBC_PASS=<enter password>
```


## Checking the state of the running containers

To check the status of the containers you can run `docker-compose ps`:

```
$ docker-compose ps

                 Name                               Command                  State                     Ports               
---------------------------------------------------------------------------------------------------------------------------         
mysql:8.0.21                                docker-entrypoint.sh --log ...   Up             0.0.0.0:32773->3306/tcp, 33060/tcp
contrast:lastest                            ./docker-entrypoint.sh /us ...   Up (healthy)   0.0.0.0:32775->8080/tcp, 8443/tcp 
```

In the example output above, you will see the port mappings from local ports to container ports. In this case,  TeamServer is listening on local port `32775`.

#### Tailing logs

The container logs can be tailed by tailing all logs for all containers `docker-compose logs -f` or for an individual service `docker-compose logs -f contrast`

Once the containers have finishing initializing, you can invoke APIs and access the TeamServer UI in the same way as the kubernetes example, but with the ports referenced in the output of the `docker-compose ps` command.


## Cleaning up

To clean up, you can stop and remove the running containers:

```
docker-compose rm -s
```# EOP_Container_BETA
