# Top Speed Infrastructure

There is no application code to deploy, just Ververica Platform resources to support the
other applications.

This includes:
* A [Ververica Platform Namespace](https://docs.ververica.com/administration/namespaces.html).
* A [Ververica Platform Deployment Target](https://docs.ververica.com/administration/deployment_targets.html).

For values, see [`values.yaml`](./values.yaml).

## Deployment

Deployments are done through a Helm release in a GitLab CI job (see [`.gitlab-ci.yml`](../../../.gitlab-ci.yml)),
but small scripts are also kept in this directory for testing. See [`deploy.sh`](./deploy.sh)
and [`uninstall.sh`](./uninstall.sh) for deploying and deleting, respectively.

