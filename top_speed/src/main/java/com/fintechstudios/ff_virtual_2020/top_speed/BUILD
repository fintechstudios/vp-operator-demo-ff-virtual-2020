package(default_visibility = ["//visibility:public"])

filegroup(
    name = "java-main-srcs",
    srcs = glob(["*.java"]),
)

# Main application
java_binary(
    name = "top_speed",
    srcs = [":java-main-srcs"],
    deploy_env = ["//:default_flink_deploy_env"],
    main_class = "com.fintechstudios.ff_virtual_2020.top_speed.TopSpeed",
    resources = [
        "//top_speed/src/main/resources:resource_files",
    ],
    deps = [
        "@maven//:org_apache_flink_flink_core",
        "@maven//:org_apache_flink_flink_java",
        "@maven//:org_apache_flink_flink_runtime_web_2_11",
        "@maven//:org_apache_flink_flink_streaming_java_2_11",
        "@maven//:org_slf4j_slf4j_api",
    ],
)

load("//tools/checkstyle:checkstyle.bzl", "checkstyle_test")

checkstyle_test(
    name = "lint",
    srcs = [":java-main-srcs"],
)
