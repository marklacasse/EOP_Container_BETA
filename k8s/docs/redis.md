# Configuring an external cache (redis)

**External cache configuration values:**

|     |     |     |     |
| --- | --- | --- | --- |
| **Properties Value** | **ENV** | **Value** | **Notes** |
| cache.useredis | CONTRAST\_CACHE\_USEREDIS | true/false | boolean |
| contrast.cache.redis.db.index | CONTRAST\_CACHE\_REDIS\_DB\_INDEX | 0   | default value does not need to be defined. |
| contrast.cache.redis.proto | CONTRAST\_CACHE\_REDIS_PROTO | redis | default value does not need to be defined. |
| contrast.cache.redis.host | CONTRAST\_CACHE\_REDIS_HOST | redis host |     |
| contrast.cache.redis.port | CONTRAST\_CACHE\_REDIS_PORT | 6379 | default value does not need to be defined |
| contrast.cache.redis.password | CONTRAST\_CACHE\_REDIS_PASSWORD | redis access password |     |
| contrast.cache.redis.client.name | CONTRAST\_CACHE\_REDIS\_CLIENT\_NAME | teamserver | default value does not need to be defined. |

## Example using contrast.properties file:
---
See [configuration overview](docs/configuration-overview.md) on setting up these values for your Teamserver container.

```properties
cache.useredis=true
contrast.cache.redis.db.index=0
contrast.cache.redis.proto=redis
contrast.cache.redis.host=teamserver-cache.acme.org
contrast.cache.redis.port=6379
contrast.cache.redis.password= SomeSecurePa$$w0rd
contrast.cache.redis.client.name=teamserver
```

1.  Update the conf/contrast.properties by uncommenting and filling out the redis section.
2.  Deploy or update the contrast configMap [see config overview](docs/configuration-overview)
3.  Deploy or redeploy the `k8s/contrast.yaml`

## Alternatively, these can also be configured in the `k8s/contrast.yaml` files `env` section.
---

> Any passwords should be stored as secrets in kubernetes
1. Create a secret for the redis password
```bash
​kubectl create secret generic redis-password --from-literal=password="changeme"
```

2. Update the `k8s/contrast.yaml` files `env` section for the `contrast` container with the following
```yaml
            - name: CONTRAST_CACHE_USEREDIS
              value: true
            - name: CONTRAST_CACHE_REDIS_HOST
              value: <REDIS HOST DNS>
            - name: CONTRAST_TRUSTSTORE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: redis-password
                  key: password
```
> configure additional values should they differ in your environment, like the redis port. 

3. Deploy or redeploy the `k8s/contrast.yaml`

## Checking setup:
---

The /data/logs/contrast.log will contain all the information on the current configuration and interactions with redis.

- RedissonCache
- CacheConfiguration

Will be two key terms you will want to look for in the logs.