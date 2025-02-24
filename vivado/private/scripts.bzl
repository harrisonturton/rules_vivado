"""Constructors for generating Vivaco Tcl scripts"""

_SYNTH_SCRIPT = """
set_part "{part}"

{read_sources}
{read_constraints}

synth_design -top "{main}" -part "{part}"

write_verilog "{netlist_path}"
write_checkpoint "{end_checkpoint_path}"
"""

_BITSTREAM_SCRIPT = """
open_checkpoint "{start_checkpoint_path}"

opt_design
place_design
route_design

write_bitstream "{bitstream_path}"
write_checkpoint "{end_checkpoint_path}"
"""

_READ_XDC = """
read_xdc "{path}"
"""

_READ_SV = """
read_verilog -sv "{path}"
"""

_INSTALL = """
open_checkpoint "{start_checkpoint_path}"

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

set_property PROGRAM.FILE "{bitstream_path}" [get_hw_devices "{device_name}"]
current_hw_device [get_hw_devices "{device_name}"]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices "{device_name}"] 0]
program_hw_devices [get_hw_devices "{device_name}"]

write_checkpoint "{end_checkpoint_path}"
"""

_SIMULATE_CMD_TCL = """
set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
  if { [llength [get_objects]] > 0} {
    add_wave /
    set_property needs_save false [current_wave_config]
  } else {
     send_msg_id Add_Wave-1 WARNING "No top level signals found. Simulator will start without a wave window. If you want to open a wave window go to 'File->New Waveform Configuration' or type 'create_wave_config' in the TCL console."
  }
}

run 1000ns
quit
"""

_SIMULATE_SH = """
{xvlog_sources}

{xelab} --debug typical main.{main}
{xsim} main.test_main -tclbatch {cmd_path} -log simulate.log -wdb "{wdb_path}"
"""

_XVLOG = """
{xvlog} -sv -work main "{path}"
"""

def _read_sv(sources):
    """TcL script snippet for reading SystemVerilog files"""
    read_sources = []
    for file in sources:
        read_sources.append(_READ_SV.format(path = file.path))
    return "\n".join(read_sources)

def _read_xdc(xdc):
    """Tcl script snippet for reading XDC files"""
    read_xdc = []
    for file in xdc:
        read_xdc.append(_READ_XDC.format(path = file.path))
    return "\n".join(read_xdc)

def _read_xvlog(xvlog, sources):
    read_xvlog = []
    for file in sources:
        read_xvlog.append(
            _XVLOG.format(
                xvlog = xvlog,
                path = file.path,
            ),
        )
    return "\n".join(read_xvlog)

def gen_simulate_wave_script():
    return _SIMULATE_CMD_TCL

def gen_simulate_script(sources, main, wdb_path, cmd_path, xvlog, xelab, xsim):
    return _SIMULATE_SH.format(
        xvlog_sources = _read_xvlog(xvlog, sources),
        main = main,
        xvlog = xvlog,
        xelab = xelab,
        xsim = xsim,
        wdb_path = wdb_path,
        cmd_path = cmd_path,
    )

def gen_synth_script(part, main, sources, constraints, netlist_path, end_checkpoint_path):
    """Tcl script to generate the netlist"""
    return _SYNTH_SCRIPT.format(
        part = part,
        main = main,
        read_sources = _read_sv(sources),
        read_constraints = _read_xdc(constraints),
        netlist_path = netlist_path,
        end_checkpoint_path = end_checkpoint_path,
    )

def gen_bitstream_script(start_checkpoint_path, end_checkpoint_path, bitstream_path):
    """Tcl script to generate the bitstream file"""
    return _BITSTREAM_SCRIPT.format(
        start_checkpoint_path = start_checkpoint_path,
        end_checkpoint_path = end_checkpoint_path,
        bitstream_path = bitstream_path,
    )

def gen_install_script(device_name, bitstream_path, start_checkpoint_path, end_checkpoint_path):
    """Tcl script to install the bitstream onto a device"""
    return _INSTALL.format(
        device_name = device_name,
        bitstream_path = bitstream_path,
        start_checkpoint_path = start_checkpoint_path,
        end_checkpoint_path = end_checkpoint_path,
    )
