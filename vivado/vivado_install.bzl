"""Rule to install the bistream on a device"""

load("//vivado/common:bitstream_info.bzl", "VivadoBitstreamInfo")
load("//vivado/private:scripts.bzl", "gen_install_script")

TOOLCHAIN_TYPE = "@rules_vivado//vivado:toolchain_type"

def _vivado_install_impl(ctx):
    vivado = ctx.toolchains[TOOLCHAIN_TYPE].vivado
    bitstream_info = ctx.attr.bitstream[VivadoBitstreamInfo]
    
    script = ctx.actions.declare_file("vivado_install.tcl")
    end_checkpoint = ctx.actions.declare_file("install.dcp")

    ctx.actions.write(
      output = script,
      content = gen_install_script(
        bitstream_path = bitstream_info.bitstream.path,
        device_name = ctx.attr.device_name,
        start_checkpoint_path = bitstream_info.checkpoint.path,
        end_checkpoint_path = end_checkpoint.path,
      ),
    )

    ctx.actions.run(
        inputs = [script, bitstream_info.bitstream, bitstream_info.checkpoint],
        executable = vivado.path,
        outputs = [end_checkpoint],
        arguments = ["-mode", "batch", "-source", script.path],
        toolchain = TOOLCHAIN_TYPE,
        progress_message = "Installing bitstream",
        env = {"HOME": vivado.home},
    )

    return [
        DefaultInfo(
            files = depset([
                end_checkpoint,
            ]),
        ),
    ]

vivado_install = rule(
    implementation = _vivado_install_impl,
    toolchains = [TOOLCHAIN_TYPE],
    attrs = {
        "bitstream": attr.label(
            doc = "Bitstream to install",
            providers = [VivadoBitstreamInfo],
        ),
        "device_name": attr.string(
            doc = "Device name to install against",
            mandatory = True,
        ),
    },
)
