# Configuring Contrast Property Files

Contrast property files can be create and maintained by using [configmaps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)

## Creating a ConfigMap

1. Create a ConfigMap from existing files

         # Create configmap from specific files or an entire directory
         kubectl create configmap contrast-config --from-file=conf/contrast.properties

1. The `contrast.yaml` deployment will mount the `ConfigMap` in the correct location