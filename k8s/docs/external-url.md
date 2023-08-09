# Configuring an External URL

The Contrast application constructs URLs for use by external services or users, for example:

* Connection properties in generated agent configuration
* Links to the Contrast UI in notifications and reports
* SAML Service Provider metadata when SSO is configured

## Configuration

In order to configure the external URL, you can set the following environmental variable in your Contrast deployment. In most cases, the default values should be overridden.

| Name                                             	| Description           	                                | Example                              	|
|--------------------------------------------------	|---------------------------------------------------------|--------------------------------------	|
| `CONTRAST_TEAMSERVER_URL`                           | Url of Loadbalancer used to access Teamserver           | `https://beta.teamserver.com/Contrast`             |

 Update the `contrast.yaml` file to define the environment variables to configure Teamserver URL. 

```yaml
            - name: CONTRAST_TEAMSERVER_URL
              value: https://<LoadBalancer_Host>/Contrast
              