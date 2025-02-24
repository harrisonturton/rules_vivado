"""Configures a Vivado toolchain for a single device"""

VivadoToolchainInfo = provider(
    "Configuration for invoking Vivado",
    fields = {
        "path": "(File) Path to the Vivado binary",
        "home": "(str) Path to the Vivado home directory",
        "part": "(str) Device part name",
        "xvlog": "(str) Path to xvlog binary",
        "xelab": "(str) Path to xelab binary",
        "xsim": "(str) Path to xsim binary",
    },
)
