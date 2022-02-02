# Configuring an External URL

The Contrast application constructs URLs for use by external services or users, for example:

* Connection properties in generated agent configuration
* Links to the Contrast UI in notifications and reports
* SAML Service Provider metadata when SSO is configured

## Configuration

In order to configure the external URL, you can set the following properties in a [contrast-config ConfigMap](./configuration-overview.md). In most cases, the default values should be overridden.

| Name | Description |
| -- | -- |
| `server.external.host` | The hostname for accessing Contrast. __Default: `localhost`__ |
| `server.external.port` | The port for accessing Contrast, if different from the default port `8080`. __Default: `8080`__ |
| `server.external.protocol` | The protocol for accessing Contrast, typically `http` or `https`. __Default: `http`__ |

