# Top Speed

This includes:
* A [Ververica Platform Deployment](https://docs.ververica.com/user_guide/deployments/index.html).

For information on configuration, see the [`values.yaml` file](./values.yaml).

## Deployment

Deployments are done through a Helm release in a GitLab CI job (see [`.gitlab-ci.yml`](../../../.gitlab-ci.yml)),
but small scripts are also kept in this directory for testing. See [`deploy.sh`](./deploy.sh)
and [`uninstall.sh`](./uninstall.sh) for deploying and deleting, respectively.

ba
