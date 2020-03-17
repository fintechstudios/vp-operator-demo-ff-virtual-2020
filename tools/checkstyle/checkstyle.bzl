# Modified from: https://stackoverflow.com/questions/49074677/what-is-the-best-way-to-invoke-checkstyle-from-within-bazel

load("@rules_jvm_external//:defs.bzl", "DEFAULT_REPOSITORY_NAME")
load("@rules_jvm_external//:specs.bzl", "maven")
load("//tools:maven_utils.bzl", "format_maven_jar_dep_name", "format_maven_jar_name")

# See: https://checkstyle.sourceforge.io/dependencies.html
DEPENDENCIES = [
    ("com.puppycrawl.tools", "checkstyle", "8.26"),
    # Direct
    ("antlr", "antlr", "2.7.7"),
    ("com.google.guava", "guava", "28.1-jre"),
    ("commons-beanutils", "commons-beanutils", "1.9.4"),
    ("info.picocli", "picocli", "4.0.4"),
    ("net.sf.saxon", "Saxon-HE", "9.9.1-5"),
    ("org.antlr", "antlr4-runtime", "4.7.2"),
    ("org.slf4j", "slf4j-api", "1.7.28"),
    ("org.slf4j", "jcl-over-slf4j", "1.7.28"),
    ("org.slf4j", "slf4j-simple", "1.7.28"),
    ("commons-collections", "commons-collections", "3.2.2"),
]

def get_classpath_labels(repository = DEFAULT_REPOSITORY_NAME):
    return [
        Label(format_maven_jar_dep_name(group_id, artifact_id, repository = repository))
        for [group_id, artifact_id, _] in DEPENDENCIES
    ]

def checkstyle_artifacts():
    """
    Get all the artifacts needed for checkstyle
    TODO: support arbitrary version numbers
    """
    return [
        maven.artifact(
            group = group_id,
            artifact = artifact_id,
            version = version,
        )
        for group_id, artifact_id, version in DEPENDENCIES
    ]

def _checkstyle_test_impl(ctx):
    name = ctx.label.name
    srcs = ctx.files.srcs
    deps = ctx.files.deps
    config = ctx.file.config
    properties = ctx.file.properties
    suppressions = ctx.file.suppressions
    opts = ctx.attr.opts
    sopts = ctx.attr.string_opts

    classpath = ""
    add = False
    for file in ctx.files.classpath:
        if add:
            classpath += ":"
        add = True
        classpath += file.path
    for file in ctx.files.deps:
        classpath += ":" + file.path

    args = ""
    inputs = []
    if config:
        args += " -c %s" % config.path
        inputs.append(config)
    if properties:
        args += " -p %s" % properties.path
        inputs.append(properties)
    if suppressions:
        inputs.append(suppressions)

    cmd = " ".join(
        ["java -cp %s com.puppycrawl.tools.checkstyle.Main" % classpath] +
        [args] +
        ["--%s" % x for x in opts] +
        ["--%s %s" % (k, sopts[k]) for k in sopts] +
        [x.path for x in srcs],
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
        is_executable = True,
    )
    files = [ctx.outputs.executable] + srcs + deps + ctx.files.classpath + inputs
    runfiles = ctx.runfiles(
        files = files,
        collect_data = True,
    )
    return struct(
        files = depset(files),
        runfiles = runfiles,
    )

checkstyle_test = rule(
    implementation = _checkstyle_test_impl,
    test = True,
    attrs = {
        "classpath": attr.label_list(default = get_classpath_labels()),
        "config": attr.label(allow_single_file = True, default = "//tools/checkstyle:checkstyle-config"),
        "suppressions": attr.label(allow_single_file = True, default = "//tools/checkstyle:checkstyle-suppressions"),
        "properties": attr.label(allow_single_file = True),
        "opts": attr.string_list(),
        "string_opts": attr.string_dict(),
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
    },
)
"""Run checkstyle

Args:
  config: A checkstyle configuration file
  suppressions: A checkstyle suppressions file
  properties: A properties file to be used
  opts: Options to be passed on the command line that have no argument
  string_opts: Options to be passed on the command line that have an argument
  srcs: The files to check
"""
