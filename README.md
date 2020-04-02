# VVP K8s Operator Demo for Flink Forward SF 2020

This repo provides an example Flink application that is deployed using the [Ververica Platform K8s Operator][1],
GitLab CI/CD, and Helm. 

## Local Setup

It is best to use [JetBrains IntelliJ](https://www.jetbrains.com/idea/) - other IDEs might work but are not currently
supported.

For bazel support, use [the official IntelliJ plugin](https://ij.bazel.build).
* Make sure you specify the absolute path to the Bazel binary in
    _Settings > Other Settings > Bazel Settings > Bazel Binary Location_
    * You should be able to generate a Bazel project from the [`BUILD` file](./BUILD), though if it
    complains you can add something like this to `./ijwb/.bazelproject`:
    ```yaml
    directories:
      # Add the directories you want added as source here
      # By default, we've added your entire workspace ('.')
      .
      core
      infongen-provider
      document-resolver
    
    # Automatically includes all relevant targets under the 'directories' above
    derive_targets_from_directories: true
    
    targets:
      # If source code isn't resolving, add additional targets that compile it here
      //core:core
      //document-resolver:document_resolver
      //infongen-provider:infongen_provider
    
    workspace_type: java
    java_language_level: 8
    ```

System Requirements:
* [bazel](https://github.com/bazelbuild/bazel/releases) >= 0.28.1
* git
* docker >= 19

The [`tools`](./tools) package contains useful bazel macros for running JUnit and checkstyle tests.

### Building

`bazel` is used as the build tool because it makes working with monorepos a breeze.

The application is built into a fat java jar with the `{module}_pruned_deploy.jar` target.
The `pruned` jar should has all Flink code that is in the deployment environment removed, similar to Maven's `provided`
dependencies.

Ex:
```shell
bazel build //top_speed:top_speed_pruned_deploy.jar
```

### Testing

Currently, each module has three testing targets: 
* `unit-tests` runs unit tests
* `int-tests` runs integration tests
* `lint` runs checkstyle

Ex:
```shell
bazel test //top_speed:unit-tests # runs all unit tests for the top_speed module
```


There are also top-level targets of the same name that will run the tests
for all the modules, as well as an `//:all-tests` target that will run _everything_. 


For tests that need environment variables, Bazel is notoriously bad at handling them.
See:
- https://bazel.build/designs/2016/06/21/environment.html
- https://www.pgrs.net/2016/11/02/bazel-and-env-files/

No fear! [`bazel-test-dotenv`](./scripts/bazel-test-dotenv.sh) script is here!

Give it a .env file (and all other `bazel test` arguments) and it will put all the
variables in the test env.

Ex:
```shell
./scripts/bazel-test-dotenv.sh .env //:int-tests
```

## Deployment

Applications are deployed to the [Ververica Platform](docs.ververica.com/stream/application_manager) with the help of
the [K8s controller](https://github.com/fintechstudios/ververica-platform-k8s-controller).

Deployment of the applications is done through Helm charts with GitLab / their Kubernetes integration.
Deployments will only be queued if there are changes to a chart, an application's code/ its dependencies, or the ci deploy config.

Rollbacks are also handled in GitLab -- there is a manual job for every deployment that can be run to revert
the last release.

CI/CD Variables:
- `${RELEASE_NAME}_${CI_ENVIRONMENT_NAME}_VALUES` 'File' variable, a Helm `values.yaml` file to use,
which can contain $ENV variables to be swapped in. Needs to be named in SCREAMING_SNAKE_CASE. This is the
place to store secrets and environment-specific config.

[1]: https://github.com/fintechstudios/ververica-platform-k8s-operator
