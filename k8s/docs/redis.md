# Configuring an external cache (redis)

**External cache configuration values:**

|     |     |     |
| --- | --- | --- |
| **ENV** | **Value** | **Notes** |
| CONTRAST\_CACHE\_USEREDIS | true/false | boolean |
| CONTRAST\_CACHE\_REDIS\_DB\_INDEX | 0   | default value does not need to be defined. |
| CONTRAST\_CACHE\_REDIS_PROTO | redis | default value does not need to be defined. |
| CONTRAST\_CACHE\_REDIS_HOST | redis host |     |
| CONTRAST\_CACHE\_REDIS_PORT | 6379 | default value does not need to be defined |
| CONTRAST\_CACHE\_REDIS_PASSWORD | redis access password |     |
| CONTRAST\_CACHE\_REDIS\_CLIENT\_NAME | teamserver | default value does not need to be defined. |


## These can be configured in the `k8s/contrast.yaml` files `env` section.
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