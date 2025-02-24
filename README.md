# rules_vivado

Bazel rules for building Vivado FPGA projects.

## Usage

First, define a `constraint_value` representing your FPGA part name and a
platform that uses this constraint. The platform allows us to easily target the
FPGA on the commandline.

```
constraint_value(
  name = "basys3_part",
  constraint_setting = "@rules_vivado//vivado/platforms:part",
)

platform(
  name = "basys3",
  constraint_values = [":basys3_part"],
)
```

Then use the `vivado_toolchain` rule to configure the Vivado rules:

```
load("@rules_vivado//vivado:defs.bzl", "vivado_toolchain")

vivado_toolchain(
  name = "basys3_vivado_toolchain",
  path = "<path to Vivado binary>",
  part = "<fpga part name>",
)
```

The `path` attribute must point to the Vivado binary that the build rules
orchestrate with generated TCL scripts, and the `part` attribute must match the
FPGA part name used in Vivado. This *must* match the board you are using,
otherwise the various build stages will fail or be incorrect.

Now, define the Bazel toolchain to tie it all together:

```
toolchain(
  name = "basys3_toolchain",
  toolchain_type = "@rules_vivado//vivado:toolchain_type",
  toolchain = ":basys3_vivado_toolchain",
  exec_compatible_with = [
    "@platforms//os:linux",
    "@platforms//cpu:x86_64",
  ],
  target_compatible_with = [
    ":basys3_part",
  ],
)
```

This will allow the toolchain to execute on `x86_64` Linux machines,  building
artefacts (like netlists and bistreams) for the `basys3_part` device.

The toolchain must be registered in `MODULE.bazel` before it can be used:

```
register_toolchains("//toolchains:basys3_toolchain")
```

This toolchain can then be used to compile a bitstream `.bit` file from a
SystemVerilog module:

```
load("@rules_vivado//vivado:defs.bzl", "sv_bitstream")

sv_bitstream(
  name = "main",
  main = "main",
  srcs = glob([ "**/*.sv" ]),
)
```

Where the `main` module is passed as the `top` module in Vivado.

Finally, the build can be run from the commandline with:

```
bazel build --platforms=//tools/toolchains/vivado:basys3 //main
```
