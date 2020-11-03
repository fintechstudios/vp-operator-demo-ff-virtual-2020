"""Global definitions.
"""

load("//tools/flink:flink.bzl", "ADDONS")

FLINK_VERSION = "1.10.2"

FLINK_SCALA_VERSION = "2.11"

# All of the addons that should be provided in the deploy environment
FLINK_PROVIDED_ADDONS = [
    ADDONS.BASE,
    ADDONS.DROPWIZARD_METRICS,
    ADDONS.FILESYSTEM,
    ADDONS.TABLE,
]

# All of the addons that should be downloaded
FLINK_ADDONS = [
    ADDONS.PULSAR,
    ADDONS.RABBIT_MQ,
    ADDONS.AVRO,
    ADDONS.ES,
    ADDONS.TESTING,
] + FLINK_PROVIDED_ADDONS
