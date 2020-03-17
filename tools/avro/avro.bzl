# Modified from https://github.com/meetup/rules_avro
# replace if this PR is merge: https://github.com/meetup/rules_avro/pull/7

load("@rules_jvm_external//:defs.bzl", "DEFAULT_REPOSITORY_NAME")
load("@rules_jvm_external//:specs.bzl", "maven")
load("//tools:maven_utils.bzl", "format_maven_jar_dep_name")

AVRO_TOOLS = ("org.apache.avro", "avro-tools")
AVRO = ("org.apache.avro", "avro")

def _common_dir(dirs):
    """
    dirs: List[String]
    """
    if not dirs:
        return ""

    if len(dirs) == 1:
        return dirs[0]

    split_dirs = [dir.split("/") for dir in dirs]

    shortest = min(split_dirs)
    longest = max(split_dirs)

    for i, piece in enumerate(shortest):
        # if the next dir does not match, we've found our common parent
        if piece != longest[i]:
            return "/".join(shortest[:i])

    return "/".join(shortest)

def _flatten_commands(commands):
    return " && ".join(commands)

def _new_avsc_generator_command(ctx, srcs, gen_dir):
    java_path = ctx.attr._jdk[java_common.JavaRuntimeInfo].java_executable_exec_path
    gen_command = "{java} -jar {tool} compile ".format(
        java = java_path,
        tool = ctx.file._avro_tools.path,
    )

    if ctx.attr.strings:
        gen_command += " -string"

    if ctx.attr.encoding:
        gen_command += " -encoding {encoding}".format(
            encoding = ctx.attr.encoding,
        )

    gen_command += " schema"
    for src in srcs:
        gen_command += " " + src.path

    gen_command += " {gen_dir}".format(
        gen_dir = gen_dir,
    )

    return gen_command

def _avro_avsc_gen_impl(ctx):
    avsc_srcs = ctx.files.srcs
    avsc_src_dir = _common_dir([f.dirname for f in avsc_srcs])

    # Create gen dirs
    gen_dir = "{out}-tmp".format(out = ctx.outputs.codegen.path)

    inputs = ctx.files._jdk + [ctx.file._avro_tools]

    commands = [
        "mkdir -p {gen_dir}".format(gen_dir = gen_dir),
    ]

    if len(avsc_srcs) > 0:
        inputs += avsc_srcs
        commands += [
            _new_avsc_generator_command(ctx, sorted(avsc_srcs, reverse = True), gen_dir),
        ]

    # now generate the java from the avsc

    commands += [
        # forcing a timestamp for deterministic artifacts
        "find {gen_dir} -exec touch -t 198001010000 {{}} \;".format(
            gen_dir = gen_dir,
        ),
        # package up as a .jar
        "{jar} cMf {output} -C {gen_dir} .".format(
            jar = "%s/bin/jar" % ctx.attr._jdk[java_common.JavaRuntimeInfo].java_home,
            output = ctx.outputs.codegen.path,
            gen_dir = gen_dir,
        ),
    ]

    ctx.actions.run_shell(
        inputs = sorted(inputs),
        outputs = [ctx.outputs.codegen],
        command = _flatten_commands(commands),
        progress_message = "generating java sources from avro schemas",
        arguments = [],
    )

    return struct(
        codegen = ctx.outputs.codegen,
    )

avro_avsc_gen = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".avsc"],
        ),
        "deps": attr.label_list(),
        "strings": attr.bool(),
        "encoding": attr.string(),
        "_jdk": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
            providers = [java_common.JavaRuntimeInfo],
        ),
        "_avro_tools": attr.label(
            cfg = "host",
            default = Label(
                format_maven_jar_dep_name(
                    group_id = AVRO_TOOLS[0],
                    artifact_id = AVRO_TOOLS[1],
                    repository = DEFAULT_REPOSITORY_NAME,
                ),
            ),
            allow_single_file = True,
        ),
    },
    outputs = {
        "codegen": "%{name}_codegen.srcjar",
    },
    implementation = _avro_avsc_gen_impl,
)

def avro_java_library(
        name,
        srcs = [],
        strings = None,
        encoding = None,
        visibility = None):
    avro_avsc_gen(
        name = name + "_srcjar",
        srcs = srcs,
        strings = strings,
        encoding = encoding,
        visibility = visibility,
    )
    native.java_library(
        name = name,
        srcs = [name + "_srcjar"],
        deps = [
            Label(
                format_maven_jar_dep_name(
                    group_id = AVRO[0],
                    artifact_id = AVRO[1],
                    repository = DEFAULT_REPOSITORY_NAME,
                ),
            ),
        ],
        visibility = visibility,
    )

def avro_artifacts(version = "1.8.2"):
    """
    version: str = "1.8.2" - the version of avro to fetch
    """
    return [
        maven.artifact(
            group = group_id,
            artifact = artifact_id,
            version = version,
        )
        for [group_id, artifact_id] in [AVRO, AVRO_TOOLS]
    ]
