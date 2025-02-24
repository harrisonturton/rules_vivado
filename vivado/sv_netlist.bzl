"""Synthesize SystemVerilog"""

load("//vivado/common:netlist_info.bzl", "VivadoNetlistInfo")
load("//vivado/private:scripts.bzl", "gen_synth_script")

TOOLCHAIN_TYPE = "@rules_vivado//vivado:toolchain_type"
PART_NAME_CONSTRAINT = "@rules_vivado//vivado/platforms:part"

def _sv_netlist_impl(ctx):
    vivado = ctx.toolchains[TOOLCHAIN_TYPE].vivado

    script = ctx.actions.declare_file("script.tcl")
    netlist = ctx.actions.declare_file("netlist.v")
    checkpoint = ctx.actions.declare_file("synth.dcp")

    ctx.actions.write(
        output = script,
        content = gen_synth_script(
            part = vivado.part,
            main = ctx.attr.main,
            sources = ctx.files.srcs,
            constraints = ctx.files.constraints,
            netlist_path = netlist.path,
            end_checkpoint_path = checkpoint.path,
        ),
    )

    ctx.actions.run(
        inputs = ctx.files.srcs + ctx.files.constraints + [script],
        outputs = [netlist, checkpoint],
        executable = vivado.path,
        arguments = ["-mode", "batch", "-source", script.path],
        toolchain = TOOLCHAIN_TYPE,
        progress_message = "Generating netlist",
        env = {"HOME": vivado.home},
    )

    return [
        DefaultInfo(
            files = depset([
                netlist,
                checkpoint,
            ]),
        ),
        VivadoNetlistInfo(
            netlist = netlist,
            checkpoint = checkpoint,
        ),
    ]

sv_netlist = rule(
    implementation = _sv_netlist_impl,
    toolchains = [TOOLCHAIN_TYPE],
    attrs = {
        "main": attr.string(
            doc = "Main module",
        ),
        "srcs": attr.label_list(
            doc = "SystemVerilog source files",
            allow_files = [".sv"],
            allow_empty = True,
        ),
        "constraints": attr.label_list(
            doc = "XDC constraint files",
            allow_files = [".xdc"],
            allow_empty = True,
        ),
    },
)
