# Trusting an internal CA or self-signed certificate

This document describes how you can trust an internal CA or self-signed certificate that may be used in your organization to allow Contrast to access network resources, e.g. bugtrackers, or Contrast Hub (ardy) via a proxy.

## Pre-requisites

You'll need the internal CA/self-signed certificate(s) you want to trust available as `.pem` files.

## Method 1 - Build a custom image

With this approach, you build a new image based off the Contrast image, where your certificates are added to the Java keystore within the Contrast image.
This custom image must then be published and made available to the environment where you'll run Contrast.

Dockerfile example:

```Dockerfile
FROM ghcr.io/contrast-security-inc/contrast:latest

ADD your_cert.pem your_cert.pem

RUN keytool -import -alias your_cert -file your_cert.pem -cacerts -storepass changeit -noprompt

EXPOSE 8080

ENTRYPOINT [ "docker-entrypoint.sh" ]
```

If you have several certificates to add, repeat the `ADD` and `RUN` lines for each certificate, replacing the alias and file arguments.

## Method 2 - Mount your certificate and load it via an initContainer

With this approach, the certificate is mounted to an initContainer, imported to a trustStore (based off the provided `cacerts` trustStore) and Contrast configured to use that custom trustStore.

1. Import the certificate `.pem` file as a secret:

`kubectl create secret generic contrast-cacert-to-add --from-file=cert-to-add.pem=your_cert.pem`

2. Update the `contrast.yaml` adding 2 volumes:
```yaml
volumes:
  - name: contrast-truststore-volume
    emptyDir: {}
  - name: contrast-cacert-volume
    secret:
      secretName: contrast-cacert-to-add
```

3. Add the below option to the `JAVA_OPTS` environment value:

`-Djavax.net.ssl.trustStore=/opt/contrast/truststore/truststore`

4. Mount `contrast-truststore-volume` to the main container:

```yaml
volumeMounts:
  - name: contrast-truststore-volume
    mountPath: /opt/contrast/truststore
```

5. Add an initContainer below the `init-migrations` container in `contrast.yaml`:

```yaml
- name: init-cacerts
  image: ghcr.io/contrast-security-inc/contrast:latest
  env:
    - name: CONTRAST_LICENSE
      valueFrom:
        secretKeyRef:
          name: contrast-license
          key: license
      volumeMounts:
        - name: contrast-truststore-volume
          mountPath: /opt/contrast/truststore
        - name: contrast-cacert-volume
          mountPath: /opt/contrast/conf/certs
      command: ['sh', 'keytool -import -alias my_ca -file /opt/contrast/conf/certs/cert-to-add.pem -cacerts -storepass changeit -noprompt && keytool -list -alias my_ca -cacerts -storepass changeit && cp /opt/java/openjdk/lib/security/cacerts /opt/contrast/truststore/truststore']
```
