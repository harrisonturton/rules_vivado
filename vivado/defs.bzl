"""Rules for building Vivado FPGA projects"""

load("//vivado:sv_bitstream.bzl", _sv_bitstream = "sv_bitstream")
load("//vivado:sv_netlist.bzl", _sv_netlist = "sv_netlist")
load("//vivado:sv_test.bzl", _sv_test = "sv_waveform")
load("//vivado:vivado_install.bzl", _vivado_install = "vivado_install")
load("//vivado/common:netlist_info.bzl", _VivadoNetlistInfo = "VivadoNetlistInfo")
load("//vivado/toolchains:vivado_toolchain.bzl", _vivado_toolchain = "vivado_toolchain")
load("//vivado/toolchains:vivado_toolchain_info.bzl", _VivadoToolchainInfo = "VivadoToolchainInfo")

# Rules

sv_bitstream = _sv_bitstream
sv_netlist = _sv_netlist
sv_test = _sv_test
vivado_install = _vivado_install
vivado_toolchain = _vivado_toolchain

# Providers

VivadoNetlistInfo = _VivadoNetlistInfo
VivadoToolchainInfo = _VivadoToolchainInfo