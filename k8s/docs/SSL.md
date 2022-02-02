# Configuring SSL/TLS for the Contrast service

The purpose of this document is to describe how to configure SSL all the way to the Contrast service. However, in most cases SSL can be configured to terminate at a load balancer instead.

## Required configuration values
| Name                                             	| Description           	                                | Example                              	|
|--------------------------------------------------	|-----------------------------------------------------------|--------------------------------------	|
| `server.ssl.enabled` | Whether to enable SSL support.  Default value `false` | `true` |
| `server.ssl.key-store` | Path to the key store that holds the SSL certificate.  Key store format most be one of `JKS` , `PKCS11`, or `PKCS12` (these are the only ones supported by Tomcat) | `/path/to/sslkeystorefile.jks` |
| `server.ssl.key-alias` | Alias that identifies the key in the key store. | |
| `CONTRAST_SERVER_SSL_KEY_STORE_PASSWORD` | Password used to access the key store.| |
| `CONTRAST_SERVER_SSL_KEY_PASSWORD` | Password used to access the key in the key store. | |


## Optional server configuration values
| Name                                             	| Description           	                                | Example                              	|
|--------------------------------------------------	|-----------------------------------------------------------|--------------------------------------	|
| `server.port` | Default value `8080` | |
| `server.ssl.key-store-type` | Type of keystore. Must key-store format.  Key store format must be one of `JKS`, `PKCS11`, or `PKCS12` (these are the only ones supported by Tomcat).  Default value `JKS` | `JKS` |
| `server.ssl.ciphers` | Supported SSL ciphers.  Default value  `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_RSA_WITH_AES_256_CBC_SHA256` | |
| `server.ssl.protocol` | SSL protocol to use.  Default value `TLS` | `TLS` |
| `server.ssl.enabled-protocols` | Enabled protocols. Default value `TLSv1.2,TLSv1.3` | |

### Notes:
`server.ssl.ciphers`: Not all systems will support all cipher suites (e.g. older systems). It is important to test this in a staging environment first. See https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices#23-use-secure-cipher-suites


## Special Notes
| Name                                             	| Description           	                                |
|--------------------------------------------------	|-----------------------------------------------------------|
| `jdk.tls.disabledalgorithms` | Contrast updates this system property to always contain `RSASSA-PSS`; not all TLS implementations can honor certs signed with `RSASSA-PSS`.  https://mailarchive.ietf.org/arch/msg/tls/c5OCDwhcD1xP_YAP7Xx700VKbis/ |


## Configuration Steps

1. Create three `secrets` to configure Contrast to access the keystore

        kubectl create secret generic contrast-ssl-keystore --from-file=ssl.jks=ssl.jks
        kubectl create secret generic contrast-ssl --from-literal=server.ssl.key-store-password="changeme" --from-literal=server.ssl.key-password="changeme"


1. Update the `contrast.yaml` file to mount the keystore as a file
  
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
                    # This should match the value set by server.ssl.key-store
                    - name: contrast-ssl
                      mountPath: /opt/contrast/data/ssl
                      readOnly: true
                ......
              # Define the volume
              volumes:
                - name: contrast-ssl
                  secret:
                    secretName: contrast-ssl-keystore

1. Update the `contrast.yaml` file to define the environment variables to configure the SSL secrets

            - name: CONTRAST_SERVER_SSL_KEY_STORE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: contrast-ssl
                  key: server.ssl.key-store-password
            - name: CONTRAST_SERVER_SSL_KEY_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: contrast-ssl
                  key: server.ssl.key-password


1. Create or update a [contrast-config ConfigMap](./configuration-overview.md) to define any configuration values
  
        server.ssl.enabled=true
        server.ssl.key-alias=contrast-server
        server.ssl.key-store=/opt/contrast/data/ssl/ssl.jks
