load("@rules_jvm_external//:defs.bzl", "DEFAULT_REPOSITORY_NAME")
load("@rules_jvm_external//:specs.bzl", "maven")
load("//tools:maven_utils.bzl", "format_maven_jar_dep_name_from_artifact")

_SCALA_VERSION_KEY = "${SCALA_VERSION}"

_FLINK_GROUP = "org.apache.flink"

# Flink core packages that should be provided by the deployment environment
_FLINK_PROVIDED_PKGS = [
    (_FLINK_GROUP, "flink-runtime_%s" % _SCALA_VERSION_KEY),
    (_FLINK_GROUP, "flink-runtime-web_%s" % _SCALA_VERSION_KEY),
    (_FLINK_GROUP, "flink-streaming-java_%s" % _SCALA_VERSION_KEY),
    (_FLINK_GROUP, "flink-clients_%s" % _SCALA_VERSION_KEY),
    (_FLINK_GROUP, "flink-test-utils_%s" % _SCALA_VERSION_KEY),
    (_FLINK_GROUP, "flink-java"),
    (_FLINK_GROUP, "flink-core"),
    (_FLINK_GROUP, "flink-metrics-core"),
    (_FLINK_GROUP, "flink-state-backends"),
    (_FLINK_GROUP, "flink-annotations"),
]

_FLINK_TEST_PKGS = [
    (_FLINK_GROUP, "flink-runtime_%s" % _SCALA_VERSION_KEY),
    (_FLINK_GROUP, "flink-streaming-java_%s" % _SCALA_VERSION_KEY),
]

# Other compile time packages that should be provided
_VERSIONED_PROVIDED_PKGS = [
    # Logging requirements
    ("org.slf4j", "slf4j-log4j12", "1.7.15"),
    ("org.slf4j", "slf4j-api", "1.7.15"),
    ("log4j", "log4j", "1.2.17"),
]

ADDONS = struct(
    AVRO = [
        (_FLINK_GROUP, "flink-avro"),
    ],
    RABBIT_MQ = [
        (_FLINK_GROUP, "flink-connector-rabbitmq_%s" % _SCALA_VERSION_KEY),
        # Other RMQ dependencies
        ("com.rabbitmq", "amqp-client", "4.2.0"),
    ],
    DROPWIZARD_METRICS = [
        (_FLINK_GROUP, "flink-metrics-dropwizard"),
        ("io.dropwizard.metrics", "metrics-core", "4.1.1"),
    ],
    FILESYSTEM = [
        (_FLINK_GROUP, "flink-connector-filesystem_%s" % _SCALA_VERSION_KEY),
    ],
)

def _replace_scala_artifact_version(artifact_id, version):
    return artifact_id if (not artifact_id.endswith(_SCALA_VERSION_KEY) or version == None) else artifact_id.replace(_SCALA_VERSION_KEY, version)

def _flat(l):
    f = []
    for x in l:
        f += x
    return f

def _format_artifact(tuple, flink_version, scala_version, classifier = None, neverlink = False):
    group = tuple[0]
    artifact_id = _replace_scala_artifact_version(tuple[1], scala_version)
    version = None
    if group == _FLINK_GROUP:
        version = flink_version
    elif len(tuple) == 3:
        version = tuple[2]

    return maven.artifact(
        group = group,
        artifact = artifact_id,
        version = version,
        neverlink = neverlink,
        classifier = classifier,
    )

def _is_provided_dep(dep, scala_version, flink_repo):
    # TODO: must enumerate all possibilities for provided artifacts
    #       (i.e. with or without version, perhaps also should do for maven compat repos)

    # could be faster if we build compile time pkgs into a struct,
    # but not necessary for now
    provided_artifacts = [
        _format_artifact(
            artifact,
            scala_version = scala_version,
            flink_version = None,  # no need for a version since we're not installing
        )
        for artifact in _FLINK_PROVIDED_PKGS + _VERSIONED_PROVIDED_PKGS
    ]
    for provided in provided_artifacts:
        if format_maven_jar_dep_name_from_artifact(provided, repository = flink_repo) == dep:
            return True

    return False

def _to_compile_time_dep(dep, flink_repo, flink_provided_repo):
    return dep.replace(flink_repo, flink_provided_repo)

def _provided_deps(deps, scala_version, flink_repo, flink_provided_repo):
    """
    :param deps: a list of dependencies
    :param scala_version: the version of scala that is being used, as some deps are named accordingly
    :param flink_repo: the main maven repository where flink dependencies are linked
    :param flink_provided_repo: the maven repo where flink dependencies are not linked
    :returns: the list of dependencies where all flink deps that should be provided
             are replaced with their compile_time alternatives
    """
    return [
        dep if not _is_provided_dep(dep, scala_version, flink_repo) else _to_compile_time_dep(dep, flink_repo, flink_provided_repo)
        for dep in deps
    ]

# Want to be able to provide a list of addons that have both main and testing artifacts
# Want to be able to either provide a version or use the default Flink version

def flink_artifacts(version, scala_version, neverlink = False, addons = []):
    return [
        _format_artifact(
            tuple,
            flink_version = version,
            scala_version = scala_version,
            neverlink = neverlink,
        )
        for tuple in _FLINK_PROVIDED_PKGS + _VERSIONED_PROVIDED_PKGS + _flat(addons)
    ]

def flink_testing_artifacts(version, scala_version, neverlink = False, addons = []):
    return [
        _format_artifact(
            tuple,
            flink_version = version,
            scala_version = scala_version,
            neverlink = neverlink,
            classifier = "tests",
        )
        for tuple in _FLINK_TEST_PKGS + _flat(addons)
    ]

def flink_java_library(
        name,
        srcs,
        scala_version = None,
        deps = [],
        resources = [],
        flink_java_library_deps = [],
        flink_repo = "maven",
        flink_provided_repo = "compile_time"):
    native.java_library(
        name = name,
        srcs = srcs,
        deps = deps + flink_java_library_deps,
    )
    native.java_library(
        name = name + "_pruned",
        srcs = srcs,
        deps = _provided_deps(deps, scala_version, flink_repo, flink_provided_repo) +
               [dep + "_pruned" for dep in flink_java_library_deps],
    )

def flink_java_binary(
        name,
        srcs,
        main_class,
        scala_version = None,
        deps = [],
        resources = [],
        flink_java_library_deps = [],
        flink_repo = "maven",
        flink_provided_repo = "compile_time"):
    native.java_binary(
        name = name,
        srcs = srcs,
        main_class = main_class,
        resources = resources,
        deps = deps + flink_java_library_deps,
    )

    provided_deps = _provided_deps(
        deps,
        scala_version,
        flink_repo,
        flink_provided_repo,
    ) + [dep + "_pruned" for dep in flink_java_library_deps]
    native.java_binary(
        name = name + "_pruned",
        srcs = srcs,
        main_class = main_class,
        resources = resources,
        deps = provided_deps,
    )
