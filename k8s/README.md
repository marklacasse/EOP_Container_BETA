# Running in a Kubenetes cluster

## Create a kubernetes secret for the Contrast License

The Contrast License is used by all of the containers to decrypt the encrypted artifacts on startup. Also, TeamServer uses the license for assess/protect entitlements.

> **NOTE**: The Contrast License needs to be generated recently (after June 11th, 2020) so it includes the updated format the container expects.

```
kubectl create secret generic contrast-license --from-file=license=<path to contrast.lic>
```


## Depoying Contrast Teamserver & MySQL in kubernetes 
---


### Deploying the Contrast MySQL service (TeamServer database)

1. Create kubernetes secrets for the Contrast database password

         kubectl create secret generic contrast-database --from-literal=password="default1"

1. Deploy the `Contrast` `PersistentVolume` and `PersistentVolumeClaim`

         kubectl apply -f mysql-pv.yaml

1. Deploy the Contrast MySQL `deployment` and `service` configuration

         kubectl apply -f mysql.yaml

### Deploying the Contrast server service (TeamServer)

1. Deploy the Contrast `deployment` and `service` configuration

         kubectl apply -f contrast.yaml


## Deploying Contrast Teamserver with Remote MySQL database 
---

> **WARNING:** It is not recomended to point the Teamserver containers at your production database. Should you wish to point the container at a pre-production database, ensure you are using the exact same version of the Teamserver for the image.  Otherwise you may inadvertanly upgrade your database schema causing problems for your normal EOP installations. 


1. Create kubernetes secret for the password used to access the MySQL database

         kubectl create secret generic contrast-database --from-literal=password="default1"

2. Open the k8s/contrast.yaml file to edit the jdbc strings
- Configure the `CONTRAST_JDBC_URL` for the `containers` & `initContainers` sections
- Configure the `CONTRAST_JDBC_USER` if it differs from the default

Example
```yaml
          env:
            - name: CONTRAST_JDBC_URL
              value: "jdbc:mysql://<ADD MySQL DNS HERE>:3306/contrast"
            - name: CONTRAST_JDBC_PASS
              valueFrom:
                secretKeyRef:
                  name: contrast-database
                  key: password
            - name: CONTRAST_JDBC_USER
              value: "contrast"
```


## Deploying the Contrast server service (TeamServer)

1. Deploy the Contrast `deployment` and `service` configuration

         kubectl apply -f contrast.yaml



## Load Balancer examples
---
> **NOTE** To run more than 1 `Contrast` server, configuring sticky sessions is required. See [traefiks](https://docs.traefik.io/routing/services/#sticky-sessions) example for enabling sticky sessions.

- **Example load balancer you can apply the `ingress` configuration**

         kubectl apply -f ingress.yaml

- **The following can also be used to quickly expose the contrast service**
        
         kubectl expose deployment contrast --type=LoadBalancer --name=contrast-lb

    Then run `kubectl get services` to get the EXTERNAL-IP and PORT(S)

- **Alternatively, if running in a cloud, the Contrast service can be forwarded to a local port**
[Port-forwarding with Kubernetes](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/#forward-a-local-port-to-a-port-on-the-pod)

> **_NOTE:_**  [K9s](https://k9scli.io/topics/install/) is a great choice for managing and interacting with pods and services

### Accessing the Contrast UI

Once the Contrast pod is ready, the UI can be accessed through `8080` once this is exposed or through another load balancer. The UI should be accessible through http://localhost:8080/Contrast


## Additional configuration options
---
- [Configuration Overview](docs/configuration-overview.md)
- [External URL](docs/external-url.md)
- [java options](docs/java_opts.md)
- [LDAPS](docs/ldap.md)
- [SSL](docs/SSL.md)
- [SSO](docs/SSO.md)
- [External ActiveMQ](docs/activemq.md)
- [External Cache](docs/redis.md)


## Helpful commands
---
#### Interacting with Contrast pods in k3s cluster

```
# List all pods
kubectl get pods

# Get logs for a specific pod (from the output of the above command)
kubectl logs <pod name>

# Get logs for pods with the contrast-mysql label
kubectl logs -l app=contrast-mysql

# Get logs for pods with the contrast label
kubectl logs -l app=contrast

# Tail logs for pods with the contrast label
kubectl logs -f -l app=contrast

# Exec into the pod
kubectl exec -it <pod name> bash
```


## References

* `services` - https://kubernetes.io/docs/concepts/services-networking/service/
* `deployments` - https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
* `ingress` - https://kubernetes.io/docs/concepts/services-networking/ingress/