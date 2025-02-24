"""Creates a Vivado toolchain for a given device"""

load(":vivado_toolchain_info.bzl", "VivadoToolchainInfo")

def _vivado_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            vivado = VivadoToolchainInfo(
                path = ctx.attr.path,
                part = ctx.attr.part,
                home = ctx.attr.home,
                xvlog = ctx.attr.xvlog,
                xelab = ctx.attr.xelab,
                xsim = ctx.attr.xsim,
            ),
        ),
    ]

vivado_toolchain = rule(
    implementation = _vivado_toolchain_impl,
    attrs = {
        "path": attr.string(
            doc = "Path of the Vivado binary",
            mandatory = True,
        ),
        "part": attr.string(
            doc = "FPGA part",
            mandatory = True,
        ),
        "home": attr.string(
            doc = "Vivado home directory",
            mandatory = True,
        ),
        "xvlog": attr.string(
            doc = "Vivado xvlog binary",
            mandatory = True,
        ),
        "xelab": attr.string(
            doc = "Vivado xelab binary",
            mandatory = True,
        ),
        "xsim": attr.string(
            doc = "Vivado xsim binary",
            mandatory = True,
        ),
    },
)
