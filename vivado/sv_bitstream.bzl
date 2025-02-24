"""Generate bitstream from SystemVerilog"""

load("//vivado/common:netlist_info.bzl", "VivadoNetlistInfo")
load("//vivado/common:bitstream_info.bzl", "VivadoBitstreamInfo")
load("//vivado/private:scripts.bzl", "gen_bitstream_script")

TOOLCHAIN_TYPE = "@rules_vivado//vivado:toolchain_type"
PART_NAME_CONSTRAINT = "@rules_vivado//vivado/platforms:part"

def _sv_bitstream_impl(ctx):
    vivado = ctx.toolchains[TOOLCHAIN_TYPE].vivado
    start_checkpoint = ctx.attr.netlist[VivadoNetlistInfo].checkpoint

    script = ctx.actions.declare_file("sv_bitstream.tcl")
    bitstream = ctx.actions.declare_file("bitstream.bit")
    end_checkpoint = ctx.actions.declare_file("checkpoint2.dsp")

    ctx.actions.write(
        output = script,
        content = gen_bitstream_script(
            start_checkpoint_path = start_checkpoint.path,
            end_checkpoint_path = end_checkpoint.path,
            bitstream_path = bitstream.path,
        ),
    )

    ctx.actions.run(
        inputs = [start_checkpoint, script],
        outputs = [bitstream, end_checkpoint],
        executable = vivado.path,
        arguments = ["-mode", "batch", "-source", script.path],
        toolchain = TOOLCHAIN_TYPE,
        progress_message = "Generating bitstream",
        env = {"HOME": vivado.home},
    )

    return [
        DefaultInfo(
            files = depset([
                bitstream,
                end_checkpoint,
            ]),
        ),
        VivadoBitstreamInfo(
            bitstream = bitstream,
            checkpoint = end_checkpoint,
        ),
    ]

sv_bitstream = rule(
    implementation = _sv_bitstream_impl,
    toolchains = [TOOLCHAIN_TYPE],
    attrs = {
        "netlist": attr.label(
            doc = "Netlist to generate the bitstream from",
            providers = [VivadoNetlistInfo],
            mandatory = True,
        ),
    },
)
