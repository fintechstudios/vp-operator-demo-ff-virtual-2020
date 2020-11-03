load("@rules_jvm_external//:defs.bzl", "DEFAULT_REPOSITORY_NAME")
load("@rules_jvm_external//:specs.bzl", "maven")
load("//tools:maven_utils.bzl", "format_maven_jar_dep_name_from_artifact")

_SCALA_VERSION_KEY = "${SCALA_VERSION}"

_FLINK_GROUP = "org.apache.flink"

# TODO: version map all non-flink versioned deps for each flink version
ADDONS = struct(
    # Flink core packages
    BASE = [
        (_FLINK_GROUP, "flink-runtime_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-runtime-web_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-streaming-java_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-streaming-scala_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-clients_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-java"),
        (_FLINK_GROUP, "flink-core"),
        (_FLINK_GROUP, "flink-metrics-core"),
        (_FLINK_GROUP, "flink-state-backends"),
        (_FLINK_GROUP, "flink-annotations"),
        # Logging requirements
        ("org.slf4j", "slf4j-log4j12", "1.7.15"),
        ("org.slf4j", "slf4j-api", "1.7.15"),
        ("log4j", "log4j", "1.2.17"),
    ],
    # for testing libs
    TESTING = [
        (_FLINK_GROUP, "flink-test-utils_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-runtime_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-streaming-java_%s" % _SCALA_VERSION_KEY),
    ],
    AVRO = [
        (_FLINK_GROUP, "flink-avro"),
    ],
    ES = [
        (_FLINK_GROUP, "flink-connector-elasticsearch7_%s" % _SCALA_VERSION_KEY),
    ],
    RABBIT_MQ = [
        (_FLINK_GROUP, "flink-connector-rabbitmq_%s" % _SCALA_VERSION_KEY),
        # Other RMQ dependencies
        ("com.rabbitmq", "amqp-client", "4.2.0"),
    ],
    DROPWIZARD_METRICS = [
        (_FLINK_GROUP, "flink-metrics-dropwizard"),
        ("io.dropwizard.metrics", "metrics-core", "3.1.5"),
    ],
    FILESYSTEM = [
        (_FLINK_GROUP, "flink-connector-filesystem_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-s3-fs-presto"),
    ],
    # see: https://ci.apache.org/projects/flink/flink-docs-stable/dev/table/index.html
    # see: https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/table/index.html
    TABLE = [
        (_FLINK_GROUP, "flink-table-api-java"),
        (_FLINK_GROUP, "flink-table-common"),
        (_FLINK_GROUP, "flink-table-api-java-bridge_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-table-api-scala-bridge_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-table-planner_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-table-planner-blink_%s" % _SCALA_VERSION_KEY),
        (_FLINK_GROUP, "flink-table-runtime-blink_%s" % _SCALA_VERSION_KEY),
    ],
    FORMATS = [
        (_FLINK_GROUP, "flink-formats"),
        (_FLINK_GROUP, "flink-csv"),
    ],
    PULSAR = [
        # Flink Pulsar connector
        ("io.streamnative.connectors", "pulsar-flink-connector_%s" % _SCALA_VERSION_KEY, "2.4.21"),
    ],
)

def _replace_scala_artifact_version(artifact_id, version):
    return artifact_id if (not artifact_id.endswith(_SCALA_VERSION_KEY) or version == None) else artifact_id.replace(_SCALA_VERSION_KEY, version)

def _flat(l):
    """Flattens a list.
    """
    f = []
    for x in l:
        f += x
    return f

def _format_artifact(tuple, flink_version, scala_version, classifier = None, neverlink = False):
    """Formats the given artifact tuple.
    """
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

def _flink_artifact_labels(version, scala_version, neverlink = False, addons = []):
    return [
        format_maven_jar_dep_name_from_artifact(a)
        for a in flink_artifacts(
            version = version,
            scala_version = scala_version,
            neverlink = neverlink,
            addons = addons,
        )
    ]

def flink_artifacts(version, scala_version, neverlink = False, addons = []):
    """Formats a list of artifacts to pass to a rules_jvm_external maven_install repository.
    """
    return [
        _format_artifact(
            tuple,
            flink_version = version,
            scala_version = scala_version,
            neverlink = neverlink,
        )
        for tuple in _flat(addons)
    ]

def flink_testing_artifacts(version, scala_version, neverlink = False, addons = [ADDONS.TESTING]):
    """Formats Flink testing artifacts to pass to a rules_jvm_external maven_install repository.
    """
    return [
        _format_artifact(
            tuple,
            flink_version = version,
            scala_version = scala_version,
            neverlink = neverlink,
            classifier = "tests",
        )
        for tuple in _flat(addons)
    ]

def setup_deploy_env(name, version, scala_version, addons = [ADDONS.BASE]):
    """Builds a java_binary to be passed as the deploy_env target.
    Can be used to build a no-op java_binary with the given addons removed from the deploy jar.
    """
    native.java_binary(
        name = name,
        srcs = ["//tools/flink:noop"],
        main_class = "tools.flink.NoOp",
        resources = [],
        deps = _flink_artifact_labels(
            addons = addons,
            scala_version = scala_version,
            version = version,
        ),
    )
