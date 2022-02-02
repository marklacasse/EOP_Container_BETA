
# Configuring Contrast JVM Arguments

## Optional configuration values

| Name      	| Description   	| Example                                                                           	|
|-----------	|---------------	|-----------------------------------------------------------------------------------	|
| JAVA_OPTS 	| JVM arguments 	| -XX:InitialRAMPercentage=75.0 -XX:MaxRAMPercentage=75.0 -XX:MinRAMPercentage=75.0 	|

## Configuring Heap size

1. Update `contrast.yaml` to include the JAVA_OPTS environment variable

        # This example will configure the JVM to calculate the heap size based on the available memory
        - name: JAVA_OPTS
          value: "-XX:InitialRAMPercentage=75.0 -XX:MaxRAMPercentage=75.0 -XX:MinRAMPercentage=75.0"

1. If you are increasing or decreasing the heap size, you'll need to update `contrast.yaml` with new resource limits

        resources:
          requests:
            cpu: 1.0
            # The memory value will need to change as the heap configuration changes
            memory: 4Gi
          limits:
            cpu: 2.0
            memory: 8Gi

## Contrast specific configuration examples

### Reset the SuperAdmin password
**Note:** It is not recommended to keep the `-Dsuperadmin.password` defined in an environment variable. A better option would be to define all the JAVA_OPTS in a Secret.

#### Using Secrets

* Create the `secret`

        # This example will reset the SuperAdmin password using JAVA_OPTS defined as a secret
        kubectl create secret generic contrast-jvm --from-literal=opts="-Dreset.superadmin=true -Dsuperadmin.username=contrast_superadmin@<your.email.domain.com> -Dsuperadmin.password=<new password>"

* Update `contrast.yaml` to set the following environment variable

        - name: JAVA_OPTS
          valueFrom:
            secretKeyRef:
              name: contrast-jvm
              key: opts

#### Using environment variables

* Update `contrast.yaml` to set the following environment variable

        # This example will reset the SuperAdmin password using an environment variable, this can be reverted after the application is redeployed
        - name: JAVA_OPTS
          value: "-Dreset.superadmin=true -Dsuperadmin.username=contrast_superadmin@<your.email.domain.com> -Dsuperadmin.password=<new password>"

