"""Simulation testing"""

load("//vivado/private:scripts.bzl", "gen_simulate_script", "gen_simulate_wave_script")

TOOLCHAIN_TYPE = "@rules_vivado//vivado:toolchain_type"

def _sv_test_impl(ctx):
    vivado = ctx.toolchains[TOOLCHAIN_TYPE].vivado

    cmd_tcl = ctx.actions.declare_file("cmd.tcl")
    sim_sh = ctx.actions.declare_file("simulate.sh")
    wdb = ctx.actions.declare_file("wave.wdb")

    ctx.actions.write(
        output = cmd_tcl,
        content = gen_simulate_wave_script(),
    )

    ctx.actions.write(
        output = sim_sh,
        content = gen_simulate_script(
            sources = ctx.files.srcs,
            main = ctx.attr.main,
            wdb_path = wdb.path,
            cmd_path = cmd_tcl.path,
            xvlog = vivado.xvlog,
            xelab = vivado.xelab,
            xsim = vivado.xsim,
        ),
        is_executable = True,
    )

    ctx.actions.run(
        inputs = ctx.files.srcs + [cmd_tcl, sim_sh],
        outputs = [wdb],
        executable = sim_sh,
        progress_message = "Running simulation",
    )

    return [
        DefaultInfo(
            files = depset([
                wdb
            ]),
        ),
    ]

sv_waveform = rule(
    implementation = _sv_test_impl,
    toolchains = [TOOLCHAIN_TYPE],
    attrs = {
        "main": attr.string(
            doc = "Test main module",
            mandatory = True,
        ),
        "srcs": attr.label_list(
            doc = "SystemVerilog source files",
            allow_files = [".sv"],
            allow_empty = True,
        ),
    },
)
