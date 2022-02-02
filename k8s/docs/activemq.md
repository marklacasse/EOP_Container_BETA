# Configuring an External broker (activeMQ)

Configuring an external broker for handing queues. (activemq)

1. Update the `k8s/contrast.yaml` `env` section under the `contrast` container with the following environmental variables.

```yaml
           - name: CONTRAST_USE_EXTERNAL_ACTIVEMQ
              value: "true"
            - name: CONTRAST_JMS_BROKER_URL
              value: "ssl://<ACTIVEMQ_DNS>:61617"
            # Optional for authenticated access
            - name: CONTRAST_JMS_BROKER_USERNAME
              value: "<USER>"
            - name: CONTRAST_JMS_BROKER_PASSWORD
              value: "<PASSWORD>"
```
> Any passwords should be stored as secrets in kubernetes

            - name: CONTRAST_TRUSTSTORE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: contrast-truststore-password
                  key: password


2.  Deploy or redeploy the `k8s/contrast.yaml`