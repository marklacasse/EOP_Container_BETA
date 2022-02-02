# Configuring Contrast to use self-signed or privately-signed certificate with LDAP

The purpose of this document is to describe how to configuring Contrast to use self-signed or privately-signed certificate with LDAP.

## Configuration Steps

1. Generate a trust store using the Java Keytool.

        keytool -importcert -keystore contrast-truststore.jks -storepass changeme -file <ldap cert> -noprompt

1. Create two `secrets` to configure Contrast to access the trust store

        kubectl create secret generic contrast-truststore --from-file=contrast-truststore.jks
        kubectl create secret generic contrast-truststore-password --from-literal=password="changeme"


1. Update the `contrast.yaml` file to mount the trust store as a file
  
        template:
            metadata:
              labels:
                app: contrast
            spec:
                ......
              containers:
                - name: contrast
                ......
                  # Mount the volume into the Contrast container
                  volumeMounts:
                  ......
                    - name: contrast-truststore
                      mountPath: /var/run/secrets/teamserver/truststore
                      readOnly: true
                ......
              # Define the volume
              volumes:
                - name: contrast-truststore
                  secret:
                    secretName: contrast-truststore

1. Update the `contrast.yaml` file to define the environment variables to configure the trust store password and configure the JVM to use the trust store

            - name: CONTRAST_TRUSTSTORE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: contrast-truststore-password
                  key: password
            - name: JAVA_OPTS
              value: '-Djavax.net.ssl.trustStorePassword=$(CONTRAST_TRUSTSTORE_PASSWORD) -Djavax.net.ssl.trustStore=/var/run/secrets/teamserver/truststore/contrast-truststore.jks'