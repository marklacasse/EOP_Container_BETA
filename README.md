# Containerized Teamserver (BETA)

## Kubernetes Deployments 
>please see the [README here](/k8s/README.md) 

## Running in Docker Compose

Although not used to deploy containers in a production environment, 
[Docker Compose](https://docs.docker.com/compose/) is a great tool for a simplified container-based deployment for development and testing. 



### Installing Docker Compose
---
Docker Compose is already included with Docker for Mac, but additional installation options 
are provided in [the official documentation](https://docs.docker.com/compose/install/).

### Setup License
---
> **NOTE**: The Contrast License needs to be generated recently (after June 11th, 2020) so it includes the updated format the container expects.

```bash
export CONTRAST_LICENSE=$(cat contrast-06-30-2021.lic)
```
OR by using your HUB credentials in the `docker-compose.yaml`:
```yaml
- CONTRAST_HUB_USERNAME=
- CONTRAST_HUB_PASSWORD=
```

### Starting the Compose services

All of the Compose services can be started with a single command:

To run in detached mode:
```
docker-compose up -d
```

To run in active mode
```
docker-compose up
```

Teamserver can be accessed on http://localhost:8080/Contrast

### Changing the Contrast UI version

To utilize specific versions of the Contrast UI, the following line in the  `docker-compose.yaml` file can be updated.

```yaml
image: ghcr.io/contrast-security-inc/contrast:latest
```
to
```yaml
image: ghcr.io/contrast-security-inc/contrast:3.7.11.53849
```

See the following link for a list of availible versions:

https://github.com/orgs/Contrast-Security-Inc/packages/container/package/contrast

### Configuring JVM OPTIONS
---

JVM options can be added/updated via the `/conf/jvm.options` file. 
This file will get mounted under `/opt/contrast/conf` in the container


### Configuration Contrast Property settings

To updating Contrast property settings for supported values can be done in `/conf/contrast.properties`.

Example of some properties that can be set here:
```properties
server.external.host=localhost
server.external.port=8080
server.external.protocol=http
authenticator.saml.keystore.path=/opt/contrast/conf/samlKeystore2.jks
authenticator.saml.keystore.default.key=some-alias
```

### Configuring distributed mysql 
---
You can also just run the Teamserver container without Mysql and point to an existing Mysql server.

> **WARNING:** It is not recomended to point the Teamserver containers at your production database. Should you wish to point the container at a pre-production database, ensure you are using the exact same version of the Teamserver for the image.  Otherwise you may inadvertanly upgrade your database schema causing problems for your normal EOP installations.

1. First comment out the Mysql container and dependancies in the `docker-compose.yaml` file.
```yaml
  # contrast-database:
  #   image: mysql:8.0.30
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
```yaml
    # depends_on:
    #   - contrast-database
```

2. Then update the Mysql connection details:

**MySQL running on your local System:**
```yaml
# FOR Localhost MySQ
- CONTRAST_JDBC_URL=jdbc:mysql://host.docker.internal:3306/contrast
- CONTRAST_JDBC_USER=<enter user>
- CONTRAST_JDBC_PASS=<enter password>
```
**MySQL running on RDS:**
```yaml
# FOR RDS MySQL
- CONTRAST_JDBC_URL=jdbc:mysql://user.c0lasdae9lf.us-east-2.rds.amazonaws.com:3306/contrast
- CONTRAST_JDBC_USER=<enter user>
- CONTRAST_JDBC_PASS=<enter password>
```


### Checking the state of the running containers
---
To check the status of the containers you can run `docker-compose ps`:

```bash
$ docker-compose ps

                 Name                               Command                  State                     Ports               
---------------------------------------------------------------------------------------------------------------------------         
mysql:8.0.21                                docker-entrypoint.sh --log ...   Up             0.0.0.0:32773->3306/tcp, 33060/tcp
contrast:lastest                            ./docker-entrypoint.sh /us ...   Up (healthy)   0.0.0.0:32775->8080/tcp, 8443/tcp 
```

In the example output above, you will see the port mappings from local ports to container ports. In this case,  TeamServer is listening on local port `32775`.

**Tailing logs**

The container logs can be tailed by tailing all logs for all containers `docker-compose logs -f` or for an individual service `docker-compose logs -f contrast`

Once the containers have finishing initializing, you can invoke APIs and access the TeamServer UI in the same way as the kubernetes example, but with the ports referenced in the output of the `docker-compose ps` command.


### Cleaning up
---
To clean up, you can stop and remove the running containers:

```bash
docker-compose rm -s
```

