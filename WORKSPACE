workspace(
    name = "ff_sf2020",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Java

## Bazel Rules for working with Maven
## see: https://github.com/bazelbuild/rules_jvm_external

RULES_JVM_EXTERNAL_TAG = "2.8"

RULES_JVM_EXTERNAL_SHA = "79c9850690d7614ecdb72d68394f994fef7534b292c4867ce5e7dec0aa7bdfad"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

## Flink
load("//tools/flink:flink.bzl", "ADDONS", "flink_artifacts", "flink_testing_artifacts")

## JUnit5
load("//tools/junit:junit5.bzl", "junit_jupiter_java_artifacts", "junit_platform_java_artifacts")

## Apache Avro
load("//tools/avro:avro.bzl", "avro_artifacts")

## Checkstyle
load("//tools/checkstyle:checkstyle.bzl", "checkstyle_artifacts")

## Maven
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")

FLINK_VERSION = "1.10.0"

FLINK_SCALA_VERSION = "2.11"

maven_install(
    artifacts = flink_artifacts(
        scala_version = FLINK_SCALA_VERSION,
        version = FLINK_VERSION,
    ) + flink_testing_artifacts(
        scala_version = FLINK_SCALA_VERSION,
        version = FLINK_VERSION,
    ) + junit_jupiter_java_artifacts(
        version = "5.5.1",
    ) + junit_platform_java_artifacts(
        version = "1.5.1",
    ) + avro_artifacts(
        version = "1.8.2",
    ) + checkstyle_artifacts(),
    fetch_sources = True,
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)

maven_install(
    name = "provided",
    artifacts = flink_artifacts(
        neverlink = True,
        scala_version = FLINK_SCALA_VERSION,
        version = FLINK_VERSION,
    ),
    fetch_sources = False,
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)
