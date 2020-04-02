package(default_visibility = ["//visibility:public"])

load("//tools/junit:junit5.bzl", "java_junit5_test")

filegroup(
    name = "srcs",
    srcs = glob(["*.java"]),
)

_PKG = "com.fintechstudios.ff_sf2020.top_speed"

_DEPS = [
    "//top_speed/src/main/java/com/fintechstudios/ff_sf2020/top_speed",
    "@maven//:com_google_truth_truth",
    "@maven//:org_apache_flink_flink_core",
    "@maven//:org_apache_flink_flink_runtime_2_11",
    "@maven//:org_apache_flink_flink_runtime_2_11_tests",
    "@maven//:org_apache_flink_flink_streaming_java_2_11",
    "@maven//:org_apache_flink_flink_streaming_java_2_11_tests",
    "@maven//:org_apache_flink_flink_test_utils_2_11",
]

java_junit5_test(
    name = "unit-tests",
    size = "small",
    srcs = [":srcs"],
    resources = ["//top_speed/src/test/resources:resource_files"],
    tags = ["unit"],
    test_package = _PKG,
    deps = _DEPS,
)

java_junit5_test(
    name = "int-tests",
    size = "medium",
    srcs = [":srcs"],
    resources = ["//top_speed/src/test/resources:resource_files"],
    tags = ["integration"],
    test_package = _PKG,
    deps = _DEPS,
)

load("//tools/checkstyle:checkstyle.bzl", "checkstyle_test")

checkstyle_test(
    name = "lint",
    srcs = [":srcs"],
)
