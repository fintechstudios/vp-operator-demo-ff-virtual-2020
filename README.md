# VP K8s Operator Demo for Flink Forward Virtual 2020

This repo provides an example Flink application that is deployed using the [Ververica Platform K8s Operator][1],
GitLab CI/CD, and Helm.

## Deployment

Applications are deployed to the [Ververica Platform](https://docs.ververica.com) with the help of
the [vp-k8s-operator](https://github.com/fintechstudios/ververica-platform-k8s-operator).

Deployment of the applications is done through Helm charts with GitLab / their Kubernetes integration.

Rollbacks are also handled in GitLab -- there is a manual job for every deployment that can be run to revert
the last release.

CI/CD Variables:
- `${RELEASE_NAME}_${CI_ENVIRONMENT_NAME}_VALUES` 'File' variable, a Helm `values.yaml` file to use,
which can contain $ENV variables to be swapped in. Needs to be named in SCREAMING_SNAKE_CASE. This is the
place to store secrets and environment-specific config.

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
      top_speed
    
    # Automatically includes all relevant targets under the 'directories' above
    derive_targets_from_directories: true
    
    targets:
      # If source code isn't resolving, add additional targets that compile it here
      //top_speed:top_speed
    
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

The application is built into a deployable jar with the `{module}_deploy.jar` target.
For an uber jar, use just the `{module}.jar` target.

Ex:
```shell
bazel build //top_speed/src/main/java/com/fintechstudios/ff_virtual_2020/top_speed:top_speed_deploy.jar

# uber jar
bazel build //top_speed:top_speed.jar
```

### Testing

Currently, there are three types of tests: 
* `unit-tests` runs unit tests
* `int-tests` runs integration tests
* `lint` runs checkstyle

Testing targets should be named as the type of test.

Ex:
```shell
bazel query 'attr(name, "lint", tests(//top_speed/...))' | xargs bazel test # runs all lint tests for the top_speed module
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

[1]: https://github.com/fintechstudios/ververica-platform-k8s-operator
