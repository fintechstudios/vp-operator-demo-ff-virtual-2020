# Modified from: https://github.com/junit-team/junit5-samples/tree/master/junit5-jupiter-starter-bazel

load("@rules_jvm_external//:defs.bzl", "DEFAULT_REPOSITORY_NAME")
load("@rules_jvm_external//:specs.bzl", "maven")
load("//tools:maven_utils.bzl", "format_maven_jar_dep_name", "format_maven_jar_name")

"""External dependencies & java_junit5_test rule"""

JUNIT_JUPITER_GROUP_ID = "org.junit.jupiter"
JUNIT_JUPITER_ARTIFACT_ID_LIST = [
    "junit-jupiter-api",
    "junit-jupiter-engine",
    "junit-jupiter-params",
]

JUNIT_PLATFORM_GROUP_ID = "org.junit.platform"
JUNIT_PLATFORM_ARTIFACT_ID_LIST = [
    "junit-platform-commons",
    "junit-platform-console",
    "junit-platform-engine",
    "junit-platform-launcher",
    "junit-platform-suite-api",
]

JUNIT_EXTRA_DEPENDENCIES = [
    ("org.apiguardian", "apiguardian-api", "1.0.0"),
    ("org.opentest4j", "opentest4j", "1.1.1"),
]

def junit_jupiter_java_artifacts(version = "5.5.1"):
    """Dependencies for JUnit Jupiter"""
    artifacts = []
    for artifact_id in JUNIT_JUPITER_ARTIFACT_ID_LIST:
        artifacts.append(
            maven.artifact(
                group = JUNIT_JUPITER_GROUP_ID,
                artifact = artifact_id,
                version = version,
            ),
        )

    for [group_id, artifact_id, version] in JUNIT_EXTRA_DEPENDENCIES:
        artifacts.append(
            maven.artifact(
                group = group_id,
                artifact = artifact_id,
                version = version,
            ),
        )
    return artifacts

def junit_platform_java_artifacts(version = "1.5.1"):
    """Dependencies for JUnit Platform"""
    return [
        maven.artifact(
            group = JUNIT_PLATFORM_GROUP_ID,
            artifact = artifact_id,
            version = version,
        )
        for artifact_id in JUNIT_PLATFORM_ARTIFACT_ID_LIST
    ]

def java_junit5_test(
        name,
        srcs,
        test_package,
        repository = DEFAULT_REPOSITORY_NAME,
        resources = [],
        tags = [],
        exclude_tags = [],
        deps = [],
        runtime_deps = [],
        size = None,
        **kwargs):
    FILTER_KWARGS = [
        "main_class",
        "use_testrunner",
        "args",
    ]

    for arg in FILTER_KWARGS:
        if arg in kwargs.keys():
            kwargs.pop(arg)

    junit_console_args = _get_tag_flags(tags, exclude_tags)
    if test_package:
        junit_console_args += ["--select-package", test_package]
    else:
        fail("must specify 'test_package'")

    native.java_test(
        name = name,
        srcs = srcs,
        size = size,
        resources = resources,
        use_testrunner = False,
        main_class = "org.junit.platform.console.ConsoleLauncher",
        args = junit_console_args,
        deps = deps + [
            format_maven_jar_dep_name(JUNIT_JUPITER_GROUP_ID, artifact_id, repository = repository)
            for artifact_id in JUNIT_JUPITER_ARTIFACT_ID_LIST
        ] + [
            format_maven_jar_dep_name(JUNIT_PLATFORM_GROUP_ID, "junit-platform-suite-api", repository = repository),
        ] + [
            format_maven_jar_dep_name(t[0], t[1], repository = repository)
            for t in JUNIT_EXTRA_DEPENDENCIES
        ],
        runtime_deps = runtime_deps + [
            format_maven_jar_dep_name(JUNIT_PLATFORM_GROUP_ID, artifact_id, repository = repository)
            for artifact_id in JUNIT_PLATFORM_ARTIFACT_ID_LIST
        ],
        **kwargs
    )

def _get_tag_flags(tags, exclude_tags):
    """
    tags: List
    exclude_tags: List
    """
    return ["-t %s" % tag for tag in tags] + ["-T %s" % tag for tag in exclude_tags]
