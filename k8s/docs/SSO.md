# Configuring Contrast for SAML Authentication

See the [documentation](https://docs.contrastsecurity.com/en/system-sso.html) for more details about Contrast and SAML.

## Required configuration values

| Name                                             	| Description           	                                | Example                              	|
|--------------------------------------------------	|---------------------------------------------------------|--------------------------------------	|
| `authenticator.saml.keystore.path`        	| Path to the keystore  	                                | /path/to/samlKeystore.jks            	|
| `authenticator.saml.keystore.default.key` 	| Key pair alias                                          | some-alias                           	|
| `CONTRAST_AUTHENTICATOR_SAML_KEYSTORE_PASSWORD`    	| Keystore password     	                                | changeit                             	|
| `CONTRAST_AUTHENTICATOR_SAML_KEYSTORE_PASSWORDMAP` 	| Keystore password map 	                                | some-alias=changeit                  	|

## Configure external URL

Contrast server provides SAML metadata that can be ingested by a SAML Identity Provider. This metadata includes
the external URL of Contrast. 

See [Configuring External URL](./external-url.md)


## Configuration steps

1. Generate a set of self-signed keys using the Java Keytool. Contrast doesn't provide keys for SAML authentication. If you enable SSO without providing private keys, you're only able to perform IdP-initiated logins.

        keytool -genkeypair -alias some-alias -keypass changeme -keyalg RSA -keystore samlKeystore.jks

1. Create two `secrets` to configure Contrast to enable SAML

        kubectl create secret generic contrast-sso-keystore --from-file=samlKeystore.jks=samlKeystore.jks
        kubectl create secret generic contrast-sso --from-literal=password="changeme" --from-literal=password-map="some-alias=changeme"

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
                    # This should match the value set by authenticator.saml.keystore.path
                    - name: contrast-sso
                      mountPath: /opt/contrast/data/saml
                      readOnly: true
                ......
              # Define the volume
              volumes:
                - name: contrast-sso
                  secret:
                    secretName: contrast-sso-keystore


1. Update the `contrast.yaml` file to define the environment variables to configure SAML secrets


            - name: CONTRAST_AUTHENTICATOR_SAML_KEYSTORE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: contrast-sso
                  key: password
            - name: CONTRAST_AUTHENTICATOR_SAML_KEYSTORE_PASSWORDMAP
              valueFrom:
                secretKeyRef:
                  name: contrast-sso
                  key: password-map

1. Create or update a [contrast-config ConfigMap](./configuration-overview.md) to define any non-secret SAML properties

          authenticator.saml.keystore.path=/opt/contrast/data/saml/samlKeystore.jks
          authenticator.saml.keystore.default.key=some-alias
          server.external.port=80

1. Continue from Step 4 in the [SSO documentation](https://docs.contrastsecurity.com/en/system-sso.html) to configure your IdP.