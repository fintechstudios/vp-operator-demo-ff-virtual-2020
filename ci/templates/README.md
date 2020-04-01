# GitLab CI Templates

Each sub-directory contains templates for unifying how tools are used in CI.

## Stages

All templates may use the following stages, and usage of them should fit in the same
structure.

```yaml
stages:
  - prepare # build the ci image and other ci dependencies
  - build # build the source
  - test # run all tests
  - release # push all release artifacts to distribution storage
  - deploy-dev # deploy to the dev cluster(s)/ environment(s)
  - deploy-prod # deploy to the prod cluster(s)/ environment(s)
```

## Environments

All templates may use the following K8s environments:

* `dev`
* `prod`

## Scripts

Usually the `script` field is used by the template, leaving the `before_script` and `after_script`
for job modifications that are not possible through variables.
